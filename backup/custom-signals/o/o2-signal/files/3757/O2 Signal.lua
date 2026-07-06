-- Id: 1301
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
    strategy:name("O2 Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("o2 Signal");

    strategy.parameters:addGroup("Parameters");
	
	strategy.parameters:addInteger("SF", "SHORT EMA Period", "", 9, 2, 2000); 
    strategy.parameters:addInteger("MF", "MEDIUM EMA Period", "", 25, 2, 2000);
	strategy.parameters:addInteger("LF", "LONG EMA Period", "", 35, 2, 2000);
		 
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


local LONG=nil;
local MEDIUM=nil;
local SHORT=nil;

local first=nil;

local LF, MF, SF;

local ShowAlert;
local SoundFile;
local BarSource = nil; 

function Prepare()
    -- collect parameters
	
	SF = instance.parameters.SF;
    MF = instance.parameters.MF;
	LF = instance.parameters.LF;
		   
    ShowAlert = instance.parameters.ShowAlert;
	
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
		
     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");

    ExtSetupSignal(" O2", ShowAlert);

   -- TickSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "close");
	BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
	
	LONG  = core.indicators:create("EMA", BarSource.close, LF);	
	MEDIUM  = core.indicators:create("EMA", BarSource.close, MF);
	SHORT  = core.indicators:create("EMA", BarSource.close, SF);
	
	first = math.max(BarSource:first() + 3, SHORT.DATA:first() + 1, MEDIUM.DATA:first() + 1, LONG.DATA:first() + 1);	
	

		
    local name = profile:id() .. "(" .. instance.bid:instrument()  .. ")" 
    instance:name(name);
end


-- when tick source is updated
function ExtUpdate(id, source, period)	


                  SHORT:update(core.UpdateLast); 	              
				  MEDIUM:update(core.UpdateLast);	 	         
				  LONG:update(core.UpdateLast);	 
	 	          
	if period >= first then	
	
		   
		           if core.crossesOver( SHORT.DATA, MEDIUM.DATA, period)  then
					  ExtSignal(BarSource.close, period, " EMA "..SF.." EMA ".. MF .." Bullish Cross Over "  , SoundFile);
				    end 						
				
					if core.crossesUnder( SHORT.DATA, MEDIUM.DATA, period)then 
					  ExtSignal(BarSource.close, period, " EMA "..SF.." EMA ".. MF .." Bearish Cross Over ", SoundFile);
					end 	
				
					if core.crossesOver( SHORT.DATA, LONG.DATA, period)  then
					  ExtSignal(BarSource.close, period, " EMA "..SF.." EMA ".. LF .." Bullish Cross Over "  , SoundFile);
					end 
				
					if core.crossesUnder( SHORT.DATA, LONG.DATA, period)then 
					  ExtSignal(BarSource.close, period, " EMA "..SF.." EMA ".. LF .." Bearish Cross Over ", SoundFile);                      
					end 	
				
		            if core.crossesOver( MEDIUM.DATA, LONG.DATA, period)  then
					   ExtSignal(BarSource.close, period, " EMA "..MF.." EMA ".. LF .." Bullish Cross Over "  , SoundFile);
					end 
				
					if core.crossesUnder( MEDIUM.DATA, LONG.DATA, period)then 
					  ExtSignal(BarSource.close, period, " EMA "..MF.." EMA ".. LF .." Bearish Cross Over ", SoundFile);
					end 	
					
	end				  
							   
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
