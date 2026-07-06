-- Id: 1326
-- More information about this indicator can be found at:
-- http://fxcodebase.com/

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
function Init()
    strategy:name("Flat/Trend Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Flat/Trend Signal");

    strategy.parameters:addGroup("Parameters");
	
	strategy.parameters:addInteger("MACD_Fast", "MACD_Fast", "Period for fast MACD", 12);
    strategy.parameters:addInteger("MACD_Slow", "MACD_Slow", "Period for slow MACD", 26);
    strategy.parameters:addInteger("MACD_MA", "MACD_MA", "Period for signal MACD", 9);

		 
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

local MACD_Fast;
local MACD_Slow;
local MACD_MA;

local Flag=nil;
local Zero=nil;

local first=nil;

local ShowAlert;
local SoundFile;
local BarSource = nil; 

local Trend=nil;

function Prepare()
    -- collect parameters
	
	MACD_Fast=instance.parameters.MACD_Fast;
    MACD_Slow=instance.parameters.MACD_Slow;
    MACD_MA=instance.parameters.MACD_MA;
  
		   
    ShowAlert = instance.parameters.ShowAlert;
	
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
		
     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");

    ExtSetupSignal(" Flat/Trend", ShowAlert);

   
	BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
	
	  MACD = core.indicators:create("MACD", BarSource.close, MACD_Fast, MACD_Slow, MACD_MA);
	
	
	first = MACD.DATA:first()+MACD_MA;	
	

		
    local name = profile:id() .. "(" .. instance.bid:instrument()  .. ")" 
    instance:name(name);
end


-- when tick source is updated
function ExtUpdate(id, source, period)	


                              
				  
	 	          
	if period >= first then	
	
	MACD:update(core.UpdateLast); 	
		   
		            if core.crossesOver(MACD.MACD,MACD.SIGNAL, period)  then
					 Flag=true;
				    end 						
				
					if core.crossesUnder( MACD.MACD,MACD.SIGNAL,period)then 
					 Flag=false;
					end 	
					
					if core.crossesOver(MACD.MACD,0, period)  then
					 Zero=true;
				    end 						
				
					if core.crossesUnder( MACD.MACD,0, period)then 
					 Zero=false;
					end 	
				
				    if Flag  and Zero  and   Trend ~= "UP" then
					ExtSignal(BarSource.close, period, " Up Trend "  , SoundFile);
					Trend = "UP"
					elseif not Flag and not Zero and  Trend ~= "DOWN" then 
					ExtSignal(BarSource.close, period, " Down Trend", SoundFile);
					Trend = "DOWN"
					elseif Flag and not Zero and  Trend ~= "NEUTRAL" then
					ExtSignal(BarSource.close, period, " Neutral ", SoundFile);
					Trend = "NEUTRAL"
					elseif not Flag and  Zero and  Trend ~= "NEUTRAL" then
					ExtSignal(BarSource.close, period, " Neutral ", SoundFile);
					Trend = "NEUTRAL"
					end
					
					
	end				  
							   
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
