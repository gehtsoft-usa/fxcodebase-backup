-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=307
-- Id: 176

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 14 "Behavioral techniques" (page 358-361)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Elliot Wave Oscillator (Customizable)");
    indicator:description("Measures the rate of price change in one wave against the rate of change in another wave.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("FastN", "Fast Moving Average", "", 5, 2, 1000);
    indicator.parameters:addInteger("SlowN", " Slow Moving Average", "", 35, 2, 1000);

    indicator.parameters:addString("Source", "The price source", "", "M3");
    indicator.parameters:addStringAlternative("Source", "Median (H+L+C)/3", "", "M3");
    indicator.parameters:addStringAlternative("Source", "Median (H+L)/2", "", "M2");
    indicator.parameters:addStringAlternative("Source", "Close", "", "C");

    indicator.parameters:addString("Method", "The smoothing method", "The methods marked by the star (*) requires to have approriate indicators installed", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("Method", "Wilders*", "", "WMA");

    indicator.parameters:addString("HideLine", "Hide the envelop curve", "This options is useful for reusing this indicator in other indicators", "Yes");
    indicator.parameters:addStringAlternative("HideLine", "Yes", "", "Yes");
    indicator.parameters:addStringAlternative("HideLine", "No", "", "No");

    indicator.parameters:addColor("clrUpGrow", "Up Growing Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrUpFall", "Up Falling Color", "", core.rgb(0, 127, 0));
    indicator.parameters:addColor("clrDnGrow", "Down Growing Color", "", core.rgb(127, 0, 0));
    indicator.parameters:addColor("clrDnFall", "Down Falling Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrCurve", "Envelope Color", "", core.rgb(127, 127, 127));
end

-- Indicator instance initialization routine
local first;
local first1;
local source = nil;

-- Streams block
local SRC = nil;
local FMA = nil;
local SMA = nil;
local EWO = nil;
local UPGROW = nil;
local UPFALL = nil;
local DNGROW = nil;
local DNFALL = nil;
local DUMMY = nil;
local srcmode;
local prior;

-- Routine
function Prepare(nameOnly)
    assert(instance.parameters.FastN < instance.parameters.SlowN, "Fast MA must be faster than Slow MA");
    srcmode = instance.parameters.Source;
    source = instance.source;
    first1 = source:first();

    local name = profile:id() .. "(" .. source:name() .. "," .. instance.parameters.FastN .. "," ..  instance.parameters.SlowN .. "," ..  instance.parameters.Method  .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    SRC = instance:addInternalStream(source:first(), 0);

	assert(core.indicators:findIndicator(instance.parameters.Method) ~= nil, "Please, download and install ".. instance.parameters.Method.. ".LUA indicator");   
	
    FMA = core.indicators:create(instance.parameters.Method, SRC, instance.parameters.FastN);
    SMA = core.indicators:create(instance.parameters.Method, SRC, instance.parameters.SlowN);

    first = SMA.DATA:first();

    if instance.parameters.HideLine == "Yes" then
        EWO = instance:addInternalStream(first, 0);
    else
        EWO = instance:addStream("EWO", core.Dot, name .. ".EWO", "EWO", instance.parameters.clrCurve, first);
    EWO:setPrecision(math.max(2, instance.source:getPrecision()));
    end
    UPGROW = instance:addStream("UG", core.Bar, name .. ".UG", "UG", instance.parameters.clrUpGrow, first + 1);
    UPGROW:setPrecision(math.max(2, instance.source:getPrecision()));
    UPFALL = instance:addStream("UF", core.Bar, name .. ".UF", "UF", instance.parameters.clrUpFall, first + 1);
    UPFALL:setPrecision(math.max(2, instance.source:getPrecision()));
    DNGROW = instance:addStream("DG", core.Bar, name .. ".DG", "DG", instance.parameters.clrDnGrow, first + 1);
    DNGROW:setPrecision(math.max(2, instance.source:getPrecision()));
    DNFALL = instance:addStream("DF", core.Bar, name .. ".DF", "DF", instance.parameters.clrDnFall, first + 1);
    DNFALL:setPrecision(math.max(2, instance.source:getPrecision()));
    UPGROW:addLevel(0);
end

-- Indicator calculation routine
function Update(period, mode)
    if period >= first1 then
        if srcmode == "M3" then
            SRC[period] = (source.high[period] + source.low[period] + source.close[period]) / 3;
        elseif srcmode == "M2" then
            SRC[period] = (source.high[period] + source.low[period]) / 2;
        else
            SRC[period] = source.close[period];
        end
    end

    local diff, pdiff;
    SMA:update(mode);
    FMA:update(mode);

    if period >= first then
        diff = FMA.DATA[period] - SMA.DATA[period];
        EWO[period] = diff;
    end

    if period >= first + 1 then
        diff = EWO[period];
        pdiff = EWO[period - 1];
        if diff > 0 then
            if diff > pdiff then
                UPGROW[period] = diff;
                prior = 1;
            elseif diff < pdiff then
                UPFALL[period] = diff;
                prior = -1;
            else
                if (prior == 1) then
                    UPGROW[period] = diff;
                else
                    UPFALL[period] = diff;
                end
            end
        else
            if diff > pdiff then
                DNGROW[period] = diff;
                prior = 1;
            elseif diff < pdiff then
                DNFALL[period] = diff;
                prior = -1;
            else
                if (prior == 1) then
                    DNGROW[period] = diff;
                else
                    DNFALL[period] = diff;
                end
            end
        end
    end
end


