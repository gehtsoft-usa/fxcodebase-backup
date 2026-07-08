-- Id: 2037
-- More information about this indicator can be found at:
-- http://fxcodebase.com

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
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
    strategy:name("Set net stop by Moving Average (for FIFO accounts)")
    strategy:description("Strategy changes net stop equal to the chosen moving average value")

    strategy.parameters:addGroup("MVA Parameters")
    strategy.parameters:addInteger("MVAN", "Periods", "", 200, 1, 299)

    strategy.parameters:addString(
        "MvaMET",
        "Moving average method",
        "The methods marked with (*) must be downloaded and installed",
        "MVA"
    )
    strategy.parameters:addStringAlternative("MvaMET", "MVA", "", "MVA")
    strategy.parameters:addStringAlternative("MvaMET", "EMA", "", "EMA")
    strategy.parameters:addStringAlternative("MvaMET", "LWMA", "", "LWMA")
    strategy.parameters:addStringAlternative("MvaMET", "TMA", "", "TMA")
    strategy.parameters:addStringAlternative("MvaMET", "SMMA(*)", "", "SMMA")
    strategy.parameters:addStringAlternative("MvaMET", "Vidya (1995)*", "", "VIDYA")
    strategy.parameters:addStringAlternative("MvaMET", "Vidya (1992)*", "", "VIDYA92")
    strategy.parameters:addStringAlternative("MvaMET", "Wilders*", "", "WMA")

    strategy.parameters:addString("Type", "Price type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addString("Period", "Timeframe", "", "H1")
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS)

    strategy.parameters:addString("Price", "Price", "", "close")
    strategy.parameters:addStringAlternative("Price", "Open", "", "open")
    strategy.parameters:addStringAlternative("Price", "High", "", "high")
    strategy.parameters:addStringAlternative("Price", "Low", "", "low")
    strategy.parameters:addStringAlternative("Price", "Close/Tick", "", "close")
    strategy.parameters:addStringAlternative("Price", "Median", "", "median")
    strategy.parameters:addStringAlternative("Price", "Typical", "", "typical")
    strategy.parameters:addStringAlternative("Price", "Weighted", "", "weighted")

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);

    strategy.parameters:addGroup("Account Parameters")
    strategy.parameters:addString("AccountID", "Account to trade on", "", "")
    strategy.parameters:setFlag("AccountID", core.FLAG_ACCOUNT)
    strategy.parameters:addInteger("Timeout", "How often change stop (in seconds)", "", 1, 1, 60)
end

local AccountID
local OfferID
local first = true
local stopOrder = nil -- the identifier of the stop order
local bid = nil
local tsource = nil
local mva = nil
local timer
local minChange
local executing = false

