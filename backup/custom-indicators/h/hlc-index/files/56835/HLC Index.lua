-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=33497
-- Id: 8757

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
    indicator:name("HLC INDEX");
    indicator:description("HLC INDEX");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("One", "1. Smoothing Period", "Period", 5);
	indicator.parameters:addString("Method1", "1. MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("Two", "2. Smoothing Period", "Period", 3);
	indicator.parameters:addString("Method2", "2. MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	
	 indicator.parameters:addInteger("Three", "Signal Line Period", "Period", 3);
	indicator.parameters:addString("Method3", "Signal Line Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("HLC_color", "HLC Line Color", "Color of HLC", core.rgb(0, 255, 0));	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	  indicator.parameters:addColor("HLC_color1", "Signal Line", "Signal Line", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 80);
    indicator.parameters:addDouble("oversold","Oversold Level","", 20 );
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
local One;
local Two;
local Three;
local Method2, Method1;
local first;
local source = nil;
local MA11, MA21, MA12, MA22, MA3;
-- Streams block
local HLC,Signal;
local ONE, TWO;
-- Routine
function Prepare(nameOnly)
    One = instance.parameters.One;
    Two = instance.parameters.Two;
	Three = instance.parameters.Three;
	Method2 = instance.parameters.Method2;
	Method1 = instance.parameters.Method1;
	Method3 = instance.parameters.Method3;
    source = instance.source;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(One) .. ", " .. tostring(Method1).. ", " .. tostring(Two) .. ", " .. tostring(Method2).. ", " .. tostring(Three) .. ", " .. tostring(Method3).. ")";
    instance:name(name);
	
    if (not (nameOnly)) then
        ONE=instance:addInternalStream(0, 0);
        TWO=instance:addInternalStream(0, 0);
        
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
        MA11 = core.indicators:create(Method1, ONE, Period1);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
        MA12 = core.indicators:create(Method2, MA11.DATA, One);
        
        MA21 = core.indicators:create(Method1, TWO, Period1);
        MA22 = core.indicators:create(Method2, MA21.DATA, Two);

        
        first = MA21.DATA:first();
        HLC = instance:addStream("HLC", core.Line, name, "HLC", instance.parameters.HLC_color, first);
    HLC:setPrecision(math.max(2, instance.source:getPrecision()));
		HLC:setWidth(instance.parameters.width);
        HLC:setStyle(instance.parameters.style);
		
		HLC:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		HLC:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);   
		
    assert(core.indicators:findIndicator(Method3) ~= nil, Method3 .. " indicator must be installed");
		MA3 = core.indicators:create(Method3, HLC, Three);
		
		Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.HLC_color1, MA3.DATA:first());
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
		Signal:setWidth(instance.parameters.width1);
        Signal:setStyle(instance.parameters.style1);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
   
    ONE[period]= source.close[period]-source.low[period];
	TWO[period]= source.high[period]-source.low[period];
	
	
	MA11:update(mode);
	MA12:update(mode);
	MA21:update(mode);
	MA22:update(mode);
	
    if period < first  then
	return;
	end
    
    HLC[period] =100*MA12.DATA[period]/MA22.DATA[period];
	
	 if period < MA3.DATA:first()  then
	return;
	end
	MA3:update(mode);
    Signal[period] =MA3.DATA[period] ;
end

