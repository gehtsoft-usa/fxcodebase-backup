-- Id: 10805

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59402

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
    indicator:name("Trend ");
    indicator:description("Trend ");
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
	
	indicator.parameters:addBoolean("Show", "Show Difference", "", false);
	indicator.parameters:addBoolean("Show1", "Show Up Line", "", true);
	indicator.parameters:addBoolean("Show2", "Show Down Line", "", true);
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Up_color", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Down_color", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Difference_color", "Color of Difference", "Color of Difference", core.rgb(0, 0, 255));
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
local Show1, Show2;
-- Streams block
local Up = nil;
local Down = nil;
local UP, DOWN,Difference;
local U,D;
local Show;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Method = instance.parameters.Method;
	Show = instance.parameters.Show;
	Show1 = instance.parameters.Show1;
	Show2 = instance.parameters.Show2;
    source = instance.source;
   

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(Method) .. ")";
    instance:name(name);
	U= instance:addInternalStream(0, 0);
	D= instance:addInternalStream(0, 0);
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	UP = core.indicators:create(Method, U, Period);
	DOWN = core.indicators:create(Method, D, Period);
	first = UP.DATA:first();

    if   (nameOnly) then
        return;
    end
	    if Show1 then
        Up = instance:addStream("Up", core.Line, name .. ".Up", "Up", instance.parameters.Up_color, first);
		Up:setWidth(instance.parameters.width1);
        Up:setStyle(instance.parameters.style1);
		Up:setPrecision (source:getPrecision ()+2);
		else
		Up = instance:addInternalStream(0, 0);
		end
		
		if Show2 then 
        Down = instance:addStream("Down", core.Line, name .. ".Down", "Down", instance.parameters.Down_color, first);
		Down:setWidth(instance.parameters.width2);
        Down:setStyle(instance.parameters.style2);
		Down:setPrecision (source:getPrecision ()+2);
		else
		Down = instance:addInternalStream(0, 0);
		end
		
		if Show then
		Difference = instance:addStream("Difference", core.Line, name .. ".Difference", "Difference", instance.parameters.Difference_color, first);
		Difference:setWidth(instance.parameters.width3);
        Difference:setStyle(instance.parameters.style3);
		Difference:setPrecision (source:getPrecision ()+2);
		else
		Difference = instance:addInternalStream(0, 0);
		end
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    if source[period]> source[period-1] then
	U[period]=source[period]- source[period-1];
    D[period]=0;
	elseif source[period]< source[period-1] then
	D[period]=source[period]- source[period-1]
    U[period]=0;
	else
	U[period]=0;
    D[period]=0;
	end
	
	UP:update(mode);
	DOWN:update(mode);
	
    if period < UP.DATA:first()  then
	return;
	end
        Up[period] = UP.DATA[period];
        Down[period]  = DOWN.DATA[period];
		Difference[period]=Up[period]-Down[period];
    
end

