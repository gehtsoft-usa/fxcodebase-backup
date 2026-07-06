-- Id: 8117
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27741

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
    indicator:name("Up/Down Percentage");
    indicator:description("Up/Down Percentage");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("U", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("D", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
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

local first;
local source = nil;

-- Streams block
local Up, Down, U, D;
local UpFlag, DownFlag;
-- Routine
function Prepare(nameOnly)  
    Period = instance.parameters.Period;
	U = instance.parameters.U;
	D = instance.parameters.D;
    source = instance.source;
    first = source:first()+Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	UpFlag = instance:addInternalStream(0, 0);
	DownFlag = instance:addInternalStream(0, 0);


 
        Up = instance:addStream("UP", core.Line, name, "UP", U, first);
    Up:setPrecision(math.max(2, instance.source:getPrecision()));
		Up:setWidth(instance.parameters.width1);
        Up:setStyle(instance.parameters.style1);
		
		Down = instance:addStream("DOWN", core.Line, name, "DOWN", D, first);
    Down:setPrecision(math.max(2, instance.source:getPrecision()));
		Down:setWidth(instance.parameters.width1);
        Down:setStyle(instance.parameters.style1);
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    UpFlag[period]= 0;
	DownFlag[period]= 0;
	
    if period < first  then
	return;
	end
	if source[period]> source[period-1] then
	UpFlag[period]= 1;
	elseif source[period] < source[period-1] then
	DownFlag[period]= 1;
	end
	
	 
	Up[period]= mathex.sum(UpFlag, period-Period+1, period) / (Period/100);
	Down[period]=mathex.sum(DownFlag, period-Period+1, period) / (Period/100);
	
	
   
end

