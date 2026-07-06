-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=74137
-- "vol_profile_v3_0.lua" - version 3.0
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
-- choose "resolution" and "source data period" to best suit chart timeframe, for example m1 for 30m chart, or H4 for D1 chart
--
-- original code by: SM Webb September 2023 aka Steve_W per fxcodebase
--
-- Steve_W V1.0 9/9/2023    first release
-- Steve_W V2.0 10/9/2023   added stats features for breakouts
-- Steve_W V2.1 15/10/2023  updated to four corners, added version, renorm on box move option
--                          fixed code errors on changing instruments hides tool when returning to same instrument
--							(tracking development reference 915)
-- Steve_W V2.2 16/10/2023  mean level & histogram display options, disallow instrument change,
--							processing efficiency - main calculation removed from draw function
-- Steve_W V3.0 18/11/2023  alternate vol source instruement, box/band/shaded options, fractional pipsize, zones,
--							improved efficiency & source data management

-- template for tool code taken from here: http://fxcodebase.com/code/viewtopic.php?f=17&t=68571
--

-- code version, revision and author
local version = 3;
local revision = 0;
local rev_author = "Steve_W";

local TF = {"Chart", "m1", "m5", "m15", "m30", "H1", "H2", "H4", "H6", "H8", "D1", "W1", "M1"};
local source, source_vol = nil;
local loading, loading_vol = false;
local max_volume = 0;	-- for normalisation of histogram 
local hist = {};
local hist_mode = 0;
local hist_mean = 0;
local hist_sigma = 0;
local max_hist = 0;
local recalc_hist = true;
local level_list = {};	-- place-holder for future work
local level = {support_resistance = "", x1 = 0, y1 = 0, x2 = 0, y2 = 0};	-- level type


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
	tool.parameters:addString("use_vol_data_from", "Use Volume Data From", "Volume data from this instrument plotted on current chart", "");
	tool.parameters:setFlag("use_vol_data_from", core.FLAG_INSTRUMENTS);
	tool.parameters:addDouble("resolution", "Resolution", "Histogram Resolution in Pips", 1, 0.05, 10);
	tool.parameters:addString("period", "Source Data Period", "", "m5");
    local i;
	for i = 1, table.getn(TF), 1 do
		tool.parameters:addStringAlternative("period", TF[i], "", TF[i]);
    end
	tool.parameters:addBoolean("renormalise_on_box_move", "Renormalise on Box Move", "", true);
	tool.parameters:addBoolean("suppress_on_move", "Suppress Calculation on Box Move", "", false);
	
	tool.parameters:addGroup("Display");
	
	tool.parameters:addInteger("hist_width", "Histogram Width", "in pixels", 100, 50, 200);
	tool.parameters:addString("show_hist", "Show Histogram", "", "Left of Box");
	tool.parameters:addStringAlternative("show_hist", "No", "", "No");
    tool.parameters:addStringAlternative("show_hist", "Left of Box", "", "Left of Box");
    tool.parameters:addStringAlternative("show_hist", "Left of Screen", "", "Left of Screen");
    tool.parameters:addStringAlternative("show_hist", "Right of Box", "", "Right of Box");
    tool.parameters:addStringAlternative("show_hist", "Right of Screen", "", "Right of Screen");
	
	tool.parameters:addString("show_mean_level", "Show Mean Level", "", "No");
	tool.parameters:addStringAlternative("show_mean_level", "No", "", "No");
	tool.parameters:addStringAlternative("show_mean_level", "Extend Right", "", "Extend Right");
	tool.parameters:addStringAlternative("show_mean_level", "Extend Left", "", "Extend Left");
	tool.parameters:addStringAlternative("show_mean_level", "Chart", "", "Chart");
	tool.parameters:addStringAlternative("show_mean_level", "On Box", "", "On Box");
	tool.parameters:addString("mean_level_style", "Mean Level Style", "", "Line");
	tool.parameters:addStringAlternative("mean_level_style", "Line", "", "Line");
	tool.parameters:addStringAlternative("mean_level_style", "Rectangle Zone", "based on sigma multiplier", "Rectangle Zone");
	tool.parameters:addStringAlternative("mean_level_style", "Line and Sigma Levels", "", "Line and Sigma Levels");
	
	tool.parameters:addBoolean("show_normal_distribution", "Show Normal Distribution", "", false);
	
	tool.parameters:addBoolean("show_target_level", "Show Target Level", "", false);
	tool.parameters:addInteger("sigma_multiplier", "Sigma Multiplier", "", 3, 0.5, 4);
	tool.parameters:addInteger("breakout_target_multiplier", "Breakout Target Multiplier", "", 1, 0.5, 4);
	tool.parameters:addBoolean("show_text", "Show Text", "", true);
	
    tool.parameters:addGroup("Style");
	tool.parameters:addString("box_style", "Box Style", "", "Band");
	tool.parameters:addStringAlternative("box_style", "Box", "", "Box");
	tool.parameters:addStringAlternative("box_style", "Band", "", "Band");
	
    tool.parameters:addColor("box_color", "Box Colour", "", core.rgb(0, 64, 128));
    tool.parameters:addInteger("box_transparency", "Box Transparency", "0 - opaque, 100 - transparent", 70, 0, 100);
	tool.parameters:addColor("hist_color", "Histogram Colour", "", core.rgb(255, 255, 0));
	tool.parameters:addInteger("hist_transparency", "Histogram Transparency", "0 - opaque, 100 - transparent", 50, 0, 100);
	tool.parameters:addBoolean("shaded", "Shaded Histogram", "", false);
	tool.parameters:addColor("mean_color", "Mean Colour", "", core.rgb(0, 255, 0));
	tool.parameters:addColor("normal_distribution_color", "Normal Distribution Colour", "", core.rgb(0, 128, 255));
	tool.parameters:addColor("sigma_level_color", "Sigma Level Colour", "", core.rgb(0, 128, 0));
	tool.parameters:addColor("target_level_color", "Target Level Colour", "", core.rgb(255, 255, 0));
    tool.parameters:addInteger("line_width", "Width of Lines", "", 2, 1, 5);
    tool.parameters:addInteger("line_style", "Style of Lines", "", core.LINE_SOLID);
    tool.parameters:setFlag("line_style", core.FLAG_LINE_STYLE);
	tool.parameters:addColor("text_color", "Text Colour", "", core.rgb(255, 255, 0));

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
	instance.parameters.use_vol_data_from = stream:instrument();	-- default vol source to chart instrument

	-- choose a sensible source data period based on current chart period
	local i, j = 0;
	for i = 1, table.getn(TF), 1 do
		if TF[i] == stream:barSize() then
			j = i;
		end
	end
	j = j - 3;					-- pick a shorter bar size for histogram period - pragmatic choice "-3" or edit yourself
	if j < 2 then j = 2 end		-- set to smallest in the TF list
	instance.parameters.period = TF[j];

	start_rate = price;
    start_date = date;
    instance.parameters.start_rate = price;
    instance.parameters.start_date = date;
    instance.parameters.end_rate = price;
    instance.parameters.end_date = date;
	
	Update_source(true);	-- reset the source state machine and trigger a load
