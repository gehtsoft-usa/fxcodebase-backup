-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=611
-- Id: 1395

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("Shows the market indexes")
    indicator:description(
        "Shows the market indexes in day, week or month resolution. The data is loaded from yahoo.finance"
    )
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addString("IDX", "Choose the Index", "", "^DJI")
    indicator.parameters:addStringAlternative("IDX", "Dow Jones", "", "^DJI")
    indicator.parameters:addStringAlternative("IDX", "NASDAQ", "", "^IXIC")
    indicator.parameters:addStringAlternative("IDX", "S&P 500", "", "^GSPC")
    indicator.parameters:addStringAlternative("IDX", "FTSE 100", "", "^FTSE")
    indicator.parameters:addStringAlternative("IDX", "10 Year bonds", "", "^TNX")
    indicator.parameters:addStringAlternative("IDX", "Bel-20", "", "^BFX")
    indicator.parameters:addStringAlternative("IDX", "CAC 40", "", "^FCHI")
    indicator.parameters:addStringAlternative("IDX", "Custom", "", "_")
    indicator.parameters:addString(
        "IDX1",
        "Custom instrument",
        "Enter the instrument here in case Custom is chosen above",
        ""
    )
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
local IDX
local RES

local first
local source = nil

-- Streams block
local O = nil
local H = nil
local L = nil
local C = nil
local data = nil
local FROM = nil

-- Routine
function Prepare(onlyname)
    IDX = instance.parameters.IDX

    if IDX == "_" then
        IDX = instance.parameters.IDX1
        assert(
            IDX ~= "",
            "You must enter the instrument in case custom instrument is chosen. Try, for example, GCQ10.CMX"
        )
    end

    source = instance.source

    local bs = source:barSize()
    if bs == "D1" then
        RES = "d"
    elseif bs == "W1" then
        RES = "w"
    elseif bs == "M1" then
        RES = "m"
    else
        assert(false, "The chart must be a day, week or month chart")
    end
    local name = profile:id() .. "(" .. IDX .. "@yahoo.finance, " .. RES .. ")"
    instance:name(name)
    if onlyname then
        return
    end

    first = source:first()
    O = instance:addStream("O", core.Line, name .. ".O", "O", core.rgb(255, 0, 0), first)
    O:setPrecision(math.max(2, instance.source:getPrecision()))
    H = instance:addStream("H", core.Line, name .. ".H", "H", core.rgb(255, 0, 0), first)
    H:setPrecision(math.max(2, instance.source:getPrecision()))
    L = instance:addStream("L", core.Line, name .. ".L", "L", core.rgb(255, 0, 0), first)
    L:setPrecision(math.max(2, instance.source:getPrecision()))
    C = instance:addStream("C", core.Line, name .. ".C", "C", core.rgb(255, 0, 0), first)
    C:setPrecision(math.max(2, instance.source:getPrecision()))
    V = instance:addStream("V", core.Line, name .. ".V", "V", core.rgb(255, 0, 0), first)
    V:setPrecision(math.max(2, instance.source:getPrecision()))
    instance:createCandleGroup(IDX, IDX, O, H, L, C, V)

    core.host:execute("setTimer", 1, 1)
end

local loadingRequest
local loading = false, loadError
local token = {}

-- Indicator calculation routine
function Update(period)
    if errorLoad or loading then
        return
    end

    local from, to
    from = core.dateToTable(source:date(0))
    if FROM == nil then
        to = core.dateToTable(source:date(source:size() - 1))
    else
        to = core.dateToTable(FROM - 1)
    end

    if data == nil then
        if source:size() > 0 and period == source:size() - 1 then
            StartLoading(IDX, RES, from, to)
        end
        if data == nil then
            return
        end
        instance:updateFrom(0)
    end

    if FROM ~= nil and period == 0 and source:date(period) < FROM then
        StartLoading(IDX, RES, from, to)
    end

    if period >= first then
        local p = findDateFast(source:date(period))
        if p >= 0 then
            p = data[p]
            O[period] = p.open
            H[period] = p.high
            L[period] = p.low
            C[period] = p.close
            V[period] = p.volume
        else
            if period >= first + 1 and O[period - 1] ~= nil and O[period - 1] ~= 0 then
                O[period] = C[period - 1]
                H[period] = H[period - 1]
                L[period] = L[period - 1]
                C[period] = C[period - 1]
                V[period] = V[period - 1]
            end
        end
    end
