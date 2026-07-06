-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66216
-- Id: 

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

function CreatePriceParameter(id, name, def)
    indicator.parameters:addString(id, name, "", def);
    indicator.parameters:addStringAlternative(id, "Close", "", "pr_close");
    indicator.parameters:addStringAlternative(id, "Open", "", "pr_open");
    indicator.parameters:addStringAlternative(id, "High", "", "pr_high");
    indicator.parameters:addStringAlternative(id, "Low", "", "pr_low");
    indicator.parameters:addStringAlternative(id, "Median", "", "pr_median");
    indicator.parameters:addStringAlternative(id, "Typical", "", "pr_typical");
    indicator.parameters:addStringAlternative(id, "Weighted", "", "pr_weighted");
    indicator.parameters:addStringAlternative(id, "Average (high+low+open+close)/4", "", "pr_average");
    indicator.parameters:addStringAlternative(id, "Average median body (open+close)/2", "", "pr_medianb");
    indicator.parameters:addStringAlternative(id, "Trend biased price", "", "pr_tbiased");
    indicator.parameters:addStringAlternative(id, "Trend biased (extreme) price", "", "pr_tbiased2");
    indicator.parameters:addStringAlternative(id, "Heiken ashi close", "", "pr_haclose");
    indicator.parameters:addStringAlternative(id, "Heiken ashi open", "", "pr_haopen");
    indicator.parameters:addStringAlternative(id, "Heiken ashi high", "", "pr_hahigh");
    indicator.parameters:addStringAlternative(id, "Heiken ashi low", "", "pr_halow");
    indicator.parameters:addStringAlternative(id, "Heiken ashi median", "", "pr_hamedian");
    indicator.parameters:addStringAlternative(id, "Heiken ashi typical", "", "pr_hatypical");
    indicator.parameters:addStringAlternative(id, "Heiken ashi weighted", "", "pr_haweighted");
    indicator.parameters:addStringAlternative(id, "Heiken ashi average", "", "pr_haaverage");
    indicator.parameters:addStringAlternative(id, "Heiken ashi median body", "", "pr_hamedianb");
    indicator.parameters:addStringAlternative(id, "Heiken ashi trend biased price", "", "pr_hatbiased");
    indicator.parameters:addStringAlternative(id, "Heiken ashi trend biased (extreme) price", "", "pr_hatbiased2");
    indicator.parameters:addStringAlternative(id, "Heiken ashi (better formula) close", "", "pr_habclose");
    indicator.parameters:addStringAlternative(id, "Heiken ashi (better formula) open", "", "pr_habopen");
    indicator.parameters:addStringAlternative(id, "Heiken ashi (better formula) high", "", "pr_habhigh");
    indicator.parameters:addStringAlternative(id, "Heiken ashi (better formula) low", "", "pr_hablow");
    indicator.parameters:addStringAlternative(id, "Heiken ashi (better formula) median", "", "pr_habmedian");
    indicator.parameters:addStringAlternative(id, "Heiken ashi (better formula) typical", "", "pr_habtypical");
    indicator.parameters:addStringAlternative(id, "Heiken ashi (better formula) weighted", "", "pr_habweighted");
    indicator.parameters:addStringAlternative(id, "Heiken ashi (better formula) average", "", "pr_habaverage");
    indicator.parameters:addStringAlternative(id, "Heiken ashi (better formula) median body", "", "pr_habmedianb");
    indicator.parameters:addStringAlternative(id, "Heiken ashi (better formula) trend biased price", "", "pr_habtbiased");
    indicator.parameters:addStringAlternative(id, "Heiken ashi (better formula) trend biased (extreme) price", "", "pr_habtbiased2");
end

