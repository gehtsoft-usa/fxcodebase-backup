--[[
	Point and Figure Charting
	Written by Gidien @ 2014
	Overhauled
	
]]--

-- Init Function
function Init()
	local color = core.colors();
    indicator:name("Point & Figure");
    indicator:description("Point and Figure Charting");
    indicator:requiredSource(core.Bar);
    indicator:type(core.View);
	-- Point and Figure price settings
	indicator.parameters:addGroup("Price Parameters");
	indicator.parameters:addString("instrument", "Instrument", "", "GBP/USD");
    indicator.parameters:setFlag("instrument", core.FLAG_INSTRUMENTS);
    indicator.parameters:addBoolean("type", "Bid or Ask", "No description", true);
    indicator.parameters:setFlag("type", core.FLAG_BIDASK);
    indicator.parameters:addString(   "TF", "TF", "Source Time frame ('m1', 'm5', etc.)", "m1");
    indicator.parameters:setFlag(   "TF", core.FLAG_PERIODS);
	indicator.parameters:addDate("from", "Date From", "Load history date from", -30);
	indicator.parameters:addString("method", "Method", "Defines whether fixed BoxSize or ATR","PIP");
	indicator.parameters:addStringAlternative("method", "ATR", "", "ATR");
	indicator.parameters:addStringAlternative("method", "PIP", "", "PIP");
	indicator.parameters:addInteger("PE", "ATR Period", "ATR Period", 14);
	indicator.parameters:addInteger("PP", "ATR Percent %", "ATR Percent %", 33);
	indicator.parameters:addInteger("BS", "Box Size", "Box size (in pips)", 5);
    indicator.parameters:addInteger("RS", "Reversal", "Reversal count (in boxes)", 3);
    indicator.parameters:addBoolean("Ignore", "Ignore High/Low", "Defines whether the calulation use high and low of the source candle", false);
    indicator.parameters:addBoolean("EndOfTheDay", "End of The Day", "If enabled, calculation only at new source candle", true);
    -- Point and Figure Drawing settings
	indicator.parameters:addGroup("Column Style");
	indicator.parameters:addString("RowStyle", "Boxes", "Defines whether rows will XO or Sqares","SQ");
	indicator.parameters:addStringAlternative("RowStyle", "Font", "", "XO");
	indicator.parameters:addStringAlternative("RowStyle", "Square", "", "SQ");
	indicator.parameters:addColor("cX", "X Column", "Color of X Column", core.rgb(0, 128, 255));
	indicator.parameters:addColor("cO", "O Column", "Color of O Column", core.rgb(192, 192, 192) );
	indicator.parameters:addColor("cNext", "Next Rows", "Color of Next Rows",core.rgb(30, 30, 30) );
	indicator.parameters:addBoolean("bDay", "Show Days", "Defines whether new day is shown", false);
	indicator.parameters:addColor("cDay", "Day", "Color of new Day", color.Orange);
	indicator.parameters:addBoolean("bMonth", "Show Months", "Defines whether new month is shown", false);
	indicator.parameters:addColor("cMonth", "Month", "Color of Month", color.Crimson );
	-- 45° Trendlines
	indicator.parameters:addGroup("45 - Trendlines")
    indicator.parameters:addInteger("styleTL_M_45", "Main Trendline Style", "Defines Line Style for Main Trendlines", core.LINE_SOLID);
    indicator.parameters:setFlag("styleTL_M_45", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("styleTL_S_45", "Internal Trendline Style", "Defines Line Style for Internal Trendlines", core.LINE_DOT);
    indicator.parameters:setFlag("styleTL_S_45", core.FLAG_LINE_STYLE);
	indicator.parameters:addString("useConfirm_45", "New Trendline", "Defines whether when new Trendline is drawed","BR");
	indicator.parameters:addStringAlternative("useConfirm_45", "At breakout", "", "BR");
	indicator.parameters:addStringAlternative("useConfirm_45", "At breakout with Adaption", "", "AD");
	indicator.parameters:addStringAlternative("useConfirm_45", "At breakout with Confirmation", "", "CO");
	--indicator.parameters:addBoolean("useConfirm_45", "Confirmation", "Confirmation Trendline break with next high/low below/above the trendline", false);
    indicator.parameters:addColor("TLu45_color", "45 Bullish Support Line", "Color of 45° Bullish Support Line", core.rgb(0, 128, 128));
    indicator.parameters:addColor("TLd45_color", "45 Bearish Resistance Line", "Color of 45° Bearish Resistance Line", core.rgb(255, 128, 128));
	indicator.parameters:addInteger("widthTL_M_45", "Main Trendline Width", "", 2, 1, 5);
	indicator.parameters:addInteger("widthTL_S_45", "Secondary Trendline Width", "", 1, 1, 5);
	-- 22.5° Trendlines
	indicator.parameters:addGroup("22.5 - Trendlines")
    indicator.parameters:addInteger("styleTL_M_22", "Main Trendline Style", "Defines Line Style for Main Trendlines", core.LINE_NONE);
    indicator.parameters:setFlag("styleTL_M_22", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("styleTL_S_22", "Internal Trendline Style", "Defines Line Style for Internal Trendlines", core.LINE_NONE);
    indicator.parameters:setFlag("styleTL_S_22", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addString("useConfirm_2", "New Trendline", "Defines whether when new Trendline is drawed","BR");
	--indicator.parameters:addString("useConfirm_22", "Calculation", "Defines whether when new Trendline is drawed", "BR");
	indicator.parameters:addStringAlternative("useConfirm_2", "At breakout", "", "BR");
	indicator.parameters:addStringAlternative("useConfirm_2", "At breakout with Adaption", "", "AD");
	indicator.parameters:addStringAlternative("useConfirm_2", "At breakout with Confirmation", "", "CO");
	indicator.parameters:addColor("TLu22_color", "22.5 Bullish Support Line", "Color of 22.5 Bullish Support Line", core.rgb(128, 255, 255));
    indicator.parameters:addColor("TLd22_color", "22.5 Bearish Resistance Line", "Color of 22.5 Bearish Resistance Line", core.rgb(255, 255, 128));
	indicator.parameters:addInteger("widthTL_M_22", "Main Trendline Width", "", 2, 1, 5);
	indicator.parameters:addInteger("widthTL_S_22", "Secondary Trendline Width", "", 1, 1, 5);
	
	indicator.parameters:addGroup("Pattern");
	indicator.parameters:addBoolean("enDTB", "Double Top and Bottom", "Enable Double Top or Bottom", true);
	indicator.parameters:addBoolean("enTTB", "Triple Top and Bottom", "Enable Triple Top or Bottom", true);
	indicator.parameters:addBoolean("enShakeOut", "ShakeOut", "Enable Bull or Bear ShakeOut", true);
	indicator.parameters:addBoolean("enCatapult", "Catapult", "Enable Bull or Bear Catapult", true);
	indicator.parameters:addBoolean("enTriangle", "Symmetrical Triangle", "Enable Bull or Bear Triangle", true);
	indicator.parameters:addBoolean("enFlag", "Flag", "Enable Bull or Bear Signal Reversed", true);
	
	indicator.parameters:addGroup("Horizontal Targets");
	indicator.parameters:addBoolean("Horizontal", 	"Show Horizontal Count", "Show Horizontal Count" ,  true);
	indicator.parameters:addDouble("tHMinRatio", "Horizontal Count min Ratio", "min 0.1 max 100", 0.3, 0.1, 100);
	indicator.parameters:addColor("cHup", "Color of Horizontal UpSide Target", "", 	core.rgb(0,255,64) );
	indicator.parameters:addColor("cHdn", "Color of Horizontal DownSide Target", "", 	core.rgb(255,0,255) );
	indicator.parameters:addColor("cHf", "Color of Horizontal Failed Target", "", 	core.rgb(30,30,30) );
	indicator.parameters:addGroup("Vertical Targets");
	indicator.parameters:addBoolean("Vertical", 	"Show Vertical Count", "Show Vertical Count" ,  true);
	indicator.parameters:addInteger("vQR", "Maximum Qualifying Range", "", 2, 0, 100);
	indicator.parameters:addColor("cVup", "Color of Vertical UpSide Target", "", 	core.rgb(0,64,64) );
	indicator.parameters:addColor("cVdn", "Color of Vertical DownSide Target", "", 	core.rgb(64,0,128) );
	
	indicator.parameters:addGroup("Signals Style");
	indicator.parameters:addColor("cB", "Buy", "Color of Buy Signal", color.Lime);
	indicator.parameters:addColor("cS", "Sell", "Color of Sell Signal", color.Red);
	
	indicator.parameters:addGroup("Alerts");
	indicator.parameters:addString("Magic", "Magic String", "No description", "MyID");
    indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
end

local instrument;
local TF;
local BS;
local RS;
local Ignore;
local EndOfTheDay;
local frame;
local bid;
local method;
local PP, PE;
local ATR;

-- Streams block
local open = nil;
local high = nil;
local low = nil;
local close = nil;
local volume = nil;
local newMonth;
local first;
local OneSecond;
local TimerID;
	
-- Variables
local lastSerial;
local lastClose = 0;
local offer;
local digits;
local point;
local loading;
local history;
local his={high,low,open,close,volume};
-- Colors
local colors = {X,O,D,M,N,Tup45,Tdn45,Tup22,Tdn22};
local nDay = {};
local nMon = {};
-- Lines
local line = {TL={w,l}}
-- Trendlines
local TL = {};
-- Pattern;
local PA = {};
-- Targets
local TA = {};

-- Routine
function Prepare(nameOnly)
	local name;
	instrument 		= instance.parameters.instrument;
    BS 				= instance.parameters.BS;
    RS 				= instance.parameters.RS;
    Ignore 			= instance.parameters.Ignore;
    EndOfTheDay 	= instance.parameters.EndOfTheDay;
    bid 			= instance.parameters.type;
	frame 			= instance.parameters.TF;
	method			= instance.parameters.method;
	PE				= instance.parameters.PE;
	PP 				= instance.parameters.PP/100;
	
	-- Colors
	colors.X 		= instance.parameters.cX;
	colors.O 		= instance.parameters.cO;
	colors.D 		= instance.parameters.cDay;
	colors.M 		= instance.parameters.cMonth;
	colors.N 		= instance.parameters.cNext;
	colors.Tup45	= instance.parameters.TLu45_color;
	colors.Tdn45	= instance.parameters.TLd45_color;
	colors.Tup22	= instance.parameters.TLu22_color;
	colors.Tdn22	= instance.parameters.TLd22_color;
	colors.B		= instance.parameters.cB;
	colors.S		= instance.parameters.cS;
	colors.THup		= instance.parameters.cHup;
	colors.THdn		= instance.parameters.cHdn;
	colors.THfa		= instance.parameters.cHf;
	-- lines
	line.TL.w_M_45	= instance.parameters.widthTL_M_45;
	line.TL.w_S_45	= instance.parameters.widthTL_S_45;
	line.TL.s_M_45	= instance.parameters.styleTL_M_45;
	line.TL.s_S_45	= instance.parameters.styleTL_S_45;
	
	line.TL.w_M_22	= instance.parameters.widthTL_M_22;
	line.TL.w_S_22	= instance.parameters.widthTL_S_22;
	line.TL.s_M_22	= instance.parameters.styleTL_M_22;
	line.TL.s_S_22	= instance.parameters.styleTL_S_22;
	
	name    		=  profile:id() .. "(" .. instrument .."." .. frame .. "," .. BS .."," ..RS..")";
    instance:name(name);
    if nameOnly then
        return;
    end
    -- check whether the instrument is available
    local offers 	= core.host:findTable("offers");
    local enum		= offers:enumerator();
    local row;
 
    row = enum:next();
    while row ~= nil do
        if row.Instrument == instrument then
            break;
        end
        row = enum:next();
    end
    assert(row ~= nil, "Instrument is not found");

    offer 			= row.OfferID;
    digits 			= row.Digits;
    point 			= row.PointSize
	BS 				= BS;
    instance:initView(instrument, digits, point, bid, true);
	
	if method == "ATR" then
		loading 	= true;
		historyD1 	= core.host:execute("getHistory", 999, instrument, "D1", instance.parameters.from, 0, bid);
		ATR			= core.indicators:create ("ATR", historyD1, PE);
		core.host:execute("setStatus", "ATR Loading History");
		BS = "ATR";
	elseif method == "PIP" then
		loading 	= true;
		history 	= core.host:execute("getHistory", 1000, instrument, frame, math.floor(instance.parameters.from), 0, bid);
		core.host:execute("setStatus", "Loading History");
		BS = BS*point;
	end

    open 			= instance:addStream("open", core.Line, name .. ".open", "open", 0,0,0);
    high 			= instance:addStream("high", core.Line, name .. ".high", "high", 0,0,0);
    low 			= instance:addStream("low", core.Line, name .. ".low", "low", 0,0,0);
    close 			= instance:addStream("close", core.Line, name .. ".close", "close", 0,0,0);
    volume 			= instance:addInternalStream(0, 0);
	tvolume 		= instance:addStream("tvolume", core.Line, name .. ".tvolume", "tvolume", 0,0,0);
	sdate 			= instance:addInternalStream(0, 0);
	direction		= instance:addInternalStream(0, 0);
	
    instance:createCandleGroup("pf,"..BS..","..RS, "pf", open, high, low, close, tvolume, "PF", false);

    open:setVisible(false);
	high:setVisible(false);
    low:setVisible(false);
    close:setVisible(false);
	volume:setVisible(false);
    instance:ownerDrawn(true);
	OneSecond		= 1/86400;
	
	-- Trendlines
	TL[45] = {	up={},dn={},Trend=0,lastTrendLine=nil,Confirm=instance.parameters.useConfirm_45,Long={},Short={},
				upOut=instance:addInternalStream(0, 0),
				dnOut=instance:addInternalStream(0, 0),
				On=instance.parameters.styleTL_M_45 ~= core.LINE_NONE or instance.parameters.styleTL_S_45 ~= core.LINE_NONE};
	TL[22] = {	up={},dn={},Trend=0,lastTrendLine=nil,Confirm=instance.parameters.useConfirm_2,Long={},Short={},
				upOut=instance:addInternalStream(0, 0),
				dnOut=instance:addInternalStream(0, 0),
				On=instance.parameters.styleTL_M_22 ~= core.LINE_NONE or instance.parameters.styleTL_S_22 ~= core.LINE_NONE};
	-- Pattern
	PA["SBS"] 		= {}
	PA["TTB"] 		= {}
	PA["DTB"] 		= {}
	PA["SHA"] 		= {}
	PA["CAT"] 		= {}
	PA["TRI"] 		= {}
	PA["FLA"] 		= {}
	-- Targets
	TA["H"]			= {};
	TA["H_SUM"]		= 0;
	TA["V"]			= {};
	TA["V_SUM"]		= 0;
end
function ReleaseInstance()
	core.host:execute("removeAll");
	core.host:execute("unsubscribeTradeEvents", "offers");
end
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    --- NOT USED in VIEW Indicator
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Vertical Calculation -----------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
function VerifyVTargets()
	local period = open:size() - 1;
	for pos,val in pairs(TA["V"]) do 
		if val.f == 0 then
			for i = val.p +1, period do
				if val.d == "UP" then
					-- Check Activation
					if high[period] >= val.e and val.a == false and val.sl == false then
						TA["V"][pos].a = true;
						TA["V"][pos].p2=period;
						break;
					end
					if low[period] <= val.s and val.sl == false then
						if val.a == false then
							table.remove(TA["V"],pos);
						else
							TA["V"][pos].f = -1;
							TA["V_SUM"] = TA["V_SUM"] + ((val.s-val.e)/point)
							TA["V"][pos].sl = true;
							break;
						end
					elseif high[period] >= val.t then
						TA["V"][pos].f = 1;
						TA["V_SUM"] = TA["V_SUM"] + ((val.t-val.e)/point)
						break;
					end
				elseif val.d == "DN" then
					-- Check Activation
					if low[period] <= val.e and val.a == false and val.sl == false then
						TA["V"][pos].a = true;
						TA["V"][pos].p2=period;
						break;
					end
					if high[period] >= val.s and val.sl == false then
						if val.a == false then
							table.remove(TA["V"],pos);
						else
							TA["V"][pos].f = -1;
							TA["V_SUM"] = TA["V_SUM"] + ((val.e-val.s)/point)
							TA["V"][pos].sl = true;
							break;
						end
					elseif low[period] <= val.t then
						TA["V"][pos].f = 1;
						TA["V_SUM"] = TA["V_SUM"] + ((val.e-val.t)/point)
						break;
					end
				end
			end
		end
	end
end
local lastVTarget = 0;
function VerticalCount()
	local period = open:size() - 1;
	if instance.parameters.Vertical == false then return; end
	local QR = instance.parameters.vQR;
	if lastVTarget ~= period and period > 7 + QR then
		-- X Column ------------------
		if direction[period] > 0 then-- and (TL[45].lastTrendLine~= nil and TL[45].lastTrendLine.sPoint >= period-4) then  --TL[45].Trend > 0 then
			-- Find Top
			if 	close[period - 2 - QR] ~= 0 and isGreaterOrEqual(close[period-2],close[period-4]) and isGreaterOrEqual(close[period-2] , close[period-6]) and
				isGreater(close[period-2] , close[period-8]) then
				local max1,maxpos1 = mathex.max(close,period-2 - QR + 1 , period);
				if maxpos1 == period - 2 or maxpos1 == period - 4 then
					local t = close[period-2] - volume[period-1]*BS*RS;
					local s = close[period-2] - BS;
					local e = close[period-1] - BS;
					local tbl = {t=t,e=e,s=s,d="DN",p=period-1,p2=period-1,a=false,sl = false,f=0};
					table.insert(TA["V"],tbl);
				end
			end
		-- O Column ------------------
		elseif direction[period] < 0  then --and (TL[45].lastTrendLine~= nil and TL[45].lastTrendLine.sPoint >= period-4) then  --TL[45].Trend < 0 then 
			-- Find Bottom
			if 	close[period - 2 - QR] ~= 0 and isSmallerOrEqual(close[period-2], close[period-4]) and isSmallerOrEqual(close[period-2], close[period-6]) and 
				isSmaller(close[period-2], close[period-8]) then
				local min1,minpos1 = mathex.min(close,period-2 - QR + 1 , period);
				if minpos1 == period - 2 or maxpos1 == period - 4 then
					local t = close[period-2] + volume[period-1]*BS*RS;
					local s = close[period-2] + BS;
					local e = close[period-1] + BS;
					local tbl = {t=t,e=e,s=s,d="UP",p=period-1,p2=period-1,a=false,sl = false,f=0};
					table.insert(TA["V"],tbl);
				end
			end
		end			
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Horizontal Calculation -----------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
function VerifyHTargets()
	local period = open:size() - 1;
	for pos,val in pairs(TA["H"]) do 
		if isEqual(val.f,0) then
			for i = val.p , period do
				if val.d == "UP" then
					if isGreaterOrEqual(high[i], val.t) then
						TA["H"][pos].f = 1
						TA["H_SUM"] = TA["H_SUM"] + ((val.t-val.e)/point)
						break;
					elseif isSmallerOrEqual(low[i],val.s) then
						TA["H"][pos].f = -1
						TA["H_SUM"] = TA["H_SUM"] + ((val.s-val.e)/point)
						break;
					end
				elseif val.d == "DN" then
					if isSmallerOrEqual(low[i], val.t) then
						TA["H"][pos].f = 1
						TA["H_SUM"] = TA["H_SUM"] + ((val.e-val.t)/point)
						break;
					elseif isGreaterOrEqual(high[i],val.s) then
						TA["H"][pos].f = -1
						TA["H_SUM"] = TA["H_SUM"] + ((val.e-val.s)/point)
						break;
					end
				end
			end
		end
	end
end
local lastHTarget = 0;
function HorizontalCount(entry)
	local period = open:size() - 1;
	if instance.parameters.Horizontal == false then return; end
	if lastHTarget ~= period and period > 7 then
		local i = 0;
		local t = 0;
		local h = high[period-1];
		local l = low[period-1];
		local pos = 0;
		for i = 0, open:size() -1  do
			if direction[period] > 0 then
				if isGreater(low[period-i],l) then
					l = low[period-i];
				end
				if isSmaller(high[period-i],h) and i > 0 then
					h = high[period-i];
				end
			elseif direction[period] < 0 then
				if isSmaller(high[period-i],h) then
					h = high[period-i];
				end
				if isGreater(low[period-i],l) and i > 0 then
					l = low[period-i];
				end
			end
			
			if isSmaller(high[period-i],l) or isGreater(low[period-i],h) then
				t = i*BS*RS-BS;
				pos = i-1;
				if direction[period] > 0 then
					t = mathex.min(low, period - i + 1, period) + t;
					if  t > high[period] then
						local risk = (t-entry) / (entry-(mathex.min(low, period - i + 1, period)-BS));
						if risk < instance.parameters.tHMinRatio then break; end
						local tbl = {t=t,e=entry,s=mathex.min(low, period - i + 1, period)-BS,r=risk,d="UP",p=period,p2=period-pos,f=0};
						table.insert(TA["H"],tbl);
						lastHTarget = period 
					end
				elseif direction[period] < 0 then
					t = mathex.max(high, period - i + 1, period) - t;
					if  t < low[period] then
						local risk = (entry-t) / ((mathex.max(high, period - i + 1, period)+BS)-entry);
						if risk < instance.parameters.tHMinRatio then break; end
						local tbl = {t=t,e=entry,s=mathex.max(high, period - i + 1, period)+BS,r=risk,d="DN",p=period,p2=period-pos,f=0};
						table.insert(TA["H"],tbl);
						lastHTarget = period 
					end
				end
				break;
			end
		end
	end	
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Pattern Calculation --------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
function cleanPatternTable()
	local period = open:size() - 1;
	if period < 2 then 
		return false; 
	end
	period = period - 1;
	if PA["SBS"][period] ~= nil and PA["SBS"][period].fin == false then
		table.remove(PA["SBS"],period);
	end
	if PA["DTB"][period] ~= nil and PA["DTB"][period].fin == false then
		table.remove(PA["DTB"],period);
	end
	if PA["TTB"][period] ~= nil and PA["TTB"][period].fin == false then
		table.remove(PA["TTB"],period);
	end
	if PA["TRI"][period] ~= nil and PA["TRI"][period].fin == false then
		table.remove(PA["TRI"],period);
	end
	if PA["CAT"][period] ~= nil and PA["CAT"][period].fin == false then
		table.remove(PA["CAT"],period);
	end
	if PA["SHA"][period] ~= nil and PA["SHA"][period].fin == false then
		table.remove(PA["SHA"],period);
	end
	if PA["FLA"][period] ~= nil and PA["FLA"][period].fin == false then
		table.remove(PA["FLA"],period);
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function findSimpleBS()
	local period = open:size() - 1;
	if period < 2 then 
		return false; 
	end
	if PA["SBS"][period] ~= nil then
		if PA["SBS"][period].fin then return true; end
	end
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Bullish ---------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	if isEqual(direction[period],1) then
		if isGreaterOrEqual(high[period],high[period-2]+BS)then
			local tbl = {entry=high[period-2] + BS,fin=true,sPoint=period-2,ePoint=period,type="Simple Bull"};
			PA["SBS"][period] = tbl;
		else
			local tbl = {entry=high[period-2] + BS,fin=false,sPoint=period-2,ePoint=period,type="Simple Bull"};
			PA["SBS"][period] = tbl;
		end
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Bearish ---------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	elseif isEqual(direction[period],-1) then
		if isSmallerOrEqual(low[period],low[period-2]-BS) then
			local tbl = {entry=low[period-2] - BS,fin=true,sPoint=period-2,ePoint=period,type="Simple Bear"};
			PA["SBS"][period] = tbl;
		else
			local tbl = {entry=low[period-2] - BS,fin=false,sPoint=period-2,ePoint=period,type="Simple Bear"};
			PA["SBS"][period] = tbl;
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function findTripleTB()
	local period = open:size() - 1;
	if period < 16 then 
		return false; 
	end
	if PA["TTB"][period] ~= nil then
		if PA["TTB"][period].fin then return true; end
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
				local tbl = {entry=high[pos1] + BS,fin=true,sPoint=period-pos2,ePoint=period,type=stType};
				PA["TTB"][period] = tbl;
				if instance.parameters.enTTB then 
					HorizontalCount(high[pos1] + BS); 
					SendAlert(stType,PA["TTB"][period].entry);
				end
				return true;
			elseif isGreater(low[period-1],low[period-3]) then
				local tbl = {entry=high[pos1] + BS,fin=false,sPoint=period-pos2,ePoint=period,type=stType};
				PA["TTB"][period] = tbl;
				return false;
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
				local tbl = {entry=low[pos1] - BS,fin=true,sPoint=period-pos2,ePoint=period,type=stType};
				PA["TTB"][period] = tbl;
				if instance.parameters.enTTB then 
					HorizontalCount(low[pos1] - BS); 
					SendAlert(stType,PA["TTB"][period].entry);
				end
				return true;
			elseif isSmaller(high[period-1],high[period-3]) then
				local tbl = {entry=low[pos1] - BS,fin=false,sPoint=period-pos2,ePoint=period,type=stType};
				PA["TTB"][period] = tbl;
				return false;
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function findDoubleTB()
	local period = open:size() - 1;
	if period < 2 then 
		return false; 
	end
	if PA["DTB"][period] ~= nil then
		if PA["DTB"][period].fin then return true; end
	end
	if PA["SBS"][period] ~= nil then
		if isEqual(direction[period],1) then
			-- Bullish --------------
			if isGreaterOrEqual(low[period-1],low[period-3]) then
				local tbl = {entry=PA["SBS"][period].entry,fin=PA["SBS"][period].fin,sPoint=period-2,ePoint=period,type="Double Top"};
				PA["DTB"][period] = tbl;
				if instance.parameters.enDTB and PA["DTB"][period].fin then 
					HorizontalCount(PA["DTB"][period].entry); 
					SendAlert("Double Top",PA["DTB"][period].entry);
				end
			end
		elseif isEqual(direction[period],-1) then
			-- Bearish --------------
			if isSmallerOrEqual(high[period-1],high[period-3]) then
				local tbl = {entry=PA["SBS"][period].entry,fin=PA["SBS"][period].fin,sPoint=period-2,ePoint=period,type="Double Bottom"};
				PA["DTB"][period] = tbl;
				if instance.parameters.enDTB and PA["DTB"][period].fin then 
					HorizontalCount(PA["DTB"][period].entry); 
					SendAlert("Double Bottom",PA["DTB"][period].entry);
				end
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function findShakeOut()
	local period = open:size() - 1;
	if period < 4 then 
		return; 
	end
	if instance.parameters.enShakeOut == false then
		return false;
	end
	if PA["SHA"][period] ~= nil then
		if PA["SHA"][period].fin then return true; end
	end
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Bullish ---------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	if direction[period] == 1 and TL[45].upOut[period] ~= nil and TL[45].upOut[period] ~= 0 then
		if isGreaterOrEqual(volume[period],3) and isEqual(high[period-4],high[period-2]) and isGreaterOrEqual(volume[period-3],volume[period-1]-3) and
			isSmaller(volume[period-3],volume[period-1]) then --and isUnEqual(TL[45].up[period],0) then
			local tbl = {entry=open[period] + (RS-1)*BS,fin=true,sPoint=period-4,ePoint=period,type="Bullish Shakeout"};
			PA["SHA"][period] = tbl;
			HorizontalCount(open[period] + (RS-1)*BS)
			SendAlert("Bullish Shakeout",PA["SHA"][period].entry);
		elseif isEqual(low[period-3],low[period-1]) and isGreaterOrEqual(volume[period-2],volume[period]-3) and
			isSmaller(volume[period-2],volume[period]) then --and isUnEqual(TL[45].dn[period],0) then
			local tbl = {entry=high[period] - BS - (RS-1)*BS,fin=false,sPoint=period-3,ePoint=period,type="Bullish Shakeout"};
			PA["SHA"][period] = tbl;
		end
	elseif direction[period] == -1 and TL[45].dnOut[period] ~= nil and TL[45].dnOut[period] ~= 0 then
		if isGreaterOrEqual(volume[period],3) and isEqual(low[period-4],low[period-2]) and isGreaterOrEqual(volume[period-3],volume[period-1]-3) and
			isSmaller(volume[period-3],volume[period-1]) then --and isUnEqual(TL[45].dn[period],0) then
			local tbl = {entry=open[period] - (RS-1)*BS,fin=true,sPoint=period-4,ePoint=period,type="Bearish Shakeout"};
			PA["SHA"][period] = tbl;
			HorizontalCount(open[period] - (RS-1)*BS)
			SendAlert("Bearish Shakeout",PA["SHA"][period].entry);
		elseif isEqual(high[period-3],high[period-1]) and isGreaterOrEqual(volume[period-2],volume[period]-3) and
			isSmaller(volume[period-2],volume[period]) then --and isUnEqual(TL[45].up[period],0) then
			local tbl = {entry=low[period] + BS + (RS-1)*BS,fin=false,sPoint=period-3,ePoint=period,type="Bearish Shakeout"};
			PA["SHA"][period] = tbl;
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function findCatapult()
	local period = open:size() - 1;
	if period < 2 then 
		return; 
	end
	if instance.parameters.enCatapult == false then
		return false;
	end
	if PA["CAT"][period] ~= nil then
		if PA["CAT"][period].fin then return true; end
	end
	if PA["SBS"][period] ~= nil and PA["TTB"][period-2] ~= nil and PA["TTB"][period-2].fin then
		if isEqual(direction[period],1) then
			-- Bullish --------------
			local tbl = {entry=PA["SBS"][period].entry,fin=PA["SBS"][period].fin,sPoint=PA["TTB"][period-2].sPoint,ePoint=period,type="Bull Catapult"};
			PA["CAT"][period] = tbl;
			if PA["CAT"][period].fin then 
				HorizontalCount(PA["CAT"][period].entry); 
				SendAlert("Bull Catapult",PA["CAT"][period].entry);
			end
			return;
		elseif isEqual(direction[period],-1) then
			-- Bearish --------------
			local tbl = {entry=PA["SBS"][period].entry,fin=PA["SBS"][period].fin,sPoint=PA["TTB"][period-2].sPoint,ePoint=period,type="Bear Catapult"};
			PA["CAT"][period] = tbl;
			if PA["CAT"][period].fin then 
				HorizontalCount(PA["CAT"][period].entry); 
				SendAlert("Bear Catapult",PA["CAT"][period].entry);
			end
			return;
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function findTriangle()
	local period = open:size() - 1;
	if period < 5 then 
		return false; 
	end
	if instance.parameters.enTriangle == false then
		return false;
	end
	if PA["TRI"][period] ~= nil then
		if PA["TRI"][period].fin then return true; end
	end
	if PA["SBS"][period] ~= nil then
		if isEqual(direction[period],1) then
			-- Bullish --------------
			if 	(isEqual(high[period-4]-high[period-2],low[period-1]-low[period-3])) and isGreater(high[period-4]-high[period-2],0) then
				local tbl = {entry=PA["SBS"][period].entry,fin=PA["SBS"][period].fin,sPoint=period-2,ePoint=period,type="Bullish Breakout of a Symmetrical Triangle"};
				PA["TRI"][period] = tbl;
				if instance.parameters.enTriangle and PA["TRI"][period].fin then 
					HorizontalCount(PA["TRI"][period].entry); 
					SendAlert("Bullish Breakout of a Symmetrical Triangle",PA["TRI"][period].entry);
				end
			end
		elseif isEqual(direction[period],-1) then
			-- Bearish --------------
			if 	(isEqual(low[period-2]-low[period-4],high[period-3]-high[period-1])) and isGreater(low[period-2]-low[period-4],0) then
				local tbl = {entry=PA["SBS"][period].entry,fin=PA["SBS"][period].fin,sPoint=period-2,ePoint=period,type="Bullish Breakout of a Symmetrical Triangle"};
				PA["TRI"][period] = tbl;
				if instance.parameters.enTriangle and PA["TRI"][period].fin then 
					HorizontalCount(PA["TRI"][period].entry); 
					SendAlert("Bearish Breakout of a Symmetrical Triangle",PA["TRI"][period].entry);
				end
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function findFlag()
	local period = open:size() - 1;
	if period < 5 then 
		return false; 
	end
	if instance.parameters.enFlag == false then
		return false;
	end
	if PA["FLA"][period] ~= nil then
		if PA["FLA"][period].fin then return true; end
	end
	if PA["SBS"][period] ~= nil then
		if isEqual(direction[period],1) then
			-- Bullish --------------
			if 	(isEqual(high[period-4]-high[period-2],low[period-3]-low[period-1])) and isGreater(high[period-4]-high[period-2],0) then
				local tbl = {entry=PA["SBS"][period].entry,fin=PA["SBS"][period].fin,sPoint=period-4,ePoint=period,type="Flag"};
				PA["FLA"][period] = tbl;
				if PA["FLA"][period].fin then 
					HorizontalCount(PA["FLA"][period].entry); 
					SendAlert("Flag",PA["FLA"][period].entry);
				end
			end
			if 	(isEqual(low[period-1]-low[period-3],high[period-2]-high[period-4])) and isGreater(low[period-1]-low[period-3],0) then
				--local tbl = {entry=PA["SBS"][period].entry,fin=PA["SBS"][period].fin,sPoint=period-4,ePoint=period,type="Inverted Flag continuation"};
				--PA["FLA"][period] = tbl;
				--if PA["FLA"][period].fin then HorizontalCount(PA["FLA"][period].entry); end
			end
		elseif isEqual(direction[period],-1) then
			-- Bearish --------------
			if 	(isEqual(low[period-2]-low[period-4],high[period-1]-high[period-3])) and isGreater(low[period-2]-low[period-4],0) then
				local tbl = {entry=PA["SBS"][period].entry,fin=PA["SBS"][period].fin,sPoint=period-4,ePoint=period,type="Inverted Flag"};
				PA["FLA"][period] = tbl;
				if PA["FLA"][period].fin then 
					HorizontalCount(PA["FLA"][period].entry); 
					SendAlert("Inverted Flag",PA["FLA"][period].entry);
				end
			end
			if 	(isEqual(high[period-1]-high[period-3],low[period-4]-low[period-2])) and isGreater(high[period-1]-high[period-3],0) then
				--local tbl = {entry=PA["SBS"][period].entry,fin=PA["SBS"][period].fin,sPoint=period-4,ePoint=period,type="Inverted Flag"};
				--PA["FLA"][period] = tbl;
				--if PA["FLA"][period].fin then HorizontalCount(PA["FLA"][period].entry); end
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function findPattern()
	cleanPatternTable();
	findSimpleBS();
	findDoubleTB();
	findTripleTB();
	findTriangle();
	findCatapult();
	findShakeOut();
	findFlag();
end

-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- TrendLine Calculation ------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
function findTrendLine(type)
	local period = open:size() - 1
	if period < 3 or RS < 3 then return; end
	local minVol = nil;
	if type == 45 then
		minVol = RS + 2 ;
	elseif type == 22 then
		minVol = RS + 1 ;
	end
	if minVol == nil then return; end
	if 	isGreater(open[period],close[period]) and isGreaterOrEqual(volume[period],minVol) and volume[period-1] ~= 0 and TL[type].dn[period-1] == nil then
		-- Bearish resistance Line
		local canAdd = true;
		if TL[type].Trend < 0 then
			if TL[type].lastTrendLine ~= nil then
				local move = nil;
				local id = nil;
				if type == 45 then
					move = BS;
				else
					move = BS/2;
				end
				local adapt = TL[type].lastTrendLine.ad*move;
				local fromLevelMain = close[TL[type].lastTrendLine.sPoint] + BS + adapt;
				local toLevelMain = fromLevelMain - ((period-1)-TL[type].lastTrendLine.sPoint)*move;
				local fromLevel = close[period-1] + BS;
				if isGreaterOrEqual(fromLevel,toLevelMain) then
					canAdd = false;
				end
			end
		end
		if canAdd then
			local tbl = {broken = false,sPoint=period-1,ePoint=period,confirmed = false,isMain=false,ad=0}
			TL[type].dn[period-1] = tbl;
			if TL[type].lastTrendLine == nil then TL[type].lastTrendLine = tbl; TL[type].dn[period-1].isMain = true end
			if TL[type].Trend == 0 then TL[type].Trend = -1 end
		end
	elseif 	isSmaller(open[period],close[period]) and isGreaterOrEqual(volume[period],minVol) and volume[period-1] ~= 0 and TL[type].up[period-1] == nil then
		local canAdd = true;
		if TL[type].Trend > 0 then
			if TL[type].lastTrendLine ~= nil then
				local move = nil;
				local id = nil;
				if type == 45 then
					move = BS;
				else
					move = BS/2;
				end
				local adapt = TL[type].lastTrendLine.ad*move;
				local fromLevelMain = close[TL[type].lastTrendLine.sPoint] - BS - adapt;
				local toLevelMain = fromLevelMain + ((period-1)-TL[type].lastTrendLine.sPoint)*move;
				local fromLevel = close[period-1] - BS;
				if isSmallerOrEqual(fromLevel,toLevelMain) then
					canAdd = false;
				end
			end
		end
		if canAdd then
			local tbl = {broken = false,sPoint=period-1,ePoint=period,confirmed = false,isMain=false,ad=0}
			TL[type].up[period-1] = tbl;
			if TL[type].lastTrendLine == nil then TL[type].lastTrendLine = tbl; TL[type].up[period-1].isMain = true end
			if TL[type].Trend == 0 then TL[type].Trend = 1 end
		end
	end
	-- Check Bearish resistance Line
	for pos,val in pairs(TL[type].dn) do 
		if val.broken == false or val.confirmed== false then
			TL[type].dn[pos].ePoint = period;
			local color = nil;
			local move = nil;
			local id = nil;
			if type == 45 then
				color = colors.Tdn45;
				move = BS;
				id = 10000*pos
			else
				color = colors.Tdn22;
				move = BS/2;
				id = 20000*pos
			end
			local adapt = val.ad*move;
			local fromDate = close:date(val.sPoint);
			local toDate = close:date(period);
			local fromLevel = close[val.sPoint] + BS + adapt;
			local toLevel = fromLevel - (period-val.sPoint)*move;
			if val == TL[type].lastTrendLine then
				if TL[type].On then
					--core.host:execute ("drawLine", id, fromDate, fromLevel, toDate, toLevel, color, line.TL.s_M, line.TL.w_M, "Main Bearish resistance Line")
				end
				core.drawLine(TL[type].dnOut, core.range(val.sPoint, period), fromLevel, val.sPoint, toLevel, period);
			else
				if TL[type].On then
					--core.host:execute ("drawLine", id, fromDate, fromLevel, toDate, toLevel, color, line.TL.s_S, line.TL.w_S, "Secondary Bearish resistance Line")
				end
			end
			if TL[type].Confirm == "CO" then
				if val.broken == false and val.confirmed == false then
					if PA["SBS"][TL[type].dn[pos].ePoint] ~= nil and PA["SBS"][TL[type].dn[pos].ePoint].fin and -- Double Top
						isGreater(high[period],toLevel) and isEqual(direction[period],1) then -- Trendline Break
						TL[type].dn[pos].broken = true;
						TL[type].dn[pos].confirmed = false;
					end
				elseif val.broken and val.confirmed == false then
					if isGreaterOrEqual(low[period],toLevel) and isSmaller(open[period],close[period]) then
						TL[type].dn[pos].broken = true;
						TL[type].dn[pos].confirmed = true;
						if val == TL[type].lastTrendLine then 
							TL[type].Long[period]=open[period]+(RS-1)*BS; 
							SendAlert(type .. " Trendline break",TL[type].Long[period]);
							--if TL[type].On and instance.parameters.styleTL_M ~= core.LINE_NONE then HorizontalCount(TL[type].Long[period]); end
						end
					end
				end
			elseif TL[type].Confirm == "BR" then
				if 	PA["SBS"][TL[type].dn[pos].ePoint] ~= nil and PA["SBS"][TL[type].dn[pos].ePoint].fin and -- Double Top
					isGreater(high[period],toLevel) and isEqual(direction[period],1) then -- Trendline Break
					TL[type].dn[pos].broken = true;
					TL[type].dn[pos].confirmed = true;
					if val == TL[type].lastTrendLine then 
						if isGreater(toLevel+BS,open[period]+(RS-1)*BS) then
							if isGreater(high[period-2] + BS,toLevel+BS) then
								TL[type].Long[period]=high[period-2] + BS; 
								SendAlert(type .. " Trendline break",TL[type].Long[period]);
								--if TL[type].On and instance.parameters.styleTL_M ~= core.LINE_NONE then HorizontalCount(TL[type].Long[period]); end
							else
								TL[type].Long[period]=toLevel+BS;
								SendAlert(type .. " Trendline break",TL[type].Long[period]);
								--if TL[type].On and instance.parameters.styleTL_M ~= core.LINE_NONE then HorizontalCount(TL[type].Long[period]); end
							end
						else
							if isGreater(high[period-2] + BS,open[period]+(RS-1)*BS) then
								TL[type].Long[period]=high[period-2] + BS;
								SendAlert(type .. " Trendline break",TL[type].Long[period]); 
								--if TL[type].On and instance.parameters.styleTL_M ~= core.LINE_NONE then HorizontalCount(TL[type].Long[period]); end
							else
								TL[type].Long[period]=open[period]+(RS-1)*BS;
								SendAlert(type .. " Trendline break",TL[type].Long[period]);
								--if TL[type].On and instance.parameters.styleTL_M ~= core.LINE_NONE then HorizontalCount(TL[type].Long[period]); end
							end
						end
					end
				end
			elseif TL[type].Confirm == "AD" then
				if 	PA["SBS"][TL[type].dn[pos].ePoint] ~= nil and PA["SBS"][TL[type].dn[pos].ePoint].fin and -- Double Top
					isGreater(high[period],toLevel) and isEqual(direction[period],1) then -- Trendline Break
					TL[type].dn[pos].broken = true;
					TL[type].dn[pos].confirmed = true;
					if val == TL[type].lastTrendLine then 
						if isGreater(toLevel+BS,open[period]+(RS-1)*BS) then
							if isGreater(high[period-2] + BS,toLevel+BS) then
								TL[type].Long[period]=high[period-2] + BS;
								SendAlert(type .. " Trendline break",TL[type].Long[period]);
								--if TL[type].On and instance.parameters.styleTL_M ~= core.LINE_NONE then HorizontalCount(TL[type].Long[period]); end
							else
								TL[type].Long[period]=toLevel+BS;
								SendAlert(type .. " Trendline break",TL[type].Long[period]); 
								--if TL[type].On and instance.parameters.styleTL_M ~= core.LINE_NONE then HorizontalCount(TL[type].Long[period]); end
							end
						else
							if isGreater(high[period-2] + BS,open[period]+(RS-1)*BS) then
								TL[type].Long[period]=high[period-2] + BS;
								SendAlert(type .. " Trendline break",TL[type].Long[period]); 
								--if TL[type].On and instance.parameters.styleTL_M ~= core.LINE_NONE then HorizontalCount(TL[type].Long[period]); end
							else
								TL[type].Long[period]=open[period]+(RS-1)*BS;
								SendAlert(type .. " Trendline break",TL[type].Long[period]);
								--if TL[type].On and instance.parameters.styleTL_M ~= core.LINE_NONE then HorizontalCount(TL[type].Long[period]); end
							end
						end
					end
				elseif 	isGreaterOrEqual(high[period-1],toLevel+move+adapt) then -- Trendline Break
						val.ad = val.ad + 1;
						core.host:trace("DN -- add");
				end
			end
		end
	end
	-- Check Bullish support line
	for pos,val in pairs(TL[type].up) do 
		if val.broken == false or val.confirmed == false then
			TL[type].up[pos].ePoint = period;
			local color = nil;
			local move = nil;
			local id = nil;
			if type == 45 then
				color = colors.Tup45;
				move = BS;
				id = 10000*pos
			else
				color = colors.Tup22;
				move = BS/2;
				id = 20000*pos
			end
			local adapt = val.ad*move;
			local fromDate = close:date(val.sPoint);
			local toDate = close:date(period);
			local fromLevel = close[val.sPoint] - BS - adapt;
			local toLevel = fromLevel + (period-val.sPoint)*move;
			if val == TL[type].lastTrendLine then
				if TL[type].On then
					--core.host:execute ("drawLine", id, fromDate, fromLevel, toDate, toLevel, color, line.TL.s_M, line.TL.w_M, "Main Bullish support line")
				end
				core.drawLine(TL[type].upOut, core.range(val.sPoint, period), fromLevel, val.sPoint, toLevel, period);
			else
				if TL[type].On then
					--core.host:execute ("drawLine", id, fromDate, fromLevel, toDate, toLevel, color, line.TL.s_S, line.TL.w_S, "Secondary Bullish support line")
				end
			end
			if TL[type].Confirm == "CO" then
				if val.broken == false and val.confirmed == false then
					if 	PA["SBS"][TL[type].up[pos].ePoint] ~= nil and PA["SBS"][TL[type].up[pos].ePoint].fin and -- Double Top
						isSmaller(low[period],toLevel) and isEqual(direction[period],-1) then -- Trendline Break
						TL[type].up[pos].broken = true;
						TL[type].up[pos].confirmed = false;
					end
				elseif val.broken and val.confirmed == false then
					if isSmallerOrEqual(high[period],toLevel) and isGreater(open[period],close[period]) then
						TL[type].up[pos].broken = true;
						TL[type].up[pos].confirmed = true;
						if val == TL[type].lastTrendLine then 
							TL[type].Short[period]=open[period]-(RS-1)*BS;
							SendAlert(type .. " Trendline break",TL[type].Short[period]); 
							--if TL[type].On and instance.parameters.styleTL_M ~= core.LINE_NONE then HorizontalCount(TL[type].Short[period]); end
						end
					end
				end
			elseif TL[type].Confirm == "BR" then
				if 	PA["SBS"][TL[type].up[pos].ePoint] ~= nil and PA["SBS"][TL[type].up[pos].ePoint].fin and -- Double Top
					isSmaller(low[period],toLevel) and isEqual(direction[period],-1) then -- Trendline Break
					TL[type].up[pos].broken = true;
					TL[type].up[pos].confirmed = true;
					if val == TL[type].lastTrendLine then 
						if isSmaller(toLevel-BS,open[period]-(RS-1)*BS) then
							if isSmaller(low[period-2] - BS,toLevel-BS) then
								TL[type].Short[period]=low[period-2] - BS;
								SendAlert(type .. " Trendline break",TL[type].Short[period]);
								--if TL[type].On and instance.parameters.styleTL_M ~= core.LINE_NONE then HorizontalCount(TL[type].Short[period]); end
							else
								TL[type].Short[period]=toLevel-BS;
								SendAlert(type .. " Trendline break",TL[type].Short[period]);
								--if TL[type].On and instance.parameters.styleTL_M ~= core.LINE_NONE then HorizontalCount(TL[type].Short[period]); end
							end
						else
							if isSmaller(low[period-2] - BS,open[period]-(RS-1)*BS) then
								TL[type].Short[period]=low[period-2] - BS;
								SendAlert(type .. " Trendline break",TL[type].Short[period]);
								--if TL[type].On and instance.parameters.styleTL_M ~= core.LINE_NONE then HorizontalCount(TL[type].Short[period]); end
							else
								TL[type].Short[period]=open[period]-(RS-1)*BS;
								SendAlert(type .. " Trendline break",TL[type].Short[period]);
								--if TL[type].On and instance.parameters.styleTL_M ~= core.LINE_NONE then HorizontalCount(TL[type].Short[period]); end
							end
						end
					end
				end
			elseif TL[type].Confirm == "AD" then
				if 	PA["SBS"][TL[type].up[pos].ePoint] ~= nil and PA["SBS"][TL[type].up[pos].ePoint].fin and -- Double Top
					isSmaller(low[period],toLevel) and isEqual(direction[period],-1) then -- Trendline Break
					TL[type].up[pos].broken = true;
					TL[type].up[pos].confirmed = true;
					if val == TL[type].lastTrendLine then 
						if isSmaller(toLevel-BS,open[period]-(RS-1)*BS) then
							if isSmaller(low[period-2] - BS,toLevel-BS) then
								TL[type].Short[period]=low[period-2] - BS;
								SendAlert(type .. " Trendline break",TL[type].Short[period]); 
								--if TL[type].On and instance.parameters.styleTL_M ~= core.LINE_NONE then HorizontalCount(TL[type].Short[period]); end
							else
								TL[type].Short[period]=toLevel-BS; 
								SendAlert(type .. " Trendline break",TL[type].Short[period]);
								--if TL[type].On and instance.parameters.styleTL_M ~= core.LINE_NONE then HorizontalCount(TL[type].Short[period]); end
							end
						else
							if isSmaller(low[period-2] - BS,open[period]-(RS-1)*BS) then
								TL[type].Short[period]=low[period-2] - BS;
								SendAlert(type .. " Trendline break",TL[type].Short[period]);
								--if TL[type].On and instance.parameters.styleTL_M ~= core.LINE_NONE then HorizontalCount(TL[type].Short[period]); end
							else
								TL[type].Short[period]=open[period]-(RS-1)*BS;
								SendAlert(type .. " Trendline break",TL[type].Short[period]);
								--if TL[type].On and instance.parameters.styleTL_M ~= core.LINE_NONE then HorizontalCount(TL[type].Short[period]); end
							end
						end
					end
				elseif 	isSmallerOrEqual(low[period-1],toLevel-move-adapt) then -- Trendline Break
						val.ad = val.ad + 1;
				end
			end
		end
	end
	if TL[type].lastTrendLine ~= nil and TL[type].lastTrendLine.broken and TL[type].lastTrendLine.confirmed then
		if TL[type].Trend < 0 then
			local move = nil;
			if type == 45 then
				move = BS;
			else
				move = BS/2;
			end
			local fromLevel = close[TL[type].lastTrendLine.sPoint] + BS;
			local toLevel = fromLevel - (period-TL[type].lastTrendLine.sPoint)*move;
			TL[type].Trend = 1;
			local v = 100000;
			for pos,val in pairs(TL[type].up) do 
				if (val.broken == false or val.confirmed == false) and v > pos then
					TL[type].lastTrendLine = val;
					v = pos;
				end
			end
			if TL[type].up[TL[type].lastTrendLine.sPoint] ~= nil then
				TL[type].up[TL[type].lastTrendLine.sPoint].isMain=true
			end
			if TL[type].lastTrendLine.broken and TL[type].lastTrendLine.confirmed then
				if TL[type].up[TL[type].lastTrendLine.sPoint] ~= nil then
					TL[type].up[TL[type].lastTrendLine.sPoint].isMain=false;
				end
				TL[type].lastTrendLine = nil;
				TL[type].Trend = 0;
			end
		elseif TL[type].Trend > 0 then
			local move = nil;
			if type == 45 then
				move = BS;
			else
				move = BS/2;
			end
			local fromLevel = close[TL[type].lastTrendLine.sPoint] - BS;
			local toLevel = fromLevel + (period-TL[type].lastTrendLine.sPoint)*move;
			TL[type].Trend = -1
			local v = 100000;
			for pos,val in pairs(TL[type].dn) do 
				if (val.broken == false or val.confirmed == false) and v > pos then
					TL[type].lastTrendLine = val;
					v = pos;
				end
			end
			if TL[type].dn[TL[type].lastTrendLine.sPoint] ~= nil then
				TL[type].dn[TL[type].lastTrendLine.sPoint].isMain=true
			end
			if TL[type].lastTrendLine.broken and TL[type].lastTrendLine.confirmed then
				if TL[type].dn[TL[type].lastTrendLine.sPoint] ~= nil then
					TL[type].dn[TL[type].lastTrendLine.sPoint].isMain=false;
				end
				TL[type].lastTrendLine = nil;
				TL[type].Trend = 0;
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Async Function History and Tick handling -----------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
local extending = false;
-------------------------------------------------------------------------------------------------------------------------------------------------------
function AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 999 then
		core.host:execute("setStatus", "ATR");
		ATR:update(core.UpdateAll);
		BS = math.floor(ATR.DATA[historyD1:size()-1]*PP/point)*point;
		loading 	= true;
		history 	= core.host:execute("getHistory", 1000, instrument, frame, math.floor(instance.parameters.from), 0, bid);
		name    		=  profile:id() .. "(" .. instrument .."." .. frame .. "," .. BS/point .."," ..RS..")";
		instance:name(name);
		core.host:execute("setStatus", "Loading History");
    elseif cookie == 1000 then
		local first_date = history:date(history:first());
		if math.floor(first_date) > math.floor(instance.parameters.from) and extending == false and instance.parameters.TF ~= "t1" then
			core.host:execute("extendHistory", 1000, history, math.floor(instance.parameters.from), first_date);
			extending = true;
			return ;
		end
		-- Handle History
		if Ignore then
			if instance.parameters.TF == "t1" then
				his.high = history;
				his.low = history;
				his.open = history;
				his.close = history;
			else
				his.high = history.close;
				his.low = history.close;
				his.open = history.close;
				his.close = history.close;
			end
		else
			if instance.parameters.TF == "t1" then
				his.high = history;
				his.low = history;
				his.open = history;
				his.close = history;
			else
				his.high = history.high;
				his.low = history.low;
				his.open = history.open;
				his.close = history.close;
			end
		end
		for i = 0, history:size() - 1, 1 do
			if i == history:size() - 1 then
				lastSerial = history:serial(i);
			end
			if RS < 2 then
				proccesWyckoff(i,history:date(i),his.high[i],his.low[i]);
			else
				proccesCandle(i,history:date(i),his.high[i],his.low[i]);
			end
		end
		loading = false;
		core.host:execute("setStatus", "");
		TimerID=core.host:execute("setTimer", 1, 1)
	elseif cookie == 1 then
		if not EndOfTheDay then
			if instance.parameters.TF ~= "t1" then
				his.high = history.close;
				his.low = history.close;
				his.open = history.close;
				his.close = history.close;
			end
		end
		-- history loading is done. start handle ticks
		core.host:execute("subscribeTradeEvents", 2000, "offers");
		core.host:execute("killTimer", TimerID);
    elseif cookie == 2000 then
		-- handle live sourcestream
        if message == offer and loading == false then
			local i = history:size() - 1;
			local Time ;
			if not EndOfTheDay or frame == "t1" then
				Time = core.host:findTable("offers"):find("OfferID", offer).Time;
				if RS < 2 then
					proccesWyckoff(i,Time,his.high[i],his.low[i]);
				else
					proccesCandle(i,Time,his.high[i],his.low[i]);
				end
			else
				if lastSerial ~= history:serial(i) and lastSerial ~= nil then
					Time = history:date(i-1);
					if RS < 2 then
						proccesWyckoff(i-1,Time,his.high[i-1],his.low[i-1]);
					else
						proccesCandle(i-1,Time,his.high[i-1],his.low[i-1]);
					end
					lastSerial = history:serial(i);
				end
			end
			tvolume[open:size()-1] = tvolume[open:size()-1] + 1;
        end
    end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Point and Figure Stream Calculation ----------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
function proccesCandle(period,time,source_high,source_low)
	-- Calculation with more then one Box Reversal Count --
	-------------------------------------------------------
	local current = open:size() - 1;
	local updateflag = false;
	if current < 0 then
		instance:addViewBar(time);
		current             = current + 1;
		sdate[current] 		= time;
		open[current]       = round(his.open[period]);
		if source_high > open[current] then
			local z = math.floor((source_high - open[current]) / BS);
			close[current] 	= open[current] + z*BS;
			high[current] 	= close[current];
			low[current] 	= open[current];
			direction[current] = 1;
			updateflag = true;
		elseif 	source_low < open[current] then
			local z = math.floor((open[current] - source_low) / BS);
			close[current] 	= open[current] - z*BS;
			low[current] 	= close[current];
			high[current] 	= open[current];
			direction[current] = -1;
			updateflag= true;
		else
			close[current] 	= open[current];
			low[current] 	= open[current];
			high[current] 	= open[current];
			direction[current] = 0;
		end
		volume[current]     = math.modf(((math.abs(close[current] - open[current]))/BS)+1.01);
		if instance.parameters.TF == "t1" then
			tvolume[current] = tvolume[current] + 1;
		else
			tvolume[current] = tvolume[current] + history.volume[period];
		end
	else
		current = open:size() - 1;
		if direction[current] == 1 then
			local z = math.floor((source_high - open[current]) / BS);
			-- 1. Use the high if new X can be drawn;
			if high[current] < open[current] + z*BS then
				high[current] 		= math.max(high[current],open[current] + z*BS);
				close[current] 		= high[current];
				volume[current]     = math.modf(((math.abs(close[current] - open[current]))/BS)+1.01);
				updateflag = true;
			else
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
					updateflag = true;
				end
			end
		elseif direction[current] == -1 then
			local z = math.floor((open[current] - source_low) / BS);
			-- 1. Use the low if new O can be drawn;
			if low[current] > open[current] - z*BS then
				low[current] 		= math.min(open[current] - z*BS,low[current]);
				close[current] 		= low[current] ;
				volume[current]     = math.modf(((math.abs(close[current] - open[current]))/BS)+1.01);
				updateflag = true;
			else
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
					updateflag = true;
				end
			end
		else
			if source_high > open[current] then
				local z = math.floor((source_high - open[current]) / BS);
				close[current] 	= open[current] + z*BS;
				high[current] 	= close[current];
				low[current] 	= open[current];
				direction[current] = 1;
				updateflag = true;
			elseif 	source_low < open[current] then
				local z = math.floor((open[current] - source_low) / BS);
				close[current] 	= open[current] - z*BS;
				low[current] 	= close[current];
				high[current] 	= open[current];
				direction[current] = -1;
				updateflag = true;
			else
				close[current] 	= open[current];
				low[current] 	= open[current];
				high[current] 	= open[current];
				direction[current] = 0;
			end
			volume[current]     = math.modf(((math.abs(close[current] - open[current]))/BS)+1.01);
			if instance.parameters.TF == "t1" then
				tvolume[current] = tvolume[current] + 1;
			else
				tvolume[current] = tvolume[current] + history.volume[period];
			end
		end
	end
	if updateflag == true then
		-- Update Month and Day.
		checkNewMonthOrDay(current);
		cleanPatternTable();
		findSimpleBS();
		findTrendLine(45);
		findTrendLine(22);
		findDoubleTB();
		findTripleTB();
		findTriangle();
		findCatapult();
		findShakeOut();
		findFlag();
		VerifyHTargets();
		VerticalCount();
		VerifyVTargets();
	end
end
-- Calculation with one Box Reversal Count -- Wyckoff Drawing Method --
function proccesWyckoff(period,time,source_high,source_low)
	local current = open:size() - 1;
	local updateflag = false;
	if current < 0 then
		instance:addViewBar(time);
		current             = current + 1;
		sdate[current] 		= time;
		open[current]       = round(his.open[period]);
		if source_high > open[current] then
			local z = math.floor((source_high - open[current]) / BS);
			close[current] 	= open[current];
			high[current] 	= open[current] + z*BS;
			low[current] 	= open[current];
			direction[current] = 1;
			updateflag = true;
		elseif 	source_low < open[current] then
			local z = math.floor((open[current] - source_low) / BS);
			close[current] 	= open[current];
			low[current] 	= open[current] - z*BS;
			high[current] 	= open[current];
			direction[current] = -1;
			updateflag = true;
		else
			close[current] 	= open[current];
			low[current] 	= open[current];
			high[current] 	= open[current];
			direction[current] = 0;
		end
		volume[current]     = math.modf(((math.abs(close[current] - open[current]))/BS)+1.01);
		if instance.parameters.TF == "t1" then
			tvolume[current] = tvolume[current] + 1;
		else
			tvolume[current] = tvolume[current] + history.volume[period];
		end
	else
		current = open:size() - 1;
		if direction[current] == 1 then
			local z = math.floor((source_high - open[current]) / BS);
			-- 1. Use the high if new X can be drawn;
			if high[current] < open[current] + z*BS then
				high[current] 		= math.max(high[current],open[current] + z*BS);
				volume[current]     = math.modf(((math.abs(close[current] - open[current]))/BS)+1.01);
				updateflag = true;
			else
			-- 2. use the low if no new X can be drawn and the low triggers a reversal;
				z = math.floor((high[current] - source_low) / BS);
				if z >= RS then
					if isEqual(high[current],open[current]) and isEqual(open[current],close[current]) then
						direction[current] = -1 ;
						open[current]     	= close[current] - BS;
						low[current]		= high[current] - z*BS;
						updateflag = true;
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
						updateflag = true;
					end
				end
			end
		elseif direction[current] == -1 then
			local z = math.floor((open[current] - source_low) / BS);
			-- 1. Use the low if new O can be drawn;
			if low[current] > open[current] - z*BS then
				low[current] 		= math.min(open[current] - z*BS,low[current]);
				--close[current] 		= low[current] ;
				volume[current]     = math.modf(((math.abs(close[current] - open[current]))/BS)+1.01);
				updateflag = true;
			else
			-- 2. use the high if no new O can be drawn and the high triggers a reversal;
				z = math.floor((source_high - low[current]) / BS);
				if z >= RS then
					if isEqual(low[current],open[current]) and isEqual(open[current],close[current]) then
						direction[current] = 1;
						close[current]     	= open[current] + BS;
						high[current]		= low[current] + z*BS;
						updateflag = true;
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
						updateflag = true;
					end
				end
			end
		else
			if source_high > open[current] then
				local z = math.floor((source_high - open[current]) / BS);
				close[current] 	= open[current];
				high[current] 	= open[current] + z*BS;
				low[current] 	= open[current];
				direction[current] = 1;
				updateflag = true;
			elseif 	source_low < open[current] then
				local z = math.floor((open[current] - source_low) / BS);
				close[current] 	= open[current];
				low[current] 	= open[current] - z*BS;
				high[current] 	= open[current];
				direction[current] = -1;
				updateflag = true;
			else
				close[current] 	= open[current];
				low[current] 	= open[current];
				high[current] 	= open[current];
				direction[current] = 0;
			end
			volume[current]     = math.modf(((math.abs(close[current] - open[current]))/BS)+1.01);
			if instance.parameters.TF == "t1" then
				tvolume[current] = tvolume[current] + 1;
			else
				tvolume[current] = tvolume[current] + history.volume[period];
			end
		end
	end
	if updateflag == true then
		-- Update Month and Day.
		checkNewMonthOrDay(current);
	end
end
-- Nex Month or Day Calculation -----------------------------------------------------------------------------------------------------------------------
local lastDay = 0;
local lastMonth = 0;
-------------------------------------------------------------------------------------------------------------------------------------------------------
function checkNewMonthOrDay(current)
	-- New Month or Day
	local tbl  = core.dateToTable(open:date(current));
	local day  = tbl.day;
	local month = tbl.month;
	if lastDay ~= day then
		if lastMonth ~= month then
			if instance.parameters.bMonth then
				nMon[current] = {d=month,p=close[current]};
			elseif instance.parameters.bDay then
				nDay[current] = {d=day,p=close[current]};
			end
			lastMonth = month;
		elseif instance.parameters.bDay then
			nDay[current] = {d=day,p=close[current]};
		end
		lastDay = day;
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function round(price)
    return math.floor(price/BS)*BS;
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Draw Functions - Draw Point and Figure Chart -------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
local init = false;
local lastGF = nil;
local FONT 	= 1;
local X_PEN = 2;
local O_PEN = 3;
local N_PEN = 4;
local X_BRU = 5;
local O_BRU = 6;
local M_BRU = 7;
local D_BRU = 8;
local B_BRU = 9;
local S_BRU = 10;
local N_BRU = 11;
-- Trendlines
local TL45_up_PEN_M = 12;
local TL45_dn_PEN_M = 13;
local TL22_up_PEN_M = 14;
local TL22_dn_PEN_M = 15;
local TL45_up_PEN_S = 16;
local TL45_dn_PEN_S = 17;
local TL22_up_PEN_S = 18;
local TL22_dn_PEN_S = 19;
-- Targets
local THU_PEN = 20;
local THD_PEN = 21;
local THF_PEN = 22;
local THF_BRUSH = 23;
local THU_BRUSH = 24;
local THD_BRUSH = 25;
local THS_BRUSH = 26;
local FONT2	= 27;
local FONT3	= 28;
local TVU_PEN = 29;
local TVD_PEN = 30;
local PB_PEN = 31;
local PS_PEN = 32;
local PE_PEN = 33;

-------------------------------------------------------------------------------------------------------------------------------------------------------
function Draw(stage, context)
	if stage == 0 and instance.parameters.ShowGrid then
		
	elseif stage == 2 and open:size() > 0 then

        if not init then
			context:createPen(X_PEN,            	context.SOLID, 1, colors.X);
            context:createPen(O_PEN,          		context.SOLID, 1, colors.O);
            context:createPen(N_PEN,          		context.SOLID, 1, colors.N);
			context:createSolidBrush (X_BRU, colors.X);
			context:createSolidBrush (O_BRU, colors.O);
			context:createSolidBrush (M_BRU, colors.M);
			context:createSolidBrush (D_BRU, colors.D);
			context:createSolidBrush (B_BRU, colors.B);
			context:createSolidBrush (S_BRU, colors.S);
			context:createSolidBrush (N_BRU, colors.N);
			local s_45 = 	context.SOLID;
			if line.TL.s_M_45 == core.LINE_DOT then
				s_45 = 	context.DOT;
			elseif line.TL.s_M_45 == core.LINE_DASH then
				s_45 = 	context.DASH;
			elseif line.TL.s_M_45 == core.LINE_DASHDOT then
				s_45 = 	context.DASHDOT;
			end
			context:createPen(TL45_up_PEN_M,     		s_45, line.TL.w_M_45, colors.Tup45);
            context:createPen(TL45_dn_PEN_M,         	s_45, line.TL.w_M_45, colors.Tdn45);
			if line.TL.s_S_45 == core.LINE_DOT then
				s_45 = 	context.DOT;
			elseif line.TL.s_S_45 == core.LINE_DASH then
				s_45 = 	context.DASH;
			elseif line.TL.s_S_45 == core.LINE_DASHDOT then
				s_45 = 	context.DASHDOT;
			end			
			context:createPen(TL45_up_PEN_S,     		s_45, line.TL.w_S_45, colors.Tup45);
            context:createPen(TL45_dn_PEN_S,         	s_45, line.TL.w_S_45, colors.Tdn45);
			-- 22.5 Trendline PEN
			local s_22 = 	context.SOLID;
			if line.TL.s_M_22 == core.LINE_DOT then
				s_22 = 	context.DOT;
			elseif line.TL.s_M_22 == core.LINE_DASH then
				s_22 = 	context.DASH;
			elseif line.TL.s_M_22 == core.LINE_DASHDOT then
				s_22 = 	context.DASHDOT;
			end
			context:createPen(TL22_up_PEN_M,     		s_22, line.TL.w_M_22, colors.Tup22);
            context:createPen(TL22_dn_PEN_M,         	s_22, line.TL.w_M_22, colors.Tdn22);
			if line.TL.s_S_22 == core.LINE_DOT then
				s_22 = 	context.DOT;
			elseif line.TL.s_S_22 == core.LINE_DASH then
				s_22 = 	context.DASH;
			elseif line.TL.s_S_22 == core.LINE_DASHDOT then
				s_22 = 	context.DASHDOT;
			end			
			context:createPen(TL22_up_PEN_S,     		s_22, line.TL.w_S_22, colors.Tup22);
            context:createPen(TL22_dn_PEN_S,         	s_22, line.TL.w_S_22, colors.Tdn22);
			
			-- Targets
			
			context:createPen(THU_PEN,            	context.SOLID, 1, instance.parameters.cHup);
            context:createPen(THD_PEN,          	context.SOLID, 1, instance.parameters.cHdn);
            context:createPen(THF_PEN,          	context.SOLID, 1, instance.parameters.cHf);
			context:createHatchBrush  (THF_BRUSH,context.DIAGCROSS, instance.parameters.cHf);
			context:createHatchBrush  (THU_BRUSH,context.DIAGCROSS, instance.parameters.cHup);
			context:createHatchBrush  (THD_BRUSH,context.DIAGCROSS, instance.parameters.cHdn);
			context:createHatchBrush  (THS_BRUSH,context.DIAGCROSS, core.rgb(255,0,0));
			context:createPen(TVU_PEN,            	context.SOLID, 1, instance.parameters.cVup);
            context:createPen(TVD_PEN,          	context.SOLID, 1, instance.parameters.cVdn);
			context:createPen(PB_PEN,          	context.SOLID, 1, colors.B);
            context:createPen(PS_PEN,          	context.SOLID, 1, colors.S);
            context:createPen(PE_PEN,          	context.SOLID, 1, core.rgb(255, 255, 0));
            init = true;
		end
		t, s, e = context:positionOfBar(1);
		cellW = math.floor((e - s)*1.45 + 0.5);
		cellH = context:priceWidth((BS*1.35),0);
		local Xw,Xh;
		-- clip the output to the chart area
        context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
        if cellW <= 8 then --cellW <= 4 or cellH <= 4 then
            drawUsingLines(context, cellW, cellH);
        else
			if cellW > cellH then
				context:createFont (FONT, "Arial", 0, cellH, 0);
			else
				context:createFont (FONT, "Arial", 0, cellW, 0);
			end
			if cellW*0.7 > cellH*0.7 then
				if cellH*0.7 <= 11 then
					context:createFont (FONT2, "Arial", 0, cellH*0.7, 0);
				else
					context:createFont (FONT2, "Arial", 0, 12, 0);
				end
			else
				if cellW*0.7 <= 11 then
					context:createFont (FONT2, "Arial", 0, cellW*0.7, 0);
				else
					context:createFont (FONT2, "Arial", 0, 12, 0);
				end
			end
			Xw,Xh = context:measureText (FONT, "O", context.CENTER+context.SINGLELINE);
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
			forcastSignal(index,context);
		end
		-- Proccess Vertical
		for pos,val in pairs(TA["V"]) do 
			if val.p == index and val.a == true then
				local s = "%." .. digits .. "f";
				local txt = string.format(s,val.t)
				local tw,th = context:measureText (FONT2, txt, context.CENTER+context.SINGLELINE);
				local p1 , p11 , p12 = context:positionOfBar (val.p)
				local p2 , p21 , p22 = context:positionOfBar (val.p2)
				local e1, ey1 = context:pointOfPrice(val.e);
				local e2, ey2 = context:pointOfPrice(val.t);
				if val.d == "UP" then
					local e3, ey3 = context:pointOfPrice(val.e-BS);
					local e4, ey4 = context:pointOfPrice(val.t + BS/2);
					if val.sl == true then
						context:drawLine (THF_PEN, p1, ey3, p1, ey2, 0)
						context:drawLine (THF_PEN, p1, ey1, p2, ey1, 0)
						context:drawLine (THF_PEN, p11, ey2, p12, ey2, 0)
						context:drawText (FONT2, txt, instance.parameters.cHf, -1, p1-tw/2, ey4-th/2, p1+tw/2, ey4 +th/2, context.CENTER+context.PATH_ELLIPSIS+context.SINGLELINE, 0);
					else
						context:drawLine (TVU_PEN, p1, ey3, p1, ey2, 0)
						context:drawLine (TVU_PEN, p1, ey1, p2, ey1, 0)
						context:drawLine (TVU_PEN, p11, ey2, p12, ey2, 0)
						context:drawText (FONT2, txt, instance.parameters.cVup, -1, p1-tw/2, ey4-th/2, p1+tw/2, ey4 +th/2, context.CENTER+context.PATH_ELLIPSIS+context.SINGLELINE, 0);
					end
				elseif val.d == "DN" then
					local e3, ey3 = context:pointOfPrice(val.e+BS);
					local e4, ey4 = context:pointOfPrice(val.t - BS/2);
					if val.sl == true then
						context:drawLine (THF_PEN, p1, ey3, p1, ey2, 0)
						context:drawLine (THF_PEN, p1, ey1, p2, ey1, 0)
						context:drawLine (THF_PEN, p11, ey2, p12, ey2, 0)
						context:drawText (FONT2, txt, instance.parameters.cHf, -1, p1-tw/2, ey4-th/2, p1+tw/2, ey4 +th/2, context.CENTER+context.PATH_ELLIPSIS+context.SINGLELINE, 0);
					else
						context:drawLine (TVD_PEN, p1, ey3, p1, ey2, 0)
						context:drawLine (TVD_PEN, p1, ey1, p2, ey1, 0)
						context:drawLine (TVD_PEN, p11, ey2, p12, ey2, 0)
						context:drawText (FONT2, txt, instance.parameters.cVdn, -1, p1-tw/2, ey4-th/2, p1+tw/2, ey4 +th/2, context.CENTER+context.PATH_ELLIPSIS+context.SINGLELINE, 0);
					end
				end
			end
		end
		-- Proccess Horizontal
		for pos,val in pairs(TA["H"]) do 
			if val.p == index then
				local s = "%." .. digits .. "f (%.1f)";
				local txt = string.format(s,val.t ,val.r)
				local tw,th = context:measureText (FONT2, txt, context.CENTER+context.SINGLELINE);
				local p , p1 , p2 = context:positionOfBar (val.p2)
				local t4, y4 = context:pointOfPrice(val.s);
				if val.d == "UP" then
					local t1, y1 = context:pointOfPrice(val.t + BS/2);
					local t2, y2 = context:pointOfPrice(val.e);
					local t3, y3 = context:pointOfPrice(val.t);
					--if not t3 then
					--	y3 = context:top() + context:priceWidth (BS*2,0);
					--	y1 = context:top() + context:priceWidth (BS,0);
					--end 
					if isEqual(val.f ,-1) then 
						--context:drawRectangle (THF_PEN, -1, p, y2, x, y3, 150)
						context:drawRectangle (THF_PEN, THF_BRUSH, p, y2, x, y3, 150)
						--context:drawText (FONT2, txt, instance.parameters.cHf, -1, x-tw, y1-th/2, x, y1 +th/2, context.LEFT+context.PATH_ELLIPSIS+context.SINGLELINE, 0);
					elseif isEqual(val.f ,1) or isEqual(val.f ,0) then
						if isEqual(val.f ,0) then 
							context:drawRectangle (-1, THS_BRUSH, p, y4, x, y2, 200); 
							context:drawRectangle (THU_PEN, THU_BRUSH, p, y2, x, y3, 200)
							--context:drawText (FONT2, txt, instance.parameters.cHup, -1, x-tw, y1-th/2, x, y1 +th/2, context.LEFT+context.PATH_ELLIPSIS+context.SINGLELINE, 0);
						else
							context:drawRectangle (THU_PEN, THU_BRUSH, p, y2, x, y3, 220)
							--context:drawText (FONT2, txt, instance.parameters.cHup, -1, x-tw, y1-th/2, x, y1 +th/2, context.LEFT+context.PATH_ELLIPSIS+context.SINGLELINE, 0);
						end
					end
				elseif val.d == "DN" then
					local t1, y1 = context:pointOfPrice(val.t - BS/2);
					local t2, y2 = context:pointOfPrice(val.e);
					local t3, y3 = context:pointOfPrice(val.t);
					--if not t3 then
					--	y3 = context:top() - context:priceWidth (BS*2,0);
					--	y1 = context:top() - context:priceWidth (BS,0);
					--end 
					if isEqual(val.f ,-1) then 
						--context:drawRectangle (THF_PEN, -1, p, y2, x, y3, 150)
						context:drawRectangle (THF_PEN, THF_BRUSH, p, y2, x, y3, 150)
						--context:drawText (FONT2, txt, instance.parameters.cHf, -1, x-tw, y1-th/2, x, y1+th/2 , context.LEFT+context.PATH_ELLIPSIS+context.SINGLELINE, 0);
					elseif isEqual(val.f ,1) or isEqual(val.f ,0) then
						if isEqual(val.f ,0) then 
							context:drawRectangle (-1, THS_BRUSH, p, y4, x, y2, 200);
							context:drawRectangle (THD_PEN, THD_BRUSH, p, y2, x, y3, 200)
							--context:drawText (FONT2, txt, instance.parameters.cHdn, -1, x-tw, y1-th/2, x, y1+th/2 , context.LEFT+context.PATH_ELLIPSIS+context.SINGLELINE, 0);
						else
							context:drawRectangle (THD_PEN, THD_BRUSH, p, y2, x, y3, 220);
							--context:drawText (FONT2, txt, instance.parameters.cHdn, -1, x-tw, y1-th/2, x, y1+th/2 , context.LEFT+context.PATH_ELLIPSIS+context.SINGLELINE, 0);
						end
					end
				end
			end
		end
	end
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
		if last then
			local txt = string.format("Sum of H Count = %.1f | V Count = %.1f",TA["H_SUM"],TA["V_SUM"]);
			iw,ih = context:measureText (FONT3, txt, context.CENTER+context.SINGLELINE);
			context:drawText (FONT3, txt, core.rgb(128,128,128), -1, context:left() + 100, context:bottom() - 20, context:left() + 100 + iw, context:bottom() - 20 + ih, context.CENTER+context.SINGLELINE, 0);
			
			if RS < 2 then
				proccesColumnWyckoff(context,index,l,r,s);
			else
				proccesColumn(context,index,l,r,s,x1-x2);
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
		-- Proccess Horizontal
		for pos,val in pairs(TA["H"]) do 
			if val.p == index then
				local s = "%." .. digits .. "f (%.1f)";
				local txt = string.format(s,val.t ,val.r)
				local tw,th = context:measureText (FONT2, txt, context.CENTER+context.SINGLELINE);
				local p , p1 , p2 = context:positionOfBar (val.p2)
				local t4, y4 = context:pointOfPrice(val.s);
				if val.d == "UP" then
					local t1, y1 = context:pointOfPrice(val.t + BS/2);
					local t2, y2 = context:pointOfPrice(val.e);
					local t3, y3 = context:pointOfPrice(val.t);
					--if not t3 then
					--	y3 = context:top() + context:priceWidth (BS*2,0);
					--	y1 = context:top() + context:priceWidth (BS,0);
					--end 
					if isEqual(val.f ,-1) then 
						--context:drawRectangle (THF_PEN, -1, p, y2, x, y3, 150)
						--context:drawRectangle (THF_PEN, THF_BRUSH, p, y2, x, y3, 150)
						context:drawText (FONT2, txt, instance.parameters.cHf, -1, x-tw, y1-th/2, x, y1 +th/2, context.LEFT+context.PATH_ELLIPSIS+context.SINGLELINE, 0);
					elseif isEqual(val.f ,1) or isEqual(val.f ,0) then
						if isEqual(val.f ,0) then 
							--context:drawRectangle (-1, THS_BRUSH, p, y4, x, y2, 200); 
							--context:drawRectangle (THU_PEN, THU_BRUSH, p, y2, x, y3, 200)
							context:drawText (FONT2, txt, instance.parameters.cHup, -1, x-tw, y1-th/2, x, y1 +th/2, context.LEFT+context.PATH_ELLIPSIS+context.SINGLELINE, 0);
						else
							--context:drawRectangle (THU_PEN, THU_BRUSH, p, y2, x, y3, 220)
							context:drawText (FONT2, txt, instance.parameters.cHup, -1, x-tw, y1-th/2, x, y1 +th/2, context.LEFT+context.PATH_ELLIPSIS+context.SINGLELINE, 0);
						end
					end
				elseif val.d == "DN" then
					local t1, y1 = context:pointOfPrice(val.t - BS/2);
					local t2, y2 = context:pointOfPrice(val.e);
					local t3, y3 = context:pointOfPrice(val.t);
					--if not t3 then
					--	y3 = context:top() - context:priceWidth (BS*2,0);
					--	y1 = context:top() - context:priceWidth (BS,0);
					--end 
					if isEqual(val.f ,-1) then 
						--context:drawRectangle (THF_PEN, -1, p, y2, x, y3, 150)
						--context:drawRectangle (THF_PEN, THF_BRUSH, p, y2, x, y3, 150)
						context:drawText (FONT2, txt, instance.parameters.cHf, -1, x-tw, y1-th/2, x, y1+th/2 , context.LEFT+context.PATH_ELLIPSIS+context.SINGLELINE, 0);
					elseif isEqual(val.f ,1) or isEqual(val.f ,0) then
						if isEqual(val.f ,0) then 
							--context:drawRectangle (-1, THS_BRUSH, p, y4, x, y2, 200);
							--context:drawRectangle (THD_PEN, THD_BRUSH, p, y2, x, y3, 200)
							context:drawText (FONT2, txt, instance.parameters.cHdn, -1, x-tw, y1-th/2, x, y1+th/2 , context.LEFT+context.PATH_ELLIPSIS+context.SINGLELINE, 0);
						else
							--context:drawRectangle (THD_PEN, THD_BRUSH, p, y2, x, y3, 220);
							context:drawText (FONT2, txt, instance.parameters.cHdn, -1, x-tw, y1-th/2, x, y1+th/2 , context.LEFT+context.PATH_ELLIPSIS+context.SINGLELINE, 0);
						end
					end
				end
			end
		end
	end
	drawTrendLines(context)
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function proccesColumnWyckoff(context,index,l,r,s)
	local o = open[index];
	if isEqual(direction[index],1) then
		if isEqual(open[index],close[index]) then
			for i = high[index] , close[index]-0.01*BS, -BS do
				t, y = context:pointOfPrice(i);
				drawRow(context,index,i,r,l,s,y,"X",colors.X,X_BRU);
			end
		else
			for i = high[index] , close[index]-0.01*BS, -BS do
				t, y = context:pointOfPrice(i);
				drawRow(context,index,i,r,l,s,y,"X",colors.X,X_BRU);
			end
			for i = open[index] , low[index]-0.01*BS, -BS do
				t, y = context:pointOfPrice(i);
				drawRow(context,index,i,r,l,s,y,"O",colors.O,O_BRU);
			end
		end
	elseif isEqual(direction[index],-1) then
		if isEqual(open[index],close[index]) then
			for i = open[index] , low[index]-0.01*BS, -BS do
				t, y = context:pointOfPrice(i);
				drawRow(context,index,i,r,l,s,y,"O",colors.O,O_BRU);
			end
		else
			for i = open[index] , low[index]-0.01*BS, -BS do
				t, y = context:pointOfPrice(i);
				drawRow(context,index,i,r,l,s,y,"O",colors.O,O_BRU);
			end
			for i = high[index] , close[index]-0.01*BS, -BS do
				t, y = context:pointOfPrice(i);
				drawRow(context,index,i,r,l,s,y,"X",colors.X,X_BRU);
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function proccesColumn(context,index,l,r,s,mx)
	local o = open[index];
	local H = context:priceWidth((BS),0);
	for i = high[index] , low[index]-0.1*BS, -BS do
		t, y = context:pointOfPrice(i);
		if isEqual(direction[index],1) then
			drawRow(context,index,i,r,l,s,y,"X",colors.X,X_BRU)
		elseif isEqual(direction[index],-1) then
			drawRow(context,index,i,r,l,s,y,"O",colors.O,O_BRU)
		end
	end
	-- Draw next Rows or Columns
	if EndOfTheDay and open:isAlive() and index == open:size() - 1 then
		local rH;
		local rL;
		rH = his.high[NOW];
		rL = his.low[NOW];
		if isEqual(direction[index],1) then
			local z = math.floor((rH - open[index]) / BS);
			-- 1. Use the high if new X can be drawn;
			if isSmaller(high[index],open[index] + z*BS) then
				z = math.floor((rH - close[index]) / BS);
				if z > 0  then
					for i = 1 , z do
						m,y =context:pointOfPrice(close[index] + i*BS);
						drawRow(context,index,i,r,l,s,y,"X",colors.N,-1)
					end
				end
			else
			-- 2. use the low if no new X can be drawn and the low triggers a reversal;
				z = math.floor((high[index] - rL) / BS);
				if z >= RS then
					z = math.floor((close[index] - rL) / BS);
					if z > 0  then
						for i = 1 , z do
							m,y =context:pointOfPrice(close[index] - i*BS);
							drawRow(context,index,i,r-mx,l-mx,s,y,"O",colors.N,-1)
						end
					end
				end
			end
		elseif isEqual(direction[index],-1)  then
			local z = math.floor((open[index] - rL) / BS);
			-- 1. Use the low if new O can be drawn;
			if low[index] > open[index] - z*BS then
				z = math.floor((close[index] - rL) / BS);
				if z > 0  then
					for i = 1 , z do
						m,y =context:pointOfPrice(close[index]-i*BS);
						drawRow(context,index,i,r,l,s,y,"O",colors.N,-1)
					end
				end
			else
			-- 2. use the high if no new O can be drawn and the high triggers a reversal;
				z = math.floor((rH - low[index]) / BS);
				if z >= RS then
					z = math.floor((rH - close[index]) / BS);
					if z > 0  then
						for i = 1 , z do
							m,y =context:pointOfPrice(close[index] + i*BS);
							drawRow(context,index,i,r-mx,l-mx,s,y,"X",colors.N,-1)
						end
					end
				end
			end
		end
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
function drawRow(context,index,price,right,left,s,y,txt,color,BRU)
	local H = context:priceWidth((BS),0);
	if instance.parameters.enTTB and PA["TTB"][index] ~= nil and isEqual(PA["TTB"][index].entry,price) and PA["TTB"][index].fin then
		if direction[index] > 0 then
			context:tooltip(left, y-H/2, right, y+H/2, "BUY - " .. PA["TTB"][index].type );
			txt = "T"
			color = colors.B;
			BRU = B_BRU;
		elseif direction[index] < 0 then
			context:tooltip(left, y-H/2, right, y+H/2, "SELL - " .. PA["TTB"][index].type );
			txt = "T"
			color = colors.S;
			BRU = S_BRU;
		end
	elseif PA["FLA"][index] ~= nil and isEqual(PA["FLA"][index].entry,price) and PA["FLA"][index].fin then
		if direction[index] > 0 then
			context:tooltip(left, y-H/2, right, y+H/2, "BUY - " .. PA["FLA"][index].type );
			txt = "F"
			color = colors.B;
			BRU = B_BRU;
		elseif direction[index] < 0 then
			context:tooltip(left, y-H/2, right, y+H/2, "SELL - " .. PA["FLA"][index].type );
			txt = "F"
			color = colors.S;
			BRU = S_BRU;
		end
	elseif PA["TRI"][index] ~= nil and isEqual(PA["TRI"][index].entry,price) and PA["TRI"][index].fin then
		if direction[index] > 0 then
			context:tooltip(left, y-H/2, right, y+H/2, "BUY - " .. PA["TRI"][index].type );
			txt = "A"
			color = colors.B;
			BRU = B_BRU;
		elseif direction[index] < 0 then
			context:tooltip(left, y-H/2, right, y+H/2, "SELL - " .. PA["TRI"][index].type );
			txt = "A"
			color = colors.S;
			BRU = S_BRU;
		end
	elseif PA["CAT"][index] ~= nil and isEqual(PA["CAT"][index].entry,price) and PA["CAT"][index].fin then
		if direction[index] > 0 then
			context:tooltip(left, y-H/2, right, y+H/2, "BUY - " .. PA["CAT"][index].type );
			txt = "C"
			color = colors.B;
			BRU = B_BRU;
		elseif direction[index] < 0 then
			context:tooltip(left, y-H/2, right, y+H/2, "SELL - " .. PA["CAT"][index].type );
			txt = "C"
			color = colors.S;
			BRU = S_BRU;
		end
	elseif PA["SHA"][index] ~= nil and isEqual(PA["SHA"][index].entry,price) and PA["SHA"][index].fin then
		if direction[index] > 0 then
			context:tooltip(left, y-H/2, right, y+H/2, "BUY - " .. PA["SHA"][index].type );
			txt = "S"
			color = colors.B;
			BRU = B_BRU;
		elseif direction[index] < 0 then
			context:tooltip(left, y-H/2, right, y+H/2, "SELL - " .. PA["SHA"][index].type );
			txt = "S"
			color = colors.S;
			BRU = S_BRU;
		end
	elseif instance.parameters.enDTB and PA["DTB"][index] ~= nil and isEqual(PA["DTB"][index].entry,price) and PA["DTB"][index].fin then
		if direction[index] > 0 then
			context:tooltip(left, y-H/2, right, y+H/2, "BUY - " .. PA["DTB"][index].type );
			txt = "D"
			color = colors.B;
			BRU = B_BRU;
		elseif direction[index] < 0 then
			context:tooltip(left, y-H/2, right, y+H/2, "SELL - " .. PA["DTB"][index].type );
			txt = "D"
			color = colors.S;
			BRU = S_BRU;
		end
	elseif TL[22].Long[index] ~= nil and TL[22].On and instance.parameters.styleTL_M ~= core.LINE_NONE then
		if isEqual(price,TL[22].Long[index]) then
			context:tooltip(left, y-H/2, right, y+H/2, "BUY - 22.5 Main Trendline break");
			txt = "L"
			color = colors.B;
			BRU = B_BRU;
		end
	elseif TL[22].Short[index] ~= nil and TL[22].On and instance.parameters.styleTL_M ~= core.LINE_NONE then
		if isEqual(price,TL[22].Short[index]) then
			context:tooltip(left, y-H/2, right, y+H/2, "SELL - 22.5 Main Trendline break");
			txt = "L"
			color = colors.S;
			BRU = S_BRU;
		end
	elseif TL[45].Long[index] ~= nil and TL[45].On and instance.parameters.styleTL_M ~= core.LINE_NONE then
		if isEqual(price,TL[45].Long[index]) then
			context:tooltip(left, y-H/2, right, y+H/2, "BUY - 45 Main Trendline break");
			txt = "L"
			color = colors.B;
			BRU = B_BRU;
		end
	elseif TL[45].Short[index] ~= nil and TL[45].On and instance.parameters.styleTL_M ~= core.LINE_NONE then
		if isEqual(price,TL[45].Short[index]) then
			context:tooltip(left, y-H/2, right, y+H/2, "SELL - 45 Main Trendline break");
			txt = "L"
			color = colors.S;
			BRU = S_BRU;
		end
	elseif nMon[index] ~= nil then
		if isEqual(nMon[index].p,price) then
			context:tooltip(left, y-H/2, right, y+H/2, win32.formatDate(high:date(index), win32.SHORT, win32.NONE))
			txt = converToASCII(nMon[index].d)
			color = colors.M;
			BRU = M_BRU;
		end
	elseif nDay[index] ~= nil then
		if isEqual(nDay[index].p,price) then
			context:tooltip(left, y-H/2, right, y+H/2, win32.formatDate(high:date(index), win32.SHORT, win32.NONE))
			txt = converToASCII(nDay[index].d)
			color = colors.D;
			BRU = D_BRU;
		end
	end	
	if instance.parameters.RowStyle == "SQ" then
		context:drawRectangle (N_PEN, BRU, left, y-H/2, right, y+H/2, 0);
		context:drawRectangle (N_PEN, BRU, (left+right)/2-1, y-1, (left+right)/2+1, y+1, 0);
	else
		context:drawText (FONT, txt, color, -1, left, y-s, right, y + s, context.CENTER+context.SINGLELINE, 0);
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function drawTrendLines(context)
	-- Trendlines
	if TL[45].On then
		for pos,val in pairs(TL[45].dn) do
			local adapt = val.ad*BS;
			local fromLevel = close[val.sPoint] + BS + adapt;
			local toLevel = (fromLevel - (val.ePoint-val.sPoint)*BS);-- + adapt;
			x1, x11, x12 = context:positionOfBar (val.sPoint)
			x2, x21, x22 = context:positionOfBar (val.ePoint)
			t, y1 = context:pointOfPrice(fromLevel);
			t, y2 = context:pointOfPrice(toLevel);
			if val.isMain and instance.parameters.styleTL_M_45 ~= core.LINE_NONE then
				context:drawLine (TL45_dn_PEN_M, x1, y1, x2, y2, 0)
			elseif val.isMain == false and instance.parameters.styleTL_S_45 ~= core.LINE_NONE then
				context:drawLine (TL45_dn_PEN_S, x1, y1, x2, y2, 0)
			end
		end
		for pos,val in pairs(TL[45].up) do
			local adapt = val.ad*BS;
			local fromLevel = close[val.sPoint] - BS - adapt;
			local toLevel = (fromLevel + (val.ePoint-val.sPoint)*BS);-- - adapt;
			x1, x11, x12 = context:positionOfBar (val.sPoint)
			x2, x21, x22 = context:positionOfBar (val.ePoint)
			t, y1 = context:pointOfPrice(fromLevel);
			t, y2 = context:pointOfPrice(toLevel);
			if val.isMain and instance.parameters.styleTL_M_45 ~= core.LINE_NONE then
				context:drawLine (TL45_up_PEN_M, x1, y1, x2, y2, 0)
			elseif val.isMain == false and instance.parameters.styleTL_S_45 ~= core.LINE_NONE then
				context:drawLine (TL45_up_PEN_S, x1, y1, x2, y2, 0)
			end
		end
	end
	if TL[22].On then
		for pos,val in pairs(TL[22].dn) do
			local fromLevel = close[val.sPoint] + BS;
			local toLevel = fromLevel - (val.ePoint-val.sPoint)*BS/2;
			x1, x11, x12 = context:positionOfBar (val.sPoint)
			x2, x21, x22 = context:positionOfBar (val.ePoint)
			t, y1 = context:pointOfPrice(fromLevel);
			t, y2 = context:pointOfPrice(toLevel);
			if val.isMain and instance.parameters.styleTL_M_22 ~= core.LINE_NONE then
				context:drawLine (TL22_dn_PEN_M, x1, y1, x2, y2, 0)
			elseif val.isMain == false and instance.parameters.styleTL_S_22 ~= core.LINE_NONE then
				context:drawLine (TL22_dn_PEN_S, x1, y1, x2, y2, 0)
			end
		end
		for pos,val in pairs(TL[22].up) do
			local fromLevel = close[val.sPoint] - BS;
			local toLevel = fromLevel + (val.ePoint-val.sPoint)*BS/2;
			x1, x11, x12 = context:positionOfBar (val.sPoint)
			x2, x21, x22 = context:positionOfBar (val.ePoint)
			t, y1 = context:pointOfPrice(fromLevel);
			t, y2 = context:pointOfPrice(toLevel);
			if val.isMain and instance.parameters.styleTL_M_22 ~= core.LINE_NONE then
				context:drawLine (TL22_up_PEN_M, x1, y1, x2, y2, 0)
			elseif val.isMain == false and instance.parameters.styleTL_S_22 ~= core.LINE_NONE then
				context:drawLine (TL22_up_PEN_S, x1, y1, x2, y2, 0)
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function forcastSignal(index,context)
	local entry = -1;
	local p1 , p11 , p12 = context:positionOfBar (index-2);
	local p2 , p21 , p22 = context:positionOfBar (index);
	local period = index;
	if instance.parameters.enTTB and PA["TTB"][index] ~= nil and PA["TTB"][index].fin == false then
		entry = PA["TTB"][index].entry;
	end
	if instance.parameters.enDTB and PA["DTB"][index] ~= nil and PA["DTB"][index].fin == false then
		entry = PA["DTB"][index].entry;
	end
	if entry < 0 then return end;
	if period > 7 then
		local i = 0;
		local t = 0;
		local h = high[period-1];
		local l = low[period-1];
		local pos = 0;
		for i = 0, index  do
			if direction[period] > 0 then
				if isGreater(low[period-i],l) then
					l = low[period-i];
				end
				if isSmaller(high[period-i],h) and i > 0 then
					h = high[period-i];
				end
			elseif direction[period] < 0 then
				if isSmaller(high[period-i],h) then
					h = high[period-i];
				end
				if isGreater(low[period-i],l) and i > 0 then
					l = low[period-i];
				end
			end
			if isSmaller(high[period-i],l) or isGreater(low[period-i],h) then
				t = i*BS*RS;
				pos = i-1;
				if direction[period] > 0 then
					t = mathex.min(low, period - i + 1, period) + t;
					if  t > high[period] then
						local risk = (t-entry) / (entry-(mathex.min(low, period - i + 1, period)-BS));
						if risk < instance.parameters.tHMinRatio then break; end
						local t1, y1 = context:pointOfPrice(entry);
						local t2, y2 = context:pointOfPrice(t);
						local t3, y3 = context:pointOfPrice(mathex.min(low, period - i + 1, period)-BS);
						context:drawLine (PE_PEN, p11, y1, p22, y1, 0)
						context:drawLine (PB_PEN, p11, y2, p22, y2, 0)
						context:drawLine (PS_PEN, p11, y3, p22, y3, 0)
						break ;
					end
				elseif direction[period] < 0 then
					t = mathex.max(high, period - i + 1, period) - t;
					if  t < low[period] then
						local risk = (entry-t) / ((mathex.max(high, period - i + 1, period)+BS)-entry);
						if risk < instance.parameters.tHMinRatio then break; end
						local t1, y1 = context:pointOfPrice(entry);
						local t2, y2 = context:pointOfPrice(t);
						local t3, y3 = context:pointOfPrice(mathex.max(high, period - i + 1, period)+BS);
						context:drawLine (PE_PEN, p11, y1, p22, y1, 0)
						context:drawLine (PB_PEN, p11, y2, p22, y2, 0)
						context:drawLine (PS_PEN, p11, y3, p22, y3, 0)
						break ;
					end
				end
				break;
			end
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

-- Strategy and Alerts
function verifyStrategy_Server()
	-- Check Strategy Status 
	if not isStrategyStarted then
		-- Strategy is not running, so wait until it is.
		local i, n;
		my_Strategy = nil;
		--Search for the Pipe Server
		for i = 0, interop:size() - 1, 1 do
			n = interop:instance(i);
			if n:name() == "PF_STRATEGY_SERVER" .. "(" .. instance.parameters.Magic .. ")" and interop:isalive(n) then
				my_Strategy = n;
				sendStatus("OK - Strategy is running");
				isStrategyStarted = true;
				return ;
			end
		end
		if my_Strategy ==  nil then
			-- Didn't find the 
			sendStatus("Upps - Strategy is not running - Check if Strategy is running and Magic String match");
		end
	else
		-- Strategy is running
		-- Check if Strategy is Still Running
		if interop:isalive(my_Strategy) then
			sendStatus("OK - Strategy is running");
			-- Pipe Server is running so send your request here
			---------------------------------------------------
		else
			sendStatus("Upps is no longer running - Trading will not possible");
			isStrategyStarted = false;
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------
-- Send Status ------------------------------------------------------------------------------------------------------------------
function sendStatus(txt)
    core.host:execute ("setStatus", txt);
end

function SendAlert(Text,entry)
	if loading == true then return; end
	if instance.parameters.ShowAlert == false then return; end
	verifyStrategy_Server();
	if my_Strategy ~= nil then
		if interop:isalive(my_Strategy) then
			-- Pipe Server is running so send your request here
			---------------------------------------------------
			my_Strategy:invoke("Alert",instrument,entry,Text,his.close:date(NOW));
		end
	end
end