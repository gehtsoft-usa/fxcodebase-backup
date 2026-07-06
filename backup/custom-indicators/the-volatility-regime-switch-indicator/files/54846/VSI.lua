-- Id: 8514
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32173

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
    indicator:name("The Volatility (Regime) Switch Indicator by Ron McEwan");
    indicator:description("The Volatility (Regime) Switch Indicator by Ron McEwan");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 21);
    indicator.parameters:addColor("VSI_color", "Color of VSI", "Color of VSI", core.rgb(255, 0, 0));
	indicator.parameters:addGroup("Style");	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 0.8);
    indicator.parameters:addDouble("oversold","Oversold Level","", 0.2);
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
local Period;

local first;
local source = nil;
local Daily, Deviation;
-- Streams block
local VSI = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
	
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);
	
	 if   (nameOnly) then
        return;
    end
	
	Daily = instance:addInternalStream(0, 0);
    Deviation = instance:addInternalStream(0, 0);
	
    first = source:first()+Period+1;

 
        VSI = instance:addStream("VSI", core.Line, name, "VSI", instance.parameters.VSI_color, first);
    VSI:setPrecision(math.max(2, instance.source:getPrecision()));
		VSI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		VSI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		VSI:setWidth(instance.parameters.width);
        VSI:setStyle(instance.parameters.style);
     
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    
 
  Daily[period] = ( source[period]- source[period-1])/(( source[period]+ source[period-1])/2);  
  
    if period < first  then
	return;
	end
  
   Deviation[period] = mathex.stdev(Daily, period -Period+1, period);
 
   local i;
   local Count =0;
   for i = period -Period+1, period do
	   if  Deviation[i] <=  Deviation[period] then
	   Count= Count+1;   
	   end   
   end
   VSI[period] = Count/Period; 
    
end

