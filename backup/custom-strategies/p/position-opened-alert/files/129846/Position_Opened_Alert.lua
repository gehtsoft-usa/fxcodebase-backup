-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=31&t=69145

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

local Modules = {};

function Init()
    strategy:name("Position Opened Alert");
    signaler:Init(strategy.parameters)
end
local TRADES_UPDATE = 1;
local ORDERS_UPDATE = 2;
local TIMER_ID = 3;
local closing_order_types = {};
local trade_opened;

function Prepare(name_only)
    for _, module in pairs(Modules) do module:Prepare(nameOnly); end
    instance:name(profile:id());
    if name_only then return ; end
    core.host:execute("subscribeTradeEvents", TRADES_UPDATE, "trades");
    core.host:execute("subscribeTradeEvents", ORDERS_UPDATE, "orders");
    core.host:execute("setTimer", TIMER_ID, 1);
end
function ExtUpdate(id, source, period) for _, module in pairs(Modules) do if module.BlockTrading ~= nil and module:BlockTrading(id, source, period) then return; end end for _, module in pairs(Modules) do if module.ExtUpdate ~= nil then module:ExtUpdate(id, source, period); end end end
function ReleaseInstance() for _, module in pairs(Modules) do if module.ReleaseInstance ~= nil then module:ReleaseInstance(); end end end
function ParseOrder(order)
    local desc = {};
    desc.TradeID = order.TradeID;
    desc.PrimaryOrderId = order.PrimaryOrderId;
    desc.OfferID = order.OfferID;
    desc.Rate = order.Rate;
    desc.Instrument = order.Instrument;
    desc.BS = order.BS;
    desc.TrlMinMove = order.TrlMinMove;
    desc.ContingencyType = order.ContingencyType;
    desc.Stage = order.Stage;
    desc.Type = order.Type;
    desc.TypeSL = order.TypeSL;
    return desc;
end
function GetTrailingType(trailing)
    if trailing == 1 then
        return "dynamic trailing";
    elseif trailing ~= 0 then
        return string.format("fixed trailing (%d)", trailing);
    end
    return "";
end
local orders;
function InitOrders()
    orders = {};
    local enum = core.host:findTable("orders"):enumerator();
    local order = enum:next();
    while (order ~= nil) do
        if order.Type == "SE" or order.Type == "LE" or order.Type == "S" or order.Type == "L" then
            orders[order.OrderID] = ParseOrder(order);
        end
        order = enum:next();
    end
end

function CheckLimitForChanges(order)
    if orders[order.OrderID].Rate ~= order.Rate then
        if orders[order.OrderID].Rate == 0 then
            orders[order.OrderID] = ParseOrder(order);
            HandleLimitChange(order.OrderID, "", "New Limit at ");
            return;
        end
        orders[order.OrderID] = ParseOrder(order);
        HandleLimitChange(order.OrderID, "", "Limit Changed to ");
        return;
    end
end

function CheckStopForChanges(order)
    if orders[order.OrderID].Rate ~= order.Rate then
        if orders[order.OrderID].Rate == 0 then
            orders[order.OrderID] = ParseOrder(order);
            HandleStopChange(order.OrderID, "", "New Stop at ");
            return;
        end
        orders[order.OrderID] = ParseOrder(order);
        HandleStopChange(order.OrderID, "", "Stop Changed to ");
        return;
    end
end

function FormatRR(rate, type_stop, stop, type_limit, limit)
    if stop ~= 0 and limit ~= 0 then
        if type_stop == 1 and type_limit == 1 then
            return "R:R 1:" .. math.floor(10 * math.abs(rate - limit) / math.abs(rate - stop)) / 10;
        end
        return "R:R 1:" .. math.abs(math.floor(10 * limit / stop) / 10);
    end
    return nil;
end

