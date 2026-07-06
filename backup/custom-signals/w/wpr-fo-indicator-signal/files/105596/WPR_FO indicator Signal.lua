-- Id: 15810
--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--|                                 Support our efforts by donating  | 
--|                                    Paypal: http://goo.gl/cEP5h5  |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                    BitCoin : 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |  
--+------------------------------------------------------------------+


function Init()
    strategy:name("WPR_FO indicator Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("");

    strategy.parameters:addGroup("Calculation");
    strategy.parameters:addInteger("WPR_Period", "WPR Period", "", 5);
    strategy.parameters:addInteger("MA_Period", "MA_Period", "", 9);
    strategy.parameters:addString("Method", "Method", "", "MVA");
    strategy.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    strategy.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    strategy.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    strategy.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    strategy.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    strategy.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    strategy.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    strategy.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    strategy.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    strategy.parameters:addStringAlternative("Method", "T3", "", "T3");
    strategy.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    strategy.parameters:addStringAlternative("Method", "Median", "", "Median");
    strategy.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    strategy.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    strategy.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    strategy.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    strategy.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    strategy.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");	
		 
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addString("TF", "Timeframe", "", "m5");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
	 strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
	
	 strategy.parameters:addBoolean("SendEmail", "Send Email", "", true);
    strategy.parameters:addString("Email", "Email", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local first;
local ShowAlert;
local SoundFile;
local BUY, SELL;
local BarSource = nil;         -- the source stream
local Email;
local SendEmail;
local RecurrentSound;
local Indicator=nil;
local WPR_Period;
local MA_Period;
local Method;
local TF;
function Prepare()
    -- collect parameters	
	WPR_Period = instance.parameters.WPR_Period;
	MA_Period = instance.parameters.MA_Period;
    Method = instance.parameters.Method;
	TF= instance.parameters.TF;
	   
    ShowAlert = instance.parameters.ShowAlert;
	
   if PlaySound then
        SoundFile = instance.parameters.SoundFile;
        RecurrentSound = instance.parameters.RecurrentSound;
    else
        SoundFile = nil;
        RecurrentSound = false;
    end
	
	 SendEmail = instance.parameters.SendEmail;
	 RecurrentSound = instance.parameters.RecurrentSound;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "Email address must be specified");
	
	
     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");

    assert(core.indicators:findIndicator("WPR_FO") ~= nil, "Please, download and install WPR_FO.LUA indicator");
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");

    BarSource = ExtSubscribe(1, nil, TF, instance.parameters.Type == "Bid", "bar");
	
	Indicator  = core.indicators:create("WPR_FO", BarSource, WPR_Period, MA_Period, Method, core.rgb(0, 0, 255), core.rgb(0, 255,0 ), core.rgb(255, 0, 0));
	first= Indicator.DATA:first();
	
        local name = profile:id() .. "(" ..  instance.bid:instrument() .. ", " .. TF   .. ", " .. WPR_Period.. ", " .. MA_Period.. ", " .. Method .. ")";
         instance:name(name);
 
    ExtSetupSignal(profile:id() .. ":", ShowAlert);
    ExtSetupSignalMail(name);		
	
end


-- when tick source is updated
function ExtUpdate(id, source, period)	
       
     Indicator:update(core.UpdateLast);
		   
		if  period  <  first then
		return;
		end
			
					 if  Indicator.DATA:colorI(period) ==  core.rgb(0, 255, 0) 
					 and Indicator.DATA:colorI(period-1) ~=  core.rgb(0, 255, 0) 
					 then
					 ExtSignal(BarSource.close, period, "Up Trend", SoundFile, Email, RecurrentSound);			
				     elseif  Indicator.DATA:colorI(period) ==  core.rgb(255, 0, 0) 
					 and Indicator.DATA:colorI(period-1) ~=  core.rgb(255, 0, 0) 
					 then				
					 ExtSignal(BarSource.close, period, "Down Trend", SoundFile, Email, RecurrentSound);
				 	 elseif  Indicator.DATA:colorI(period) ==  core.rgb(0, 0, 255) 
					 and Indicator.DATA:colorI(period-1) ~=  core.rgb(0, 0, 255) 
					 then				
					 ExtSignal(BarSource.close, period, "Neutral Trend", SoundFile, Email, RecurrentSound);
					 end
				
						  
							   
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
