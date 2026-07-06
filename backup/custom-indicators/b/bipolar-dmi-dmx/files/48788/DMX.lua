-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27832
-- Id: 8170

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
    indicator:name("Bipolar DMI");
    indicator:description("Bipolar DMI");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
    indicator.parameters:addInteger("SP", "Smoothing Period", "Smoothing Period", 5);
	indicator.parameters:addString("Method", "Smoothing Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("DMX_color", "Color of DMX", "Color of DMX", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("Signal_color", "Color of Signal", "Color of Signal", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local SP;
local Method;
local first;
local source = nil;
local DMI;
-- Streams block
local DMX = nil;
local Signal, MA;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Method = instance.parameters.Method;
    SP = instance.parameters.SP;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(SP) .. ", " .. tostring(Method).. ")";
    instance:name(name);

    if (not (nameOnly)) then
        DMI = core.indicators:create("DMI", source,Period);
         first = DMI.DATA:first();
        DMX = instance:addStream("DMX", core.Line, name, "DMX", instance.parameters.DMX_color, first);
		DMX:setWidth(instance.parameters.width1);
        DMX:setStyle(instance.parameters.style1);
		MA = core.indicators:create(Method, DMX,SP);
		
		Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.Signal_color, MA.DATA:first());
		Signal:setWidth(instance.parameters.width2);
        Signal:setStyle(instance.parameters.style2);
		
		DMX:setPrecision(math.max(2, instance.source:getPrecision()));
		Signal:setPrecision(math.max(2, instance.source:getPrecision()));
		
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

   DMI:update(mode);
   
   if period < first   then
	return;
	end
        DMX[period] = ( DMI.DIP[period] - DMI.DIM[period] ) / ( DMI.DIP[period] + DMI.DIM[period] ) ;
		
		
	 MA:update(mode);
	if period < MA.DATA:first()   then
	return;
	end
    Signal[period]= MA.DATA[period];
end

