-- Id: 18706
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=64933

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

local maxTableCount = 7
function Init() -- The strategy profile initialization
    strategy:name("Account trade Log")
    strategy:description(
        "Strategy dumps selected data from the Accounts Trades and Closed Trades tables at a defined time period to CSV file."
    )

    local accountsArray = {
        "AccountID",
        "AccountName",
        "Balance",
        "Equity",
        "DayPL",
        "UsedMargin",
        "UsableMargin",
        "GrossPL",
        "Kind",
        "MarginCall",
        "IsUnderMarginCall",
        "Hedging"
    }
    local tradesArray = {
        "TradeID",
        "AccountID",
        "AccountName",
        "OfferID",
        "Instrument",
        "Lot",
        "AmountK",
        "BS",
        "Open",
        "Close",
        "Stop",
        "Limit",
        "PL",
        "GrossPL",
        "Com",
        "Int",
        "Time",
        "IsBuy",
        "Kind",
        "QuoteID",
        "OpenOrderID",
        "OpenOrderReqID",
        "QTXT",
        "StopOrderID",
        "LimitOrderID",
        "TradeIDOrigin"
    }
    local closedTradesArray = {
        "TradeID",
        "AccountID",
        "AccountName",
        "OfferID",
        "Instrument",
        "Lot",
        "AmountK",
        "BS",
        "Open",
        "Close",
        "PL",
        "GrossPL",
        "Com",
        "Int",
        "OpenTime",
        "CloseTime",
        "Kind",
        "OpenOrderID",
        "OpenOrderReqID",
        "CloseOrderID",
        "CloseOrderReqID",
        "OQTXT",
        "CQTXT",
        "TradeIDOrigin",
        "TradeIDRemain"
    }
    GenerateTableSelector("Accounts", accountsArray, maxTableCount)
    GenerateTableSelector("Trades", tradesArray, maxTableCount)
    GenerateTableSelector("Closed Trades", closedTradesArray, maxTableCount)

    strategy.parameters:addGroup("Log parameters")
    strategy.parameters:addString("File", "File", "", "")
    strategy.parameters:addString("Separator", "separator", "", ",")
    strategy.parameters:addBoolean("IsMerge", "Merge into one file", "", true)
    strategy.parameters:addString("StartTime", "StartTime", "", "17:00:00")
    strategy.parameters:addString("StopTime", "StopTime", "", "24:00:00")
    strategy.parameters:addInteger("UpdatePeriod", "UpdatePeriod(min)", "", 30, 1, 60)
end
local maxTableCount = 7

function GenerateTableSelector(tableName, columnNames, maxTableColumn)
    local column
    strategy.parameters:addGroup(tableName)
    for column = 1, maxTableColumn do
        GenerateColumnSelector(tableName, columnNames, column)
    end
end

function GenerateColumnSelector(tableName, columnNames, column)
    local columnName = tableName .. "_" .. "Column" .. tostring(column)

    local columnIndex = column % #columnNames
    if columnIndex == 0 then
        columnIndex = 1
    end
    strategy.parameters:addString(columnName, "Column" .. tostring(column), "", columnNames[columnIndex])
    for columnAlt = 1, #columnNames do
        strategy.parameters:addStringAlternative(columnName, columnNames[columnAlt], "", columnNames[columnAlt])
    end
    strategy.parameters:addStringAlternative(columnName, "-", "", "-")
end

local TimerId
local Logging = nil
local StartTime = nil
local StopTime = nil
local LogAccountsColumns = {}
local LogTradesColumns = {}
local LogClosedTradesColumns = {}
local MergeFileHandle = nil
local AccountFileHandle = nil
local TradesFileHandle = nil
local ClosedTradesFileHandle = nil
local IsMerge = nil
local Separator = nil
local isWriteHeaders = false

function Prepare(nameOnly)
    local name
    name = profile:id() .. "( " .. instance.bid:name()

    name =
        name ..
        ", " ..
            instance.parameters.File ..
                ", " ..
                    instance.parameters.StartTime ..
                        ", " .. instance.parameters.StopTime .. ", " .. instance.parameters.UpdatePeriod .. " min"

    name = name .. " )"
    instance:name(name)

    if nameOnly then
        return
    end

    assert(instance.parameters.File ~= "", "Log file not selected, Please select log file ")

    local updatePeriod = instance.parameters.UpdatePeriod * 60
    timerId = core.host:execute("setTimer", 100, updatePeriod)

    StartTime, valid = ParseTime(instance.parameters.StartTime)
    assert(valid, "Time " .. instance.parameters.StartTime .. " is invalid")

    StopTime, valid = ParseTime(instance.parameters.StopTime)
    assert(valid, "Time " .. instance.parameters.StopTime .. " is invalid")

    IsMerge = instance.parameters.IsMerge
    Separator = instance.parameters.Separator

    LogAccountsColumns = FillLogColumns("Accounts")
    LogTradesColumns = FillLogColumns("Trades")
    LogClosedTradesColumns = FillLogColumns("Closed Trades")

    if IsMerge == true then
        MergeFileHandle = io.open(instance.parameters.File .. ".csv", "w")
    else
        local fileName = instance.parameters.File
        AccountFileHandle = io.open(fileName .. "_" .. "accounts" .. ".csv", "w")
        TradesFileHandle = io.open(fileName .. "_" .. "trades" .. ".csv", "w")
        ClosedTradesFileHandle = io.open(fileName .. "_" .. "closed_trades" .. ".csv", "w")
    end

    Logging = false
