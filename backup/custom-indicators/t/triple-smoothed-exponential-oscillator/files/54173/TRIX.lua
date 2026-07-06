-- Id: 8458
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=31775

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Triple Smoothed Exponential Oscillator");
    indicator:description("Triple Smoothed Exponential Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("P1", "1.Period Smoothing", "1.Period", 15);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("P2", "2. Period Smoothing", "2. Period", 15);
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("P3", "3. Period Smoothing", "3. Period", 15);
	indicator.parameters:addString("Method3", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addInteger("P", "Signal Line Period", "Signal Line Period", 9);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addColor("TRIX_color", "Color of TRIX", "Color of TRIX", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Signal_color", "Color of Signal", "Color of Signal", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("HISTOGRAM_color", "Color of HISTOGRAM", "Color of HISTOGRAM", core.rgb(0, 0, 288));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local P1;
local P2;
local P3;
local P;
local MA, MA1, MA2, MA3;
local Method, Method1, Method2, Method3;
local first;
local source = nil;
local HISTOGRAM;
-- Streams block
local TRIX = nil;
local Signal = nil;

-- Routine
function Prepare(nameOnly)
    P1 = instance.parameters.P1;
    P2 = instance.parameters.P2;
    P3 = instance.parameters.P3;
    P = instance.parameters.P;
	Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
	Method3 = instance.parameters.Method3;
	Method = instance.parameters.Method;
    source = instance.source;
    

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(P1) .. ", " .. tostring(Method1) .. ", " .. tostring(P2).. ", " .. tostring(Method2) .. ", " .. tostring(P3).. ", " .. tostring(Method3) .. ", " .. tostring(P).. ", " .. tostring(Method) .. ")";
    instance:name(name);

	if   (nameOnly) then
        return;
    end
	
		
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
	MA1 = core.indicators:create(Method1, source, P1);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
	MA2 = core.indicators:create(Method2, MA1.DATA, P2);
    assert(core.indicators:findIndicator(Method3) ~= nil, Method3 .. " indicator must be installed");
	MA3 = core.indicators:create(Method3, MA2.DATA, P3);
	first = MA3.DATA:first();
	

        TRIX = instance:addStream("TRIX", core.Line, name .. ".TRIX", "TRIX", instance.parameters.TRIX_color, first);
    TRIX:setPrecision(math.max(2, instance.source:getPrecision()));
		TRIX:setWidth(instance.parameters.width1);
        TRIX:setStyle(instance.parameters.style1);
		
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
		MA = core.indicators:create(Method, TRIX, P);
        Signal = instance:addStream("Signal", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.Signal_color, MA.DATA:first());
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
		Signal:setWidth(instance.parameters.width2);
        Signal:setStyle(instance.parameters.style2);
		
		HISTOGRAM = instance:addStream("HISTOGRAM", core.Bar, name .. ".HISTOGRAM", "HISTOGRAM", instance.parameters.HISTOGRAM_color, MA.DATA:first());
    HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    
	MA1:update(mode)
	MA2:update(mode)
	MA3:update(mode)
	
	if period < first+1  then
	return;
	end
	
	
	
    TRIX[period] = 100 * ( MA3.DATA[period] /  MA3.DATA[period-1] - 1 );
		
	MA:update(mode)	
	
	if period < MA.DATA:first()  then
	return;
	end	
		
    Signal[period] =  MA.DATA[period];
	HISTOGRAM[period]= TRIX[period] -Signal[period];
	
    
end

