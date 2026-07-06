-- Id: 6361
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=16112

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

function Init()
    strategy:name("EntryPolylineOrder")
    strategy:description("EntryPolylineOrder")
    strategy:setTag("Version", "1.1")

    strategy.parameters:addString("Name", "Polyline name", "", "1")
    strategy.parameters:addBoolean("Beams", "Use sections as beams", "", false)
    strategy.parameters:addString("Type", "Price type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)
    strategy.parameters:addString("Account", "Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addString("BuySell", "Buy/Sell", "", "B")
    strategy.parameters:addStringAlternative("BuySell", "Buy", "", "B")
    strategy.parameters:addStringAlternative("BuySell", "Sell", "", "S")
    strategy.parameters:addInteger("Amount", "Amount", "", 1)
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false)
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false)
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false)
end

local indicator = nil

local Amount
local BS
local source

-- Routine
function Prepare(nameOnly)
    local name = "EntryPolylineOrder - " .. instance.parameters.Name
    instance:name(name)
    if nameOnly then
        return
    end

    Account = instance.parameters.Account
    Amount = instance.parameters.Amount
    BS = instance.parameters.BuySell
    source = instance.parameters.Type == "Bid" and instance.bid or instance.ask

    Offer = core.host:findTable("offers"):find("Instrument", source:instrument()).OfferID
    BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account)
    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)
    SetLimit = instance.parameters.SetLimit
    Limit = instance.parameters.Limit * instance.bid:pipSize()
    SetStop = instance.parameters.SetStop
    Stop = instance.parameters.Stop * instance.bid:pipSize()
    TrailingStop = instance.parameters.TrailingStop
end

-- strategy calculation routine
function Update()
    if indicator == nil then
        local indiName = "EntryPolyline - " .. instance.parameters.Name
        for i = 0, interop:size() - 1 do
            local ii = interop:instance(i)

            if ii:name() == indiName then
                indicator = ii
            end
        end
        assert(indicator ~= nil, "EntryPolyline - " .. instance.parameters.Name .. " not found")

        local pair = indicator:invoke("GetPair")
        assert(
            pair == instance.bid:instrument(),
            "EntryPolyline - " .. instance.parameters.Name .. " applied to another currency pair"
        )
    end

    if interop:isalive(indicator) then
        Size = source:size()
        if
            indicator:invoke(
                "Crosses",
                source:date(Size - 2),
                source[Size - 2],
                source:date(Size - 1),
                source[Size - 1],
                instance.parameters.Beams
            )
         then
            if instance.parameters.AllowTrade then
                enter(BS)
            end
            core.host:execute("stop")
        end
    end
end

-- -----------------------------------------------------------------------
-- Enter into the specified direction
--  BuySell : direction to enter, shoulde be 'B' for long position or 'S' for short
-- -----------------------------------------------------------------------
function enter(BuySell)
    local valuemap, success, msg

    valuemap = core.valuemap()

    valuemap.OrderType = "OM"
    valuemap.OfferID = Offer
    valuemap.AcctID = Account
    valuemap.Quantity = Amount * BaseSize
    valuemap.BuySell = BuySell
    valuemap.PegTypeStop = "M"

    if SetLimit then
        -- set limit order
        if BuySell == "B" then
            valuemap.RateLimit = instance.ask[NOW] + Limit
        else
            valuemap.RateLimit = instance.bid[NOW] - Limit
        end
    end

    if SetStop then
        -- set limit order
        if BuySell == "B" then
            valuemap.RateStop = instance.ask[NOW] - Stop
        else
            valuemap.RateStop = instance.bid[NOW] + Stop
        end
        if TrailingStop then
            valuemap.TrailStepStop = 1
        end
    end

    if (not CanClose) and (SetStop or SetLimit) then
        valuemap.EntryLimitStop = "Y"
    end

    success, msg = terminal:execute(100, valuemap)

    if not (success) then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            "Open order failed:" .. msg,
            instance.bid:date(instance.bid:size() - 1)
        )
        return false
    end
end
