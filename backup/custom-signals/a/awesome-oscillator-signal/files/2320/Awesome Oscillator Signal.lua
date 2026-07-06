-- Id: 806

-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=29&t=1224

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+


function Init()
    strategy:name("Awesome Oscillator Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Signal in generated when Awesome Oscillator crosses Over/Under the zero line");

    strategy.parameters:addGroup("Parameters");

 
    strategy.parameters:addInteger("FP", "Period", "", 5,2,2000); 
    strategy.parameters:addInteger("SP", "Period", "", 35,2,2000); 
	strategy.parameters:addBoolean("SCS", "Saucer Signal", "", false);
		
		 
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addString("Period", "Timeframe", "", "m5");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
end

local ShowAlert;
local SoundFile;
local BUY, SELL;
local BarSource = nil;         -- the source stream
local Fast=0;
local Slow=0;
local Flag=nil;
local AO=nil;
local Saucer;

function Prepare()
    -- collect parameters
	
	Fast = instance.parameters.FP;
    Slow = instance.parameters.SP;
	Saucer= instance.parameters.SCS;
	
	   
    ShowAlert = instance.parameters.ShowAlert;
	
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
	
	
     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");

    SELL = "Short";
    BUY = "Long";

    ExtSetupSignal("Awesome Oscillator", ShowAlert);

    BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
	
	AO  = core.indicators:create("AO", BarSource, Fast, Slow,  core.rgb(0, 255, 0),  core.rgb(255,0, 0));
	
    local name = profile:id() .. "(" .. instance.bid:instrument()  .. ")" 
    instance:name(name);
end


-- when tick source is updated
function ExtUpdate(id, source, period)	
       
     AO:update(core.UpdateLast);
		   
		if period > Fast then	
		
				
					if AO.AO[period] >0 and AO.AO[period-1] <= 0 and  Flag ~= "Buy" then 
					 Flag="Buy";
					 ExtSignal(BarSource.close, period, BUY, SoundFile);
					end 	
					
				
					if AO.AO[period] <0 and AO.AO[period-1] >= 0  and Flag ~= "Sell" then 
					 Flag="Sell";
					 ExtSignal(BarSource.close, period, SELL, SoundFile);
					end 	
				
				if (Saucer) then
					if AO.AO:colorI(period-2) ~=  core.rgb(0, 255, 0) and AO.AO:colorI(period-1) ~=  core.rgb(0, 255, 0)and AO.AO:colorI(period) ==  core.rgb(0, 255, 0)  and  AO.AO[period] > 0   then 
					 Flag="Buy";
					 ExtSignal(BarSource.close, period, BUY, SoundFile);
					end 	
					
					if AO.AO:colorI(period-2) ~=  core.rgb(255, 0, 0) and  AO.AO:colorI(period-1) ~=  core.rgb(255, 0, 0)  and  AO.AO:colorI(period) ==  core.rgb(255, 0, 0)   and AO.AO[period] < 0 then 
					 Flag="Sell";
					 ExtSignal(BarSource.close, period, SELL, SoundFile);
					end 	
				
				 end
				  
		 end				
				
						  
							   
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
