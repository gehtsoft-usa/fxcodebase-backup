-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2236

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Shows breakeven price level for the current instrument");
    indicator:description("The indicator shows the price at which the currently held positions will have zero profit");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator:setTag("IgnoreBidAskChange", "True");

    indicator.parameters:addColor("BC", "Buy Positions Level color", "", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("SC", "Sell positions level color", "", core.COLOR_DOWNCANDLE);
    indicator.parameters:addInteger("STYLE", "Line style", "", core.LINE_DOT);
    indicator.parameters:setFlag("STYLE", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("WIDTH", "Line width", "", 1, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local BC;
local SC;
local style;
local width;

local instrument;
local first;
local source = nil;
local format;

-- Streams block
local BUY = nil;
local SELL = nil;
local timer;

-- Routine
function Prepare(onlyName)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end

    BC = instance.parameters.BC;
    SC = instance.parameters.SC;
    style = instance.parameters.STYLE;
    width = instance.parameters.WIDTH;
    instrument = source:instrument();
    format = "%s:%." .. source:getPrecision() .. "f";

    BUY = instance:addStream("BUY", core.Line, name, "BUY", instance.parameters.BC, 0);
    SELL = instance:addStream("SELL", core.Line, name, "SELL", instance.parameters.SC, 0);
    timer = core.host:execute("setTimer", 1, 1);
end

-- Indicator calculation routine
function Update(period, mode)
    local i, v;
    if period == source:size() - 1 then
        i = BUY:getBookmark(1);
        if i >= 0 and i ~= period then
            v = BUY[i];
            BUY:set(i, nil);
            BUY[period] = v;
            BUY:setBookmark(1, period);
        end
        i = SELL:getBookmark(1);
        if i >= 0 and i ~= period then
            v = SELL[i];
            SELL:set(i, nil);
            SELL[period] = v;
            SELL:setBookmark(1, period);
        end
    end
end

local _sellP = -1;
local _buyP = -1;

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 and source:size() > source:first() then
        local period;
        period = source:size() - 1;

        local table, enum, row;
        local sellA, sellP;
        local buyA, buyB;
        local i;
        table = core.host:findTable("summary");
        if table == nil then
            return ;
        end
        enum = table:enumerator();
        row = enum:next();
        sellA = 0;
        sellP = 0;
        buyA = 0;
        buyP = 0;
        while row ~= nil do
            if row.Instrument == instrument then
                sellA = sellA + row.SellAmountK;
                sellP = sellP + row.SellAvgOpen * sellA;
                buyA = buyA + row.BuyAmountK;
                buyP = buyP + row.BuyAvgOpen * buyA;
            end
            row = enum:next();
        end

        if sellA > 0.00001 then
            sellP = sellP / sellA;
        end
        if buyA > 0.00001 then
            buyP = buyP / buyA;
        end

        if BUY:getBookmark(1) < 0 and _buyP > 0 then
            _buyP = -1;
        end
            
        if SELL:getBookmark(1) < 0 and _sellP > 0 then
            _sellP = -1;
        end

        if math.abs(sellP - _sellP) < 0.000001 and
           math.abs(buyP - _buyP) < 0.000001 then
            return ;
        end

        _sellP = sellP;
        _buyP = buyP;

        i = BUY:getBookmark(1);
        if i >= 0 then
            BUY:set(i, nil);
            BUY:setBookmark(1, -1);
        end

        i = SELL:getBookmark(1);
        if i >= 0 then
            SELL:set(i, nil);
            SELL:setBookmark(1, -1);
        end

        if sellA > 0.00001 then
            SELL[period] = sellP;
            SELL:setBookmark(1, period);
            core.host:execute("drawLine", 1, source:date(source:first()), sellP, source:date(source:size() - 1) + 5, sellP, SC, style, width, string.format(format, "breakeven sell", sellP));
        else
            core.host:execute("removeLine", 1);
        end

        if buyA > 0.00001 then
            BUY[period] = buyP;
            BUY:setBookmark(1, period);
            core.host:execute("drawLine", 2, source:date(source:first()), buyP, source:date(source:size() - 1) + 5, buyP, BC, style, width, string.format(format, "breakeven buy", buyP));
        else
            core.host:execute("removeLine", 2);
        end

        return core.ASYNC_REDRAW;
    end
end

function ReleaseInstance()
    core.host:execute("killTimer", timer);
end