function FormatLimit(bs, open, limit_type, rate, point_size, digits)
    if limit_type == 1 then
        local limit_pips;
        if bs == "B" then
            limit_pips = (rate - open) / point_size
        else
            limit_pips = (open - rate) / point_size
        end
        return string.format( "%s (%s Pips)", 
            win32.formatNumber(rate, false, digits),
            win32.formatNumber(limit_pips, false, 1)
        );
    elseif limit_type == 0 then
        return "";
    end
    if bs == "S" then
        rate = -rate;
    end
    return string.format("%s Pips", win32.formatNumber(rate, false, 1));
end

function FormatStop(bs, open, stop_type, rate, point_size, digits)
    if stop_type == 1 then
        local stop_pips;
        if bs == "B" then
            stop_pips = (rate - open) / point_size
        else
            stop_pips = (open - rate) / point_size
        end
        return string.format( "%s (%s Pips)", 
            win32.formatNumber(rate, false, digits),
            win32.formatNumber(stop_pips, false, 1)
        );
    elseif stop_type == 0 then
        return "";
    end
    if bs == "S" then
        rate = -rate;
    end
    return string.format("%s Pips", win32.formatNumber(rate, false, 1));
end

function HandleLimitChange(orderID, fix_status, label)
    if fix_status == "C" or fix_status == "S" then
        local trade = core.host:findTable("trades"):find("TradeID", orders[orderID].TradeID);
        if trade ~= nil then
            local side = trade.BS == "B" and "Buy" or "Sell";
            local message = string.format("Trade %s %s %s\r\nLimit was deleted.",
                trade.TradeID, side, trade.Instrument);
            signaler:Signal(message);
            return;
        end

        local primary_order = core.host:findTable("orders"):find("OrderID", orders[orderID].PrimaryOrderId);
        if primary_order ~= nil then
            local side = primary_order.BS == "B" and "Buy" or "Sell";
            local message = string.format("Order %s %s %s\r\nLimit was deleted.",
                primary_order.OrderID, side, primary_order.Instrument);
            signaler:Signal(message);
        end
        return;
    end
    if orders[orderID].ContingencyType == 3 then
        local trade = core.host:findTable("trades"):find("TradeID", orders[orderID].TradeID);
        if trade ~= nil then
            HandleTradeLimitChange(trade, orderID, label);
        else
            local primary_order = core.host:findTable("orders"):find("OrderID", orders[orderID].PrimaryOrderId);
            if primary_order ~= nil then
                HandleOrderLimitChange(primary_order, orderID, label);
            end
        end
    elseif orders[orderID].ContingencyType == 0 then
        local trade = core.host:findTable("trades"):find("TradeID", orders[orderID].TradeID);
        if trade ~= nil then
            HandleTradeLimitChange(trade, orderID, label);
        end
    end
end

function HandleOrderLimitChange(order, limit_order_id, label)
    local offer = core.host:findTable("offers"):find("OfferID", orders[limit_order_id].OfferID);
    local message = string.format("Order %s %s:\r\n%s%s", 
        order.OrderID, orders[limit_order_id].Instrument, label,
        FormatLimit(order.BS, order.Rate, orders[limit_order_id].TypeSL, orders[limit_order_id].Rate, offer.PointSize, offer.Digits));
    local rr = FormatRR(order.Rate, order.TypeStop, order.Stop, order.TypeLimit, order.Limit);
    if rr ~= nil then
        message = message .. "\r\n" .. rr;
    end
    signaler:Signal(message);
end

function HandleTradeLimitChange(trade, limit_order_id, label)
    local offer = core.host:findTable("offers"):find("OfferID", orders[limit_order_id].OfferID);
    local message = string.format("Trade %s %s:\r\n%s%s", 
        trade.TradeID, orders[limit_order_id].Instrument, label,
        FormatLimit(trade.BS, trade.Open, 1, orders[limit_order_id].Rate, offer.PointSize, offer.Digits));
    local rr = FormatRR(trade.Open, 1, trade.Stop, 1, trade.Limit);
    if rr ~= nil then
        message = message .. "\r\n" .. rr;
    end
    signaler:Signal(message);