end
--                     Date,  Open,   High,   Low,     Close, Volume, Adj Close
local pattern_line = "([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*)\n"
local pattern_date = "(%d+)-(%d+)-(%d+)"

function getToken(index)
    local token = {}
    local req = http_lua.createRequest()
    local url = string.format("https://finance.yahoo.com/quote/%s?p=&s", index, index)

    req:start(url)
    while req:loading() do
    end

    if not (req:success()) then
        errorLoad = true
        core.host:execute("setStatus", "load failed")
        return nil
    end

    if req:httpStatus() ~= 200 then
        errorLoad = true
        core.host:execute("setStatus", "load failed")
        return nil
    end

    local response = req:response()
    local cookie = req:responseHeader("set-cookie")
    if cookie == nil then
        errorLoad = true
        core.host:execute("setStatus", "load failed 1")
        return nil
    end

    token.cookie = string.sub(cookie, 0, string.find(cookie, ";") - 1)
    token.crumb = string.match(response, '"CrumbStore":{"crumb":"(%P+)"}')

    if token == nil or token.cookie == nil or token.crumb == nil then
        errorLoad = true
        core.host:execute("setStatus", "load failed")
        return nil
    end

    return token
end

function StartLoading(index, timeframe, from, to)
    token = getToken(index)

    if token == nil then
        return false
    end

    if timeframe == "d" then
        timeframe = "1d"
    elseif timeframe == "w" then
        timeframe = "1wk"
    else
        timeframe = "1mo"
    end

    local convertedFrom = os.time({year = from.year, month = from.month, day = from.day, hour = 0, min = 0, sec = 0})
    local convertedTo = os.time({year = to.year, month = to.month, day = to.day, hour = 0, min = 0, sec = 0})

    local url =
        string.format(
        "https://query1.finance.yahoo.com/v7/finance/download/%s?period1=%s&period2=%s&interval=%s&events=history&crumb=%s",
        index,
        tostring(convertedFrom),
        tostring(convertedTo),
        timeframe,
        token.crumb
    )

    loadingRequest = http_lua.createRequest()
    loadingRequest:setRequestHeader("Cookie", token.cookie)

    loadingRequest:start(url)
    loading = true
    core.host:execute("setStatus", "loading...")
end

function findDateFast(date)
    local datesec = nil
    local periodsec = nil
    local min, max, mid

    datesec = math.floor(date + 0.5 / 86400)

    min = 0
    max = data.count - 1

    if (max < 0) then
        return -1
    end

    while true do
        mid = math.floor((min + max) / 2)
        periodsec = data[mid].date
        if datesec == periodsec then
            return mid
        elseif datesec > periodsec then
            min = mid + 1
        else
            max = mid - 1
        end
        if min > max then
            return -1
        end
    end
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 then
        if loading then
            if not (loadingRequest:loading()) then
                loading = false
                if loadingRequest:httpStatus() == 200 then
                    local body = loadingRequest:response()
                    local pos
                    local date, open, high, low, close, volume, t, period
                    local year, month, day
                    pos = 1
                    if FROM == nil then
                        data = {}
                        data.count = 0
                    end
                    FROM = source:date(0)
                    while true do
                        date, open, high, low, close, adjClose, volume = string.match(body, pattern_line, pos)
                        if date == nil then
                            break
                        end
                        pos = string.find(body, "\n", pos) + 3
                        year, month, day = string.match(date, pattern_date)
                        if year ~= nil then
                            t = {}
                            t.month = tonumber(month)
                            t.day = tonumber(day)
                            t.year = tonumber(year)
                            t.year = (t.year < 70) and 2000 + t.year or 1900 + t.year
                            t.hour = 0
                            t.min = 0
                            t.sec = 0
                            period = {}
                            period.date = core.tableToDate(t)
                            period.open = tonumber(open)
                            period.high = tonumber(high)
                            period.low = tonumber(low)
                            period.close = tonumber(close)
                            period.volume = tonumber(volume)
                            data[data.count] = period
                            data.count = data.count + 1
                        end
                    end
                    errorLoad = false
                    instance:updateFrom(0)
                    core.host:execute("setStatus", "")
                    return core.ASYNC_REDRAW
                else
                    errorLoad = true
                    core.host:execute("setStatus", "load failed")
                end
            end
        end
    end
    return 0
end

function ReleaseInstance()
    if loading then
        while (loadingRequest:loading()) do
        end
    end
    core.host:execute("killTimer", 1)
end

require("http_lua")
