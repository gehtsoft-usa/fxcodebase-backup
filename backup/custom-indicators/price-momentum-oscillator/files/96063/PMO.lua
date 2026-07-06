-- Id: 12552
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61209


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
    indicator:name("Price Momentum Oscillator");
    indicator:description("Price Momentum Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("one", "Short Period", "Period", 20);
	indicator.parameters:addInteger("two", "Long Period", "Period", 35);
	indicator.parameters:addInteger("Period", "Signal Period", "Period", 10);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("PMO_color", "Color of PMO", "Color of PMO", core.rgb(0, 255, 0));
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
local one, two;

local first;
local source = nil;
local RawOne,RawTwo;
-- Streams block
local PMO = nil;
local SmoothingMultiplierOne,SmoothingMultiplierTwo;
local CustomSmoothingFunctionOne;
local CustomSmoothingFunctionTwo;
local Signal;
local EMA;
local Period;
-- Routine
function Prepare(nameOnly)
    one = instance.parameters.one;
	two = instance.parameters.two;
	Period= instance.parameters.Period;
    source = instance.source;
    first = source:first();
	
	RawOne = instance:addInternalStream(0, 0);
	RawTwo = instance:addInternalStream(0, 0);
	CustomSmoothingFunctionOne= instance:addInternalStream(0, 0);
    CustomSmoothingFunctionTwo= instance:addInternalStream(0, 0);
	
	SmoothingMultiplierOne = (2 / one);
	SmoothingMultiplierTwo = (2 / two);

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(one) .. ", " .. tostring(two) .. ", " .. tostring(Period).. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
        PMO = instance:addStream("PMO", core.Line, name, "PMO", instance.parameters.PMO_color, first);
		PMO:setWidth(instance.parameters.width1);
        PMO:setStyle(instance.parameters.style1);
		
		EMA = core.indicators:create("EMA", PMO, Period);
		
		Signal = instance:addStream("SIGNAL", core.Line, name, "Signal", instance.parameters.Signal_color, first);
		Signal:setWidth(instance.parameters.width2);
        Signal:setStyle(instance.parameters.style2);
		
		PMO:setPrecision(math.max(2, instance.source:getPrecision()));
		Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

   if period < first or not source:hasData(period) then
	return;
	end  
	 
   RawOne[period] =(( (source[period]/source[period-1]) * 100)-100)  ;
   
   Two(RawOne,period)
   
   RawTwo[period]= 10*CustomSmoothingFunctionTwo[period];
	
    One(RawTwo,period);
	
        PMO[period] = CustomSmoothingFunctionOne[period];
		
		EMA:update(mode);
		if period < EMA.DATA:first() then
		return;
		end
		
		Signal[period]= EMA.DATA[period];
    
end

function One ( Close, period)

CustomSmoothingFunctionOne[period] = (Close[period] - CustomSmoothingFunctionOne[period-1]) * SmoothingMultiplierOne +  CustomSmoothingFunctionOne[period-1];
end

function Two(Close, period)
CustomSmoothingFunctionTwo[period] = (Close[period] - CustomSmoothingFunctionTwo[period-1]) * SmoothingMultiplierTwo +  CustomSmoothingFunctionTwo[period-1];
end
 