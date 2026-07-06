-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=74137
-- "vol_profile_v2_1.lua" - version 2.1
--
-- Drag-Drop Volume Profile Tool
-- 1) copy 16x16 vol_profile.png icon into C:\Program Files (x86)\Candleworks\FXTS2\Tools\Custom\
-- 2) copy "vol_profile_v2_1.lua" to a temp directory
-- 3) install tool using normal method - <I> short-cut key, "Manage Extension...", or "Import Extension...", importing from temp directory
-- 4) the tool should install into ...\Tools\Custom\ and register the icon to create a custom toolbar button
--
-- Activate tool via custom toolbar button, or right click->add tool->volume profile -> drag+drop a box over area of interest
-- edit / set default parameters via right click / double clicking on box instance
-- using mouse, re-size+move box to dynamically observe how volume changes with price and time 
-- right-click -> show/hide breakout guidelines
--
-- original code by: SM Webb September 2023 aka Steve_W per fxcodebase
--
-- Steve_W V1.0 9/9/2023    first release
-- Steve_W V2.0 10/9/2023   added stats features for breakouts
-- Steve_W V2.1 15/10/2023  updated to four corners, added version, renorm on box move option
--                          fixed code errors on changing instruments hides tool when returning to same instrument (tracking development reference 915)

-- template for tool code taken from here: http://fxcodebase.com/code/viewtopic.php?f=17&t=68571
--

-- code version, revision and author
local version = 2;
local revision = 1;
local rev_author = "Steve_W";


local source = {};
local loading = false;
local max_volume = 0;	-- for normalisation of histogram 
local max_hist = 0;

