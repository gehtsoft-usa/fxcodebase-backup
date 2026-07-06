-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27834
-- Id: 8172

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
    indicator:name("BH Ergodic");
    indicator:description("BH Ergodic");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("BarDiff", "Bar Difference", "Bar Difference", 1);
    indicator.parameters:addInteger("r", "1. MA Period", "1. MA Period", 2);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("s", "2. MA Period", "2. MA Period", 10);
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("u", "3. MA Period", "3. MA Period", 5);
	indicator.parameters:addString("Method3", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("trigger", "Final moving average or smoothing", "Final moving average or smoothing", 3);
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
	indicator.parameters:addColor("BHE_color", "Color of BHE", "Color of BHE", core.rgb(0, 255, 0));
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
local BarDiff;
local r;
local s;
local u;
local trigger;
local Method1, Method2, Method3, Method4;

local first;
local source = nil;
local M11, M21, M31;
local M12, M22, M32 ;
local M4;
-- Streams block
local BHE = nil;
local Signal = nil;
local Price_Delta1_Buffer, Price_Delta2_Buffer;
-- Routine
function Prepare(nameOnly)
    BarDiff = instance.parameters.BarDiff;
	Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
	Method3 = instance.parameters.Method3;
	Method4 = instance.parameters.Method4;
    r = instance.parameters.r;
    s = instance.parameters.s;
    u = instance.parameters.u;
    trigger = instance.parameters.trigger;
    source = instance.source;
    first = source:first()+BarDiff;
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(BarDiff) .. ", " .. tostring(r) .. ", " .. tostring(Method1).. ", " .. tostring(s) .. ", " .. tostring(Method2).. ", " .. tostring(u) .. ", " .. tostring(Method3).. ", " .. tostring(trigger).. ", " .. tostring(Method4) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Price_Delta1_Buffer =   instance:addInternalStream(0, 0);
        Price_Delta2_Buffer = instance:addInternalStream(0, 0);
        
        M11 = core.indicators:create(Method1, Price_Delta1_Buffer, r);
        M21 = core.indicators:create(Method2, M11.DATA, s);
        M31 = core.indicators:create(Method3,  M21.DATA, u);
        
        M12 = core.indicators:create(Method1, Price_Delta2_Buffer, r);
        M22 = core.indicators:create(Method2,  M12.DATA, s);
        M32 = core.indicators:create(Method3,  M22.DATA, u);
        
        BHE = instance:addStream("BHE", core.Line, name .. ".BHE", "BHE", instance.parameters.BHE_color, M32.DATA:first());
		BHE:setWidth(instance.parameters.width1);
        BHE:setStyle(instance.parameters.style1);
		
		M4 = core.indicators:create(Method4, BHE, trigger);
		 
        Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Signal_color, M4.DATA:first());
		Signal:setWidth(instance.parameters.width2);
        Signal:setStyle(instance.parameters.style2);
		
		
		BHE:setPrecision(math.max(2, instance.source:getPrecision()));
		Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
     
	
	if period < first   then
	return;
	end
	
	Price_Delta1_Buffer[period] = source[period] - source[period-BarDiff];
    Price_Delta2_Buffer[period] = math.abs( source[period] - source[period-BarDiff] );
	
	M11:update(mode);
	M12:update(mode);
	M21:update(mode);
	M22:update(mode);
	M31:update(mode);
	M32:update(mode);
		  
		  if period < M32.DATA:first() then
		  return;
		  end
		  
	
        BHE[period] = ( 100 * M31.DATA[period] ) / M32.DATA[period]; 
		
		
		 M4:update(mode);
		 
		 
		    if period < M4.DATA:first() then
		  return;
		  end
		  
		  
        Signal[period] = M4.DATA[period];
   
end

