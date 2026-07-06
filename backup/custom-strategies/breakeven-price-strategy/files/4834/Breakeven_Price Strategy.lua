-- Id: 1967
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=2280

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

local Modules = {};

function Init()
    strategy:name("Breakeven_Price Strategy");
    strategy:description("The strategy Closes Position on Breakeven Price");
	strategy:setTag("NonOptimizableParameters", "ShowAlert,PlaySound,SoundFile,RecurrentSound,SendMail,Email");

    strategy.parameters:addGroup("Price Parameters");
    strategy.parameters:addString("TF", "Time Frame", "", "m15");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Trading Parameters");
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addBoolean("AllowLong", "Allow strategy to Close Long Positions", "", false);
	strategy.parameters:addBoolean("AllowShort", "Allow strategy to Close Short Positions", "", false);
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "Breakeven_Price_Strategy");
	strategy.parameters:addString("action", "Action", "", "close");
    strategy.parameters:addStringAlternative("action", "Close all positions", "", "close");
	strategy.parameters:addStringAlternative("action", "Hedge", "", "hedge");
     
    signaler:Init(strategy.parameters);
end

local AllowLong, AllowShort;
local Offer;
local Account;
local CustomID;
local action;

function Prepare(nameOnly)
    for _, module in pairs(Modules) do module:Prepare(nameOnly); end
    action = instance.parameters.action;
    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick");
    assert(core.indicators:findIndicator("BREAKEVEN_PRICE") ~= nil, "Please download and install BREAKEVEN_PRICE indicator!");

    local name;
    name = profile:id() .. "(" .. instance.bid:name() .. "." .. instance.parameters.TF ..  ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    AllowShort = instance.parameters.AllowShort;
	AllowLong = instance.parameters.AllowLong;
    if AllowLong or AllowShort then
        Account = instance.parameters.Account; 
		CustomID = instance.parameters.CustomID;		
        Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;
    end

    ExtSubscribe(1, nil, "t1", true, "close");
end

local first = true;
local BAR = nil;
local indicator = nil;
function ReleaseInstance() for _, module in pairs(Modules) do if module.ReleaseInstance ~= nil then module:ReleaseInstance(); end end end
function ExtAsyncOperationFinished(cookie, success, message, message1, message2) for _, module in pairs(Modules) do if module.AsyncOperationFinished ~= nil then module:AsyncOperationFinished(cookie, success, message, message1, message2); end end end
function ExtUpdate(id, source, period)
    if not instance.parameters.AllowTrade then
        return;
    end
    for _, module in pairs(Modules) do if module.BlockTrading ~= nil and module:BlockTrading(id, source, period) then return; end end for _, module in pairs(Modules) do if module.ExtUpdate ~= nil then module:ExtUpdate(id, source, period); end end
    if id == 1 and first then
        first = false;
        
        BAR = ExtSubscribe(2, nil, instance.parameters.TF, true, "bar");	   
        indicator = core.indicators:create("BREAKEVEN_PRICE", BAR.close);
    elseif id == 2 and period > 1 then
        indicator:update(core.UpdateLast);
        -- check whether the signal appears
        if core.crossesOver(BAR.close, indicator.SELL[NOW], period) and AllowShort then
            if action == "close" then
                signaler:Signal("Short Position Closed");
                exit("S");
            else
                signaler:Signal("Hedging short positions");
                HedgePositions("S");
                core.host:execute("stop");
            end
        elseif core.crossesUnder(BAR.close, indicator.BUY[NOW], period) and AllowLong then
            if action == "close" then
                signaler:Signal("Long Position Closed");
                exit("B");
            else
                signaler:Signal("Hedging long positions");
                HedgePositions("B");
                core.host:execute("stop");
            end
        end
    end
end

function CalculateTotalAmount(offer_id, account_id, bs)
    local total = 0;
    local count=0;
    local enum = core.host:findTable("trades"):enumerator();
    local row = enum:next();
    while (row ~= nil) do
        if row.OfferID == offer_id and row.AccountID == account_id and row.BS == bs then
            total = total + row.AmountK;
            count=count+row.Lot;
        end
        row = enum:next();
    end
    return total,count;
end