function Init()
    indicator:name("quantile bands");
    indicator:description("quantile bands");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addDouble("Periods", "Calculating period", "", 35);
    CreatePriceParameter("PriceM", "Median price", "pr_median");
    CreatePriceParameter("PriceH", "High price", "pr_high");
    CreatePriceParameter("PriceL", "Low price", "pr_low");
    indicator.parameters:addDouble("UpperBandPercent", "Upper band percent", "", 90);
    indicator.parameters:addDouble("LowerBandPercent", "Lower band percent", "", 10);
    indicator.parameters:addDouble("MedianBandPercent", "Median percent", "", 50);
    indicator.parameters:addBoolean("Interpolate", "Interpolate in multi time frame mode?", "", true);

    indicator.parameters:addColor("bufferUp", "bufferUp", "", core.colors().LimeGreen);
    indicator.parameters:addColor("bufferUpa", "bufferUpa", "", core.colors().SandyBrown);
    indicator.parameters:addColor("bufferUpb", "bufferUpb", "", core.colors().SandyBrown);
    indicator.parameters:addColor("bufferDn", "bufferDn", "", core.colors().LimeGreen);
    indicator.parameters:addColor("bufferDna", "bufferDna", "", core.colors().SandyBrown);
    indicator.parameters:addColor("bufferDnb", "bufferDnb", "", core.colors().SandyBrown);
    indicator.parameters:addColor("bufferMe", "bufferMe", "", core.colors().Silver);
    indicator.parameters:addInteger("bufferMe_w", "bufferMe width", "", 3, 1, 5);
    indicator.parameters:addColor("bufferMua", "bufferMua", "", core.colors().LimeGreen);
    indicator.parameters:addInteger("bufferMua_w", "bufferMua width", "", 3, 1, 5);
    indicator.parameters:addColor("bufferMub", "bufferMub", "", core.colors().LimeGreen);
    indicator.parameters:addInteger("bufferMub_w", "bufferMub width", "", 3, 1, 5);
    indicator.parameters:addColor("bufferMda", "bufferMda", "", core.colors().SandyBrown);
    indicator.parameters:addInteger("bufferMda_w", "bufferMda width", "", 3, 1, 5);
    indicator.parameters:addColor("bufferMdb", "bufferMdb", "", core.colors().SandyBrown);
    indicator.parameters:addInteger("bufferMdb_w", "bufferMdb width", "", 3, 1, 5);
end

local source;
local first;
local _priceInstances = 3;
local _priceInstancesSize = 4;
local _priceWorkHa = {};
local btf;
local Interpolate;
local MedianBandPercent;
local LowerBandPercent;
local UpperBandPercent;
local PriceL;
local PriceH;
local PriceM;
local bufferUp;
local bufferUpa;
local bufferUpb;
local bufferDn;
local bufferDna;
local bufferDnb;
local bufferMe;
local bufferMua;
local bufferMub;
local bufferMda;
local bufferMdb;
local trendu;
local trendd;
local trendm;
local pricesm;
local pricesl;
local pricesh;
local count;
local Periods;

