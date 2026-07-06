-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60293
-- Id: 11113

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
    indicator:name("Volatility Ratio");
    indicator:description("Volatility Ratio");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
   
	
	indicator.parameters:addGroup("Style");
	 indicator.parameters:addColor("VR_color", "Color of VR", "Color of VR", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
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
local VR = nil; 
function getTrueRange(period)
    local hl = math.abs(source.high[period] - source.low[period]);
    local hc = math.abs(source.high[period] - source.close[period - 1]);
    local lc = math.abs(source.low[period] - source.close[period - 1]);

    local tr = hl;
    if (tr < hc) then
        tr = hc;
    end
    if (tr < lc) then
        tr = lc;
    end
    return tr;
end

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
	 
    first = source:first()+1 + Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        VR = instance:addStream("VR", core.Line, name, "VR", instance.parameters.VR_color, first);
    VR:setPrecision(math.max(2, instance.source:getPrecision()));
		VR:setWidth(instance.parameters.width);
        VR:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

 
 
     local tr = getTrueRange(period);
    if period < first or not source:hasData(period) then
	return;
	end
	
	local min, max = mathex.minmax(source, period-Period+1, period);
	local pr = math.max(max,source.open[period-Period+1])-math.min (min,source.open[period-Period+1] );
	
   VR[period] = tr/pr;
    
end

