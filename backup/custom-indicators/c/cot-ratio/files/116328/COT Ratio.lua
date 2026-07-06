-- Id: 19880
--#!/usr/bin/lua


-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=65426

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

local labels = {
  ["!090741"] = "CANADIAN DOLLAR",
  ["!092741"] = "SWISS FRANC",
  ["!095741"] = "MEXICAN PESO",
  ["!096742"] = "BRITISH POUND",
  ["!097741"] = "JAPANESE YEN",
  ["!098662"] = "U.S. DOLLAR INDEX",
  ["!099741"] = "EURO FX",
  ["!112741"] = "NEW ZEALAND DOLLAR",
  ["!232741"] = "AUSTRALIAN DOLLAR",
 	["!089741"] = "RUSSIAN RUBLE",
	["!102741"] = "BRAZILIAN REAL - CHICAGO MERCANTILE EXCHANGE",
	
 	["!1170E1"] = "VIX FUTURES",   		
  ["!042601"] = "2-YEAR U.S. TREASURY NOTES",   
  ["!043602"] = "10-YEAR U.S. TREASURY NOTES",   
  ["!044601"] = "5-YEAR U.S. TREASURY NOTES",   
 
 	["!33874A"] = "E-MINI S&P 400 STOCK INDEX",   
  ["!23977A"] = "RUSSELL 2000 MINI INDEX FUTURE",   
   ["!240741"] = "NIKKEI STOCK AVERAGE - CHICAGO MERCANTILE EXCHANGE", 
  ["!209742"] = "NASDAQ-100 STOCK INDEX (MINI)",     
  ["!138741"] = "S&P 500 STOCK INDEX - CHICAGO MERCANTILE EXCHANGE",   
  
	["!088691"] = "GOLD",
 	["!085692"] = "COPPER",   
  ["!084691"] = "SILVER",  
  ["!075651"] = "PALLADIUM",   
 	["!076651"] = "PLATINUM",
	["!067411"] = "CRUDE OIL, LIGHT SWEET - ICE FUTURES EUROPE",
	["!067651"] = "CRUDE OIL, LIGHT SWEET - NEW YORK MERCANTILE EXCHANGE",
	["!06765T"] = "BRENT CRUDE OIL LAST DAY - NEW YORK MERCANTILE EXCHANGE",
}



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("COT Ratio");
    indicator:description("Commitments of Traders Report Ratio");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	
	
    indicator.parameters:addGroup("COT Calculation");

    indicator.parameters:addString("instrument", "Instrument", " Instrument Selection" , "!098662");
    for k,v in pairs(labels) do
     indicator.parameters:addStringAlternative("instrument", v, "Select " .. v, k);
    end
	
	
 
    indicator.parameters:addString("segment", "Investor Type", " Investor Type " , "Noncommercial");
    indicator.parameters:addStringAlternative("segment", "Investor Type Noncommercial", "Investor Type Noncommercial" , "Noncommercial");
    indicator.parameters:addStringAlternative("segment", "Investor Type Commercial", "Investor Type Commercial" , "Commercial");

	
	indicator.parameters:addGroup("Style");	
	indicator.parameters:addColor("COT", "COT Index Color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", .8);
    indicator.parameters:addDouble("oversold","Oversold Level","", 0.2);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local source = nil;
local host = "www.fxcodebase.com";
local instrument = nil
local COT=nil;
local COTLong=nil;
local COTShort=nil;
local cache = {}
local Period;


local pline =  "([^,]+),([^,]+),[^,]+,[^,]+,([^,]+),([^,]+),([^,]+),([^,]+)"
local pdate = "(%d%d%d%d)(%d%d)(%d%d)"

local cache_from = math.huge
local cache_to = 0


-- Routine
function Prepare(nameOnly)
    source = instance.source;
    instrument = instance.parameters.instrument;
    segment    = instance.parameters.segment;
    

    local label=instrument or "undefined";

    if labels[instrument] ~= nil then
        label = labels[instrument];
    end


    local name = profile:id() .. "(" .. label .. ", ".. segment   .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
     -- NP= instance:addInternalStream(0, 0);
      COT = instance:addStream("COT", core.Line, name, "COT Index", instance.parameters.COT, source:first());
    COT:setPrecision(math.max(2, instance.source:getPrecision()));
	  
       COT:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		COT:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
		COT:setWidth(instance.parameters.width);
        COT:setStyle(instance.parameters.style);
   
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

      if idx > 0 then
        data = cache[idx]

        -- Get "long" and "short" values depending on segment
        local long, short = 0, 0
        if  segment == "Noncommercial" then
          long, short = data.ncl, data.ncs;
        else
          long, short = data.cl, data.cs;
        end

      
		
			  
				  
				  COT[period] =long/(long+short);
				  
            
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
        http_loader = core.makeHttpLoader()
        dt  = core.dateToTable(from) -- date table
        
        local req = http_lua.createRequest();
        local url = string.format(host .. "/cot/data?cmc=%s&from=%s", instrument:sub(2), dateToString(dt));
        
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
                code,datestamp,ncl,ncs,cl,cs = string.match(line, pline);
                -- pase date
                year,month,day = string.match(datestamp, pdate)

                data = {}
                data.datestamp = core.datetime(tonumber(year), tonumber(month), tonumber(day), 0, 0, 0)
                data.ncl=tonumber(ncl);
                data.ncs=tonumber(ncs);
                data.cl =tonumber(cl);
                data.cs =tonumber(cs);

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
