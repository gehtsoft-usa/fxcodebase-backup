-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32209
-- Id: 8525

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Support-Resistance Indicator");
    indicator:description("Support-Resistance Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");

    indicator.parameters:addInteger("Smoothing", "Smoothing", "Smoothing", 20);
    indicator.parameters:addInteger("Period", "Period", "Period", 20);
	
	indicator.parameters:addGroup("Style");

    indicator.parameters:addColor("Top_color", "Color of Top", "Color of Top", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Central_color", "Color of Central", "Color of Central", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Bottom_color", "Color of Bottom", "Color of Bottom", core.rgb(255, 0, 0));
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
local Smoothing;
local first;
local source = nil;

-- Streams block
local Top = nil;
local Central = nil;
local Bottom = nil;
local MA1, MA2;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Smoothing = instance.parameters.Smoothing;
    source = instance.source;
    
    local name = profile:id() .. "(" .. source:name()  .. ", " .. tostring(Smoothing).. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
	
        assert(core.indicators:findIndicator("GAUSS") ~= nil, "Please, download and install GAUSS.LUA indicator");
        MA1 = core.indicators:create("GAUSS", source.high, Smoothing);
        MA2 = core.indicators:create("GAUSS", source.low, Smoothing);
        first = MA1.DATA:first() + Period;
        Top = instance:addStream("Top", core.Line, name .. ".Top", "Top", instance.parameters.Top_color, first);
		Top:setWidth(instance.parameters.width1);
        Top:setStyle(instance.parameters.style1);
        Central = instance:addStream("Central", core.Line, name .. ".Central", "Central", instance.parameters.Central_color, first);
		Central:setWidth(instance.parameters.width2);
        Central:setStyle(instance.parameters.style2);
        Bottom = instance:addStream("Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.Bottom_color, first);
		Bottom:setWidth(instance.parameters.width3);
        Bottom:setStyle(instance.parameters.style3);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    MA1:update(mode);
	MA2:update(mode);
	
    if period< first  then
	return;
	end
	
	
	local min, max;
	
	min = mathex.min(MA2.DATA,period-Period+1 , period);
	max = mathex.max(MA1.DATA,period-Period+1,  period);
	
        Top[period] = max;
        Central[period] = (max + min)/2;
        Bottom[period] = min;
   
end

