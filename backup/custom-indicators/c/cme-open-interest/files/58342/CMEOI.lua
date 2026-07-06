-- Id: 8927
--#!/usr/bin/lua

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34229

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+


local labels = {
    [4] = "AUD",
    [5] = "EUR FX",
    [6] = "AUD/CAD",
    [7] = "AUD/JPY",
    [8] = "AUD/NZD",
    [9] = "GBP",
    [10] = "GBP/JPY",
    [11] = "GBP/CHF",
    [12] = "CAD",
    [13] = "NZD",
    [14] = "CAD/JPY",
    [15] = "EUR/AUD",
    [16] = "EUR/GBP",
    [17] = "EUR/CAD",
    [18] = "EUR/JPY",
    [19] = "EUR/CHF",
    [20] = "JPY",
    [21] = "CHF",
    [22] = "CHF/JPY"
}



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("CME Open Interest");
    indicator:description("CME Open Interest");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addColor("Color", "Color", "Color for values of CME Open Interest indicator.", core.rgb(255, 0, 0));
    --indicator.parameters:addColor("COTs", "COT Short", "Color for Short values of COT indicator.", core.rgb(0, 255, 0));
    indicator.parameters:addString("host", "CME OI host", " CME OI host", "www.fxcodebase.com");

    indicator.parameters:addString("instrument", "Instrument", " Instrument Selection" , "5");

    --indicator.parameters:addBoolean("Cumulative", "Combined", "Combined" ,  true);
    --indicator.parameters:addBoolean("Relative", "Relative", "Relative" ,  false);


    for k,v in pairs(labels) do
        indicator.parameters:addStringAlternative("instrument", v, "Select " .. v, tostring(k));
    end

    --indicator.parameters:addString("segment", "Investor Type", " Investor Type " , "Noncommercial");
    --indicator.parameters:addStringAlternative("segment", "Investor Type Noncommercial", "Investor Type Noncommercial" , "Noncommercial");
    --indicator.parameters:addStringAlternative("segment", "Investor Type Commercial", "Investor Type Commercial" , "Commercial");
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local source = nil;
local host = nil
local instrument = nil
local OI=nil;
local cache = {}
local Relative=nil;
local Cumulative=nil;

local pline =  "([^,]+),([^,]+),([^,]+)"
local pdate = "(%d%d%d%d)(%d%d)(%d%d)"

local cache_from = math.huge
local cache_to = 0


