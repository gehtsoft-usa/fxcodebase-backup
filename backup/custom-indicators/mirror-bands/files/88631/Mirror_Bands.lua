-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59154


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
    indicator:name("Mirror Bands");
    indicator:description("Mirror Bands");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("Period", "Period", "Period", 9);
	 indicator.parameters:addInteger("MA_Period", "MA Period", "Period", 2);
    indicator.parameters:addDouble("Deviations", "Deviations", "Deviations", 2);
    indicator.parameters:addColor("Top_color", "Color of Top", "Color of Top", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("Bottom_color", "Color of Bottom", "Color of Bottom", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("MA_color", "Color of MA", "Color of MA", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("Mirror_color", "Color of Mirror", "Color of Mirror", core.rgb(255, 0, 0));
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
local Deviations;
local MA_Period;
local first;
local source = nil;

-- Streams block
local Top = nil;
local Bottom = nil;
local MA = nil;
local Mirror = nil;
local ma, ma2;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	MA_Period = instance.parameters.MA_Period;
    Deviations = instance.parameters.Deviations;
    source = instance.source;
	 
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Deviations) .. ", " .. tostring(MA_Period) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	ma = core.indicators:create("MVA", source, Period);
	
	ma2 = core.indicators:create("MVA", source, MA_Period);
    first = math.max(ma.DATA:first(),ma2.DATA:first())

 
        Top = instance:addStream("Top", core.Line, name .. ".Top", "Top", instance.parameters.Top_color, ma.DATA:first());
		Top:setWidth(instance.parameters.width);
        Top:setStyle(instance.parameters.style);
        Bottom = instance:addStream("Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.Bottom_color,ma.DATA:first());
		Bottom:setWidth(instance.parameters.width1);
        Bottom:setStyle(instance.parameters.style1);
        MA = instance:addStream("MA", core.Line, name .. ".MA", "MA", instance.parameters.MA_color, ma2.DATA:first());
		MA:setWidth(instance.parameters.width2);
        MA:setStyle(instance.parameters.style2);
        Mirror = instance:addStream("Mirror", core.Line, name .. ".Mirror", "Mirror", instance.parameters.Mirror_color, ma2.DATA:first());
		Mirror:setWidth(instance.parameters.width3);
        Mirror:setStyle(instance.parameters.style3);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


    ma:update(mode);
	
	if period < ma.DATA:first() then
	return;
	end
	
	local sum=0;
	local new;
	
	for j = period -Period+1, period, 1 do
	new=source[j]-ma.DATA[period];
    sum=sum + new*new;
	end
	
	local deviation=Deviations*math.sqrt(sum/Period);
		
        Top[period] = ma.DATA[period]+deviation;
        Bottom[period] = ma.DATA[period]-deviation;
		
		ma2:update(mode);
		
	if period < first  then
	return;
	end	
	
        MA[period] = ma2.DATA[period];
        Mirror[period] = ma.DATA[period]*2 - ma2.DATA[period]
    
end

