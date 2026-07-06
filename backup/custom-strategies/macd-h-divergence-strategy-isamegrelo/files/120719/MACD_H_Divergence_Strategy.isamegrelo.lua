-- Id: 22127
-- Id: 
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=66582

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

local Modules = {}

function Init() --The strategy profile initialization
    strategy:name("MACD Divergence strategy")
    strategy:description("MACD Divergence strategy")

    strategy.parameters:addGroup("Parameters")
    strategy.parameters:addInteger("MACD_Short", "Period of short EMA for MACD", "", 12)
    strategy.parameters:addInteger("MACD_Long", "Period of long EMA for MACD", "", 26)
    strategy.parameters:addInteger("MACD_Signal", "Signal period of MACD", "", 9)

    strategy.parameters:addGroup("Strategy Parameters")
    strategy.parameters:addString("TypeSignal", "Type of signal", "", "direct")
    strategy.parameters:addStringAlternative("TypeSignal", "direct", "", "direct")
    strategy.parameters:addStringAlternative("TypeSignal", "reverse", "", "reverse")
    strategy.parameters:addDouble("min_diff", "Min. diff between peaks, in pips", "", 0);

    strategy.parameters:addGroup("Price Parameters")
    strategy.parameters:addString("TF", "Time Frame", "", "m15")
    strategy.parameters:setFlag("TF", core.FLAG_BARPERIODS)

    strategy.parameters:addGroup("Trading Parameters")
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("Account", "Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 100)
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false)
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false)
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false)
    strategy.parameters:addString("AllowDirection", "Allow direction for positions", "", "Both")
    strategy.parameters:addStringAlternative("AllowDirection", "Both", "", "Both")
    strategy.parameters:addStringAlternative("AllowDirection", "Long", "", "Long")
    strategy.parameters:addStringAlternative("AllowDirection", "Short", "", "Short")

    strategy.parameters:addGroup("Signal Parameters")
    signaler:Init(strategy.parameters)
end

-- Internal indicators
local MACD_H_D = nil

-- Strategy parameters
local openLevel = 0
local closeLevel = 0
local confirmTrend

-- Trading parameters
local AllowTrade = nil
local Account = nil
local Amount = nil
local BaseSize = nil
local PipSize
local SetLimit = nil
local Limit = nil
local SetStop = nil
local Stop = nil
local TrailingStop = nil
local CanClose = nil
local AllowDirection
local min_diff;

function Prepare()
    for _, module in pairs(Modules) do module:Prepare(nameOnly); end
    AllowDirection = instance.parameters.AllowDirection
    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick")

    local name
    name = profile:id() .. "(" .. instance.bid:name() .. "." .. instance.parameters.TF
    instance:name(name)

    min_diff = instance.parameters.min_diff;
    AllowTrade = instance.parameters.AllowTrade
    Account = instance.parameters.Account
    Amount = instance.parameters.Amount
    BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account)
    Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID
    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)
    PipSize = instance.bid:pipSize()
    SetLimit = instance.parameters.SetLimit
    Limit = instance.parameters.Limit
    SetStop = instance.parameters.SetStop
    Stop = instance.parameters.Stop
    TrailingStop = instance.parameters.TrailingStop

    assert(
        core.indicators:findIndicator("MACD_H_DIVERGENCE") ~= nil,
        "Please, download and install MACD_H_DIVERGENCE.LUA indicator"
    )

    Source = ExtSubscribe(2, nil, instance.parameters.TF, true, "bar")
    MACD_H_D =
        core.indicators:create(
        "MACD_H_DIVERGENCE",
        Source,
        instance.parameters.MACD_Short,
        instance.parameters.MACD_Long,
        instance.parameters.MACD_Signal,
        false
    )
end

function FindPreviosUp(period)
    for i = period - 1, 0, -1 do
        local UP = MACD_H_D.UP[period - 2]
        if UP == nil then
            UP = 0
        end
        local DN = MACD_H_D.DN[period - 2]
        if DN == nil then
            DN = 0
        end
        if UP + DN > 0 then
            return i;
        end
    end
    return nil;
end

function FindPreviosDown(period)
    for i = period - 1, 0, -1 do
        local UP = MACD_H_D.UP[period - 2]
        if UP == nil then
            UP = 0
        end
        local DN = MACD_H_D.DN[period - 2]
        if DN == nil then
            DN = 0
        end
        if UP + DN < 0 then
            return i;
        end
    end
    return nil;
end