end

function HandleTradeStopChange(trade, stop_order_id, label)
    local offer = core.host:findTable("offers"):find("OfferID", orders[stop_order_id].OfferID);
    local message = string.format("Trade %s %s:\r\n%s%s", 
        trade.TradeID, orders[stop_order_id].Instrument, label,
        FormatStop(trade.BS, trade.Open, 1, orders[stop_order_id].Rate, offer.PointSize, offer.Digits));
    local rr = FormatRR(trade.Open, 1, trade.Stop, 1, trade.Limit);
    if rr ~= nil then
        message = message .. "\r\n" .. rr;
    end
    signaler:Signal(message);
end

function HandleOrderStopChange(order, stop_order_id, label)
    local offer = core.host:findTable("offers"):find("OfferID", orders[stop_order_id].OfferID);
    local message = string.format("Order %s %s:\r\n%s%s", 
        order.OrderID, orders[stop_order_id].Instrument, label,
        FormatStop(order.BS, order.Rate, orders[stop_order_id].TypeSL, orders[stop_order_id].Rate, offer.PointSize, offer.Digits));
    local rr = FormatRR(order.Rate, order.TypeStop, order.Stop, order.TypeLimit, order.Limit);
    if rr ~= nil then
        message = message .. "\r\n" .. rr;
    end
    signaler:Signal(message);
end

function HandleStopChange(orderID, fix_status, label)
    if fix_status == "C" or fix_status == "S" then
        local trade = core.host:findTable("trades"):find("TradeID", orders[orderID].TradeID);
        if trade ~= nil then
            local side = trade.BS == "B" and "Buy" or "Sell";
            local message = string.format("Trade %s %s %s\r\nStop was deleted.",
                trade.TradeID, side, trade.Instrument);
            signaler:Signal(message);
            return;
        end

        local primary_order = core.host:findTable("orders"):find("OrderID", orders[orderID].PrimaryOrderId);
        if primary_order ~= nil then
            local side = primary_order.BS == "B" and "Buy" or "Sell";
            local message = string.format("Order %s %s %s\r\nStop was deleted.",
                primary_order.OrderID, side, primary_order.Instrument);
            signaler:Signal(message);
        end
        return;
    end
    if orders[orderID].ContingencyType == 3 then
        local trade = core.host:findTable("trades"):find("TradeID", orders[orderID].TradeID);
        if trade ~= nil then
            HandleTradeStopChange(trade, orderID, label);
        else
            local primary_order = core.host:findTable("orders"):find("OrderID", orders[orderID].PrimaryOrderId);
            if primary_order ~= nil then
                HandleOrderStopChange(primary_order, orderID, label);
            end
        end
    elseif orders[orderID].ContingencyType == 0 then
        local trade = core.host:findTable("trades"):find("TradeID", orders[orderID].TradeID);
        if trade ~= nil then
            HandleTradeStopChange(trade, orderID, label);
        end
    end
end

function HandleDeletedOrder(orderID)
    if orders[orderID].Stage == "C" then
        if orders[orderID].Type == "S" or orders[orderID].Type == "SE" or orders[orderID].Type == "STE" then
            HandleStopChange(orderID, "C", "Stop was deleted.");
            orders[order.OrderID] = ParseOrder(order);
        end
        HandleLimitChange(orderID, "C", "Limit was deleted.");
        return;
    end
    local side = orders[orderID].BS == "B" and "Buy" or "Sell";
    local message = string.format("Order %s %s %s:\r\nDeleted", 
        orderID, side, orders[orderID].Instrument);
    signaler:Signal(message);
end

