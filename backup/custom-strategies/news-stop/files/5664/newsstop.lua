-- Id: 2137
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=2551

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
    strategy:name("DailyFX News Stop");
    strategy:description("The strategy closes specific position before particular dailyfx calendar events")
    strategy:setTag("Version", "2");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");
    
    strategy.parameters:addGroup("News parameters");
    strategy.parameters:addString("MASK", "Mask to be searched in news", "Mask to be searched in news", "");
	strategy.parameters:addString("IMP", "Importance of the news to search", "Importance of the news to search", "ALL");
    strategy.parameters:addStringAlternative("IMP", "All news", "", "ALL");
    strategy.parameters:addStringAlternative("IMP", "Medium or above", "", "MED");
    strategy.parameters:addStringAlternative("IMP", "High only", "", "HIGH");
    strategy.parameters:addBoolean("ALL", "All instruments", "Choose true to check all news and false to check the news which are related with the current currency pair only", false);
    
    strategy.parameters:addGroup("Timeout parameters");
    strategy.parameters:addInteger("NEWS_RELOAD", "Timeout value to refresh news (in minutes)", "Timeout value to refresh news (in minutes)", 15, 5, 60);
    strategy.parameters:addInteger("CHECK_STOP", "Timeout value for checking if stop necessary (in minutes)", "", 1, 1, 60);
    strategy.parameters:addInteger("ADVANCE", "Analyze news for N future days", "Analyze news for N future days", 7, 1, 30);
    strategy.parameters:addDouble("HOURS_BEFORE", "Specify time before event, when positions will be closed (in hours)", "Specify time before event, when positions will be closed (in hours). You can specify fractional value here (0.5 hours, for example)", 0, 0, 170);
    
    strategy.parameters:addGroup("Trade parameters");
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addBoolean("USETRADE", "Close specific trade", "Close specific trade", false);
    strategy.parameters:addString("TRADE", "Choose Trade", "Choose Trade", "");
    strategy.parameters:setFlag("TRADE", core.FLAG_TRADE);
    strategy.parameters:addBoolean("USEACCOUNT", "Close trades of specific account", "Close trades of specific account", false); --???
    strategy.parameters:addString("ACCOUNT", "Choose Account", "Choose Account", "");
    strategy.parameters:setFlag("ACCOUNT", core.FLAG_ACCOUNT);
    strategy.parameters:addBoolean("TERMINATE_AFTER", "Disable strategy after triggering", "", true);
end

local SERVER =  "www.dailyfx.com" --"192.168.40.52" 
local DEBUG = true
-- Loading properties and variables
local http;
local loading;
local loadingWeek;
local loadingYear;

local instr;
local OFFER;

-- News parameters
local MASK;
local IMP;
local ALL;

-- Timeout parameters
local NEWS_RELOAD;
local CHECK_STOP;
local ADVANCE;
local HOURS_BEFORE;

-- Trade parameters
local USETRADE
local TRADE
local USEACCOUNT
local ACCOUNT
local TERMINATE_AFTER

local stopBefore = nil
local lastCheck = nil
    

local CID = "DailyFX News Stop"
local notBefore = 40325;        -- May, 26 2010, the oldest availabe news archive

local loadedWeeks = {size = 0}
local stopEvents = {};

