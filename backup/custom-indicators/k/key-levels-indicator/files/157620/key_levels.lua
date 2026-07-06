--
--
-- "Key Levels" Indicator
-- plot levels of support and resistance based on fractal turning points for different timeframes
-- select data sources for levels from: daily, weekly, monthly, quaterly or yearly
-- daily, weekly and monthly data can be filtered by extending fractal widths


-- original code by: SM Webb December 2024 aka Steve_W per fxcodebase
-- partly based on ideas from Paul Langham of Exact Trading https://exacttrading.com/
--  
-- Steve_W V1.0 28/12/2024    first release

-- keeping track of code version, revision and author
local version = 1;
local revision = 0;
local rev_author = "Steve_W";


-- Indicator parameters
function Init()
    indicator:name("Key Levels" .. " v" .. version .. "." .. revision);
    indicator:description("Support / Resistance levels based on fractal turning points for different timeframes");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator); 

    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addBoolean("disp_yearly", "Display Yearly Levels", "", true);
	indicator.parameters:addBoolean("disp_quarterly", "Display Quaterly Levels", "", true);
	indicator.parameters:addBoolean("disp_monthly", "Display Monthly Levels", "", false);
	indicator.parameters:addBoolean("disp_weekly", "Display Weekly Levels", "", false);
	indicator.parameters:addBoolean("disp_daily", "Display Daily Levels", "", false);
	
	indicator.parameters:addInteger("yearly_num", "Yearly Bars to Look Back", "", 10, 1, 10);
	indicator.parameters:addInteger("quarterly_num", "Quarterly Bars to Look Back", "", 12, 1, 40);
	indicator.parameters:addInteger("monthly_num", "Monthly Bars to Look Back", "", 36, 1, 120);
	indicator.parameters:addInteger("weekly_num", "Weekly Bars to Look Back", "", 52, 1, 300);
	indicator.parameters:addInteger("daily_num", "Daily Bars to Look Back", "", 30, 1, 300);
	
	indicator.parameters:addInteger("monthly_pk_filt", "Monthly reversal Filter", "Set to 0 to disable or 1-5 (weak->strong)", 1, 0, 5);
	indicator.parameters:addInteger("weekly_pk_filt", "Weekly reversal Filter", "Set to 0 to disable or 1-5 (weak->strong)", 1, 0, 5);
	indicator.parameters:addInteger("daily_pk_filt", "Daily reversal Filter", "Set to 0 to disable or 1-5 (weak->strong)", 1, 0, 5);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("yearly_col", "Yearly Line Colour","", core.rgb(128, 128, 0)); 	
    indicator.parameters:addColor("quarterly_col", "Quaterly Line Colour","", core.rgb(0, 128, 0)); 	
	indicator.parameters:addColor("monthly_col", "Monthly Line Colour","", core.rgb(128, 0, 0)); 	
	indicator.parameters:addColor("weekly_col", "Weekly Line Colour","", core.rgb(0, 0, 128)); 	
	indicator.parameters:addColor("daily_col", "Daily Line Colour","", core.rgb(128, 128, 128)); 	
	indicator.parameters:addInteger("yearly_width", "Yearly Line Width", "", 1, 1, 3);
	indicator.parameters:addInteger("monthly_width", "Monthly Line Width", "", 1, 1, 3);
    indicator.parameters:addInteger("quarterly_width", "Quarterly Line Width", "", 1, 1, 3);
    indicator.parameters:addInteger("weekly_width", "Weekly Line Width", "", 1, 1, 3);
    indicator.parameters:addInteger("daily_width", "Daily Line Width", "", 1, 1, 3);
    indicator.parameters:addInteger("support_style", "Support Line Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("support_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("resistance_style", "Resistance Line Style", "", core.LINE_DASH);
    indicator.parameters:setFlag("resistance_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("transparency", "Line Transparency","", 50); 
	
	indicator.parameters:addGroup("About");
	indicator.parameters:addInteger("version", "Version", "", version, version, version);
	indicator.parameters:addInteger("revision", "Revision", "", revision, revision, revision);
	indicator.parameters:addString("rev_author", "Revision Author", "for this code revision", rev_author);
end


local source = nil;
local transparency;
local first;
local yearly = {};
local quarterly = {};
local monthly_for_quarter = {};
local monthly = {};
local monthly_for_year = {};
local weekly = {};
local daily = {};
local loading = true;
local searching;

local offset, weekoffset;
local font;

local id = 0;		-- drawing line number
local lbl = 0;		-- label number
local n;			-- number of levels identified
local t = {};		-- bar where level was identified 
local y = {};		-- level


	
-- Initialise the indicator
function Prepare(nameOnly)
    local host = core.host;
	
	source = instance.source;
	first = source:first();
	length = instance.parameters.length;
       
    if nameOnly then
		return;
	end

	font = core.host:execute("createFont", "Arial", 12, true, false);
	
	offset = host:execute("getTradingDayOffset");
	weekoffset = host:execute("getTradingWeekOffset");
    
	-- Quarterly and Yearly require special treatment since "M3" and "M12" are not allowed in syntax
	daily = host:execute("getSyncHistory", source:instrument(), "D1", source:isBid(), instance.parameters.daily_num, 300, 301);
	weekly = host:execute("getSyncHistory", source:instrument(), "W1", source:isBid(), instance.parameters.weekly_num, 200, 201);
	monthly = host:execute("getSyncHistory", source:instrument(), "M1", source:isBid(), instance.parameters.monthly_num, 100, 101);
	monthly_for_quarter = host:execute("getSyncHistory", source:instrument(), "M1", source:isBid(), instance.parameters.quarterly_num * 3, 400, 401);	-- x3 months
	monthly_for_year = host:execute("getSyncHistory", source:instrument(), "M1", source:isBid(), instance.parameters.yearly_num * 12, 500, 501);		-- x12 months
end


-- Indicator calculation routine
function Update(period)
	local today;
	local current_bar;
   
	local name = profile:id() .. " (";
	if instance.parameters.disp_yearly == true then name = name .. instance.parameters.yearly_num .. "Y" end
	if instance.parameters.disp_quarterly == true then name = name .. " " .. instance.parameters.quarterly_num .. "Q" end
	if instance.parameters.disp_monthly == true then name = name .. " " .. instance.parameters.monthly_num .. "M" end
	if instance.parameters.disp_weekly == true then name = name .. " " .. instance.parameters.weekly_num .. "W" end
	if instance.parameters.disp_daily == true then name = name .. " " .. instance.parameters.daily_num .. "D" end
	name = name .. " Bars)";
    if loading == true then name = name .. " loading..." end
	instance:name(name);
 
	if period < source:size() - 1 then return end
	if loading then return end

    -- Generate yearly candles
	local idx = 0;
	local state = 0;
	local assigned_date = nil;
	yearly["date"] = {};
	yearly["open"] = {};
	yearly["close"] = {};
	yearly["high"] = {};
	yearly["low"] = {};
	if monthly_for_year:size() - 1 < monthly_for_year:first() then return end
	
	for i = monthly_for_year:first(), monthly_for_year:size()-1, 1 do
		local m_date = core.dateToTable(monthly_for_year:date(i));
		if state == 0 then	-- waiting for December so we can assign this date to the synthesized candle
			if m_date.month == 12 then
				assigned_date = monthly_for_year:date(i);
				state = 1
			end
		elseif state == 1 then
			if m_date.month == 1 then		-- start at January
				yearly.open[idx] = monthly_for_year.open[i];
				yearly.high[idx] = monthly_for_year.high[i];
				yearly.low[idx] = monthly_for_year.low[i];		
			end
			if monthly_for_year.high[i] > yearly.high[idx] then 
				yearly.high[idx] = monthly_for_year.high[i];
			end
			if monthly_for_year.low[i] < yearly.low[idx] then 
				yearly.low[idx] = monthly_for_year.low[i];
			end			
			if m_date.month == 12 then		-- end in December
				yearly.date[idx] = assigned_date;
				yearly.close[idx] = monthly_for_year.close[i];
				idx = idx + 1;			
				assigned_date = monthly_for_year:date(i);	-- next yearly candle is assigned this date
			end
		end
	end
	if idx == 0 then return	end
	
    
	-- Generate quarterly candles
	idx = 0;
	state = 0;
	assigned_date = nil;
	quarterly["date"] = {};
	quarterly["open"] = {};
	quarterly["close"] = {};
	quarterly["high"] = {};
	quarterly["low"] = {};
	if monthly_for_quarter:size() - 1 < monthly_for_quarter:first() then return	end
	
	for i = monthly_for_quarter:first(), monthly_for_quarter:size() - 1, 1 do
		m_date = core.dateToTable(monthly_for_quarter:date(i));
		if state == 0 then
			if m_date.month == 3 or m_date.month == 6 or m_date.month == 9 or m_date.month == 12 then	-- first quarterly candle ...
				assigned_date = monthly_for_quarter:date(i);
				state = 1
			end
		elseif state == 1 then
			if m_date.month == 1 or m_date.month == 4 or m_date.month == 7 or m_date.month == 10 then	-- start of quarters
				quarterly.open[idx] = monthly_for_quarter.open[i];
				quarterly.high[idx] = monthly_for_quarter.high[i];
				quarterly.low[idx] = monthly_for_quarter.low[i];
			end
			if monthly_for_quarter.high[i] > quarterly.high[idx] then 
				quarterly.high[idx] = monthly_for_quarter.high[i];
			end
			if monthly_for_quarter.low[i] < quarterly.low[idx] then 
				quarterly.low[idx] = monthly_for_quarter.low[i];
			end			
			if m_date.month == 3 or m_date.month == 6 or m_date.month == 9 or m_date.month == 12 then 	-- end of quarters
				quarterly.date[idx] = assigned_date;
				quarterly.close[idx] = monthly_for_quarter.close[i];
				idx = idx + 1;			
				assigned_date = monthly_for_quarter:date(i);
			end
		end
	end
	if idx == 0 then return	end
	
	-- we now have the data - clear all lines
	core.host:execute("removeAll");

	-- search for fractal turning point levels in different timeframes - filter setting sets width of fractal
	n = 0;
	t={};
	y={};
	searching = false;
	if instance.parameters.disp_daily then Search_levels("D1", period) end
	if instance.parameters.disp_weekly then Search_levels("W1", period) end
	if instance.parameters.disp_monthly then Search_levels("M1", period) end
	if instance.parameters.disp_quarterly then Search_levels("Q1", period) end
	if instance.parameters.disp_yearly then Search_levels("Y1", period) end
	if searching then return end
end


function Search_levels(candle_type, p)
	local i, j;
	local today, current_bar;
	local col, width, num, data, search;
	local peak;
	
	-- define search and drawing style
	if candle_type == "D1" then 
		col = instance.parameters.daily_col;
		width = instance.parameters.daily_width;
		num = instance.parameters.daily_num;
		search = instance.parameters.daily_pk_filt;
		data = daily;
	end
	if candle_type == "W1" then
		col = instance.parameters.weekly_col;
		width = instance.parameters.weekly_width;
		num = instance.parameters.weekly_num;
		search = instance.parameters.weekly_pk_filt;
		data = weekly;		
	end
	if candle_type == "M1" then
		col = instance.parameters.monthly_col;
		width = instance.parameters.monthly_width;
		num = instance.parameters.monthly_num;
		search = instance.parameters.monthly_pk_filt;
		data = monthly;
	end
	if candle_type == "Q1" then
		col = instance.parameters.quarterly_col;
		width = instance.parameters.quarterly_width;
		num = instance.parameters.quarterly_num;
		search = 0;
		data = quarterly;
	end
	if candle_type == "Y1" then
		col = instance.parameters.yearly_col;
		width = instance.parameters.yearly_width;
		num = instance.parameters.yearly_num;
		search = 0;
		data = yearly;
	end
	
	-- find current bar for data timeframe
	if candle_type == "Y1" then
		current_bar = table.getn(yearly.date);
	elseif candle_type == "Q1" then
		current_bar = table.getn(quarterly.date);
	else
		today = core.getcandle(candle_type, source:date(p), offset, weekoffset);
		today = math.floor(today * 86400 + 0.5) / 86400;
		current_bar = core.findDate(data, today, false);	
		if current_bar < 0 then
			searching = true;
			return;
		end
	end
    
	-- search the data
	local scan_start = current_bar - num + search;
	local scan_end = current_bar - 1 - search;
	if candle_type == "Y1" or candle_type == "Q1" then
		scan_end = current_bar;
		if scan_start < 0 or scan_end < 1 then 
			searching = true;
			return
		end
	end
	
	for i = scan_end, scan_start, -1 do
		
		-- basic fractal search
		if search == 0 or candle_type == "Y1" or candle_type == "Q1" then
			n = n + 1;
			y[n] = data.high[i];
			if candle_type == "Y1" or candle_type == "Q1" then
				t[n] = data.date[i];
			else
				t[n] = data:date(i);             
			end
			id = id + 1;
			core.host:execute("drawLine", id, t[n], y[n], source:date(p)+1, y[n], col, instance.parameters.resistance_style, width);
			
			n = n + 1;
			y[n] = data.low[i];
            if candle_type == "Y1"  or candle_type == "Q1" then
				t[n] = data.date[i];
            else
				t[n] = data:date(i);             
            end
			id = id + 1;
			core.host:execute("drawLine", id, t[n], y[n], source:date(p)+1, y[n], col, instance.parameters.support_style, width);
			
		else
			-- optional deeper fractal search on daily, weekly and monthly levels
			peak = true;
			for j = 0, search, 1 do
				if data.high[i] < data.high[i - j] or data.high[i] < data.high[i + j] then peak = false end
			end	
			if peak then
				n = n + 1;
				y[n] = data.high[i];
				t[n] = data:date(i);             
				id = id + 1;
				core.host:execute("drawLine", id, t[n], y[n], source:date(p)+1, y[n], col, instance.parameters.resistance_style, width);
			end
			
			peak = true;
			for j = 0, search, 1 do
				if data.low[i] > data.low[i - j] or data.low[i] > data.low[i + j] then peak = false end
			end	
			if peak then
				n = n + 1;
				y[n] = data.low[i];
				t[n] = data:date(i);             
				id = id + 1;
				core.host:execute("drawLine", id, t[n], y[n], source:date(p)+1, y[n], col, instance.parameters.support_style, width);
			end		
		end
	end
end
		

-- Called when the instance is being released
function ReleaseInstance()
	host:execute("deleteFont", font);
end


local loading_q = false;
local loading_m = false;
local loading_w = false;
local loading_d = false;
local loading_y = false;
function AsyncOperationFinished(cookie, success, message)
    if cookie == 101 then
		loading_m = true;
	elseif cookie == 100 then
		assert(success, error);
		loading_m = false;
	end
    if cookie == 201 then
		loading_w = true;
	elseif cookie == 200 then
		assert(success, error);
		loading_w = false;
	end
    if cookie == 301 then
		loading_d = true;
	elseif cookie == 300 then
		assert(success, error);
		loading_d = false;
	end
    if cookie == 401 then
		loading_q = true;
	elseif cookie == 400 then
		assert(success, error);
		loading_q = false;
	end
	   if cookie == 501 then
		loading_y = true;
	elseif cookie == 500 then
		assert(success, error);
		loading_y = false;
	end
 
	if loading_q or loading_y or loading_m or loading_w or loading_d then
		loading = true;
	else
		loading = false;
		instance:updateFrom(0);
	end
 end

