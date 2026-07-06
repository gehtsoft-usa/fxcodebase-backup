-- "vol_profile.lua"
-- Drag-Drop Volume Profile Tool
-- install using normal method, copy 16x16 vol_profile.png icon into C:\Program Files (x86)\Candleworks\FXTS2\Tools\Custom\
-- activate via custom toolbar button, or right click->add tool->volume profile -> drag+drop a box over area of interest
-- edit / set default parameters via right click / double clicking on box instance
-- using mouse, re-size+move box to dynamically observe how volume changes with price and time 
--
-- Webb Consultancy Ltd.
-- SM Webb September 2023
-- V1.0
--
-- template for tool code taken from here: http://fxcodebase.com/code/viewtopic.php?f=17&t=68571
--

local source;
local loading = false;
local max_volume = 0;	-- for normalisation of histogram 


function Init()
    tool:name("Volume Profile");
    tool:description("Drag drop volume profile box");
    tool:icon("vol_profile.png");
	tool.creationStrategy:setPattern(core.DragClick);
    tool.creationStrategy:setMaxClickCount(0);
    tool:setTag("group", "Tools");
    tool:setTag("orderInGroup", "1");
    tool:setTag("NonResetableParameters", "start_rate,start_date,end_rate,end_date");
    tool:setTag("requiredPaneType", "hasStreams");

	tool.parameters:addGroup("Location");
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
    
	
    tool.parameters:addGroup("Style");
    tool.parameters:addColor("box_color", "Box Color", "", core.rgb(0, 64, 128));
	tool.parameters:addColor("hist_color", "Histogram Color", "", core.rgb(255, 255, 0));
	tool.parameters:addInteger("border_width", "Border Width", "", 1, 1, 5);
    tool.parameters:addInteger("border_style", "Border Style", "", core.LINE_SOLID);
    tool.parameters:setFlag("border_style", core.FLAG_LINE_STYLE);
    tool.parameters:addInteger("box_transparency", "Box Transparency", "0 - opaque, 100 - transparent", 90, 0, 100);
	tool.parameters:addInteger("hist_transparency", "Histogram Transparency", "0 - opaque, 100 - transparent", 50, 0, 100);
	tool.parameters:addColor("text_color", "Text Colour", "", core.rgb(255, 255, 0));
    
end


function CreationStarted(Parameters)
end


local start_rate;
local start_date;
function Click(x, y, price, date)
    start_rate = price;
    start_date = date;
    instance.parameters.start_rate = price;
    instance.parameters.start_date = date;
    instance.parameters.end_rate = price;
    instance.parameters.end_date = date;
end


function DoubleClick(x, y, price, date)
end


local last_stream_size = 0;
function UpdateReferencePoints()
    local pane = core.host.Window.CurrentPane;
    local stream = pane.Data:getStream(0);
    last_stream_size = stream:size();
    local referencePoints = core.host.ReferencePoints;
    referencePoints:setReferencePoint(1,
										instance.parameters.start_date,
										instance.parameters.start_rate,
										referencePoints.DATE + referencePoints.PRICE,
										instance.parameters.box_color,
										instance.parameters.border_width + 1);
    referencePoints:setReferencePoint(2,
										instance.parameters.end_date,
										instance.parameters.end_rate,
										referencePoints.DATE + referencePoints.PRICE,
										instance.parameters.box_color,
										instance.parameters.border_width + 1);
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
    if movingPointID == 1 then
        instance.parameters.start_date = date;
        instance.parameters.start_rate = price;
        UpdateReferencePoints();
    elseif movingPointID == 2 then
        instance.parameters.end_date = date;
        instance.parameters.end_rate = price;
        UpdateReferencePoints();
    end
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
local init = false;
function Draw(stage, context)
    if stage == 2 then
        if not init then
            context:createPen(BOX_PEN,
								context:convertPenStyle(instance.parameters.border_style),
								instance.parameters.border_width,
								instance.parameters.box_color);
            context:createSolidBrush(BOX_BRUSH,
										instance.parameters.box_color);
            box_transparency = context:convertTransparency(instance.parameters.box_transparency);
            context:createPen(HIST_PEN,
								context:convertPenStyle(instance.parameters.border_style),
								instance.parameters.border_width,
								instance.parameters.hist_color);
			context:createSolidBrush(HIST_BRUSH,
										instance.parameters.hist_color);
            hist_transparency = context:convertTransparency(instance.parameters.hist_transparency);
            init = true;
        end
        local pane = core.host.Window.CurrentPane;
        local stream = pane.Data:getStream(0);
        if last_stream_size ~= stream:size() then
            UpdateReferencePoints();
        end
        
        local x1, y1 = get_point_coordinates(instance.parameters.start_date, instance.parameters.start_rate, context);
        local x2, y2 = get_point_coordinates(instance.parameters.end_date, instance.parameters.end_rate, context);
		--[[local temp;
		if x1 > x2 then
			temp = x2;
			x2 = x1;
			x1 = temp;
		end
		if y1 > y2 then
			temp = y2;
			y2 = y1;
			y1 = temp;
		end]]--
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
		
		local text = source:instrument();
		if loading == true then
			text = "Loading...";
		else
			text = "";
			local hist = Calculate_profile();
			local i;
			for i = 1, hist:size(), 1 do
				local y = y2 - (y2 - y1) * i / hist:size();
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
		end
		
		local width, height = context:measureText(1, text, 0);
		context:drawText(1, text, instance.parameters.text_color, -1, x1, y1 - 1 * height, x1 + width, y1 - 0 * height, context.LEFT + context.EXPANDTABS);
		
    end
end


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
	for i = 1, hist_size, 1 do
		if hist[i] > max_volume then max_volume = hist[i] end
	end
	if max_volume > 0 then
		for i = 1, hist_size, 1 do
			hist[i] = instance.parameters.hist_width * hist[i] / max_volume;	-- normalise 0-100
		end
	end
	return hist;
end


function Sort(a, b)
	if a > b then return b, a end
	return a, b;
end


function Prepare(onlyName)
    local name = profile:name();
    instance:name(name);
    
    if onlyName then return end
    
	init = false;
    last_stream_size = 0;
    UpdateReferencePoints();
	
	local from, to;
	local pane = core.host.Window.CurrentPane;
    local stream = pane.Data:getStream(0);
	from = stream:date(stream:first());
	if stream:isAlive() then
		to = 0;
    else
        to = stream:date(stream:size() - 1);
    end
	
	-- source loaded bid or ask with desired bar size
	source = core.host:execute("getHistory", 100, stream:instrument(), instance.parameters.period, from, to, stream:isBid());
	loading = true;   	
end


local temp_params;
function CheckParameters(params)
    temp_params = params;
    return profile:name();
end


function ChangeParameters()
    Prepare(false);
end


function AsyncOperationFinished(cookie)
	if cookie == 100 then
		loading = false;   
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