function Prepare(nameOnly)
    instr = instance.bid:instrument();
    OFFER = core.host:findTable("offers"):find("Instrument", instr).OfferID;    
    
    -- News parameters    
    MASK = instance.parameters.MASK;
    assert (MASK ~= "", "Mask should be specified");
    IMP = instance.parameters.IMP;
    ALL = instance.parameters.ALL;
 
    local name = profile:id();
	name = name .. "(" .. MASK 
	if (IMP ~= "ALL") then
	  name = name .. "," .. IMP
	end
	name = name .. ")"
	instance:name(name);
    if nameOnly then return end

    -- Timeout parameters
    NEWS_RELOAD = instance.parameters.NEWS_RELOAD
    CHECK_STOP = instance.parameters.CHECK_STOP
    ADVANCE = instance.parameters.ADVANCE;
    HOURS_BEFORE = instance.parameters.HOURS_BEFORE
    
    stopBefore = HOURS_BEFORE / 24.0;
    lastCheck  = core.host:execute("convertTime", 3, 1, core.now()) + stopBefore
    
    -- Trade parameters
    USETRADE = instance.parameters.USETRADE;
    TRADE = instance.parameters.TRADE;
    USEACCOUNT = instance.parameters.USEACCOUNT;
    ACCOUNT = instance.parameters.ACCOUNT;
    TERMINATE_AFTER = instance.parameters.TERMINATE_AFTER;
    
    loading = false;
    http = core.makeHttpLoader();
    core.host:execute("setTimer", 1, 1);                -- Check finishind of HTTP loading
    core.host:execute("setTimer", 2, CHECK_STOP * 60);  -- Check stop timer
    core.host:execute("setTimer", 3, NEWS_RELOAD * 60); -- Refresh news timer
    
    updateNews()
end

--              date    time    TZ      curr    desc    imp     act     fore    prev
local pline = "([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*)%c()";
local pdate = "%a%a%a%s(%a%a%a)%s(%d%d?)";
local ptime = "(%d%d?):(%d%d)";
    
local months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}

function AsyncOperationFinished(cookie, success, message)
    if cookie == 1 then
        if loading and not(http:loading()) then 
            if http:successful() then
                finishLoading();    
            end
            loading = false;
            updateNews();
        end
        return 0;
    elseif cookie == 2 then
        checkStop()
    elseif cookie == 3 then
        loadedWeeks = {size = 0};
        stopEvents  = {}
        updateNews();
    end
    
    return 0;
end

-- -------------------------------------
-- Start updateing process
-- -------------------------------------
function updateNews()
    local today = core.now()
    for i = 0, ADVANCE - 1 do
        local week, weekData, year;
        local dt = today + i
        week, year = getweek(dt);
        if loadedWeeks[week] == nil and dt >= notBefore then
            if not(loading) then
                loadweek(week, year);
            end
        end
    end
end

-- -------------------------------------
-- gets a week for the specified date
-- returns week, year for specified date
-- -------------------------------------
function getweek(date)
    local t = core.dateToTable(date);
    date = math.floor(date) - (t.wday - 1);
    t = core.dateToTable(date);
    return string.format("%02i-%02i-%04i", t.month, t.day, t.year), t.year;
end

-- -------------------------------------
-- Start asynchronous loading process
-- -------------------------------------
function loadweek(week, year)
    local url = "/files/Calendar-" .. week .. ".csv";
    http:load(SERVER, 80, url, true);

-- DEBUG --	
    if DEBUG then
      core.host:trace('Start loading ' .. SERVER .. url)  
    end
-- END DEBUG -- 

    loading = true;
    loadingWeek = week;
    loadingYear = year;
    return 1;
end

