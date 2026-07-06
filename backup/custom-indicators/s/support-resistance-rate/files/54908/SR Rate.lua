-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32211
-- Id: 8527

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
    indicator:name("Support-Resistance Rate");
    indicator:description("Support-Resistance Rate");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");

    indicator.parameters:addInteger("Smoothing", "Smoothing", "Smoothing", 20);
    indicator.parameters:addInteger("Period", "Period", "Period", 20);
	
	indicator.parameters:addGroup("Style");

    indicator.parameters:addColor("color", "Color of SR Line", "Color of SR Line", core.rgb(0, 255, 0));
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
local Smoothing;
local first;
local source = nil;

-- Streams block
local SR;
local MA1, MA2, MA3;
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
        MA3 = core.indicators:create("GAUSS", source.low, Smoothing);
        first = MA1.DATA:first() + Period;
        
        SR = instance:addStream("SR", core.Line, name .. ".SR", "SR", instance.parameters.color, first);
    SR:setPrecision(math.max(2, instance.source:getPrecision()));
        SR:setWidth(instance.parameters.width);
        SR:setStyle(instance.parameters.style);		
        SR:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		SR:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		
	
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    MA1:update(mode);
	MA2:update(mode);
	MA3:update(mode);
	
    if period< first  then
	return;
	end
	
	
	local min, max;
	
	min = mathex.min(MA2.DATA,period-Period+1 , period);
	max = mathex.max(MA1.DATA,period-Period+1,  period);
	
        SR[period] =(MA3.DATA[period] - min)/(max - min);
   
end

