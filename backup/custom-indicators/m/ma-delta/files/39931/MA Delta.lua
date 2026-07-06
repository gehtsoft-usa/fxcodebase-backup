-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23185
-- Id: 7347

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("MA Delta");
    indicator:description("MA Delta");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Method1", "Delta Method", "Delta Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method1", "VAMA", "VAMA" , "VAMA");	
	indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA", "VIDYA"); 
    indicator.parameters:addInteger("Period1", " MVA Period", " ", 14);
	
	
	indicator.parameters:addString("Method2", "Signal Method", "Signal Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method2", "VAMA", "VAMA" , "VAMA");	
	indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA", "VIDYA"); 
	indicator.parameters:addInteger("Period2", " Signal Period", " ", 14);
	 indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("up_color", "Color of Up", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("dn_color", "Color of Down", "", core.rgb(255, 0, 0));

	
    indicator.parameters:addColor("ma_color", "Signal Period", "", core.rgb(0, 0, 128));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE); 
	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period1, Period2;
local Method1, Method2;
local first;
local source = nil;

-- Streams block
local DELTA = nil;
local MA, Smoothing, Signal;
-- Routine
function Prepare(nameOnly)
    Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;
    source = instance.source;
    Method2 = instance.parameters.Method2;
	Method1 = instance.parameters.Method1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Method1) .. ", " .. tostring(Period1)  .. ", " .. tostring(Method2).. ", " .. tostring(Period2).. ")";
    instance:name(name);

    if (not (nameOnly)) then
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
        MA = core.indicators:create(Method1,source, Period);
        DELTA = instance:addStream("DELTA", core.Bar, name .. ".Delta", "Delta", core.rgb(128, 128, 128), MA.DATA:first()+1);  
    DELTA:setPrecision(math.max(2, instance.source:getPrecision()));
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
		Smoothing= core.indicators:create(Method2,DELTA, Period);
		
		  first = Smoothing.DATA:first();
		
		Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal",   instance.parameters.ma_color, first);
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
		Signal:setWidth(instance.parameters.width);
        Signal:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    
	
	MA:update(mode);
	
	if period < MA.DATA:first() then
	return;
	end
 
	
    DELTA[period] =MA.DATA[period]-MA.DATA[period-1];
	
	
	
	if MA.DATA[period] < MA.DATA[period-1]  then
	 DELTA:setColor(period, instance.parameters.dn_color);
	else
	  DELTA:setColor(period, instance.parameters.up_color);
	end
	
	Smoothing:update(mode);
	
	if period < first or not source:hasData(period) then
	return;
	end
	
	Signal[period]=Smoothing.DATA[period];
  
end