function haveTrades(BuySell)
    local enum = core.host:findTable("trades"):enumerator()
    local row = enum:next()
    while (not found) and (row ~= nil) do
        if row.AccountID == Account and (row.BS == BuySell or BuySell == nil) then
            return true;
        end
        row = enum:next()
    end
    return false
end

function DoBuy(id, source, period)
    if instance.parameters.AllowDirection ~= "Short" then
        local trades = core.host:findTable("trades")
        if (haveTrades()) then
            local enum = trades:enumerator()
            while true do
                local row = enum:next()
                if row == nil then
                    break
                end

                if row.AccountID == Account and row.OfferID == Offer then
                    -- Close position if we have corresponding closing conditions.
                    if row.BS == "S" then
                        signaler:Signal("Close SELL and BUY", source);

                        if AllowTrade then
                            Close(row)
                            Open("B")
                        end
                    end
                end
            end
        else
            signaler:Signal("BUY", source);

            if AllowTrade then
                Open("B")
            end
        end
    end
end

function DoSell(id, source, period)
    if instance.parameters.AllowDirection ~= "Long" then
        local trades = core.host:findTable("trades")
        if (haveTrades()) then
            local enum = trades:enumerator()
            while true do
                local row = enum:next()
                if row == nil then
                    break
                end

                if row.AccountID == Account and row.OfferID == Offer then
                    -- Close position if we have corresponding closing conditions.
                    if row.BS == "B" then
                        signaler:Signal("Close BUY and SELL", source);

                        if AllowTrade then
                            Close(row)
                            Open("S")
                        end
                    end
                end
            end
        else
            signaler:Signal("SELL", source);

            if AllowTrade then
                Open("S")
            end
        end
    end
end

function ExtUpdate(id, source, period) -- The method called every time when a new bid or ask price appears.
    for _, module in pairs(Modules) do if module.BlockTrading ~= nil and module:BlockTrading(id, source, period) then return; end end for _, module in pairs(Modules) do if module.ExtUpdate ~= nil then module:ExtUpdate(id, source, period); end end
    MACD_H_D:update(core.UpdateLast)

    -- Check that we have enough data
    if (MACD_H_D.DATA:first() > (period - 1)) then
        return
    end

    local UP = MACD_H_D.UP[period - 2]
    if UP == nil then
        UP = 0
    end
    local DN = MACD_H_D.DN[period - 2]
    if DN == nil then
        DN = 0
    end

    if UP + DN > 0 then
        local prev = FindPreviosUp(period - 2);
        if prev ~= nil and math.abs(Source.low[period - 2] - Source.low[prev]) / Source:pipSize() >= min_diff then
            if instance.parameters.TypeSignal == "direct" then
                DoBuy(id, source, period);
            else
                DoSell(id, source, period);
            end
        end
    elseif UP + DN < 0 then
        local prev = FindPreviosDown(period - 2);
        if prev ~= nil and math.abs(Source.high[period - 2] - Source.high[prev]) / Source:pipSize() >= min_diff then
            if instance.parameters.TypeSignal == "direct" then
                DoSell(id, source, period);
            else
                DoBuy(id, source, period);
            end
        end
    end
end

-- The strategy instance finalization.
function ReleaseInstance()
    for _, module in pairs(Modules) do if module.ReleaseInstance ~= nil then module:ReleaseInstance(); end end
end

-- The method enters to the market
function Open(side)
    local valuemap

    valuemap = core.valuemap()
    valuemap.OrderType = "OM"
    valuemap.OfferID = Offer
    valuemap.AcctID = Account
    valuemap.Quantity = Amount * BaseSize
    valuemap.CustomID = CID
    valuemap.BuySell = side
    valuemap.QTXT = "1"
    if SetStop and CanClose then
        valuemap.PegTypeStop = "O"
        if side == "B" then
            valuemap.PegPriceOffsetPipsStop = -Stop
        else
            valuemap.PegPriceOffsetPipsStop = Stop
        end
        if TrailingStop then
            valuemap.TrailStepStop = 1
        end
    end
    if SetLimit and CanClose then
        valuemap.PegTypeLimit = "O"
        if side == "B" then
            valuemap.PegPriceOffsetPipsLimit = Limit
        else
            valuemap.PegPriceOffsetPipsLimit = -Limit
        end
    end
    success, msg = terminal:execute(200, valuemap)
    assert(success, msg)

    -- FIFO Account, in that case we have to open Net Limit and Stop Orders
    if not (CanClose) then
        if SetStop then
            valuemap = core.valuemap()
            valuemap.OrderType = "SE"
            valuemap.OfferID = Offer
            valuemap.AcctID = Account
            valuemap.NetQtyFlag = "y"
            if side == "B" then
                valuemap.BuySell = "S"
                rate = instance.ask[NOW] - Stop * PipSize
                valuemap.Rate = rate
            elseif side == "S" then
                valuemap.BuySell = "B"
                rate = instance.bid[NOW] + Stop * PipSize
                valuemap.Rate = rate
            end
            if TrailingStop then
                valuemap.TrailUpdatePips = 1
            end
            success, msg = terminal:execute(200, valuemap)
            --core.host:trace('Set stop @ ' .. rate);
            assert(success, msg)
        end
        if SetLimit then
            valuemap = core.valuemap()
            valuemap.OrderType = "LE"
            valuemap.OfferID = Offer
            valuemap.AcctID = Account
            valuemap.NetQtyFlag = "y"
            if side == "B" then
                valuemap.BuySell = "S"
                rate = instance.ask[NOW] + Limit * PipSize
                valuemap.Rate = rate
            elseif side == "S" then
                valuemap.BuySell = "B"
                rate = instance.bid[NOW] - Limit * PipSize
                valuemap.Rate = rate
            end
            success, msg = terminal:execute(200, valuemap)
            --core.host:trace('Set limit @ ' .. rate);
            assert(success, msg)
        end
    end