function HedgePositions(side)
    local offers = core.host:findTable("offers"):enumerator();
    local offer = offers:next();
    while (offer ~= nil) do
        local offer_id = offer.OfferID;
        local enum = core.host:findTable("accounts"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if row.Hedging == "Y" then
                local total_amount = CalculateTotalAmount(offer_id, row.AccountID, side);
                local base_size = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), row.AccountID);
                if total_amount > 0 then
                    if side == "B" then
                        OpenMarket(offer_id, row.AccountID, "S", total_amount * base_size);
                    else
                        OpenMarket(offer_id, row.AccountID, "B", total_amount * base_size);
                    end
                end
            end
            row = enum:next();
        end
        offer = offers:next();
    end
end

function OpenMarket(offer_id, account_id, bs, amount)
    local valuemap = core.valuemap();
    valuemap.OrderType = "OM";
    valuemap.OfferID = offer_id;
    valuemap.AcctID = account_id;
    valuemap.Quantity = amount;
    valuemap.BuySell = bs;
    local success, msg = terminal:execute(200, valuemap);
    assert(success, msg);
end

-- exit from the specified direction
function exit(BuySell)
    if not(AllowLong) and not(AllowShort) then
        return ;
    end

    local enum, row, valuemap, success, msg;

    -- check whether we have at least one trade on the specified account
    -- in the specified direction for the specified instrument
    local count = 0;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while count == 0 and row ~= nil do
        if row.AccountID == Account and
           row.OfferID == Offer and
           row.BS == BuySell then
           count = count + 1;
        end
        row = enum:next();
    end

    if count > 0 then
        valuemap = core.valuemap();

        -- switch the direction since the order must be in oppsite direction
        if BuySell == "B" then
            BuySell = "S";
        else
            BuySell = "B";
        end
        valuemap.OrderType = "CM";
        valuemap.OfferID = Offer;
        valuemap.AcctID = Account;
        valuemap.TradeID = "all";
        valuemap.NetQtyFlag = "Y";
        valuemap.BuySell = BuySell;
		valuemap.CustomID = CustomID;
        success, msg = terminal:execute(101, valuemap);

        if not(success) then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");

signaler = {};
signaler.Name = "Signaler";
signaler.Debug = false;
signaler.Version = "1.1.4";

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
        if self._telegram_key == nil then
            return;
        end

        local data = self:ArrayToJSON(self._alerts);
        self._alerts = {};
        
        self.last_req = http_lua.createRequest();
        local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
            self._telegram_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
        self.last_req:setRequestHeader("Content-Type", "application/json");
        self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

        self.last_req:start("http://profitrobots.com/api/v1/notification", "POST", query);
    end
end

function signaler:Signal(label, source)
    if source == nil then
        source = instance.bid;
    end
    if self._show_alert then
        terminal:alertMessage(source:instrument(), source[NOW], label, source:date(NOW));
    end

    if self._sound_file ~= nil then
        terminal:alertSound(self._sound_file, self._recurrent_sound);
    end

    if self._email ~= nil then
        terminal:alertEmail(self._email, profile:id().. " : " .. label , FormatEmail(source, NOW, label));
    end

    if self._telegram_key ~= nil then
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
    parameters:addGroup("Alerts");
    parameters:addBoolean("signaler_show_alert", "Show Alert", "", true);
    parameters:addBoolean("signaler_play_sound", "Play Sound", "", false);
    parameters:addFile("signaler_sound_file", "Sound File", "", "");
    parameters:setFlag("signaler_sound_file", core.FLAG_SOUND);
    parameters:addBoolean("signaler_recurrent_sound", "Recurrent Sound", "", true);
    parameters:addBoolean("signaler_send_email", "Send Email", "", false);
    parameters:addString("signaler_email", "Email", "", "");
    parameters:setFlag("signaler_email", core.FLAG_EMAIL);
    parameters:addBoolean("use_telegram", "Send to Telegram", "", false);
    parameters:addString("telegram_key", "Telegram Key", "Used for @profit_robots_bot", "");
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

    if instance.parameters.telegram_key ~= "" and instance.parameters.use_telegram then
        self._telegram_key = instance.parameters.telegram_key;
        require("http_lua");
        self._telegram_timer = self._ids_start + 1;
        core.host:execute("setTimer", self._telegram_timer, 1);
    end
end
signaler:RegisterModule(Modules);