-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=3154

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

function Init()
    indicator:name("Show ELS Orders");
    indicator:description("The indicator shows coverage of the existing trades on chosen account and instrument by entry orders");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);


    indicator.parameters:addGroup("Parameters");
    indicator.parameters:addString("ACCT", "Choose Account", "", "");
    indicator.parameters:setFlag("ACCT", core.FLAG_ACCOUNT);
    indicator.parameters:addInteger("TO", "Refresh Time (in seconds)", "", 2, 1, 60);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("FS", "Font Size (in points)", "", 6, 6, 32);
end

local Account;
local Instrument;
local Font;
local Font1;
local Color = -1;
local Format;
local point;

function Prepare(onlyName)

     local name = profile:id() .. "(" ..  instance.bid:name()  .. ")";
    instance:name(name); 


     if   (nameOnly) then
        return;
    end
	
	
    Instrument = instance.source:instrument();
    Account = instance.parameters.ACCT;

    local _account;
    assert(not(core.host:execute("getTradingProperty", "canCreateMarketClose", Instrument, Account)), "The indicator can be used on FIFO accounts only");

    if not(core.host:execute("isTableFilled", "accounts")) then
        _account = "id:#" .. Account;
    else
        local row = core.host:findTable("accounts"):find("AccountID", Account);
        if row ~= nil then
            _account = "acct:#" .. row.AccountName;
        else
            _account = "id:#" .. Account;
        end
    end
 
    Format = "%." .. instance.source:getPrecision() .. "f";
    point = instance.source:pipSize();
    Font = core.host:execute("createFont", "Arial", instance.parameters.FS, false, false);
    Font1 = core.host:execute("createFont", "Wingdings", instance.parameters.FS, false, false);
    core.host:execute("setTimer", 1, instance.parameters.TO);
end

function Update(period, mode)
    return ;
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 then
        UpdateImage();
        return core.ASYNC_REDRAW;
    end
end

local Market;

