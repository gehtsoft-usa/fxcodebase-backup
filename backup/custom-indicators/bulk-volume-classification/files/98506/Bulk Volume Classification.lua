-- Id: 13558
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61786

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
    indicator:name("Bulk Volume Classification");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addColor("vb_color", "Color of vb", "Color of vb", core.rgb(0, 255, 0));
    indicator.parameters:addColor("vs_color", "Color of vs", "Color of vs", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

-- Streams block
local vb = nil;
local vs = nil;
local price_diff = nil;
local periods = 2; --page 9: use the standardized price change between the two consecutive intervals

-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first() + periods + 1;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        vb = instance:addStream("vb", core.Bar, name .. ".vb", "vb", instance.parameters.vb_color, first);
    vb:setPrecision(math.max(2, instance.source:getPrecision()));
        vs = instance:addStream("vs", core.Bar, name .. ".vs", "vs", instance.parameters.vs_color, first);
    vs:setPrecision(math.max(2, instance.source:getPrecision()));
        price_diff = instance:addInternalStream(0, 0);
    end
end
 

function cfd(x)
    --http://en.wikipedia.org/wiki/Normal_distribution
    local sum = x;
    local value = x;
    for i = 1, 100 do
        value = value * x * x / (2 * i + 1);
        sum = sum + value;
    end
    return 0.5 + (sum / math.sqrt(2 * math.pi)) * math.exp(-(x * x) / 2);
end

function weigthed_mean(period, n, wi, xi)
    -- http://stats.stackexchange.com/questions/6534/how-do-i-calculate-a-weighted-standard-deviation-in-excel
    local w_summ = 0;
    local w_x_summ = 0
    for i = 0, n - 1 do
        w_summ = w_summ + wi[period - i];
        w_x_summ = w_x_summ + wi[period - i] * xi[period - i];
    end
    return w_x_summ / w_summ;
end

function weightsd(period, n, wi, xi)
    -- http://www.itl.nist.gov/div898/software/dataplot/refman2/ch2/weightsd.pdf
    -- http://stats.stackexchange.com/questions/6534/how-do-i-calculate-a-weighted-standard-deviation-in-excel
    local x = weigthed_mean(period, n, wi, xi);
    local w_summ = 0;
    local w_xi_x_summ = 0
    for i = 0, n - 1 do
        w_summ = w_summ + wi[period - i];
        w_xi_x_summ = w_xi_x_summ + wi[period - i] * math.pow(xi[period - i] - x, 2);
    end
    return math.sqrt(w_xi_x_summ / ((n - 1) * w_summ / n));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period) 
    --code converted from the python sample in the document
    if period >= 1 then
        price_diff[period] = source.close[period] - source.close[period - 1];
    end
    if period >= first and source:hasData(period) then
        local stdDev = weightsd(period, price_diff:size() - 1, source.volume, price_diff)
        local z = price_diff[period] / stdDev;
        local z = cfd(z);
        vb[period] = source.volume[period] * z;
        vs[period] = source.volume[period] * (1 - z) * (-1);-- * (-1) to get the down bar
    end

end