-- Routine
function Prepare(name_only)
    source = instance.source;
    first = source:first();
    PriceM = instance.parameters.PriceM;
    PriceH = instance.parameters.PriceH;
    PriceL = instance.parameters.PriceL;
    UpperBandPercent = instance.parameters.UpperBandPercent;
    LowerBandPercent = instance.parameters.LowerBandPercent;
    MedianBandPercent = instance.parameters.MedianBandPercent;
    Interpolate = instance.parameters.Interpolate;
    Periods = instance.parameters.Periods;

    local name = string.format("%s", profile:id());
    instance:name(name);
    if name_only then
        return;
    end
    
    bufferUp = instance:addStream("bufferUp", core.Line, name .. ".bufferUp", "bufferUp", instance.parameters.bufferUp, 0);
    bufferUpa = instance:addStream("bufferUpa", core.Line, name .. ".bufferUpa", "bufferUpa", instance.parameters.bufferUpa, 0);
    bufferUpb = instance:addStream("bufferUpb", core.Line, name .. ".bufferUpb", "bufferUpb", instance.parameters.bufferUpb, 0);
    bufferDn = instance:addStream("bufferDn", core.Line, name .. ".bufferDn", "bufferDn", instance.parameters.bufferDn, 0);
    bufferDna = instance:addStream("bufferDna", core.Line, name .. ".bufferDna", "bufferDna", instance.parameters.bufferDna, 0);
    bufferDnb = instance:addStream("bufferDnb", core.Line, name .. ".bufferDnb", "bufferDnb", instance.parameters.bufferDnb, 0);
    bufferMe = instance:addStream("bufferMe", core.Line, name .. ".bufferMe", "bufferMe", instance.parameters.bufferMe, 0);
    bufferMe:setWidth(instance.parameters.bufferMe_w);
    bufferMua = instance:addStream("bufferMua", core.Line, name .. ".bufferMua", "bufferMua", instance.parameters.bufferMua, 0);
    bufferMua:setWidth(instance.parameters.bufferMua_w);
    bufferMub = instance:addStream("bufferMub", core.Line, name .. ".bufferMub", "bufferMub", instance.parameters.bufferMub, 0);
    bufferMub:setWidth(instance.parameters.bufferMub_w);
    bufferMda = instance:addStream("bufferMda", core.Line, name .. ".bufferMda", "bufferMda", instance.parameters.bufferMda, 0);
    bufferMda:setWidth(instance.parameters.bufferMda_w);
    bufferMdb = instance:addStream("bufferMdb", core.Line, name .. ".bufferMdb", "bufferMdb", instance.parameters.bufferMdb, 0);
    bufferMdb:setWidth(instance.parameters.bufferMdb_w);
    trendu = instance:addInternalStream(0, 0);
    trendd = instance:addInternalStream(0, 0);
    trendm = instance:addInternalStream(0, 0);
    pricesm = instance:addInternalStream(0, 0);
    pricesl = instance:addInternalStream(0, 0);
    pricesh = instance:addInternalStream(0, 0);
    count = instance:addInternalStream(0, 0);
    
    for i = 0, _priceInstances * _priceInstancesSize - 1 do
        _priceWorkHa[i] = instance:addInternalStream(0, 0);
    end
end

function AsyncOperationFinished(cookie)
end

function Update(period, mode)
    if (trendu[period] == -1) then
        CleanPoint(period, bufferUpa, bufferUpb);
    end
    if (trendd[period] == -1) then
        CleanPoint(period, bufferDna, bufferDnb);
    end
    if (trendm[period] > 0) then
        CleanPoint(period, bufferMua, bufferMub);
    end
    if (trendm[period] < 0) then
        CleanPoint(period, bufferMda, bufferMdb);
    end
    local prices = {};
    table.insert(prices, getPrice(PriceH, period, 0));
    table.insert(prices, getPrice(PriceL, period, 1));
    table.insert(prices, getPrice(PriceM, period, 2));
    table.sort(prices, function(a,b) return b > a end);
    for i, val in ipairs(prices) do
        if (i == 1) then
            pricesl[period] = val;
        end
        if (i == 2) then
            pricesm[period] = val;
        end
        if (i == 3) then
            pricesh[period] = val;
        end
    end
    if period < Periods then
        return;
    end

    local workPricesH = {};
    local workPricesM = {};
    local workPricesL = {};
    for i = 0, Periods - 1 do
        table.insert(workPricesH, pricesh[period - i]);
        table.insert(workPricesM, pricesm[period - i]);
        table.insert(workPricesL, pricesl[period - i]);
    end
    table.sort(workPricesH, function(a,b) return b > a end);
    table.sort(workPricesM, function(a,b) return b > a end);
    table.sort(workPricesL, function(a,b) return b > a end);
    bufferUp[period] = iQuantile(Periods, UpperBandPercent, workPricesH);
    bufferDn[period] = iQuantile(Periods, LowerBandPercent, workPricesL);
    bufferMe[period] = iQuantile(Periods, MedianBandPercent, workPricesM);

    if bufferUp[period] > bufferUp[period - 1] then
        trendu[period] = 1;
    elseif bufferUp[period] < bufferUp[period - 1] then
        trendu[period] = -1;
    else
        trendu[period] = trendu[period - 1];
    end
    if bufferDn[period] > bufferDn[period - 1] then
        trendd[period] = 1;
    elseif bufferDn[period] < bufferDn[period - 1] then
        trendd[period] = -1;
    else
        trendd[period] = trendd[period - 1];
    end
    trendm[period] = trendu[period] + trendd[period];
    if (trendu[period] == -1) then
        PlotPoint(period, bufferUpa, bufferUpb, bufferUp);
    end
    if (trendd[period] == -1) then
        PlotPoint(period, bufferDna, bufferDnb, bufferDn);
    end
    if (trendm[period] < 0) then
        PlotPoint(period, bufferMda, bufferMdb, bufferMe);
    end
    if (trendm[period] > 0) then
        PlotPoint(period, bufferMua, bufferMub, bufferMe);
    end
