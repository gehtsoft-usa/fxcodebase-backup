-- Id: 9491

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=895

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Centered Detrend Price");
    indicator:description("Centered Detrend Price");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 20);
    indicator.parameters:addInteger("Band_Period", "Band Period", "Band Period", 20);
    indicator.parameters:addDouble("Deviation", "Deviation", "Deviation", 2);
	
    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("color", "Line Color", "",  core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "Top Band Color", "",  core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "Bottom Band Color", "",  core.rgb(0, 0, 255));
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
local Band_Period;
local Deviation;

local first;
local source = nil;
local Up, Down;
-- Streams block
local  CDP=nil;

local Avg,Cycle,Avg_Cycle,ABS,Avg_Abs;

-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    Period = instance.parameters.Period;
    Band_Period = instance.parameters.Band_Period;
    Deviation = instance.parameters.Deviation;
    source = instance.source;
    first = source:first();
	
	
 
	    Avg = core.indicators:create("MVA",source,Period );
	    Cycle = instance:addInternalStream(0, 0);
		Avg_Cycle = core.indicators:create("MVA",Cycle,Band_Period );
		ABS = instance:addInternalStream(0, 0);
		Avg_Abs = core.indicators:create("MVA",ABS,Band_Period );
        CDP = instance:addStream("CDP", core.Line, name, "CDP",  instance.parameters.color, first);
	    CDP:setWidth(instance.parameters.width);
        CDP:setStyle(instance.parameters.style);
		
		Up = instance:addStream("TOP", core.Line, name, "Top",  instance.parameters.color1, first);
	    Up:setWidth(instance.parameters.width1);
        Up:setStyle(instance.parameters.style1);
		
		Down = instance:addStream("BOTTOM", core.Line, name, "Bottom",  instance.parameters.color2, first);
	    Down:setWidth(instance.parameters.width2);
        Down:setStyle(instance.parameters.style2);
		
		CDP:setPrecision(math.max(2, instance.source:getPrecision()));
		Up:setPrecision(math.max(2, instance.source:getPrecision()));
		Down:setPrecision(math.max(2, instance.source:getPrecision()));
 
     
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    Avg:update(mode);
	
    if period < Avg.DATA:first()  then
	return;
	end
	
	CDP[period] =source[period] - Avg.DATA[period-Period/2];
	
	Avg_Cycle:update(mode);
	
	 if period < Avg_Cycle.DATA:first()  then
	return;
	end
	
	ABS[period] = math.abs(CDP[period]-Avg_Cycle.DATA[period]);
	
	 	
	Avg_Abs:update(mode);
	
	 if period < Avg_Abs.DATA:first()  then
	return;
	end   
	
	Up[period]   = Avg_Cycle.DATA[period] +(Deviation*Avg_Abs.DATA[period]);
	Down[period] = Avg_Cycle.DATA[period] -(Deviation*Avg_Abs.DATA[period]);
   
end

