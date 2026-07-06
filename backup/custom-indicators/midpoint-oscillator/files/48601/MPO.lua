-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27748
-- Id: 8123

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
    indicator:name("Midpoint Oscillator");
    indicator:description("Midpoint Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 26);
    indicator.parameters:addInteger("Smoothing", "Smoothing Period", "Smoothing Period", 9);
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
    indicator.parameters:addColor("M_color", "Color of M", "Color of M", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	 indicator.parameters:addColor("S_color", "Color of S", "Color of S", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 67);
    indicator.parameters:addDouble("oversold","Oversold Level","", -67);
	indicator.parameters:addDouble("max", "Top Line","", 100);
    indicator.parameters:addDouble("min","Bottom Line","", -100);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Smoothing;
local MA;
local first;
local source = nil;
local Method;
-- Streams block
local M , S;
 
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Method = instance.parameters.Method;
    Smoothing = instance.parameters.Smoothing;
    source = instance.source;
    first = source:first()+Period;
	 

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Smoothing)  .. ", " .. tostring(Method).. ")";
    instance:name(name);

    if (not (nameOnly)) then
        M = instance:addStream("M", core.Line, name, "M", instance.parameters.M_color, first);
    M:setPrecision(math.max(2, instance.source:getPrecision()));
		M:setWidth(instance.parameters.width1);
        M:setStyle(instance.parameters.style1);
		M:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		M:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		MA = core.indicators:create( Method,M, Smoothing);
		S = instance:addStream("S", core.Line, name, "S", instance.parameters.S_color, MA.DATA:first());
    S:setPrecision(math.max(2, instance.source:getPrecision()));
		S:setWidth(instance.parameters.width2);
        S:setStyle(instance.parameters.style2);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period  < first   then
	return;
	end
	
	local min,max; 
    min, max  = mathex.minmax(source, period - Period + 1, period);
	
	  M[period] = 100*(2*source.close[period]- max-min)/(max-min) ;
	  
	  MA:update(mode);
	 
	 if period < MA.DATA:first() then
	 return;
	 end
	
	  S[period] = MA.DATA[period] ;
      
     
end

