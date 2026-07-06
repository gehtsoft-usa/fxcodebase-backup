-- Id: 18538
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60079

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Relative Spread Strength");
    indicator:description("Relative Spread Strength");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Short", "Short MA Period", "Short MA Period", 10);
    indicator.parameters:addInteger("Long", "Long Period MA", "Long Period MA", 50);
    indicator.parameters:addInteger("RSI", "RSI Period", "RSI Period", 5);
	indicator.parameters:addInteger("Smoothing", "Smoothing Period", "Smoothing Period", 5);
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("RSS_color", "Color of RSS", "Color of RSS", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
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
local Short;
local Long;
local RSI, rsi, ma;
local Smoothing;
local first;
local source = nil;
local short, long;
-- Streams block
local RSS = nil;
local Spread;
-- Routine
function Prepare(nameOnly)
    Short = instance.parameters.Short;
	Smoothing = instance.parameters.Smoothing;
    Long = instance.parameters.Long;
    RSI = instance.parameters.RSI;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Short) .. ", " .. tostring(Long) .. ", " .. tostring(RSI) .. ", " .. tostring(Smoothing) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        short = core.indicators:create("EMA",source, Short);	
        long = core.indicators:create("EMA", source, Long);
    
        first = math.max(short.DATA:first(), long.DATA:first());
        
        Spread = instance:addInternalStream(0, 0);
        rsi = core.indicators:create("RSI", Spread, RSI);
        ma = core.indicators:create("MVA", rsi.DATA,Smoothing);
        RSS = instance:addStream("RSS", core.Line, name, "RSS", instance.parameters.RSS_color, ma.DATA:first());
    RSS:setPrecision(math.max(2, instance.source:getPrecision()));
		RSS:setWidth(instance.parameters.width);
        RSS:setStyle(instance.parameters.style);
		
        RSS:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		RSS:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    short:update(mode);
	long:update(mode);

	
    if period < first  then
	return;
	end
	
	Spread[period]=short.DATA[period]-long.DATA[period];
	rsi:update(mode);
	ma:update(mode);
	
	 if period < ma.DATA:first()  then
	return;
	end
	
 
	
        RSS[period] = ma.DATA[period];
		
		
   
end

 
 --Smooth = savg(RS, 5)
 --Smooth

