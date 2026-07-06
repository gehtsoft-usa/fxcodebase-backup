--[[
	Point and Figure pure Version
	Only draws Point and Figure without any Signals , Trendlines ,Targets and Days.
	Source PaF_View_V2.3
	

]]--


function Init()
    indicator:name("Point & Figure Chart");
    indicator:description("Beta View Indicator Point and Figure Chart");
    indicator:requiredSource(core.Tick);
    indicator:type(core.View);
	-- Point and Figure source settings
	indicator.parameters:addGroup("PF - Instrument");
	indicator.parameters:addString("instrument", "Instrument", "", "GBP/USD");
    indicator.parameters:setFlag("instrument", core.FLAG_INSTRUMENTS);
    indicator.parameters:addBoolean("type", "Bid or Ask", "No description", true);
    indicator.parameters:setFlag("type", core.FLAG_BIDASK);
    indicator.parameters:addString(   "TF", "TF", "Source Time frame ('m1', 'm5', etc.)", "m1");
    indicator.parameters:setFlag(   "TF", core.FLAG_PERIODS);
    indicator.parameters:addDate("from", "Date From", "", -30);
	-- Point and Figure calculation settings
	indicator.parameters:addGroup("PF - Calculation");
    indicator.parameters:addInteger("BS", "Box Size (in pips)", "No description", 5);
    indicator.parameters:addInteger("RS", "Reversal Count (in boxes)", "No description", 3);
    indicator.parameters:addBoolean("Ignore", "Ignore High/Low", "No description", false);
    indicator.parameters:addBoolean("EndOfTheDay", "End of The Day", "If Enabled, drawing only at new source candle", true);
	-- Point and Figure Drawing settings
	indicator.parameters:addGroup("PF - Style");
	indicator.parameters:addString("Fonts", "Fonts", "", "Consolas");
	indicator.parameters:addColor("Bull", "Color of X's", "", core.rgb(0, 128, 255));
	indicator.parameters:addColor("Bear", "Color of O's", "", core.rgb(192,192,192) );
	indicator.parameters:addBoolean("bDay", "Show Days", "No description", false);
	indicator.parameters:addColor("cDay", "Color of Day", "", core.rgb(255, 128, 0));
	indicator.parameters:addBoolean("bMonth", "Show Month", "No description", false);
	indicator.parameters:addColor("cMonth", "Color of Month", "", core.rgb(255, 0, 128) );
	indicator.parameters:addColor("cNext", "Color of Next", "", core.rgb(255, 255, 0) );
	
	indicator.parameters:addGroup("PF - TrendLines")
	indicator.parameters:addBoolean("TL45", "TL 45 degree", "No description", true);
    indicator.parameters:addColor("TLu45_color", "Color of TLu45", "Color of TLu45", core.rgb(0, 128, 128));
    indicator.parameters:addColor("TLd45_color", "Color of TLd45", "Color of TLd45", core.rgb(255, 128, 128));
	indicator.parameters:addBoolean("TL22", "TL 22.5 degree", "No description", true);
    indicator.parameters:addColor("TLu22_color", "Color of TLu22", "Color of TLu22", core.rgb(128, 255, 255));
    indicator.parameters:addColor("TLd22_color", "Color of TLd22", "Color of TLd22", core.rgb(255, 255, 128));
	indicator.parameters:addBoolean("useLines", "Lines instead of +", "No description", true);
	indicator.parameters:addBoolean("useAdaptive", "Adaptive Mode", "No description", false);
	indicator.parameters:addInteger("widthTL", "TL Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleTL", "TL Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleTL", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("PF - Pattern");
	indicator.parameters:addBoolean("enDTB", "Double Top and Bottom", "Enable Double Top or Bottom", true);
	indicator.parameters:addBoolean("enTTB", "Triple Top and Bottom", "Enable Triple Top or Bottom", true);
	indicator.parameters:addBoolean("enShakeOut", "ShakeOut", "Enable Bull or Bear ShakeOut", true);
	indicator.parameters:addBoolean("enCatapult", "Catapult", "Enable Bull or Bear Catapult", true);
	indicator.parameters:addBoolean("enTriangle", "Triangle", "Enable Bull or Bear Triangle", true);
	indicator.parameters:addInteger("pAdiv", "Triangle Divergence", "0 == Symmetrical", 4, 0, 10);
	indicator.parameters:addInteger("pAbearBox", "Triangle Bear MinBoxSize", "0 == TOP/Bottoms , 2 == 45", 0, 0, 10);
	indicator.parameters:addInteger("pAbullBox", "Triangle Bull MinBoxSize", "0 == TOP/Bottoms , 2 == 45", 0, 0, 10);
	indicator.parameters:addBoolean("enFlag", "Flag", "Enable Bull or Bear Signal Reversed", true);
	indicator.parameters:addColor("Long_color", "Color of Bull", "Color of Bull", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Short_color", "Color of Bear", "Color of Bear", core.rgb(255, 0, 0));
	indicator.parameters:addBoolean("enPatternLine", "Draw Lines", "No description", false);
	indicator.parameters:addInteger("widthP", "Pattern Line Width", "", 2, 1, 5);
    indicator.parameters:addInteger("styleP", "Pattern Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleP", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("PF - Targets");
	indicator.parameters:addBoolean("Vertical", 	"Show Vertical Count", "Show Vertical Count" ,  true);
	indicator.parameters:addInteger("vQR", "Maximum Qualifying Range", "", 2, 0, 100);
	indicator.parameters:addColor("cVup", "Color of Vertical UpSide Target", "", 	core.rgb(0,64,64) );
	indicator.parameters:addColor("cVdn", "Color of Vertical DownSide Target", "", 	core.rgb(64,0,128) );
	indicator.parameters:addColor("cEstablished", 	"Color of Established", "When count is extablished", 		core.rgb(128,128,128) );
	indicator.parameters:addBoolean("Horizontal", 	"Show Horizontal Count", "Show Horizontal Count" ,  true);
	indicator.parameters:addDouble("tHMinRatio", "Horizontal Count min Ratio", "min 0.1 max 100", 0.3, 0.1, 100);
	indicator.parameters:addColor("cHup", "Color of Horizontal UpSide Target", "", 	core.rgb(0,255,64) );
	indicator.parameters:addColor("cHdn", "Color of Horizontal DownSide Target", "", 	core.rgb(255,0,255) );
	indicator.parameters:addColor("cHf", "Color of Horizontal Failed Target", "", 	core.rgb(128,128,128) );
	
	indicator.parameters:addGroup("PF - Trading");
	indicator.parameters:addString("Magic", "Magic String", "No description", "MyID");
    indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);

end

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
local newDay;
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
local col = {X,O,Day,Month,Next};
-- Trendline
local TL = {};
-- Pattern
local pattern = {};
local Patter = {DTB}
-- Tragets
local T = {H,V};
local Targets = {H,V,Hsum=0,Vsum=0};
-- dashdoard
local Signal={L,C,F};
-- Strategy
local isStrategyStarted = false;
local my_Strategy = nil;


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
    history = core.host:execute("getHistory", 1000, instrument, frame, math.floor(instance.parameters.from), 0, bid);
	core.host:execute("setStatus", "Loading History");
    

    open 		= instance:addStream("open", core.Line, name .. ".open", "open", 0,0,0);
    high 		= instance:addStream("high", core.Line, name .. ".high", "high", 0,0,0);
    low 		= instance:addStream("low", core.Line, name .. ".low", "low", 0,0,0);
    close 		= instance:addStream("close", core.Line, name .. ".close", "close", 0,0,0);
    volume 		= instance:addInternalStream(0, 0);
	tvolume 	= instance:addStream("tvolume", core.Line, name .. ".tvolume", "tvolume", 0,0,0);
	sdate 		= instance:addInternalStream(0, 0);
	direction	= instance:addInternalStream(0, 0);
	newDay 		= instance:addInternalStream(0, 0);
	newMonth 	= instance:addInternalStream(0, 0);
	
    instance:createCandleGroup("pf", "pf", open, high, low, close, tvolume, "PF", false);
	
    open:setVisible(false);
	high:setVisible(false);
    low:setVisible(false);
    close:setVisible(false);
	volume:setVisible(false);
    instance:ownerDrawn(true);
	
	-- TrendLines
	TL[45] = {	Enable		= instance.parameters.TL45,
				Lines       = instance.parameters.useLines,
				up			= instance:addStream("TL45up", core.Line, name .. ".TL45up", "TL45up", instance.parameters.TLu45_color,0,0),
				dn			= instance:addStream("TL45dn", core.Line, name .. ".TL45dn", "TL45dn", instance.parameters.TLd45_color,0,0)};
	TL[45].up:setStyle(instance.parameters.styleTL);
	TL[45].up:setWidth(instance.parameters.widthTL);
	TL[45].dn:setStyle(instance.parameters.styleTL);
	TL[45].dn:setWidth(instance.parameters.widthTL);
	if TL[45].Enable == false or TL[45].Lines == false then
		TL[45] = {	Enable		= instance.parameters.TL45,
					Lines       = instance.parameters.useLines,
					up			= instance:addInternalStream(0, 0),
					dn			= instance:addInternalStream(0, 0)};
	end
	TL[22] = {	Enable		= instance.parameters.TL22,
				Lines       = instance.parameters.useLines,
				up			= instance:addStream("TL22up", core.Line, name .. ".TL22up", "TL22up", instance.parameters.TLu22_color,0,0),
				dn			= instance:addStream("TL22dn", core.Line, name .. ".TL22dn", "TL22dn", instance.parameters.TLd22_color,0,0)};
	TL[22].up:setStyle(instance.parameters.styleTL);
	TL[22].up:setWidth(instance.parameters.widthTL);
	TL[22].dn:setStyle(instance.parameters.styleTL);
	TL[22].dn:setWidth(instance.parameters.widthTL);
	if TL[22].Enable == false or TL[22].Lines == false then
		TL[22] = {	Enable		= instance.parameters.TL45,
					Lines       = instance.parameters.useLines,
					up			= instance:addInternalStream(0, 0),
					dn			= instance:addInternalStream(0, 0)};
	end
	-- Pattern
	Patter.DTB = {};
	Patter.TTB = {};
	Patter.CAT = {};
	Patter.SHA = {};
	Patter.TRI = {};
	pattern = {	Flag		= { Enable  = instance.parameters.enFlag,
								id    	= 25000;
								s		= instance:addInternalStream(0, 0),
								lt 		= instance:addInternalStream(0, 0),
								lb 		= instance:addInternalStream(0, 0),
								l1 		= instance:addInternalStream(0, 0),
								l2 		= instance:addInternalStream(0, 0)},								
				cBuy		= instance.parameters.Long_color,
				cSell		= instance.parameters.Short_color,
				widthP		= instance.parameters.widthP,
				styleP		= instance.parameters.styleP};
	-- Targets
	Targets.H = {};
	Targets.V = {};
	OneSecond=1/86400;
    TimerID=core.host:execute("setTimer", 1, 1)
	
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
-- Horizontal Calculation -------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
function VerifyVTargets()
	local period = open:size() - 1;
	for pos,val in pairs(Targets.V) do 
		if val.f == 0 then
			for i = val.p +1, period do
				if val.d == "UP" then
					-- Check Activation
					if high[period] >= val.e and val.a == false and val.sl == false then
						Targets.V[pos].a = true;
						Targets.V[pos].p2=period;
						break;
					end
					if low[period] <= val.s and val.sl == false then
						if val.a == false then
							table.remove(Targets.V,pos);
						else
							Targets.V[pos].f = -1;
							Targets.Vsum = Targets.Vsum + ((val.s-val.e)/point)
							Targets.V[pos].sl = true;
							break;
						end
					elseif high[period] >= val.t then
						Targets.V[pos].f = 1;
						Targets.Vsum = Targets.Vsum + ((val.t-val.e)/point)
						break;
					end
				elseif val.d == "DN" then
					-- Check Activation
					if low[period] <= val.e and val.a == false and val.sl == false then
						Targets.V[pos].a = true;
						Targets.V[pos].p2=period;
						break;
					end
					if high[period] >= val.s and val.sl == false then
						if val.a == false then
							table.remove(Targets.V,pos);
						else
							Targets.V[pos].f = -1;
							Targets.Vsum = Targets.Vsum + ((val.e-val.s)/point)
							Targets.V[pos].sl = true;
							break;
						end
					elseif low[period] <= val.t then
						Targets.V[pos].f = 1;
						Targets.Vsum = Targets.Vsum + ((val.e-val.t)/point)
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
		if direction[period] > 0 then
			-- Find Top
			if 	close[period - 2 - QR] ~= 0 and isGreaterOrEqual(close[period-2],close[period-4]) and isGreaterOrEqual(close[period-2] , close[period-6]) then
				local max1,maxpos1 = mathex.max(close,period-2 - QR + 1 , period);
				if maxpos1 == period - 2 or maxpos1 == period - 4 then
					local t = close[period-2] - volume[period-1]*BS*RS;
					local s = close[period-2] - BS;
					local e = close[period-1] - BS;
					local tbl = {t=t,e=e,s=s,d="DN",p=period-1,p2=period-1,a=false,sl = false,f=0};
					table.insert(Targets.V,tbl);
				end
			end
		-- O Column ------------------
		elseif direction[period] < 0 then 
			-- Find Bottom
			if 	close[period - 2 - QR] ~= 0 and isSmallerOrEqual(close[period-2], close[period-4]) and isSmallerOrEqual(close[period-2], close[period-6]) then
				local min1,minpos1 = mathex.min(close,period-2 - QR + 1 , period);
				if minpos1 == period - 2 or maxpos1 == period - 4 then
					local t = close[period-2] + volume[period-1]*BS*RS;
					local s = close[period-2] + BS;
					local e = close[period-1] + BS;
					local tbl = {t=t,e=e,s=s,d="UP",p=period-1,p2=period-1,a=false,sl = false,f=0};
					table.insert(Targets.V,tbl);
				end
			end
		end			
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Horizontal Calculation -------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
function VerifyHTargets()
	local period = open:size() - 1;
	for pos,val in pairs(Targets.H) do 
		if isEqual(val.f,0) then
			for i = val.p , period do
				if val.d == "UP" then
					if high[i] >= val.t then
						Targets.H[pos].f = 1
						Targets.Hsum = Targets.Hsum + ((val.t-val.e)/point)
						break;
					elseif low[i] <= val.s then
						Targets.H[pos].f = -1
						Targets.Hsum = Targets.Hsum + ((val.s-val.e)/point)
						break;
					end
				elseif val.d == "DN" then
					if low[i] <= val.t then
						Targets.H[pos].f = 1
						Targets.Hsum = Targets.Hsum + ((val.e-val.t)/point)
						break;
					elseif high[i] >= val.s then
						Targets.H[pos].f = -1
						Targets.Hsum = Targets.Hsum + ((val.e-val.s)/point)
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
		local h = high[period];
		local l = low[period];
		local pos = 0;
		for i = 0, open:size() -1  do
			if direction[period] > 0 then
			
			elseif direction[period] < 0 then
			
			end
			if isGreater(low[period-i],l) then
				l = low[period-i];
			end
			if isSmaller(high[period-i],h) then
				h = high[period-i];
			end
			if isSmaller(high[period-i],l) or isGreater(low[period-i],h) then
				t = i*BS*RS;
				pos = i-1;
				if direction[period] > 0 then
					t = mathex.min(low, period - i + 1, period) + t;
					if  t > high[period] then
						local risk = (t-entry) / (entry-(mathex.min(low, period - i + 1, period)-BS));
						if risk < instance.parameters.tHMinRatio then break; end
						local tbl = {t=t,e=entry,s=mathex.min(low, period - i + 1, period)-BS,r=risk,d="UP",p=period,p2=period-pos,f=0};
						table.insert(Targets.H,tbl);
						lastHTarget = period 
					end
				elseif direction[period] < 0 then
					t = mathex.max(high, period - i + 1, period) - t;
					if  t < low[period] then
						local risk = (entry-t) / ((mathex.max(high, period - i + 1, period)+BS)-entry);
						if risk < instance.parameters.tHMinRatio then break; end
						local tbl = {t=t,e=entry,s=mathex.max(high, period - i + 1, period)+BS,r=risk,d="DN",p=period,p2=period-pos,f=0};
						table.insert(Targets.H,tbl);
						lastHTarget = period 
					end
				end
				break;
			end
		end
	end	
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Pattern Calculation --------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
function Flag()
	local period = open:size() - 1;
	if period < 7 then 
		return; 
	end
	if pattern.Flag.Enable then
		core.host:execute ("removeLine", pattern.Flag.id+1);
	end
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Bullish ---------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	if direction[period] == 1 then
		if 	isSmaller(high[period-2],high[period-4]) and isSmaller(high[period-4],high[period-6]) and 
			isSmaller(low[period-1],low[period-3]) and isSmaller(low[period-3],low[period-5]) and isSmaller(low[period-7],low[period-1]) then
			if isGreaterOrEqual(high[period],high[period-2] + BS) then
				if pattern.Flag.Enable then
					if instance.parameters.enPatternLine then
						pattern.Flag.id = pattern.Flag.id + 1;
						core.host:execute ("drawLine", pattern.Flag.id, sdate[period-6], high[period-6], sdate[period-2], high[period-2], col.Next,pattern.styleP,pattern.widthP,"Bull Flag");
						pattern.Flag.id = pattern.Flag.id + 1;
						core.host:execute ("drawLine", pattern.Flag.id, sdate[period-5], low[period-5], sdate[period-1], low[period-1], col.Next,pattern.styleP,pattern.widthP,"Bull Flag");
						pattern.Flag.id = pattern.Flag.id + 1;
						core.host:execute ("drawLine", pattern.Flag.id, sdate[period-2], high[period-2], sdate[period], high[period-2], col.Next,pattern.styleP,pattern.widthP,"Bull Flag");
					end
					pattern.Flag.s[period] = high[period-2] + BS;
					HorizontalCount(high[period-2] + BS)
					SendAlert("Bull Flag",pattern.Flag.s[period]);
				end
			else
			
			end
		end
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Bearish ---------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	elseif direction[period] == -1 then
		if 	isGreater(low[period-2],low[period-4]) and isGreater(low[period-4],low[period-6]) and 
			isGreater(high[period-1],high[period-3]) and isGreater(high[period-3],high[period-5]) and isGreater(high[period-7],high[period-1])  then
			if isSmallerOrEqual(low[period],low[period-2] - BS) then
				if pattern.Flag.Enable then
					if instance.parameters.enPatternLine then
						pattern.Flag.id = pattern.Flag.id + 1;
						core.host:execute ("drawLine", pattern.Flag.id, sdate[period-5], high[period-5], sdate[period-1], high[period-1], col.Next,pattern.styleP,pattern.widthP,"Bear Flag");
						pattern.Flag.id = pattern.Flag.id + 1;
						core.host:execute ("drawLine", pattern.Flag.id, sdate[period-6], low[period-6], sdate[period-2], low[period-2], col.Next,pattern.styleP,pattern.widthP,"Bear Flag");
						pattern.Flag.id = pattern.Flag.id + 1;
						core.host:execute ("drawLine", pattern.Flag.id, sdate[period-2], low[period-2], sdate[period], low[period-2], col.Next,pattern.styleP,pattern.widthP,"Bear Flag");
					end
					pattern.Flag.s[period] = low[period-2] - BS;
					HorizontalCount(low[period-2] - BS)
					SendAlert("Bear Flag",pattern.Flag.s[period]);
				end
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
	if direction[period] > 0 then
		local topLine = (high[period-4] - high[period-2])/BS;
		local bottomLine = (low[period-1] - low[period-3])/BS;
		local diff = math.abs(topLine - bottomLine);
		if isEqual(topLine,0) and isEqual(bottomLine,0) then return; end
		if isGreaterOrEqual(topLine,instance.parameters.pAbearBox) and isGreaterOrEqual(bottomLine,instance.parameters.pAbullBox) and isSmallerOrEqual(diff,instance.parameters.pAdiv) then
			if isGreaterOrEqual(high[period],high[period-2] + BS) then
				if instance.parameters.enTriangle then
					local tbl = {e=high[period-2] + BS,f=true,tl= topLine,bl=bottomLine};
					Patter.TRI[period] = tbl;
					HorizontalCount(high[period-2] + BS)
					SendAlert("Bull Triangle",Patter.TRI[period].e);
				end
			else
				-- Next
			end
		end
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Bearish ---------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	elseif direction[period] < 0 then
		local topLine = (high[period-3] - high[period-1])/BS;
		local bottomLine = (low[period-2] - low[period-4])/BS;
		local diff = math.abs(topLine - bottomLine);
		if isEqual(topLine,0) and isEqual(bottomLine,0) then return; end
		if isGreaterOrEqual(topLine,instance.parameters.pAbearBox) and isGreaterOrEqual(bottomLine,instance.parameters.pAbullBox) and isSmallerOrEqual(diff,instance.parameters.pAdiv) then
			if isSmallerOrEqual(low[period],low[period-2] - BS) then
				if instance.parameters.enTriangle then
					local tbl = {e=low[period-2] - BS,f=true,tl= topLine,bl=bottomLine};
					Patter.TRI[period] = tbl;
					HorizontalCount(low[period-2] - BS)
					SendAlert("Bear Triangle",Patter.TRI[period].e);
				end
			else
				-- Next
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function Catapult()
	local period = open:size() - 1;
	if period < 24 then 
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
				if instance.parameters.enCatapult then
					local tbl = {e=high[period-2]+BS,e2=high[pos1],f=true,p1=period-2,p2=period-pos2};
					Patter.CAT[period] = tbl;
					HorizontalCount(high[period-2] + BS)
					SendAlert("Bull Catapult",Patter.CAT[period].e);
				end
			elseif isEqual(high[period-2],high[pos1]+BS) and isGreater(low[period-1],low[period-3]) then
				if instance.parameters.enCatapult then
					local tbl = {e=high[period-2]+BS,e2=high[pos1],f=false,p1=period-2,p2=period-pos2};
					Patter.CAT[period] = tbl;
				end
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
				if instance.parameters.enCatapult then
					local tbl = {e=low[period-2]-BS,e2=low[pos1],f=true,p1=period-2,p2=period-pos2};
					Patter.CAT[period] = tbl;
					HorizontalCount(low[period-2] - BS)
					SendAlert("Bear Catapult",Patter.CAT[period].e);
				end
			elseif isEqual(low[period-2],low[pos1]-BS) and isSmaller(high[period-1],high[period-3]) then
				if instance.parameters.enCatapult then
					local tbl = {e=low[period-2]-BS,e2=low[pos1],f=false,p1=period-2,p2=period-pos2};
					Patter.CAT[period] = tbl;
				end
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
			isSmaller(volume[period-3],volume[period-1]) then --and isUnEqual(TL[45].up[period],0) then
			if instance.parameters.enShakeOut then
				local tbl = {e=open[period] + (RS-1)*BS,f=true};
				Patter.SHA[period] = tbl;
				HorizontalCount(open[period] + (RS-1)*BS)
				SendAlert("Bull ShakeOut",Patter.SHA[period].e);
			end
		elseif isEqual(low[period-3],low[period-1]) and isGreaterOrEqual(volume[period-2],volume[period]-3) and
			isSmaller(volume[period-2],volume[period]) then --and isUnEqual(TL[45].dn[period],0) then
			if instance.parameters.enShakeOut then
				local tbl = {e=high[period] - BS - (RS-1)*BS,f=false};
				Patter.SHA[period] = tbl;
			end
		end
	elseif direction[period] == -1 then
		if isGreaterOrEqual(volume[period],3) and isEqual(low[period-4],low[period-2]) and isGreaterOrEqual(volume[period-3],volume[period-1]-3) and
			isSmaller(volume[period-3],volume[period-1]) then --and isUnEqual(TL[45].dn[period],0) then
			if instance.parameters.enShakeOut then
				local tbl = {e=open[period] - (RS-1)*BS,f=true};
				Patter.SHA[period] = tbl;
				HorizontalCount(open[period] - (RS-1)*BS)
				SendAlert("Bear ShakeOut",Patter.SHA[period].e);
			end
		elseif isEqual(high[period-3],high[period-1]) and isGreaterOrEqual(volume[period-2],volume[period]-3) and
			isSmaller(volume[period-2],volume[period]) then --and isUnEqual(TL[45].up[period],0) then
			if instance.parameters.enShakeOut then
				local tbl = {e=low[period] + BS + (RS-1)*BS,f=false};
				Patter.SHA[period] = tbl;
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function tripleTB()
	local period = open:size() - 1;
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
				if instance.parameters.enTTB then
					local tbl = {e=high[pos1] + BS,f=true,p1=period-pos2};
					Patter.TTB[period] = tbl;
					HorizontalCount(high[pos1] + BS)
					SendAlert("Trible Top",Patter.TTB[period].e);
				end
			elseif isGreater(low[period-1],low[period-3]) then
				if instance.parameters.enTTB then
					local tbl = {e=high[pos1] + BS,f=false,p1=period-pos2};
					Patter.TTB[period] = tbl;
				end
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
				if instance.parameters.enTTB then
					local tbl = {e=low[pos1] - BS,f=true,p1=period-pos2};
					Patter.TTB[period] = tbl;
					HorizontalCount(low[pos1] - BS)
					SendAlert("Trible Bottom",Patter.TTB[period].e);
				end
			elseif isSmaller(high[period-1],high[period-3]) then
				if instance.parameters.enTTB then
					local tbl = {e=low[pos1] - BS,f=false,p1=period-pos2};
					Patter.TTB[period] = tbl;
				end
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function doubleTB()
	local period = open:size() - 1;
	if period < 2 then 
		return; 
	end
	if Patter.DTB[period] ~= nil then
		if Patter.DTB[period].f == true then return; end
	end
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Bullish ---------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	if isEqual(direction[period],1) then
		if isGreater(high[period],high[period-2]) and isGreaterOrEqual(low[period-1],low[period-3]) then
			if instance.parameters.enDTB then
				local tbl = {e=high[period-2] + BS,f=true,p1=period-2};
				Patter.DTB[period] = tbl;
				HorizontalCount(high[period-2] + BS)
				SendAlert("Double Top",Patter.DTB[period].e);
			end
		elseif isGreaterOrEqual(low[period-1],low[period-3]) then
			if instance.parameters.enDTB then
				local tbl = {e=high[period-2] + BS,f=false,p1=period-2};
				Patter.DTB[period] = tbl;
			end
		end
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	-- Bearish ---------------------------------------------------------------------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------------------------------------------------------------------------------
	elseif isEqual(direction[period],-1) then
		if isSmaller(low[period],low[period-2]) and isSmallerOrEqual(high[period-1],high[period-3]) then
			if instance.parameters.enDTB then
				local tbl = {e=low[period-2] - BS,f=true,p1=period-2};
				Patter.DTB[period] = tbl;
				HorizontalCount(low[period-2] - BS)
				SendAlert("Double Bottom",Patter.DTB[period].e);
			end
		elseif isSmallerOrEqual(high[period-1],high[period-3]) then
			if instance.parameters.enDTB then
				local tbl = {e=low[period-2] - BS,f=false,p1=period-2};
				Patter.DTB[period] = tbl;
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
			core.drawLine (TL[45].dn, core.range(dST1_45, period) , from, dST1_45, to, period);
        elseif open[period] < close[period] and volume[period] >= minVol and volume[period-1] ~= 0 then
            uST1_45 = period - 1;
			local from = close[uST1_45] - BS;
			local to = from + (period - uST1_45)*BS;
			core.drawLine (TL[45].up, core.range(uST1_45, period) , from, uST1_45, to, period);
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
					core.drawLine (TL[45].up, core.range(uST1_45, period) , from, uST1_45, to, period);
					TL[45].up:setBreak (uST1_45, true);
				end 
				--TL[45].dn:setBreak (period, true);
				dST1_45 = nil;
				return;
			end
		end
		if uST1_45 == nil then
			core.drawLine (TL[45].dn, core.range(dST1_45, period) , from, dST1_45, to, period);
			if direction[period] < 0 and instance.parameters.useAdaptive then
				if isGreaterOrEqual(high[period-1],to+BS) then
					dST1_45 = period-1;
				end
			end
		else
			local dfrom = close[uST1_45] + BS;
			local dto = dfrom - (period - uST1_45)*BS;
			core.drawLine (TL[45].dn, core.range(dST1_45, period) , from, dST1_45, to, period);
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
					core.drawLine (TL[45].dn, core.range(dST1_45, period) , from, dST1_45, to, period);
					TL[45].dn:setBreak (dST1_45, true);
				end 
				--TL[45].up:setBreak (period, true);
				uST1_45 = nil;
				return;
			end
		end
		if dST1_45 == nil then
			core.drawLine (TL[45].up, core.range(uST1_45, period) , from, uST1_45, to, period);
			if direction[period] > 0  and instance.parameters.useAdaptive then
				if isSmallerOrEqual(low[period-1],to-BS) then
					uST1_45 = period-1;
				end
			end
		else
			local dfrom = close[dST1_45] + BS;
			local dto = dfrom - (period - dST1_45)*BS;
			core.drawLine (TL[45].up, core.range(uST1_45, period) , from, uST1_45, to, period);
			if isGreater(to,dto) then
				uST1_45 = nil;
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
local dST1_22 = nil;
local uST1_22 = nil;
function proccesTL22()
	local period = open:size() - 1
	if period < 2 or RS < 2 then return; end
	local minVol = RS + 1;
	if dST1_22 == nil and uST1_22 == nil then
		if open[period] > close[period] and volume[period] >= minVol and volume[period-1] ~= 0 then
            dST1_22 = period - 1;
			local from = close[dST1_22] + BS;
			local to = from - (period-dST1_22)*BS/2;
			core.drawLine (TL[22].dn, core.range(dST1_22, period) , from, dST1_22, to, period);
        elseif open[period] < close[period] and volume[period] >= minVol and volume[period-1] ~= 0 then
            uST1_22 = period - 1;
			local from = close[uST1_22] - BS;
			local to = from + (period - uST1_22)*BS/2;
			core.drawLine (TL[22].up, core.range(uST1_22, period) , from, uST1_22, to, period);
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
					core.drawLine (TL[22].up, core.range(uST1_22, period) , from, uST1_22, to, period);
				end 
				TL[22].dn:setBreak (period, true);
				dST1_22 = nil;
				return;
			end
		end
		if uST1_22 == nil then
			core.drawLine (TL[22].dn, core.range(dST1_22, period) , from, dST1_22, to, period);
			if direction[period] < 0 and instance.parameters.useAdaptive then
				if isGreaterOrEqual(high[period-1],to+BS/2) then
					dST1_22 = period-1;
				end
			end
		else
			local dfrom = close[uST1_22] + BS;
			local dto = dfrom - (period - uST1_22)*BS/2;
			core.drawLine (TL[22].dn, core.range(dST1_22, period) , from, dST1_22, to, period);
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
					core.drawLine (TL[22].dn, core.range(dST1_22, period) , from, dST1_22, to, period);
				end 
				TL[22].up:setBreak (period, true);
				uST1_22 = nil;
				return;
			end
		end
		if dST1_22 == nil then
			core.drawLine (TL[22].up, core.range(uST1_22, period) , from, uST1_22, to, period);
			if direction[period] > 0  and instance.parameters.useAdaptive then
				if isSmallerOrEqual(low[period-1],to-BS/2) then
					uST1_22 = period-1;
				end
			end
		else
			local dfrom = close[dST1_22] + BS;
			local dto = dfrom - (period - dST1_22)*BS/2;
			core.drawLine (TL[22].up, core.range(uST1_22, period) , from, uST1_22, to, period);
			if to > dto then
				uST1_22 = nil;
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Async Function History and Tick handling -----------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
local extending = false;
function AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 1000 then
		local first_date = history:date(history:first());
		if math.floor(first_date) > math.floor(instance.parameters.from) and extending == false and instance.parameters.TF ~= "t1" then
			core.host:execute("extendHistory", 1000, history, math.floor(instance.parameters.from), first_date);
			core.host:trace("Extend History First: " .. math.floor(first_date) .. " From: " .. math.floor(instance.parameters.from));
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
		checkNewMonthOrDay(period);
		-- TrendLines
		proccesTL45();
		proccesTL22();
		-- Pattern
		tripleTB();
		ShakeOut();
		Catapult();
		Triangle();
		Flag();
		doubleTB();
		VerifyHTargets();
		VerticalCount();
		VerifyVTargets();
	end
end
-- Calculation with one Box Reversal Count -- Wyckoff Drawing Method --
-----------------------------------------------------------------------
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
		checkNewMonthOrDay(period);
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
-- Nex Month or Day Calculation -----------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
local lastDay = 0;
local lastMonth = 0;
function checkNewMonthOrDay(sourceperiod)
	local current = open:size() - 1;
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
local THU_PEN = 4;
local THD_PEN = 5;
local THF_PEN = 6;
local THF_BRUSH = 7;
local THU_BRUSH = 8;
local THD_BRUSH = 9;
local THS_BRUSH = 10;
local FONT2	= 11;
local PB_PEN = 12;
local PS_PEN = 13;
local PB_BRUSH = 14;
local PS_BRUSH = 15;
local TVU_PEN = 16;
local TVD_PEN = 17;
local FONT3	= 18;
local PE_PEN = 19;
function Draw(stage, context)
    if stage == 2 and open:size() > 0 then

        if not init then
			context:createPen(X_PEN,            	context.SOLID, 1, col.X);
            context:createPen(O_PEN,          		context.SOLID, 1, col.O);
			context:createPen(THU_PEN,            	context.SOLID, 1, instance.parameters.cHup);
            context:createPen(THD_PEN,          	context.SOLID, 1, instance.parameters.cHdn);
			context:createPen(TVU_PEN,            	context.SOLID, 1, instance.parameters.cVup);
            context:createPen(TVD_PEN,          	context.SOLID, 1, instance.parameters.cVdn);
            context:createPen(THF_PEN,          	context.DOT, 1, instance.parameters.cHf);
			--context:createSolidBrush (THF_BRUSH, instance.parameters.cHf)
			context:createHatchBrush  (THF_BRUSH,context.DIAGCROSS, instance.parameters.cHf);
			context:createHatchBrush  (THU_BRUSH,context.DIAGCROSS, instance.parameters.cHup);
			context:createHatchBrush  (THD_BRUSH,context.DIAGCROSS, instance.parameters.cHdn);
			context:createHatchBrush  (THS_BRUSH,context.DIAGCROSS, core.rgb(255,0,0))
			context:createPen(PB_PEN,          	context.SOLID, instance.parameters.widthP, instance.parameters.Long_color);
            context:createPen(PS_PEN,          	context.SOLID, instance.parameters.widthP, instance.parameters.Short_color);
            context:createPen(PE_PEN,          	context.SOLID, instance.parameters.widthP, instance.parameters.cNext);
			context:createFont (FONT3, instance.parameters.Fonts, 0, context:pointsToPixels (8), 0);
			--context:createHatchBrush  (PB_BRUSH,context.DIAGCROSS, instance.parameters.Long_color);
			PB_BRUSH = -1;
			--context:createHatchBrush  (PS_BRUSH,context.DIAGCROSS, instance.parameters.Short_color);
			PS_BRUSH = -1;
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
			if cellW*0.75 > cellH*0.75 then
				context:createFont (FONT2, instance.parameters.Fonts, 0, cellH*0.75, 0);
			else
				context:createFont (FONT2, instance.parameters.Fonts, 0, cellW*0.75, 0);
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
		end
		-- Proccess Vertical
		for pos,val in pairs(Targets.V) do 
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
		for pos,val in pairs(Targets.H) do 
			if val.p == index then
				local s = "%." .. digits .. "f (%.1f)";
				local txt = string.format(s,val.t ,val.r)
				local tw,th = context:measureText (FONT2, txt, context.CENTER+context.SINGLELINE);
				local p , p1 , p2 = context:positionOfBar (val.p2)
				local t, y4 = context:pointOfPrice(val.s);
				if val.d == "UP" then
					local t, y1 = context:pointOfPrice(val.t + BS/2);
					local t, y2 = context:pointOfPrice(val.e);
					local t, y3 = context:pointOfPrice(val.t);
					if isEqual(val.f ,-1) then 
						context:drawRectangle (THF_PEN, THF_BRUSH, p, y2, x, y3, 200)
						context:drawText (FONT2, txt, instance.parameters.cHf, -1, x-tw, y1-th/2, x, y1 +th/2, context.LEFT+context.PATH_ELLIPSIS+context.SINGLELINE, 0);
					elseif isEqual(val.f ,1) or isEqual(val.f ,0) then
						context:drawRectangle (THU_PEN, THU_BRUSH, p, y2, x, y3, 200)
						context:drawRectangle (-1, THS_BRUSH, p, y4, x, y2, 200)
						context:drawText (FONT2, txt, instance.parameters.cHup, -1, x-tw, y1-th/2, x, y1 +th/2, context.LEFT+context.PATH_ELLIPSIS+context.SINGLELINE, 0);
					end
				elseif val.d == "DN" then
					local t, y1 = context:pointOfPrice(val.t - BS/2);
					local t, y2 = context:pointOfPrice(val.e);
					local t, y3 = context:pointOfPrice(val.t);
					if isEqual(val.f ,-1) then 
						context:drawRectangle (THF_PEN, THF_BRUSH, p, y2, x, y3, 200)
						context:drawText (FONT2, txt, instance.parameters.cHf, -1, x-tw, y1-th/2, x, y1+th/2 , context.LEFT+context.PATH_ELLIPSIS+context.SINGLELINE, 0);
					elseif isEqual(val.f ,1) or isEqual(val.f ,0) then
						context:drawRectangle (THD_PEN, THD_BRUSH, p, y2, x, y3, 200)
						context:drawRectangle (-1, THS_BRUSH, p, y4, x, y2, 200)
						context:drawText (FONT2, txt, instance.parameters.cHdn, -1, x-tw, y1-th/2, x, y1+th/2 , context.LEFT+context.PATH_ELLIPSIS+context.SINGLELINE, 0);
					end
				end
			end
		end
		local v = open[index];
		if last then
			if RS < 2 then
				--proccesColumnWyckoff(context,index,l,r,s);
			else
				for i = high[index] , low[index]-0.1*BS, -BS do
					proccesPattern(index,i,context);
				end
				--proccesColumnNext(context,index,l,r,s,x1-x2);
			end
		else
			if index > 1 then
				if RS < 2 then
					--proccesColumnWyckoff(context,index,l,r,s);
				else
					for i = high[index] , low[index]-0.1*BS, -BS do
						proccesPattern(index,i,context);
					end
				end
			end
		end
		-- TrendLines
		if TL[45].Enable and instance.parameters.useLines == false and isEqual(TL[45].up[index],0) == false and isSmaller(TL[45].up[index],low[index]) then
			local t1, y1 = context:pointOfPrice(TL[45].up[index]);
			context:drawText (1, "+", instance.parameters.TLu45_color, -1, l, y1-s, r, y1 + s, context.CENTER+context.SINGLELINE, 0);
		end
		if TL[45].Enable and instance.parameters.useLines == false and isEqual(TL[45].dn[index],0) == false and isGreater(TL[45].dn[index],high[index]) then
			local t1, y1 = context:pointOfPrice(TL[45].dn[index]);
			context:drawText (1, "+", instance.parameters.TLd45_color, -1, l, y1-s, r, y1 + s, context.CENTER+context.SINGLELINE, 0);
		end
		if TL[22].Enable and instance.parameters.useLines == false and isEqual(TL[22].up[index],0) == false and isSmaller(TL[22].up[index],low[index]) then
			local t1, y1 = context:pointOfPrice(TL[22].up[index]);
			context:drawText (1, "+", instance.parameters.TLu22_color, -1, l, y1-s, r, y1 + s, context.CENTER+context.SINGLELINE, 0);
		end
		if TL[22].Enable and instance.parameters.useLines == false and isEqual(TL[22].dn[index],0) == false and isGreater(TL[22].dn[index],high[index]) then
			local t1, y1 = context:pointOfPrice(TL[22].dn[index]);
			context:drawText (1, "+", instance.parameters.TLd22_color, -1, l, y1-s, r, y1 + s, context.CENTER+context.SINGLELINE, 0);
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
		local v = open[index];
		if last then
			local txt = string.format("Sum of H Count = %.1f | V Count = %.1f",Targets.Hsum,Targets.Vsum);
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
		-- TrendLines
		if TL[45].Enable and instance.parameters.useLines == false and isEqual(TL[45].up[index],0) == false and isSmaller(TL[45].up[index],low[index]) then
			local t1, y1 = context:pointOfPrice(TL[45].up[index]);
			context:drawText (1, "+", instance.parameters.TLu45_color, -1, l, y1-s, r, y1 + s, context.CENTER+context.SINGLELINE, 0);
		end
		if TL[45].Enable and instance.parameters.useLines == false and isEqual(TL[45].dn[index],0) == false and isGreater(TL[45].dn[index],high[index]) then
			local t1, y1 = context:pointOfPrice(TL[45].dn[index]);
			context:drawText (1, "+", instance.parameters.TLd45_color, -1, l, y1-s, r, y1 + s, context.CENTER+context.SINGLELINE, 0);
		end
		if TL[22].Enable and instance.parameters.useLines == false and isEqual(TL[22].up[index],0) == false and isSmaller(TL[22].up[index],low[index]) then
			local t1, y1 = context:pointOfPrice(TL[22].up[index]);
			context:drawText (1, "+", instance.parameters.TLu22_color, -1, l, y1-s, r, y1 + s, context.CENTER+context.SINGLELINE, 0);
		end
		if TL[22].Enable and instance.parameters.useLines == false and isEqual(TL[22].dn[index],0) == false and isGreater(TL[22].dn[index],high[index]) then
			local t1, y1 = context:pointOfPrice(TL[22].dn[index]);
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
		local txt,color = checkRow(index,i,o,context);
		context:drawText (FONT, txt, color, -1, l, y-s, r, y + s, context.CENTER+context.SINGLELINE, 0);
	end
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
						context:drawText (1, "X", col.Next, -1, l, y-s, r, y + s, context.CENTER+context.SINGLELINE, 0);
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
							context:drawText (1, "O", col.Next, -1, l-mx, y-s, r-mx, y + s, context.CENTER+context.SINGLELINE, 0);
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
						context:drawText (1, "O", col.Next, -1, l, y-s, r, y + s, context.CENTER+context.SINGLELINE, 0);
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
							context:drawText (1, "X", col.Next, -1, l-mx, y-s, r-mx, y + s, context.CENTER+context.SINGLELINE, 0);
						end
					end
				end
			end
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function proccesPattern(index,i,context)
	-- Pattern
	-- Shakeout
	if Patter.SHA[index] ~= nil then
		if isEqual(Patter.SHA[index].e,i) and Patter.SHA[index].f == true then
			local p1 , p11 , p12 = context:positionOfBar (index);
			local p2 , p21 , p22 = context:positionOfBar (index-2);
			local p3 , p31 , p32 = context:positionOfBar (index-4);
			local p4 , p41 , p42 = context:positionOfBar (index-3);
			if isEqual(direction[index],1) then
				if instance.parameters.enPatternLine then
					local t11, y11 = context:pointOfPrice(high[index-4]+BS/2);
					local t12, y12 = context:pointOfPrice(high[index-4]-BS/2);
					local t21, y21 = context:pointOfPrice(low[index-3]-BS/2);
					local t22, y22 = context:pointOfPrice(low[index-3]+BS/2);
					context:drawRectangle (PB_PEN, PB_BRUSH, p31, y11, p22, y12, 155)
					context:drawRectangle (PB_PEN, PB_BRUSH, p41, y21, p12, y22, 155)
				end
				return;
			elseif isEqual(direction[index],-1)  then
				if instance.parameters.enPatternLine then
					local t11, y11 = context:pointOfPrice(low[index-4]+BS/2);
					local t12, y12 = context:pointOfPrice(low[index-4]-BS/2);
					local t21, y21 = context:pointOfPrice(high[index-3]-BS/2);
					local t22, y22 = context:pointOfPrice(high[index-3]+BS/2);
					context:drawRectangle (PS_PEN, PS_BRUSH, p31, y11, p22, y12, 155);
					context:drawRectangle (PS_PEN, PS_BRUSH, p41, y21, p12, y22, 155)
				end
				return ;
			end
		end
	end
	-- Catapult
	if Patter.CAT[index] ~= nil then
		if isEqual(Patter.CAT[index].e,i) and Patter.CAT[index].f == true then
			local p1 , p11 , p12 = context:positionOfBar (Patter.CAT[index].p1);
			local p2 , p21 , p22 = context:positionOfBar (index);
			local p3 , p31 , p32 = context:positionOfBar (Patter.CAT[index].p2);
			if isEqual(direction[index],1) then
				if instance.parameters.enPatternLine then
					local t11, y11 = context:pointOfPrice(Patter.CAT[index].e-BS/2);
					local t12, y12 = context:pointOfPrice(Patter.CAT[index].e-BS-BS/2);
					local t21, y21 = context:pointOfPrice(Patter.CAT[index].e2+BS/2);
					local t22, y22 = context:pointOfPrice(Patter.CAT[index].e2-BS/2);
					context:drawRectangle (PB_PEN, PB_BRUSH, p11, y11, p22, y12, 155);
					context:drawRectangle (PB_PEN, PB_BRUSH, p31, y21, p12, y22, 155);
				end
				return ;
			elseif isEqual(direction[index],-1)  then
				if instance.parameters.enPatternLine then
					local t1, y11 = context:pointOfPrice(Patter.CAT[index].e+BS+BS/2);
					local t2, y12 = context:pointOfPrice(Patter.CAT[index].e+BS/2);
					local t21, y21 = context:pointOfPrice(Patter.CAT[index].e2+BS/2);
					local t22, y22 = context:pointOfPrice(Patter.CAT[index].e2-BS/2);
					context:drawRectangle (PS_PEN, PS_BRUSH, p11, y11, p22, y12, 155);
					context:drawRectangle (PS_PEN, PS_BRUSH, p31, y21, p12, y22, 155);
				end
				return ;
			end
		end
	end
	-- Triple Top or Bottom
	if Patter.TTB[index] ~= nil then
		local p1 , p11 , p12 = context:positionOfBar (Patter.TTB[index].p1);
		local p2 , p21 , p22 = context:positionOfBar (index);
		if isEqual(Patter.TTB[index].e,i) and Patter.TTB[index].f == true then
			if isEqual(direction[index],1) then
				if instance.parameters.enPatternLine then
					local t, y1 = context:pointOfPrice(Patter.TTB[index].e-BS/2);
					local t, y2 = context:pointOfPrice(Patter.TTB[index].e-BS-BS/2);
					context:drawRectangle (PB_PEN, PB_BRUSH, p11, y1, p22, y2, 155)
				end
				return ;
			elseif isEqual(direction[index],-1)  then
				if instance.parameters.enPatternLine then
					local t, y1 = context:pointOfPrice(Patter.TTB[index].e+BS+BS/2);
					local t, y2 = context:pointOfPrice(Patter.TTB[index].e+BS/2);
					context:drawRectangle (PS_PEN, PS_BRUSH, p11, y1, p22, y2, 155);
				end
				return ;
			end
		elseif index == open:size() - 1 and Patter.TTB[index].f == false then
			forcastSignal(index,context,Patter.TTB[index].e)
		end
	end
	if Patter.TRI[index] ~= nil then
		if isEqual(Patter.TRI[index].e,i) and Patter.TRI[index].f == true then
			local p1 , p11 , p12 = context:positionOfBar (index-4);
			local p2 , p21 , p22 = context:positionOfBar (index);
			if isEqual(direction[index],1) then
				if instance.parameters.enPatternLine then
					local points = ownerdraw_points.new();
					local t1, y1 = context:pointOfPrice(high[index-4]+BS/2);
					local t2, y2 = context:pointOfPrice(high[index-2]+BS/2);
					local t3, y3 = context:pointOfPrice(low[index-1]-BS/2);
					local t4, y4 = context:pointOfPrice(low[index-3]-BS/2);
					points:add(p1,y1)
					points:add(p2,y2)
					points:add(p2,y3)
					points:add(p1,y4)
					context:drawPolygon (PB_PEN, PB_BRUSH, points, 155)
				end
				return ;
			elseif isEqual(direction[index],-1)  then
				if instance.parameters.enPatternLine then
					local points = ownerdraw_points.new();
					local t1, y1 = context:pointOfPrice(high[index-3]+BS/2);
					local t2, y2 = context:pointOfPrice(high[index-1]+BS/2);
					if high[index-3] ~= high[index-1] then
						t1, y1 = context:pointOfPrice(high[index-3]+BS+BS/2);
						t2, y2 = context:pointOfPrice(high[index-1]+BS/2);
					end
					local t3, y3 = context:pointOfPrice(low[index-2]-BS/2);
					local t4, y4 = context:pointOfPrice(low[index-4]-BS/2);
					points:add(p1,y1)
					points:add(p2,y2)
					points:add(p2,y3)
					points:add(p1,y4)
					context:drawPolygon (PS_PEN, PS_BRUSH, points, 155)
				end
				return ;
			end
		end
	end
	if isEqual(pattern.Flag.s[index],i) then 			-- Flag
		if isEqual(direction[index],1) then
			return ;
		elseif isEqual(direction[index],-1)  then
			return ;
		end
	end
	-- Double Top or Bottom
	if Patter.DTB[index] ~= nil then
		local p1 , p11 , p12 = context:positionOfBar (Patter.DTB[index].p1);
		local p2 , p21 , p22 = context:positionOfBar (index);
		if isEqual(Patter.DTB[index].e,i) and Patter.DTB[index].f == true then
			if isEqual(direction[index],1) then
				if instance.parameters.enPatternLine then
					local t, y1 = context:pointOfPrice(Patter.DTB[index].e-BS/2);
					local t, y2 = context:pointOfPrice(Patter.DTB[index].e-BS-BS/2);
					context:drawRectangle (PB_PEN, PB_BRUSH, p11, y1, p22, y2, 155);
				end
				return ;
			elseif isEqual(direction[index],-1)  then
				if instance.parameters.enPatternLine then
					local t, y1 = context:pointOfPrice(Patter.DTB[index].e+BS+BS/2);
					local t, y2 = context:pointOfPrice(Patter.DTB[index].e+BS/2);
					context:drawRectangle (PS_PEN, PS_BRUSH, p11, y1, p22, y2, 155);
				end
				return ;
			end
		elseif index == open:size() - 1 and Patter.DTB[index].f == false then
			forcastSignal(index,context,Patter.DTB[index].e)
		end
	end
end
-------------------------------------------------------------------------------------------------------------------------------------------------------
function forcastSignal(index,context,entry)
	local p1 , p11 , p12 = context:positionOfBar (index-2);
	local p2 , p21 , p22 = context:positionOfBar (index);
	local period = index;
	if period > 7 then
		local i = 0;
		local t = 0;
		local h = high[period];
		local l = low[period];
		local pos = 0;
		for i = 0, index  do
			if isGreater(low[period-i],l) then
				l = low[period-i];
			end
			if isSmaller(high[period-i],h) then
				h = high[period-i];
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
function checkRow(index,i,o,context)
	-- Pattern
	-- Shakeout
	if Patter.SHA[index] ~= nil then
		if isEqual(Patter.SHA[index].e,i) and Patter.SHA[index].f == true then
			if isEqual(direction[index],1) then
				return "S",pattern.cBuy ;
			elseif isEqual(direction[index],-1)  then
				return "S",pattern.cSell;
			end
		end
	end
	-- Catapult
	if Patter.CAT[index] ~= nil then
		if isEqual(Patter.CAT[index].e,i) and Patter.CAT[index].f == true then
			if isEqual(direction[index],1) then
				return "C",pattern.cBuy ;
			elseif isEqual(direction[index],-1)  then
				return "C",pattern.cSell;
			end
		end
	end
	-- Triple Top or Bottom
	if Patter.TTB[index] ~= nil then
		if isEqual(Patter.TTB[index].e,i) and Patter.TTB[index].f == true then
			if isEqual(direction[index],1) then
				return "T",pattern.cBuy ;
			elseif isEqual(direction[index],-1)  then
				return "T",pattern.cSell;
			end
		end
	end
	if Patter.TRI[index] ~= nil then
		if isEqual(Patter.TRI[index].e,i) and Patter.TRI[index].f == true then
			if isEqual(direction[index],1) then
				return "A",pattern.cBuy ;
			elseif isEqual(direction[index],-1)  then
				return "A",pattern.cSell;
			end
		end
	end
	if isEqual(pattern.Flag.s[index],i) then 			-- Flag
		if isEqual(direction[index],1) then
			return "F",pattern.cBuy ;
		elseif isEqual(direction[index],-1)  then
			return "F",pattern.cSell;
		end
	end
	-- Double Top or Bottom
	if Patter.DTB[index] ~= nil then
		if isEqual(Patter.DTB[index].e,i) and Patter.DTB[index].f == true then
			if isEqual(direction[index],1) then
				return "D",pattern.cBuy ;
			elseif isEqual(direction[index],-1)  then
				return "D",pattern.cSell;
			end
		end
	end
	-- Trendline
	if instance.parameters.useLines == false then
		if TL[45].Enable then
			if isEqual(TL[45].dn[index],i) then
				return "+",instance.parameters.TLd45_color;
			elseif isEqual(TL[45].up[index],i) then
				return "+",instance.parameters.TLu45_color;
			end
		elseif TL[22].Enable then
			if isEqual(TL[22].dn[index],i) then
				return "+",instance.parameters.TLd22_color;
			elseif isEqual(TL[22].up[index],i) then
				return "+",instance.parameters.TLu22_color;
			end
		end
	end
	-- Normal Proccess no pattern no trendline no other thinks
	local mVol, mNum = math.modf (newMonth[index]);
	local dVol, dNum = math.modf (newDay[index]);
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