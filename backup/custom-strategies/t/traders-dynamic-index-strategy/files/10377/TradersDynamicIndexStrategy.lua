-- Id: 3834
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=4134

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
    strategy:name("Trades the Traders Dynamic Index Indicator data")
    strategy:description("Implements scalping, active and moderate trading strategies for the Traders Index Indicator")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")

    strategy.parameters:addGroup("Traders Dynamic Index Calculation")

    strategy.parameters:addInteger("RSI_N", "RSI Periods", "Recommended values are in 8-25 range", 13, 2, 1000)
    strategy.parameters:addInteger(
        "VB_N",
        "Volatility Band",
        "Number of periods to find volatility band. Recommended value is 20-40",
        34,
        2,
        1000
    )
    strategy.parameters:addDouble("VB_W", "Volatility Band Width", "", 1.6185, 0, 100)

    strategy.parameters:addInteger("RSI_P_N", "RSI Price Line Periods", "", 2, 1, 1000)
    strategy.parameters:addString("RSI_P_M", "RSI Price Line Smoothing Method", "", "MVA")
    strategy.parameters:addStringAlternative("RSI_P_M", "MVA(SMA)", "", "MVA")
    strategy.parameters:addStringAlternative("RSI_P_M", "EMA", "", "EMA")
    strategy.parameters:addStringAlternative("RSI_P_M", "LWMA", "", "LWMA")
    strategy.parameters:addStringAlternative("RSI_P_M", "LSMA(Regression)", "", "REGRESSION")
    strategy.parameters:addStringAlternative("RSI_P_M", "SMMA", "", "SMMA")
    strategy.parameters:addStringAlternative("RSI_P_M", "WMA(Wilders)", "", "WMA")
    strategy.parameters:addStringAlternative("RSI_P_M", "KAMA(Kaufman)", "", "KAMA")

    strategy.parameters:addInteger("TS_N", "Trade Signal Line Periods", "", 7, 1, 1000)
    strategy.parameters:addString("TS_M", "Trade Signal Line Smoothing Method", "", "MVA")
    strategy.parameters:addStringAlternative("TS_M", "MVA(SMA)", "", "MVA")
    strategy.parameters:addStringAlternative("TS_M", "EMA", "", "EMA")
    strategy.parameters:addStringAlternative("TS_M", "LWMA", "", "LWMA")
    strategy.parameters:addStringAlternative("TS_M", "LSMA(Regression)", "", "REGRESSION")
    strategy.parameters:addStringAlternative("TS_M", "SMMA", "", "SMMA")
    strategy.parameters:addStringAlternative("TS_M", "WMA(Wilders)", "", "WMA")
    strategy.parameters:addStringAlternative("TS_M", "KAMA(Kaufman)", "", "KAMA")

    strategy.parameters:addGroup("Levels")
    strategy.parameters:addInteger("L1", "Low Level", "", 32, 0, 100)
    strategy.parameters:addInteger("L2", "Middle Level", "", 50, 0, 100)
    strategy.parameters:addInteger("L3", "High Level", "", 68, 0, 100)

    strategy.parameters:addGroup("Price")
    strategy.parameters:addString("TF", "Target Timeframe", "", "H1")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)
    strategy.parameters:addString("T", "Target Price", "", "close")
    strategy.parameters:addStringAlternative("T", "Open", "", "open")
    strategy.parameters:addStringAlternative("T", "High", "", "high")
    strategy.parameters:addStringAlternative("T", "Low", "", "low")
    strategy.parameters:addStringAlternative("T", "Close", "", "close")
    strategy.parameters:addStringAlternative("T", "Median", "", "median")
    strategy.parameters:addStringAlternative("T", "Typical", "", "typical")
    strategy.parameters:addStringAlternative("T", "Weighed", "", "weighted")

    strategy.parameters:addGroup("Trading")
    strategy.parameters:addInteger("S", "Strategy", "", 2)
    strategy.parameters:addIntegerAlternative("S", "Scaliping", "", 0)
    strategy.parameters:addIntegerAlternative("S", "Active", "", 1)
    strategy.parameters:addIntegerAlternative("S", "Moderate", "", 2)

    strategy.parameters:addInteger("BM", "Bar Mode", "", 0)
    strategy.parameters:addIntegerAlternative("BM", "On Closed Bar", "", 0)
    strategy.parameters:addIntegerAlternative("BM", "On Active Bar", "", 1)

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)

    strategy.parameters:addString("Account", "Choose Account to trade on", "", "")
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
    strategy.parameters:addInteger("Amount", "Trading amount (in lots)", "", 1, 1, 100)

    strategy.parameters:addGroup("Alert")
    strategy.parameters:addBoolean("ShowAlert", "Show Alerts", "", false)
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false)
    strategy.parameters:addFile("SoundFile", "  Sound File", "", "")
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND)
    strategy.parameters:addBoolean("RecurrentSound", "  Recurrent Sound", "", false)
