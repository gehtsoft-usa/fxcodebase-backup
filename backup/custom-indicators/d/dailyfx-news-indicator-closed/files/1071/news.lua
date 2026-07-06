-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=603&p=1071#p1071

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
    indicator:name("DailyFX News");
    indicator:description("The indicator shows chosen dailyfx calendar events")
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDate("NewsFrom", "News from", "", -60);
    indicator.parameters:addString("Instruments", "Instruments", "", "All");
    indicator.parameters:addStringAlternative("Instruments", "All", "", "All");
    indicator.parameters:addStringAlternative("Instruments", "Current", "", "Current");
    indicator.parameters:addStringAlternative("Instruments", "List", "", "List");
    indicator.parameters:addString("List", "Instruments List", "Used when Instruments is set to List. Specify currencies in a comma separated list, i.e., EUR,USD,AUD etc", "");
    indicator.parameters:addString("IMP", "Importance of the new to show", "", "ALL");
    indicator.parameters:addStringAlternative("IMP", "All news", "", "ALL");
    indicator.parameters:addStringAlternative("IMP", "Medium or above", "", "MED");
    indicator.parameters:addStringAlternative("IMP", "High only", "", "HIGH");
    indicator.parameters:addString("NM", "Meaning of Negative", "", "LTZ");
    indicator.parameters:addStringAlternative("NM", "Less than zero", "", "LTZ");
    indicator.parameters:addStringAlternative("NM", "Less than forecast/previous", "", "LTF");
    indicator.parameters:addStringAlternative("NM", "Greater than forecast/previous", "", "GTF");
    indicator.parameters:addBoolean("REFRESH", "Refresh news automatically", "", false);
    indicator.parameters:addInteger("TIMEOUT", "Refresh news in the specified timeout (in minutes)", "", 5, 5, 60);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("S", "Font size in points", "", 8, 6, 20);
    indicator.parameters:addColor("clrN", "Negative news color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrP", "Positive/Neutral news color", "", core.rgb(0, 255, 0));
end

local source;
local newsN;
local newsP;
local loadingRequest;
local loading;
local loadingWeek;
local loadingYear;
local barSize;
local offset;
local extent;
local instr;
local barSizeInDays;
local IMP;
local DUMMY;
local refresh = false;
local notBefore = 40325;        -- May, 26 2010, the oldest availabe news archive
local NM;
local instruments;
local instrumentsList;
local from;

function Prepare(onlyName)
    local name = profile:id();
    instance:name(name);
    if onlyName then
        return ;
    end

    source = instance.source;
    barSize = source:barSize();
    instr = source:instrument();
    offset = core.host:execute("getTradingDayOffset");
    IMP = instance.parameters.IMP;
    NM = instance.parameters.NM;
    instruments = instance.parameters.Instruments;
    if (instruments == "List") then
        instrumentsList = instance.parameters.List:split(",");
    end
    from = instance.parameters.NewsFrom;

    -- calculate the size of the candle
    local s, e;
    s, e = core.getcandle(source:barSize(), core.now(), offset);
    s = e - s;  -- length of candle in days
    if s > 1 then
        assert(false, "1-day is the largest chart which can be used to get news");
    end
    barSizeInDays = s;
    -- number of candles to extent for 1 week.
    -- if source:isAlive() then
    if true then
        extent = math.floor(7 / s);
        if extent > 300 then
            extent = 300;
        end
    else
        extent = 0;
    end

    newsN = instance:createTextOutput("N", "N", "Arial", instance.parameters.S, core.H_Center, core.V_Bottom, instance.parameters.clrN, extent);
    newsP = instance:createTextOutput("P", "P", "Arial", instance.parameters.S, core.H_Center, core.V_Top, instance.parameters.clrP, extent);
    loading = false;
    DUMMY = instance:addInternalStream(0, 0);
    http = core.makeHttpLoader();
    core.host:execute("setTimer", 1, 1);
    core.host:execute("addCommand", 2, "Refresh News", "");
    if instance.parameters.REFRESH then
        core.host:execute("setTimer", 3, instance.parameters.TIMEOUT * 60);
    end
