-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59547
-- Id: 10026

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
    indicator:name("ATR Candle Range Ratio");
    indicator:description("ATR Period Range Ratio");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addString("Method", "Range Type", "" , "Close/Open");
    indicator.parameters:addStringAlternative("Method", "Close/Open", "Close/Open" , "Close/Open");
    indicator.parameters:addStringAlternative("Method", "High/Low", "High/Low" , "High/Low");
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Color", "Line Color", "Line Colorr", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 110);
    indicator.parameters:addDouble("oversold","Oversold Level","", 10);
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
local Color, Period;
local Method;
local first;
local source = nil;
local ATR;
-- Streams block
local Ratio;

-- Routine
function Prepare(nameOnly)
    Color= instance.parameters.Color;
	Method= instance.parameters.Method;
	Period= instance.parameters.Period;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(Method) .. ")";
    instance:name(name);
	
    if (not (nameOnly)) then
        ATR = core.indicators:create("ATR", source, Period);
    
        first = ATR.DATA:first();
        Ratio = instance:addStream("Ratio", core.Line, name, "Ratio", Color, first);
		Ratio:setWidth(instance.parameters.width);
        Ratio:setStyle(instance.parameters.style);
		
		Ratio:setPrecision(math.max(2, instance.source:getPrecision()));
		
        Ratio:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		Ratio:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    ATR:update(mode);
    if period < first  then
	return;
	end
	
	local X;
	
	if Method ==  "Close/Open" then
	X= math.abs(source.open[period]- source.close[period]);
	else
	X= source.high[period]- source.low[period];
	end
	
	
	
    Ratio[period] = X/(ATR.DATA[period]/100);
   
end

