-- Id: 13875
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62053


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
    indicator:name("Breakdown Oscillator");
    indicator:description("Breakdown Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Short_Period", "Short Period", "Short Period", 10);
    indicator.parameters:addInteger("Bollinger_Band_Period", "Bollinger Band Period", "Bollinger Band Period", 20);
    indicator.parameters:addDouble("Number_of_deviation", "Number_of_deviation", "Number_of_deviation", 1.5);
   
    indicator.parameters:addDouble("Slope_factor", "Slope factor", "Slope factor", 2);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Breakdown_color", "Color of Breakdown", "Color of Breakdown", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("Buy/Sell Levels");
	 indicator.parameters:addDouble("Buy_level", "Buy level", "Buy level", 10);
    indicator.parameters:addDouble("Sell_level", "Sell level", "Sell level", 0);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Short_Period;
local Bollinger_Band_Period;
local Number_of_deviation;
local Buy_level;
local Sell_level;
local Slope_factor;
local Difference;
local first;
local source = nil;

-- Streams block
local Breakdown = nil;
local SMA;
-- Routine
 function Prepare(nameOnly)  
    Short_Period = instance.parameters.Short_Period;
    Bollinger_Band_Period = instance.parameters.Bollinger_Band_Period;
    Number_of_deviation = instance.parameters.Number_of_deviation;
    Buy_level = instance.parameters.Buy_level;
    Sell_level = instance.parameters.Sell_level;
    Slope_factor = instance.parameters.Slope_factor;
    source = instance.source;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Short_Period) .. ", " .. tostring(Bollinger_Band_Period) .. ", " .. tostring(Number_of_deviation) .. ", " .. tostring(Buy_level) .. ", " .. tostring(Sell_level) .. ", " .. tostring(Slope_factor) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	SMA = core.indicators:create("MVA", source, Bollinger_Band_Period);
    first = SMA.DATA:first();
	
	Difference = instance:addInternalStream(0, 0);
	
	EMA = core.indicators:create("EMA", Difference, Short_Period);
 
        Breakdown = instance:addStream("Breakdown", core.Line, name, "Breakdown", instance.parameters.Breakdown_color, EMA.DATA:first());
		Breakdown:setWidth(instance.parameters.width);
        Breakdown:setStyle(instance.parameters.style);
		Breakdown:addLevel(Buy_level, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		Breakdown:addLevel(Sell_level, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		Breakdown:setPrecision(math.max(2, instance.source:getPrecision()));
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    SMA:update(mode);
	
    if period < first or not  source:hasData(period) then
	return;
	end
	
	local Bottom= SMA.DATA[period] - Number_of_deviation * mathex.stdev(source, period-Bollinger_Band_Period+1, period)
    
    Difference[period]= source[period]-Bottom +Slope_factor*(SMA.DATA[period]-SMA.DATA[period-1])
	
	
	EMA:update(mode);
	
	if period < EMA.DATA:first()  then
	return;
	end
	
    Breakdown[period] = 100*EMA.DATA[period]/Bottom;
			
		
    
end
 

