-- Id: 1714
--+------------------------------------------------------------------+
--|                                              GMMACD Signal.lua   |
--|                               Copyright © 2015, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: http://goo.gl/cEP5h5  |
--|                    BitCoin : 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |  
--+------------------------------------------------------------------+

function Init()
    strategy:name("GMMACD Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Signal in generated when GMMACD  crosses Over/Under the zero line");

    strategy.parameters:addGroup("Parameters");
		 
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addString("Period", "Timeframe", "", "m5");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
	strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	strategy.parameters:addBoolean("SendEmail", "Send email", "", false);
    strategy.parameters:addString("Email", "Email address", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local ShowAlert;
local SoundFile;
local BUY, SELL;
local TickSource = nil;         -- the source stream
local GMMACD = nil;  
local Email;
local RecurrentSound;
function Prepare()
    -- collect parameters
		   
    ShowAlert = instance.parameters.ShowAlert;
	
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
		RecurrentSound = instance.parameters.RecurrentSound;
    else
        SoundFile = nil;
		RecurrentSound  = nil;
    end
	
	
     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");
	 
	 SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "Email address must be specified");
	 

    SELL = " Strong DownTrend";
    BUY = " Strong UpTrend";

    ExtSetupSignal("GMMACD", ShowAlert);
	ExtSetupSignalMail(name);

    TickSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "close");
    assert(core.indicators:findIndicator("GMMACD") ~= nil, "GMMACD" .. " indicator must be installed");
	GMMACD  = core.indicators:create("GMMACD", TickSource);	
	
    local name = profile:id() .. "(" .. instance.bid:instrument()  .. ")" 
    instance:name(name);
end


-- when tick source is updated
function ExtUpdate(id, source, period)	
       
     GMMACD:update(core.UpdateLast);
	 
	 	          if not(GMMACD.DATA:hasData(period - 1)) then
				  		return ;
				  	end

		   
	
				
					if core.crossesOver( GMMACD.DATA, 0, period)  then
					  ExtSignal(TickSource, period, BUY, SoundFile, Email, RecurrentSound);
					end 	
					
				
					if core.crossesUnder( GMMACD.DATA, 0, period)then 
					  ExtSignal(TickSource, period, SELL, SoundFile, Email, RecurrentSound);
					end 	
				
		
						  
							   
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
