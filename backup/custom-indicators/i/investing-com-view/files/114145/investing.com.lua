

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64988

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


function Init()
    indicator:name("Shows the market historical data");
    indicator:description("Shows the market indexes in day, week or month resolution. The data is loaded from investing.com");
    indicator:requiredSource(core.Bar);
    indicator:type(core.View);

    indicator.parameters:addString("IDX", "Choose the Index", "", "apple-computer-inc");
    indicator.parameters:addString("TF", "Time frame", "", "Daily");
    indicator.parameters:addStringAlternative("TF", "Day", "", "Daily");
    indicator.parameters:addStringAlternative("TF", "Week", "", "Weekly");
    indicator.parameters:addStringAlternative("TF", "Month", "", "Monthly");
    indicator.parameters:addDate("FROM", "Date from", "", -1000);
    indicator.parameters:addDate("TO", "Date to", "", 0);
    indicator.parameters:setFlag("TO", core.FLAG_DATE);
end

local O, H, L, C, V

-- initializes the instance of the indicator
function Prepare(onlyName)

    local IDX = instance.parameters.IDX;
    assert(IDX ~= "", "You must enter the instrument in case custom instrument is chosen. Try, for example, GCQ10.CMX");

    local TF = instance.parameters.TF;

    local name = profile:id() .. "(" .. IDX .. "@invesing.com, " .. TF .. ")";

    instance:name(name);
    if onlyname then
        return ;
    end

    instance:initView(IDX, 2, 0.01, true, false);

    O = instance:addStream("O", core.Line, name .. ".O", "O", core.rgb(255, 0, 0), 0);
    H = instance:addStream("H", core.Line, name .. ".H", "H", core.rgb(255, 0, 0), 0);
    L = instance:addStream("L", core.Line, name .. ".L", "L", core.rgb(255, 0, 0), 0);
    C = instance:addStream("C", core.Line, name .. ".C", "C", core.rgb(255, 0, 0), 0);
    V = instance:addStream("V", core.Line, name .. ".V", "V", core.rgb(255, 0, 0), 0);
    instance:createCandleGroup(IDX, IDX, O, H, L, C, V, TF);
    core.host:execute("setTimer", 1, 1);
    local res =  false;
    
    local maxRepeat = 5;
    while res == false do
        res = StartLoading(IDX, TF, instance.parameters.FROM, instance.parameters.TO);
        maxRepeat = maxRepeat - 1;
        if maxRepeat < 0 then
            errorLoad = true;
            core.host:execute("setStatus", "load failed");
            break;
        end
    end               
end

function Update(period)
end

local loadingRequest;
local loading, loadError;
local token = {};
local patternUrls = {"https://www.investing.com/equities/%s", "http://www.investing.com/commodities/%s", 
                     "http://www.investing.com/indices/%s", "http://www.investing.com/quotes/%s"}

function getPairID(index, patternUrl)

    local pairID = nil;
    local req = http_lua.createRequest();
    local url = string.format(patternUrl, index);
    
    req:start(url);
    while req:loading() do
    end
        
    if not(req:success()) then
        errorLoad = true;
        core.host:execute("setStatus", "load failed");
        return nil;
    end    
    
    if req:httpStatus() ~= 200 then
        errorLoad = true;
        core.host:execute("setStatus", "load failed");
        return nil;
    end

    local response = req:response();
        
    pairID = string.match(response, 'instrument_id.....(%d+)');
    
    if  pairID == nil then 
        errorLoad = true;
        core.host:execute("setStatus", "load failed");
        return nil;
    end
    
    return pairID;
end

function StartLoading(index, timeframe, _from, _to)
   
    local pairID = nil;
    
    for i = 1, #patternUrls do
        pairID = getPairID(index, patternUrls[i]);
        if pairID ~= nil then 
            break;
        end;
    end
    
    if pairID == nil then 
        return false;
    end
    
    local _start = core.formatDate(_from):match("(%S+)%s+(.+)");    
    local _end = core.formatDate(_to):match("(%S+)%s+(.+)");
      
    local query = string.format("action=historical_data&curr_id=%s&st_date=%s&end_date=%s&interval_sec=%s",
                              pairID,
                              _start,
                              _end,
                              timeframe);

    loadingRequest = http_lua.createRequest(); 
    loadingRequest:setRequestHeader("Origin", "http://www.investing.com");
    loadingRequest:setAgent("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Ubuntu" ..
            ' Chromium/51.0.2704.79 Chrome/51.0.2704.79 Safari/537.36')
    loadingRequest:setRequestHeader("X-Requested-With", "XMLHttpRequest");
    loadingRequest:setRequestHeader("content-type", "application/x-www-form-urlencoded");

    loadingRequest:start("https://uk.investing.com/instruments/HistoricalDataAjax", "POST", query);
    loading = true;
    core.host:execute("setStatus", "loading...");
end

function responseToTable(s)
    local periods = {};
    local count = 0;
    
    local bodyTag = s:match("<tbody>(.-)</tbody>");
    for trTag in string.gmatch(bodyTag, "<tr>(.-)</tr>") do 
        local prices = {};
        local index = 1;
        trTag = trTag:gsub("%,", "")
        for data in string.gmatch(trTag, '"(%d*%.?%d+)"') do 
            prices[index] = tonumber(data);
            index = index +1;
        end
        
        if #prices >= 6 then
        
            local  period = {};
            period.date = ConvertUnixDateToDateTime(tonumber(prices[1]));
            period.open = tonumber(prices[3]);
            period.high = tonumber(prices[4]);
            period.low = tonumber(prices[5]);
            period.close = tonumber(prices[2]);
            period.volume = tonumber(prices[6]);
            count = count + 1;
            periods[count] = period;
        end
    end
    
    return periods
end

function ConvertUnixDateToDateTime(date)
    return (date / 86400) + 25569;
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 then
        if loading then
            if not(loadingRequest:loading()) then
                loading = false;
                if loadingRequest:httpStatus() == 200 then
                     local body = loadingRequest:response();
                     periods = responseToTable(loadingRequest:response());
                 
                     local lastdate = nil, date, s;
                     for i = #periods, 1, -1  do
                        date = periods[i].date;
                        if lastdate == nil or lastdate < date then
                            instance:addViewBar(date);
                            s = O:size() - 1;
                            O[s] = periods[i].open;
                            H[s] = periods[i].high;
                            L[s] = periods[i].low;
                            C[s] = periods[i].close;
                            V[s] = periods[i].volume;
                            lastdate = date;
                        else
                            core.host:trace(string.format("%i %s %s", i, core.formatDate(lastdate), core.formatDate(date)));
                        end
                     end
                     errorLoad = false;
                     core.host:execute("setStatus", "");
                     return core.ASYNC_REDRAW;
                else
                     errorLoad = true;
                     core.host:execute("setStatus", "load failed");
                end
            end
        end
    end
    return 0;
end

function ReleaseInstance()
    if loading then
        while (loadingRequest:loading()) do
        end
    end
    core.host:execute("killTimer", 1);
end

require("http_lua");    