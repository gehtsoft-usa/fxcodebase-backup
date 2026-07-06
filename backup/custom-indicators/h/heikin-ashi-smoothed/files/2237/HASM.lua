-- Id: 783
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=606

--+------------------------------------------------------------------+
--|                                            http://fxcodebase.com |
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
    indicator:name("Heikin-Ashi Smoothed");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Trend");
    indicator:setTag("replaceSource", "t");

    indicator.parameters:addString("Method1", "The smoothing method for prices", "The methods marked by the star (*) requires to have approriate indicators installed", "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("Method1", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("Method1", "Wilders*", "", "WMA");

    indicator.parameters:addInteger("N1", "Periods to smooth prices", "", 6, 1, 1000);

    indicator.parameters:addString("Method2", "The smoothing method for candles", "The methods marked by the star (*) requires to have approriate indicators installed", "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("Method2", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("Method2", "Wilders*", "", "WMA");

    indicator.parameters:addInteger("N2", "Periods to smooth candles", "", 6, 1, 1000);
end

local smopen = nil;
local smhigh = nil;
local smlow = nil;
local smclose = nil;

local iopen = nil;
local ihigh = nil;
local ilow = nil;
local iclose = nil;

local smiopen = nil;
local smihigh = nil;
local smilow = nil;
local smiclose = nil;

local open = nil;
local high = nil;
local low = nil;
local close = nil;

local first1 = 0;
local first2 = 0;

-- Routine
function Prepare(nameOnly)
    source = instance.source;
   
    -- was missing, so N1 was not set
    local N1 = instance.parameters.N1;
    local name = "Heikin-Ashi Smoothed" .. "(" .. source:name() .. "," .. instance.parameters.Method1 .. "(" .. instance.parameters.N1 .. ")," .. instance.parameters.Method2 .. "(" .. instance.parameters.N2.. "))"
    instance:name(name);
    if nameOnly then
        return;
    end
    assert(core.indicators:findIndicator(instance.parameters.Method1) ~= nil, instance.parameters.Method1 .. " indicator must be installed");
    smopen = core.indicators:create(instance.parameters.Method1, source.open, N1);
    smclose = core.indicators:create(instance.parameters.Method1, source.close, N1);
    smhigh = core.indicators:create(instance.parameters.Method1, source.high, N1);
    smlow = core.indicators:create(instance.parameters.Method1, source.low, N1);

    first1 = smopen.DATA:first() + 1;

    iopen = instance:addInternalStream(first1, 0);
    iclose = instance:addInternalStream(first1, 0);
    ihigh = instance:addInternalStream(first1, 0);
    ilow = instance:addInternalStream(first1, 0);
   
    -- was missing, so N2 was not set
    local N2 = instance.parameters.N2;
   
    assert(core.indicators:findIndicator(instance.parameters.Method2) ~= nil, instance.parameters.Method2 .. " indicator must be installed");
    smiopen = core.indicators:create(instance.parameters.Method2, iopen, N2);
    smiclose = core.indicators:create(instance.parameters.Method2, iclose, N2);
    smihigh = core.indicators:create(instance.parameters.Method2, ihigh, N2);
    smilow = core.indicators:create(instance.parameters.Method2, ilow, N2);

    first2 = smiopen.DATA:first() + 1;
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first2)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first2)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first2)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first2)
    instance:createCandleGroup("HAS", "HAS", open, high, low, close);
end

-- Indicator calculation routine
function Update(period, mode)
    -- smooth source
    smopen:update(mode);
    smhigh:update(mode);
    smlow:update(mode);
    smclose:update(mode);

    if period >= first1 then
        -- calculate candles
        if (period == first1) then
            iopen[period] = (smopen.DATA[period - 1] + smclose.DATA[period - 1]) / 2;
        else
            iopen[period] = (iopen[period - 1] + iclose[period - 1]) / 2;
        end
        iclose[period] = (smopen.DATA[period] + smhigh.DATA[period] + smlow.DATA[period] + smclose.DATA[period]) / 4;
        ihigh[period] = math.max(iopen[period], iclose[period], smhigh.DATA[period]);
        ilow[period] = math.min(iopen[period], iclose[period], smlow.DATA[period]);

        -- smooth candles
        smiopen:update(mode);
        smihigh:update(mode);
        smilow:update(mode);
        smiclose:update(mode);
    end

    if period >= first2 then
        open[period] = smiopen.DATA[period];
        close[period] = smiclose.DATA[period];
        high[period] = math.max(open[period], close[period], smihigh.DATA[period]);
        low[period] = math.min(open[period], close[period], smilow.DATA[period]);
    end
end



