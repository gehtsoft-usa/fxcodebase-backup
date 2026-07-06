-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=58421

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
    indicator:name("Shows the market historical data");
    indicator:description("Shows the market indexes in day, week or month resolution. The data is loaded from yahoo.finance");
    indicator:requiredSource(core.Bar);
    indicator:type(core.View);

    indicator.parameters:addString("IDX", "Choose the Index", "", "UBER");
    indicator.parameters:addString("TF", "Time frame", "", "d");
    indicator.parameters:addStringAlternative("TF", "Day", "", "d");
    indicator.parameters:addStringAlternative("TF", "Week", "", "w");
    indicator.parameters:addStringAlternative("TF", "Month", "", "m");
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

    local name = profile:id() .. "(" .. IDX .. "@yahoo.finance, " .. TF .. ")";

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
    
    while res == false do
        res = StartLoading(IDX, TF, instance.parameters.FROM, instance.parameters.TO);
    end
end

function Update(period)
end

local loadingRequest;
local loading, loadError;
local token = {};

function getToken(index)

    local token = {};
    local req = http_lua.createRequest();
    local url = string.format("https://finance.yahoo.com/quote/%s?p=%s", index, index);
    
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
    local cookie = req:responseHeader("set-cookie");
    token.cookie = string.sub(cookie, 0, string.find(cookie, ";") - 1);
    token.crumb = string.match(response, '"CrumbStore":{"crumb":"(%P+)"}');
    if token == nil or token.cookie == nil or token.crumb == nil then 
        errorLoad = true;
        core.host:execute("setStatus", "load failed");
        return nil;
    end
    
    return token;
end

function StartLoading(index, timeframe, _from, _to)
    token = getToken(index)
    core.host:trace(tostring(token))
    if token == nil then 
        return false;
    end 

    local from = core.dateToTable(_from);
    local to = core.dateToTable(_to);

    if timeframe == "d" then
      timeframe = "1d";
    elseif timeframe == "w" then
      timeframe = "1wk";
    else
      timeframe = "1mo";
    end
      
    local convertedFrom = os.time({year = from.year, month = from.month, day = from.day, hour = 0, min = 0, sec = 0});
    local convertedTo = os.time({year = to.year, month = to.month, day = to.day, hour = 0, min = 0, sec = 0});

      
    local url = string.format("https://query1.finance.yahoo.com/v7/finance/download/%s?period1=%s&period2=%s&interval=%s&events=history&crumb=%s",
                              index,
                              tostring(convertedFrom),
                              tostring(convertedTo),
                              timeframe,
                              token.crumb);
    
    loadingRequest = http_lua.createRequest();                          
    loadingRequest:setRequestHeader("Cookie", token.cookie);

    loadingRequest:start(url);
    loading = true;
    core.host:execute("setStatus", "loading...");
end

local pattern_line = "([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*)\n";
local pattern_date = "(%d+)-(%d+)-(%d+)";

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 then
        if loading then
            if not(loadingRequest:loading()) then
                loading = false;
                if loadingRequest:httpStatus() == 200 then
                     local body = loadingRequest:response();
                     core.host:trace(body);
                     local pos = 0;
                     local date, open, high, low, close, adjClose, volume, t, period;
                     local year, month, day;
                     local periods = {};
                     local count = 0;
                     while true do
                         date, open, high, low, close, adjClose, volume = string.match(body, pattern_line, pos);
                         if date == nil then
                             break;
                         end
                         pos = string.find(body, '\n', pos) + 3 
                         year, month, day = string.match(date, pattern_date);
                         if year ~= nil then
                             t = {};
                             t.month = tonumber(month);
                             t.day = tonumber(day);
                             t.year = tonumber(year);
                             t.year = (t.year < 70) and 2000 + t.year or 1900 + t.year;
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
                     local lastdate = nil, date, s;
                     for i = 1, count do
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