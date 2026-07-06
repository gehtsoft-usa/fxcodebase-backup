-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61970

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
    indicator:name("Custom ATR Pivot");
    indicator:description("Custom ATR Pivot");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ATR_Period", "ATR Period", "ATR Period", 14);
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Top_color", "Color of Top Line", "Color of Top", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Bottom_color", "Color of Bottom Line", "Color of Bottom", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Color", "Color of Label", "Color of Label", core.rgb(0, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("fontwidth", "Font width", "",  10);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local ATR_Period;
local Period;
local first;
local source = nil;
local Color;
-- Streams block
local ATR = nil;

-- Routine
function Prepare(nameOnly) 
    ATR_Period = instance.parameters.ATR_Period;
    Period = instance.parameters.Period;
	Color = instance.parameters.Color;
    source = instance.source;
   
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(ATR_Period) .. ", " .. tostring(Period) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	ATR= core.indicators:create("ATR", source, ATR_Period);
	first = math.max(Period, ATR.DATA:first());

    
	
	instance:ownerDrawn(true);
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period )
   
	
end

 
local init = false;
 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
        if not init then
            context:createPen (1, context:convertPenStyle (instance.parameters.style), instance.parameters.width, instance.parameters.Top_color);
			context:createPen (2, context:convertPenStyle (instance.parameters.style), instance.parameters.width, instance.parameters.Bottom_color);
			context:createFont (3, "Arial", instance.parameters.fontwidth, instance.parameters.fontwidth, 0)
            init = true;
        end

		
    ATR:update(core.UpdateLast);
	
	local period= source:size()-1;
	  
	if period-Period+1 < source:first() then
	return;
	end	
  
	local Min, Max= mathex.minmax(source, period-Period+1, period);
	
 
	local Top= Max-ATR.DATA[period];
	local Bottom= Min+ATR.DATA[period];
	
	visible, y1 = context:pointOfPrice (Top);
	visible, y2 = context:pointOfPrice (Bottom);
	
	context:drawLine (1, context:left (), y1, context:right (), y1);
	context:drawLine (2,context:left (), y2, context:right (), y2); 
	
	
	local  text1= string.format("%." .. source:getPrecision() .. "f", Top);
	local  text2= string.format("%." .. source:getPrecision() .. "f", Bottom);
	local width1, height1 = context:measureText (3,text1, 0);
	local width2, height2 = context:measureText (3,text2, 0)
	
	context:drawText (3, text1, Color, -1, context:right ()-width1, y1-height1, context:right (), y1, 0);
	context:drawText (3, text2, Color, -1, context:right ()-width2, y2-height2, context:right (), y2, 0);
	
	core.host:execute ("setStatus", "Top :" .. text1..   " Bottom :" .. text2   )
   
end