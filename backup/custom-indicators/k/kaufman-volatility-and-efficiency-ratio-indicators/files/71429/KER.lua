-- Id: 9485

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3683

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
    indicator:name("Kaufman Efficiency Ratio");
    indicator:description("Kaufman Efficiency Ratio");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("length", "Length", "Length", 20); 
	indicator.parameters:addInteger("movingAvePeriod", "Moving Average Period", "Moving Average Period", 10);
	
	indicator.parameters:addGroup("Style")    
    indicator.parameters:addColor("ERatio_color", "Color of ERatio", "Color of ERatio", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Average_color", "Color of Average", "Color of Average", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("upperERThreshold", "Lower ER Threshold Level","", 30);
    indicator.parameters:addDouble("lowerERThreshold","Upper ER Threshold Level","", -30);
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
local length;
local lowerERThreshold;
local upperERThreshold;
local movingAvePeriod;

local first;
local source = nil;

-- Streams block
local ERatio = nil;
local Average = nil;
local incrementalTotalChange;
-- Routine
function Prepare(nameOnly)
    length = instance.parameters.length;
    lowerERThreshold = instance.parameters.lowerERThreshold;
    upperERThreshold = instance.parameters.upperERThreshold;
    movingAvePeriod = instance.parameters.movingAvePeriod;
    source = instance.source;
    first = source:first()+length;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(length) .. ", " .. tostring(lowerERThreshold) .. ", " .. tostring(upperERThreshold) .. ", " .. tostring(movingAvePeriod) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	incrementalTotalChange= instance:addInternalStream(0, 0);

   
        ERatio = instance:addStream("ERatio", core.Line, name .. ".ERatio", "ERatio", instance.parameters.ERatio_color, first);
    ERatio:setPrecision(math.max(2, instance.source:getPrecision()));
		ERatio:addLevel(instance.parameters.upperERThreshold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		ERatio:addLevel(instance.parameters.lowerERThreshold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
        ERatio:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
		ERatio:setWidth(instance.parameters.width1);
        ERatio:setStyle(instance.parameters.style1);
		
        Average = instance:addStream("Average", core.Line, name .. ".Average", "Average", instance.parameters.Average_color, first+ movingAvePeriod );
    Average:setPrecision(math.max(2, instance.source:getPrecision()));
		Average:setWidth(instance.parameters.width2);
        Average:setStyle(instance.parameters.style2);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    
	
	
	incrementalTotalChange[period] = math.abs(source.median[period] - source.median[period-1]);
	  
	if period < first   then
	return;
	end
	
	  local  NetChange = source.median[period] - source.median[period-length+1];
      local  TotalChange = mathex.sum(incrementalTotalChange,period-length+1, period);
 
 
     

        ERatio[period] =  (NetChange/TotalChange) * 100;
		
	if period < first+ movingAvePeriod  then
	return;
	end
		 
        Average[period] = mathex.avg(ERatio, period-movingAvePeriod+1, period);
  
end

