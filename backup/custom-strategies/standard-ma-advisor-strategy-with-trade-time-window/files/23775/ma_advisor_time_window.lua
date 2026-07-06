-- Id: 5952
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=11909

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
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
    strategy:name(resources:get("R_NAME"))
    strategy:description(resources:get("R_DESCRIPTION"))
    strategy:setTag("group", "Moving Averages")
    strategy:setTag("Version", "1.1")
    strategy:setTag("NonOptimizableParameters", "EMAIL,SENDEMAIL,SOUND,RECURRENTSOUND,PLAY")
    strategy:type(core.Both)

    strategy.parameters:addGroup(resources:get("R_PARAMS_FMA"))
    strategy.parameters:addString("FMA_M", resources:get("R_MA_METHOD"), resources:get("R_MA_METHOD_D"), "MVA")
    strategy.parameters:addStringAlternative("FMA_M", "MVA", "", "MVA")
    strategy.parameters:addStringAlternative("FMA_M", "EMA", "", "EMA")
    strategy.parameters:addStringAlternative("FMA_M", "LWMA", "", "LWMA")
    strategy.parameters:addStringAlternative("FMA_M", "TMA", "", "TMA")
    strategy.parameters:addStringAlternative("FMA_M", "SMMA*", "", "SMMA")
    strategy.parameters:addStringAlternative("FMA_M", "Vidya (1995)*", "", "VIDYA")
    strategy.parameters:addStringAlternative("FMA_M", "Vidya (1992)*", "", "VIDYA92")
    strategy.parameters:addStringAlternative("FMA_M", "Wilders*", "", "WMA")
    strategy.parameters:addStringAlternative("FMA_M", "TEMA*", "", "TEMA1")
    strategy.parameters:addInteger("FMA_N", resources:get("R_MA_N"), "", 5, 1, 300)
    strategy.parameters:addInteger("FMA_S", resources:get("R_MA_S"), resources:get("R_MA_S_D"), 0, 0, 300)
    strategy.parameters:addString("FMA_P", resources:get("R_MA_P"), "", "C")
    strategy.parameters:addStringAlternative("FMA_P", resources:get("R_MA_P_OPEN"), "", "O")
    strategy.parameters:addStringAlternative("FMA_P", resources:get("R_MA_P_HIGH"), "", "H")
    strategy.parameters:addStringAlternative("FMA_P", resources:get("R_MA_P_LOW"), "", "L")
    strategy.parameters:addStringAlternative("FMA_P", resources:get("R_MA_P_CLOSE"), "", "C")
    strategy.parameters:addStringAlternative("FMA_P", resources:get("R_MA_P_MEDIAN"), "", "M")
    strategy.parameters:addStringAlternative("FMA_P", resources:get("R_MA_P_TYPICAL"), "", "T")
    strategy.parameters:addStringAlternative("FMA_P", resources:get("R_MA_P_WEIGHTED"), "", "W")

    strategy.parameters:addGroup(resources:get("R_PARAMS_SMA"))
    strategy.parameters:addString("SMA_M", resources:get("R_MA_METHOD"), resources:get("R_MA_METHOD_D"), "MVA")
    strategy.parameters:addStringAlternative("SMA_M", "MVA", "", "MVA")
    strategy.parameters:addStringAlternative("SMA_M", "EMA", "", "EMA")
    strategy.parameters:addStringAlternative("SMA_M", "LWMA", "", "LWMA")
    strategy.parameters:addStringAlternative("SMA_M", "TMA", "", "TMA")
    strategy.parameters:addStringAlternative("SMA_M", "SMMA*", "", "SMMA")
    strategy.parameters:addStringAlternative("SMA_M", "Vidya (1995)*", "", "VIDYA")
    strategy.parameters:addStringAlternative("SMA_M", "Vidya (1992)*", "", "VIDYA92")
    strategy.parameters:addStringAlternative("SMA_M", "Wilders*", "", "WMA")
    strategy.parameters:addStringAlternative("SMA_M", "TEMA*", "", "TEMA1")
    strategy.parameters:addInteger("SMA_N", resources:get("R_MA_N"), "", 20, 1, 300)
    strategy.parameters:addInteger("SMA_S", resources:get("R_MA_S"), resources:get("R_MA_S_D"), 0, 0, 300)
    strategy.parameters:addString("SMA_P", resources:get("R_MA_P"), "", "C")
    strategy.parameters:addStringAlternative("SMA_P", resources:get("R_MA_P_OPEN"), "", "O")
    strategy.parameters:addStringAlternative("SMA_P", resources:get("R_MA_P_HIGH"), "", "H")
    strategy.parameters:addStringAlternative("SMA_P", resources:get("R_MA_P_LOW"), "", "L")
    strategy.parameters:addStringAlternative("SMA_P", resources:get("R_MA_P_CLOSE"), "", "C")
    strategy.parameters:addStringAlternative("SMA_P", resources:get("R_MA_P_MEDIAN"), "", "M")
    strategy.parameters:addStringAlternative("SMA_P", resources:get("R_MA_P_TYPICAL"), "", "T")
    strategy.parameters:addStringAlternative("SMA_P", resources:get("R_MA_P_WEIGHTED"), "", "W")

    strategy.parameters:addString("BeginTime", "Begin valid time for operations with orders", "", "10:00:00")
    strategy.parameters:addString("EndTime", "End valid time for operations with orders", "", "12:00:00")
    strategy.parameters:addBoolean("CloseAtEnd", "Close orders at time of end", "", true)

    strategy.parameters:addGroup(resources:get("R_PARAMS_PRICE"))
    strategy.parameters:addString("TF", resources:get("R_TF"), "", "H1")
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

    strategy.parameters:addString("TYPE", resources:get("R_PriceType"), "", "Bid")
    strategy.parameters:addStringAlternative("TYPE", resources:get("R_BID"), "", "Bid")
    strategy.parameters:addStringAlternative("TYPE", resources:get("R_ASK"), "", "Ask")

    strategy.parameters:addGroup(resources:get("R_Trading_ParamGroup"))
    strategy.parameters:addBoolean("CANTRADE", resources:get("R_AllowTrade"), resources:get("R_TR_ALLOWED_D"), false)
    strategy.parameters:setFlag("CANTRADE", core.FLAG_ALLOW_TRADE)
    strategy.parameters:addString("ACCOUNT", resources:get("R_Account2Trade"), "", "")
    strategy.parameters:setFlag("ACCOUNT", core.FLAG_ACCOUNT)
    strategy.parameters:addString(
        "ALLOWEDSIDE",
        resources:get("R_ALLOWEDSIDE"),
        resources:get("R_ALLOWEDSIDE_D"),
        "Both"
    )
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", resources:get("R_BOTH"), "", "Both")
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", resources:get("R_BUY"), "", "Buy")
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", resources:get("R_SELL"), "", "Sell")

    strategy.parameters:addInteger("AMOUNT", resources:get("R_AMOUNT"), "", 1, 1, 100)
    strategy.parameters:addInteger("LIMIT", resources:get("R_TR_L"), resources:get("R_TR_L_D"), 0, 0, 300)
    strategy.parameters:addInteger("STOP", resources:get("R_TR_S"), resources:get("R_TR_S_D"), 0, 0, 300)
    strategy.parameters:addBoolean("USE_TRAILING_STOP", resources:get("R_USE_TRAILING_STOP"), "", true)
    strategy.parameters:addBoolean("PLAY", resources:get("R_PlaySound"), "", false)
    strategy.parameters:addBoolean("RECURRENTSOUND", resources:get("R_RecurrentSound"), "", false)
    strategy.parameters:addFile("SOUND", resources:get("R_SoundFile"), "", "")
    strategy.parameters:setFlag("SOUND", core.FLAG_SOUND)
    strategy.parameters:addBoolean("SENDEMAIL", resources:get("R_SENDEMAIL"), "", false)
    strategy.parameters:addString("EMAIL", resources:get("R_EMAILADDRESS"), resources:get("R_EMAILADDRESSDESCR"), "")
    strategy.parameters:setFlag("EMAIL", core.FLAG_EMAIL)
