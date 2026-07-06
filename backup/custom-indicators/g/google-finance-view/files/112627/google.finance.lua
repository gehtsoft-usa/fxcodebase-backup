-- Id: 18221
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64694

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

function Init()
    indicator:name("Shows the market historical data");
    indicator:description("Shows the market indexes in day resolution. The data is loaded from google.finance");
    indicator:requiredSource(core.Bar);
    indicator:type(core.View);


    indicator.parameters:addString("IDX", "Choose the Index", "", "GOOG");
    indicator.parameters:addDate("FROM", "Date from", "", -1000);
    indicator.parameters:addDate("TO", "Date to", "", 0);
    indicator.parameters:setFlag("TO", core.FLAG_DATE);
end

local O, H, L, C, V
 
-- initializes the instance of the indicator
function Prepare(onlyName)
    local IDX = instance.parameters.IDX;
    assert(IDX ~= "", "You must enter the instrument in case custom instrument is chosen. Try, for example, GCQ10.CMX");


    local name = profile:id() .. "(" .. IDX .. "@google.finance, " .. ")";

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
    StartLoading(IDX, TF, instance.parameters.FROM, instance.parameters.TO);
end

function Update(period)
end

local http, loading, loadError;

function StartLoading(index, timeframe, _from, _to)
    local from = core.dateToTable(_from);
    local to = core.dateToTable(_to);

    local url;
    url = "/finance/historical?q=" .. index ..
          "&startdate=" .. toApiStringDate(from) ..
          "&enddate=" .. toApiStringDate(to) .. 
          "&output=csv";

    if http == nil then
        http = core.makeHttpLoader();
    end

    http:load("www.google.com", 80, url, true);
    loading = true;
    loadError = false;
    core.host:execute("setStatus", "loading...");
end

function toApiStringDate(date)
	return getmonth(date.month) .. "+" .. date.day .. "+" .. date.year;
end

function getmonth(month)
    local months = { "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" }
    return months[tonumber(month)]
end

local pattern_line = "([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*)";
local pattern_date = "(%d+)-(%a+)-(%d+)";
local MON={Jan=1,Feb=2,Mar=3,Apr=4,May=5,Jun=6,Jul=7,Aug=8,Sep=9,Oct=10,Nov=11,Dec=12}   

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 then
        if loading then
            if not(http:loading()) then
                loading = false;
                if http:successful() then
                     local body = http:response();
                     local pos = 0;
                     local date, open, high, low, close, volume, t, period;
                     local year, month, day;
                     local periods = {};
                     local count = 0;
                     while true do
                         date, open, high, low, close, volume = string.match(body, pattern_line, pos);
                         if date == nil then
                             break;
                         end
                         pos = string.find(body, "\n", pos) + 1 
                             
                         day,month,year = string.match(date, pattern_date);
                         if year ~= nil then                          
                             t = {};
                             t.month = MON[month]
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
                     for i = count, 1, -1 do
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
        while (http:loading()) do
        end
    end
    core.host:execute("killTimer", 1);
end