function Init()
    tool:name("Volume Profile");
    tool:description("Drag drop volume profile box");
    tool:icon("vol_profile.png");
	tool.creationStrategy:setPattern(core.DragClick);
    tool.creationStrategy:setMaxClickCount(0);
	--tool.creationStrategy:setNeedParamsAfterPattern(true);	-- uncomment to immediately edit parameters after drawing box
    tool:setTag("group", "Tools");
    tool:setTag("orderInGroup", "1");
    tool:setTag("NonResetableParameters", "loaded_on_instrument,start_rate,start_date,end_rate,end_date"); -- not sure this line works!
    tool:setTag("requiredPaneType", "hasStreams");

	tool.parameters:addGroup("Location");
	tool.parameters:addString("loaded_on_instrument","Loaded on Instrument", "DON'T CHANGE - variable is used to track which instrument the tool was drawn on - check Chart Elements", "");
	tool.parameters:setFlag("loaded_on_instrument", core.FLAG_INSTRUMENTS);
	tool.parameters:addDate("start_date", "Date start", "", 0);
    tool.parameters:setFlag("start_date", core.FLAG_DATETIME);
    tool.parameters:addDate("end_date", "Date end", "", 0);
    tool.parameters:setFlag("end_date", core.FLAG_DATETIME);
    tool.parameters:addDouble("start_rate", "Rate top", "", 0);
    tool.parameters:addDouble("end_rate", "Rate bottom", "", 0);

	tool.parameters:addGroup("Calculation");
	tool.parameters:addInteger("resolution", "Resolution", "Histogram Resolution in Pips", 1, 1, 10);
	local TF = {"m1", "m5", "m15", "m30", "H1", "H4", "Chart"};
	tool.parameters:addString("period", "Source Data Period", "", "m5"); 
    local i;
	for i = 1, 6, 1 do
		tool.parameters:addStringAlternative("period", TF[i], "", TF[i]);
    end
	
	tool.parameters:addGroup("Display");
	tool.parameters:addInteger("hist_width", "Histogram Width", "in pixels", 100, 50, 200);
	tool.parameters:addString("hist_location", "Histogram Location", "", "Left of Box")
	tool.parameters:addStringAlternative("hist_location", "Left of Box", "", "Left of Box");
    tool.parameters:addStringAlternative("hist_location", "Left of Screen", "", "Left of Screen");
    tool.parameters:addStringAlternative("hist_location", "Right of Box", "", "Right of Box");
    tool.parameters:addStringAlternative("hist_location", "Right of Screen", "", "Right of Screen");
	tool.parameters:addBoolean("renormalise_on_box_move", "Renormalise on Box Move", "", false);
	tool.parameters:addBoolean("show_mean_level", "Show Mean Level", "", false);
	tool.parameters:addBoolean("extend_mean_level", "Extend Mean Level", "", false);
	tool.parameters:addBoolean("show_normal_distribution", "Show Normal Distribution", "", false);
	tool.parameters:addBoolean("show_breakout_level", "Show Breakout Level", "", false);
	tool.parameters:addBoolean("show_target_level", "Show Target Level", "", false);
	tool.parameters:addInteger("breakout_sigma_multiplier", "Breakout Sigma Multiplier", "", 3, 0.5, 4);
	tool.parameters:addInteger("breakout_target_multiplier", "Breakout Target Multiplier", "", 1, 0.5, 4);
	
    tool.parameters:addGroup("Style");
    tool.parameters:addColor("box_color", "Box Colour", "", core.rgb(0, 64, 128));
	tool.parameters:addColor("hist_color", "Histogram Colour", "", core.rgb(255, 255, 0));
	tool.parameters:addColor("mean_color", "Mean Colour", "", core.rgb(0, 255, 0));
	tool.parameters:addColor("normal_distribution_color", "Normal Distribution Colour", "", core.rgb(0, 128, 255));
	tool.parameters:addColor("breakout_level_color", "Breakout Level Colour", "", core.rgb(255, 0, 0));
	tool.parameters:addColor("target_level_color", "Target Level Colour", "", core.rgb(255, 255, 0));
	tool.parameters:addColor("text_color", "Text Colour", "", core.rgb(255, 255, 0));
    tool.parameters:addInteger("line_width", "Line Width", "", 2, 1, 5);
    tool.parameters:addInteger("line_style", "Line Style", "", core.LINE_SOLID);
    tool.parameters:setFlag("line_style", core.FLAG_LINE_STYLE);
    tool.parameters:addInteger("box_transparency", "Box Transparency", "0 - opaque, 100 - transparent", 70, 0, 100);
	tool.parameters:addInteger("hist_transparency", "Histogram Transparency", "0 - opaque, 100 - transparent", 50, 0, 100);

	tool.parameters:addGroup("About");
	tool.parameters:addInteger("version", "Version", "", version, version, version);
	tool.parameters:addInteger("revision", "Revision", "", revision, revision, revision);
	tool.parameters:addString("rev_author", "Revision Author", "for this code revision", rev_author);
end


function CreationStarted(Parameters)
end


local start_rate;
local start_date;
function Click(x, y, price, date)
    local pane = core.host.Window.CurrentPane;
    local stream = pane.Data:getStream(0);
	instance.parameters.loaded_on_instrument = stream:instrument();

	start_rate = price;
    start_date = date;
    instance.parameters.start_rate = price;
    instance.parameters.start_date = date;
    instance.parameters.end_rate = price;
    instance.parameters.end_date = date;
end


function DoubleClick(x, y, price, date)
end


local PNT_TL = 1;	-- top left
local PNT_BR = 2;	-- bottom right
local PNT_TR = 3;	-- top right
local PNT_BL = 4;	-- bottom left
local last_stream_size = 0;
function UpdateReferencePoints()
    local pane = core.host.Window.CurrentPane;
    local stream = pane.Data:getStream(0);
    last_stream_size = stream:size();
    local referencePoints = core.host.ReferencePoints;
    referencePoints:setReferencePoint(PNT_TL,
										instance.parameters.start_date,
										instance.parameters.start_rate,
										referencePoints.DATE + referencePoints.PRICE,
										instance.parameters.box_color,
										2);
    referencePoints:setReferencePoint(PNT_BR,
										instance.parameters.end_date,
										instance.parameters.end_rate,
										referencePoints.DATE + referencePoints.PRICE,
										instance.parameters.box_color,
										2);
	referencePoints:setReferencePoint(PNT_TR,
										instance.parameters.end_date,
										instance.parameters.start_rate,
										referencePoints.DATE + referencePoints.PRICE,
										instance.parameters.box_color,
										2);
	referencePoints:setReferencePoint(PNT_BL,
										instance.parameters.start_date,
										instance.parameters.end_rate,
										referencePoints.DATE + referencePoints.PRICE,
										instance.parameters.box_color,
										2);
