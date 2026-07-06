-- Id: 6088
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=14923

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
    indicator:name("Wilder's RSI");
    indicator:description("Wilder's RSI");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	
	
   indicator.parameters:addGroup("RSI Style");
	
	indicator.parameters:addInteger("widthFirst", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleFirst", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleFirst", core.FLAG_LEVEL_STYLE);
	indicator.parameters:addColor("Color", "RSI Line Color", "", core.rgb(0, 255, 0));
	
	 indicator.parameters:addGroup("Levels Style" ); 
    indicator.parameters:addInteger("overbought", "Overbought Level", "", 70, 0, 100);
    indicator.parameters:addInteger("oversold", "Oversold Level", "", 30, 0, 100);
	
    indicator.parameters:addInteger("level_overboughtsold_width", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("level_overboughtsold_color", "Color", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;

-- Streams block
local RSI = nil;
local pos, neg;
local positive, negative;
local k;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first()+Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);
    if (not (nameOnly)) then
        k= 1/ Period;
        
        pos = instance:addInternalStream(0, 0);
        neg = instance:addInternalStream(0, 0);
        positive = instance:addInternalStream(0, 0);
        negative = instance:addInternalStream(0, 0);
        RSI = instance:addStream("RSI", core.Line, name, "RSI", instance.parameters.Color, first);
    RSI:setPrecision(math.max(2, instance.source:getPrecision()));
		RSI:addLevel(0);
		RSI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		RSI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		RSI:addLevel(100);
		
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
       if period < source:first()+1  then
    return;
    end
	
	local diff = source[period] - source[period-1];
	
	pos[period]=0;
	neg[period]=0;
	
	if diff > 0 then
	pos[period]=diff;
	elseif diff < 0 then
	neg[period]=math.abs(diff);
	end
	
    if period < first or not  source:hasData(period) then
    return;
    end
	
	if period == first then
	 positive[period] = mathex.avg (pos, period - Period +1 , period);
	 negative[period] = mathex.avg (neg, period - Period +1 , period);
	else
	positive[period] =  ((pos[period] - positive[period - 1]) * k) + positive[period - 1];
	 negative[period] =  ((neg[period] - negative[period - 1]) * k) + negative[period - 1];
	end
	
	
    RSI[period] =  100 - (100 / (1 + positive[period] / negative[period]));
   
end