end

local gWeekData = {};

function getweek(date)
    -- gets a week for the specified date
    local t = core.dateToTable(date);
    date = math.floor(date) - (t.wday - 1);
    t = core.dateToTable(date);
    return string.format("%04i/%02i%02i", t.year, t.month, t.day), t.year;
end

function includeCurrency(curr)
    if instruments == "All" then
        return true;
    end

    if instruments == "Current" then
        return (string.find(instr, curr, 1, true) ~= nil);
    end

    for i,ccy in ipairs(instrumentsList) do
        if (string.upper(ccy) == curr) then
            return true;
        end
    end

    return false;
end

local pattern_date = "(%d%d%d%d)-(%d%d)-(%d%d)";
local pattern_time = "(%d%d?):(%d%d)";

function parseHtml(response, year)
   
    local weekData = {};
    local idx = 1;
	local pos = 1;
       
    while true do
        local tableAtrib, tableBody = response:match("<table (.-)>(.-)</table>", pos);        
        if tableAtrib == nil or tableBody == nil then
            break;
        end
        
        if tableAtrib:match ('id="daily.cal%d*') ~= nil then
            idx = parseTable(tableBody, year, weekData, idx)
        end
                
        pos = string.find(response, "<table (.-)>(.-)</table>", pos) + 1
    end
    
    weekData.last = idx - 1;
    return weekData;
end 

function parseTable(table, year, weekData, idx)

    local bodyTag = table:match("<tbody>(.-)</tbody>");
    for trAtrib, trBody in string.gmatch(bodyTag, "<tr(.-)>(.-)</tr>") do

        local row = {};       
        row.category = trAtrib:match('data.category="(%w+)"');
        row.importance = trAtrib:match('data.importance="(%w+)"');
           
        if row.category ~= nil and row.importance ~= nil then
            parseRow(trAtrib, trBody, row)
        
            if  IMP == "ALL" or (IMP == "MED" and row.importance == "medium" or row.importance == "high" or
                IMP == "HIGH" and row.importance == "high") then                        
                if includeCurrency(string.upper(row.category)) then
                    
                local news = {};
                news.instrument = row.category;
                news.orgtime = row.date .. " " .. row.time ;
                
                local ttime = {};                                    
                ttime.year, ttime.month, ttime.day = row.date:match(pattern_date);
                ttime.hour, ttime.min = row.time:match(pattern_time);
                ttime.sec = 0;
                        
                news.gmt_time = core.tableToDate(ttime);
                news.est_time = core.host:execute("convertTime", 2, 1, news.gmt_time);
                ttime = core.dateToTable(core.host:execute("convertTime", 2, 4, news.gmt_time));
                news.sdate = string.format("%02i/%02i %02i:%02i", ttime.month, ttime.day, ttime.hour, ttime.min);
                -- get new's candle
                local s, e;
                s, e = core.getcandle(barSize, news.est_time, offset);
                local n, e1;
                news.orgcandles = s;
                news.orgcandlee = e;
                -- check whether candle is a nontraing candle
                n, e1 = core.isnontrading(s, offset);
                if n then
                    -- put the news to the first after-nontrading candle (2 day after the begin of the
                    -- non-trading period)
                    s, e = core.getcandle(barSize, e1 + 2, offset);
                end
                news.candles = s;
                news.candlee = e;
                news.subject = row.description;
                if (NM == "LTZ") then
                    -- negative means less than zero.
                    local posneg = "";
                    if row.actual ~= "" then
                        posneg = row.actual;
                    elseif row.forecast ~= "" then
                        posneg = row.forecast;
                    end
                    news.neg = (string.find(posneg, "-", 1, true) ~= nil);
                else
                    if row.actual  ~= "" then
                        local actual = row.actual;
                        local pp = 0;
                        if row.forecast ~= "" then
                            pp = row.forecast;
                        elseif row.previous ~= "" then
                            pp = row.previous;
                        end

                        -- format numbers.
                        local actualValue = formatValue(row.actual);
                        local prevValue = formatValue(pp);

                        if (actualValue == nil or prevValue == nil) then
                            core.host:trace("Failed to parse " .. news.sdate .. " values: Act: " .. actual .. " Parsed: " .. tostring(actualValue) .. " Prev: " .. pp .. " Parsed: " .. tostring(prevValue));
                            news.neg = false;
                        else
                            if (NM == "LTF") then
                                -- negative means less than forecast
                                news.neg = actualValue < prevValue;
                            elseif (NM == "GTF") then
                                -- negative means greater than forecast
                                news.neg = actualValue > prevValue;
                            end
                        end
                    end
                end
                news.act = row.actual;
                news.fore = row.forecast;
                news.prev = row.previous;
                news.imp = row.importance;
                weekData[idx] = news;
                idx = idx + 1;
                end
            end
        end                 
    end
    
    return idx;
