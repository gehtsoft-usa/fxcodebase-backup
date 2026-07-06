-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68393

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Price Action Doji Harami")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)
    indicator.parameters:addGroup("Calculation")

    indicator.parameters:addInteger("pctDw", "Doji, Min % of Range of Candle for Wicks", "", 60, 0, 90);
    indicator.parameters:addInteger("pipMin", "Doji, Previous Candle Min Pip Body Size", "", 0, 0)
    indicator.parameters:addBoolean("sname", "Show Price Action Bar Names", "", true)
    indicator.parameters:addBoolean("cbar", "Highlight Harami & Doji Bars", "", false)
    indicator.parameters:addBoolean("sHm", "Show Only Harami Style Doji's", "", false)
    indicator.parameters:addInteger("bars", "Doji, Number of Lookback Bars", "", 3, 1, 3);

    indicator.parameters:addGroup("Style")
    indicator.parameters:addInteger("Size1", "Arrow Size", "", 15)
    indicator.parameters:addInteger("Size2", "Font Size", "", 15)
    indicator.parameters:addColor("clrUP", "Bullish Harami Color", "", core.COLOR_UPCANDLE)
    indicator.parameters:addColor("clrDN", "Bearish Harami Color", "", core.COLOR_DOWNCANDLE)
    indicator.parameters:addColor("clrDojiUP", "Bullish Doji Color", "", core.COLOR_UPCANDLE)
    indicator.parameters:addColor("clrDojiDN", "Bearish Doji Color", "", core.COLOR_DOWNCANDLE)
    indicator.parameters:addBoolean("ShowPrice", "Show Labels", "", false)
end

local source
local Bearish_Harami, Bullish_Harami, Bearish_Harami1, Bullish_Harami1, Bearish_Doji, Bearish_Doji1, Bullish_Doji, Bullish_Doji1
local Size1, Size2
local pctDw, bars, pipMin, sname, sHm;

function Prepare(nameOnly)
    source = instance.source
    Size1 = instance.parameters.Size1
    Size2 = instance.parameters.Size2
    pctDw = instance.parameters.pctDw;
    bars = instance.parameters.bars;
    pipMin = instance.parameters.pipMin;
    sname = instance.parameters.sname;
    sHm = instance.parameters.sHm;
    local name = profile:id() .. "(" .. source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    Bullish_Harami = instance:createTextOutput("Bullish_Harami", "Bullish Harami", "Wingdings", Size1, core.H_Center, core.V_Top, instance.parameters.clrUP, 0)
    Bearish_Harami = instance:createTextOutput("Bearish_Harami", "Bearish Harami", "Wingdings", Size1, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0)
    Bullish_Harami1 = instance:createTextOutput("", "Bullish_HaramiL", "Arial", Size2, core.H_Right, core.V_Bottom, instance.parameters.clrUP, 0)
    Bearish_Harami1 = instance:createTextOutput("", "Bearish_HaramiL", "Arial", Size2, core.H_Right, core.V_Top, instance.parameters.clrDN, 0)
    Bullish_Doji = instance:createTextOutput("Bullish_Doji", "Bullish Doji", "Wingdings", Size1, core.H_Center, core.V_Top, instance.parameters.clrDojiUP, 0)
    Bearish_Doji = instance:createTextOutput("Bearish_Doji", "Bearish Doji", "Wingdings", Size1, core.H_Center, core.V_Bottom, instance.parameters.clrDojiDN, 0)
    Bullish_Doji1 = instance:createTextOutput("", "Bullish_DojiL", "Arial", Size2, core.H_Right, core.V_Bottom, instance.parameters.clrDojiUP, 0)
    Bearish_Doji1 = instance:createTextOutput("", "Bearish_DojiL", "Arial", Size2, core.H_Right, core.V_Top, instance.parameters.clrDojiDN, 0)
end