end

-- check parameters and set advisor name
local name
local BeginT, EndT

function Prepare(onlyName)
    -- set the name
    name =
        profile:id() ..
        "(" ..
            instance.bid:instrument() ..
                "." ..
                    instance.parameters.TF ..
                        "." ..
                            instance.parameters.TYPE ..
                                "," ..
                                    instance.parameters.FMA_M ..
                                        "(" ..
                                            instance.parameters.FMA_P ..
                                                "," ..
                                                    instance.parameters.FMA_N ..
                                                        "," ..
                                                            instance.parameters.FMA_S ..
                                                                ")," ..
                                                                    instance.parameters.SMA_M ..
                                                                        "(" ..
                                                                            instance.parameters.SMA_P ..
                                                                                "," ..
                                                                                    instance.parameters.SMA_N ..
                                                                                        "," ..
                                                                                            instance.parameters.SMA_S ..
                                                                                                "))"
    instance:name(name)
    if onlyName then
        return
    end

    assert(
        core.indicators:findIndicator(instance.parameters.FMA_M) ~= nil,
        "Please, download and install " .. instance.parameters.FMA_M .. ".LUA indicator"
    )
    assert(
        core.indicators:findIndicator(instance.parameters.SMA_M) ~= nil,
        "Please, download and install " .. instance.parameters.SMA_M .. ".LUA indicator"
    )

    -- check time frame
    assert(instance.parameters.TF ~= "t1", resources:get("R_ERROR_TICK"))
    -- check sound alert params
    assert(
        not (instance.parameters.PLAY) or (instance.parameters.PLAY and instance.parameters.SOUND ~= ""),
        resources:get("R_SoundFileError")
    )
    -- check trading params
    if instance.parameters.CANTRADE then
        assert(
            core.host:findTable("Accounts"):find("AccountID", instance.parameters.ACCOUNT) ~= nil,
            resources:get("R_ERROR_ACCOUNT")
        )
        assert(
            core.host:findTable("offers"):find("Instrument", instance.bid:instrument()) ~= nil,
            resources:get("R_ERROR_OFFER")
        )
    end

    local BeginTime = instance.parameters.BeginTime
    local Pos = string.find(BeginTime, ":")
    local BeginH = tonumber(string.sub(BeginTime, 1, Pos - 1))
    BeginTime = string.sub(BeginTime, Pos + 1)
    Pos = string.find(BeginTime, ":")
    local BeginM = tonumber(string.sub(BeginTime, 1, Pos - 1))
    local BeginS = tonumber(string.sub(BeginTime, Pos + 1))
    BeginT = 3600 * BeginH + 60 * BeginM + BeginS

    local EndTime = instance.parameters.EndTime
    local Pos = string.find(EndTime, ":")
    local EndH = tonumber(string.sub(EndTime, 1, Pos - 1))
    EndTime = string.sub(EndTime, Pos + 1)
    Pos = string.find(EndTime, ":")
    local EndM = tonumber(string.sub(EndTime, 1, Pos - 1))
    local EndS = tonumber(string.sub(EndTime, Pos + 1))
    EndT = 3600 * EndH + 60 * EndM + EndS
    -- check methods
    assert(core.indicators:findIndicator(instance.parameters.FMA_M) ~= nil, resources:get("R_ERROR_METHOD"))
    assert(core.indicators:findIndicator(instance.parameters.SMA_M) ~= nil, resources:get("R_ERROR_METHOD"))
