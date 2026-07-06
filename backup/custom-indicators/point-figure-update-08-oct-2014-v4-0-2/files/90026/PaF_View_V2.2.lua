-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Point & Figure Chart");
    indicator:description("Beta View Indicator Point and Figure Chart");
    indicator:requiredSource(core.Tick);
    indicator:type(core.View);
	
	indicator.parameters:addGroup("PF - Instrument");
	indicator.parameters:addString("instrument", "Instrument", "", "GBP/USD");
    indicator.parameters:setFlag("instrument", core.FLAG_INSTRUMENTS);
    indicator.parameters:addBoolean("type", "Bid or Ask", "No description", true);
    indicator.parameters:setFlag("type", core.FLAG_BIDASK);
    indicator.parameters:addString(   "TF", "TF", "Source Time frame ('m1', 'm5', etc.)", "m5");
    indicator.parameters:setFlag(   "TF", core.FLAG_PERIODS);
    indicator.parameters:addDate("from", "Date From", "", -700);
	
	indicator.parameters:addGroup("PF - Calculation");
    indicator.parameters:addInteger("BS", "Box Size (in pips)", "No description", 10);
    indicator.parameters:addInteger("RS", "Reversal Count (in boxes)", "No description", 3);
    indicator.parameters:addBoolean("Ignore", "Ignore High/Low", "No description", false);
    indicator.parameters:addBoolean("EndOfTheDay", "End of The Day", "If Enabled, drawing only at new source candle", true);
	
	indicator.parameters:addGroup("PF - Style");
	indicator.parameters:addString("Fonts", "Fonts", "", "Comic Sans MS");
	indicator.parameters:addColor("Bull", "Color of X's", "", core.rgb(0,192,255));
	indicator.parameters:addColor("Bear", "Color of O's", "", core.rgb(255,255,255) );
	indicator.parameters:addBoolean("bDay", "Show Days", "No description", true);
	indicator.parameters:addColor("cDay", "Color of Day", "", core.rgb(255, 128, 0));
	indicator.parameters:addBoolean("bMonth", "Show Month", "No description", true);
	indicator.parameters:addColor("cMonth", "Color of Month", "", core.rgb(255, 0, 128) );
	indicator.parameters:addColor("cNext", "Color of Next", "", core.rgb(255, 255, 0) );
	
	indicator.parameters:addGroup("PF - TrendLines")
	indicator.parameters:addBoolean("tl45", "TL 45 degree", "No description", true);
    indicator.parameters:addColor("TLu45_color", "Color of TLu45", "Color of TLu45", core.rgb(0, 128, 128));
    indicator.parameters:addColor("TLd45_color", "Color of TLd45", "Color of TLd45", core.rgb(255, 128, 128));
	indicator.parameters:addBoolean("tl22", "TL 22.5 degree", "No description", true);
    indicator.parameters:addColor("TLu22_color", "Color of TLu22", "Color of TLu22", core.rgb(128, 255, 255));
    indicator.parameters:addColor("TLd22_color", "Color of TLd22", "Color of TLd22", core.rgb(255, 255, 128));
	indicator.parameters:addBoolean("useLines", "Lines instead of +", "No description", false);
	indicator.parameters:addBoolean("useAdaptive", "Adaptive Mode", "No description", true);
	indicator.parameters:addInteger("widthTL", "TL Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleTL", "TL Line Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("styleTL", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("PF - Pattern");
	indicator.parameters:addBoolean("enTTB", "Triple Top and Bottom", "Enable Triple Top or Bottom", true);
	indicator.parameters:addBoolean("enShakeOut", "ShakeOut", "Enable Bull or Bear ShakeOut", true);
	indicator.parameters:addBoolean("enCatapult", "Catapult", "Enable Bull or Bear Catapult", true);
	indicator.parameters:addBoolean("enTriangle", "Triangle", "Enable Bull or Bear Triangle", true);
	indicator.parameters:addBoolean("enFlag", "Flag", "Enable Bull or Bear Signal Reversed", true);
	indicator.parameters:addColor("Long_color", "Color of Bull", "Color of Bull", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Short_color", "Color of Bear", "Color of Bear", core.rgb(255, 0, 0));
	indicator.parameters:addBoolean("enPatternLine", "Draw Lines", "No description", true);
	indicator.parameters:addInteger("widthP", "Pattern Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleP", "Pattern Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleP", core.FLAG_LINE_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local BS;
local RS;
local Ignore;
local EndOfTheDay;
local frame;
local bid;
local instrument;
-- Streams block
local open = nil;
local high = nil;
local low = nil;
local close = nil;
local volume = nil;
local tick;
local first;
-- Variables
local lastSerial;
local offer;
local digits;
local point;
local loading;
local history;
-- Colors
local col = {X,O,Day,Month,Next};

local newDay;
local newMonth;
-- TrendLines
local TL45 = {};
local TL22 = {};
-- Pattern
local pattern = {};
local TTID = 10000;
local lastClose = 0;
-- Routine
function Prepare(nameOnly)
	local name;
	instrument 	= instance.parameters.instrument;
    BS 			= instance.parameters.BS;
    RS 			= instance.parameters.RS;
    Ignore 		= instance.parameters.Ignore;
    EndOfTheDay = instance.parameters.EndOfTheDay;
    bid 		= instance.parameters.type;
	frame 		= instance.parameters.TF;
	
	col.X 		= instance.parameters.Bull;
	col.O 		= instance.parameters.Bear;
	col.Day 	= instance.parameters.cDay;
	col.Month 	= instance.parameters.cMonth;
	col.Next 	= instance.parameters.cNext;

    name    =  profile:id() .. "(" .. instrument .. ", " .. BS ..", " ..RS..")";
    name    = name .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    -- check whether the instrument is available
    local offers = core.host:findTable("offers");
    local enum = offers:enumerator();
    local row;
 
    row = enum:next();
    while row ~= nil do
        if row.Instrument == instrument then
            break;
        end
        row = enum:next();
    end
    assert(row ~= nil, "Instrument is not found");

    offer = row.OfferID;
    digits = row.Digits;
    point = row.PointSize
	BS = BS*point;
    instance:initView(instrument, digits, point, bid, true);
    loading = true;
    history = core.host:execute("getHistory", 1000, instrument, frame, instance.parameters.from, 0, bid);
	core.host:execute("setStatus", "Loading History");
    core.host:execute("subscribeTradeEvents", 2000, "offers");

    open 		= instance:addStream("open", core.Line, name .. ".open", "open", 0,0,0);
    high 		= instance:addStream("high", core.Line, name .. ".high", "high", 0,0,0);
    low 		= instance:addStream("low", core.Line, name .. ".low", "low", 0,0,0);
    close 		= instance:addStream("close", core.Line, name .. ".close", "close", 0,0,0);
    volume 		= instance:addStream("volume", core.Line, name .. ".volume", "volume", 0,0,0);
	sdate 		= instance:addInternalStream(0, 0);
	tick 		= instance:addInternalStream(0, 0);
	direction	= instance:addInternalStream(0, 0);
	newDay 		= instance:addInternalStream(0, 0);
	newMonth 	= instance:addInternalStream(0, 0);
	
    instance:createCandleGroup("pf", "pf", open, high, low, close, volume, "PF", false);
	
    open:setVisible(false);
	high:setVisible(false);
    low:setVisible(false);
    close:setVisible(false);
    instance:ownerDrawn(true);
	-- TrendLines
	widthTL 			= instance.parameters.widthTL;
	styleTL 			= instance.parameters.styleTL;
	TL45 = {up			= instance:addStream("TL45up", core.Line, name .. ".TL45up", "TL45up", instance.parameters.TLu45_color,0,0),
			dn			= instance:addStream("TL45dn", core.Line, name .. ".TL45dn", "TL45dn", instance.parameters.TLd45_color,0,0)};
	TL45.up:setStyle(styleTL);
	TL45.up:setWidth(widthTL);
	TL45.dn:setStyle(styleTL);
	TL45.dn:setWidth(widthTL);
	if instance.parameters.tl45 == false or instance.parameters.useLines == false then
		TL45 = {up			= instance:addInternalStream(0, 0),
				dn			= instance:addInternalStream(0, 0)};
	end
	TL22 = {Enable		= instance.parameters.tl22,
			Lines       = instance.parameters.useLines,
			up			= instance:addStream("TL22up", core.Line, name .. ".TL22up", "TL22up", instance.parameters.TLu22_color,0,0),
			dn			= instance:addStream("TL22dn", core.Line, name .. ".TL22dn", "TL22dn", instance.parameters.TLd22_color,0,0)};
	TL22.up:setStyle(styleTL);
	TL22.up:setWidth(widthTL);
	TL22.dn:setStyle(styleTL);
	TL22.dn:setWidth(widthTL);
	if TL22.Enable == false or TL22.Lines == false then
		TL22.up = instance:addInternalStream(0, 0);
		TL22.dn = instance:addInternalStream(0, 0);
	end
	-- Pattern
	pattern = {	TTB 		= {	Enable 	= instance.parameters.enTTB,
								s 		= instance:addInternalStream(0, 0),
								lt 		= instance:addInternalStream(0, 0),
								lb 		= instance:addInternalStream(0, 0)},
				ShakeOut 	= {	Enable 	= instance.parameters.enShakeOut,
								s 		= instance:addInternalStream(0, 0)},
				Catapult	= { Enable  = instance.parameters.enCatapult,
								s		= instance:addInternalStream(0, 0),
								lt1 	= instance:addInternalStream(0, 0),
								lb1 	= instance:addInternalStream(0, 0),
								lt2 	= instance:addInternalStream(0, 0),
								lb2 	= instance:addInternalStream(0, 0)},
				Triangle	= { Enable  = instance.parameters.enTriangle,
								s		= instance:addInternalStream(0, 0),
								lt 		= instance:addInternalStream(0, 0),
								lb 		= instance:addInternalStream(0, 0),
								l1 		= instance:addInternalStream(0, 0),
								l2 		= instance:addInternalStream(0, 0)},
				Flag		= { Enable  = instance.parameters.enFlag,
								s		= instance:addInternalStream(0, 0),
								lt 		= instance:addInternalStream(0, 0),
								lb 		= instance:addInternalStream(0, 0),
								l1 		= instance:addInternalStream(0, 0),
								l2 		= instance:addInternalStream(0, 0)},								
				cBuy		= instance.parameters.Long_color,
				cSell		= instance.parameters.Short_color,
				widthP		= instance.parameters.widthP,
				styleP		= instance.parameters.styleP};
	
	pattern.Catapult.s:setWidth(3);
end
function ReleaseInstance()
	core.host:execute("removeAll");
end
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    --- NOT USED in VIEW Indicator
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Async Function History and Tick handling -----------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
function AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 1000 then
		for i = 0, history:size() - 1, 1 do
			if i == history:size() - 1 then
				lastSerial = history:serial(i);
			end
			if Ignore then
				if RS < 2 then
					proccesWyckoff(i,history:date(i),history.close[i],history.close[i]);
				else
					proccesCandle(i,history:date(i),history.close[i],history.close[i]);
				end
			else
				if RS < 2 then
					proccesWyckoff(i,history:date(i),history.high[i],history.low[i]);
				else
					proccesCandle(i,history:date(i),history.high[i],history.low[i]);
				end
			end
			checkNewMonthOrDay(i);
			-- TrendLines
			proccesTL45();
			proccesTL22();
			-- Pattern
			proccesPattern();
		end
		loading = false;
		core.host:execute("setStatus", "");
    elseif cookie == 2000 then
        if message == offer and loading == false then
			local i = history:size() - 1;
			if EndOfTheDay then
				if lastSerial ~= history:serial(i) and lastSerial ~= nil then
					if Ignore then
						if RS < 2 then
							proccesWyckoff(history:size() - 2,history:date(history:size() - 2),history.close[history:size() - 2],history.close[history:size() - 2]);
						else
							proccesCandle(history:size() - 2,history:date(history:size() - 2),history.close[history:size() - 2],history.close[history:size() - 2]);
						end
					else
						if RS < 2 then
							proccesWyckoff(history:size() - 2,history:date(history:size() - 2),history.high[history:size() - 2],history.low[history:size() - 2]);
						else
							proccesCandle(history:size() - 2,history:date(history:size() - 2),history.high[history:size() - 2],history.low[history:size() - 2]);
						end
					end
					lastSerial = history:serial(i);
				end
			else
				local Time = core.host:findTable("offers"):find("OfferID", offer).Time;
				if RS < 2 then
					proccesWyckoff(i,Time,history.close[i],history.close[i]);
				else
					proccesCandle(i,Time,history.close[i],history.close[i]);
				end
			end
			if lastClose ~= close[open:size()-1] then
				checkNewMonthOrDay(i);
				-- TrendLines
				proccesTL45();
				proccesTL22();
				-- Pattern
				proccesPattern();
				lastClose = close[open:size()-1] ;
			end
        end
    end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Pattern Calculation --------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
function proccesPattern()
	core.host:execute ("removeLine", TTID+1);
	if pattern.TTB.Enable then
		tripleTB();
	end
	if pattern.ShakeOut.Enable then
		ShakeOut();
	end
	if pattern.Catapult.Enable then
		Catapult();
	end
	if pattern.Triangle.Enable then
		Triangle();
	end
	if pattern.Flag.Enable then
		Flag();
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function Flag()
	local period = open:size() - 1;
	if period < 7 then 
		return; 
	end
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Bullish ---------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	if direction[period] == 1 then
		if 	isSmaller(high[period-2],high[period-4]) and isSmaller(high[period-4],high[period-6]) and 
			isSmaller(low[period-1],low[period-3]) and isSmaller(low[period-3],low[period-5]) then
			if isGreaterOrEqual(high[period],high[period-2] + BS) then
				if instance.parameters.enPatternLine then
					TTID = TTID + 1;
					core.host:execute ("drawLine", TTID, sdate[period-6], high[period-6], sdate[period-2], high[period-2], col.Next,pattern.styleP,pattern.widthP,"Bull Flag");
					TTID = TTID + 1;
					core.host:execute ("drawLine", TTID, sdate[period-5], low[period-5], sdate[period-1], low[period-1], col.Next,pattern.styleP,pattern.widthP,"Bull Flag");
					TTID = TTID + 1;
					core.host:execute ("drawLine", TTID, sdate[period-2], high[period-2], sdate[period], high[period-2], col.Next,pattern.styleP,pattern.widthP,"Bull Flag");
				end
				pattern.Flag.s[period] = high[period-2] + BS;
			else
			
			end
		end
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Bearish ---------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	elseif direction[period] == -1 then
		if 	isGreater(low[period-2],low[period-4]) and isGreater(low[period-4],low[period-6]) and 
			isGreater(high[period-1],high[period-3]) and isGreater(high[period-3],high[period-5]) then
			if isSmallerOrEqual(low[period],low[period-2] - BS) then
				if instance.parameters.enPatternLine then
					TTID = TTID + 1;
					core.host:execute ("drawLine", TTID, sdate[period-5], high[period-5], sdate[period-1], high[period-1], col.Next,pattern.styleP,pattern.widthP,"Bear Flag");
					TTID = TTID + 1;
					core.host:execute ("drawLine", TTID, sdate[period-6], low[period-6], sdate[period-2], low[period-2], col.Next,pattern.styleP,pattern.widthP,"Bear Flag");
					TTID = TTID + 1;
					core.host:execute ("drawLine", TTID, sdate[period-2], low[period-2], sdate[period], low[period-2], col.Next,pattern.styleP,pattern.widthP,"Bear Flag");
				end
				pattern.Flag.s[period] = low[period-2] - BS;
			else
			
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function Triangle()
	local period = open:size() - 1;
	if period < 6 then 
		return; 
	end
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Bullish ---------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	if direction[period] == 1 then
		if 	isSmaller(high[period-2],high[period-4]) and isSmaller(high[period-4],high[period-6]) and 
			isGreater(low[period-1],low[period-3]) and isGreater(low[period-3],low[period-5]) then
			if isGreaterOrEqual(close[period],close[period-2] + BS) then
				if instance.parameters.enPatternLine then
					TTID = TTID + 1;
					core.host:execute ("drawLine", TTID, sdate[period-6], high[period-6], sdate[period-2], high[period-2], col.Next,pattern.styleP,pattern.widthP,"Bull Triangle");
					TTID = TTID + 1;
					core.host:execute ("drawLine", TTID, sdate[period-5], low[period-5], sdate[period-1], low[period-1], col.Next,pattern.styleP,pattern.widthP,"Bull Triangle");
					TTID = TTID + 1;
					core.host:execute ("drawLine", TTID, sdate[period-2], high[period-2], sdate[period], high[period-2], col.Next,pattern.styleP,pattern.widthP,"Bull Triangle");
				end
				core.drawLine (pattern.Triangle.lt, core.range(period-2, period) , high[period-2], period-2, high[period-2], period);
				core.drawLine (pattern.Triangle.l1, core.range(period-6, period-2) , high[period-6], period-6, high[period-2], period-2);
				core.drawLine (pattern.Triangle.l2, core.range(period-5, period-1) , low[period-5], period-5, low[period-1], period-1);
				pattern.Triangle.s[period] = high[period-2] + BS;
			else
			
			end
		end
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Bearish ---------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	elseif direction[period] == -1 then
		if 	isSmaller(high[period-1],high[period-3]) and isSmaller(high[period-3],high[period-5]) and 
			isGreater(low[period-2],low[period-4]) and isGreater(low[period-4],low[period-6]) then
			if isSmallerOrEqual(close[period],close[period-2] - BS) then
				if instance.parameters.enPatternLine then
					TTID = TTID + 1;
					core.host:execute ("drawLine", TTID, sdate[period-5], high[period-5], sdate[period-1], high[period-1], col.Next,pattern.styleP,pattern.widthP,"Bear Triangle");
					TTID = TTID + 1;
					core.host:execute ("drawLine", TTID, sdate[period-6], low[period-6], sdate[period-2], low[period-2], col.Next,pattern.styleP,pattern.widthP,"Bear Triangle");
					TTID = TTID + 1;
					core.host:execute ("drawLine", TTID, sdate[period-2], low[period-2], sdate[period], low[period-2], col.Next,pattern.styleP,pattern.widthP,"Bear Triangle");
				end
				core.drawLine (pattern.Triangle.lb, core.range(period-2, period) , low[period-2], period-2, low[period-2], period);
				core.drawLine (pattern.Triangle.l1, core.range(period-6, period-2) , low[period-6], period-6, low[period-2], period-2);
				core.drawLine (pattern.Triangle.l2, core.range(period-5, period-1) , high[period-5], period-5, high[period-1], period-1);
				pattern.Triangle.s[period] = low[period-2] - BS;
			else
			
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function Catapult()
	local period = open:size() - 1;
	if period < 14 then 
		return; 
	end
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Bullish ---------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	if direction[period] == 1 then
		local pos2 = nil;
		local pos1 = nil;
		local top;
		local stType ;
		for i = 0 , 12, 2 do
			if pos1 ~= nil then
				if isSmaller(high[pos1],high[pos1 - i]) then
					break;
				end
			end
			if 	isEqual(high[period-4],high[period-6]) then
				if 	isGreaterOrEqual(high[period-4],high[period-6-i]) then
					if 	isEqual(high[period-4],high[period-6-i]) then
						pos1 = period-4;
						pos2 = 6+i;
						top = (pos2 )/2;
						stType = tostring(top) .. "-Tops";
					end
				else 
					break;
				end
			elseif 	isEqual(high[period-6],high[period-8]) and 
					isGreater(high[period-6],high[period-4]) then
				if 	isGreaterOrEqual(high[period-6],high[period-8-i]) then
					if 	isEqual(high[period-6],high[period-8-i]) then
						pos1 = period-6;
						pos2 = 8+i;
						top = (pos2-2)/2;
						stType = "Spread- " .. tostring(top) .. "-Tops"
					end
				else 
					break;
				end
			elseif 	isEqual(high[period-4],high[period-8]) and 
					isGreater(high[period-4],high[period-6]) then
				if 	isGreaterOrEqual(high[period-4],high[period-8-i]) then
					if 	isEqual(high[period-4],high[period-8-i]) then
						pos1 = period-4;
						pos2 = 8+i;
						top = (pos2-2)/2;
						stType = "Spread- " .. tostring(top) .. "-Tops";
					end
				else 
					break;
				end
			else
				break;
			end
		end
		if  pos1 ~= nil then
			if isEqual(high[period-2],high[pos1]+BS) and isGreaterOrEqual(high[period],high[period-2]+BS) and isGreater(low[period-1],low[period-3]) then
				min, minpos = mathex.min(low, period - pos2 + 1, period);
				TP = high[pos1] + (high[pos1] - min) + BS;
				--iTP:set (period, TP, "---" , "TP");
				SL = high[pos1] - (high[pos1] - min) - BS;
				--iSL:set (period, SL, "---" , "SL");
				if instance.parameters.enPatternLine then
					TTID = TTID + 1;
					core.host:execute ("drawLine", TTID, sdate[period-pos2], high[pos1], sdate[period], high[pos1], col.Next,pattern.styleP,pattern.widthP,stType);
					TTID = TTID + 1;
					core.host:execute ("drawLine", TTID, sdate[period-2], high[period-2], sdate[period], high[period-2], col.Next,pattern.styleP,pattern.widthP,stType);
				end
				core.drawLine (pattern.Catapult.lt1, core.range(period-2, period) , high[period-2], period-2, high[period-2], period);
				core.drawLine (pattern.Catapult.lt2, core.range(period-pos2, pos1) , high[pos1], period-pos2, high[pos1], pos1);
				pattern.Catapult.s[period] = high[period-2] + BS;
			elseif isEqual(high[period-2],high[pos1]+BS) and isGreater(low[period-1],low[period-3]) then
				core.host:execute ("drawLine", TTID+1, sdate[period-2], high[period-2], sdate[period], high[period-2], col.Next,pattern.styleP,pattern.widthP,stType);
			end
		end
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Bearish ---------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	elseif direction[period] == -1 then
		local pos2 = nil;
		local pos1 = nil;
		local top;
		local stType ;
		for i = 0 , 12, 2 do
			if pos1 ~= nil then
				if isGreater(low[pos1],low[pos1 - i]) then
					break;
				end
			end
			if 	isEqual(low[period-4],low[period-6]) then
				if 	isSmallerOrEqual(low[period-4],low[period-6-i]) then
					if 	isEqual(low[period-4],low[period-6-i]) then
						pos1 = period-4;
						pos2 = 6+i;
						top = (pos2 )/2;
						stType = tostring(top) .. "-Bottoms";
					end
				else
					break;
				end
			elseif 	isEqual(low[period-6],low[period-8]) and 
					isSmaller(low[period-6],low[period-4]) then
				if 	isSmallerOrEqual(low[period-6],low[period-8-i]) then
					if 	isEqual(low[period-6],low[period-8-i]) then
						pos1 = period-6;
						pos2 = 9+i;
						top = (pos2-2)/2;
						stType = "Spread- " .. tostring(top) .. "-Bottoms";
					end
				else
					break;
				end
			elseif 	isEqual(low[period-4],low[period-8]) and 
					isSmaller(low[period-4],low[period-6]) then
				if 	isSmallerOrEqual(low[period-4],low[period-8-i]) then
					if 	isEqual(low[period-4],low[period-8-i]) then
						pos1 = period-4;
						pos2 = 8+i;
						top = (pos2-2)/2;
						stType = "Spread- " .. tostring(top) .. "-Bottoms";
					end
				else
					break;
				end
			else
				break;
			end
		end
		if  pos1 ~= nil then
			if isEqual(low[period-2],low[pos1]-BS) and isSmallerOrEqual(low[period],low[period-2]-BS) and isSmaller(high[period-1],high[period-3]) then
				max, minpos = mathex.max(high, period - pos2 + 1, period);
				TP = low[pos1] - (max - low[pos1]) - BS;
				--iTP:set (period, TP, "---" , "TP");
				SL = low[pos1] + (max - low[pos1]) + BS;
				--iSL:set (period, SL, "---" , "SL");
				if instance.parameters.enPatternLine then
					TTID = TTID + 1;
					core.host:execute ("drawLine", TTID, sdate[period-pos2], low[pos1], sdate[period], low[pos1], col.Next,pattern.styleP,pattern.widthP,stType);
					TTID = TTID + 1;
					core.host:execute ("drawLine", TTID, sdate[period-2], low[period-2], sdate[period], low[period-2], col.Next,pattern.styleP,pattern.widthP,stType);
				end
				core.drawLine (pattern.Catapult.lb1, core.range(period-2, period) , low[period-2], period-2, low[period-2], period);
				core.drawLine (pattern.Catapult.lb2, core.range(period-pos2, pos1) , low[pos1], period-pos2, low[pos1], pos1);
				pattern.Catapult.s[period] = low[period-2] - BS;
			elseif isEqual(low[period-2],low[pos1]-BS) and isSmaller(high[period-1],high[period-3]) then
				core.host:execute ("drawLine", TTID+1, sdate[period-2], low[period-2], sdate[period], low[period-2], col.Next,pattern.styleP,pattern.widthP,stType);
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function ShakeOut()
	local period = open:size() - 1;
	if period < 4 then 
		return; 
	end
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Bullish ---------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	if direction[period] == 1 then
		if isGreaterOrEqual(volume[period],3) and isEqual(high[period-4],high[period-2]) and isGreaterOrEqual(volume[period-3],volume[period-1]-3) and
			isSmaller(volume[period-3],volume[period-1]) and isUnEqual(TL45.up[period],0) then
			pattern.ShakeOut.s[period] = open[period] + (RS-1)*BS;
			--TTID = TTID + 1;
			local TP = low[period-1] + 5*BS*2;
			if instance.parameters.enPatternLine then
				TTID = TTID + 1;
				core.host:execute ("drawLine", TTID, sdate[period-4], high[period-4], sdate[period], high[period-4], col.Next,pattern.styleP,pattern.widthP,"TP - Bull ShakeOut");
				TTID = TTID + 1;
				core.host:execute ("drawLine", TTID, sdate[period-3], low[period-3], sdate[period], low[period-3], col.Next,pattern.styleP,pattern.widthP,"TP - Bull ShakeOut");
			end
			--core.host:execute ("drawLine", TTID, sdate[period-1], TP, sdate[period], TP, cBull,styleP,widthP,"TP - Bull Trap");
			--TTID = TTID + 1;
			--core.host:execute ("drawLine", TTID, sdate[period-1], low[period-1]-BS, sdate[period], low[period-1]-BS, cBear,styleP,widthP,"SL - Bull Trap");
		end
		-- False Bear Trap
		if isGreater(high[period],high[period-2]) and 
			isEqual(volume[period-1],3) and 
			isEqual(low[period-5],low[period-3]) and 
			isGreaterOrEqual(volume[period-4],volume[period-2]-3) and
			isSmaller(volume[period-4],volume[period-2]) and isUnEqual(TL45.up[period],0) then
			pattern.ShakeOut.s[period] = high[period] + BS;
			--TTID = TTID + 1;
			local TP = low[period-3] + 6*BS*2;
			if instance.parameters.enPatternLine then
				TTID = TTID + 1;
				core.host:execute ("drawLine", TTID, sdate[period-2], high[period-2], sdate[period], high[period-2], col.Next,pattern.styleP,pattern.widthP,"TP - Bear Reversal ShakeOut");
			end
			--core.host:execute ("drawLine", TTID, sdate[period-1], TP, sdate[period], TP, cBull,styleP,widthP,"TP - Bull Trap");
			--TTID = TTID + 1;
			--core.host:execute ("drawLine", TTID, sdate[period-1], low[period-1]-BS, sdate[period], low[period-1]-BS, cBear,styleP,widthP,"SL - Bull Trap");
		end
	elseif direction[period] == -1 then
		if isGreaterOrEqual(volume[period],3) and isEqual(low[period-4],low[period-2]) and isGreaterOrEqual(volume[period-3],volume[period-1]-3) and
			isSmaller(volume[period-3],volume[period-1]) and isUnEqual(TL45.dn[period],0) then
			pattern.ShakeOut.s[period] = open[period] - (RS-1)*BS;
				
			--TTID = TTID + 1;
			local TP = high[period-1] - 5*BS*2;
			if instance.parameters.enPatternLine then
				TTID = TTID + 1;
				core.host:execute ("drawLine", TTID, sdate[period-4], low[period-4], sdate[period], low[period-4], col.Next,pattern.styleP,pattern.widthP,"TP - Bear ShakeOut");
				TTID = TTID + 1;
				core.host:execute ("drawLine", TTID, sdate[period-3], high[period-3], sdate[period], high[period-3], col.Next,pattern.styleP,pattern.widthP,"TP - Bear ShakeOut");
			end
			--core.host:execute ("drawLine", TTID, sdate[period-1], TP, sdate[period], TP, cBull,styleP,widthP,"TP - Bear Trap");
			--TTID = TTID + 1;
			--core.host:execute ("drawLine", TTID, sdate[period-1], high[period-1]+BS, sdate[period], high[period-1]+BS, cBear,styleP,widthP,"SL - Bear Trap");
		end
		-- False Bull Trap
		if isSmaller(low[period],low[period-2]) and 
			isEqual(volume[period-1],3) and 
			isEqual(high[period-5],high[period-3]) and 
			isGreaterOrEqual(volume[period-4],volume[period-2]-3) and
			isSmaller(volume[period-4],volume[period-2]) and isUnEqual(TL45.dn[period],0) then
			pattern.ShakeOut.s[period] = low[period-2] - BS;
			--TTID = TTID + 1;
			local TP = high[period-3] - 6*BS*2;
			if instance.parameters.enPatternLine then
				TTID = TTID + 1;
				core.host:execute ("drawLine", TTID, sdate[period-2], low[period-2], sdate[period], low[period-2], col.Next,pattern.styleP,pattern.widthP,"TP - Bull Reversal ShakeOut");
			end
			--core.host:execute ("drawLine", TTID, sdate[period-1], TP, sdate[period], TP, cBull,styleP,widthP,"TP - Bear Trap");
			--TTID = TTID + 1;
			--core.host:execute ("drawLine", TTID, sdate[period-1], high[period-1]+BS, sdate[period], high[period-1]+BS, cBear,styleP,widthP,"SL - Bear Trap");
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function tripleTB()
	local period = open:size() - 1;
	core.host:execute ("removeLine", TTID + 1);
	if period < 16 then 
		return; 
	end
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Bullish ---------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	if isEqual(direction[period],1) then
		local pos2 = nil;
		local pos1 = nil;
		local top;
		local stType ;
		for i = 0 , 12, 2 do
			if pos1 ~= nil then
				if isSmaller(high[pos1],high[pos1 - i]) then
					break;
				end
			end
			if 	isEqual(high[period-2],high[period-4]) then
				if 	isGreaterOrEqual(high[period-2],high[period-4-i]) then
					if 	isEqual(high[period-2],high[period-4-i]) then
						pos1 = period-2;
						pos2 = 4+i;
						top = (pos2 +2)/2;
						stType = tostring(top) .. "-Tops";
					end
				else 
					break;
				end
			elseif 	isEqual(high[period-4],high[period-6]) and 
					isGreater(high[period-4],high[period-2]) then
				if 	isGreaterOrEqual(high[period-4],high[period-6-i]) then
					if 	isEqual(high[period-4],high[period-6-i]) then
						pos1 = period-4;
						pos2 = 6+i;
						top = (pos2)/2;
						stType = "Spread- " .. tostring(top) .. "-Tops"
					end
				else 
					break;
				end
			elseif 	isEqual(high[period-2],high[period-6]) and 
					isGreater(high[period-2],high[period-4]) then
				if 	isGreaterOrEqual(high[period-2],high[period-6-i]) then
					if 	isEqual(high[period-2],high[period-6-i]) then
						pos1 = period-2;
						pos2 = 6+i;
						top = (pos2)/2;
						stType = "Spread- " .. tostring(top) .. "-Tops";
					end
				else 
					break;
				end
			else
				break;
			end
		end
		if  pos1 ~= nil then
			if isGreater(high[period],high[pos1]) and isGreater(low[period-1],low[period-3]) then
				min, minpos = mathex.min(low, period - pos2 + 1, period);
				TP = high[pos1] + (high[pos1] - min) + BS;
				--iTP:set (period, TP, "---" , "TP");
				SL = high[pos1] - (high[pos1] - min) - BS;
				--iSL:set (period, SL, "---" , "SL");
				if instance.parameters.enPatternLine then
					TTID = TTID + 1;
					core.host:execute ("drawLine", TTID, sdate[period-pos2], high[pos1], sdate[period], high[pos1], col.Next,pattern.styleP,pattern.widthP,stType);
				end
				core.drawLine (pattern.TTB.lt, core.range(period-pos2, period) , high[pos1], period-pos2, high[pos1], period);
				pattern.TTB.s[period] = high[pos1] + BS;
			else
				core.host:execute ("drawLine", TTID+1, sdate[period-pos2], high[pos1], sdate[period], high[pos1], col.Next,pattern.styleP,pattern.widthP,stType);
			end
		end
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Bearish ---------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	elseif isEqual(direction[period],-1) then
		local pos2 = nil;
		local pos1 = nil;
		local top;
		local stType ;
		for i = 0 , 12, 2 do
			if pos1 ~= nil then
				if isGreater(low[pos1],low[pos1 - i]) then
					break;
				end
			end
			if 	isEqual(low[period-2],low[period-4]) then
				if 	isSmallerOrEqual(low[period-2],low[period-4-i]) then
					if 	isEqual(low[period-2],low[period-4-i]) then
						pos1 = period-2;
						pos2 = 4+i;
						top = (pos2 +2)/2;
						stType = tostring(top) .. "-Bottoms";
					end
				else
					break;
				end
			elseif 	isEqual(low[period-4],low[period-6]) and 
					isSmaller(low[period-4],low[period-2]) then
				if 	isSmallerOrEqual(low[period-4],low[period-6-i]) then
					if 	isEqual(low[period-4],low[period-6-i]) then
						pos1 = period-4;
						pos2 = 6+i;
						top = (pos2)/2;
						stType = "Spread- " .. tostring(top) .. "-Bottoms";
					end
				else
					break;
				end
			elseif 	isEqual(low[period-2],low[period-6]) and 
					isSmaller(low[period-2],low[period-4]) then
				if 	isSmallerOrEqual(low[period-2],low[period-6-i]) then
					if 	isEqual(low[period-2],low[period-6-i]) then
						pos1 = period-2;
						pos2 = 6+i;
						top = (pos2)/2;
						stType = "Spread- " .. tostring(top) .. "-Bottoms";
					end
				else
					break;
				end
			else
				break;
			end
		end
		if  pos1 ~= nil then
			if isSmaller(low[period],low[pos1]) and isSmaller(high[period-1],high[period-3]) then
				max, minpos = mathex.max(high, period - pos2 + 1, period);
				TP = low[pos1] - (max - low[pos1]) - BS;
				--iTP:set (period, TP, "---" , "TP");
				SL = low[pos1] + (max - low[pos1]) + BS;
				--iSL:set (period, SL, "---" , "SL");
				if instance.parameters.enPatternLine then
					TTID = TTID + 1;
					core.host:execute ("drawLine", TTID, sdate[period-pos2], low[pos1], sdate[period], low[pos1], col.Next,pattern.styleP,pattern.widthP,stType);
				end
				core.drawLine (pattern.TTB.lb, core.range(period-pos2, period) , low[pos1], period-pos2, low[pos1], period);
				pattern.TTB.s[period] = low[pos1] - BS;
			else
				core.host:execute ("drawLine", TTID+1, sdate[period-pos2], low[pos1], sdate[period], low[pos1], col.Next,pattern.styleP,pattern.widthP,stType);
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- TrendLine Calculation ------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
local dST1_45 = nil;
local uST1_45 = nil;
function proccesTL45()
	local period = open:size() - 1
	if period < 2 or RS < 2 then return; end
	local minVol = RS + 2 ;
	if dST1_45 == nil and uST1_45 == nil then
		if open[period] > close[period] and volume[period] >= minVol and volume[period-1] ~= 0 then
            dST1_45 = period - 1;
			local from = close[dST1_45] + 2*BS;
			local to = from - (period-dST1_45)*BS;
			core.drawLine (TL45.dn, core.range(dST1_45, period) , from, dST1_45, to, period);
        elseif open[period] < close[period] and volume[period] >= minVol and volume[period-1] ~= 0 then
            uST1_45 = period - 1;
			local from = close[uST1_45] - BS;
			local to = from + (period - uST1_45)*BS;
			core.drawLine (TL45.up, core.range(uST1_45, period) , from, uST1_45, to, period);
        end
	elseif dST1_45 ~= nil then
		local from = close[dST1_45] + BS;
		local to = from - (period-dST1_45)*BS;
		if isSmaller(open[period], close[period]) then
			-- Check for new Up Trend
			if isGreater(close[period],to) and isGreaterOrEqual(close[period], close[period-2] + BS) then
				-- Break Bearish TrendLine
				local nsb = period-1;
				local lnsb = nil;
				local i = period;
				while i >= 0 do
					nsb = i - 1;
					if volume[i] >= minVol then
						local ii = i;
						while ii <= period do
							local from = close[nsb] - BS;
							local to = from + (ii-nsb)*BS;
							if instance.parameters.useAdaptive then
								if isSmallerOrEqual(close[ii],to) then
									nsb = nil;
									break;
								end
							else
								if isSmaller(close[ii],to) then
									nsb = nil;
									break;
								end
							end
							ii = ii + 1;
						end
						if nsb == nil then
							break;
						else
							lnsb = nsb;
						end
					end
					i = i - 2;
				end
				if lnsb ~= nil then
					uST1_45 = lnsb;
					local from = close[uST1_45] - BS;
					local to = from + (period - uST1_45)*BS;
					core.drawLine (TL45.up, core.range(uST1_45, period) , from, uST1_45, to, period);
				end 
				TL45.dn:setBreak (period, true);
				dST1_45 = nil;
				return;
			end
		end
		if uST1_45 == nil then
			core.drawLine (TL45.dn, core.range(dST1_45, period) , from, dST1_45, to, period);
			if direction[period] < 0 and instance.parameters.useAdaptive then
				if isGreaterOrEqual(high[period-1],to+BS) then
					dST1_45 = period-1;
				end
			end
		else
			local dfrom = close[uST1_45] + BS;
			local dto = dfrom - (period - uST1_45)*BS;
			core.drawLine (TL45.dn, core.range(dST1_45, period) , from, dST1_45, to, period);
			if isSmaller(to, dto) then
				dST1_45 = nil;
			end
		end
	elseif uST1_45 ~= nil then
		local from = close[uST1_45] - BS;
		local to = from + (period - uST1_45)*BS;
		if open[period] > close[period] then
			-- Check for new DN Trend
			if isSmaller(close[period],to) and isSmallerOrEqual(close[period],close[period-2] - BS) then
				-- Break Bearish TrendLine
				local nsb = period-1;
				local lnsb = nil;
				local i = period;
				while i >= 0 do
					nsb = i - 1;
					if volume[i] >= minVol then
						local ii = i;
						while ii <= period do
							local from = close[nsb] + BS;
							local to = from - (ii-nsb)*BS;
							if instance.parameters.useAdaptive then
								if isGreaterOrEqual(close[ii],to) then --and volume[ii] >= minVol then
									nsb = nil;
									break;
								end
							else
								if isGreater(close[ii],to) then --and volume[ii] >= minVol then
									nsb = nil;
									break;
								end
							end
							ii = ii + 1;
						end
						if nsb == nil then
							break;
						else
							lnsb = nsb;
						end
					end
					i = i - 2;
				end
				if lnsb ~= nil then
					dST1_45 = lnsb;
					local from = close[dST1_45] + BS;
					local to = from - (period - dST1_45)*BS;
					core.drawLine (TL45.dn, core.range(dST1_45, period) , from, dST1_45, to, period);
				end 
				TL45.up:setBreak (period, true);
				uST1_45 = nil;
				return;
			end
		end
		if dST1_45 == nil then
			core.drawLine (TL45.up, core.range(uST1_45, period) , from, uST1_45, to, period);
			if direction[period] > 0  and instance.parameters.useAdaptive then
				if isSmallerOrEqual(low[period-1],to-BS) then
					uST1_45 = period-1;
				end
			end
		else
			local dfrom = close[dST1_45] + BS;
			local dto = dfrom - (period - dST1_45)*BS;
			core.drawLine (TL45.up, core.range(uST1_45, period) , from, uST1_45, to, period);
			if isGreater(to,dto) then
				uST1_45 = nil;
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
local dST1_22 = nil;
local uST1_22 = nil;
function proccesTL22(period)
	local period = open:size() - 1
	if period < 2 or RS < 2 then return; end
	local minVol = RS + 1;
	if dST1_22 == nil and uST1_22 == nil then
		if open[period] > close[period] and volume[period] >= minVol and volume[period-1] ~= 0 then
            dST1_22 = period - 1;
			local from = close[dST1_22] + BS;
			local to = from - (period-dST1_22)*BS/2;
			core.drawLine (TL22.dn, core.range(dST1_22, period) , from, dST1_22, to, period);
        elseif open[period] < close[period] and volume[period] >= minVol and volume[period-1] ~= 0 then
            uST1_22 = period - 1;
			local from = close[uST1_22] - BS;
			local to = from + (period - uST1_22)*BS/2;
			core.drawLine (TL22.up, core.range(uST1_22, period) , from, uST1_22, to, period);
        end
	elseif dST1_22 ~= nil then
		local from = close[dST1_22] + BS;
		local to = from - (period-dST1_22)*BS/2;
		if open[period] < close[period] then
			-- Check for new Up Trend
			if isGreater(close[period] , to) and isGreaterOrEqual(close[period],close[period-2] + BS) then
				-- Break Bearish TrendLine
				local nsb = period-1;
				local lnsb = nil;
				local i = period;
				while i >= 0 do
					nsb = i - 1;
					if volume[i] >= minVol then
						local ii = i;
						while ii <= period do
							local from = close[nsb] - BS;
							local to = from + (ii-nsb)*BS/2;
							if instance.parameters.useAdaptive then
								if isSmallerOrEqual(close[ii],to) then
									nsb = nil;
									break;
								end
							else
								if isSmaller(close[ii],to) then
									nsb = nil;
									break;
								end
							end
							ii = ii + 1;
						end
						if nsb == nil then
							break;
						else
							lnsb = nsb;
						end
					end
					i = i - 2;
				end
				if lnsb ~= nil then
					uST1_22 = lnsb;
					local from = close[uST1_22] - BS;
					local to = from + (period - uST1_22)*BS/2;
					core.drawLine (TL22.up, core.range(uST1_22, period) , from, uST1_22, to, period);
				end 
				TL22.dn:setBreak (period, true);
				dST1_22 = nil;
				return;
			end
		end
		if uST1_22 == nil then
			core.drawLine (TL22.dn, core.range(dST1_22, period) , from, dST1_22, to, period);
			if direction[period] < 0 and instance.parameters.useAdaptive then
				if isGreaterOrEqual(high[period-1],to+BS/2) then
					dST1_22 = period-1;
				end
			end
		else
			local dfrom = close[uST1_22] + BS;
			local dto = dfrom - (period - uST1_22)*BS/2;
			core.drawLine (TL22.dn, core.range(dST1_22, period) , from, dST1_22, to, period);
			if isSmaller(to,dto) then
				dST1_22 = nil;
			end
		end
	elseif uST1_22 ~= nil then
		local from = close[uST1_22] - BS;
		local to = from + (period - uST1_22)*BS/2;
		if open[period] > close[period] then
			-- Check for new Up Trend
			if isSmaller(close[period] , to) and isSmallerOrEqual(close[period] , close[period-2] - BS) then
				-- Break Bearish TrendLine
				local nsb = period-1;
				local lnsb = nil;
				local i = period;
				while i >= 0 do
					nsb = i - 1;
					if volume[i] >= minVol then
						local ii = i;
						while ii <= period do
							local from = close[nsb] + BS;
							local to = from - (ii-nsb)*BS/2;
							if instance.parameters.useAdaptive then
								if isGreaterOrEqual(close[ii],to) then
									nsb = nil;
									break;
								end
							else
								if isGreater(close[ii],to) then
									nsb = nil;
									break;
								end
							end
							ii = ii + 1;
						end
						if nsb == nil then
							break;
						else
							lnsb = nsb;
						end
					end
					i = i - 2;
				end
				if lnsb ~= nil then
					dST1_22 = lnsb;
					local from = close[dST1_22] + BS;
					local to = from - (period - dST1_22)*BS/2;
					core.drawLine (TL22.dn, core.range(dST1_22, period) , from, dST1_22, to, period);
				end 
				TL22.up:setBreak (period, true);
				uST1_22 = nil;
				return;
			end
		end
		if dST1_22 == nil then
			core.drawLine (TL22.up, core.range(uST1_22, period) , from, uST1_22, to, period);
			if direction[period] > 0  and instance.parameters.useAdaptive then
				if isSmallerOrEqual(low[period-1],to-BS/2) then
					uST1_22 = period-1;
				end
			end
		else
			local dfrom = close[dST1_22] + BS;
			local dto = dfrom - (period - dST1_22)*BS/2;
			core.drawLine (TL22.up, core.range(uST1_22, period) , from, uST1_22, to, period);
			if to > dto then
				uST1_22 = nil;
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Nex Month or Day Calculation -----------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
local lastDay = 0;
local lastMonth = 0;
function checkNewMonthOrDay(sourceperiod)
	local current = open:size() - 1;
	tick[current] = history.close[sourceperiod];
	-- New Month or Day
	local tbl  = core.dateToTable(open:date(current));
	local day  = tbl.day;
	local month = tbl.month;
	if lastDay ~= day then
		if lastMonth ~= month then
			if instance.parameters.bMonth then
				newMonth[current] = volume[current] + month*0.01;
			elseif instance.parameters.bDay then
				newDay[current] = volume[current] + day*0.01;
			end
			lastMonth = month;
		elseif instance.parameters.bDay then
			newDay[current] = volume[current] + day*0.01;
		end
		lastDay = day;
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Point and Figure Stream Calculation ----------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
function proccesCandle(period,time,source_high,source_low)
	-- Calculation with more then one Box Reversal Count --
	-------------------------------------------------------
	local current = open:size() - 1;
	if current < 0 then
		instance:addViewBar(time);
		current             = current + 1;
		sdate[current] 		= time;
		open[current]       = round(history.open[period]);
		if source_high > open[current] then
			local z = math.floor((source_high - open[current]) / BS);
			close[current] 	= open[current] + z*BS;
			high[current] 	= close[current];
			low[current] 	= open[current];
			direction[current] = 1;
		elseif 	source_low < open[current] then
			local z = math.floor((open[current] - source_low) / BS);
			close[current] 	= open[current] - z*BS;
			low[current] 	= close[current];
			high[current] 	= open[current];
			direction[current] = -1;
		end
		volume[current]     = math.modf(((math.abs(close[current] - open[current]))/BS)+1.01);
	else
		current = open:size() - 1;
		if direction[current] == 1 then
			local z = math.floor((source_high - open[current]) / BS);
			-- 1. Use the high if new X can be drawn;
			if high[current] < open[current] + z*BS then
				high[current] 		= math.max(high[current],open[current] + z*BS);
				close[current] 		= high[current];
				volume[current]     = math.modf(((math.abs(close[current] - open[current]))/BS)+1.01);
				return;
			end
			-- 2. use the low if no new X can be drawn and the low triggers a reversal;
			z = math.floor((high[current] - source_low) / BS);
			if z >= RS then
				instance:addViewBar(time);
				current = current + 1;
				sdate[current] 		= time;
				direction[current] = -1 ;
				open[current] 	    = high[current-1] - BS;
				high[current] 	    = high[current-1] - BS;
				close[current]     	= high[current-1] - z*BS;
				low[current]		= high[current-1] - z*BS;
				volume[current]     = math.modf(((math.abs(close[current] - open[current]))/BS)+1.01);
				return;
			end
			-- 3. Ignore High and Low;
			return;
		elseif direction[current] == -1 then
			local z = math.floor((open[current] - source_low) / BS);
			-- 1. Use the low if new O can be drawn;
			if low[current] > open[current] - z*BS then
				low[current] 		= math.min(open[current] - z*BS,low[current]);
				close[current] 		= low[current] ;
				volume[current]     = math.modf(((math.abs(close[current] - open[current]))/BS)+1.01);
				return;
			end
			-- 2. use the high if no new O can be drawn and the high triggers a reversal;
			z = math.floor((source_high - low[current]) / BS);
			if z >= RS then
				instance:addViewBar(time);
				current = current + 1;
				sdate[current] 		= time;
				direction[current] = 1;
				open[current] 	    = low[current-1] + BS;
				low[current] 	    = low[current-1] + BS;
				close[current]     	= low[current-1] + z*BS;
				high[current]		= low[current-1] + z*BS;
				volume[current]     = math.modf(((math.abs(close[current] - open[current]))/BS)+1.01);
				return;
			end
			-- 3. Ignore High and Low;
			return;
		end
	end
end
-- Calculation with one Box Reversal Count -- Wyckoff Drawing Method --
-----------------------------------------------------------------------
function proccesWyckoff(period,time,source_high,source_low)
	local current = open:size() - 1;
	if current < 0 then
		instance:addViewBar(time);
		current             = current + 1;
		sdate[current] 		= time;
		open[current]       = round(history.open[period]);
		if source_high > open[current] then
			local z = math.floor((source_high - open[current]) / BS);
			close[current] 	= open[current];
			high[current] 	= open[current] + z*BS;
			low[current] 	= open[current];
			direction[current] = 1;
		elseif 	source_low < open[current] then
			local z = math.floor((open[current] - source_low) / BS);
			close[current] 	= open[current];
			low[current] 	= open[current] - z*BS;
			high[current] 	= open[current];
			direction[current] = -1;
		end
		volume[current]     = math.modf(((math.abs(close[current] - open[current]))/BS)+1.01);
	else
		current = open:size() - 1;
		if direction[current] == 1 then
			local z = math.floor((source_high - open[current]) / BS);
			-- 1. Use the high if new X can be drawn;
			if high[current] < open[current] + z*BS then
				high[current] 		= math.max(high[current],open[current] + z*BS);
				volume[current]     = math.modf(((math.abs(close[current] - open[current]))/BS)+1.01);
				return;
			end
			-- 2. use the low if no new X can be drawn and the low triggers a reversal;
			z = math.floor((high[current] - source_low) / BS);
			if z >= RS then
				if isEqual(high[current],open[current]) and isEqual(open[current],close[current]) then
					direction[current] = -1 ;
					open[current]     	= close[current] - BS;
					low[current]		= high[current] - z*BS;
				else
					instance:addViewBar(time);
					current = current + 1;
					sdate[current] 		= time;
					direction[current] = -1 ;
					close[current] 	    = high[current-1] - BS;
					high[current] 	    = high[current-1] - BS;
					open[current]     	= high[current-1] - BS;
					low[current]		= high[current-1] - z*BS;
					volume[current]     = math.modf(((math.abs(close[current] - open[current]))/BS)+1.01);
				end
				return;
			end
			-- 3. Ignore High and Low;
			return;
		elseif direction[current] == -1 then
			local z = math.floor((open[current] - source_low) / BS);
			-- 1. Use the low if new O can be drawn;
			if low[current] > open[current] - z*BS then
				low[current] 		= math.min(open[current] - z*BS,low[current]);
				--close[current] 		= low[current] ;
				volume[current]     = math.modf(((math.abs(close[current] - open[current]))/BS)+1.01);
				return;
			end
			-- 2. use the high if no new O can be drawn and the high triggers a reversal;
			z = math.floor((source_high - low[current]) / BS);
			if z >= RS then
				if isEqual(low[current],open[current]) and isEqual(open[current],close[current]) then
					direction[current] = 1;
					close[current]     	= open[current] + BS;
					high[current]		= low[current] + z*BS;
				else
					instance:addViewBar(time);
					current = current + 1;
					sdate[current] 		= time;
					direction[current] = 1;
					open[current] 	    = low[current-1] + BS;
					low[current] 	    = low[current-1] + BS;
					close[current]     	= low[current-1] + BS;
					high[current]		= low[current-1] + z*BS;
					volume[current]     = math.modf(((math.abs(close[current] - open[current]))/BS)+1.01);
				end
				return;
			end
			-- 3. Ignore High and Low;
			return;
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function round(price)
    return math.floor(price/BS)*BS;
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Draw Functions - Draw Point and Figure Chart -------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
local init = false;
local FONT 	= 1;
local X_PEN = 2;
local O_PEN = 3;

function Draw(stage, context)
    if stage == 2 and open:size() > 0 then

        if not init then
			context:createPen(X_PEN,            	context.SOLID, 1, col.X);
            context:createPen(O_PEN,          		context.SOLID, 1, col.O);
            init = true;
		end
		t, s, e = context:positionOfBar(0);
		cellW = math.floor(e - s + 0.5) + 2;
		cellH = context:priceWidth((BS),0) + 2;
		local Xw,Xh;
		-- clip the output to the chart area
        context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
        if cellW <= 4 or cellH <= 4 then
            drawUsingLines(context, cellW, cellH);
        else
			if cellW > cellH then
				context:createFont (FONT, instance.parameters.Fonts, 0, cellH, 0);
			else
				context:createFont (FONT, instance.parameters.Fonts, 0, cellW, 0);
			end
			Xw,Xh = context:measureText (FONT, "Q", context.CENTER+context.SINGLELINE);
            drawUsingFont(context, Xw, Xh, cellW-2, cellH-2);
        end
        context:resetClipRectangle();
    end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------
function drawUsingFont(context, Xw, Xh,cellW,cellH)
	local shift = 0;
	context:startEnumeration();
	while true do
		local index, x, x1, x2, c1, c2 = context:nextBar();
		if index == nil then
			break;
		end
		local l = x-Xw/2;
		local r = x+Xw/2;
		local s = Xh/2;
		local last = false;
		if open:isAlive() and index == open:size() - 1 then
			last = true;
		end
		local v = open[index];
		if last then
			if RS < 2 then
				proccesColumnWyckoff(context,index,l,r,s);
			else
				proccesColumn(context,index,l,r,s,x1-x2);
				proccesColumnNext(context,index,l,r,s,x1-x2);
			end
		else
			if index > 1 then
				if RS < 2 then
					proccesColumnWyckoff(context,index,l,r,s);
				else
					proccesColumn(context,index,l,r,s,x1-x2);
				end
			end
		end
		-- TrendLines
		if instance.parameters.tl45 and instance.parameters.useLines == false and isEqual(TL45.up[index],0) == false and isSmaller(TL45.up[index],low[index]) then
			local t1, y1 = context:pointOfPrice(TL45.up[index]);
			context:drawText (1, "+", instance.parameters.TLu45_color, -1, l, y1-s, r, y1 + s, context.CENTER+context.SINGLELINE, 0);
		end
		if instance.parameters.tl45 and instance.parameters.useLines == false and isEqual(TL45.dn[index],0) == false and isGreater(TL45.dn[index],high[index]) then
			local t1, y1 = context:pointOfPrice(TL45.dn[index]);
			context:drawText (1, "+", instance.parameters.TLd45_color, -1, l, y1-s, r, y1 + s, context.CENTER+context.SINGLELINE, 0);
		end
		if TL22.Enable and instance.parameters.useLines == false and isEqual(TL22.up[index],0) == false and isSmaller(TL22.up[index],low[index]) then
			local t1, y1 = context:pointOfPrice(TL22.up[index]);
			context:drawText (1, "+", instance.parameters.TLu22_color, -1, l, y1-s, r, y1 + s, context.CENTER+context.SINGLELINE, 0);
		end
		if TL22.Enable and instance.parameters.useLines == false and isEqual(TL22.dn[index],0) == false and isGreater(TL22.dn[index],high[index]) then
			local t1, y1 = context:pointOfPrice(TL22.dn[index]);
			context:drawText (1, "+", instance.parameters.TLd22_color, -1, l, y1-s, r, y1 + s, context.CENTER+context.SINGLELINE, 0);
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function proccesColumnWyckoff(context,index,l,r,s)
	local o = open[index];
	if isEqual(direction[index],1) then
		if isEqual(open[index],close[index]) then
			for i = high[index] , close[index]-0.01*BS, -BS do
				t, y = context:pointOfPrice(i);
				mVol, mNum = math.modf (newMonth[index]);
				dVol, dNum = math.modf (newDay[index]);
				if newMonth[index] > 0 and isEqual(i ,o + (mVol-1)*BS) then
					context:drawText (1, converToASCII(mNum*100), col.Month, -1, l, y-s, r, y + s, context.CENTER+context.SINGLELINE, 0);
				elseif newDay[index] > 0 and isEqual(i ,o + (dVol-1)*BS) then
					context:drawText (1, converToASCII(dNum*100), col.Day, -1, l, y-s, r, y + s, context.CENTER+context.SINGLELINE, 0);
				else
					context:drawText (1, "X", col.X, -1, l, y-s, r, y + s, context.CENTER+context.SINGLELINE, 0)
				end
			end
		else
			for i = high[index] , close[index]-0.01*BS, -BS do
				t, y = context:pointOfPrice(i);
				mVol, mNum = math.modf (newMonth[index]);
				dVol, dNum = math.modf (newDay[index]);
				if newMonth[index] > 0 and isEqual(i ,o + (mVol-1)*BS) then
					context:drawText (1, converToASCII(mNum*100), col.Month, -1, l, y-s, r, y + s, context.CENTER+context.SINGLELINE, 0);
				elseif newDay[index] > 0 and isEqual(i ,o + (dVol-1)*BS) then
					context:drawText (1, converToASCII(dNum*100), col.Day, -1, l, y-s, r, y + s, context.CENTER+context.SINGLELINE, 0);
				else
					context:drawText (1, "X", col.X, -1, l, y-s, r, y + s, context.CENTER+context.SINGLELINE, 0)
				end
			end
			for i = open[index] , low[index]-0.01*BS, -BS do
				t, y = context:pointOfPrice(i);
				mVol, mNum = math.modf (newMonth[index]);
				dVol, dNum = math.modf (newDay[index]);
				if newMonth[index] > 0 and isEqual(i ,o - (mVol-1)*BS) then
					context:drawText (1, converToASCII(mNum*100), col.Month, -1, l, y-s, r, y + s, context.CENTER+context.SINGLELINE, 0);
				elseif newDay[index] > 0 and isEqual(i ,o - (dVol-1)*BS) then
					context:drawText (1, converToASCII(dNum*100), col.Day, -1, l, y-s, r, y + s, context.CENTER+context.SINGLELINE, 0);
				else
					context:drawText (1, "O", col.O, -1, l, y-s, r, y + s, context.CENTER+context.SINGLELINE, 0);
				end
			end
		end
	elseif isEqual(direction[index],-1) then
		if isEqual(open[index],close[index]) then
			for i = open[index] , low[index]-0.01*BS, -BS do
				t, y = context:pointOfPrice(i);
				mVol, mNum = math.modf (newMonth[index]);
				dVol, dNum = math.modf (newDay[index]);
				if newMonth[index] > 0 and isEqual(i ,o - (mVol-1)*BS) then
					context:drawText (1, converToASCII(mNum*100), col.Month, -1, l, y-s, r, y + s, context.CENTER+context.SINGLELINE, 0);
				elseif newDay[index] > 0 and isEqual(i ,o - (dVol-1)*BS) then
					context:drawText (1, converToASCII(dNum*100), col.Day, -1, l, y-s, r, y + s, context.CENTER+context.SINGLELINE, 0);
				else
					context:drawText (1, "O", col.O, -1, l, y-s, r, y + s, context.CENTER+context.SINGLELINE, 0);
				end
			end
		else
			for i = open[index] , low[index]-0.01*BS, -BS do
				t, y = context:pointOfPrice(i);
				mVol, mNum = math.modf (newMonth[index]);
				dVol, dNum = math.modf (newDay[index]);
				if newMonth[index] > 0 and isEqual(i ,o - (mVol-1)*BS) then
					context:drawText (1, converToASCII(mNum*100), col.Month, -1, l, y-s, r, y + s, context.CENTER+context.SINGLELINE, 0);
				elseif newDay[index] > 0 and isEqual(i ,o - (dVol-1)*BS) then
					context:drawText (1, converToASCII(dNum*100), col.Day, -1, l, y-s, r, y + s, context.CENTER+context.SINGLELINE, 0);
				else
					context:drawText (1, "O", col.O, -1, l, y-s, r, y + s, context.CENTER+context.SINGLELINE, 0);
				end
			end
			for i = high[index] , close[index]-0.01*BS, -BS do
				t, y = context:pointOfPrice(i);
				mVol, mNum = math.modf (newMonth[index]);
				dVol, dNum = math.modf (newDay[index]);
				if newMonth[index] > 0 and isEqual(i ,o + (mVol-1)*BS) then
					context:drawText (1, converToASCII(mNum*100), col.Month, -1, l, y-s, r, y + s, context.CENTER+context.SINGLELINE, 0);
				elseif newDay[index] > 0 and isEqual(i ,o + (dVol-1)*BS) then
					context:drawText (1, converToASCII(dNum*100), col.Day, -1, l, y-s, r, y + s, context.CENTER+context.SINGLELINE, 0);
				else
					context:drawText (1, "X", col.X, -1, l, y-s, r, y + s, context.CENTER+context.SINGLELINE, 0)
				end
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function proccesColumn(context,index,l,r,s,mx)
	local o = open[index];
	for i = high[index] , low[index]-0.1*BS, -BS do
		t, y = context:pointOfPrice(i);
		local txt,color = checkRow(index,i,o);
		context:drawText (FONT, txt, color, -1, l, y-s, r, y + s, context.CENTER+context.SINGLELINE, 0);
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function proccesColumnNext(context,index,l,r,s,mx)
	if EndOfTheDay then
		local rH;
		local rL;
		if Ignore == false then
			rH = history.high[NOW];
			rL = history.low[NOW];
		else
			rH = history.close[NOW];
			rL = history.close[NOW];
		end
		if isEqual(direction[index],1) then
			local z = math.floor((rH - open[index]) / BS);
			-- 1. Use the high if new X can be drawn;
			if isSmaller(high[index],open[index] + z*BS) then
				z = math.floor((rH - close[index]) / BS);
				if z > 0  then
					for i = 1 , z do
						m,y =context:pointOfPrice(close[index] + i*BS);
						context:drawText (1, "X", col.Next, -1, l, y-s, r, y + s, context.CENTER+context.SINGLELINE, 0);
					end
				end
				return;
			end
			-- 2. use the low if no new X can be drawn and the low triggers a reversal;
			z = math.floor((high[index] - rL) / BS);
			if z >= RS then
				z = math.floor((close[index] - rL) / BS);
				if z > 0  then
					for i = 1 , z do
						m,y =context:pointOfPrice(close[index] - i*BS);
						context:drawText (1, "O", col.Next, -1, l-mx, y-s, r-mx, y + s, context.CENTER+context.SINGLELINE, 0);
					end
				end
				return;
			end
		elseif isEqual(direction[index],-1)  then
			local z = math.floor((open[index] - rL) / BS);
			-- 1. Use the low if new O can be drawn;
			if low[index] > open[index] - z*BS then
				z = math.floor((close[index] - rL) / BS);
				if z > 0  then
					for i = 1 , z do
						m,y =context:pointOfPrice(close[index]-i*BS);
						context:drawText (1, "O", col.Next, -1, l, y-s, r, y + s, context.CENTER+context.SINGLELINE, 0);
					end
				end
				return;
			end
			-- 2. use the high if no new O can be drawn and the high triggers a reversal;
			z = math.floor((rH - low[index]) / BS);
			if z >= RS then
				z = math.floor((rH - close[index]) / BS);
				if z > 0  then
					for i = 1 , z do
						m,y =context:pointOfPrice(close[index] + i*BS);
						context:drawText (1, "X", col.Next, -1, l-mx, y-s, r-mx, y + s, context.CENTER+context.SINGLELINE, 0);
					end
				end
				return;
			end
		end
		return;
	else
		if isEqual(direction[index],1) then
			if tick[index] > close[index] then
				local dis = math.abs(math.floor((tick[index]- (close[index]+BS))/point*10)/10);
				local st = "X - [" .. dis .. "]";
				Nw,Nh = context:measureText (1, st, context.CENTER+context.SINGLELINE);
				m,y =context:pointOfPrice(close[index]+BS);
				context:drawText (1, st, col.Next, -1, l, y-s, l+Nw, y + s, context.CENTER+context.SINGLELINE, 0)
			else
				for i = 1 , RS do
					if i == RS then
						local dis = math.abs(math.floor(((close[index]-(i)*BS) - tick[index])/point*10)/10);
						local st = "O - [" .. dis .. "]";
						Nw,Nh = context:measureText (1, st, context.CENTER+context.SINGLELINE);
						m,y =context:pointOfPrice(close[index]-(i)*BS);
						context:drawText (1, st, col.Next, -1, l-mx+1, y-s, l-mx+Nw, y + s, context.CENTER+context.SINGLELINE, 0)
					else
						m,y =context:pointOfPrice(close[index]-(i)*BS);
						context:drawText (1, "O", col.Next, -1, l-mx, y-s, r-mx, y + s, context.CENTER+context.SINGLELINE, 0);
					end
				end
			end
		elseif isEqual(direction[index],-1) then
			if tick[index] < close[index] then
				local dis = math.abs(math.floor(((close[index]-BS)-tick[index])/point*10)/10);
				local st = "O - [" .. dis .. "]";
				Nw,Nh = context:measureText (1, st, context.CENTER+context.SINGLELINE);
				m,y =context:pointOfPrice(close[index]-BS);
				context:drawText (1, st, col.Next, -1, l, y-s,  l + Nw, y + s, context.CENTER+context.SINGLELINE, 0);
			else
				for i = 1, RS do
					if i == RS then
						local dis = math.abs(math.floor((tick[index]-(close[index]+(i)*BS))/point*10)/10);
						local st = "X - [" .. dis .. "]";
						Nw,Nh = context:measureText (1, st, context.CENTER+context.SINGLELINE);
						m,y =context:pointOfPrice(close[index]+(i)*BS);
						context:drawText (1, st, col.Next, -1, l-mx+1, y-s, l-mx+Nw, y + s, context.CENTER+context.SINGLELINE, 0)
					else
						m,y =context:pointOfPrice(close[index]+(i)*BS);
						context:drawText (1, "X", col.Next, -1, l-mx, y-s, r-mx, y + s, context.CENTER+context.SINGLELINE, 0);
					end
				end
			end
		end
		return;
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function drawUsingLines(context, cellW, cellH)
    context:startEnumeration();
    while true do
        local index, x, x1, x2 = context:nextBar();
        if index == nil then
            break;
        end

        local last = false;
        if open:isAlive() and index == open:size() - 1 then
            last = true;
        end

        local t, y, hy, ly;
        t, hy = context:pointOfPrice(high[index]);-- - BS);
        t, ly = context:pointOfPrice(low[index]);
        if last then
            t, y  = context:pointOfPrice(tick[index]);
            if open[index] > close[index] then
                context:drawLine(O_PEN,          x1, hy, x1,  ly);
            else
                context:drawLine(X_PEN,            x1, ly, x1,  hy);
            end
        else
            if open[index] > close[index] then
                context:drawLine(O_PEN, x1, hy, x1, ly);
            else
                context:drawLine(X_PEN,   x1, ly, x1, hy);
            end
        end
    end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function checkRow(index,i,o)
	local mVol, mNum = math.modf (newMonth[index]);
	local dVol, dNum = math.modf (newDay[index]);
	if 	isEqual(pattern.ShakeOut.s[index],i) then 		-- ShakeOut
		if isEqual(direction[index],1) then
			return "S",pattern.cBuy ;
		elseif isEqual(direction[index],-1)  then
			return "S",pattern.cSell;
		end
	end
	if isEqual(pattern.TTB.s[index],i) then				-- Triple
		if isEqual(direction[index],1) then
			return "T",pattern.cBuy ;
		elseif isEqual(direction[index],-1)  then
			return "T",pattern.cSell;
		end
	end
	if isEqual(pattern.Catapult.s[index],i) then 		-- CataPult
		if isEqual(direction[index],1) then
			return "C",pattern.cBuy ;
		elseif isEqual(direction[index],-1)  then
			return "C",pattern.cSell;
		end
	end
	if isEqual(pattern.Triangle.s[index],i) then 		-- Triangle
		if isEqual(direction[index],1) then
			return "A",pattern.cBuy ;
		elseif isEqual(direction[index],-1)  then
			return "A",pattern.cSell;
		end
	end
	if isEqual(pattern.Flag.s[index],i) then 			-- Flag
		if isEqual(direction[index],1) then
			return "F",pattern.cBuy ;
		elseif isEqual(direction[index],-1)  then
			return "F",pattern.cSell;
		end
	end
	--[[if 	isEqual(pattern.TTB.s[index]-BS,i) or isEqual(pattern.TTB.lt[index],i) or
		isEqual(pattern.Catapult.lt1[index],i) or isEqual(pattern.Catapult.lt2[index],i) or isEqual(pattern.Catapult.lt1[index]-BS,i) or 
		isEqual(pattern.Triangle.lt[index],i) then
		if isEqual(direction[index],1) then
			return "X",col.Next;
		elseif isEqual(direction[index],-1)  then
			return "O",col.Next;
		end
	end]]--
	if instance.parameters.useLines == false then
		if instance.parameters.tl45 then
			if isEqual(TL45.dn[index],i) then
				return "+",instance.parameters.TLd45_color;
			elseif isEqual(TL45.up[index],i) then
				return "+",instance.parameters.TLu45_color;
			end
		elseif TL22.Enable then
			if isEqual(TL22.dn[index],i) then
				return "+",instance.parameters.TLd22_color;
			elseif isEqual(TL22.up[index],i) then
				return "+",instance.parameters.TLu22_color;
			end
		end
	end
	if newMonth[index] > 0 and isEqual(i ,o + (mVol-1)*BS) then
		return converToASCII(mNum*100),col.Month;
	elseif newDay[index] > 0 and isEqual(i ,o + (dVol-1)*BS) then
		return converToASCII(dNum*100),col.Day;
	else
		if isEqual(direction[index],1) then
			return "X",col.X;
		elseif isEqual(direction[index],-1)  then
			return "O",col.O;
		end
	end	
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Convert Days and Month to Ascii 10=A 11=B and so on ------------------------------------------------------------------------------------------------
function converToASCII(v)
	if v < 10 then
		return string.char(48 + v);
	else
		return string.char(64 + (v-9));
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- RealNumber Correction ------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
function isEqual(a,b)
	local decimal = 1/(10^(digits+2));
	if (math.abs(a - b) < decimal) then
		return true;
	end
	return false;
end
function isUnEqual(a,b)
	local decimal = 1/(10^(digits+2));
	if (math.abs(a - b) < decimal) then
		return false;
	end
	return true;
end
function isGreater(a,b)
	local decimal = 1/(10^(digits+2));
	if (math.abs(a - b) < decimal) then
		return false;
	elseif a > b then
		return true;
	end
	return false;
end
function isSmaller(a,b)
	local decimal = 1/(10^(digits+2));
	if (math.abs(a - b) < decimal) then
		return false;
	elseif a < b then
		return true;
	end
	return false;
end
function isGreaterOrEqual(a,b)
	local decimal = 1/(10^(digits+2));
	if (math.abs(a - b) < decimal) then
		return true;
	elseif a > b then
		return true;
	end
	return false;
end
function isSmallerOrEqual(a,b)
	local decimal = 1/(10^(digits+2));
	if (math.abs(a - b) < decimal) then
		return true;
	elseif a < b then
		return true;
	end
	return false;
end