function UpdateImage()
    local orders = {};
    local dir = nil;
    local trades = {};
    local t, idx, i;
    local enum, row;

    core.host:execute("removeAll");

    if not(core.host:execute("isTableFilled", "orders")) or
       not(core.host:execute("isTableFilled", "trades")) then
        core.host:execute("setStatus", "Tables aren't ready");
        return ;
    end

    -- trade info
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    idx = 1;
    while row ~= nil do
        if row.AccountID == Account and
           row.Instrument == Instrument then
            if dir == nil then
                dir = row.BS;
            end
            t = {};
            t.TradeID = row.TradeID;
            t.Amount = row.Lot;
            t.Time = row.Time;

            t.Stops = {};
            t.Limits = {};
            t.StopTotal = 0;
            t.LimitTotal = 0;

            trades[idx] = t;
            idx = idx + 1;
        end
        row = enum:next();
    end

    if idx == 1 then
        -- no trades
        core.host:execute("setStatus", "No trades on chosen account/instrument");
        return ;
    end

    -- orders info
    table.sort(trades,  function (first, second) return first.Time < second.Time; end);

    enum = core.host:findTable("orders"):enumerator();
    row = enum:next();
    idx = 1;
    while row ~= nil do
        if row.AccountID == Account and
           row.Instrument == Instrument and
           (row.Type == "SE" or row.Type == "LE") and
           row.BS ~= dir and
           (row.NetQuantity or row.TypeSL == 1) then
            t = {};
            t.Type = row.Type;
            t.OrderID = row.OrderID;
            t.Rate = row.Rate;
            t.Amount = row.Lot;
            t.NetOrder = row.NetQuantity;
            if row.NetQuantity then
                t.CoverAmount = 99999999999999999999;
            else
                t.CoverAmount = t.Amount;
            end
            orders[idx] = t;
            idx = idx + 1;
        end
        row = enum:next();
    end

    if idx == 1 then
        -- no trades
        core.host:execute("setStatus", "No entry orders opposite to the trade on chosen account/instrument");
        return ;
    end

    row = core.host:findTable("offers"):find("Instrument", Instrument);
    assert(row ~= nil, "You must be still subscribed for the instrument!!!");

    if dir == "B" then
        -- buy positions are closed by sell operations/by bid price
        Market = row.Bid;
    else
        -- sell positions are closed by sell operations/by bid price
        Market = row.Ask;
    end

    table.sort(orders,  function (first, second) return math.abs(first.Rate - Market) < math.abs(second.Rate - Market); end);

    core.host:execute("setStatus", "");

    local j, c;
    local trade_limit = 1;
    local trade_stop = 1;

    -- map stops and limits to trades
    for i = 1, #orders, 1 do
        if orders[i].Type == "SE" then
            for j = trade_stop, #trades, 1 do
                c = math.min(orders[i].CoverAmount, trades[j].Amount - trades[j].StopTotal);
                if c >= 0.0001 then
                    trades[j].StopTotal = trades[j].StopTotal + c;
                    trades[j].Stops[#trades[j].Stops + 1] = orders[i];

                    orders[i].CoverAmount = orders[i].CoverAmount - c;
                    if math.abs(trades[j].StopTotal - trades[j].Amount) < 0.0001 then
                        trade_stop = j + 1;
                    end
                    if orders[i].CoverAmount <= 0.0001 then
                        break;
                    end
                end
            end
        elseif orders[i].Type == "LE" then
            for j = trade_limit, #trades, 1 do
                c = math.min(orders[i].CoverAmount, trades[j].Amount - trades[j].LimitTotal);
                if c >= 0.0001 then
                    trades[j].LimitTotal = trades[j].LimitTotal + c;
                    trades[j].Limits[#trades[j].Limits + 1] = orders[i];

                    orders[i].CoverAmount = orders[i].CoverAmount - c;

                    if math.abs(trades[j].LimitTotal - trades[j].Amount) < 0.0001 then
                        trade_limit = j + 1;
                    end

                    if orders[i].CoverAmount <= 0.00001 then
                        break;
                    end
                end
            end
        end
    end

    table.sort(orders,  function (first, second) return first.Rate > second.Rate; end);
    -- display
    local id = 1000;
    local line = 0;
    local msg;
    local above = true;
    local y = 12;
    local yStep = instance.parameters.FS * 1.2;
    for i = 1, #orders, 1 do
        if orders[i].Rate < Market and above then
            core.host:execute("drawLabel1", id, 0, core.CR_LEFT, y, core.CR_TOP, core.H_Right, core.V_Bottom, Font, Color, "MKT @" .. string.format(Format, Market));
            id = id + 1;
            y = y + yStep;
            above = false;
        end
        orders[i].y = y;
        if orders[i].NetOrder then
            core.host:execute("drawLabel1", id, 0, core.CR_LEFT, y, core.CR_TOP, core.H_Right, core.V_Bottom, Font, Color, string.format("%s(%s) NET @" .. Format .. "/%.1f pts", orders[i].Type, orders[i].OrderID, orders[i].Rate, (orders[i].Rate - Market) / point));
        else
            core.host:execute("drawLabel1", id, 0, core.CR_LEFT, y, core.CR_TOP, core.H_Right, core.V_Bottom, Font, Color, string.format("%s(%s) %i @" .. Format .. "/%.1f pts", orders[i].Type, orders[i].OrderID, orders[i].Amount, orders[i].Rate, (orders[i].Rate - Market) / point));
        end
        id = id + 1;
        y = y + yStep;
    end

    local trade_y = y;
    local trade_step = instance.parameters.FS * 16;
    local trade_x = instance.parameters.FS * 24;

    for i = 1, #trades, 1 do
        core.host:execute("drawLabel1", id, trade_x, core.CR_LEFT, trade_y, core.CR_TOP, core.H_Right, core.V_Bottom, Font, Color, string.format("(%s) %i", trades[i].TradeID, trades[i].Amount));
        trades[i].x = trade_x;
        id = id + 1;
        for j = 1, #(trades[i].Stops), 1 do
            core.host:execute("drawLabel1", id, trade_x + trade_step / 3, core.CR_LEFT, trades[i].Stops[j].y, core.CR_TOP, core.H_Right, core.V_Bottom, Font1, Color, "\252");
            id = id + 1;
        end
        for j = 1, #(trades[i].Limits), 1 do
            core.host:execute("drawLabel1", id, trade_x + trade_step / 3, core.CR_LEFT, trades[i].Limits[j].y, core.CR_TOP, core.H_Right, core.V_Bottom, Font1, Color, "\252");
            id = id + 1;
        end
        trade_x = trade_x + trade_step;
    end
end


function ReleaseInstance()
    core.host:execute("deleteFont", Font);
    core.host:execute("deleteFont", Font1);
end