function Update(period, mode)
    if period < 3 then
        return;
    end
    local range = source.high[period] - source.low[period];
    -- Calculate Doji/Harami Candles
    local pctCDw = (pctDw / 2) * 0.01;
    local pctCDb = (100 - pctDw) * 0.01;

    -- Lookback Candles for bulls or bears
    local lbBull = false;
    local lbBear = false;
    if bars == 1 then
        lbBull = source.open[period - 1] > source.close[period - 1]
        lbBear = source.open[period - 1] < source.close[period - 1]
    elseif bars == 2 then
        lbBull = source.open[period - 1] > source.close[period - 1] and source.open[period - 2] > source.close[period - 2]
        lbBear = source.open[period - 1] < source.close[period - 1] and source.open[period - 2] < source.close[period - 2]
    elseif bars == 3 then
        lbBull = source.open[period - 1] > source.close[period - 1] and source.open[period - 2] > source.close[period - 2] 
            and source.open[period - 3] > source.close[period - 3]
        lbBear = source.open[period - 1] < source.close[period - 1] and source.open[period - 2] < source.close[period - 2] 
            and source.open[period - 3] < source.close[period - 3]
    end

    -- Lookback Candle Size only if mininum size is > 0
    local lbSize = false;
    if pipMin == 0 then
        lbSize = true;
    elseif bars == 1 then
        lbSize = math.abs(source.open[period - 1] - source.close[period - 1]) > pipMin * source:pipSize();
    elseif bars == 2 then
        lbSize = math.abs(source.open[period - 1] - source.close[period - 1]) > pipMin * source:pipSize()
            and math.abs(source.open[period - 2] - source.close[period - 2]) > pipMin * source:pipSize();
    elseif bars == 3 then
        lbSize = math.abs(source.open[period - 1] - source.close[period - 1]) > pipMin * source:pipSize() 
            and math.abs(source.open[period - 2] - source.close[period - 2]) > pipMin * source:pipSize()
            and math.abs(source.open[period - 3] - source.close[period - 3]) > pipMin * source:pipSize()
    end

    local dojiBu = (source.open[period - 1] >= math.max(source.close[period], source.open[period]) 
        and source.close[period - 1] <= math.min(source.close[period], source.open[period])) 
        and lbSize 
        and (math.abs(source.close[period] - source.open[period]) < range * pctCDb 
        and (source.high[period] - math.max(source.close[period], source.open[period])) > (pctCDw * range) 
        and (math.min(source.close[period], source.open[period]) - source.low[period]) > (pctCDw * range))

    local dojiBe = (source.close[period - 1] >= math.max(source.close[period], source.open[period]) 
        and source.open[period - 1] <= math.min(source.close[period], source.open[period])) 
        and lbSize 
        and (math.abs(source.close[period] - source.open[period]) < range * pctCDb 
        and (source.high[period] - math.max(source.close[period], source.open[period])) > (pctCDw * range) 
        and (math.min(source.close[period], source.open[period]) - source.low[period]) > (pctCDw * range))

    local haramiBull = (source.open[period] <= source.close[period] 
        or (math.max(source.close[period], source.open[period]) - math.min(source.close[period], source.open[period])) < source:pipSize() * 0.5)
        and lbBull and dojiBu
    local haramiBear = (source.open[period] >= source.close[period] 
        or (math.max(source.close[period], source.open[period]) - math.min(source.close[period], source.open[period])) < source:pipSize() * 0.5) 
        and lbBear and dojiBe

    local dojiBull = not sHm and not haramiBull and not haramiBear and lbBull and dojiBu
    local dojiBear = not sHm and not haramiBull and not haramiBear and lbBear and dojiBe

    if haramiBear then
        if cbar then
            Bearish_Harami:set(period, math.max(source.open[period], source.close[period]), "\226", "Bearish\nHarami");
        end
        if sname then
            Bearish_Harami1:set(period, source.high[period], "Bearish\nHarami");
        end
    end
    if haramiBull then
        if cbar then
            Bullish_Harami:set(period, math.max(source.open[period], source.close[period]), "\225", "Bullish\nHarami");
        end
        if sname then
            Bullish_Harami1:set(period, source.low[period], "Bullish\nHarami");
        end
    end
    if dojiBear then
        if cbar then
            Bearish_Doji:set(period, math.max(source.open[period], source.close[period]), "\226", "Bearish\nDoji");
        end
        if sname then
            Bearish_Doji1:set(period, source.high[period], "Bearish\nDoji");
        end
    end
    if dojiBull then
        if cbar then
            Bullish_Doji:set(period, math.max(source.open[period], source.close[period]), "\225", "Bullish\nDoji");
        end
        if sname then
            Bullish_Doji1:set(period, source.low[period], "Bullish\nDoji");
        end
    end
end
