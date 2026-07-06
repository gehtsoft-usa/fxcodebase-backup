-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27612
-- Id: 8063

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Detrended Synthetic Price");
    indicator:description("Detrended Synthetic Price");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("MA Calculation");	
    indicator.parameters:addInteger("Period1", "Period", "Period", 14);
	
	indicator.parameters:addString("Method1", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	 
	
	 indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("DSP_color", "Color of DSP", "Color of DSP", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period1,Method1; 
local MA1, MA2;
local first;
local source = nil;

-- Streams block
local DSP = nil;

-- Routine
function Prepare(nameOnly)
    Period1 = instance.parameters.Period1;
	Method1 = instance.parameters.Method1;	 
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period1) .. ", " .. tostring(Method1).. ")";
    instance:name(name);

    if (not (nameOnly)) then
        MA1 = core.indicators:create(Method1, source, Period1);
        MA2 = core.indicators:create(Method1, source, Period1*2);
        first = math.max(MA1.DATA:first(),MA2.DATA:first());
        DSP = instance:addStream("DSP", core.Line, name, "DSP", instance.parameters.DSP_color, first);
		DSP:setWidth(instance.parameters.width);
        DSP:setStyle(instance.parameters.style);
		
		DSP:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values

function Update(period, mode)

    MA1:update(mode);
	MA2:update(mode);
    
	if period < first   then
       return;
    end
	
	
	DSP[period]= MA1.DATA[period]-MA2.DATA[period];
	
end

