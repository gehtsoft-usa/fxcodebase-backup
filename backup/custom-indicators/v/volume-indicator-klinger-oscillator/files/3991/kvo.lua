-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1967&p=3991#p3991

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Klinger Oscillator");
    indicator:description("Klinger Oscillator is sensitive enough to signal short-term tops and bottoms, yet accurate enough to reflect the long-term flow of money into and out of a security.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volume Indicators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FastN", "Fast Periods", "", 34, 1, 1000);
    indicator.parameters:addInteger("SlowN", "Slow Periods", "", 55, 1, 1000);
    indicator.parameters:addInteger("TrigN", "Trigger Periods", "", 13, 1, 1000);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrKO", "Indicator Line Color", "", core.rgb(123, 104, 238));
    indicator.parameters:addInteger("widthKO", "Indicator Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleKO", "Indicator Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleKO", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("clrT", "Trigger Line Color", "", core.rgb(139, 69, 19));
    indicator.parameters:addInteger("widthT", "Trigger Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleT", "Trigger Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleT", core.FLAG_LINE_STYLE);

end

local DM;
local CM;
local VF;
local TREND;
local first0;
local first1;
local first2;
local first3;
local EMAF, EMAS, EMAT;
local source;

local KO;
local T;

function Prepare(nameOnly)
    local name;

    name = profile:id() .. "(" .. instance.source:name() .. "," .. instance.parameters.FastN  .. "," .. instance.parameters.SlowN  .. "," .. instance.parameters.TrigN .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    source = instance.source;
    assert(source:supportsVolume(), "The source must have volume");
    first0 = source:first();
    first1 = source:first() + 1;

    DM = instance:addInternalStream(first0, 0);
    CM = instance:addInternalStream(first0, 0);
    TREND = instance:addInternalStream(first0, 0);
    VF = instance:addInternalStream(first1, 0);

    EMAF = core.indicators:create("EMA", VF, instance.parameters.FastN);
    EMAS = core.indicators:create("EMA", VF, instance.parameters.SlowN);
    first2 = math.max(EMAF.DATA:first(), EMAS.DATA:first());

    KO = instance:addStream("KO", core.Line, name .. ".KO", "KO", instance.parameters.clrKO, first2);
    KO:setPrecision(2);
    KO:setWidth(instance.parameters.widthKO);
    KO:setStyle(instance.parameters.styleKO);
    KO:addLevel(0);

    EMAT = core.indicators:create("EMA", KO, instance.parameters.TrigN);
    first3 = EMAT.DATA:first();

    T = instance:addStream("T", core.Line, name .. ".T", "T", instance.parameters.clrT, first3);
    T:setPrecision(2);
    T:setWidth(instance.parameters.widthT);
    T:setStyle(instance.parameters.styleT);
end




function Update(period, mode)
    -- calculate vforce
    if period >= first0 then
        TREND[period] = 0;
        CM[period] = 0;
        DM[period] = source.high[period] - source.low[period];
    end

    if period >= first1 then
        -- originally h+l+c, but typical is (h+l+c)/3, so is the same
        -- for our purposes
        local trend = TREND[period - 1];
        if source.typical[period] > source.typical[period - 1] then
            trend = 1;
        elseif source.typical[period] < source.typical[period - 1] then
            trend = -1;
        end
        TREND[period] = trend;
        if TREND[period] == TREND[period - 1] then
            CM[period] = CM[period] + DM[period];
        else
            CM[period] = DM[period - 1] + DM[period];
        end
        if CM[period] == 0 then
            VF[period] = 0;
        else
            VF[period] = source.volume[period] * math.abs(2 * DM[period] / CM[period] - 1) * trend * 100;
        end
    end

    if period >= first2 then
        EMAF:update(mode);
        EMAS:update(mode);

        KO[period] = EMAF.DATA[period] - EMAS.DATA[period];
    end

    if period >= first3 then
        EMAT:update(mode);
        T[period] = EMAT.DATA[period];
    end
end