end

-- Closes specific position
function Close(trade)
    local valuemap
    valuemap = core.valuemap()

    if CanClose then
        -- non-FIFO account, create a close market order
        valuemap.OrderType = "CM"
        valuemap.TradeID = trade.TradeID
    else
        -- FIFO account, create an opposite market order
        valuemap.OrderType = "OM"
    end

    valuemap.OfferID = trade.OfferID
    valuemap.AcctID = trade.AccountID
    valuemap.Quantity = trade.Lot
    valuemap.CustomID = trade.QTXT
    if trade.BS == "B" then
        valuemap.BuySell = "S"
    else
        valuemap.BuySell = "B"
    end
    success, msg = terminal:execute(200, valuemap)
    assert(success, msg)
end

function ExtAsyncOperationFinished(cookie, success, message, message1, message2)
    core.host:trace("test");
    for _, module in pairs(Modules) do if module.AsyncOperationFinished ~= nil then module:AsyncOperationFinished(cookie, success, message, message1, message2); end end
    if not success then
        core.host:trace("Error: " .. message)
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")

signaler = {}
signaler.Name = "Signaler"
signaler.Debug = false
signaler.Version = "1.2.1"

signaler._show_alert = nil
signaler._sound_file = nil
signaler._recurrent_sound = nil
signaler._email = nil
signaler._ids_start = nil
signaler._telegram_timer = nil
signaler._tz = nil
signaler._alerts = {}

function signaler:trace(str)
    if not self.Debug then
        return
    end
    core.host:trace(self.Name .. ": " .. str)
end
function signaler:OnNewModule(module)
end
function signaler:RegisterModule(modules)
    for _, module in pairs(modules) do
        self:OnNewModule(module)
        module:OnNewModule(self)
    end
    modules[#modules + 1] = self
    self._ids_start = (#modules) * 100
end

function signaler:ToJSON(item)
    local json = {}
    function json:AddStr(name, value)
        local separator = ""
        if self.str ~= nil then
            separator = ","
        else
            self.str = ""
        end
        self.str = self.str .. string.format('%s"%s":"%s"', separator, tostring(name), tostring(value))
    end
    function json:AddNumber(name, value)
        local separator = ""
        if self.str ~= nil then
            separator = ","
        else
            self.str = ""
        end
        self.str = self.str .. string.format('%s"%s":%f', separator, tostring(name), value or 0)
    end
    function json:AddBool(name, value)
        local separator = ""
        if self.str ~= nil then
            separator = ","
        else
            self.str = ""
        end
        self.str = self.str .. string.format('%s"%s":%s', separator, tostring(name), value and "true" or "false")
    end
    function json:ToString()
        return "{" .. (self.str or "") .. "}"
    end

    local first = true
    for idx, t in pairs(item) do
        local stype = type(t)
        if stype == "number" then
            json:AddNumber(idx, t)
        elseif stype == "string" then
            json:AddStr(idx, t)
        elseif stype == "boolean" then
            json:AddBool(idx, t)
        elseif stype == "function" or stype == "table" then
            --do nothing
        else
            core.host:trace(tostring(idx) .. " " .. tostring(stype))
        end
    end
    return json:ToString()
end

function signaler:ArrayToJSON(arr)
    local str = "["
    for i, t in ipairs(self._alerts) do
        local json = self:ToJSON(t)
        if str == "[" then
            str = str .. json
        else
            str = str .. "," .. json
        end
    end
    return str .. "]"
end

function signaler:AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == self._telegram_timer and #self._alerts > 0 and (self.last_req == nil or not self.last_req:loading()) then
        if self._external_service_key == nil then
            return
        end

        local data = self:ArrayToJSON(self._alerts)
        self._alerts = {}

        self.last_req = http_lua.createRequest()
        local query =
            string.format(
            '{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
            self._external_service_key,
            string.gsub(self.StrategyName or "", '"', '\\"'),
            data
        )
        self.last_req:setRequestHeader("Content-Type", "application/json")
        self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)))

        self.last_req:start("http://profitrobots.com/api/v1/notification", "POST", query)
    end