end

function FillLogColumns(tableName)
    local selectedColumns = {}
    for column = 1, maxTableCount do
        local id = tableName .. "_" .. "Column" .. tostring(column)
        local value = instance.parameters:getString(id)

        if value == "-" then
            return
        end

        selectedColumns[#selectedColumns + 1] = instance.parameters:getString(id)
    end

    return selectedColumns
end

function logMerge(fileHandle, logAccountsColumns, logTradesColumns, logClosedTradesColumns)
    local now = core.host:execute("getServerTime")
    fileHandle:write(core.formatDate(now))
    fileHandle:write("\n")

    fileHandle:write("Accounts")
    fileHandle:write("\n")
    logTable(fileHandle, "accounts", logAccountsColumns)

    fileHandle:write("Trades")
    fileHandle:write("\n")
    logTable(fileHandle, "trades", logTradesColumns)

    fileHandle:write("Closed trades")
    fileHandle:write("\n")
    logTable(fileHandle, "closed trades", logClosedTradesColumns)
end

function logTable(fileHandle, tableName, tableColumns)
    for column = 1, #tableColumns do
        fileHandle:write(tableColumns[column] .. Separator)
    end
    fileHandle:write("\n")

    local enum, row, value
    enum = core.host:findTable(tableName):enumerator()
    row = enum:next()
    while row ~= nil do
        for column = 1, #tableColumns do
            value = row:cell(tableColumns[column])
            fileHandle:write(tostring(value) .. Separator)
        end
        fileHandle:write("\n")
        row = enum:next()
    end
    fileHandle:flush(MergeFileHandle)
end

function log(logAccountsColumns, logTradesColumns, logClosedTradesColumns)
    local now = core.host:execute("getServerTime")

    AccountFileHandle:write(core.formatDate(now))
    AccountFileHandle:write("\n")
    logTable(AccountFileHandle, "accounts", logAccountsColumns)

    TradesFileHandle:write(core.formatDate(now))
    TradesFileHandle:write("\n")
    logTable(TradesFileHandle, "trades", logTradesColumns)

    ClosedTradesFileHandle:write(core.formatDate(now))
    ClosedTradesFileHandle:write("\n")
    logTable(ClosedTradesFileHandle, "closed trades", logClosedTradesColumns)
end

function Update()
    if not (checkReady("trades")) or not (checkReady("orders")) then
        return
    end

    local now = core.host:execute("getServerTime")
    -- get only time
    now = now - math.floor(now)
    -- check whether the time is in the exit time period
    if now >= StartTime and now <= StopTime then
        Logging = true
    else
        Logging = false
    end
end

function AsyncOperationFinished(id, success, msg)
    if id == 100 then
        if Logging == true then
            if IsMerge == true then
                logMerge(MergeFileHandle, LogAccountsColumns, LogTradesColumns, LogClosedTradesColumns)
            else
                log(LogAccountsColumns, LogTradesColumns, LogClosedTradesColumns)
            end
        end
    end
end

function checkReady(table)
    return core.host:execute("isTableFilled", table)
end

function ParseTime(time)
    local pos = string.find(time, ":")
    if pos == nil then
        return nil, false
    end
    local h = tonumber(string.sub(time, 1, pos - 1))
    time = string.sub(time, pos + 1)
    pos = string.find(time, ":")
    if pos == nil then
        return nil, false
    end
    local m = tonumber(string.sub(time, 1, pos - 1))
    local s = tonumber(string.sub(time, pos + 1))
    return (h / 24.0 + m / 1440.0 + s / 86400.0), ((h >= 0 and h < 24 and m >= 0 and m < 60 and s >= 0 and s < 60) or -- time in ole format
        (h == 24 and m == 0 and s == 0)) -- validity flag
end

function InRange(now, openTime, closeTime)
    if openTime < closeTime then
        return now >= openTime and now <= closeTime;
    end
    if openTime > closeTime then
        return now > openTime or now < closeTime;
    end

    return now == openTime;
end
