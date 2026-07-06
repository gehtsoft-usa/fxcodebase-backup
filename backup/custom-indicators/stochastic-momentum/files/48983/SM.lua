-- Id: 8211
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27917


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
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("STOCHASTIC MOMENTUM");
    indicator:description("STOCHASTIC MOMENTUM");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 13);
    indicator.parameters:addInteger("SignalPeriod", "SignalPeriod", "Period", 3);
	indicator.parameters:addString("Method3", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Smoothing");
	indicator.parameters:addBoolean("Smooth", "Use Smoothing", " ", true);
	
	indicator.parameters:addInteger("FirstPeriod", "First Smoothing Period", "First Smoothings Period", 10);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");

    indicator.parameters:addInteger("SecondPeriod", "Second Smoothing Period", "Second Smoothings Period", 2);
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("SM_color", "Color of SM", "Color of SM", core.rgb(0, 255, 0));
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
local FirstPeriod;
local SecondPeriod;
local Method2, Method1, Method3;
local first;
local source = nil;
local Smooth;
-- Streams block
local SM = nil;
local FIRST, SECOND;
local Raw;
local Signal, SIGNAL;
local SignalPeriod;
-- Routine
function Prepare(nameOnly)
    SignalPeriod = instance.parameters.SignalPeriod;
	Method3 = instance.parameters.Method3;
    Period = instance.parameters.Period;
	Smooth = instance.parameters.Smooth;
	Method2 = instance.parameters.Method2;
	Method1 = instance.parameters.Method1;
    FirstPeriod = instance.parameters.FirstPeriod;
    SecondPeriod = instance.parameters.SecondPeriod;
    source = instance.source;
    first = source:first()+Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(SignalPeriod).. ", " .. tostring(Method3) .. ", " .. tostring(FirstPeriod).. ", " .. tostring(Method1) .. ", " .. tostring(SecondPeriod).. ", " .. tostring(Method2) .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	  
	   
	    Raw = instance:addInternalStream(0, 0);
		if Smooth then
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
	    FIRST = core.indicators:create(Method1, Raw,FirstPeriod);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
		SECOND = core.indicators:create(Method2, FIRST.DATA,SecondPeriod);
        SM = instance:addStream("SM", core.Line, name, "SM", instance.parameters.SM_color, SECOND.DATA:first());
    SM:setPrecision(math.max(2, instance.source:getPrecision()));
    SM:setPrecision(math.max(2, instance.source:getPrecision()));
		else
		SM = instance:addStream("SM", core.Line, name, "SM", instance.parameters.SM_color, first+Period);
		end
		SM:setWidth(instance.parameters.width1);
        SM:setStyle(instance.parameters.style1);
		
    assert(core.indicators:findIndicator(Method3) ~= nil, Method3 .. " indicator must be installed");
		SIGNAL = core.indicators:create(Method3, SM,SignalPeriod);
		
		Signal = instance:addStream("Signal", core.Line, name, "Signal", instance.parameters.Signal_color, SIGNAL.DATA:first());
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
		Signal:setWidth(instance.parameters.width2);
        Signal:setStyle(instance.parameters.style2);
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period  <  first  then
	return;
	end
	
	local min, max;
	
	min, max= mathex.minmax (source, period-Period+1, period);
	
    Raw[period] =  source.close[period] - 0.5* (min + max);
	
	if Smooth then
	
			FIRST:update(mode);
			SECOND:update(mode);
			
			if period  < SECOND.DATA:first() then
			return;
			end
			
			SM[period]= SECOND.DATA[period];
	
	else
	        SM[period]= Raw[period];
	end
	
	
	SIGNAL:update(mode);
	
	if period < SIGNAL.DATA[period] then
	return;
	end
	
	Signal[period]= SIGNAL.DATA[period];
    
end