end


function Drag(x, y, price, date)    
    instance.parameters.end_rate = price;
    instance.parameters.end_date = date;
    UpdateReferencePoints();
end


function DragEnd(x, y, price, date)
end


function CreationFinished()
end


local movingPointID;
function MoveReferencePointStart(id)
    movingPointID = id;
end


function MoveReferencePoint(x, y, price, date)
    if movingPointID == PNT_TL then
        instance.parameters.start_date = date;
        instance.parameters.start_rate = price;
    elseif movingPointID == PNT_BR then
        instance.parameters.end_date = date;
        instance.parameters.end_rate = price;
    elseif movingPointID == PNT_TR then
        instance.parameters.end_date = date;
        instance.parameters.start_rate = price;
    elseif movingPointID == PNT_BL then
        instance.parameters.start_date = date;
        instance.parameters.end_rate = price;
	end
    UpdateReferencePoints();
	max_volume = 0;	-- reset histogram normalisation if size of box is changed
end


function MoveReferencePointFinished()
end


local start_rate = nil;
local start_period = nil;
local start_rate_start;
local period_1_start;
local end_rate_start;
local period_2_start;
function MoveStart()
    local pane = core.host.Window.CurrentPane;
    stream = pane.Data:getStream(0);
    
    start_rate = nil;
    start_period = nil;
    start_rate_start = instance.parameters.start_rate;
    period_1_start = core.host:execute("calculatePositionOfDate", stream, instance.parameters.start_date);
    end_rate_start = instance.parameters.end_rate;
    period_2_start = core.host:execute("calculatePositionOfDate", stream, instance.parameters.end_date);
end


function Move(x, y, price, date)
    local pane = core.host.Window.CurrentPane;
    stream = pane.Data:getStream(0);
    if start_rate == nil then
        start_rate = price;
        start_period = core.host:execute("calculatePositionOfDate", stream, date);
    else
        local rate_diff = price - start_rate;
        local period_diff = core.host:execute("calculatePositionOfDate", stream, date) - start_period;
        instance.parameters.start_rate = start_rate_start + rate_diff;
        instance.parameters.start_date = core.host:execute("calculateDate", stream, period_1_start + period_diff);
        instance.parameters.end_rate = end_rate_start + rate_diff;
        instance.parameters.end_date = core.host:execute("calculateDate", stream, period_2_start + period_diff);
        UpdateReferencePoints();
    end
	if instance.parameters.renormalise_on_box_move == true then
		max_volume = 0;	-- reset histogram normalisation? since we have moved the box
	end
end


function MoveFinished()
    start_rate = nil;
    start_period = nil;
end


function get_point_coordinates(date, price, context)
    local x, x1, x2 = context:positionOfDate(date);
    local visible, y = context:pointOfPrice(price);
    return x, y;
end


