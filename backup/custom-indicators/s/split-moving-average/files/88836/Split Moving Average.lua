-- Id: 9788

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59276

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
    indicator:name("Split Moving Average");
    indicator:description("Split Moving Average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
	--indicator.parameters:addString("Type", "Fill the gap", "Type" , "Zero");
  --  indicator.parameters:addStringAlternative("Type", "Zero", "Zero" , "Zero");
   -- indicator.parameters:addStringAlternative("Type", "Previous / Last Value", "Previous" , "Previous");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up_color", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("Down_color", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Mid_color", "Color of Mid", "Color of Mid", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Method;
local first;
local source = nil;
--local Type;
-- Streams block
local Up = nil;
local Down = nil;
local UP,DOWN;
local U,D;
local Mid;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	--Type = instance.parameters.Type;
	Method = instance.parameters.Method;
    source = instance.source;
	
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(Method).. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	UP = instance:addInternalStream(0, 0);
	DOWN = instance:addInternalStream(0, 0);
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	U = core.indicators:create(Method, UP, Period);
	D = core.indicators:create(Method, DOWN, Period);
    first = U.DATA:first();
	
 
        Up = instance:addStream("Up", core.Line, name .. ".Up", "Up", instance.parameters.Up_color, first);
    Up:setPrecision(math.max(2, instance.source:getPrecision()));
		Up:setWidth(instance.parameters.width1);
        Up:setStyle(instance.parameters.style1);
        Down = instance:addStream("Down", core.Line, name .. ".Down", "Down", instance.parameters.Down_color, first);
    Down:setPrecision(math.max(2, instance.source:getPrecision()));
		Down:setWidth(instance.parameters.width2);
        Down:setStyle(instance.parameters.style2);
		Mid = instance:addStream("Mid", core.Line, name .. ".Mid", "Mid", instance.parameters.Mid_color, first);
    Mid:setPrecision(math.max(2, instance.source:getPrecision()));
		Mid:setWidth(instance.parameters.width3);
        Mid:setStyle(instance.parameters.style3);
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    if	source[period]> source[period-1] then  
	UP[period]=source[period]; 
		DOWN[period]=0; 
	else
	DOWN[period]=source[period]; 
		UP[period]=0; 
	end
	
	U:update(mode);
	D:update(mode);
	
    if period < first then
	return;
	end
        Up[period] = U.DATA[period];
        Down[period] = D.DATA[period];
		Mid[period]=  (Up[period]+Down[period])/2; 
    
end