end

-- global data block start
local init = false
local loaded = false
local priorbar = nil

-- price and MVA data (indicator, data and shift)
local TICKSRC
local SRC
local SMA, SMADATA, SMASHIFT
local FMA, FMADATA, FMASHIFT

-- trade data
local OFFER
local CANTRADE
local ACCOUNT
local AMOUNT
local PLAY
local RECURRENTSOUND
local SOUND
local LIMIT
local STOP
local SELL
local BUY
local CANCLOSE
local SENDEMAIL
local EMAIL
local ALLOWEDSIDE
local CID = "MACROSS"
local USE_TRAILING_STOP

-- global data block end
function Update()
    if not (init) then
        TICKSRC = instance.bid
        -- collect the trading parameters
        CANTRADE = instance.parameters.CANTRADE
        if CANTRADE then
            ACCOUNT = instance.parameters.ACCOUNT
            USE_TRAILING_STOP = instance.parameters.USE_TRAILING_STOP
            AMOUNT =
                instance.parameters.AMOUNT *
                core.host:execute("getTradingProperty", "baseUnitSize", TICKSRC:instrument(), ACCOUNT)
            LIMIT = math.floor(instance.parameters.LIMIT + 0.5)
            STOP = math.floor(instance.parameters.STOP + 0.5)
            OFFER = core.host:findTable("offers"):find("Instrument", TICKSRC:instrument()).OfferID
            CANCLOSE = core.host:execute("getTradingProperty", "canCreateMarketClose", TICKSRC:instrument(), ACCOUNT)
        end
        ALLOWEDSIDE = instance.parameters.ALLOWEDSIDE
        SELL = resources:get("R_SELL")
        BUY = resources:get("R_BUY")
        PLAY = instance.parameters.PLAY
        SOUND = instance.parameters.SOUND
        RECURRENTSOUND = instance.parameters.RECURRENTSOUND

        SENDEMAIL = instance.parameters.SENDEMAIL
        EMAIL = instance.parameters.EMAIL

        -- load the price data
        SRC =
            core.host:execute(
            "getHistory",
            1,
            TICKSRC:instrument(),
            instance.parameters.TF,
            0,
            0,
            instance.parameters.TYPE == "Bid"
        )
        FMA, FMADATA = CreateMA(instance.parameters.FMA_M, instance.parameters.FMA_N, instance.parameters.FMA_P, SRC)
        SMA, SMADATA = CreateMA(instance.parameters.SMA_M, instance.parameters.SMA_N, instance.parameters.SMA_P, SRC)
        FMASHIFT = instance.parameters.FMA_S
        SMASHIFT = instance.parameters.SMA_S
        init = true
        return
    end

    -- return if the data is not loaded yet
    if not (loaded) or SRC:size() < 2 then
        return
    end

    -- the index of the bar to be processed
    local p = SRC:size() - 2

    -- check if the same bar is still updating
    if priorbar ~= nil and SRC:serial(p) == priorbar then
        return
    end

    -- remember the last processed bar
    priorbar = SRC:serial(p)

    -- update moving average
    FMA:update(core.UpdateLast)
    SMA:update(core.UpdateLast)

    -- check whether here is enough data to check the
    -- signal conditions
    if p <= FMADATA:first() + FMASHIFT or p <= SMADATA:first() + SMASHIFT then
        return
    end

    local CVT = CheckValidTime(p)
    local MustCloseOrders = CheckCloseTime(p)
    if MustCloseOrders then
        close("B")
        close("S")
    end

    if
        core.crossesOver(FMADATA, SMADATA, p - FMASHIFT, p - SMASHIFT) and
            (ALLOWEDSIDE == "Both" or ALLOWEDSIDE == "Buy") and
            CVT
     then
        -- buy condition met (fast crosses over slow)
        if CANTRADE then
            close("S") -- closes all existing shorts on the account
            enter("B") -- and the enter long
        end
        terminal:alertMessage(TICKSRC:instrument(), TICKSRC[NOW], name .. ":" .. BUY, TICKSRC:date(NOW))
        if PLAY then
            terminal:alertSound(SOUND, RECURRENTSOUND)
        end

        if SENDEMAIL then
            terminal:alertEmail(EMAIL, name .. ":" .. BUY, FormatEmail(TICKSRC, NOW, BUY))
        end
    elseif
        core.crossesUnder(FMADATA, SMADATA, p - FMASHIFT, p - SMASHIFT) and
            (ALLOWEDSIDE == "Both" or ALLOWEDSIDE == "Sell") and
            CVT
     then
        -- sell condition met (slow crosses over fast)
        if CANTRADE then
            close("B") -- closes all existing longs on the account
            enter("S") -- and the enter short
        end
        terminal:alertMessage(TICKSRC:instrument(), TICKSRC[NOW], name .. ":" .. SELL, TICKSRC:date(NOW))
        if PLAY then
            terminal:alertSound(SOUND, RECURRENTSOUND)
        end

        if SENDEMAIL then
            terminal:alertEmail(EMAIL, name .. ":" .. SELL, FormatEmail(TICKSRC, NOW, SELL))
        end
    end