local BOX_PEN = 1;
local BOX_BRUSH = 2;
local HIST_PEN = 3;
local HIST_BRUSH = 4;
local MEAN_PEN = 5;
local BREAKOUT_PEN = 6;
local TARGET_PEN = 7;
local FIT_PEN = 8;
local init = false;
function Draw(stage, context)
	local pane = core.host.Window.CurrentPane;
	local stream = pane.Data:getStream(0);
			
    if stage == 2 then
		-- ignore drawing+loading if box was not drawn on the currently displayed instrument (prevents slowdown and hanging)
		if instance.parameters.loaded_on_instrument ~= stream:instrument() then return end
	
        if not init then
            context:createPen(BOX_PEN,
								context:convertPenStyle(core.LINE_SOLID),
								1,
								instance.parameters.box_color);
            context:createSolidBrush(BOX_BRUSH,
										instance.parameters.box_color);
            box_transparency = context:convertTransparency(instance.parameters.box_transparency);
            context:createPen(HIST_PEN,
								context:convertPenStyle(core.LINE_SOLID),
								1,
								instance.parameters.hist_color);
			context:createSolidBrush(HIST_BRUSH,
										instance.parameters.hist_color);
            hist_transparency = context:convertTransparency(instance.parameters.hist_transparency);
            context:createPen(MEAN_PEN,
								context:convertPenStyle(instance.parameters.line_style),
								instance.parameters.line_width,
								instance.parameters.mean_color);
            context:createPen(BREAKOUT_PEN,
								context:convertPenStyle(instance.parameters.line_style),
								instance.parameters.line_width,
								instance.parameters.breakout_level_color);
            context:createPen(TARGET_PEN,
								context:convertPenStyle(instance.parameters.line_style),
								instance.parameters.line_width,
								instance.parameters.target_level_color);
		    context:createPen(FIT_PEN,
								context:convertPenStyle(instance.parameters.line_style),
								instance.parameters.line_width,
								instance.parameters.normal_distribution_color);
	
			local from, to;
			from = stream:date(stream:first());
			if stream:isAlive() then
				to = 0;
			else
				to = stream:date(stream:size() - 1);
			end
	
			-- source loaded bid or ask with desired bar size
			source = core.host:execute("getHistory", 100, stream:instrument(), instance.parameters.period, from, to, stream:isBid());
			loading = true;   	
			
			loaded_instrument = stream:instrument();
		    init = true;
        end

        local pane = core.host.Window.CurrentPane;
        local stream = pane.Data:getStream(0);
        if last_stream_size ~= stream:size() then
            UpdateReferencePoints();
        end
        
        local x1, y1 = get_point_coordinates(instance.parameters.start_date, instance.parameters.start_rate, context);
        local x2, y2 = get_point_coordinates(instance.parameters.end_date, instance.parameters.end_rate, context);
		x1, x2 = Sort(x1, x2);
		y1, y2 = Sort(y1, y2);
		
        context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
        context:drawRectangle(BOX_PEN, BOX_BRUSH, x1, y1, x2, y2, box_transparency);
        context:resetClipRectangle();
		
		local pane = core.host.Window.CurrentPane;
        stream = pane.Data:getStream(0);
        if last_stream_size ~= stream:size() then
            UpdateReferencePoints();
        end
		
		local text;
		local fit_error = 0;
		if loading == true then
			text = "Loading...";
		else
			text = "";
			local hist = Calculate_profile();
			
			-- measure histogram and draw stats
			local hist_mode, hist_mean, hist_sigma = Calculate_stats(hist);
			local y;
			if instance.parameters.show_target_level == true then
				local delta_n_sigma = hist_sigma * instance.parameters.breakout_sigma_multiplier * 2;	-- recommend +/-3 sigma
				text = Round_dp(delta_n_sigma, 1)  .. " pips";
				y = y2 - (y2 - y1) / hist:size() * (hist_mean + instance.parameters.breakout_sigma_multiplier * hist_sigma
					+ delta_n_sigma * instance.parameters.breakout_target_multiplier);
				context:drawLine(TARGET_PEN, x2 + (x2 - x1) / 4, y, x2, y);
				y = y2 - (y2 - y1) / hist:size() * (hist_mean - instance.parameters.breakout_sigma_multiplier * hist_sigma
					- delta_n_sigma * instance.parameters.breakout_target_multiplier);
				context:drawLine(TARGET_PEN, x2 + (x2 - x1) / 4, y, x2, y);
			end
			if instance.parameters.show_mean_level == true then
				y = y2 - (y2 - y1) * hist_mean / hist:size()
				if instance.parameters.extend_mean_level == false then
					context:drawLine(MEAN_PEN, x1, y, x2, y);
				else
					context:drawLine(MEAN_PEN, x1, y, context:right(), y);
				end
			end
			if instance.parameters.show_breakout_level == true then
				y = y2 - (y2 - y1) / hist:size() * (hist_mean + instance.parameters.breakout_sigma_multiplier * hist_sigma);
				context:drawLine(BREAKOUT_PEN, x1, y, x2, y);
				y = y2 - (y2 - y1) / hist:size() * (hist_mean - instance.parameters.breakout_sigma_multiplier * hist_sigma);
				context:drawLine(BREAKOUT_PEN, x1, y, x2, y);
			end
			
			-- draw the histogram
			local i;
			for i = 1, hist:size(), 1 do
				y = y2 - (y2 - y1) * i / hist:size();
				local dy = (y2 - y1) / hist:size();
				if instance.parameters.hist_location == "Left of Box" then
					context:drawRectangle(HIST_PEN,
											HIST_BRUSH,
											x1 - instance.parameters.hist_width - 10,
											y - dy / 2,
											x1 - instance.parameters.hist_width - 10 + hist[i],
											y + dy / 2,
											hist_transparency);
				elseif instance.parameters.hist_location == "Left of Screen" then
					context:drawRectangle(HIST_PEN,
											HIST_BRUSH,
											context:left() + 10,
											y - dy / 2,
											context:left() + 10 + hist[i],
											y + dy / 2,
											hist_transparency);
				elseif instance.parameters.hist_location == "Right of Box" then
					context:drawRectangle(HIST_PEN,
											HIST_BRUSH,
											x2 + instance.parameters.hist_width + 10,
											y - dy / 2,
											x2 + instance.parameters.hist_width + 10 - hist[i],
											y + dy / 2,
											hist_transparency);
				elseif instance.parameters.hist_location == "Right of Screen" then
					context:drawRectangle(HIST_PEN,
											HIST_BRUSH,
											context:right() - 10,
											y - dy / 2,
											context:right() - 10 - hist[i],
											y + dy / 2,
											hist_transparency);
				end
			end
			
			-- display idealised normal distribution using hist_mean and hist_sigma 
			if instance.parameters.show_normal_distribution == true then
				local fx;
				local prev_x, prev_y;
				local x;
				fit_error = 0;
				local fx_scale = max_hist * (hist_sigma * math.sqrt(2 * math.pi));
				for i = 1, hist:size(), 1 do
					y = y2 - (y2 - y1) * i / hist:size();
					fx = 1 / (hist_sigma * math.sqrt(2 * math.pi)) * math.exp(-(i - hist_mean)^2 / (2 * hist_sigma^2));
					fx = fx * fx_scale;
					fit_error = fit_error + (fx - hist[i])^2;
					if instance.parameters.hist_location == "Left of Box" then
						x = x1 - instance.parameters.hist_width - 10 + fx;
					elseif instance.parameters.hist_location == "Left of Screen" then
						x = context:left() + 10 + fx;
					elseif instance.parameters.hist_location == "Right of Box" then
						x = x2 + instance.parameters.hist_width + 10 - fx;
					elseif instance.parameters.hist_location == "Right of Screen" then
						x = context:right() - 10 - fx;
					end
					if i > 1 then
						context:drawLine(FIT_PEN,
											prev_x,
											prev_y,
											x,
											y);
					end
					prev_x = x;
					prev_y = y;
				end
				fit_error = math.sqrt(fit_error / hist:size()) / max_hist * 100;	-- rms error - arbitrary units
			end
			
		end
		
		local width, height = context:measureText(1, text, 0);
		context:drawText(1, text, instance.parameters.text_color, -1, x1, y1 - 1 * height, x1 + width, y1 - 0 * height, context.LEFT + context.EXPANDTABS);
		if instance.parameters.show_normal_distribution == true then
			text = "Error = " .. Round_dp(fit_error, 1);
			width, height = context:measureText(1, text, 0);
			context:drawText(1, text, instance.parameters.text_color, -1, x1, y2 + 0 * height, x1 + width, y2 + 1 * height, context.LEFT + context.EXPANDTABS);
		end	
    end
