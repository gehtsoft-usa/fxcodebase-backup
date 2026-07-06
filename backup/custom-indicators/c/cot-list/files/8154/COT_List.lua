--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

local CODE = {"!088691", "!090741", "!092741", "!095741", "!096742", "!097741", "!098662", "!099741", "!112741", "!232741"};

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("COT List");
    indicator:description("Commitments of Traders Report");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addColor("COTl", "Label Color", "", core.rgb(0, 0, 0)); 
    indicator.parameters:addString("host", "COT host", " COT host", "www.fxcodebase.com"); 
    indicator.parameters:addBoolean("Relative", "Relative", "Relative" ,  false);


    indicator.parameters:addString("segment", "Investor Type", " Investor Type " , "Noncommercial");
    indicator.parameters:addStringAlternative("segment", "Investor Type Noncommercial", "Investor Type Noncommercial" , "Noncommercial");
    indicator.parameters:addStringAlternative("segment", "Investor Type Commercial", "Investor Type Commercial" , "Commercial");
	indicator.parameters:addInteger("size", "Font Size", "", 20);
end

local SHORT ={"XAU", "CAD", "CHF", "MXN", "GBP", "JPY", "USD", "EUR", "NZD", "AUD"}

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local source = nil;
local host = nil
local instrument = nil
local COT={};
local COTLong={};
local COTShort={};

local oldCOT={};
local oldCOTLong={};
local oldCOTShort={};

local cache = {}
local Relative=nil;

local pline =  "([^,]+),([^,]+),[^,]+,[^,]+,([^,]+),([^,]+),([^,]+),([^,]+)"
local pdate = "(%d%d%d%d)(%d%d)(%d%d)"

local cache_from = math.huge
local cache_to = 0

local font;
local fontsize;

local BS;

local day_offset, week_offset;


-- Routine
function Prepare()
    source = instance.source;
	fontsize=instance.parameters.size;  
    segment    = instance.parameters.segment;
    host       = instance.parameters.host;    
    Relative   = instance.parameters.Relative;
	
	local s, e;
	 
	day_offset = core.host:execute("getTradingDayOffset");
    week_offset = core.host:execute("getTradingWeekOffset");

    s, e = core.getcandle("W1", core.now(), day_offset, week_offset);
    BS=e-s;
	--BS=math.floor((e - s) * 86400 + 0.5) ; 

    local name = profile:id() .. "(" ..  segment .. ", " .. (Relative and "Relative" or "Absolute") ..  ")";
    instance:name(name);
	
	 font = core.host:execute("createFont", "Courier", fontsize, false, false);
  
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values

