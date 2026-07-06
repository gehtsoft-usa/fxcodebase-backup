-- Id: 1430
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
    strategy:name("Conqueror method Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Conqueror method Signal");

    strategy.parameters:addGroup("Parameters");
	
	strategy.parameters:addGroup("Calculation"); 
    strategy.parameters:addInteger("Frame", "Number of Periods", "", 10);
	strategy.parameters:addInteger("RANGE", "Range Period", "Range Period", 40);

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
local BarSource = nil; 

local Frame = nil;
local Range=nil;
local SIGNAL=nil;
	
function Prepare()
    -- collect parameters
	
	Frame = instance.parameters.Frame;
	Range = instance.parameters.RANGE;
		
    ShowAlert = instance.parameters.ShowAlert;
	
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
		
     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");

    ExtSetupSignal(" Conqueror method ", ShowAlert);

    BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
	
    assert(core.indicators:findIndicator("CONQUEROR") ~= nil, "CONQUEROR" .. " indicator must be installed");
	SIGNAL  = core.indicators:create("CONQUEROR", BarSource, Frame, Range);	
	
   
	
    local name = profile:id() .. "(" .. instance.bid:instrument()  .. ")" 
    instance:name(name);
end


-- when tick source is updated
function ExtUpdate(id, source, period)	
   
    if period >= math.max(Frame, Range) then

                  SIGNAL:update(core.UpdateLast); 	              
				 
                 if SIGNAL.UP[period]== 1 and SIGNAL.UP[period-1]~= 1 then
				 ExtSignal(BarSource.close, period, " Open Long Position", SoundFile);
                 elseif SIGNAL.DOWN[period]== 1  and SIGNAL.DOWN[period-1]~= 1 then
				 ExtSignal(BarSource.close, period, " Open Short Position  ", SoundFile);
				 elseif SIGNAL.NEUTRAL[period]== 1  and SIGNAL.NEUTRAL[period-1]~= 1  then
				 ExtSignal(BarSource.close, period, " Tighten  The Stops  ", SoundFile);
                 end	
	end						   
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