end


function DoubleClick(x, y, price, date)
end


local PNT_TL = 1;	-- top left
local PNT_BR = 2;	-- bottom right
local PNT_TR = 3;	-- top right
local PNT_BL = 4;	-- bottom left
local PNT_L  = 5;	-- left middle
local PNT_R  = 6;	-- right middle
function UpdateReferencePoints()
    local referencePoints = core.host.ReferencePoints;
	
	if instance.parameters.box_style == "Box" then
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
		referencePoints:removeReferencePoint(PNT_L);	-- destroy unwanted points
		referencePoints:removeReferencePoint(PNT_R);
	end
	
	if instance.parameters.box_style == "Band" then
		referencePoints:setReferencePoint(PNT_L,
											instance.parameters.start_date,
											(instance.parameters.start_rate + instance.parameters.end_rate) / 2,
											referencePoints.DATE + referencePoints.PRICE,
											instance.parameters.box_color,
											2);
		referencePoints:setReferencePoint(PNT_R,
											instance.parameters.end_date,
											(instance.parameters.start_rate + instance.parameters.end_rate) / 2,
											referencePoints.DATE + referencePoints.PRICE,
											instance.parameters.box_color,
											2);
		referencePoints:removeReferencePoint(PNT_TL);	-- destroy unwanted points
		referencePoints:removeReferencePoint(PNT_TR);
		referencePoints:removeReferencePoint(PNT_BL);
		referencePoints:removeReferencePoint(PNT_BR);
	end
end


function Drag(x, y, price, date)    
    instance.parameters.end_rate = price;
    instance.parameters.end_date = date;
    UpdateReferencePoints();
	
	recalc_hist = true;
end


function DragEnd(x, y, price, date)
	recalc_hist = true;
end


function CreationFinished()
	recalc_hist = true;
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
	elseif movingPointID == PNT_L then
		instance.parameters.start_date = date;
	elseif movingPointID == PNT_R then
		instance.parameters.end_date = date;
	end
    UpdateReferencePoints();
	max_volume = 0;	-- reset histogram normalisation if size of box is changed
	recalc_hist = true;
end


function MoveReferencePointFinished()
	recalc_hist = true;
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


local suppress_hist_plot = false;
function Move(x, y, price, date)
    local pane = core.host.Window.CurrentPane;
    stream = pane.Data:getStream(0);
    if start_rate == nil then
        start_rate = price;
        start_period = core.host:execute("calculatePositionOfDate", stream, date);
    else
        local rate_diff = price - start_rate;
        local period_diff = core.host:execute("calculatePositionOfDate", stream, date) - start_period;
        if instance.parameters.box_style == "Box" then
			instance.parameters.start_rate = start_rate_start + rate_diff;	-- don't change for band style
			instance.parameters.end_rate = end_rate_start + rate_diff;
		end
        instance.parameters.start_date = core.host:execute("calculateDate", stream, period_1_start + period_diff);
        instance.parameters.end_date = core.host:execute("calculateDate", stream, period_2_start + period_diff);
        UpdateReferencePoints();
    end
	
	if instance.parameters.suppress_on_move == false then
		if instance.parameters.renormalise_on_box_move == true then
			max_volume = 0;			-- reset histogram normalisation? since we have moved the box
		end
		recalc_hist = true;
	else
		suppress_hist_plot = true;
	end