local LAST=nil;
function Update(period)
	if LAST ==  nil then
		LAST= source:serial(period);
	end
   
	if period < source:size()-1 or LAST== source:serial(period)  then   
		return;
	end
   
	LAST= source:serial(period);

	local i;
   
	local i = source:size();
	local first = source:first();
	local size=source:barSize(); 

	for i = 1, 10, 1 do
		cache_from = math.huge;
		cache_to = 0
		instrument = CODE[i];
		local data={};
		local olddata={};
		if source:date(first) < cache_from then
			ReloadCache(source:date(first));
		else
			if source:date(first+i - 1) > cache_to then
				ReloadCache(source:date(cache_to));
			end
		end

		local idx;
		local oldidx;
		if #cache > 0 then
			idx = findDateFast(cache, source:date(period), false);
			oldidx = findDateFast(cache, source:date(period)-BS, false);
		else
			idx = 0;
			oldidx = 0;
		end
		if idx > 0 and #cache > 0 then
			data = cache[idx];
			olddata = cache[oldidx]
			--  data = cache[#cache-1];
			-- olddata = cache[#cache-2];
			if olddata == nil then
				return;
			end

			-- Get "long" and "shor" values depending on segment
			local long, short;
			local oldlong, oldshort;

			if  segment == "Noncommercial" then
				long, short = data.ncl, data.ncs;
				oldlong, oldshort = olddata.ncl, olddata.ncs;
			else
				long, short = data.cl, data.cs;
				oldlong, oldshort = olddata.cl, olddata.cs;
			end

			-- Calculate "denominator" in case of Relative indicator, or leave it 1
			local denominator = 1;
			local olddenominator = 1;
			if Relative then
				denominator = (long + short) / 100;
				olddenominator = (oldlong + oldshort) / 100;
			end

			COT[i] = (long - short) / denominator;				
			COTLong[i] = long / denominator;
			COTShort[i] = -short / denominator;

			oldCOT[i] = (oldlong - oldshort) / olddenominator;				
			oldCOTLong[i] = oldlong / olddenominator;
			oldCOTShort[i] = -oldshort / olddenominator;
		else
			COT[i] = 0;
			COTLong[i] = 0;
			COTShort[i] = 0;
			oldCOT[i] = 0;
			oldCOTLong[i] = 0;
			oldCOTShort[i] = 0;
		end
			
		core.host:execute("drawLabel1", 1,200, core.CR_LEFT,  20, core.CR_TOP, core.H_Left, core.V_Center,
								  font, instance.parameters.COTl, "Short"  );
		
		core.host:execute("drawLabel1", 2,300, core.CR_LEFT,  20, core.CR_TOP, core.H_Left, core.V_Center,
								  font, instance.parameters.COTl, "Long"  );		
								  
		core.host:execute("drawLabel1", 3,400, core.CR_LEFT,  20, core.CR_TOP, core.H_Left, core.V_Center,
								  font, instance.parameters.COTl, "Sum"  );	
						
		local COLOR;			
		if COTLong[i]>  oldCOTLong[i] then
			COLOR=core.rgb(0, 255, 0);
		elseif COTLong[i]<  oldCOTLong[i] then
			COLOR=core.rgb(255, 0, 0);			 
		else
			COLOR=core.rgb(0, 0, 255);
		end			 
			
		core.host:execute("drawLabel1", 10+ i,300, core.CR_LEFT,  20+20*i, core.CR_TOP, core.H_Left, core.V_Center,
								  font, COLOR, string.format("%." .. 0 .. "f",  COTLong[i] )  );
								  
		if COTShort[i]>  oldCOTShort[i] then
			COLOR=core.rgb(0, 255, 0);
		elseif COTShort[i]<  oldCOTShort[i] then
			COLOR=core.rgb(255, 0, 0);			 
		else
			COLOR=core.rgb(0, 0, 255);
		end
		
		core.host:execute("drawLabel1", 20+i,200, core.CR_LEFT,  20+20*i, core.CR_TOP, core.H_Left, core.V_Center,
								  font, COLOR, string.format("%." .. 0 .. "f",  COTShort[i] )  );
								  
		if COT[i]>  oldCOT[i] then
			COLOR=core.rgb(0, 255, 0);
		elseif COT[i]<  oldCOT[i] then
			COLOR=core.rgb(255, 0, 0);			 
		else
			COLOR=core.rgb(0, 0, 255);
		end		
		
		core.host:execute("drawLabel1", 30+i,400, core.CR_LEFT,  20+20*i, core.CR_TOP, core.H_Left, core.V_Center,
								  font, COLOR, string.format("%." .. 0 .. "f",  COT[i] )   );
								  
		core.host:execute("drawLabel1", 40+ i,100, core.CR_LEFT,  20+20*i, core.CR_TOP, core.H_Left, core.V_Center,
								  font, instance.parameters.COTl,SHORT[i]  );
	end
end

function ReleaseInstance()
    core.host:execute("deleteFont", font); 
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
        loader = core.makeHttpLoader()
        dt  = core.dateToTable(from) -- date table
		params = '/cot/data?cmc=' .. instrument:sub(2) .. '&from=' .. dateToString(dt)
	    loader:load(host, 80, params, false)
        
        body = loader:response()
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