end

function _prHABF(_prtype)
    return _prtype == "pr_habclose" or _prtype == "pr_habopen" or _prtype == "pr_habhigh"
        or _prtype == "pr_hablow" or _prtype == "pr_habmedian" or _prtype == "pr_habtypical"
        or _prtype == "pr_habweighted" or _prtype == "pr_habaverage" or _prtype == "pr_habmedianb"
        or _prtype == "pr_habtbiased" or _prtype == "pr_habtbiased2";
end

function getPrice(tprice, period, instance)
    if tprice == "pr_haclose" or _prHABF(tprice) or tprice == "pr_hatbiased2" or tprice == "pr_hatbiased"
        or tprice == "pr_haaverage" or tprice == "pr_haweighted" or tprice == "pr_hatypical"
        or tprice == "pr_hamedianb" or tprice == "pr_hamedian" or tprice == "pr_halow" or tprice == "pr_hahigh"
        or tprice == "pr_haopen" 
    then
        local r = period;
        local haOpen = (r > 0) and ((_priceWorkHa[instance * 4 + 2][r - 1] + _priceWorkHa[instance * 4 + 3][r - 1]) / 2.0) or ((source.open[period] + source.close[period]) / 2);
        local haClose = (source.open[period] + source.high[period] + source.low[period] + source.close[period]) / 4.0;
        if _prHABF(tprice) then
            if source.high[period] ~= source.low[period] then
                haClose = (source.open[period] + source.close[period]) / 2.0 + (((source.close[period] - source.open[period]) / (source.high[period] - source.low[period])) * math.abs((source.close[period] - source.open[period]) / 2.0));
            else
                haClose = (source.open[period] + source.close[period]) / 2.0; 
            end
        end
        local haHigh = math.max(source.high[period], math.max(haOpen, haClose));
        local haLow = math.min(source.low[period], math.min(haOpen, haClose));
        if (haOpen < haClose) then
            _priceWorkHa[instance * 4 + 0][r] = haLow;
            _priceWorkHa[instance * 4 + 1][r] = haHigh;
        else
            _priceWorkHa[instance * 4 + 0][r] = haHigh;
            _priceWorkHa[instance * 4 + 1][r] = haLow;
        end
        _priceWorkHa[instance * 4 + 2][r] = haOpen;
        _priceWorkHa[instance * 4 + 3][r] = haClose;
        if tprice == "pr_haclose" or tprice == "pr_habclose" then
            return haClose;
        end
        if tprice == "pr_haopen" or tprice == "pr_habopen" then
            return haOpen;
        end
        if tprice == "pr_hahigh" or tprice == "pr_habhigh" then
            return haHigh;
        end
        if tprice == "pr_halow" or tprice == "pr_hablow" then
            return haLow;
        end
        if tprice == "pr_hamedian" or tprice == "pr_habmedian" then
            return (haHigh + haLow) / 2.0;
        end
        if tprice == "pr_hamedianb" or tprice == "pr_habmedianb" then
            return (haOpen + haClose) / 2.0;
        end
        if tprice == "pr_hatypical" or tprice == "pr_habtypical" then
            return (haHigh + haLow + haClose) / 3.0;
        end
        if tprice == "pr_haweighted" or tprice == "pr_habweighted" then
            return (haHigh + haLow + haClose + haClose) / 4.0;
        end
        if tprice == "pr_haaverage" or tprice == "pr_habaverage" then
            return (haHigh + haLow + haClose + haOpen) / 4.0;
        end
        if tprice == "pr_hatbiased" or tprice == "pr_habtbiased" then
            if haClose > haOpen then
                return (haHigh + haClose) / 2.0;
            else
                return (haLow + haClose) / 2.0;
            end
        end
        if tprice == "pr_hatbiased2" or tprice == "pr_habtbiased2" then
            if (haClose > haOpen) then
                return haHigh;
            end
            if (haClose < haOpen) then
                return haLow;
            end
        end
        return haClose;
    end
    if tprice == "pr_close" then
        return source.close[period];
    end
    if tprice == "pr_open" then
        return source.open[period];
    end
    if tprice == "pr_high" then
        return source.high[period];
    end
    if tprice == "pr_low" then
        return source.low[period];
    end
    if tprice == "pr_median" then
        return (source.high[period] + source.low[period]) / 2.0;
    end
    if tprice == "pr_medianb" then
        return (source.open[period] + source.close[period]) / 2.0;
    end
    if tprice == "pr_typical" then
        return (source.high[period] + source.low[period] + source.close[period]) / 3.0;
    end
    if tprice == "pr_weighted" then
        return (source.high[period] + source.low[period] + source.close[period] + source.close[period]) / 4.0;
    end
    if tprice == "pr_average" then 
        return (source.high[period] + source.low[period] + source.close[period] + source.open[period]) / 4.0;
    end
    if tprice == "pr_tbiased" then
        if source.close[period] > source.open[period] then
            return (source.high[period] + source.close[period]) / 2.0;
        else
            return (source.low[period] + source.close[period]) / 2.0;
        end
    end
    if tprice == "pr_tbiased2" then
        if source.close[period] > source.open[period] then
            return source.high[period];
        end
        if source.close[period] < source.open[period] then
            return source.low[period];
        end
        return source.close[period];
    end
    return 0;