-- ---------------------------------------
-- Finish loading and parse HTTP response
-- ---------------------------------------
function finishLoading()
    local date, time, tz, curr, desc, imp, act, fore, prev;
    local month, day, hour, minute
    local pos = 1
    local response, year = http:response(), loadingYear
    
    while true do
        -- Parse CSV string
        date, time, tz, curr, desc, imp, act, fore, prev, pos = string.match(response, pline, pos);
        if (date == nil) then
            break;
        end

        -- process only those news, which are related with the currencies of
        -- the current instrument
        if (ALL or (string.find(instr, string.upper(curr), 1, true) ~= nil)) and 
           (IMP == "ALL" or (IMP == "MED" and imp == "Medium" or imp == "High") or (IMP == "HIGH" and imp == "High")) and
           string.find(desc, MASK, 1, true) ~= nil then 
            month, day = string.match(date, pdate);
            hour, minute = string.match(time, ptime);
            
            if month ~= nil and hour ~= nil then
                local ttime = {};
                -- set year
                ttime.year = year;
                -- set month
                local skip = true;
                for n, mname in ipairs(months) do
                    if month == mname then
                        ttime.month = n
                        skip = false
                        break;
                    end
                end
                -- set day
                if not(skip) then
                    ttime.day  = tonumber(day);
                    ttime.hour = tonumber(hour);
                    ttime.min  = tonumber(minute);
                    ttime.sec  = 0;
                
                    local news = {};
                    news.instrument = curr;
                    news.desc = desc;
                    news.gmt_time = core.tableToDate(ttime);
                    news.est_time = core.host:execute("convertTime", 2, 1, news.gmt_time);
                    if news.est_time > lastCheck then
                        table.insert(stopEvents, news);
                    end
                end
            end
        end
    end
    loadedWeeks[loadingWeek] = true;
    loadedWeeks.size = loadedWeeks.size + 1
	
-- DEBUG --	
    if DEBUG then
		core.host:trace('Complete parsing for ' .. loadingWeek .. ' stopEvents = ' .. #stopEvents);
	end
--END DEBUG --

	checkStop(); -- we need to check stop for newly loaded events
end

-- Compare events by time
function compareEvents(a, b) return a.est_time < b.est_time end

function checkStop()
    local enum, row, valuemap;

    local now_time = core.host:execute("convertTime", 3, 1, core.now()) + stopBefore -- We will check time in future
    
-- DEBUG --	
    if (DEBUG and #stopEvents > 0) then 
		table.sort(stopEvents, compareEvents);
		local minutes = ((stopEvents[1].est_time - now_time) * 1440)
        core.host:trace( string.format("%.0f", math.floor(minutes / 60)) .. ":" .. string.format("%.0f", (minutes % 60)) .. " before stop @ " .. stopEvents[1].desc);
    end
-- END DEBUG

    -- First of all we need to check if the searched event is reached
    local stop = false
    if core.host:findTable("trades"):find("OfferId", gOffer) ~= nil then
        for _, event in pairs(stopEvents) do
            if (now_time >= event.est_time and 
               lastCheck < event.est_time) then
               stop = true;
               break;
            end
        end
    end
    
    lastCheck = now_time;
    
    if not(stop) or not instance.parameters.AllowTrade then
        return
    end
    
    local wasStoped = false;
    enum = core.host:findTable("trades"):enumerator();    
    while true do
        row = enum:next();
        if row == nil then
            break;
        end
        
        if row.OfferID == OFFER and
           (not(USETRADE) or TRADE == row.TradeID) and
           (not(USEACCOUNT) or ACCOUNT == row.AccountID) then
           
            valuemap = core.valuemap();
            valuemap.OfferID = OFFER;
            valuemap.AcctID = row.AccountID;
            valuemap.Quantity = row.Lot;
            valuemap.CustomID = CID;
            valuemap.BuySell = (row.BS == "B") and "S" or "B";
            
            CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instr, row.AccountID);
            core.host:trace('Close :' .. tostring(CanClose));
            if CanClose then
                -- non-FIFO account, create a close market order
                valuemap.OrderType = "CM";
                valuemap.TradeID = row.TradeID;
            else
                -- FIFO account, create an opposite market order
                valuemap.OrderType = "OM";
            end
            success, msg = terminal:execute(200, valuemap);
            assert(success, msg);
            wasStoped = true;
        end
    end
    
    if wasStoped and TERMINATE_AFTER then
        core.host:execute ("stop")    
    end 
    
end

function Update(period, mode) end

function ReleaseInstance()
    if loading then
        while (http:loading()) do
        end
    end
    core.host:execute("killTimer", 1);
    core.host:execute("killTimer", 2);
    core.host:execute("killTimer", 3);
end
