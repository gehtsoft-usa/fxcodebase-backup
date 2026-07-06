-- Id: 21520
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=66179

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
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
    strategy:name("Monitor loosing trades alert");
    strategy:description("v.2 2018-08-06");

    strategy.parameters:addGroup("Trade");
    strategy.parameters:addString("Trade", "(non-FIFO) Choose Trade", "", "");
    strategy.parameters:setFlag("Trade", core.FLAG_TRADE);
    strategy.parameters:addBoolean("all_trades", "Monitor new trades", "", false);

    strategy.parameters:addGroup("Price");
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
    strategy.parameters:addString("Period", "Timeframe", "", "m15");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Alerts");
    signaler:Init(strategy.parameters);
end

local Sources = {};
local trade;
local all_trades;
local TRADES_UPDATE = 1000;
local trades = {};

function CreateTrade(trade)
    core.host:trace("new trade");
    if Sources[trade.Instrument] == nil then
        Sources[trade.Instrument] = ExtSubscribe(#Sources + 1, trade.Instrument, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
    end
    local controller = {};
    controller.limit = trade.Open;
    controller.instrument = trade.Instrument;
    controller.trade_id = trade.TradeID;
    trades[#trades + 1] = controller;
end

function Prepare(nameOnly)
    for _, module in pairs(Modules) do module:Prepare(nameOnly); end
    name = profile:id() .. "(" ..  instance.parameters.Trade   ..  " [" .. instance.parameters.Period .. "] " .. ")";
    all_trades = instance.parameters.all_trades;
    if not all_trades then
        trade = core.host:findTable("trades"):find("TradeID", instance.parameters.Trade);
        assert(trade ~= nil, "Trade can not be found")
    end

    instance:name(name);
    if onlyName then
        return ;
    end 
      
    assert(instance.parameters.Period ~= "t1", "Time frame t1 is not support");
    if not all_trades then
        CreateTrade(trade)
    else
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        while row ~= nil do
            CreateTrade(row);
            row = enum:next();
        end
        core.host:execute("subscribeTradeEvents", TRADES_UPDATE, "trades");
    end
end

local init = false;
function ExtUpdate(id, source, period)
    for _, module in pairs(Modules) do if module.BlockTrading ~= nil and module:BlockTrading(id, source, period) then return; end end for _, module in pairs(Modules) do if module.ExtUpdate ~= nil then module:ExtUpdate(id, source, period); end end
    if not(checkReady("trades")) then
        return;
    end

    for _, controller in ipairs(trades) do
        DoTradeLogic(controller, source, period);
    end
end

function DoTradeLogic(controller, source, period)
    if controller.Finished == true or controller.instrument ~= source:instrument() then
        return;
    end
    local trade = core.host:findTable("trades"):find("TradeID", controller.trade_id);
    if isTradeExist(trade) == false then
        controller.Finished = true;
        return;
    end 
    
    if trade.BS == 'S' then
        if source.high[period] > controller.limit then
            controller.limit = source.high[period];
            signaler:Signal(trade.TradeID .. " Should change limits: " .. controller.limit, source);
        end
    else
        if source.low[period] < controller.limit then
            controller.limit = source.low[period];
            signaler:Signal(trade.TradeID .. " Should change limits: " .. controller.limit, source);
        end
    end
end

function isTradeExist(trade)
    if trade == nil then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Trade " .. instance.parameters.Trade .. " disappear", instance.bid:date(NOW));
        core.host:execute("stop");
        return false;
    end
    
    return true;
end 

function checkReady(table)
    return core.host:execute("isTableFilled", table);
end
function ReleaseInstance() for _, module in pairs(Modules) do if module.ReleaseInstance ~= nil then module:ReleaseInstance(); end end end
function ExtAsyncOperationFinished(cookie, success, message, message1, message2)
    for _, module in pairs(Modules) do if module.AsyncOperationFinished ~= nil then module:AsyncOperationFinished(cookie, success, message, message1, message2); end end
    if cookie == TRADES_UPDATE then
        local close_trade = success;
        if not close_trade then
            local trade_id = message;
            local trade = core.host:findTable("trades"):find("TradeID", trade_id);
            CreateTrade(trade);
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");

signaler = {};
signaler.Name = "Signaler";
signaler.Debug = false;
signaler.Version = "1.2.1";

signaler._show_alert = nil;
signaler._sound_file = nil;
signaler._recurrent_sound = nil;
signaler._email = nil;
signaler._ids_start = nil;
signaler._telegram_timer = nil;
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
    if cookie == self._telegram_timer and #self._alerts > 0 and (self.last_req == nil or not self.last_req:loading()) then
        if self._external_service_key == nil then
            return;
        end

        local data = self:ArrayToJSON(self._alerts);
        self._alerts = {};
        
        self.last_req = http_lua.createRequest();
        local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
            self._external_service_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
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
    local ttime = core.dateToTable(core.host:execute("convertTime", 1, 4, source:date(period)));
    local dateDescr = string.format("Time:  %02i/%02i %02i:%02i", ttime.month, ttime.day, ttime.hour, ttime.min);
    local priceDescr = "Price: " .. source[period];
    local text = "You have received this message because the following signal alert was received:"
        .. delim .. signalDescr .. delim .. symbolDescr .. delim .. messageDescr .. delim .. dateDescr .. delim .. priceDescr;
    return subject, text;
end

function signaler:Signal(label, source)
    if source == nil then
        source = instance.bid;
        if instance.bid == nil then
            local pane = core.host.Window.CurrentPane;
            source = pane.Data:getStream(0);
        else
            source = instance.bid;
        end
    end
    if self._show_alert then
        terminal:alertMessage(source:instrument(), source[NOW], label, source:date(NOW));
    end

    if self._sound_file ~= nil then
        terminal:alertSound(self._sound_file, self._recurrent_sound);
    end

    if self._email ~= nil then
        terminal:alertEmail(self._email, profile:id().. " : " .. label, self:FormatEmail(source, NOW, label));
    end

    if self._external_service_key ~= nil then
        self:AlertTelegram(label, source:instrument(), source:barSize());
    end
end

function signaler:AlertTelegram(message, instrument, timeframe)
    if core.host.Trading:getTradingProperty("isSimulation") then
        return;
    end
    local alert = {};
    alert.Text = message or "";
    alert.Instrument = instrument or "";
    alert.TimeFrame = timeframe or "";
    self._alerts[#self._alerts + 1] = alert;
end

function signaler:Init(parameters)
    parameters:addBoolean("signaler_show_alert", "Show Alert", "", true);
    parameters:addBoolean("signaler_play_sound", "Play Sound", "", false);
    parameters:addFile("signaler_sound_file", "Sound File", "", "");
    parameters:setFlag("signaler_sound_file", core.FLAG_SOUND);
    parameters:addBoolean("signaler_recurrent_sound", "Recurrent Sound", "", true);
    parameters:addBoolean("signaler_send_email", "Send Email", "", false);
    parameters:addString("signaler_email", "Email", "", "");
    parameters:setFlag("signaler_email", core.FLAG_EMAIL);
    parameters:addBoolean("use_external_service", "Send to external service", "Telegram message or Channel post", false);
    parameters:addString("external_service_key", "External service Key", "You can get it via @profit_robots_bot Telegram bot", "");
end

function signaler:Prepare(name_only)
    if instance.parameters.signaler_play_sound then
        self._sound_file = instance.parameters.signaler_sound_file;
        assert(self._sound_file ~= "", "Sound file must be chosen");
    end
    self._show_alert = instance.parameters.signaler_show_alert;
    self._recurrent_sound = instance.parameters.signaler_recurrent_sound;
    if instance.parameters.signaler_send_email then
        self._email = instance.parameters.signaler_email;
        assert(self._email ~= "", "E-mail address must be specified");
    end
    --do what you usually do in prepare
    if name_only then
        return;
    end

    if instance.parameters.external_service_key ~= "" and instance.parameters.use_external_service then
        self._external_service_key = instance.parameters.external_service_key;
        require("http_lua");
        self._telegram_timer = self._ids_start + 1;
        core.host:execute("setTimer", self._telegram_timer, 1);
    end
end
signaler:RegisterModule(Modules);