-- Routine
function Prepare()
    source = instance.source;
    instrument = instance.parameters.instrument;
    --segment    = instance.parameters.segment;
    host       = instance.parameters.host;
    --Cumulative = instance.parameters.Cumulative;
    --Relative    = instance.parameters.Relative;

    local label=instrument or "undefined";

    if labels[tonumber(instrument)] ~= nil then
        label = labels[tonumber(instrument)];
    end

    local name = profile:id() .. "(" .. label .. ")";
    instance:name(name);
    OI = instance:addStream("OI", core.Bar, name, "CME Open Interest", instance.parameters.Color, source:first());
    OI:setPrecision(math.max(2, instance.source:getPrecision()));
    require("http_lua");  
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    local i = source:size();
    local first = source:first();
    local size=source:barSize();
    local data={};

    if source:date(first) < cache_from then
        ReloadCache(source:date(first));
    else
        if source:date(i - 1) > cache_to then
            ReloadCache(source:date(to));
        end
    end

    if #cache > 0 then 
        local idx = findDateFast(cache, source:date(period), false)

        core.host:trace(idx .. "," .. #cache)
        if idx > 0 and #cache > 0 then
            data = cache[idx]

            --core.host:trace(idx .. "," .. data.val)
            OI[period] = data.val
        end
    end
end

-- ------------------------------------------------------------------------------
-- Auxilary function which splits string by '\n' character and
-- return iterator function which can be used in 'for .. in ' expression
--
-- Parameters:
--  s           String to split
-- Returns: Pair of iterator function and state object
--
-- ------------------------------------------------------------------------------
function split(s)

  -- the for loop calls this for every iteration
  -- returning nil terminates the loop
  local function iterator (state)

    if not state.pos then
      return nil
    end -- end of string, exit loop

    local oldpos = state.pos + 1 -- step past previous newline
    state.pos = string.find (state.s, "\n", oldpos) -- find next newline

    if not state.pos then  -- no more newlines, return rest of string
      return string.sub (state.s, oldpos)
    end -- no newline

    return string.sub (state.s, oldpos, state.pos - 1)

  end -- iterator

  local state = { s = s, pos = 0 }
  return iterator, state
end -- getlines

-- ------------------------------------------------------------------------------
-- Converts date table to "COT" service compatible format 'yyyymmdd'
--
-- Parameters:
-- dt           Date table which contains year, month, day fields
--
-- Returns: String in yyyymmdd format
-- ------------------------------------------------------------------------------
function dateToString(dt)
    return tostring(dt.year) ..
           string.format('%02d', dt.month) ..
           string.format('%02d', dt.day)
end

-- ------------------------------------------------------------------------------
-- Refreshes cahce with webservice data
--
-- Parameters:
-- from           Begining of the time frame
--
-- Returns: Nothing
-- ------------------------------------------------------------------------------
function ReloadCache(from)
    cache = {}
    if instrument ~= nil then
        dt  = core.dateToTable(from) -- date table
        local req = http_lua.createRequest();
        local url = string.format(host .. "/ed/data?val_id=%d&from=%s", tonumber(instrument), dateToString(dt));
        
        req:start(url);
        core.host:execute("setStatus", "loading...");
        while req:loading() do
        end
      
        if not(req:success()) then
            core.host:execute("setStatus", "load failed");
            return ;
        end    
        
        if req:httpStatus() ~= 200 then
            core.host:execute("setStatus", "load failed");
            return ;
        end

        core.host:execute("setStatus", "");
        local body = req:response();
        
        for line in split(body) do
            if string.len(line) ~= 0 then

                -- parse line
                code,datestamp,val = string.match(line, pline);
                -- pase date
                year,month,day = string.match(datestamp, pdate)
                --core.host:trace(year .. "," .. month .. "," .. day)

                data = {}
                data.datestamp = core.datetime(tonumber(year), tonumber(month), tonumber(day), 0, 0, 0)
                data.val=tonumber(val);

                cache[#cache + 1] = data
            end
        end

        cache_from = from
        cache_to   = core.now()
    end
end

-- ------------------------------------------------------------------------------
-- Find the specified date in the cache
--
-- The function uses the binary search algorithm, so it requires only O(n) = log2(n) operations
-- to find (or to do not find) the value.
--
-- The function compares the date and time rounded to the whole seconds.
--
-- Parameters:
-- cache        The cache table to find the date in
-- date         Date and time value to be found
-- precise      The search mode
--              In case the value of the parameter is true, the function
--              Searches for the the exact date and returns not found in the
--              date is not found.
--              In case the value of the parameter is false, the function
--              returns the period with the biggest time value which is smaller
--              than the value of the date parameter.
-- Returns:
-- < 0          The value is not found
-- >= 0         The index of the the period in the cache
-- ----------------------------------------------------------------------------------
function findDateFast(stream, date, precise)
    local datesec = nil;
    local periodsec = nil;
    local min, max, mid;

    datesec = math.floor(date * 86400 + 0.5)

    min = 1;
    max = #stream;

    while true do
        mid = math.floor((min + max) / 2);
        periodsec = math.floor(stream[mid].datestamp * 86400 + 0.5);
        core.host:trace(datesec .. ":" .. periodsec)
        if datesec == periodsec then
            return mid;
        elseif datesec < periodsec then
            min = mid + 1;
        else
            max = mid - 1;
        end

        if min > max then
            if precise or max == #stream then
                return -1;
            else
                return max + 1;
            end
        end
    end
end
