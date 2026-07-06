-- Id: 16024
--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
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
    indicator:name("Shadow TSI");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("TSI Calculation");
    indicator.parameters:addInteger("Period1", "1. Period", "", 13, 2, 5000);
	indicator.parameters:addInteger("Period2", "2. Period", "", 7, 2, 5000);
	
	indicator.parameters:addGroup("1. MA Calculation");
	indicator.parameters:addInteger("Period3", "Period", "", 2, 2, 5000);
	indicator.parameters:addString("Method3", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("2. MA Calculation");
	indicator.parameters:addInteger("Period4", "Period", "", 6, 2, 5000);
	indicator.parameters:addString("Method4", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method4", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method4", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method4", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method4", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method4", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method4", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method4", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method4", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "TSI Line color", "Line Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line Line style", "Line style", core.LINE_SOLID);
	
	indicator.parameters:addColor("color2", "1. MA Line color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line Line style", "Line style", core.LINE_SOLID);
	
	indicator.parameters:addColor("color3", "2. MA Line color", "Line Color", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line Line style", "Line style", core.LINE_SOLID);
  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first;
local source;
local TSI,tsi;
local MA1, ma1, MA2, ma2;
local Method3, Method4, Period1, Period2, Period3,Period4;
local Show;
-- Routine
function Prepare()
    Method3= instance.parameters.Method3;
	Method4= instance.parameters.Method4;
	Period1= instance.parameters.Period1;
	Period2= instance.parameters.Period2;
	Period3= instance.parameters.Period3;
	Period4= instance.parameters.Period4; 
    source = instance.source;
	
	 local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

 
  
	
    tsi = core.indicators:create("TSI", source, Period1,Period2); 
    assert(core.indicators:findIndicator(Method3) ~= nil, Method3 .. " indicator must be installed");
    ma1 = core.indicators:create(Method3, tsi.DATA, Period3); 
    assert(core.indicators:findIndicator(Method4) ~= nil, Method4 .. " indicator must be installed");
	ma2 = core.indicators:create(Method4, ma1.DATA, Period4); 
	
	TSI = instance:addStream("TSI", core.Line, name .. "TSI", "TSI", instance.parameters.color1, tsi.DATA:first());
    TSI:setPrecision(math.max(2, instance.source:getPrecision()));
	TSI:setWidth(instance.parameters.width1);
    TSI:setStyle(instance.parameters.style1); 
	
	
	MA1 = instance:addStream("MA1", core.Line, name .. "1. MA", "1. MA", instance.parameters.color2, ma1.DATA:first());
    MA1:setPrecision(math.max(2, instance.source:getPrecision()));
	MA1:setWidth(instance.parameters.width2);
    MA1:setStyle(instance.parameters.style2); 
	
    MA2 = instance:addStream("MA2", core.Line, name .. "2. MA", "2. MA", instance.parameters.color3, ma2.DATA:first());
    MA2:setPrecision(math.max(2, instance.source:getPrecision()));
	MA2:setWidth(instance.parameters.width3);
    MA2:setStyle(instance.parameters.style3); 
	 
end

-- Indicator calculation routine
function Update(period, mode)
	
    tsi:update(mode);
	ma1:update(mode);
	ma2:update(mode);

    if period < tsi.DATA:first() then
	return;
	end
	
	TSI[period]= tsi.DATA[period];
	
	
	if period < ma1.DATA:first() then
	return;
	end
	
	MA1[period]= ma1.DATA[period];
	
	
	
	if period < ma2.DATA:first() then
	return;
	end
	
	MA2[period]= ma2.DATA[period];
	
end