function Prepare(onlyName)
    local name

    name =
        profile:id() ..
        "(" ..
            instance.bid:instrument() ..
                "[" ..
                    instance.parameters.Period ..
                        "]" ..
                            "." ..
                                instance.parameters.Price ..
                                    "," ..
                                        instance.parameters.MvaMET ..
                                            "(" ..
                                                instance.parameters.MVAN ..
                                                    ")" .. "," .. instance.parameters.AccountID .. ")"
    instance:name(name)
    if onlyName then
        return
    end

    ExtSetupSignal(name .. ":", true)
    minChange = instance.bid:pipSize()
    local isource

    bid = ExtSubscribe(1, nil, "t1", true, "tick")
    tsource = ExtSubscribe(2, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar")
    if instance.parameters.Period == "t1" then
        isource = tsource
    elseif instance.parameters.Price == "open" then
        isource = tsource.open
    elseif instance.parameters.Price == "high" then
        isource = tsource.high
    elseif instance.parameters.Price == "low" then
        isource = tsource.low
    elseif instance.parameters.Price == "close" then
        isource = tsource.close
    elseif instance.parameters.Price == "median" then
        isource = tsource.median
    elseif instance.parameters.Price == "typical" then
        isource = tsource.typical
    elseif instance.parameters.Price == "weighted" then
        isource = tsource.weighted
    else
        isource = tsource.close
    end
    AccountID = instance.parameters.AccountID
    OfferID = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID

    assert(
        core.indicators:findIndicator(instance.parameters.MvaMET) ~= nil,
        "Please, download and install " .. instance.parameters.MvaMET .. " indicator"
    )

    mva = core.indicators:create(instance.parameters.MvaMET, isource, instance.parameters.MVAN)
    timer = core.host:execute("setTimer", 100, instance.parameters.Timeout)
end

function ExtUpdate(id, source, period)
    if id == 1 then
        mva:update(core.UpdateLast)
    end
end

function ExtAsyncOperationFinished(id, success, message)
    if not instance.parameters.AllowTrade then
        return;
    end
    if id == 100 and not (executing) then
        local period
        period = mva.DATA:size() - 1

        if period >= 0 and mva.DATA:hasData(period) then
            if not (core.host:execute("isTableFilled", "trades")) then
                -- relogin??
                return
            end

            if not (core.host:execute("isReadyForTrade")) then
                -- relogin??
                return
            end

            local enum, row
            local buy, sell
            enum = core.host:findTable("trades"):enumerator()
            row = enum:next()
            buy = 0
            sell = 0
            while row ~= nil do
                if row.OfferID == OfferID and row.AccountID == AccountID then
                    if row.BS == "B" then
                        buy = buy + 1
                    elseif row.BS == "S" then
                        sell = sell + 1
                    end
                end
                row = enum:next()
            end

            local stopValue, valuemap, success, msg
            stopValue = mva.DATA[period]

            if buy > 0 then
                stop("S", stopValue)
            end

            if sell > 0 then
                stop("B", stopValue)
            end
        end
    elseif id == 200 then
        executing = false
        if not (success) then
            terminal:alertMessage(
                instance.bid:instrument(),
                instance.bid[NOW],
                "Failed create/change stop " .. msg,
                instance.bid:date(NOW)
            )
        end
    end
end

function stop(stopSide, stopValue)
    if stopSide == "S" then
        if stopValue >= instance.bid[NOW] then
            return
        end
    elseif stopSide == "B" then
        if stopValue <= instance.ask[NOW] then
            return
        end
    end

    -- try to find the order
    local enum, row
    local order = nil
    local rate

    local enum, row
    local buy, sell
    enum = core.host:findTable("orders"):enumerator()
    row = enum:next()
    while (row ~= nil) do
        if
            row.OfferID == OfferID and row.AccountID == AccountID and row.BS == stopSide and row.NetQuantity and
                row.Type == "SE"
         then
            order = row.OrderID
            rate = row.Rate
        end
        row = enum:next()
    end

    if order == nil then
        valuemap = core.valuemap()
        valuemap.Command = "CreateOrder"
        valuemap.OrderType = "SE"
        valuemap.OfferID = OfferID
        valuemap.AcctID = AccountID
        valuemap.NetQtyFlag = "y"
        valuemap.Rate = stopValue
        valuemap.BuySell = stopSide
        executing = true
        success, msg = terminal:execute(200, valuemap)
        if not (success) then
            executing = false
            terminal:alertMessage(
                instance.bid:instrument(),
                instance.bid[NOW],
                "Failed create stop " .. msg,
                instance.bid:date(NOW)
            )
        end
    else
        if math.abs(stopValue - rate) >= minChange then
            -- stop exists
            valuemap = core.valuemap()
            valuemap.Command = "EditOrder"
            valuemap.OfferID = OfferID
            valuemap.AcctID = AccountID
            valuemap.OrderID = order
            valuemap.Rate = stopValue
            executing = true
            success, msg = terminal:execute(200, valuemap)
            if not (success) then
                executing = false
                terminal:alertMessage(
                    instance.bid:instrument(),
                    instance.bid[NOW],
                    "Failed change stop " .. msg,
                    instance.bid:date(NOW)
                )
            end
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