end


-- Calculate volume-price histogram
function Calculate_profile()
	local i, j;
	local end_bar = core.findDate(source, instance.parameters.end_date, false);
	local start_bar = core.findDate(source, instance.parameters.start_date, false);
	local start_rate = instance.parameters.start_rate;
	local end_rate = instance.parameters.end_rate;
	
	-- re-order box coordinates
	start_bar, end_bar = Sort(start_bar, end_bar);
	end_rate, start_rate = Sort(start_rate, end_rate);
	
	-- create correctly sized and zeroed histogram
	local row = core.host:findTable("Offers"):find("Instrument", source:instrument());
	local point_size = row.PointSize;
	local hist_size = math.floor((start_rate - end_rate) / point_size / instance.parameters.resolution + 0.5);
	local hist = core.makeArray(hist_size);
	for i = 1, hist_size, 1 do
		hist[i] = 0;
	end
	
	-- build histogram
	for i = start_bar, end_bar, 1 do
		local vol_divisions = math.floor((source.high[i] - source.low[i]) / point_size / instance.parameters.resolution + 0.5);
		local vol_fraction = source.volume[i] / vol_divisions;
		local pip_index = math.floor((source.low[i] - end_rate) / point_size / instance.parameters.resolution + 0.5);
		for j = 1, vol_divisions, 1 do	-- evenly spread bar volume over histogram 
			if j + pip_index > 0 and j + pip_index < hist_size then
				hist[j + pip_index] = hist[j + pip_index] + vol_fraction; 
			end
		end
	end
	
	-- rescale and normalise histogram 
	local current_max = 0;
	for i = 1, hist_size, 1 do
		if hist[i] > current_max then
			current_max = hist[i];
			hist_skew = i;
		end
		if hist[i] > max_volume then max_volume = hist[i] end
	end
	if max_volume > 0 then
		max_hist = 0;
		for i = 1, hist_size, 1 do
			hist[i] = instance.parameters.hist_width * hist[i] / max_volume;	-- normalise 0-100
			if hist[i] > max_hist then max_hist = hist[i] end
		end
	end
	
	return hist;
