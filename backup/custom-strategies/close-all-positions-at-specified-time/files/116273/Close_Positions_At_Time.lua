-- Id: 19854
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=65410

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
    strategy:name("Close Positions At Time")
    strategy:description("Close Positions At Time")

    local cur = core.now()
    local tcur = core.dateToTable(cur)

    local sTime = string.format("%02i:%02i", tcur.hour, tcur.min)

    strategy.parameters:addString(
        "TIME",
        "Time",
        "The time at which the trades should be closed (hh:mm). The time is specified in the local time zone.",
        "hh:mm"
    )
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)
    strategy.parameters:addString("Account", "Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
end

local sTIME
local CanClose
local hours, minutes
local Fl
local Source

function Prepare(onlyName)
    local name = profile:id()
    instance:name(name)
    if onlyName then
        return
    end

    CanClose =
        core.host:execute(
        "getTradingProperty",
        "canCreateMarketClose",
        instance.bid:instrument(),
        instance.parameters.Account
    )

    sTIME = instance.parameters.TIME

    hours, minutes = string.match(sTIME, "(%d+):(%d+)")

    local sErrorTime = "Please specify the time in the format 'hh:mm' in the local time zone."

    assert(string.match(sTIME, "(%d+):(%d+)") ~= nil, sErrorTime)

    if string.len(hours) ~= 2 or string.len(minutes) ~= 2 then
        assert(false, sErrorTime)
    end
    Source = ExtSubscribe(1, nil, "t1", true, "close")
    Fl = false
end

function CloseAll()
    local trades = core.host:findTable("trades")
    local enum = trades:enumerator()
    while true do
        local row = enum:next()
        if row == nil then
            break
        end
        local valuemap
        valuemap = core.valuemap()

        if CanClose then
            valuemap.OrderType = "CM"
            valuemap.TradeID = row.TradeID
        else
            valuemap.OrderType = "OM"
        end

        valuemap.OfferID = row.OfferID
        valuemap.AcctID = row.AccountID
        valuemap.Quantity = row.Lot
        valuemap.CustomID = row.QTXT
        if row.BS == "B" then
            valuemap.BuySell = "S"
        else
            valuemap.BuySell = "B"
        end
        success, msg = terminal:execute(200, valuemap)
        assert(success, msg)
    end
end

function ExtUpdate(id, source, period)
    if not instance.parameters.AllowTrade then
        return;
    end
    local T = core.dateToTable(core.now())
    local H = T.hour + T.min / 60

    if H >= hours + minutes / 60 then
        if Fl then
            CloseAll()
        end
        Fl = false
    elseif H < hours + minutes / 60 then
        Fl = true
    end
end

function AsyncOperationFinished(cookie, success, message)
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