end


function MoveFinished()
    start_rate = nil;
    start_period = nil;
	
	if instance.parameters.renormalise_on_box_move == true then
		max_volume = 0;			-- reset histogram normalisation? since we have moved the box
	end
	
	recalc_hist = true;
	suppress_hist_plot = false;
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
local MEAN_BRUSH = 6;
local SIGMA_PEN = 7;
local TARGET_PEN = 8;
local FIT_PEN = 9;
local init = false;
local last_source_size = 0;
local last_source_vol_size = 0;
local hist_transparency;
local prev_start_rate = 0;
local prev_end_rate = 0;
function Draw(stage, context)
	
	-- ignore drawing+loading if tool was not drawn on the currently displayed chart instrument
	local pane = core.host.Window.CurrentPane;
	local stream = pane.Data:getStream(0);
	if instance.parameters.loaded_on_instrument ~= stream:instrument() then return end

	-- service source loading to match chart window (false = don't reset state machine)
	Update_source(false);
	if instance.parameters.use_vol_data_from ~= instance.parameters.loaded_on_instrument then
		Update_source_vol(false);
	end

	-- setup pens & brushes
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
		context:createSolidBrush(MEAN_BRUSH,
									instance.parameters.mean_color);					
		context:createPen(SIGMA_PEN,
							context:convertPenStyle(instance.parameters.line_style),
							instance.parameters.line_width,
							instance.parameters.sigma_level_color);
		context:createPen(TARGET_PEN,
							context:convertPenStyle(instance.parameters.line_style),
							instance.parameters.line_width,
							instance.parameters.target_level_color);
		context:createPen(FIT_PEN,
							context:convertPenStyle(instance.parameters.line_style),
							instance.parameters.line_width,
							instance.parameters.normal_distribution_color);
		context:createFont(1, "font", 0, 0, 0);
		init = true;
	end
	
	
    if stage == 2 then
		
		-- new data to add to histogram?
        if last_source_size ~= source:size() then
            last_source_size = source:size();
			UpdateReferencePoints();
			recalc_hist = true;
        end
        if instance.parameters.use_vol_data_from ~= instance.parameters.loaded_on_instrument then
			if last_source_vol_size ~= source_vol:size() then	-- comparison is made only if previous statement is true to prevent nil error
				last_source_vol_size = source_vol:size();
				UpdateReferencePoints();
				recalc_hist = true;
			end
        end
        
		-- update screen context if set to band style
		if instance.parameters.box_style == "Band" then
			instance.parameters.start_rate = context:priceOfPoint(context:top());
			instance.parameters.end_rate = context:priceOfPoint(context:bottom());
			if instance.parameters.start_rate ~= prev_start_rate or				-- screen context rescaled?
				instance.parameters.end_rate ~= prev_end_rate then
				UpdateReferencePoints();
				recalc_hist = true;
			end
			prev_start_rate = instance.parameters.start_rate;
			prev_end_rate = instance.parameters.end_rate;
		end
		
        local x1, y1 = get_point_coordinates(instance.parameters.start_date, instance.parameters.start_rate, context);
        local x2, y2 = get_point_coordinates(instance.parameters.end_date, instance.parameters.end_rate, context);
		x1, x2 = Sort(x1, x2);
		y1, y2 = Sort(y1, y2);
		
        context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
        context:drawRectangle(BOX_PEN, BOX_BRUSH, x1, y1, x2, y2, box_transparency);
        context:resetClipRectangle();
		
		local text;
		local width, height;
		local y_upper, y_lower;
		local draw_on_left = false;	
		if loading == true or loading_vol == true then
			text = "Loading...";
			recalc_hist = true;	-- force recalc once all loading is finished
			if loading == true then text = text .. " " .. instance.parameters.loaded_on_instrument end
			if loading_vol == true then text = text .. " " .. instance.parameters.use_vol_data_from end
			width, height = context:measureText(1, text, 0);
			-- plot top, mid box
			context:drawText(1, text, instance.parameters.text_color, -1, (x1 + x2 - width)/2, y1 + 0 * height, (x1 + x2 + width)/2, y1 + 1 * height, context.LEFT + context.EXPANDTABS);
		else
			if recalc_hist == true then
				hist, hist_mode, hist_mean, hist_sigma = Calculate_profile();
				recalc_hist = false;
			end
			
			if suppress_hist_plot == true then return end;		-- covers option to not recalc on box move
			
			text = "";
			local fit_error = 0;
		
			-- some conversions
			local dy = (y2 - y1) / hist:size();					-- delta Y scaling factor
			
			-- draw the histogram
			if instance.parameters.show_hist ~= "No" then
				local x_location = 0;
				if instance.parameters.show_hist == "Left of Box" then
					x_location = x1 - instance.parameters.hist_width - 10;
					draw_on_left = true;
				elseif instance.parameters.show_hist == "Left of Screen" then
					x_location = context:left() + 10;
					draw_on_left = true;
				elseif instance.parameters.show_hist == "Right of Box" then
					x_location = x2 + instance.parameters.hist_width + 10;
					draw_on_left = false;
				elseif instance.parameters.show_hist == "Right of Screen" then
					x_location = context:right() - 10;
					draw_on_left = false;
				end
				
				-- optimised drawing for speed efficiency
				y_upper = y2 + (dy * 0.5);
				y_lower = y2 - (dy * 0.5);
				local tmp_y_upper;
				local ht = hist_transparency;
				if dy <= 1 then															-- draw lines not rectangles?
					if draw_on_left == true then
						for i = 1, hist:size(), 1 do
							tmp_y_upper = y_upper;
							y_upper = y_upper - dy;
							y_lower = y_lower - dy;
							if hist[i] > 0 then											-- something to plot?
								if instance.parameters.shaded == true then
									ht = hist_transparency + (255 - hist_transparency) * (1 - hist[i] / instance.parameters.hist_width);
								end
								if math.floor(tmp_y_upper) ~= math.floor(y_upper) then	-- at least one pixel difference to last line
									context:drawLine(HIST_PEN, x_location, y_upper, x_location + hist[i], y_upper, ht);
								end
							end
						end
					else
						for i = 1, hist:size(), 1 do
							tmp_y_upper = y_upper;
							y_upper = y_upper - dy;
							y_lower = y_lower - dy;
							if hist[i] > 0 then
								if instance.parameters.shaded == true then
									ht = hist_transparency + (255 - hist_transparency) * (1 - hist[i] / instance.parameters.hist_width);
								end
								if math.floor(tmp_y_upper) ~= math.floor(y_upper) then	-- at least one pixel difference to last line
									context:drawLine(HIST_PEN, x_location, y_upper, x_location - hist[i], y_upper, ht);
								end
							end
						end
					end
				else
					if draw_on_left == true then
						for i = 1, hist:size(), 1 do
							y_upper = y_upper - dy;
							y_lower = y_lower - dy;
							if hist[i] > 0 then
								if instance.parameters.shaded == true then
									ht = hist_transparency + (255 - hist_transparency) * (1 - hist[i] / instance.parameters.hist_width);
								end
								context:drawRectangle(HIST_PEN,
													HIST_BRUSH,
													x_location,
													y_lower,
													x_location + hist[i],
													y_upper,
													ht);
							end
						end
					else
						for i = 1, hist:size(), 1 do
							y_upper = y_upper - dy;
							y_lower = y_lower - dy;
							if hist[i] > 0 then
								if instance.parameters.shaded == true then
									ht = hist_transparency + (255 - hist_transparency) * (1 - hist[i] / instance.parameters.hist_width);
								end
								context:drawRectangle(HIST_PEN,
													HIST_BRUSH,
													x_location,
													y_lower,
													x_location - hist[i],
													y_upper,
													ht);
							end
						end
					end
				end
				
				-- display idealised normal distribution using hist_mean and hist_sigma 
				if instance.parameters.show_normal_distribution == true then
					local fx;
					local fx_scale = max_hist * (hist_sigma * math.sqrt(2 * math.pi));
					local k1 = 1 / (hist_sigma * math.sqrt(2 * math.pi));
					local k2 = (2 * hist_sigma^2);
					local y = y2;
					local prev_x = x_location;
					local prev_y = y;
					if draw_on_left == true then
						for i = 2, hist:size(), 1 do
							y = y - dy;
							fx = k1 * math.exp(-(i - hist_mean)^2 / k2);
							fx = fx * fx_scale;
							fit_error = fit_error + (fx - hist[i])^2;
							local x = x_location + fx;
							if fx >= 1 then	-- worth plotting?
								context:drawLine(FIT_PEN, prev_x, prev_y, x, y);
							end
							prev_x = x;
							prev_y = y;
						end
					else
						for i = 2, hist:size(), 1 do
							y = y - dy;
							fx = k1 * math.exp(-(i - hist_mean)^2 / k2);
							fx = fx * fx_scale;
							fit_error = fit_error + (fx - hist[i])^2;
							local x = x_location - fx;
							if fx >= 1 then
								context:drawLine(FIT_PEN, prev_x, prev_y, x, y);
							end
							prev_x = x;
							prev_y = y;
						end
					end
					fit_error = math.sqrt(fit_error / hist:size()) / max_hist * 100;	-- rms error - arbitrary units
				end
			end				
			
			-- draw stats
			
			-- sigma based breakout target
			local y;
			local delta_n_sigma;
			if instance.parameters.show_target_level == true then
				delta_n_sigma = hist_sigma * instance.parameters.sigma_multiplier * 2;	-- recommend +/-3 sigma
				y_lower = y2 - dy * (hist_mean + instance.parameters.sigma_multiplier * hist_sigma
					+ delta_n_sigma * instance.parameters.breakout_target_multiplier);
				context:drawLine(TARGET_PEN, x2 + (x2 - x1) / 4, y_lower, x2, y_lower);
				y_upper = y2 - dy * (hist_mean - instance.parameters.sigma_multiplier * hist_sigma
					- delta_n_sigma * instance.parameters.breakout_target_multiplier);
				context:drawLine(TARGET_PEN, x2 + (x2 - x1) / 4, y_upper, x2, y_upper);
			end
			
			-- mean level
			if instance.parameters.show_mean_level ~= "No" then
				local xx1, xx2;	-- local local variables...
				y = y2 - hist_mean * dy
				if instance.parameters.show_mean_level == "On Box" then
					xx1 = x1;
					xx2 = x2;
				elseif instance.parameters.show_mean_level == "Extend Right" then
					xx1 = x1;
					xx2 = context:right();
				elseif instance.parameters.show_mean_level == "Extend Left" then
					xx1 = context:left();
					xx2 = x2;
				elseif instance.parameters.show_mean_level == "Chart" then
					xx1 = context:left();
					xx2 = context:right();
				end
				if instance.parameters.mean_level_style == "Line" then
					context:drawLine(MEAN_PEN, xx1, y, xx2, y);
					y_upper = y;
					y_lower = y;
				elseif instance.parameters.mean_level_style == "Line and Sigma Levels" then
					context:drawLine(MEAN_PEN, xx1, y, xx2, y);
					y_upper = y2 - dy * (hist_mean + instance.parameters.sigma_multiplier * hist_sigma);
					context:drawLine(SIGMA_PEN, xx1, y_upper, xx2, y_upper);
					y_lower = y2 - dy * (hist_mean - instance.parameters.sigma_multiplier * hist_sigma);
					context:drawLine(SIGMA_PEN, xx1, y_lower, xx2, y_lower);
				elseif instance.parameters.mean_level_style == "Rectangle Zone" then
					y_lower = y2 - dy * (hist_mean + instance.parameters.sigma_multiplier * hist_sigma);
					y_upper = y2 - dy * (hist_mean - instance.parameters.sigma_multiplier * hist_sigma);
					context:drawRectangle(MEAN_PEN,
											MEAN_BRUSH,
											xx1,
											y_upper,
											xx2,
											y_lower,
											hist_transparency);
				end
				level.x1 = xx1;
				level.y1 = context:priceOfPoint(y_upper);
				level.x2 = xx2;
				level.y2 = context:priceOfPoint(y_lower);
			end
			
			-- draw stored levels
			for i = 1, table.getn(level_list), 1 do
				if level_list[i].y1 == level_list[i].y2 then
					context:drawLine(MEAN_PEN, level_list[i].x1, level_list[i].y1, level_list[i].x2, level_list[i].y2);
				else
					context:drawRectangle(MEAN_PEN,
											MEAN_BRUSH,
											level_list[i].x1, level_list[i].y1, level_list[i].x2, level_list[i].y2,
											hist_transparency);
				end
			end
			
			
				
			-- various text
			if instance.parameters.show_text == true then
				if instance.parameters.show_target_level == true then
					text = Round_dp(delta_n_sigma, 1)  .. " pips";
					width, height = context:measureText(1, text, 0);
					context:drawText(1, text, instance.parameters.text_color, -1, x1, y1 + 0 * height, x1 + width, y1 + 1 * height, context.LEFT + context.EXPANDTABS);
				end
				if instance.parameters.show_normal_distribution == true then
					text = "Error = " .. Round_dp(fit_error, 1);
					width, height = context:measureText(1, text, 0);
					context:drawText(1, text, instance.parameters.text_color, -1, x1, y2 - 1 * height, x1 + width, y2 - 0 * height, context.LEFT + context.EXPANDTABS);
				end
				text = instance.parameters.use_vol_data_from;
				text = text .. "," .. instance.parameters.period;
				text = text .. "," .. Round_dp(instance.parameters.resolution, 1);
				width, height = context:measureText(1, text, 0);
				if draw_on_left == true then
					context:drawText(1, text, instance.parameters.text_color, -1, x1, y1 + 0 * height, x1 + width, y1 + 1 * height, context.LEFT + context.EXPANDTABS);
				else
					context:drawText(1, text, instance.parameters.text_color, -1, x2 - width, y1 + 0 * height, x2, y1 + 1 * height, context.LEFT + context.EXPANDTABS);
				end
			end
		end
    end
end


-- Calculate volume-price histogram (not called until data has been loaded)
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
	local hist_local = core.makeArray(hist_size);
	for i = 1, hist_size, 1 do
		hist_local[i] = 0;
	end
	
	-- build histogram
	for i = start_bar, end_bar, 1 do
		local vol_divisions = math.floor((source.high[i] - source.low[i]) / point_size / instance.parameters.resolution + 0.5);
		local vol_fraction;
		if instance.parameters.loaded_on_instrument == instance.parameters. use_vol_data_from then
			vol_fraction = source.volume[i] / vol_divisions;		-- source for chart already has the volume! (we suppress loading of other instrument)
		else
			-- date alignment is required to correctly index two different streams (and prevent "Specified index out of range" errors)
			local date = source:date(i);							-- extract date of current index in chart source
			local j = core.findDate(source_vol, date, false);		-- index in the volume source
			vol_fraction = source_vol.volume[j] / vol_divisions;	-- volume from volume source data
		end
		local pip_index = math.floor((source.low[i] - end_rate) / point_size / instance.parameters.resolution + 0.5);
		for j = 1, vol_divisions, 1 do	-- evenly spread bar volume over histogram 
			if j + pip_index > 0 and j + pip_index < hist_size then
				hist_local[j + pip_index] = hist_local[j + pip_index] + vol_fraction; 
			end
		end
	end
	
	-- rescale and normalise histogram 
	local current_max = 0;
	for i = 1, hist_size, 1 do
		if hist_local[i] > current_max then
			current_max = hist_local[i];
		end
		if hist_local[i] > max_volume then max_volume = hist_local[i] end
	end
	if max_volume > 0 then
		max_hist = 0;
		for i = 1, hist_size, 1 do
			hist_local[i] = instance.parameters.hist_width * hist_local[i] / max_volume;	-- normalise 0-100
			if hist_local[i] > max_hist then max_hist = hist_local[i] end
		end
	end
	
	-- calculate stats
	local mode = 0;
	local mean;
	local sigma;
	local sum_ih = 0;
	local sum_h = 0;
	for i = 1, hist_size, 1 do
		if hist_local[i] > mode then
			current_max = hist_local[i];
			mode = i;
		end
		sum_ih = sum_ih + i * hist_local[i];
		sum_h = sum_h + hist_local[i];
	end
	mean = sum_ih / sum_h;
	local sum_s = 0;
	for i = 1, hist_size, 1 do
		sum_s = sum_s + hist_local[i] * (i - mean)^2;
	end
	sigma = math.sqrt(sum_s / sum_h);
	
	return hist_local, mode, mean, sigma;
end


function Sort(a, b)
	if a > b then return b, a end
	return a, b;
end


local init_add_cmd = false;
local SOURCE_UPDATE_COOKIE = 100;
local SOURCE_VOL_UPDATE_COOKIE = 101;
local SHOW_GUIDELINES_COOKIE = 200;
local HIDE_GUIDELINES_COOKIE = 201;
local ADD_SUPPORT_COOKIE = 202;		-- place-holders for future work
local ADD_RESISTANCE_COOKIE = 203;
local REMOVE_LEVEL_COOKIE = 204;
local force_instrument = nil;
function Prepare(onlyName)
    local pane = core.host.Window.CurrentPane;
	local stream = pane.Data:getStream(0);
	
	local name = profile:name() .. " (" .. instance.parameters.loaded_on_instrument .. " using " .. instance.parameters.use_vol_data_from .. " vol)";	-- identify the name & instrument the tool was drawn on
    instance:name(name);

	if onlyName then return end
	
	if init_add_cmd == false and 
		stream:instrument() == instance.parameters.loaded_on_instrument	-- only add if display instrument is same as the one the tool was drawn on
	then
		core.host:execute("addCommand", SHOW_GUIDELINES_COOKIE, "Show Guidelines", "");
		core.host:execute("addCommand", HIDE_GUIDELINES_COOKIE, "Hide Guidelines", "");
		--[[ place holder for future work
		core.host:execute("addCommand", ADD_SUPPORT_COOKIE, "Add Level as Support", "");
		core.host:execute("addCommand", ADD_RESISTANCE_COOKIE, "Add Level as Resistance", "");
		core.host:execute("addCommand", REMOVE_LEVEL_COOKIE, "Remove Level", "");
		]]--
		init_add_cmd = true;
	end
    
    UpdateReferencePoints();
	
	force_instrument = instance.parameters.loaded_on_instrument;		-- register this instance has been loaded on this instrument
	
	init = false;			-- update pens and brushes
end


local temp_params;
function CheckParameters(params)
	params.loaded_on_instrument = force_instrument;					-- dis-allow the instrument to be changed so tool remains attached to current chart
	params.version = version;
    params.revision = revision;
	params.author = author;
	
	temp_params = params;
	return profile:name();
end


function ChangeParameters()
    -- copy all the params because of strange FXTS2 bug
	instance.parameters.loaded_on_instrument = temp_params.loaded_on_instrument;
    instance.parameters.start_date = temp_params.start_date;
    instance.parameters.end_date = temp_params.end_date;
    instance.parameters.start_rate = temp_params.start_rate;
    instance.parameters.end_rate = temp_params.end_rate;
    if instance.parameters.use_vol_data_from ~= temp_params.use_vol_data_from then
		instance.parameters.use_vol_data_from = temp_params.use_vol_data_from;
		if instance.parameters.use_vol_data_from ~= instance.parameters.loaded_on_instrument then
			Update_source_vol(true);
		end
		recalc_hist = true;
		max_volume = 0;													-- reset and recalc histogram
	end
	if instance.parameters.resolution ~= temp_params.resolution then	-- changed required recalc
		instance.parameters.resolution = temp_params.resolution;
		recalc_hist = true;
		max_volume = 0;													-- reset and recalc histogram
	end
    if instance.parameters.period ~= temp_params.period then
		instance.parameters.period = temp_params.period;
		Update_source(true);
		if instance.parameters.use_vol_data_from ~= instance.parameters.loaded_on_instrument then
			Update_source_vol(true);									-- we have to reload other instrument
		end
		recalc_hist = true;
		max_volume = 0;													-- reset and recalc histogram
	end
	instance.parameters.renormalise_on_box_move = temp_params.renormalise_on_box_move;
    instance.parameters.suppress_on_move = temp_params.suppress_on_move;
    if instance.parameters.hist_width ~= temp_params.hist_width then
		instance.parameters.hist_width = temp_params.hist_width;
		recalc_hist = true;
	end
	instance.parameters.hist_location = temp_params.hist_location;
    instance.parameters.show_mean_level = temp_params.show_mean_level;
    instance.parameters.mean_level_style = temp_params.mean_level_style;
    instance.parameters.show_normal_distribution = temp_params.show_normal_distribution;
    instance.parameters.show_target_level = temp_params.show_target_level;
    instance.parameters.breakout_sigma_multiplier = temp_params.breakout_sigma_multiplier;
    instance.parameters.breakout_target_multiplier = temp_params.breakout_target_multiplier;
	instance.parameters.show_text = temp_params.show_text;
	if instance.parameters.box_style ~= temp_params.box_style then
	    instance.parameters.box_style = temp_params.box_style;			-- force a recentering as box style has changed
		recalc_hist = true;
	end
	instance.parameters.box_color = temp_params.box_color;
    instance.parameters.box_transparency = temp_params.box_transparency;
    instance.parameters.hist_color = temp_params.hist_color;
	instance.parameters.hist_transparency = temp_params.hist_transparency;
    instance.parameters.shaded = temp_params.shaded;
	instance.parameters.mean_color = temp_params.mean_color;
	instance.parameters.normal_distribution_color = temp_params.normal_distribution_color;
    instance.parameters.breakout_level_color = temp_params.breakout_level_color;
    instance.parameters.target_level_color = temp_params.target_level_color;
    instance.parameters.line_width = temp_params.line_width;
    instance.parameters.line_style = temp_params.line_style;
    instance.parameters.text_color = temp_params.text_color;
    instance.parameters.version = temp_params.version;
    instance.parameters.revision = temp_params.revision;
	instance.parameters.author = temp_params.author;
	Prepare(false);
end


function AsyncOperationFinished(cookie, success, message)
    if cookie == SOURCE_UPDATE_COOKIE then
		if success == true then
			loading = false;
		else
			Update_source(true);		-- something went wrong... force reset of source
		end
	end
    if cookie == SOURCE_VOL_UPDATE_COOKIE then
		if success == true then
			loading_vol = false;
		else
			Update_source_vol(true);	-- something went wrong... force reset of source
		end
	end
	if cookie == SHOW_GUIDELINES_COOKIE then
		instance.parameters.show_mean_level = "Extend Right";
		instance.parameters.show_normal_distribution = true;
		instance.parameters.show_target_level = true;	
	end
    if cookie == HIDE_GUIDELINES_COOKIE then
		instance.parameters.show_mean_level = "No";
		instance.parameters.show_normal_distribution = false;
		instance.parameters.show_target_level = false;	
	end
	if cookie == ADD_SUPPORT_COOKIE then
		if instance.parameters.show_mean_level ~= "No" then
			level.support_resistance = "S";
			Add_list(level);
		end
	end
    if cookie == ADD_RESISTANCE_COOKIE then
		if instance.parameters.show_mean_level ~= "No" then
			level.support_resistance = "R";
			Add_list(level);
		end
	end
    return core.ASYNC_REDRAW ;
end


function Round_dp(v, n)
	local txt;
	if n == 5 then txt = string.format("%.5f", math.floor(v * 100000 + 0.5) / 100000) end
	if n == 4 then txt = string.format("%.4f", math.floor(v * 10000 + 0.5) / 10000) end
	if n == 3 then txt = string.format("%.3f", math.floor(v * 1000 + 0.5) / 1000) end
	if n == 2 then txt = string.format("%.2f", math.floor(v * 100 + 0.5) / 100) end
	if n == 1 then txt = string.format("%.1f", math.floor(v * 10 + 0.5) / 10) end
	if n == 0 then txt = string.format("%.0f", math.floor(v + 0.5)) end
	return txt;	
end


-- update and extend source state machine - unable to use "getSyncHistory" with a "tool profile".... so we have to do some work
local debug_Update_source = false;	-- activate optional local debug code => output to trace, left in here fyi
local extend = true;
local request_from = 0;
local request_to = 0;
function Update_source(reset)
	
	-- reset state machine?
	if reset == true or 	-- commanded reset
		source == nil		-- no source and we do need one
	then
		if debug_Update_source == true then core.host:trace("Update_source(): reset") end
		extend = true;
		request_from = 0;
		request_to = 0;
		source = nil;
		loading = false;
	end
	
	-- date range for current displayed chart
	local from, to;
	local pane = core.host.Window.CurrentPane;
	local stream = pane.Data:getStream(0);
	from = stream:date(stream:first());
	if stream:isAlive() then
		to = 0;
	else
		to = stream:date(stream:size() - 1);
	end

	if loading == false then
		if source == nil then	-- source == nil is the trigger to load source, the process is managed there-after
			loading = true;
			request_from = from;
			request_to = to;
			local period = instance.parameters.period;
			if period == "Chart" then	-- special case
				period = stream:barSize();
			end
			if extend == true then
				-- load the default duration and extend
                if debug_Update_source == true then core.host:trace("Update_source(): load default duration and extend") end
				source = core.host:execute("getHistory", SOURCE_UPDATE_COOKIE, stream:instrument(), period, 0, to, stream:isBid());
            else
                -- load the whole date range
                if debug_Update_source == true then core.host:trace("Update_source(): load whole date range") end
				source = core.host:execute("getHistory", SOURCE_UPDATE_COOKIE, stream:instrument(), period, from, to, stream:isBid());
            end	
		else
			if from < request_from then
				-- extend left
				if debug_Update_source == true then core.host:trace("Update_source(): extend left") end
				loading = true;
				request_from = from;
				core.host:execute("extendHistory", SOURCE_UPDATE_COOKIE, source, from, source:date(source:first()));
			elseif to ~= 0 and to > request_to then
				-- extend right
				if debug_Update_source == true then core.host:trace("Update_source(): extend right") end
                loading = true;
				request_to = to;
				core.host:execute("extendHistory", SOURCE_UPDATE_COOKIE, source, source:date(source:size() - 1), to);
			elseif extend == true and source:size() > 0 and from < source:date(source:first()) then
                -- extend unloaded history
				if debug_Update_source == true then core.host:trace("Update_source(): extend unloaded") end
                loading = true;
                request_from = from;
                extend = false;
                core.host:execute("extendHistory", SOURCE_UPDATE_COOKIE, source, from, source:date(source:first()));
			end
		end
	end
end


-- update and extend volume source - identical code to the above.... could make a class to remove duplication
local extend_vol = true;
local request_from_vol = 0;
local request_to_vol = 0;
function Update_source_vol(reset)
	
	-- reset state machine?
	if reset == true or 	-- commanded reset
		source_vol == nil	-- no source and we do need one
	then
		extend_vol = true;
		request_from_vol = 0;
		request_to_vol = 0;
		source_vol = nil;
		loading_vol = false;
	end
	
	-- date range for current displayed chart
	local from, to;
	local pane = core.host.Window.CurrentPane;
	local stream = pane.Data:getStream(0);
	from = stream:date(stream:first());
	if stream:isAlive() then
		to = 0;
	else
		to = stream:date(stream:size() - 1);
	end

	if loading_vol == false then
		if source_vol == nil then	-- source == nil is the trigger to load source, the process is managed there-after
			loading_vol = true;
			request_from_vol = from;
			request_to_vol = to;
			local period = instance.parameters.period;
			if period == "Chart" then	-- special case
				period = stream:barSize();
			end
			if extend_vol == true then
				-- load the default duration and extend
                source_vol = core.host:execute("getHistory", SOURCE_VOL_UPDATE_COOKIE, instance.parameters.use_vol_data_from, period, 0, to, stream:isBid());
            else
                -- load the whole date range
                source_vol = core.host:execute("getHistory", SOURCE_VOL_UPDATE_COOKIE, instance.parameters.use_vol_data_from, period, from, to, stream:isBid());
            end	
		else
			if from < request_from_vol then
				-- extend left
				loading_vol = true;
				request_from_vol = from;
				core.host:execute("extendHistory", SOURCE_VOL_UPDATE_COOKIE, source_vol, from, source_vol:date(source_vol:first()));
			elseif to ~= 0 and to > request_to_vol then
				-- extend right
				loading_vol = true;
				request_to_vol = to;
				core.host:execute("extendHistory", SOURCE_VOL_UPDATE_COOKIE, source_vol, source_vol:date(source_vol:size() - 1), to);
			elseif extend_vol == true and source_vol:size() > 0 and from < source_vol:date(source_vol:first()) then
                -- extend unloaded history
				loading_vol = true;
                request_from_vol = from;
                extend_vol = false;
                core.host:execute("extendHistory", SOURCE_VOL_UPDATE_COOKIE, source_vol, from, source_vol:date(source_vol:first()));
			end
		end
	end
end


-- place-holder for future work
function Add_list(level)
	table.insert(level_list, level);
	local text = Round_dp(table.getn(level_list), 0)  .. ", ";
	text = text .. level.support_resistance .. ", " .. Round_dp(level.y1, 4) .. ", " .. Round_dp(level.y2, 4);
	
	text = Round_dp(level_list[table.getn(level_list)].y1, 4);
	core.host:trace("Add_list(): " .. text);
end
