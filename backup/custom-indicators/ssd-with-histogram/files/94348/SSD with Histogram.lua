-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60786
-- Id: 11908

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


-- The indicator corresponds to the Stochastic indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 6 "Momentum and Oscillators" (page 135-137)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Stochastic Slow");
    indicator:description("Shows the location of the current close relative to the high/low range over a set number of periods.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("K", "%K periods","", 5, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods","", 3, 2, 1000);
    indicator.parameters:addInteger("D", "%D periods","", 3, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrFirst", "K Line Color","", core.rgb(0, 183, 183));
    indicator.parameters:addInteger("widthFirst", "K Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleFirst", "K Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleFirst", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrSecond", "D Line Color","", core.rgb(219, 63, 0));
    indicator.parameters:addInteger("widthSecond", "D Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleSecond", "D Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSecond", core.FLAG_LEVEL_STYLE);
	
	 indicator.parameters:addColor("clrUp", "Histogram Up Color","", core.rgb(0, 255, 0));
     indicator.parameters:addColor("clrDown", "Histogram Down Color","", core.rgb(255, 0, 0));
	 
    indicator.parameters:addGroup("Levels");
    -- Overboughy/oversold level
    indicator.parameters:addDouble("overbought", "Overbought Level","", 30 );
    indicator.parameters:addDouble("oversold", "Oversold Level","", -30 );
    indicator.parameters:addInteger("level_overboughtsold_width", "Overbought Oversold Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style","Overbought Oversold Line Style","", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "Overbought Oversold Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local k;
local d;
local sd;

local source = nil;
local signalLine = nil;
local sfk = nil;
local kFirst = nil;
local dFirst = nil;
local Histogram;
-- Streams block
local K = nil;
local D = nil;

-- Routine
function Prepare(nameOnly)
    assert(instance.parameters.oversold < instance.parameters.overbought, "Overbought should be greater than Oversold");

    k = instance.parameters.K;
    d = instance.parameters.D;
    sd = instance.parameters.SD;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. k .. ", " .. d .. ", " .. sd .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    sfk = core.indicators:create("SFK", source, k, sd);
    K = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.clrFirst, sfk.D:first());
    K:setWidth(instance.parameters.widthFirst);
    K:setStyle(instance.parameters.styleFirst);
    K:setPrecision(2);

    D = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.clrSecond, K:first() + d - 1);
    D:setWidth(instance.parameters.widthSecond);
    D:setStyle(instance.parameters.styleSecond);
    D:setPrecision(2);
    kFirst = K:first();
    dFirst = D:first();
	
	Histogram= instance:addStream("Histogram", core.Bar, name .. ".Histogram", "Histogram", instance.parameters.clrUp, K:first() + d - 1);
    Histogram:setPrecision(math.max(2, instance.source:getPrecision()));

    D:addLevel(-50);
    D:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    D:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    D:addLevel(50);
end

-- Indicator calculation routine
function Update(period, mode)
    sfk:update(mode);
    if period < kFirst then
	return;
	end
	
        K[period] = sfk.D[period]-50;
    
    if period < dFirst then
	return;
	end
	
        D[period] = mathex.avg(K, period - d + 1, period);
        Histogram[period]=K[period]-D[period];
		
		if Histogram[period] >Histogram[period-1] then
		Color = instance.parameters.clrUp;
		else
		Color = instance.parameters.clrDown;
		end
		
		Histogram:setColor(period, Color);
end