function HandleNewEntryOrder(order)
    local offer = core.host:findTable("offers"):find("OfferID", order.OfferID);
    local side = order.BS == "B" and "Buy" or "Sell";
    local message = string.format("New Entry Order\r\nOrder %s %s %s\r\nEntry Price at: %s"
        , order.OrderID, side, order.Instrument, win32.formatNumber(order.Rate, false, offer.Digits));
    if order.Stop ~= 0 then
        message = message .. "\r\n Stop at: " .. FormatStop(order.BS, order.Rate, order.TypeStop, order.Stop, offer.PointSide, offer.Digits);
    end
    if order.Limit ~= 0 then
        message = message .. "\r\n Limit at: " .. FormatLimit(order.BS, order.Rate, order.TypeLimit, order.Limit, offer.PointSide, offer.Digits);
    end
    local rr = FormatRR(order.Rate, order.TypeStop, order.Stop, order.TypeLimit, order.Limit);
    if rr ~= nil then
        message = message .. "\r\n" .. rr;
    end
    signaler:Signal(message);
end

function HandleClosedTrade(trade_id)
    local closed_trade = core.host:findTable("closed trades"):find("TradeID", trade_id);
    if closed_trade == nil then
        return;
    end

    local side = closed_trade.BS == "B" and "Buy" or "Sell";
    local closing_order = closing_order_types[closed_trade.CloseOrderID];
    local offer = core.host:findTable("offers"):find("OfferID", closed_trade.OfferID);
    local message;
    if closing_order == "S" then
        message = string.format("Trade %s %s:\r\nClosed: Stop Hit at %s\r\nResult: %s Pips", 
            closed_trade.TradeID, closed_trade.Instrument, 
            win32.formatNumber(closed_trade.Close, false, offer.Digits),
            win32.formatNumber(closed_trade.PL, false, 1));
    elseif closing_order == "L" then
        message = string.format("Trade %s %s:\r\nClosed: Limit Hit at %s\r\nResult: %s Pips", 
            closed_trade.TradeID, closed_trade.Instrument, 
            win32.formatNumber(closed_trade.Close, false, offer.Digits),
            win32.formatNumber(closed_trade.PL, false, 1));
    else
        message = string.format("Trade %s %s:\r\nClosed: Manually at %s\r\nResult: %s Pips", 
            closed_trade.TradeID, closed_trade.Instrument, 
            win32.formatNumber(closed_trade.Close, false, offer.Digits),
            win32.formatNumber(closed_trade.PL, false, 1));
    end
    signaler:Signal(message);
end

function HandleNewTrade(trade_id)
    local trade = core.host:findTable("trades"):find("TradeID", trade_id);
    if trade == nil then
        return;
    end
    local offer = core.host:findTable("offers"):find("OfferID", trade.OfferID);
    local side = trade.BS == "B" and "Buy" or "Sell";
    local message = string.format("New Trade\r\nTrade %s %s %s\r\nEntry Price at %s", 
        trade.TradeID, side, trade.Instrument, win32.formatNumber(trade.Open, false, offer.Digits));
    if trade.Stop ~= 0 then
        message = message .. "\r\nStop at " .. FormatStop(trade.BS, trade.Open, 1, trade.Stop, offer.PointSize, offer.Digits);
    end
    if trade.Limit ~= 0 then
        message = message .. "\r\nLimit at " .. FormatLimit(trade.BS, trade.Open, 1, trade.Limit, offer.PointSize, offer.Digits);
    end
    local rr = FormatRR(trade.Open, 1, trade.Stop, 1, trade.Limit);
    if rr ~= nil then
        message = message .. "\r\n" .. rr;
    end
    signaler:Signal(message);
end

function CheckOrderForChange(order)
    if orders[order.OrderID].Rate ~= order.Rate then
        local side = order.BS == "B" and "Buy" or "Sell";
        local offer = core.host:findTable("offers"):find("OfferID", order.OfferID);
        local message = string.format("Order %s %s %s\r\nEntry Price Changed to: %s",
            order.OrderID, side, order.Instrument,
            win32.formatNumber(order.Rate, false, offer.Digits));
        signaler:Signal(message);
        orders[order.OrderID].Rate = order.Rate;
    end