end

local ShowAlert, PlaySound, SoundFile, RecurrentSound
local AllowTrade, OfferID, AccountID, LotSize, Instrument
local Price, ATDI, E, X
local loaded = false
local BarMode, LastSerial, first
local name
local BaseSize
function Prepare(onlyName)
    assert(
        core.indicators:findIndicator("TRADERSDYNAMICINDEX") ~= nil,
        "Please download and install TradersDynamicIndex.lua indicator"
    )
    assert(
        core.indicators:findIndicator("ANALYZETRADERSDYNAMICINDEX") ~= nil,
        "Please download and install AnalyzeTradersDynamicIndex.lua indicator"
    )
    assert(instance.parameters.TF ~= "t1", "The strategy cannot be applied on ticks")
    assert(
        not (instance.parameters.PlaySound) or
            (instance.parameters.PlaySound and instance.parameters.SoundFile ~= "" and
                instance.parameters.SoundFile ~= nil),
        "The sound file must be chosen"
    )

    local sn

    if instance.parameters.S == 0 then
        sn = "Scalping"
    elseif instance.parameters.S == 1 then
        sn = "Active"
    else
        sn = "Moderate"
    end

    name =
        profile:id() ..
        "(" ..
            instance.bid:instrument() ..
                "[" ..
                    instance.parameters.TF ..
                        "]" ..
                            "." ..
                                instance.parameters.T ..
                                    "," ..
                                        sn ..
                                            "," ..
                                                instance.parameters.RSI_N ..
                                                    "," ..
                                                        instance.parameters.VB_N ..
                                                            "," ..
                                                                instance.parameters.VB_W ..
                                                                    "," ..
                                                                        instance.parameters.RSI_P_N ..
                                                                            "," ..
                                                                                instance.parameters.RSI_P_M ..
                                                                                    "," ..
                                                                                        instance.parameters.TS_N ..
                                                                                            "," ..
                                                                                                instance.parameters.TS_M ..
                                                                                                    ")"
    instance:name(name)

    if onlyName then
        return
    end

    ShowAlert = instance.parameters.ShowAlert
    PlaySound = instance.parameters.PlaySound

    if PlaySound then
        SoundFile = instance.parameters.SoundFile
        RecurrentSound = instance.parameters.RecurrentSound
    end

    AllowTrade = instance.parameters.AllowTrade
    Instrument = instance.bid:instrument()

    if AllowTrade then
        AccountID = instance.parameters.Account
        BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), AccountID)
        Amount = instance.parameters.Amount * BaseSize
        OfferID = core.host:findTable("offers"):find("Instrument", Instrument).OfferID
    end

    Price = core.host:execute("getHistory", 1, Instrument, instance.parameters.TF, 0, 0, true)

    local pTDI = core.indicators:findIndicator("ANALYZETRADERSDYNAMICINDEX")
    local p = pTDI:parameters()

    p:setInteger("RSI_N", instance.parameters.RSI_N)
    p:setInteger("VB_N", instance.parameters.VB_N)
    p:setDouble("VB_W", instance.parameters.VB_W)
    p:setInteger("RSI_P_N", instance.parameters.RSI_P_N)
    p:setString("RSI_P_M", instance.parameters.RSI_P_M)
    p:setInteger("TS_N", instance.parameters.TS_N)
    p:setString("TS_M", instance.parameters.TS_M)
    p:setInteger("L1", instance.parameters.L1)
    p:setInteger("L2", instance.parameters.L2)
    p:setInteger("L3", instance.parameters.L3)
    p:setInteger("S", instance.parameters.S)
    p:setString("T", instance.parameters.T)
    ATDI = pTDI:createInstance(Price, p)
    E = ATDI.E
    X = ATDI.X
    first = math.max(E:first(), X:first()) + 1

    BarMode = instance.parameters.BM