end

function parseRow(trAtrib, trBody, row)
                                    
    local index = 1;
    row.actual = "";
    row.forecast = "";
    row.previous = "";
    row.description = "";
    for tdAtrib, tdBody in string.gmatch(trBody, "<td(.-)>(.-)</td>") do 
        
        if index == 2 then 
            row.date = tdBody:match(('%d+-%d+-%d+'));
            row.time = tdBody:match(('%d+:%d+:%d+'));
        elseif index == 4 then 
            local desc = tdBody:match('<br></div>(.*)');
                
            if desc ~= nil then 
                row.description = desc;
            end
        elseif index == 6 then 
            --local value = tdBody:match('(-?%d+.%d+)');   
            row.actual = tdBody;
        elseif index == 7 then              
            row.forecast = tdBody;
        elseif index == 8 then 
            row.previous = tdBody;
        end          
        index = index + 1;
    end                  
end
    
function formatValue(str) 
    if (str == nil or str == "") then
        return 0;
    end

    local suffix = string.sub (str, -1);
    if (suffix == " ") then
        -- trim the string.
        str = string.sub (str, 1, string.len(str) - 1);
        return formatValue(str);
    end

    if (string.len(str) > 1) then
        local prefix = string.sub (str, 1, 1);
        local neg = false;
        local count = 1;
        while (count < 5 and tonumber(prefix) == nil) do
            -- sometimes the first character is not a number, like a $ sign or something.
            -- Actually, sometimes it is more than the first character like for Yen values.. example "¥80T"
            -- so we need to loop around until we get a proper value.
            if (prefix == "-") then
                -- need to handle negative.
                neg = true;
            end
            -- remove the prefix
            str = string.sub (str, -(string.len(str) - 1));
            -- try again.
            prefix = string.sub (str, 1, 1);
            count = count + 1;
        end

        if (neg) then
            str = "-" .. str;
        end
    end

    local number = tonumber(string.sub (str, 1, string.len(str) - 1));
    if (number == nil) then
        return tonumber(str);
    elseif (suffix == "K" or suffix =="k") then
        return number * 1000;
    elseif (suffix == "M" or suffix =="m") then
        return number * 1000000;
    elseif (suffix == "B" or suffix =="b") then
        return number * 1000000000;
    elseif (suffix == "T" or suffix =="t") then
        return number * 1000000000000;
    elseif (suffix == "%") then
        return number;
    end

    return tonumber(str);
end

function loadweek(week, year)
    local url;   
    loadingRequest = http_lua.createRequest();        
    loadingRequest:setRequestHeader("Accept-Encoding:", "deflate");
    loadingRequest:start("http://dailyfx.com/calendar?previous=true&week=" .. week);   
    loading = true;
    core.host:execute("setStatus", "loading " .. week .. "...");
    loadingWeek = week;
    loadingYear = year;
    return ;
end

