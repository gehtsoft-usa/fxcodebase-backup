
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65064

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
    indicator:name("Shows the market historical data");
    indicator:description("Shows the market indexes in day, week or month resolution. The data is loaded from barchart.com");
    indicator:requiredSource(core.Bar);
    indicator:type(core.View);

    indicator.parameters:addString("IDX", "Choose the Index", "", "AAPL");
    indicator.parameters:addString("TF", "Time frame", "", "daily");
    indicator.parameters:addStringAlternative("TF", "Day", "", "daily");
    indicator.parameters:addStringAlternative("TF", "Week", "", "weekly");
    indicator.parameters:addStringAlternative("TF", "Month", "", "monthly");
    indicator.parameters:addDate("FROM", "Date from", "", -1000);
    indicator.parameters:addDate("TO", "Date to", "", 0);
    indicator.parameters:setFlag("TO", core.FLAG_DATE);
    indicator.parameters:addString("VolumeType", "Volume Type", "", "total");
    indicator.parameters:addStringAlternative("VolumeType", "Total", "", "total");
    indicator.parameters:addStringAlternative("VolumeType", "Contract", "", "contract");   
end

local O, H, L, C, V

-- initializes the instance of the indicator
function Prepare(onlyName)

    local IDX = instance.parameters.IDX;
    assert(IDX ~= "", "You must enter the instrument in case custom instrument is chosen. Try, for example, AAPL");

    local TF = instance.parameters.TF;

    local name = profile:id() .. "(" .. IDX .. "@barchart.com, " .. TF .. ")";

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

local patternUrl = {"https://www.barchart.com/proxies/timeseries/queryeod.ashx?symbol=%s&data=%s&start=%s&end=%s&volume=total"}

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
        
    pairID = string.match(response, 'pair_id="(%d+)"');
    
    if  pairID == nil then 
        errorLoad = true;
        core.host:execute("setStatus", "load failed");
        return nil;
    end
    
    return pairID;
end

function StartLoading(index, timeframe, _from, _to)
   
    local volumeType = instance.parameters.VolumeType;
    local _start = ConvertToValidDateFormat(core.formatDate(_from))
    local _end = ConvertToValidDateFormat(core.formatDate(_to))

    local query = string.format("symbol=%s&data=%s&start=%s&end=%s&volume=%s",
                              index,
                              timeframe,
                              _start,
                              _end,
                              volumeType);

    loadingRequest = http_lua.createRequest(); 

    loadingRequest:start("https://www.barchart.com/proxies/timeseries/queryeod.ashx?".. query);
    loading = true;
    core.host:execute("setStatus", "loading...");
end

function ConvertToValidDateFormat(dateString)

    local template = "(%d+)/(%d+)/(%d+) (%d+):(%d+):(%d+)"
    month,day,year,hour,min,sec=dateString:match(template)
    
    return year .. month .. day;
end

local pattern_line = "([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*)\n";
local pattern_date = "(%d%d%d%d)-(%d%d)-(%d%d)";

function responseToTable(body)
    local periods = {};
    local count = 0;
    local pos = 0;
    
    while true do
        index, date, open, high, low, close, volume = string.match(body, pattern_line, pos);
        if date == nil then
            break;
        end
        pos = string.find(body, '\n', pos) + 1  
        year, month, day = string.match(date, pattern_date);
        if year ~= nil then
             t = {};
             t.month = tonumber(month);
             t.day = tonumber(day);
             t.year = tonumber(year);
             t.hour = 0;
             t.min = 0;
             t.sec = 0;
             period = {};
             period.date = core.tableToDate(t);
             period.open = tonumber(open);
             period.high = tonumber(high);
             period.low = tonumber(low);
             period.close = tonumber(close);
             period.volume = tonumber(volume);
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
                     periods = responseToTable(body);
                                          
                     local lastdate = nil, date, s;
                     for i = 1, #periods  do
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