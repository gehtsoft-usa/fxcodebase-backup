-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=40074
-- Id: 9260

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
    indicator:name("Stochastic MACD");
    indicator:description("Stochastic MACD");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Short", "Short Period", "Short Period", 12);
    indicator.parameters:addInteger("Long", "Long Period", "Long Period", 35);
    indicator.parameters:addInteger("Signal", "Signal Period", "Signal Period", 9);
	indicator.parameters:addInteger("Stochastic", "Stochastic Period", "Stochastic Period", 18);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("STOCHMACD_color", "Color of STOCHMACD", "Color of STOCHMACD", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 80);
    indicator.parameters:addDouble("oversold","Oversold Level","", 20);
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
local Short;
local Long;
local Signal;
local Method;
local Stochastic;
local source = nil;
local B1, B2, E1, E2;
-- Streams block
local STOCHMACD = nil;

-- Routine
function Prepare(nameOnly)
    Short = instance.parameters.Short;
    Long = instance.parameters.Long;
    Signal = instance.parameters.Signal;
	Method = instance.parameters.Method;
	Stochastic = instance.parameters.Stochastic;
    source = instance.source;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Short) .. ", " .. tostring(Long) .. ", " .. tostring(Signal) .. ", " .. tostring(Method)  .. ", " .. tostring(Stochastic).. ")";
    instance:name(name);

    if (not (nameOnly)) then
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
        E1 = core.indicators:create(Method, source, Short);
        E2 = core.indicators:create(Method, source, Long);
        B1= instance:addInternalStream(0, 0);
        E3 = core.indicators:create(Method, B1, Signal);
        B2= instance:addInternalStream(0, 0);
        STOCHMACD = instance:addStream("STOCHMACD", core.Line, name, "STOCHMACD", instance.parameters.STOCHMACD_color, E3.DATA:first());
    STOCHMACD:setPrecision(math.max(2, instance.source:getPrecision()));
		STOCHMACD:setWidth(instance.parameters.width);
        STOCHMACD:setStyle(instance.parameters.style);
		STOCHMACD:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		STOCHMACD:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    E1:update(mode);
    E2:update(mode);
	
    if period< math.max(E1.DATA:first(), E2.DATA:first())  then
	return;
	end
	
	 B1[period]= E1.DATA[period]-E2.DATA[period];
	 
	 E3:update(mode);
	  if period< E3.DATA:first()   then
	return;
	end
	  
--[[
	100*(( Mov( C,12,E ) - Mov( C,35,E ) ) - Mov( ( Mov( C,12,E ) - Mov( C,35,E ) ),9,E )
-LLV(( Mov( C,12,E ) - Mov( C,35,E ) ) - Mov( ( Mov( C,12,E ) - Mov( C,35,E ) ),9,E ),18))
 / (HHV(( Mov( C,12,E ) - Mov( C,35,E ) ) - Mov( ( Mov( C,12,E ) - Mov( C,35,E ) ),9,E ),18)-LLV(( Mov( C,12,E ) - Mov( C,35,E ) ) - Mov( ( Mov( C,12,E ) - Mov( C,35,E ) ),9,E ),18))
   ]]
   
   B2[period]= B1[period] - E3.DATA[period];

   
    STOCHMACD[period] =100*(( B1[period]) - E3.DATA[period]  -mathex.min(B2, period -Stochastic+1, period))/(mathex.max(B2, period -Stochastic+1, period)-mathex.min(B2, period -Stochastic+1, period) );
				
    
end

