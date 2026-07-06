-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60479
-- Id: 11406

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
function Init()
    indicator:name("Advance Decline Line");
    indicator:description("Advance Decline Line");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 10);
    indicator.parameters:addBoolean("Cumulative", "Cumulative", "Cumulative", true);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("ADL_color", "Color of ADL", "Color of ADL", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("OB/OS Levels");	
	 indicator.parameters:addBoolean("Show", "Show OverBought/OverSold", "", false);
    indicator.parameters:addDouble("overbought", "Overbought Level","", 0);
    indicator.parameters:addDouble("oversold","Oversold Level","", 0);
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
local Cumulative;

local first;
local source = nil;

-- Streams block
local ADL = nil;
local Show;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    Cumulative = instance.parameters.Cumulative;
	Show = instance.parameters.Show;
    source = instance.source;
    first = source:first()+Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Cumulative) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        ADL = instance:addStream("ADL", core.Line, name, "ADL", instance.parameters.ADL_color, first);
    ADL:setPrecision(math.max(2, instance.source:getPrecision()));
		ADL:setWidth(instance.parameters.width);
        ADL:setStyle(instance.parameters.style);
		if Show then
		ADL:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		ADL:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		end
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period <first or not  source:hasData(period) then
	return;
	end	
	
	local rs=0;
    local fs=0;
	local i;
	 for i=0,Period-1, 1 do
		 if source.close[period-i]> source.open[period-i] then
		 rs=rs+1;
		 end
		 if source.close[period-i]< source.open[period-i] then
		 fs=fs+1;
		 end
	 end
 
        if Cumulative then
        ADL[period] =  rs - fs + ADL[period-1];
        else
		 ADL[period] =  rs - fs ;
		end
end

