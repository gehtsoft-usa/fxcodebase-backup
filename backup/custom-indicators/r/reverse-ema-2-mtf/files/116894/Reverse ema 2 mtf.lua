-- Id: 20303
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65611

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
    indicator:name("Reverse ema 2 mtf");
    indicator:description("Reverse ema 2 mtf");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addString("TimeFrame", "Time frame", "", "m1");
    indicator.parameters:setFlag("TimeFrame", core.FLAG_BARPERIODS);
    indicator.parameters:addInteger("EmaPeriodT", "Trend ema period", "", 5);
    indicator.parameters:addInteger("EmaPeriodC", "Cycle ema period", "", 39);
    indicator.parameters:addString("EmaPrice", "Price to use", "", "pr_close");
    indicator.parameters:addStringAlternative("EmaPrice", "Close", "", "pr_close");
    indicator.parameters:addStringAlternative("EmaPrice", "Open", "", "pr_open");
    indicator.parameters:addStringAlternative("EmaPrice", "High", "", "pr_high");
    indicator.parameters:addStringAlternative("EmaPrice", "Low", "", "pr_low");
    indicator.parameters:addStringAlternative("EmaPrice", "Median", "", "pr_median");
    indicator.parameters:addStringAlternative("EmaPrice", "Typical", "", "pr_typical");
    indicator.parameters:addStringAlternative("EmaPrice", "Weighted", "", "pr_weighted");
    indicator.parameters:addStringAlternative("EmaPrice", "Average (high+low+open+close)/4", "", "pr_average");
    indicator.parameters:addStringAlternative("EmaPrice", "Average median body (open+close)/2", "", "pr_medianb");
    indicator.parameters:addStringAlternative("EmaPrice", "Trend biased price", "", "pr_tbiased");
    indicator.parameters:addStringAlternative("EmaPrice", "Trend biased (extreme) price", "", "pr_tbiased2");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi close", "", "pr_haclose");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi open", "", "pr_haopen");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi high", "", "pr_hahigh");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi low", "", "pr_halow");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi median", "", "pr_hamedian");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi typical", "", "pr_hatypical");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi weighted", "", "pr_haweighted");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi average", "", "pr_haaverage");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi median body", "", "pr_hamedianb");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi trend biased price", "", "pr_hatbiased");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi trend biased (extreme) price", "", "pr_hatbiased2");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi (better formula) close", "", "pr_habclose");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi (better formula) open", "", "pr_habopen");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi (better formula) high", "", "pr_habhigh");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi (better formula) low", "", "pr_hablow");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi (better formula) median", "", "pr_habmedian");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi (better formula) typical", "", "pr_habtypical");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi (better formula) weighted", "", "pr_habweighted");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi (better formula) average", "", "pr_habaverage");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi (better formula) median body", "", "pr_habmedianb");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi (better formula) trend biased price", "", "pr_habtbiased");
    indicator.parameters:addStringAlternative("EmaPrice", "Heiken ashi (better formula) trend biased (extreme) price", "", "pr_habtbiased2");

    indicator.parameters:addString("ColorOn", "Color change on", "", "col_onCycle");
    indicator.parameters:addStringAlternative("ColorOn", "Change color on slope change", "", "col_onSlope");
    indicator.parameters:addStringAlternative("ColorOn", "Change color when slopes are the same", "", "col_onSlope2");
    indicator.parameters:addStringAlternative("ColorOn", "Change color on zero cross", "", "col_onZero");
    indicator.parameters:addStringAlternative("ColorOn", "Change color when values are on the same side of zero", "", "col_onZero2");
    indicator.parameters:addStringAlternative("ColorOn", "Change color on trend crossing cycle", "", "col_onCycle");

    indicator.parameters:addColor("emat", "emat", "", core.colors().Silver);
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("emac", "emac", "", core.colors().DeepSkyBlue);
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("emacUa", "emacUa", "", core.colors().DeepSkyBlue);
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("emacUb", "emacUb", "", core.colors().SandyBrown);
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("emacDa", "emacDa", "", core.colors().SandyBrown);
	indicator.parameters:addInteger("width5", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style5", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style5", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("emacDb", "emacDb", "", core.colors().Silver);
	indicator.parameters:addInteger("width6", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style6", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style6", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("ematUa", "ematUa", "", core.colors().DeepSkyBlue);
	indicator.parameters:addInteger("width7", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style7", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style7", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("ematUb", "ematUb", "", core.colors().DeepSkyBlue);
	indicator.parameters:addInteger("width8", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style8", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style8", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("ematDa", "ematDa", "", core.colors().SandyBrown);
	indicator.parameters:addInteger("width9", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style9", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style9", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("ematDb", "ematDb", "", core.colors().SandyBrown);	
	indicator.parameters:addInteger("width10", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style10", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style10", core.FLAG_LINE_STYLE);
end

local TimeFrame;
local EmaPeriodT;
local EmaPeriodC;
local EmaPrice;
local ColorOn;
local source;
local first;
local trendt;
local trendc;
local emat;
local emac;
local emacUa;
local emacUb;
local emacDa;
local emacDb;
local ematUa;
local ematUb;
local ematDa;
local ematDb;
local trenwt;
local trenwc;
local workRema = {};
local _remaInstances = 2;
local _remaInstancesSize = 9;
local _priceInstances = 1;
local _priceInstancesSize = 4;
local _priceWorkHa = {};
local btf;

-- Routine
function Prepare(name_only)
    source = instance.source;
    first = source:first();
    TimeFrame = instance.parameters.TimeFrame;
    EmaPeriodT = instance.parameters.EmaPeriodT;
    EmaPeriodC = instance.parameters.EmaPeriodC;
    EmaPrice = instance.parameters.EmaPrice;
    ColorOn = instance.parameters.ColorOn;
    
    local name = string.format("%s (%s, %d, %d)", profile:id(), TimeFrame, EmaPeriodT, EmaPeriodC);
    instance:name(name);

    if name_only then
        return;
    end

    trendt = instance:addInternalStream(0, 0);
    trendc = instance:addInternalStream(0, 0);
    trenwt = instance:addInternalStream(0, 0);
    trenwc = instance:addInternalStream(0, 0);
    emat = instance:addStream("emat", core.Line, name .. ".emat", "emat", instance.parameters.emat, 0);
    emat:setPrecision(math.max(2, instance.source:getPrecision()));
	emat:setWidth(instance.parameters.width1);
    emat:setStyle(instance.parameters.style1);
		
    emac = instance:addStream("emac", core.Line, name .. ".emac", "emac", instance.parameters.emac, 0);
    emac:setPrecision(math.max(2, instance.source:getPrecision()));
	emac:setWidth(instance.parameters.width2);
    emac:setStyle(instance.parameters.style2);
	
    emacUa = instance:addStream("emacUa", core.Line, name .. ".emacUa", "emacUa", instance.parameters.emacUa, 0);
    emacUa:setPrecision(math.max(2, instance.source:getPrecision()));
	emacUa:setWidth(instance.parameters.width3);
    emacUa:setStyle(instance.parameters.style3);
	
    emacUb = instance:addStream("emacUb", core.Line, name .. ".emacUb", "emacUb", instance.parameters.emacUb, 0);
    emacUb:setPrecision(math.max(2, instance.source:getPrecision()));
	emacUb:setWidth(instance.parameters.width4);
    emacUb:setStyle(instance.parameters.style4);
	
    emacDa = instance:addStream("emacDa", core.Line, name .. ".emacDa", "emacDa", instance.parameters.emacDa, 0);
    emacDa:setPrecision(math.max(2, instance.source:getPrecision()));
	emacDa:setWidth(instance.parameters.width5);
    emacDa:setStyle(instance.parameters.style5);
	
    emacDb = instance:addStream("emacDb", core.Line, name .. ".emacDb", "emacDb", instance.parameters.emacDb, 0);
    emacDb:setPrecision(math.max(2, instance.source:getPrecision()));
    emacDb:setWidth(instance.parameters.width6);
    emacDb:setStyle(instance.parameters.style6);
	
	ematUa = instance:addStream("ematUa", core.Line, name .. ".ematUa", "ematUa", instance.parameters.ematUa, 0);
    ematUa:setPrecision(math.max(2, instance.source:getPrecision()));
    ematUa:setWidth(instance.parameters.width7);
    ematUa:setStyle(instance.parameters.style7);
	
	ematUb = instance:addStream("ematUb", core.Line, name .. ".ematUb", "ematUb", instance.parameters.ematUb, 0);
    ematUb:setPrecision(math.max(2, instance.source:getPrecision()));
    ematUb:setWidth(instance.parameters.width8);
    ematUb:setStyle(instance.parameters.style8);
		
	ematDa = instance:addStream("ematDa", core.Line, name .. ".ematDa", "ematDa", instance.parameters.ematDa, 0);
    ematDa:setPrecision(math.max(2, instance.source:getPrecision()));
    ematDa:setWidth(instance.parameters.width9);
    ematDa:setStyle(instance.parameters.style9);
	
	ematDb = instance:addStream("ematDb", core.Line, name .. ".ematDb", "ematDb", instance.parameters.ematDb, 0);
    ematDb:setPrecision(math.max(2, instance.source:getPrecision()));
   	ematDb:setWidth(instance.parameters.width10);
    ematDb:setStyle(instance.parameters.style10);
	
    for i = 0, _remaInstances * _remaInstancesSize - 1 do
        workRema[i] = instance:addInternalStream(0, 0);
    end
    for i = 0, _priceInstances * _priceInstancesSize - 1 do
        _priceWorkHa[i] = instance:addInternalStream(0, 0);
    end

    if TimeFrame ~= source:barSize() then
        Source = core.host:execute("getSyncHistory", source:instrument(), TimeFrame, source:isBid(), 0, 100, 101);
    assert(core.indicators:findIndicator("REVERSE EMA 2 MTF") ~= nil, "REVERSE EMA 2 MTF" .. " indicator must be installed");
        btf = core.indicators:create("REVERSE EMA 2 MTF", Source, TimeFrame, EmaPeriodT, EmaPeriodC, EmaPrice, ColorOn);
    else
        loading = false;
    end
end

local loading = true;

function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end

function Update(period, mode)
    if btf ~= nil then
        if loading then
            return;
        end
        btf:update(mode);
        local btf_period = core.findDate(Source, source:date(period), false);
        emat[period] = btf.emat[btf_period];
        emac[period] = btf.emac[btf_period];
        emacUa[period] = btf.emacUa[btf_period];
        emacUb[period] = btf.emacUb[btf_period];
        emacDa[period] = btf.emacDa[btf_period];
        emacDb[period] = btf.emacDb[btf_period];
        ematUa[period] = btf.ematUa[btf_period];
        ematUb[period] = btf.ematUb[btf_period];
        ematDa[period] = btf.ematDa[btf_period];
        ematDb[period] = btf.ematDb[btf_period];
        return;
    end
    if (trendt[period] == -1) then
        CleanPoint(period, ematDa, ematDb);
    end
    if (trendc[period] == -1) then
        CleanPoint(period, emacDa, emacDb);
    end
    if (trendt[period] == 1) then
        CleanPoint(period, ematUa, ematUb);
    end
    if (trendc[period] == 1) then
        CleanPoint(period, emacUa, emacUb);
    end
    local i = period;
    local price = getPrice(EmaPrice, i);
    emat[i] = iRema(price, EmaPeriodT, period, 0);
    emac[i] = iRema(price, EmaPeriodC, period, 1);
    emacUa[i] = EMPTY_VALUE;
    emacUb[i] = EMPTY_VALUE;
    emacDa[i] = EMPTY_VALUE;
    emacDb[i] = EMPTY_VALUE;
    ematUa[i] = EMPTY_VALUE;
    ematUb[i] = EMPTY_VALUE;
    ematDa[i] = EMPTY_VALUE;
    ematDb[i] = EMPTY_VALUE;
    if ColorOn == "col_onSlope" then 
        trendt[i] = i >= 1 and ((emat[i] > emat[i - 1]) and 1 or ((emat[i] < emat[i - 1]) and -1 or trendt[i - 1])) or 0;
        trendc[i] = i >= 1 and ((emac[i] > emac[i - 1]) and 1 or ((emac[i] < emac[i - 1]) and -1 or trendc[i - 1])) or 0;
    end
    if ColorOn == "col_onSlope2" then
        trenwt[i] = i >= 1 and ((emat[i] > emat[i - 1]) and 1 or ((emat[i] < emat[i - 1]) and -1 or trenwt[i - 1])) or 0;
        trenwc[i] = i >= 1 and ((emac[i] > emac[i - 1]) and 1 or ((emac[i] < emac[i - 1]) and -1 or trenwc[i - 1])) or 0;
        trendt[i] = (trenwt[i] == trenwc[i]) and trenwt[i] or 0;
        trendc[i] = trendt[i];
    end
    if ColorOn == "col_onZero" then 
        trendt[i] = emat[i] > 0 and 1 or (emat[i] < 0 and -1 or (i >= 1 and trendt[i - 1] or 0));
        trendc[i] = emac[i] > 0 and 1 or (emac[i] < 0 and -1 or (i >= 1 and trendc[i - 1] or 0));
    end
    if ColorOn == "col_onZero2" then 
        trenwt[i] = emat[i] > 0 and 1 or (emat[i] < 0 and -1 or (i >= 1 and trenwt[i - 1] or 0));
        trenwc[i] = emac[i] > 0 and 1 or (emac[i] < 0 and -1 or (i >= 1 and trenwc[i - 1] or 0));
        trendt[i] = (trenwt[i] == trenwc[i]) and trenwt[i] or 0;
        trendc[i] = trendt[i];
    end
    if ColorOn == "col_onCycle" then 
        trendt[i] = emat[i] > emac[i] and 1 or (emat[i] < emac[i] and -1 or (i >= 1 and trendt[i - 1] or 0));
        trendc[i] = trendt[i];
    end
    if (trendt[i] == 1) then
        PlotPoint(i, ematUa, ematUb, emat);
    end
    if (trendc[i] == 1) then
        PlotPoint(i, emacUa, emacUb, emac);
    end
    if (trendt[i] == -1) then
        PlotPoint(i, ematDa, ematDb, emat);
    end
    if (trendc[i] == -1) then
        PlotPoint(i, emacDa, emacDb, emac);
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

function CleanPoint(i, first, second)
    if i <= 3 then
        return;
    end
    if (second[i] ~= EMPTY_VALUE) and (second[i - 1] ~= EMPTY_VALUE) then
        second[i - 1] = EMPTY_VALUE;
    elseif (first[i] ~= EMPTY_VALUE) and (first[i - 1] ~= EMPTY_VALUE) and (first[i - 2] == EMPTY_VALUE) then
        first[i - 1] = EMPTY_VALUE;
    end
end

function iRema(price, period, r, instanceNo)
    instanceNo = instanceNo * _remaInstancesSize;
    local _aa = (2. / (1. + period));
    if r > 0 and period > 1 then
        local _cc = 1. - _aa;
        workRema[instanceNo][r] = _aa * price + _cc * workRema[instanceNo][r - 1];
        for i = 1, 8 do
            workRema[i + instanceNo][r] = math.pow(_cc, math.pow(2, i - 1)) * workRema[i - 1 + instanceNo][r] + workRema[i - 1 + instanceNo][r - 1];
        end
        return workRema[instanceNo][r] - _aa * workRema[8 + instanceNo][r];
    end
    for i = 0, 8 do
        workRema[i + instanceNo][r] = price;
    end
    return 0;
end

function _prHABF(_prtype)
    return _prtype == "pr_habclose" or _prtype == "pr_habopen" or _prtype == "pr_habhigh"
        or _prtype == "pr_hablow" or _prtype == "pr_habmedian" or _prtype == "pr_habtypical"
        or _prtype == "pr_habweighted" or _prtype == "pr_habaverage" or _prtype == "pr_habmedianb"
        or _prtype == "pr_habtbiased" or _prtype == "pr_habtbiased2";
end

function getPrice(tprice, i)
    if tprice == "pr_haclose" or _prHABF(tprice) or tprice == "pr_hatbiased2" or tprice == "pr_hatbiased"
        or tprice == "pr_haaverage" or tprice == "pr_haweighted" or tprice == "pr_hatypical"
        or tprice == "pr_hamedianb" or tprice == "pr_hamedian" or tprice == "pr_halow" or tprice == "pr_hahigh"
        or tprice == "pr_haopen" 
    then
        local r = i;
        local haOpen = (r > 0) and ((_priceWorkHa[2][r - 1] + _priceWorkHa[3][r - 1]) / 2.0) or ((source.open[i] + source.close[i]) / 2);
        local haClose = (source.open[i] + source.high[i] + source.low[i] + source.close[i]) / 4.0;
        if _prHABF(tprice) then
            if source.high[i] ~= source.low[i] then
                haClose = (source.open[i] + source.close[i]) / 2.0 + (((source.close[i] - source.open[i]) / (source.high[i] - source.low[i])) * math.abs((source.close[i] - source.open[i]) / 2.0));
            else
                haClose = (source.open[i] + source.close[i]) / 2.0; 
            end
        end
        local haHigh = math.max(source.high[i], math.max(haOpen, haClose));
        local haLow = math.min(source.low[i], math.min(haOpen, haClose));
        if (haOpen < haClose) then
            _priceWorkHa[0][r] = haLow;
            _priceWorkHa[1][r] = haHigh;
        else
            _priceWorkHa[0][r] = haHigh;
            _priceWorkHa[1][r] = haLow;
        end
        _priceWorkHa[2][r] = haOpen;
        _priceWorkHa[3][r] = haClose;
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
        return source.close[i];
    end
    if tprice == "pr_open" then
        return source.open[i];
    end
    if tprice == "pr_high" then
        return source.high[i];
    end
    if tprice == "pr_low" then
        return source.low[i];
    end
    if tprice == "pr_median" then
        return (source.high[i] + source.low[i]) / 2.0;
    end
    if tprice == "pr_medianb" then
        return (source.open[i] + source.close[i]) / 2.0;
    end
    if tprice == "pr_typical" then
        return (source.high[i] + source.low[i] + source.close[i]) / 3.0;
    end
    if tprice == "pr_weighted" then
        return (source.high[i] + source.low[i] + source.close[i] + source.close[i]) / 4.0;
    end
    if tprice == "pr_average" then 
        return (source.high[i] + source.low[i] + source.close[i] + source.open[i]) / 4.0;
    end
    if tprice == "pr_tbiased" then
        if source.close[i] > source.open[i] then
            return (source.high[i] + source.close[i]) / 2.0;
        else
            return (source.low[i] + source.close[i]) / 2.0;
        end
    end
    if tprice == "pr_tbiased2" then
        if source.close[i] > source.open[i] then
            return source.high[i];
        end
        if source.close[i] < source.open[i] then
            return source.low[i];
        end
        return source.close[i];
    end
    return 0;
end
 