function ProcessCandle(period, date)
    local week, weekData, year;
    week, year = getweek(date);
    if gWeekData[week] == nil then
        if date >= from and date >= notBefore then
            if not(loading) then
                loadweek(week, year);
                DUMMY:setBookmark(1, period);
            end
            return ;
        else
            gWeekData[week] = {};
            weekData = gWeekData[week];
            weekData.last = 0;
        end
    else
        weekData = gWeekData[week];
    end

    if weekData ~= nil then
        local msgp = "";
        local cntp = 0;
        local msgn = "";
        local cntn = 0;
        for i = 1, weekData.last, 1 do
            local data = weekData[i];
            if (data.candles <= date and
                data.candlee > date) or
               (data.orgcandles <= date and
                data.orgcandlee > date)  then
                if data.neg then
                    if cntn > 0 then
                        msgn = msgn .. "\013\010";
                    end
                    msgn = msgn .. data.sdate .. " " .. data.subject .. "(" .. data.imp .. ")";
                    if data.act ~= "" then
                        msgn = msgn .. " Act=" .. data.act;
                    end
                    if data.fore ~= "" then
                        msgn = msgn .. " For=" .. data.fore;
                    elseif data.prev ~= "" then
                        msgn = msgn .. " Prev=" .. data.prev;
                    end
                    cntn = cntn + 1;
                else
                    if cntp > 0 then
                        msgp = msgp .. "\013\010";
                    end
                    msgp = msgp .. data.sdate .. " " .. data.subject .. "(" .. data.imp .. ")";
                    if data.act ~= "" then
                        msgp = msgp .. " Act=" .. data.act;
                    end
                    if data.fore ~= "" then
                        msgp = msgp .. " For=" .. data.fore;
                    elseif data.prev ~= "" then
                        msgp = msgp .. " Prev=" .. data.prev;
                    end
                    cntp = cntp + 1;
                end
            end
        end
        local pperiod;
        if period >= source:size() then
            pperiod = source:size() - 1;
        else
            pperiod = period;
        end
        if (cntn > 0) then
            newsN:set(period, source.low[pperiod], "(" .. cntn .. ")", msgn);
        end
        if (cntp > 0) then
            newsP:set(period, source.high[pperiod], "(" .. cntp .. ")", msgp);
        end
    end
end

function Update(period, mode)
    if not(source:hasData(period)) then
        return ;
    end
    ProcessCandle(period, source:date(period));

    if extent > 0 and period == source:size() - 1 then
        local i, ccandle;

        ccandle = source:date(period);
        for i = 1, extent - 1, 1 do
            ccandle = ccandle + barSizeInDays;
            ProcessCandle(period + i, ccandle);
        end
    end
end

function preprocessingHTML(data)
    data = data:gsub("</div></tbody>", "</div>\n\r</tr>\n\r</tbody>"); --fix the absence of a </tr> for the last row of the table.
    data = data:gsub("</div><tr", "</div>\n\r</tr>\n\r<tr"); --fix sticking tags for table row and absence of a </tr>
    return data;
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 then
        if loading then
            if not(loadingRequest:loading()) then           
                if loadingRequest:httpStatus() == 200 then
                    local body = loadingRequest:response();                       
                    gWeekData[loadingWeek] = parseHtml(body, loadingYear);
                else
                    gWeekData[loadingWeek] = nil;
                end
                loading = false;
                core.host:execute("setStatus", "");
                instance:updateFrom(math.max(0, DUMMY:getBookmark(1)));
                return core.ASYNC_REDRAW;
            end
        end
        return 0;
    elseif cookie == 2 then
        gWeekData = {};
        instance:updateFrom(0);
        return core.ASYNC_REDRAW;
    elseif cookie == 3 then
        if not(refresh) then
            -- skip the first refresh tick
            refresh = true;
            return 0;
        else
            gWeekData = {};
            instance:updateFrom(0);
            return core.ASYNC_REDRAW;
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
    core.host:execute("killTimer", 3);
end

function string:split(sep)
 local sep, fields = sep or ";", {}
 local pattern = string.format("([^%s]+)", sep)
 self:gsub(pattern, function(c) fields[#fields + 1] = c end)
 return fields
end

require("http_lua");