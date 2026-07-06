-- Id: 6863
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=20428

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
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


-- Idea (c) ThemBonez
-- developed by fxcodebase team.
-- CADX = Current ADX / Average ADX (EURUSD,GBPUSD,AUDUSD,USDJPY,USDCAD)
-- Anything over a 1 is a stronger trend than the average...anything below 1 is
-- a weaker trending pair. Also, looking at the currency pair of the strongest to
-- the weakest reveals very strong trends. i.e if the GBPUSD comparitive Relative
-- strength is a 1.5 and the USDJPY is a .5.....looking at the GBPJPY reveals a
-- very strong trend.

function Init()
    indicator:name("Comparative ADX");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "", 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("C", "Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("W", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("S", "Style", "", 1, 1, core.LINE_SOLID);
    indicator.parameters:setFlag("S", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addGroup("Level");
    indicator.parameters:addColor("LC", "Color", "", core.COLOR_CUSTOMLEVEL);
    indicator.parameters:addInteger("LW", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("LS", "Style", "", 1, 1, core.LINE_DOT);
    indicator.parameters:setFlag("LS", core.FLAG_LEVEL_STYLE);
end

local adx;              -- source ADX
local cadx = 0;         -- number of comparative adx
local radx = {};        -- list of comparative adx
                        -- each element is a table
                        --  .data   - the data
                        --  .loaded - the flag indicating that the data is loaded
                        --  .adx    - the indicator applied
local first;            -- the first bar we can calculate the data for
local source;           -- the source
local output;           -- the output stream

function Prepare(onlyName)
    local name = profile:id() .. "(" .. instance.source:name() .. "," .. instance.parameters.N .. ")";
    instance:name(name);
    checkCurrency("EUR/USD");
    checkCurrency("GBP/USD");
    checkCurrency("AUD/USD");
    checkCurrency("USD/JPY");
    checkCurrency("USD/CAD");

    if onlyName then
        return ;
    end



    adx = core.indicators:create("ADX", instance.source, instance.parameters.N);
    first = adx.DATA:first();
    addADX("EUR/USD", instance.parameters.N, first - instance.source:first(), instance.source:barSize(), instance.source:isBid());
    addADX("GBP/USD", instance.parameters.N, first - instance.source:first(), instance.source:barSize(), instance.source:isBid());
    addADX("AUD/USD", instance.parameters.N, first - instance.source:first(), instance.source:barSize(), instance.source:isBid());
    addADX("USD/JPY", instance.parameters.N, first - instance.source:first(), instance.source:barSize(), instance.source:isBid());
    addADX("USD/CAD", instance.parameters.N, first - instance.source:first(), instance.source:barSize(), instance.source:isBid());

    source = instance.source;

    output = instance:addStream("cadx", core.Line, name, "cadx", instance.parameters.C, first);
    output:setWidth(instance.parameters.W);
    output:setStyle(instance.parameters.S);
    output:addLevel(1, instance.parameters.LS, instance.parameters.LW, instance.parameters.LC);
	
	output:setPrecision(math.max(2, instance.source:getPrecision()));
end

function checkCurrency(instrument)
    local rc = false;
    if instrument  == instance.source:instrument() then
        rc = true;
    else
        local enum, row;
        enum = core.host:findTable("offers"):enumerator();
        row = enum:next();
        while row ~= nil and not rc do
            if row.Instrument == instrument then
                rc = true;
            else
                row = enum:next();
            end
        end
    end
    assert(rc, "The subscription for " .. instrument .. " is required for the indicator");
end

function addADX(instrument, n, bars, frame, bid)
    local t = {};
    if instrument == instance.source:instrument() then
        t.data = nil;
        t.adx = adx;
        t.loaded = true;
    else
        t.data = core.host:execute("getSyncHistory", instrument, frame, bid, bars + n, 101 + cadx, 201 + cadx);
        t.adx = core.indicators:create("ADX", t.data, n);
        t.loaded = false;
    end
    cadx = cadx + 1;
    radx[cadx] = t;
    return ;
end

function Update(period, mode)
    if period < first then
        return ;
    end

    local i;
    for i = 1, cadx, 1 do
        if not radx[i].loaded then
            return ;
        else
            radx[i].adx:update(core.UpdateLast);
        end
    end
    adx:update(core.UpdateLast);
    local cdate = source:date(period);
    local period1;
    local sum = 0;
    local t;
    for i = 1, cadx, 1 do
        t = radx[i];
        if t.data == nil then
            sum = sum + t.adx.DATA[period];
        else
            period1 = core.findDate(t.data, cdate, false);
            if period1 < 0 then
                return ;
            end
            sum = sum + t.adx.DATA[period1];
        end
    end
    sum = sum / cadx;
    output[period] = adx.DATA[period] / sum;
end

function AsyncOperationFinished(cookie)
    if cookie >= 101 and cookie < 200 then
        radx[cookie - 100].loaded = true;
        local i;
        for i = 1, cadx, 1 do
            if not radx[i].loaded then
                return ;
            end
        end
        -- add data loaded
        instance:updateFrom(0);
    elseif cookie >= 201 and cookie < 300 then
        radx[cookie - 200].loaded = false;
    end
end