end

-- creates moving average with the specified parameters for the specified price
function CreateMA(method, n, price, src)
    local p
    if price == "O" then
        p = src.open
    elseif price == "H" then
        p = src.high
    elseif price == "L" then
        p = src.low
    elseif price == "M" then
        p = src.median
    elseif price == "T" then
        p = src.typical
    elseif price == "W" then
        p = src.weighted
    else
        p = src.close
    end

    assert(core.indicators:findIndicator(method) ~= nil, method .. " indicator must be installed");
    local indicator = core.indicators:create(method, p, n)
    return indicator, indicator.DATA
end

-- closes all positions of the specified direction (B for buy, S for sell)
function close(side)
    local enum, row, valuemap

    enum = core.host:findTable("trades"):enumerator()
    while true do
        row = enum:next()
        if row == nil then
            break
        end
        if row.AccountID == ACCOUNT and row.OfferID == OFFER and row.BS == side and row.QTXT == CID then
            -- if trade has to be closed

            if CANCLOSE then
                -- non-FIFO account, create a close market order
                valuemap = core.valuemap()
                valuemap.OrderType = "CM"
                valuemap.OfferID = OFFER
                valuemap.AcctID = ACCOUNT
                valuemap.Quantity = row.Lot
                valuemap.TradeID = row.TradeID
                valuemap.CustomID = CID
                if row.BS == "B" then
                    valuemap.BuySell = "S"
                else
                    valuemap.BuySell = "B"
                end
                success, msg = terminal:execute(200, valuemap)
                assert(success, msg)
            else
                -- FIFO account, create an opposite market order
                valuemap = core.valuemap()
                valuemap.OrderType = "OM"
                valuemap.OfferID = OFFER
                valuemap.AcctID = ACCOUNT
                valuemap.Quantity = AMOUNT
                valuemap.CustomID = CID
                if row.BS == "B" then
                    valuemap.BuySell = "S"
                else
                    valuemap.BuySell = "B"
                end
                success, msg = terminal:execute(200, valuemap)
                assert(success, msg)
            end
        end
    end