end

function ExtAsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == TIMER_ID then
        if orders == nil then
            InitOrders();
        else
            local enum = core.host:findTable("orders"):enumerator();
            local order = enum:next();
            while (order ~= nil) do
                if order.Type == "SE" or order.Type == "LE" then
                    CheckOrderForChange(order);
                elseif order.Type == "S" then
                    CheckStopForChanges(order);
                elseif order.Type == "L" then
                    CheckLimitForChanges(order);
                end
                order = enum:next();
            end
        end
        signaler:SendSignals();
    elseif cookie == TRADES_UPDATE then
        local trade_id = message;
        local close_trade = success;
        if close_trade then
            HandleClosedTrade(trade_id);
        else
            HandleNewTrade(trade_id);
        end
    elseif cookie == ORDERS_UPDATE then
        local order_id = message;
        local order = core.host:findTable("orders"):find("OrderID", order_id);
        local fix_status = message1;
        if order ~= nil then
            if order.Stage == "C" then
                closing_order_types[order.OrderID] = order.Type;
            end
            if order.Type == "SE" or order.Type == "LE" then
                local offer = core.host:findTable("offers"):find("OfferID", order.OfferID);
                if fix_status == "C" or fix_status == "S" then
                    HandleDeletedOrder(order_id);
                elseif fix_status == "W" then
                    HandleNewEntryOrder(order);
                end
                orders[order.OrderID] = ParseOrder(order);
            elseif order.Type == "S" then
                orders[order.OrderID] = ParseOrder(order);
                HandleStopChange(order.OrderID, fix_status, "New Stop at ");
            elseif order.Type == "L" then
                orders[order.OrderID] = ParseOrder(order);
                HandleLimitChange(order.OrderID, fix_status, "New Limit at ");
            else
            end
        elseif fix_status == "C" then
            HandleDeletedOrder(order_id);
        end
    end
    for _, module in pairs(Modules) do if module.AsyncOperationFinished ~= nil then module:AsyncOperationFinished(cookie, success, message, message1, message2); end end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");

signaler = {};
signaler.Name = "Signaler";
signaler.Debug = false;
signaler.Version = "1.5";

signaler._show_alert = nil;
signaler._sound_file = nil;
signaler._recurrent_sound = nil;
signaler._email = nil;
signaler._ids_start = nil;
signaler._advanced_alert_timer = nil;
signaler._tz = nil;
signaler._alerts = {};

function signaler:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function signaler:OnNewModule(module) end
function signaler:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end

function signaler:ToJSON(item)
    local json = {};
    function json:AddStr(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":\"%s\"", separator, tostring(name), tostring(value));
    end
    function json:AddNumber(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":%f", separator, tostring(name), value or 0);
    end
    function json:AddBool(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), value and "true" or "false");
    end
    function json:ToString()
        return "{" .. (self.str or "") .. "}";
    end
    
    local first = true;
    for idx,t in pairs(item) do
        local stype = type(t)
        if stype == "number" then
            json:AddNumber(idx, t);
        elseif stype == "string" then
            json:AddStr(idx, t);
        elseif stype == "boolean" then
            json:AddBool(idx, t);
        elseif stype == "function" or stype == "table" then
            --do nothing
        else
            core.host:trace(tostring(idx) .. " " .. tostring(stype));
        end
    end
    return json:ToString();
end

function signaler:ArrayToJSON(arr)
    local str = "[";
    for i, t in ipairs(self._alerts) do
        local json = self:ToJSON(t);
        if str == "[" then
            str = str .. json;
        else
            str = str .. "," .. json;
        end
    end
    return str .. "]";
end

