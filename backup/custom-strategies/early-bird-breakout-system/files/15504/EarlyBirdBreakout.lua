-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=6862

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    strategy:name("Early Bird Breakout System");
    strategy:description("");
    strategy:setTag("Version", "2");

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);

    strategy.parameters:addInteger("MM", "Number of hours to find HH and LL", "", 5, 1, 24);
    strategy.parameters:addInteger("EntryHour", "Hour of entry (EST 24-hour)", "", 5, 0, 23);
    strategy.parameters:addInteger("ExitHour", "Hour of exit (EST, 24-hour)", "", 13, 0, 23);
    strategy.parameters:addInteger("ProfitTarget", "Profit Target (in pips)", "", 90, 0, 10000);

    strategy.parameters:addString("AccountID", "AccountID to trade on", "", "");
    strategy.parameters:setFlag("AccountID", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000);
end

local MM, EntryHour, ExitHour;
local BidH1, AskH1;
local ProfitTarget;
local AccountID;
local Amount;
local OfferID;
local LotSize;
local CustomID;
local bidLoaded, askLoaded;
local S;
local CanClose;

function Prepare(onlyName)

    instance:name(profile:id() .. "(" .. instance.bid:instrument() .. ")");
    if onlyName then
        return ;
    end

    CustomID = "EBBS_" .. instance.bid:instrument();

    MM = instance.parameters.MM;
    EntryHour = instance.parameters.EntryHour;
    ExitHour = instance.parameters.ExitHour;
    ProfitTarget = instance.parameters.ProfitTarget;

    AccountID = instance.parameters.AccountID;
    Amount = instance.parameters.Amount;
    LotSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), AccountID);
    OfferID = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;

    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), AccountID);


    bidLoaded = false;
    askLoaded = false;

    BidH1 = core.host:execute("getHistory", 1, instance.bid:instrument(), "H1", 0, 0, true);
    AskH1 = core.host:execute("getHistory", 2, instance.bid:instrument(), "H1", 0, 0, false);
    S = CheckTime();
end

function Update()
    if not instance.parameters.AllowTrade then
        return;
    end
    local S1;
    S1 = CheckTime();
    if bidLoaded and askLoaded and BidH1.close:size() > MM and AskH1.close:size() > MM then
        if not S and S1 then
            -- entry time
            Entry();
        end
        if S and not S1 then
            -- exit time
            Exit();
        end
    end
    S = S1;
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 then
        bidLoaded = true;
        return ;
    end

    if cookie == 2 then
        askLoaded = true;
        return ;
    end

    if cookie == 100 and not success then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Creating entry order failed:" .. message, instance.bid:date(instance.bid:size() - 1));
    end

    if cookie == 101 and not success then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Closing trade failed:" .. message, instance.bid:date(instance.bid:size() - 1));
    end

    if cookie == 102 and not success then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Cancelling order failed:" .. message, instance.bid:date(instance.bid:size() - 1));
    end
end

function Entry()
    terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Entry", instance.bid:date(instance.bid:size() - 1));

    local maxAsk, minBid;

    maxAsk = mathex.max(AskH1.high, AskH1:size() - MM + 1, AskH1:size() - 1);
    minBid = mathex.min(BidH1.low, BidH1:size() - MM + 1, BidH1:size() - 1);

    CreateEntry(maxAsk + AskH1:pipSize() * 5, "B");
    CreateEntry(minBid - BidH1:pipSize() * 5, "S");
end

function CreateEntry(rate, side)
    local valuemap = core.valuemap();

    valuemap.Command = "CreateOrder";
    valuemap.OrderType = "SE";
    valuemap.OfferID = OfferID;
    valuemap.AcctID = AccountID;
    valuemap.Quantity = Amount * LotSize;
    valuemap.Rate = rate;
    valuemap.BuySell = side;
    valuemap.CustomID = CustomID;

    if side == "B" then
        valuemap.PegPriceOffsetPipsLimit = ProfitTarget;
    else
        valuemap.PegPriceOffsetPipsLimit = -ProfitTarget;
    end
    valuemap.PegTypeLimit = "M";

    if not CanClose then
        valuemap.EntryLimitStop = 'Y'
    end

    success, message = terminal:execute(100, valuemap);
    if not success then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Creating entry order failed:" .. message, instance.bid:date(instance.bid:size() - 1));
    end
end

function Exit()
    terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Exit", instance.bid:date(instance.bid:size() - 1));
    -- close all positions
    local arr1 = {};
    local arr2 = {};
    local arr3 = {};
    local cnt = 0;

    local enum, row;
    local found = false;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while row ~= nil do
        if row.AccountID == AccountID and
           row.OfferID == OfferID and
           row.QTXT == CustomID then
           cnt = cnt + 1;
           arr1[cnt] = row.TradeID;
           arr2[cnt] = row.Lot;
           arr3[cnt] = row.BS;
        end
        row = enum:next();
    end

    if cnt > 0 then
        for i = 1, cnt, 1 do
            CloseTrade(arr1[i], arr2[i], arr3[i]);
        end
    end

    cnt = 0;
    enum = core.host:findTable("orders"):enumerator();
    row = enum:next();
    while row ~= nil do
        if row.AccountID == AccountID and
           row.Type == "SE" and
           row.OfferID == OfferID and
           row.QTXT == CustomID then
           cnt = cnt + 1;
           arr1[cnt] = row.OrderID;
        end
        row = enum:next();
    end

    if cnt > 0 then
        for i = 1, cnt, 1 do
            CancelOrder(arr1[i]);
        end
    end
end

function CloseTrade(TradeID, Amount, Side)
    local valuemap = core.valuemap();

    if Side == "B" then
        Side = "S";
    else
        Side = "B";
    end

    valuemap.Command = "CreateOrder";

    if not CanClose then
        valuemap.OrderType = 'OM'
    else
        valuemap.OrderType = "CM";
    end                         

    valuemap.OfferID = OfferID;
    valuemap.AcctID = AccountID;
    valuemap.Quantity = Amount
    valuemap.BuySell = Side;
    valuemap.TradeID = TradeID;

    success, message = terminal:execute(101, valuemap);
    if not success then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Closing trade failed:" .. message, instance.bid:date(instance.bid:size() - 1));
    end
end

function CancelOrder(OrderID)
    local valuemap = core.valuemap();
    valuemap.Command = "DeleteOrder";
    valuemap.OfferID = OfferID;
    valuemap.AcctID = AccountID;
    valuemap.OrderID = OrderID;

    success, message = terminal:execute(102, valuemap);
    if not success then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Cancelling order failed:" .. message, instance.bid:date(instance.bid:size() - 1));
    end

end

function CheckTime()
    local st = core.host:execute("getServerTime");
    local h = math.floor((st - math.floor(st)) * 24);
    if h < EntryHour then
        return false;
    elseif h < ExitHour then
        return true;
    else
        return false;
    end
end