end

function CheckValidTime(period)
    local d, t
    d, t = SRC:date(period)
    local table = core.dateToTable(d)
    local CurTime = table.hour * 3600 + table.min * 60 + table.sec
    if
        (BeginT < EndT and CurTime > BeginT and CurTime < EndT) or
            (BeginT > EndT and (CurTime > BeginT or CurTime < EndT))
     then
        return true
    else
        return false
    end
end

function CheckCloseTime(period)
    if instance.parameters.CloseAtEnd == true then
        if CheckValidTime(period) then
            return false
        else
            return true
        end
    end
    return false
end

-- the method enters to the market
function enter(side)
    local valuemap

    valuemap = core.valuemap()
    valuemap.OrderType = "OM"
    valuemap.OfferID = OFFER
    valuemap.AcctID = ACCOUNT
    valuemap.Quantity = AMOUNT
    valuemap.CustomID = CID
    valuemap.BuySell = side
    if STOP >= 1 then
        valuemap.PegTypeStop = "O"
        if side == "B" then
            valuemap.PegPriceOffsetPipsStop = -STOP
        else
            valuemap.PegPriceOffsetPipsStop = STOP
        end
        if USE_TRAILING_STOP then
            valuemap.TrailStepStop = 1
        end
    end
    if LIMIT >= 1 then
        valuemap.PegTypeLimit = "O"
        if side == "B" then
            valuemap.PegPriceOffsetPipsLimit = LIMIT
        else
            valuemap.PegPriceOffsetPipsLimit = -LIMIT
        end
    end

    if (not CANCLOSE) and (STOP >= 1 or LIMIT >= 1) then
        valuemap.EntryLimitStop = "Y"
    end

    success, msg = terminal:execute(200, valuemap)
    assert(success, msg)
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 then
        loaded = true
        priorbar = SRC:serial(SRC:size() - 2)
    elseif cookie == 200 then
        assert(success, message)
    end
end

local emailInit = false
local delim
local signalDescr
local symbolDescr
local messageDescr
local dateDescr
local priceDescr
local introDescr
local priceFormat
-- ---------------------------------------------------------
-- Formats the email subject and text
-- @param source   The signal source
-- @param period    The number of the period
-- @param message   The rest of the message to be added to the signal
-- ---------------------------------------------------------
function FormatEmail(source, period, message)
    --format email text
    if not (emailInit) then
        emailInit = true
        delim = "\013\010"
        signalDescr = resources:get("R_MailSignalHeader")
        symbolDescr = resources:get("R_MailSymbolHeader")
        messageDescr = resources:get("R_MailMessageHeader")
        dateDescr = resources:get("R_MailTimeHeader")
        priceDescr = resources:get("R_MailPriceHeader")
        introDescr = resources:get("R_MailIntroduction")
        priceFormat = "%." .. instance.bid:getPrecision() .. "f"
    end
    local ttime =
        core.dateToTable(
        core.host:execute("convertTime", 1, 4, math.max(instance.bid:date(NOW), instance.ask:date(NOW)))
    )

    local r =
        delim ..
        introDescr ..
            delim ..
                signalDescr ..
                    name ..
                        delim ..
                            symbolDescr ..
                                instance.bid:instrument() ..
                                    delim ..
                                        messageDescr ..
                                            message ..
                                                delim ..
                                                    dateDescr ..
                                                        string.format(
                                                            "%02i/%02i %02i:%02i",
                                                            ttime.month,
                                                            ttime.day,
                                                            ttime.hour,
                                                            ttime.min
                                                        ) ..
                                                            delim ..
                                                                priceDescr ..
                                                                    string.format(priceFormat, source[period]) .. delim
    return r
end
