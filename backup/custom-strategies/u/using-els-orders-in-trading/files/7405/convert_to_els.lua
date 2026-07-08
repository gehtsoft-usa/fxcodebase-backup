-- Id: 2871
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
    strategy:name("Convert Entry to ELS")
    strategy:description("The strategy converts a chosen entry order into ELS")
    strategy:setTag("strategy_type", "Money management");

    strategy.parameters:addString("ORDR", "Choose Order", "", "")
    strategy.parameters:setFlag("ORDR", core.FLAG_ORDER)

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addGroup("Parameters")
    strategy.parameters:addBoolean("SetLimit", "Set Limit Order", "", true)
    strategy.parameters:addInteger("Limit", " Limit Distance in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("SetStop", "Set Stop Order", "", true)
    strategy.parameters:addInteger("Stop", " Stop Distance in pips", "", 30, 1, 10000)
    strategy.parameters:addBoolean("TrailingStop", "  Trailing Stop", "", false)
end

local name
local tid
local doit = true
local deleteit = true

function Prepare(onlyName)
    local name = profile:id() .. "(" .. instance.bid:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    local order = FindOrder()
    assert(order ~= nil, "Order is not found")
    assert(order.Type == "SE" or order.Type == "LE", "Order must be an entry stop or entry limit order")
    assert(order.FixStatus == "W", "The order must be not yet executed")
    assert(order.TypeSL == 1, "The order must not be a pegged order")
    assert(
        not (core.host:execute("getTradingProperty", "canCreateMarketClose", order.Instrument, order.AccountID)),
        "ELS orders are supported for FIFO accounts only"
    )
    assert(instance.parameters.SetLimit or instance.parameters.SetStop, "At least stop or limit order must be attached")

    if instance.parameters.AllowTrade then
        tid = core.host:execute("setTimer", 1, 1)
    end
end

function Update()
end

local neworderid

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 and doit then
        doit = false
        local order = FindOrder()

        if order ~= nil then
            -- 1 fill valuemap to create the order
            local valuemap
            valuemap = core.valuemap()
            valuemap.Command = "CreateOrder"
            valuemap.OrderType = order.Type
            valuemap.OfferID = order.OfferID
            valuemap.AcctID = order.AccountID
            valuemap.Rate = order.Rate
            valuemap.Quantity = order.Lot
            valuemap.BuySell = order.BS

            if instance.parameters.SetStop then
                valuemap.PegTypeStop = "M"
                if order.BS == "B" then
                    valuemap.PegPriceOffsetPipsStop = -instance.parameters.Stop
                else
                    valuemap.PegPriceOffsetPipsStop = instance.parameters.Stop
                end

                if instance.parameters.TrailingStop then
                    valuemap.TrailStepStop = 1
                end
            end

            if instance.parameters.SetLimit then
                valuemap.PegTypeLimit = "M"
                if order.BS == "B" then
                    valuemap.PegPriceOffsetPipsLimit = instance.parameters.Limit
                else
                    valuemap.PegPriceOffsetPipsLimit = -instance.parameters.Limit
                end
            end

            valuemap.EntryLimitStop = "Y"

            local success, msg = terminal:execute(100, valuemap)

            if not (success) then
                ShowMessage("create ELS order failed:" .. msg)
                core.host:execute("stop")
            end
        else
            ShowMessage("Order is not found")
        end
    elseif cookie == 100 then
        if deleteit then
            deleteit = false
            if not (success) then
                ShowMessage("create ELS order failed:" .. message)
                core.host:execute("stop")
            else
                neworderid = message
                local valuemap
                valuemap = core.valuemap()
                valuemap.Command = "DeleteOrder"
                valuemap.OrderID = instance.parameters.ORDR
                local success, msg = terminal:execute(101, valuemap)

                if not (success) then
                    ShowMessage("New order " .. neworderid .. " created. Delete original order failed (1):" .. msg)
                    core.host:execute("stop")
                end
            end
        end
    elseif cookie == 101 then
        if not (success) then
            ShowMessage("New order " .. neworderid .. " created. Delete original order failed (2):" .. message)
        else
            ShowMessage("New order " .. neworderid .. " created. Original order deleted")
        end
        core.host:execute("stop")
    end
end

function FindOrder()
    local row, table
    row = nil
    if core.host:execute("isTableFilled", "orders") then
        table = core.host:findTable("orders")
        if table ~= nil then
            row = table:find("OrderID", instance.parameters.ORDR)
        end
    end
    return row
end

function ShowMessage(msg)
    terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], msg, instance.bid:date(NOW))
end
