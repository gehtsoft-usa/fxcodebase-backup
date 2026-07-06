-- Id: 10078
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59583

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
    indicator:name("Warren Momentum Indicator");
    indicator:description("Warren Momentum Indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("L", "1. Period", "L", 4);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
  indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("M", "2. Period", "M", 13);
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("N", "3. Period", "N", 13);
	indicator.parameters:addString("Method3", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("S", "Signal Line Period", "Signal", 4);
	indicator.parameters:addString("Method4", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method4", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method4", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method4", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method4", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method4", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method4", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method4", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method4", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("WAMI_color", "Color of WAMI", "Color of WAMI", core.rgb(0, 255, 0));
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
local L;
local M;
local N;
local S;
local Method4,Method3, Method2,Method1;
local first;
local source = nil;

-- Streams block
local WAMI = nil;
local Signal = nil;
local Difference;
-- Routine
function Prepare(nameOnly)
    L = instance.parameters.L;
    M = instance.parameters.M;
    N = instance.parameters.N;
    S = instance.parameters.S;
	Method4 = instance.parameters.Method4;
	Method3 = instance.parameters.Method3;
	Method2 = instance.parameters.Method2;
	Method1 = instance.parameters.Method1; 
	
	source = instance.source;
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(L).. ", " .. tostring(Method1) 
	.. ", " .. tostring(M).. ", " .. tostring(Method2)  
	.. ", " .. tostring(N) .. ", " .. tostring(Method3) 
	.. ", " .. tostring(S).. ", " .. tostring(Method4)  .. ")";
    instance:name(name);

	if   (nameOnly) then
        return;
    end
	
	Difference = instance:addInternalStream(0, 0);
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
	M1 = core.indicators:create(Method1,Difference, L);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
	M2 = core.indicators:create(Method2,M1.DATA, M);
    assert(core.indicators:findIndicator(Method3) ~= nil, Method3 .. " indicator must be installed");
	M3 = core.indicators:create(Method3,M2.DATA, N);
    assert(core.indicators:findIndicator(Method4) ~= nil, Method4 .. " indicator must be installed");
	M4 = core.indicators:create(Method4,M3.DATA, S);
    first = M3.DATA:first();
	
   
        WAMI = instance:addStream("WAMI", core.Line, name .. ".WAMI", "WAMI", instance.parameters.WAMI_color, first);
		WAMI:setWidth(instance.parameters.width1);
        WAMI:setStyle(instance.parameters.style1);
        Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Signal_color, M4.DATA:first());
		WAMI:setWidth(instance.parameters.width2);
        WAMI:setStyle(instance.parameters.style2);
		
		
		WAMI:setPrecision(math.max(2, instance.source:getPrecision()));
	    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
   
  
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


    Difference[period]= source[period]-source[period-1];
	
 
	M1:update(mode)
	M2:update(mode);
	M3:update(mode);
	M4:update(mode);
	
	    if period < first then
	return;
	end
	
	WAMI[period]=M3.DATA[period];
	if period < M4.DATA:first() then
	return;
	end
		
        Signal[period] = M4.DATA[period];
    
end

