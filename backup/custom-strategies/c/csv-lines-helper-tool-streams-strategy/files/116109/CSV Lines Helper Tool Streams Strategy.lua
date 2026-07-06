-- Id: 19760
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=65377

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

function Init()
    strategy:name("CSV Lines Helper Tool Streams Strategy")
    strategy:description("")

    strategy.parameters:addString("TF", "Time frame", "", "m5")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addGroup("CSV Files")
    strategy.parameters:addFile("input_file_1", "CSV File (1)", "", "")
    strategy.parameters:addString("input_file_1_separator", "CSV File Separator (1)", "", ",")
    strategy.parameters:addString("input_file_1_ID", "ID for streams (1)", "", "up")
    strategy.parameters:addFile("input_file_2", "CSV File (2)", "", "")
    strategy.parameters:addString("input_file_2_separator", "CSV File Separator (2)", "", ",")
    strategy.parameters:addString("input_file_2_ID", "ID for streams (2)", "", "down")

    strategy.parameters:addGroup("Price")
    strategy.parameters:addString("Type", "Price Type", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid")
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask")

    strategy.parameters:addGroup("Trading Parameters")
    strategy.parameters:addString("Account", "Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addString(
        "CustomID",
        "Custom Identifier",
        "The identifier that can be used to distinguish strategy instances",
        "CSV Lines Helper Tool Streams Strategy"
    )

    strategy.parameters:addGroup("Strategy Parameters")
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)
    strategy.parameters:addInteger("Amount", "Amount", "", 1, 1, 100)
end

local Account
local BaseSize
local CanClose
local CustomID
local Offer
local Amount
local InicatorName = "CSV LINES HELPER TOOL_STREAMS"
local InicatorInstance = nil

function Prepare(nameOnly)
    local name
    name = profile:id() .. "( " .. instance.bid:name()

    name = name .. ", " .. instance.parameters.TF .. ", " .. instance.parameters.Type

    name = name .. " )"
    instance:name(name)

    if nameOnly then
        return
    end

    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick")

    assert(
        core.indicators:findIndicator(InicatorName) ~= nil,
        "Please, download and install " .. InicatorName .. ".LUA indicator"
    )
    assert(TF ~= "t1", "The time frame must not be tick")

    PrepareTrading()
    Source = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar")

    InicatorInstance =
        core.indicators:create(
        InicatorName,
        Source,
        instance.parameters.input_file_1,
        instance.parameters.input_file_1_separator,
        instance.parameters.input_file_1_ID,
        instance.parameters.input_file_2,
        instance.parameters.input_file_2_separator,
        instance.parameters.input_file_2_ID
    )
end

function PrepareTrading()
    CustomID = instance.parameters.CustomID
    Account = instance.parameters.Account
    BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account)
    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)

    Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID
    Amount = instance.parameters:getInteger("Amount")
end

local Period
local outputStreamsCount
function ExtUpdate(id, source, period) -- The method called every time when a new bid or ask price appears.
    InicatorInstance:update(core.UpdateAll)
    if not instance.parameters.AllowTrade then
        return;
    end

    streamsCount = InicatorInstance:getStreamCount()
    for i = 0, streamsCount - 1 do
        local stream = InicatorInstance:getStream(i)
        if string.find(stream:id(), "up") ~= nil then
            if core.crosses(Source.close, stream, period) == true then
                CreateMarketOrder("B")
            end
        elseif string.find(stream:id(), "down") ~= nil then
            if core.crosses(Source.close, stream, period) == true then
                CreateMarketOrder("S")
            end
        end
    end
end

function ExtAsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 200 then
        if not success then
            terminal:alertMessage(
                instance.bid:instrument(),
                instance.bid[instance.bid:size() - 1],
                " Open order failed " .. message,
                instance.bid:date(instance.bid:size() - 1)
            )
        end
    end
end

function CreateMarketOrder(side)
    local valuemap, success, msg
    valuemap = core.valuemap()

    valuemap.Command = "CreateOrder"
    valuemap.OrderType = "OM"
    valuemap.OfferID = Offer
    valuemap.AcctID = Account
    valuemap.BuySell = side
    valuemap.Quantity = Amount * BaseSize
    valuemap.CustomID = CustomID

    success, msg = terminal:execute(200, valuemap)

    if not (success) then
        terminal:alertMessage(
            instance.bid:instrument(),
            instance.bid[instance.bid:size() - 1],
            " Open order failed " .. msg,
            instance.bid:date(instance.bid:size() - 1)
        )
        return false
    end

    return msg
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