end

function Update()
    local period

    if not loaded then
        return
    end

    period = Price:size() - 1

    if BarMode == 1 and period < first then
        -- work on current bar, not enough data
        return
    end

    if BarMode == 0 then
        -- work on closed bar
        if LastSerial == nil then
            -- first tick received, ignore the current bar
            LastSerial = Price:serial(period)
            return
        elseif LastSerial == Price:serial(period) then
            -- this bar has been already processed
            return
        else
            -- the first tick of a new bar
            LastSerial = Price:serial(period)
            period = period - 1
        end
    end

    ATDI:update(core.UpdateLast)

    -- check exit condition
    if X[period] > 0.1 then
        -- exit long
        ExitLong()
    elseif X[period] < -0.1 then
        ExitShort()
    -- exit shorts
    end

    -- check entry codition
    if E[period] > 0.1 and E[period - 1] <= 0 then
        EnterLong()
    elseif E[period] < -0.1 and E[period - 1] >= 0 then
        EnterShort()
    end
end

function ExitLong()
    Alert("Exit Long", false)
    if AllowTrade then
        Exit("B")
    end
end

function ExitShort()
    Alert("Exit Short", false)
    if AllowTrade then
        Exit("S")
    end
end

function EnterLong()
    Alert("Enter Long", false)
    if AllowTrade then
        Exit("S")
        Enter("B")
    end
end

function EnterShort()
    Alert("Enter Short", false)
    if AllowTrade then
        Exit("B")
        Enter("S")
    end
end

function Alert(msg, errorAlert)
    if ShowAlert or errorAlert then
        terminal:alertMessage(Instrument, instance.bid[NOW], name .. ":" .. msg, instance.bid:date(NOW))
    end

    if PlaySound and not errorAlert then
        terminal:alertSound(SoundFile, RecurrentSound)
    end
end

function Exit(side)
    if not hasPosition(side) then
        return
    end

    local msg, valuemap

    valuemap = core.valuemap()
    valuemap.OrderType = "CM"
    valuemap.OfferID = OfferID
    valuemap.AcctID = AccountID
    if side == "B" then
        valuemap.BuySell = "S"
    else
        valuemap.BuySell = "B"
    end
    valuemap.NetQtyFlag = "y"
    success, msg = terminal:execute(101, valuemap)
    if not success then
        Alert("Close Order Failed:" .. msg, true)
    end
end

function Enter(side)
    if hasPosition(side) then
        return
    end

    local msg, valuemap

    valuemap = core.valuemap()
    valuemap.OrderType = "OM"
    valuemap.OfferID = OfferID
    valuemap.AcctID = AccountID
    valuemap.Quantity = Amount
    valuemap.BuySell = side
    success, msg = terminal:execute(100, valuemap)
    if not success then
        Alert("Open Order Failed:" .. msg, true)
    end
end

function hasPosition(side)
    local enum = core.host:findTable("trades"):enumerator()
    local row

    while true do
        row = enum:next()
        if row == nil then
            break
        end
        if row.AccountID == AccountID and row.OfferID == OfferID and row.BS == side then
            return true
        end
    end

    return false
end

function AsyncOperationFinished(cookie, success, msg)
    if cookie == 1 then
        loaded = true
    elseif cookie == 100 then
        if not success then
            Alert("Open Order Failed:" .. msg, true)
        end
    elseif cookie == 101 then
        if not success then
            Alert("Close Order Failed:" .. msg, true)
        end
    end
end