end

function signaler:FormatEmail(source, period, message)
    --format email subject
    local subject = message .. "(" .. source:instrument() .. ")"
    --format email text
    local delim = "\013\010"
    local signalDescr = "Signal: " .. (self.StrategyName or "")
    local symbolDescr = "Symbol: " .. source:instrument()
    local messageDescr = "Message: " .. message
    local ttime = core.dateToTable(core.host:execute("convertTime", 1, 4, source:date(period)))
    local dateDescr = string.format("Time:  %02i/%02i %02i:%02i", ttime.month, ttime.day, ttime.hour, ttime.min)
    local priceDescr = "Price: " .. source[period]
    local text =
        "You have received this message because the following signal alert was received:" ..
        delim ..
            signalDescr .. delim .. symbolDescr .. delim .. messageDescr .. delim .. dateDescr .. delim .. priceDescr
    return subject, text
end

function signaler:Signal(label, source)
    if source == nil then
        source = instance.bid
        if instance.bid == nil then
            local pane = core.host.Window.CurrentPane
            source = pane.Data:getStream(0)
        else
            source = instance.bid
        end
    end
    if self._show_alert then
        terminal:alertMessage(source:instrument(), source[NOW], label, source:date(NOW))
    end

    if self._sound_file ~= nil then
        terminal:alertSound(self._sound_file, self._recurrent_sound)
    end

    if self._email ~= nil then
        terminal:alertEmail(self._email, profile:id() .. " : " .. label, self:FormatEmail(source, NOW, label))
    end

    if self._external_service_key ~= nil then
        self:AlertTelegram(label, source:instrument(), source:barSize())
    end
end

function signaler:AlertTelegram(message, instrument, timeframe)
    if core.host.Trading:getTradingProperty("isSimulation") then
        return
    end
    local alert = {}
    alert.Text = message or ""
    alert.Instrument = instrument or ""
    alert.TimeFrame = timeframe or ""
    self._alerts[#self._alerts + 1] = alert
end

function signaler:Init(parameters)
    parameters:addBoolean("signaler_show_alert", "Show Alert", "", true)
    parameters:addBoolean("signaler_play_sound", "Play Sound", "", false)
    parameters:addFile("signaler_sound_file", "Sound File", "", "")
    parameters:setFlag("signaler_sound_file", core.FLAG_SOUND)
    parameters:addBoolean("signaler_recurrent_sound", "Recurrent Sound", "", true)
    parameters:addBoolean("signaler_send_email", "Send Email", "", false)
    parameters:addString("signaler_email", "Email", "", "")
    parameters:setFlag("signaler_email", core.FLAG_EMAIL)
    parameters:addBoolean("use_external_service", "Send to external service", "Telegram message or Channel post", false)
    parameters:addString(
        "external_service_key",
        "External service Key",
        "You can get it via @profit_robots_bot Telegram bot",
        ""
    )
end

function signaler:Prepare(name_only)
    if instance.parameters.signaler_play_sound then
        self._sound_file = instance.parameters.signaler_sound_file
        assert(self._sound_file ~= "", "Sound file must be chosen")
    end
    self._show_alert = instance.parameters.signaler_show_alert
    self._recurrent_sound = instance.parameters.signaler_recurrent_sound
    if instance.parameters.signaler_send_email then
        self._email = instance.parameters.signaler_email
        assert(self._email ~= "", "E-mail address must be specified")
    end
    --do what you usually do in prepare
    if name_only then
        return
    end

    if instance.parameters.external_service_key ~= "" and instance.parameters.use_external_service then
        self._external_service_key = instance.parameters.external_service_key
        require("http_lua")
        self._telegram_timer = self._ids_start + 1
        core.host:execute("setTimer", self._telegram_timer, 1)
    end
end

signaler:RegisterModule(Modules)
