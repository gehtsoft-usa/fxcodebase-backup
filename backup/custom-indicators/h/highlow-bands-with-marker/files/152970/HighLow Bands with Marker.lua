-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74260

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+


-- revisions
-- Nikolay.Gekht VER 1.0 2012 http://fxcodebase.com/code/viewtopic.php?f=17&t=20388
-- Steve_W       VER 2.0 17/102023

local version = 2;
local revision = 0;
local rev_author = "Steve_W";


function Init()
    indicator:name("High/Low Bands with Marker");
    indicator:description("Daily high/low bands with weekly line marker - adjust periods as required");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("TF_marker", "Marker Bar Size", "", "W1");
    indicator.parameters:setFlag("TF_marker", core.FLAG_PERIODS);
    indicator.parameters:addString("TF", "High/Low Band Bar Size", "", "D1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	indicator.parameters:addBoolean("display_marker", "Display Marker", "", true);
    indicator.parameters:addBoolean("YTD", "Show Previous Band", "Choose yes to show previous high/low band instead of current", false);
	indicator.parameters:addBoolean("Extend", "Extend Band to Bar End", "", true);
    
    indicator.parameters:addGroup("Marker");
    indicator.parameters:addColor("clrM", "Line Color", "", core.rgb(0, 128, 255));
    indicator.parameters:addInteger("WidthM", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("StyleM", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("StyleM", core.FLAG_LEVEL_STYLE);
	
    indicator.parameters:addGroup("High/Low Band");
    indicator.parameters:addColor("clrB", "Band Color", "", core.rgb(192, 192, 192));
    indicator.parameters:addInteger("Width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("A", "Band transparency (%)", "", 95, 0, 100);
    
	indicator.parameters:addGroup("Labels");
    indicator.parameters:addBoolean("ShowLabelPip", "Show Size Labels", "", false);
    indicator.parameters:addBoolean("ShowLabelFrame", "Show Frame Labels", "", false);
    indicator.parameters:addColor("LabelC", "Label Color", "", core.COLOR_LABEL);
    indicator.parameters:addInteger("LabelI", "Label Size", "", 8, 6, 24);
    indicator.parameters:addInteger("LabelLoc", "Label Location", "", 1);
    indicator.parameters:addIntegerAlternative("LabelLoc", "Above", "", 1);
    indicator.parameters:addIntegerAlternative("LabelLoc", "Below", "", 2);
	
	indicator.parameters:addGroup("About");
	indicator.parameters:addInteger("version", "Version", "", version, version, version);
	indicator.parameters:addInteger("revision", "Revision", "", revision, revision, revision);
	indicator.parameters:addString("rev_author", "Revision Author", "for this code revision", rev_author);
end

local source;                   -- the source
local hilo_data = nil;          -- the high/low data
local H;                        -- high stream
local L;                        -- low stream
local TF;
local TF_marker;
local BSLen;
local dates;                    -- candle dates
local CLen;
local host;
local dayoffset;
local weekoffset;
local hl_date;                  -- stream of the high/low candle dates
local marker_date;              -- stream of marker candle dates
local YTD;
local Extend;
local maxBarsPerBS;
local ShowLabelPip;
local ShowLabelFrame;
local LabelLoc;
local Labels;
local pipSize;
local formatPips;
local hilo_data, marker_data;
local loaded = false;
local name;
function Prepare(nameOnly)
    source = instance.source;
    host = core.host;
    dayoffset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    TF = instance.parameters.TF;
    TF_marker = instance.parameters.TF_marker;
    YTD = instance.parameters.YTD;
    Extend = instance.parameters.Extend;
    ShowLabelPip = instance.parameters.ShowLabelPip;
    ShowLabelFrame = instance.parameters.ShowLabelFrame;
    LabelLoc = instance.parameters.LabelLoc;
    local YTDn;
    if YTD then
        YTDn = "Prev";
    else
        YTDn = "Curr";
    end

	name = profile:id() .. "(" .. source:name() .. "," .. TF_marker .. "," .. TF .. "," .. YTDn .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
    local l1, l2;
    local s, e;

    s, e = core.getcandle(source:barSize(), core.now(), 0);
    l1 = e - s;
    s, e = core.getcandle(TF, core.now(), 0);
    l2 = e - s;
    CLen = l1;
    BSLen = l2; -- remember length of the period
    assert(l1 <= l2, "The chosen time frame must be the same of longer than the chart time frame");
    if Extend then
        maxBarsPerBS = math.floor(l2 / l1 + 0.5);
    else
        maxBarsPerBS = 0;
    end
	
    hilo_data = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0, 100, 101);
	marker_data = core.host:execute("getSyncHistory", source:instrument(), TF_marker, source:isBid(), 0, 200, 201);

    H = instance:addStream("H", core.Line, name .. ".H", "H", instance.parameters.clrB, 0, maxBarsPerBS);
    H:setStyle(instance.parameters.Style);
    H:setWidth(instance.parameters.Width);
    L = instance:addStream("L", core.Line, name .. ".L", "L", instance.parameters.clrB, 0, maxBarsPerBS);
    L:setStyle(instance.parameters.Style);
    L:setWidth(instance.parameters.Width);
    instance:createChannelGroup("HL", "HL", H, L, instance.parameters.clrB, 100 - instance.parameters.A, true);
    hl_date = instance:addInternalStream(0, 0);
    marker_date = instance:addInternalStream(0, 0);
    if ShowLabelPip or ShowLabelFrame then
        pipSize = source:pipSize();
        formatPips = "%.1f pips";
        local align;
        if LabelLoc == 1 then
            align = core.V_Top;
        else
            align = core.V_Bottom;
        end
        Labels = instance:createTextOutput("Labels", "Lbl", "Arial", instance.parameters.LabelI, core.H_Right, align, instance.parameters.LabelC, 0);
    end
	
	instance:ownerDrawn(true);
end


-- owner-drawn for painting markers
local draw_init = false;
local MARKER_PEN = 1;
function Draw(stage, context)
	-- setup marker pen
	if draw_init == false then
		context:createPen(	MARKER_PEN,
							context:convertPenStyle(instance.parameters.StyleM),
							instance.parameters.WidthM,
							instance.parameters.clrM);
		draw_init = true;
	end
	
	if stage == 2 and instance.parameters.display_marker == true then
		local i;
		for i = 2, marker_date:size(), 1 do
			-- draw new marker if date has changed
			if marker_date:hasData(i - 1) and marker_date:hasData(i) then	-- prevent nil errors
				if marker_date[i - 1] ~= marker_date[i] then
					local x = context:positionOfDate(marker_date[i]);
					context:drawLine(MARKER_PEN, x, context:top(), x, context:bottom());
				end
			end
		end
	end
end


-- the function which is called to calculate the period
function Update(period, mode)
    local hilo_candle;
	local marker_candle;
    hilo_candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);
	marker_date[period] = core.getcandle(TF_marker, source:date(period), dayoffset, weekoffset);

	-- indicate loading as we have multiple sources
	if loaded == true then
		instance:name(name);
	else
	    instance:name(name .. "  Loading...");
		return;	-- do nothing else until loaded
	end
	
    if period < source:first() then return end

    local hilo_i, marker_i = Initialization(period) 
    if hilo_i < 0 or marker_i < 0 then return end

    if YTD then
        if hilo_i == 0 then
            return;
        end
        hilo_i = hilo_i - 1;
    end

    H[period] = hilo_data.high[hilo_i];
    L[period] = hilo_data.low[hilo_i];
    hl_date[period] = hilo_candle;
    if period > 0 and hl_date[period - 1] ~= hl_date[period] then
        H:setBreak(period, true);
        L:setBreak(period, true);
    else
        H:setBreak(period, false);
        L:setBreak(period, false);
    end

	if source:isAlive() and period > source:first() and period == source:size() - 1 then
        -- update all today's data in case today's high low is changed
        if hl_date:hasData(period - 1) and hl_date[period - 1] == hilo_candle and
           ((H[period - 1] ~= H[period]) or (L[period - 1] ~= L[period]))  then
            local i = period - 1;
            local h = hilo_data.high[hilo_i];
            local l = hilo_data.low[hilo_i];
            while i > 0 and hl_date:hasData(i) and hl_date[i] == hilo_candle do
                H[i] = h;
                L[i] = l;
                i = i - 1
            end

            if ShowLabelPip or ShowLabelFrame then
                local text;
                text = "";
                if ShowLabelFrame then
                    text = text .. TF;
                end
                if ShowLabelPip then
                    if ShowLabelFrame then
                        text = text .. ",";
                    end
                    text = text .. string.format(formatPips, (H[i + 1] - L[i + 1]) / pipSize);
                end
                local loc;
                if LabelLoc == 1 then
                    loc = H[i + 1];
                else
                    loc = L[i + 1];
                end
                Labels:set(period, loc, text);
            end
        end
    end

    if Extend and period == source:size() - 1 then
        local i = period + 1;
        local b = source:date(period) + CLen;
        local h = hilo_data.high[hilo_i];
        local l = hilo_data.low[hilo_i];
        while i < H:size() and b < hilo_candle + BSLen do
            if H:hasData(i) and H[i] == h and L[i] == l then
                break;
            end
            H[i] = h;
            L[i] = l;
            i = i + 1;
            b = b + CLen;
        end
    end

    if (ShowLabelPip or ShowLabelFrame) and (period == 0 or hl_date[period - 1] ~= hilo_candle) then
        local text;
        text = "";
        if ShowLabelFrame then
            text = text .. TF;
        end
        if ShowLabelPip then
            if ShowLabelFrame then
                text = text .. ",";
            end
            text = text .. string.format(formatPips, (H[period] - L[period]) / pipSize);
        end
        local loc;
        if LabelLoc == 1 then
            loc = H[period];
        else
            loc = L[period];
        end
        Labels:set(period, loc, text);
    end
end


-- the function is called when the async operation is finished
local loaded_hl;
local loaded_marker;
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loaded_hl = true;
    elseif cookie == 101 then
        loaded_hl = false;
    end
	if cookie == 200 then
		loaded_marker = true;
	elseif cookie == 201 then
		loaded_marker = false;
	end
	
	if loaded_marker == true and
		loaded_hl == true
	then
		loaded = true;
		instance:updateFrom(0);
	else
		loaded = false;
	end
end


function Initialization(period)
    -- look for candle in both data streams
	local Candle;
    Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);
	local p = core.findDate(hilo_data, Candle, false);
	local q = core.findDate(marker_data, Candle, false);
	
	-- check size and period
    if hilo_data:size() == 0 or
		marker_data:size() == 0 or
		period < source:first()
	then
        p = -1;	-- emulate candle not found...
		q = -1;
    end

    return p, q;
end


--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+