end
 
function iQuantile(period, qp, quantileArray)
    local index = (period - 1) * qp / 100.00;
    local ind = math.floor(index);
    local delta = index - ind;
    if delta < 0.00001 then
        return quantileArray[ind];
    else
        return (1.0 - delta) * quantileArray[ind] + delta * quantileArray[ind + 1];
    end
end

function CleanPoint(i, first, second)
    if i <= 3 then
        return;
    end
    if (second[period] ~= EMPTY_VALUE) and (second[period - 1] ~= EMPTY_VALUE) then
        second[period - 1] = EMPTY_VALUE;
    elseif (first[period] ~= EMPTY_VALUE) and (first[period - 1] ~= EMPTY_VALUE) and (first[i - 2] == EMPTY_VALUE) then
        first[period - 1] = EMPTY_VALUE;
    end
end

function PlotPoint(period, first, second, from)
    if period <= 2 then
        return;
    end
    if first[period - 1] == EMPTY_VALUE then
        if first[period - 2] == EMPTY_VALUE then
            first[period] = from[period];
            first[period + 1] = from[period + 1];
            second[period] = EMPTY_VALUE;
        else
            second[period] = from[period];
            second[period + 1] = from[period + 1];
            first[period] = EMPTY_VALUE;
        end
    else
        first[period] = from[period];
        second[period] = EMPTY_VALUE;
    end
end