function signaler:AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == self._advanced_alert_timer and #self._alerts > 0 and (self.last_req == nil or not self.last_req:loading()) then
        if self._advanced_alert_key == nil then
            return;
        end

        local data = self:ArrayToJSON(self._alerts);
        self._alerts = {};
        
        self.last_req = http_lua.createRequest();
        local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
            self._advanced_alert_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
        self.last_req:setRequestHeader("Content-Type", "application/json");
        self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

        self.last_req:start("http://profitrobots.com/api/v1/notification", "POST", query);
    end
end

function signaler:FormatEmail(source, period, message)
    --format email subject
    local subject = message .. "(" .. source:instrument() .. ")";
    --format email text
    local delim = "\013\010";
    local signalDescr = "Signal: " .. (self.StrategyName or "");
    local symbolDescr = "Symbol: " .. source:instrument();
    local messageDescr = "Message: " .. message;
    local ttime = core.dateToTable(core.host:execute("convertTime", core.TZ_EST, self._ToTime, source:date(period)));
    local dateDescr = string.format("Time:  %02i/%02i %02i:%02i", ttime.month, ttime.day, ttime.hour, ttime.min);
    local priceDescr = "Price: " .. source[period];
    local text = "You have received this message because the following signal alert was received:"
        .. delim .. signalDescr .. delim .. symbolDescr .. delim .. messageDescr .. delim .. dateDescr .. delim .. priceDescr;
    return subject, text;
end
local alerts_to_send = {};
function signaler:Signal(message, source)
    local alert = {};
    alert.message = message;
    alert.source = source;
    alert.time = core.now();
    alerts_to_send[#alerts_to_send + 1] = alert;
end

function signaler:SendSignal(message, source)
    if source == nil then
        if instance.source ~= nil then
            source = instance.source;
        elseif instance.bid ~= nil then
            source = instance.bid;
        else
            local pane = core.host.Window.CurrentPane;
            source = pane.Data:getStream(0);
        end
    end
    if self._show_alert then
        terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW));
    end

    if self._sound_file ~= nil then
        terminal:alertSound(self._sound_file, self._recurrent_sound);
    end

    if self._email ~= nil then
        terminal:alertEmail(self._email, profile:id().. " : " .. message, self:FormatEmail(source, NOW, message));
    end

    if self._advanced_alert_key ~= nil then
        self:AlertTelegram(message, source:instrument(), source:barSize());
    end

    if self._signaler_debug_alert then
        core.host:trace(message);
    end

    if self._show_popup then
        local subject, text = self:FormatEmail(source, NOW, message);
        core.host:execute("prompt", self._ids_start + 2, subject, text);
    end

    if self._dde_alerts then
        dde_server:set(self.dde_topic, self.dde_alerts, message);
    end
end

function signaler:SendSignals()
    local unsent_alerts = {};
    local to_send = "";
    local src;
    for _, alert in ipairs(alerts_to_send) do
        if core.now() - alert.time > 3 / 86400 then
            to_send = to_send .. alert.message .. "\r\n";
            src = alert.source;
        else
            unsent_alerts[unsent_alerts + 1] = alert;
        end
    end
    if to_send ~= "" then
        self:SendSignal(to_send, src);
    end
    alerts_to_send = unsent_alerts;
end