end


-- measure histogram statistics
function Calculate_stats(hist)
	local i;
	local mode = 0;
	local mean;
	local sigma;
	local sum_ih = 0;
	local sum_h = 0;
	for i = 1, hist:size(), 1 do
		if hist[i] > mode then
			current_max = hist[i];
			mode = i;
		end
		sum_ih = sum_ih + i * hist[i];
		sum_h = sum_h + hist[i];
	end
	mean = sum_ih / sum_h;
	local sum_s = 0;
	for i = 1, hist:size(), 1 do
		sum_s = sum_s + hist[i] * (i - mean)^2;
	end
	sigma = math.sqrt(sum_s / sum_h);
	return mode, mean, sigma;
end


function Sort(a, b)
	if a > b then return b, a end
	return a, b;
end


local init_add_cmd = false;
local SHOW_BREAKOUT_GUIDELINES = 200;
local HIDE_BREAKOUT_GUIDELINES = 201;
function Prepare(onlyName)
    local pane = core.host.Window.CurrentPane;
	local stream = pane.Data:getStream(0);
	
	local name = profile:name() .. " (" .. instance.parameters.loaded_on_instrument .. ")";	-- identify the name & instrument the tool was drawn on
    instance:name(name);
    
    if onlyName then return end
	
	if init_add_cmd == false and 
		stream:instrument() == instance.parameters.loaded_on_instrument	-- only add if display instrument is same as the one the tool was drawn on
	then
		core.host:execute("addCommand", SHOW_BREAKOUT_GUIDELINES, "Show Breakout Guidelines", "");
		core.host:execute("addCommand", HIDE_BREAKOUT_GUIDELINES, "Hide Breakout Guidelines", "");
		init_add_cmd = true;
	end
    
	init = false;
    last_stream_size = 0;
    UpdateReferencePoints();