function signaler:AlertTelegram(message, instrument, timeframe)
    if core.host.Trading:getTradingProperty("isSimulation") then
        return;
    end
    local alert = {};
    alert.Text = message or "";
    alert.Instrument = "";
    alert.TimeFrame = "";
    self._alerts[#self._alerts + 1] = alert;
end

function signaler:Init(parameters)
    parameters:addInteger("signaler_ToTime", "Convert the date to", "", 6)
    parameters:addIntegerAlternative("signaler_ToTime", "EST", "", 1)
    parameters:addIntegerAlternative("signaler_ToTime", "UTC", "", 2)
    parameters:addIntegerAlternative("signaler_ToTime", "Local", "", 3)
    parameters:addIntegerAlternative("signaler_ToTime", "Server", "", 4)
    parameters:addIntegerAlternative("signaler_ToTime", "Financial", "", 5)
    parameters:addIntegerAlternative("signaler_ToTime", "Display", "", 6)
    
    parameters:addBoolean("signaler_show_alert", "Show Alert", "", true);
    parameters:addBoolean("signaler_play_sound", "Play Sound", "", false);
    parameters:addFile("signaler_sound_file", "Sound File", "", "");
    parameters:setFlag("signaler_sound_file", core.FLAG_SOUND);
    parameters:addBoolean("signaler_recurrent_sound", "Recurrent Sound", "", true);
    parameters:addBoolean("signaler_send_email", "Send Email", "", false);
    parameters:addString("signaler_email", "Email", "", "");
    parameters:setFlag("signaler_email", core.FLAG_EMAIL);
    if indicator ~= nil and strategy == nil then
        parameters:addBoolean("signaler_show_popup", "Show Popup", "", false);
    end
    parameters:addBoolean("signaler_debug_alert", "Print Into Log", "", false);
    parameters:addBoolean("use_advanced_alert", "Send Advanced Alert", "Telegram/Discord/other platform (like MT4)", false)
	parameters:addString("advanced_alert_key", "Advanced Alert Key",
		"You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys", "")
    if DDEAlertsSupport then
        parameters:addBoolean("signaler_dde_export", "DDE Export", "You can export the alert into the Excel or any other application with DDE support (=Service Name|DDE Topic!Alerts)", false);
        parameters:addString("signaler_dde_service", "Service Name", "The service name must be unique amoung all running instances of the strategy", "TS2ALERTS");
        parameters:addString("signaler_dde_topic", "DDE Topic", "", "");
    end
end

function signaler:Prepare(name_only)
    self._ToTime = instance.parameters.signaler_ToTime
    if self._ToTime == 1 then
        self._ToTime = core.TZ_EST
    elseif self._ToTime == 2 then
        self._ToTime = core.TZ_UTC
    elseif self._ToTime == 3 then
        self._ToTime = core.TZ_LOCAL
    elseif self._ToTime == 4 then
        self._ToTime = core.TZ_SERVER
    elseif self._ToTime == 5 then
        self._ToTime = core.TZ_FINANCIAL
    elseif self._ToTime == 6 then
        self._ToTime = core.TZ_TS
    end
    self._dde_alerts = instance.parameters.signaler_dde_export;
    if self._dde_alerts then
        assert(instance.parameters.signaler_dde_topic ~= "", "You need to specify the DDE topic");
        require("ddeserver_lua");
        self.dde_server = ddeserver_lua.new(instance.parameters.signaler_dde_service);
        self.dde_topic = self.dde_server:addTopic(instance.parameters.signaler_dde_topic);
        self.dde_alerts = self.dde_server:addValue(self.dde_topic, "Alerts");
    end

    if instance.parameters.signaler_play_sound then
        self._sound_file = instance.parameters.signaler_sound_file;
        assert(self._sound_file ~= "", "Sound file must be chosen");
    end
    self._show_alert = instance.parameters.signaler_show_alert;
    self._recurrent_sound = instance.parameters.signaler_recurrent_sound;
    self._show_popup = instance.parameters.signaler_show_popup;
    self._signaler_debug_alert = instance.parameters.signaler_debug_alert;
    if instance.parameters.signaler_send_email then
        self._email = instance.parameters.signaler_email;
        assert(self._email ~= "", "E-mail address must be specified");
    end
    --do what you usually do in prepare
    if name_only then
        return;
    end

    if instance.parameters.advanced_alert_key ~= "" and instance.parameters.use_advanced_alert then
        self._advanced_alert_key = instance.parameters.advanced_alert_key;
        require("http_lua");
        self._advanced_alert_timer = self._ids_start + 1;
        core.host:execute("setTimer", self._advanced_alert_timer, 1);
    end
end

function signaler:ReleaseInstance()
    if self.dde_server ~= nil then
        self.dde_server:close();
    end
end

signaler:RegisterModule(Modules);