end


local temp_params;
function CheckParameters(params)
    temp_params = params;
    return profile:name();
end


function ChangeParameters()
    -- copy all the params because of FXTS2 bug
	instance.parameters.loaded_on_instrument = temp_params.loaded_on_instrument;
    instance.parameters.start_date = temp_params.start_date;
    instance.parameters.end_date = temp_params.end_date;
    instance.parameters.start_rate = temp_params.start_rate;
    instance.parameters.end_rate = temp_params.end_rate;
    instance.parameters.resolution = temp_params.resolution;
    instance.parameters.period = temp_params.period;
    instance.parameters.hist_width = temp_params.hist_width;
    instance.parameters.hist_location = temp_params.hist_location;
    instance.parameters.renormalise_on_box_move = temp_params.renormalise_on_box_move;
    instance.parameters.show_mean_level = temp_params.show_mean_level;
    instance.parameters.extend_mean_level = temp_params.extend_mean_level;
    instance.parameters.show_normal_distribution = temp_params.show_normal_distribution;
    instance.parameters.show_breakout_level = temp_params.show_breakout_level;
    instance.parameters.show_target_level = temp_params.show_target_level;
    instance.parameters.breakout_sigma_multiplier = temp_params.breakout_sigma_multiplier;
    instance.parameters.breakout_target_multiplier = temp_params.breakout_target_multiplier;
    instance.parameters.box_color = temp_params.box_color;
    instance.parameters.hist_color = temp_params.hist_color;
    instance.parameters.mean_color = temp_params.mean_color;
	instance.parameters.normal_distribution_color = temp_params.normal_distribution_color;
    instance.parameters.breakout_level_color = temp_params.breakout_level_color;
    instance.parameters.target_level_color = temp_params.target_level_color;
    instance.parameters.text_color = temp_params.text_color;
    instance.parameters.line_width = temp_params.line_width;
    instance.parameters.box_transparency = temp_params.box_transparency;
    instance.parameters.hist_transparency = temp_params.hist_transparency;
    instance.parameters.version = temp_params.version;
    instance.parameters.revision = temp_params.revision;
    	
	Prepare(false);
end


function AsyncOperationFinished(cookie)
	if cookie == 100 then
		loading = false;   
    end
	if cookie == SHOW_BREAKOUT_GUIDELINES then
		instance.parameters.show_breakout_level = true;
		instance.parameters.show_mean_level = true;
		instance.parameters.show_normal_distribution = true;
		instance.parameters.show_target_level = true;	
	end
    if cookie == HIDE_BREAKOUT_GUIDELINES then
		instance.parameters.show_breakout_level = false;
		instance.parameters.show_mean_level = false;
		instance.parameters.show_normal_distribution = false;
		instance.parameters.show_target_level = false;	
	end
    return core.ASYNC_REDRAW ;
end


function Round_dp(v, n)
	local txt;
	--if n ~= 0 then v = math.floor(v * math.pow(10, n) + 0.5) / math.pow(10, n) end -- pow function sucks!
	if n == 5 then txt = string.format("%.5f", math.floor(v * 100000 + 0.5) / 100000) end
	if n == 4 then txt = string.format("%.4f", math.floor(v * 10000 + 0.5) / 10000) end
	if n == 3 then txt = string.format("%.3f", math.floor(v * 1000 + 0.5) / 1000) end
	if n == 2 then txt = string.format("%.2f", math.floor(v * 100 + 0.5) / 100) end
	if n == 1 then txt = string.format("%.1f", math.floor(v * 10 + 0.5) / 10) end
	if n == 0 then txt = string.format("%.0f", math.floor(v + 0.5)) end
	return txt;	
end
