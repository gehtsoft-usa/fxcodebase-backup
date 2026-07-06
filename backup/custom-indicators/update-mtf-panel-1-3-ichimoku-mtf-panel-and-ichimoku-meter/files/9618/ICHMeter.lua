-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Ichimoku Signal Panel V1.0");
    indicator:description("Ichimoku Infopanel Signal");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Custom Ichimoku");

    indicator.parameters:addInteger("X", "TenkanSen", "No description", 9);
    indicator.parameters:addInteger("Y", "KijunSen", "No description", 26);
    indicator.parameters:addInteger("Z", "SenkoSpan", "No description", 52);
    indicator.parameters:addInteger("lSS", "LotsForStrongSignal", "No description", 3);
    indicator.parameters:addInteger("las", "LotsForAvarageSignal", "No description", 2);
    indicator.parameters:addInteger("lwa", "LotsForWeakSignal", "No description", 1);

    indicator.parameters:addGroup("Graphics");
	indicator.parameters:addString("Pos", "Position of the Panel", "", "TopRight");
    indicator.parameters:addStringAlternative("Pos", "TopRight", "", "TopRight");
    indicator.parameters:addStringAlternative("Pos", "TopLeft", "", "TopLeft");
    indicator.parameters:addStringAlternative("Pos", "BottomRight", "", "BottomRight");
	
	indicator.parameters:addBoolean("Legend", "Legend", "No description", true);
    -- Colors
    indicator.parameters:addColor("Weak", "color Weak", "", core.rgb(255, 255, 0));
    indicator.parameters:addColor("Bear", "color Bearish", "", core.rgb(255, 128, 128));
    indicator.parameters:addColor("StrongBear", "color Strong Bearish", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Bull", "color Bullish", "", core.rgb(128, 255, 128));
    indicator.parameters:addColor("StrongBull", "color Strong Bullish", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("TC", "TextColor", "No description", core.rgb(192, 192, 192));

    indicator.parameters:addColor("BearC", "Bearisch Color", "No description", core.rgb(255, 0, 0));
    indicator.parameters:addColor("BullC", "Bullisch Color", "No description", core.rgb(0, 255, 0));
    indicator.parameters:addColor("S1_color", "Color of S1", "Color of S1", core.rgb(0, 0, 0));

	indicator.parameters:addGroup("Ichimoku Style");
    indicator.parameters:addColor("clrTS","param_clrTS_name","param_clrTS_description", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthSL","param_widthSL_name","param_widthSL_description", 1, 1, 5);
    indicator.parameters:addInteger("styleSL","param_styleSL_name","param_styleSL_description", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSL", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrKS","param_clrKS_name","param_clrKS_description", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("widthTL","param_widthTL_name","param_widthTL_description", 1, 1, 5);
    indicator.parameters:addInteger("styleTL","param_styleTL_name","param_styleTL_description", core.LINE_SOLID);
    indicator.parameters:setFlag("styleTL", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrCS","param_clrCS_name","param_clrCS_description", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthCS","param_widthCS_name","param_widthCS_description", 1, 1, 5);
    indicator.parameters:addInteger("styleCS","param_styleCS_name","param_styleCS_description", core.LINE_SOLID);
    indicator.parameters:setFlag("styleCS", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrSSA","param_clrSSA_name","param_clrSSA_description", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthSSA","param_widthSSA_name","param_widthSSA_description", 1, 1, 5);
    indicator.parameters:addInteger("styleSSA","param_styleSSA_name","param_styleSSA_description", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSSA", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrSSB","param_clrSSB_name","param_clrSSB_description", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthSSB","param_widthSSB_name","param_widthSSB_description", 1, 1, 5);
    indicator.parameters:addInteger("styleSSB","param_styleSSB_name","param_styleSSB_description", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSSB", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addInteger("transp","param_transp_name","param_transp_description", 80, 0, 100);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local X;
local Y;
local Z;
local lSS;
local las;
local lwa;
local TC;
local BC;
local BullC;
local Legend;
local first;
local source = nil;

-- Indicator
local ICH   = nil;
local SL    = nil;
local TL    = nil;
local CS    = nil;
local SA    = nil;
local SB    = nil;
local sSL = nil;
local sTL = nil;
local sCS = nil;
local sSA = nil;
local sSB = nil;
local sSA1 = nil;
local sSB2 = nil;
local clrSSA, clrSSB;
-- Streams block
local S1 = nil;
-- Fonts
local sF = nil;
local bF = nil;
local bW = nil;
local sW = nil;
local bbF = nil
-- Signals;
local TSKS_Signal   = "Flat";
local CS_Signal     = "Flat";
local EntryStart    = {};
local S = {PA="Flat",PKS="Flat",TSKS="Flat",CS="Flat"}
-- Level
local Level_1 = 0;
local Level_2 = 0;
local Level_3 = 0;
local Level_4 = 0;
local Level_5 = 0;

-- Routine
--Variablen

local point = nil;
function Prepare()
    X = instance.parameters.X;
    Y = instance.parameters.Y;
    Z = instance.parameters.Z;
    lSS = instance.parameters.lSS;
    las = instance.parameters.las;
    lwa = instance.parameters.lwa;
    TC = instance.parameters.TC;
	Legend = instance.parameters.Legend
    BullC = instance.parameters.BullC;
    source = instance.source;
    first = source:first()+150;
	firstPeriod = source:first();
    point = source:pipSize();

    tradingDayOffset = core.host:execute("getTradingDayOffset");
    tradingWeekOffset = core.host:execute("getTradingWeekOffset");
    TF = source:barSize();

    local name = profile:id() .. "(" .. source:name() .. ", " .. X .. ", " .. Y .. ", " .. Z .. ")";
    instance:name(name);

    SL = instance:addStream("SL", core.Line, name .. ".SL", "SL", instance.parameters.clrTS, firstPeriod + X - 1)
    SL:setWidth(instance.parameters.widthSL);
    SL:setStyle(instance.parameters.styleSL);
    TL = instance:addStream("TL", core.Line, name .. ".TL", "TL", instance.parameters.clrKS, firstPeriod + Y - 1)
    TL:setWidth(instance.parameters.widthTL);
    TL:setStyle(instance.parameters.styleTL);
    CS = instance:addStream("CS", core.Line, name .. ".CS", "CS", instance.parameters.clrCS, firstPeriod, -Y)
    CS:setWidth(instance.parameters.widthCS);
    CS:setStyle(instance.parameters.styleCS);
    SA = instance:addStream("SA", core.Line, name .. ".SA", "SA", instance.parameters.clrSSA, math.max(SL:first(), TL:first()), Y)
    SA:setWidth(instance.parameters.widthSSA);
    SA:setStyle(instance.parameters.styleSSA);
    SB = instance:addStream("SB", core.Line, name .. ".SB", "SB", instance.parameters.clrSSB, firstPeriod + Z - 1, Y)
    SB:setWidth(instance.parameters.widthSSB);
    SB:setStyle(instance.parameters.styleSSB);
	S = instance:addStream("S", core.Dot, name .. ".S", "S", instance.parameters.clrTS, firstPeriod + X - 1)
	S:setWidth(5);
	csFirst = CS:first() + Y;
    slFirst = SL:first();
    tlFirst = TL:first();
    saFirst = SA:first();
    sbFirst = SB:first();
	
	chFirst = math.max(saFirst, sbFirst);
    SA1 = instance:addInternalStream(chFirst, Y);
    SB1 = instance:addInternalStream(chFirst, Y);
    instance:createChannelGroup("SA-SB", "SA-SB", SA1, SB1, instance.parameters.clrSSA, 100 - instance.parameters.transp);
    clrSSA = instance.parameters.clrSSA;
    clrSSB = instance.parameters.clrSSB;
	up = instance:createTextOutput ("Up", "Up", "Wingdings", 15, core.H_Center, core.V_Top, instance.parameters.StrongBull, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", 15, core.H_Center, core.V_Bottom, instance.parameters.StrongBear, 0);
    -- Strategy Info
    sF = core.host:execute("createFont","Tahoma",10,false,false);
    bF = core.host:execute("createFont","Tahoma",12,false,false);
    bbF = core.host:execute("createFont","Tahoma",15,false,true);
    sW = core.host:execute("createFont","Wingdings",10,false,false);
    bW = core.host:execute("createFont","Wingdings",25,false,false);
	if Legend then
	    drwText("--------------------------------------------------" ,23,-250,234,instance.parameters.TC,sF);
		drwText("PA     : Price against Kumo",24,-250,247,instance.parameters.TC,sF);
		drwText("P/KS   : Price against Kijun",25,-250,260,instance.parameters.TC,sF);
		drwText("TS/KS  : TenkanSen against KijunSen",26,-250,273,instance.parameters.TC,sF);
		drwText("CS     : Chikou Position",27,-250,286,instance.parameters.TC,sF);
	end
	
end
function ReleaseInstance()
       core.host:execute("deleteFont", sF);
       core.host:execute("deleteFont", bF);
       core.host:execute("deleteFont", bbF);
       core.host:execute("deleteFont", bW);
       core.host:execute("deleteFont", sW);
   end
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
local endOfCandle = nil;
function Update(period,mode)
    local s, e;
    if endOfCandle == nil then
        s, e = core.getcandle(TF, source.close:date(NOW), tradingDayOffset, tradingWeekOffset);
        endOfCandle = e;
    elseif source:date(NOW) >= endOfCandle then
            s, e = core.getcandle(TF, source.close:date(NOW), tradingDayOffset, tradingWeekOffset);
            endOfCandle = e;
    end
        local dates = core.now();
        local x = core.host:execute("convertTime",core.TZ_LOCAL,core.TZ_EST,dates);
        local q = endOfCandle-x;
        local date = core.dateToTable(q);
        local diff = date;
    drwText(diff.hour .. ":" ..diff.min..":"..  diff.sec,30,-60,83,instance.parameters.TC,sF);
	if (period >= csFirst) then
        CS[period - Y] = source.close[period];
    end

    local p, hh, ll;

    if (period >= slFirst) then
        ll, hh = mathex.minmax(source, period - X + 1, period);
        SL[period] = (hh + ll) / 2;
    end

    if (period >= tlFirst) then
        ll, hh = mathex.minmax(source, period - Y + 1, period);
        TL[period] = (hh + ll) / 2;
    end

    local p = period + Y;

    if (period >= saFirst) then
        SA[p] = (SL[period] + TL[period]) / 2;
    end

    if (period >= sbFirst) then
        ll, hh = mathex.minmax(source, period - Z + 1, period);
        SB[p] = (hh + ll) / 2;
    end

    if (period >= chFirst) then
        SA1[p] = SA[p];
        SB1[p] = SB[p];
        if (SA[p] > SB[p]) then
            SA1:setColor(p, clrSSB);
        else
            SA1:setColor(p, clrSSA);
        end
    end
    if period >= first and source:hasData(period) then
        getSignal(period);
        getLevel(period)
        -- Set Text ----------------------------------------
        setText(period)
    end
end



function getLevel(period)
   local HL8 = 0;
   local L_2HL8 = 0;
   local f1 = 0;
   local f2 = 0;
   local f3 = 0;
   local f4 = 0;
   local f5 = 0;
   local f6 = 0;
   local f7 = 0;
   local f8 = 0;
   local f9 = 0;
   local f10 = 0;
   local f11 = 0;
   local f12 = 0;
   local High = mathex.max(source.high,period-64+1,period);
   local Low = mathex.min(source.low,period-64+1,period);
   HL8 = (High - Low) / 8.0;
   L_2HL8 = Low - 2.0 * HL8;
   f1 = L_2HL8 + HL8;
   f2 = f1 + HL8;
   f3 = f2 + HL8;
   f4 = f3 + HL8;
   f5 = f4 + HL8;
   f6 = f5 + HL8;
   f12 = f6 + HL8;
   f11 = f12 + HL8;
   f10 = f11 + HL8;
   f9 = f10 + HL8;
   f8 = f9 + HL8;
   f7 = f8 + HL8;
   if (source.close[period] <= L_2HL8) then
      Level_3 = L_2HL8;
      Level_2 = Level_3 + HL8;
      Level_1 = Level_2 + HL8;
      Level_4 = Level_3 - HL8;
      Level_5 = Level_4 - HL8;
   end
   if (source.close[period] >= L_2HL8 and source.close[period] < f1) then
      Level_3 = f1;
      Level_2 = Level_3 + HL8;
      Level_1 = Level_2 + HL8;
      Level_4 = Level_3 - HL8;
      Level_5 = Level_4 - HL8;
   end
   if (source.close[period] >= f1 and source.close[period] < f2) then
      Level_3 = f2;
      Level_2 = Level_3 + HL8;
      Level_1 = Level_2 + HL8;
      Level_4 = Level_3 - HL8;
      Level_5 = Level_4 - HL8;
   end
   if (source.close[period] >= f2 and source.close[period] < f3) then
      Level_3 = f3;
      Level_2 = Level_3 + HL8;
      Level_1 = Level_2 + HL8;
      Level_4 = Level_3 - HL8;
      Level_5 = Level_4 - HL8;
   end
   if (source.close[period] >= f3 and source.close[period] < f4) then
      Level_3 = f4;
      Level_2 = Level_3 + HL8;
      Level_1 = Level_2 + HL8;
      Level_4 = Level_3 - HL8;
      Level_5 = Level_4 - HL8;
   end
   if (source.close[period] >= f4 and source.close[period] < f5) then
      Level_3 = f5;
      Level_2 = Level_3 + HL8;
      Level_1 = Level_2 + HL8;
      Level_4 = Level_3 - HL8;
      Level_5 = Level_4 - HL8;
   end
   if (source.close[period] >= f5 and source.close[period] < f6) then
      Level_3 = f6;
      Level_2 = Level_3 + HL8;
      Level_1 = Level_2 + HL8;
      Level_4 = Level_3 - HL8;
      Level_5 = Level_4 - HL8;
   end
   if (source.close[period] >= f6 and source.close[period] < f12) then
      Level_3 = f12;
      Level_2 = Level_3 + HL8;
      Level_1 = Level_2 + HL8;
      Level_4 = Level_3 - HL8;
      Level_5 = Level_4 - HL8;
   end
   if (source.close[period] >= f12 and source.close[period] < f11) then
      Level_3 = f11;
      Level_2 = Level_3 + HL8;
      Level_1 = Level_2 + HL8;
      Level_4 = Level_3 - HL8;
      Level_5 = Level_4 - HL8;
   end
   if (source.close[period] >= f11 and source.close[period] < f10) then
      Level_3 = f10;
      Level_2 = Level_3 + HL8;
      Level_1 = Level_2 + HL8;
      Level_4 = Level_3 - HL8;
      Level_5 = Level_4 - HL8;
   end
   if (source.close[period] >= f10 and source.close[period] < f9) then
      Level_3 = f9;
      Level_2 = Level_3 + HL8;
      Level_1 = Level_2 + HL8;
      Level_4 = Level_3 - HL8;
      Level_5 = Level_4 - HL8;
   end
   if (source.close[period] >= f9 and source.close[period] < f8) then
      Level_3 = f8;
      Level_2 = Level_3 + HL8;
      Level_1 = Level_2 + HL8;
      Level_4 = Level_3 - HL8;
      Level_5 = Level_4 - HL8;
   end
   if (source.close[period] >= f8 and source.close[period] < f7) then
      Level_3 = f7;
      Level_2 = Level_3 + HL8;
      Level_1 = Level_2 + HL8;
      Level_4 = Level_3 - HL8;
      Level_5 = Level_4 - HL8;
   end
   if (source.close[period] >= f7) then
      Level_3 = f7;
      Level_2 = Level_3 + HL8;
      Level_1 = Level_2 + HL8;
      Level_4 = Level_3 - HL8;
      Level_5 = Level_4 - HL8;
   end
end
local lots=0;

local PKS_wait = "";
function getSignal(period)
    --PA Signal Price against Kumo
    if source.close[period] > SA[period] and source.close[period] > SB[period] then
        S.PA = "Bullish";
    end
    if source.close[period] < SA[period] and source.close[period] < SB[period] then
        S.PA = "Bearish";
    end
    if source.close[period] > SA[period] and source.close[period] < SB[period] then
        S.PA = "Flat";
    end
    if source.close[period] < SA[period] and source.close[period] > SB[period] then
        S.PA = "Flat";
    end
    --PKS Signal Price against Kijun
    if source.open[period]>TL[period] and TL[period] > SA[period] and TL[period] > SB[period]then 
		S.PKS 		= "Strong Bullish Crossover";
    end
	if source.open[period]<TL[period] and TL[period] < SA[period] and TL[period] < SB[period]then 
        S.PKS 		= "Strong Bearish Crossover";
    end
	if source.open[period]>TL[period] and TL[period] < SA[period] and TL[period] > SB[period]then 
		S.PKS 		= "Average Bullish Crossover";
    end
	if source.open[period]>TL[period] and TL[period] > SA[period] and TL[period] < SB[period]then 
		S.PKS 		= "Average Bullish Crossover";
    end
	if source.open[period]<TL[period] and TL[period] < SA[period] and TL[period] > SB[period]then 
		S.PKS 		= "Average Bearish Crossover";
    end
	if source.open[period]<TL[period] and TL[period] > SA[period] and TL[period] < SB[period]then 
		S.PKS 		= "Average Bearish Crossover";
    end
	if source.open[period]>TL[period] and TL[period] < SA[period] and TL[period] < SB[period]then 
		S.PKS 		= "Weak Bullish Crossover";
    end
	if source.open[period]<TL[period] and TL[period] > SA[period] and TL[period] > SB[period]then 
        S.PKS 		= "Weak Bearish Crossover";
    end
    --TSKS Signal Tenkan against Kijun
    if SL[period-2]<=TL[period-2] and SL[period-1]>TL[period-1] then 
        if source.close[period-1] < SA[period-1] and source.close[period-1] < SB[period-1] then
            TSKS_Signal = "Weak Bullish Crossover";
            EntryStart[1]  = source.open[period];
            EntryStart[2]  = "Bull";
            text6_label = "Long " .. lwa .. " Lots @ " .. source.open[period];
            lots=lwa;
			S[period] = source.open[period];
			up:set(period, source.high[period], "\225");
        end
        if source.close[period-1] > SA[period-1] and source.close[period-1] > SB[period-1] then
            TSKS_Signal = "Strong Bullish Crossover";
            EntryStart[1]  = source.open[period];
            EntryStart[2]  = "Bull";
            text6_label = "Long " .. lSS .. " Lots @ " .. source.open[period];
            lots=lSS;
			S[period] = source.open[period];
			up:set(period, source.high[period], "\225");
        end
        if source.close[period-1] < SA[period-1] and source.close[period-1] > SB[period-1] then
            TSKS_Signal = "Average Bullish Crossover";
            EntryStart[1]  = source.open[period];
            EntryStart[2]  = "Bull";
            text6_label = "Long " .. las .. " Lots @ " .. source.open[period];
            lots=las;
			S[period] = source.open[period];
			up:set(period, source.high[period], "\225");
        end
        if source.close[period-1] > SA[period-1] and source.close[period-1] < SB[period-1] then
            TSKS_Signal = "Average Bullish Crossover";
            EntryStart[1]  = source.open[period];
            EntryStart[2]  = "Bull";
            text6_label = "Long " .. las .. " Lots @ " .. source.open[period];
            lots=las;
			S[period] = source.open[period];
			up:set(period, source.high[period], "\225");
        end
    end
    if SL[period-2]>=TL[period-2] and SL[period-1]<TL[period-1] then 
        if source.close[period-1] > SA[period-1] and source.close[period-1] > SB[period-1] then
            TSKS_Signal = "Weak Bearish Crossover";
            EntryStart[1]  = source.open[period];
            EntryStart[2]  = "Bear";
            text6_label = "Short " .. lwa .. " Lots @ " .. source.open[period];
            lots=lwa;
			S[period] = source.open[period];
			down:set(period, source.low[period], "\226");
        end
        if source.close[period-1] < SA[period-1] and source.close[period-1] < SB[period-1] then
            TSKS_Signal = "Strong Bearish Crossover";
            EntryStart[1]  = source.open[period];
            EntryStart[2]  = "Bear";
            text6_label = "Short " .. lSS .. " Lots @ " .. source.open[period];
            lots=lSS;
			S[period] = source.open[period];
			down:set(period, source.low[period], "\226");
        end
        if source.close[period-1] > SA[period-1] and source.close[period-1] < SB[period-1] then
            TSKS_Signal = "Average Bearish Crossover";
            EntryStart[1]  = source.open[period];
            EntryStart[2]  = "Bear";
            text6_label = "Short " .. las .. " Lots @ " .. source.open[period];
            lots=las;
			S[period] = source.open[period];
			down:set(period, source.low[period], "\226");
        end
        if source.close[period-1] < SA[period-1] and source.close[period-1] > SB[period-1] then
            TSKS_Signal = "Average Bearish Crossover";
            EntryStart[1]  = source.open[period];
            EntryStart[2]  = "Bear";
            text6_label = "Short " .. las .. " Lots @ " .. source.open[period];
            lots=las;
			S[period] = source.open[period];
			down:set(period, source.low[period], "\226");
        end
    end
    --CS Chikou-Bias
    if  CS[period-Y] < source.high[period-Y] and 
        CS[period-Y] > source.low[period-Y] then
        CS_Signal = "Flat";
    end
    if (CS[period-Y] > source.high[period-Y])then
        CS_Signal = "Bullish";
    end
    if (CS[period-Y] < source.low[period-Y])then
        CS_Signal = "Bearish";
    end
        --local MedianPrice = (source.open[period-PKS_shift] + source.close[period-PKS_shift] + source.low[period-PKS_shift] + source.high[period-PKS_shift]) / 4.0;

end

function setText(period)
-----------------------------------------------------
	local PAcolor = instance.parameters.StrongBull;
	local PAdirection= " ";
    if S.PA == "Bearish" then
        --PKSBearStrong:set(period-15,20*V_Step,"\234");
        --Percent = Percent + 20;
		PAdirection = "\234";
		PAcolor 	= instance.parameters.StrongBear;
    end
    if S.PA == "Bullish" then
        --PKSBullStrong:set(period-15,20*V_Step,"\233");
        --Percent = Percent + 20;
		PAdirection = "\233";
		PAcolor 	= instance.parameters.StrongBull;
    end
    if S.PA == "Flat" then
        --PKSBearweak:set(period-15,20*V_Step,"\238");
        --Percent = Percent + 10;
		PAdirection = "\232";
		PAcolor 	= instance.parameters.Weak;
    end
----------------------------------------------------
	local PKScolor = instance.parameters.StrongBull;
	local PKSdirection= " ";
    if S.PKS == "Strong Bullish Crossover" then
        --PKSBullStrong:set(period-5,20*V_Step,"\233");
        --Percent = Percent + 20;
		PKScolor = instance.parameters.StrongBull;
		PKSdirection= "\233";
    end
    if S.PKS == "Average Bullish Crossover" then
        --PKSBull:set(period-5,20*V_Step,"\236");
        --Percent = Percent + 10;
		PKScolor = instance.parameters.Weak;
		PKSdirection= "\236";
    end
    if S.PKS == "Weak Bullish Crossover" then
        --PKSBullweak:set(period-5,20*V_Step,"\236");
        --Percent = Percent + 0;
		PKScolor = instance.parameters.Weak;
		PKSdirection= "\236";
    end
    if S.PKS == "Strong Bearish Crossover" then
        --PKSBearStrong:set(period-5,20*V_Step,"\234");
        --Percent = Percent + 20;
		PKScolor = instance.parameters.StrongBear;
		PKSdirection= "\234";
    end
    if S.PKS == "Average Bearish Crossover" then
        --PKSBear:set(period-5,20*V_Step,"\238");
        --Percent = Percent + 10;
		PKScolor = instance.parameters.Weak;
		PKSdirection= "\238";
    end
    if S.PKS == "Weak Bearish Crossover" then
        --PKSBearweak:set(period-5,20*V_Step,"\238");
        --Percent = Percent + 0;
		PKScolor = instance.parameters.Weak;
		PKSdirection= "\238";
    end
----------------------------------------------------
	local TScolor = instance.parameters.StrongBull;
	local TSdirection= " ";
    if TSKS_Signal == "Strong Bullish Crossover" then
        --PKSBullStrong:set(period-5,20*V_Step,"\233");
        --Percent = Percent + 20;
		TScolor = instance.parameters.StrongBull;
		TSdirection= "\233";
    end
    if TSKS_Signal == "Average Bullish Crossover" then
        --PKSBull:set(period-5,20*V_Step,"\236");
        --Percent = Percent + 10;
		TScolor = instance.parameters.Weak;
		TSdirection= "\236";
    end
    if TSKS_Signal == "Weak Bullish Crossover" then
        --PKSBullweak:set(period-5,20*V_Step,"\236");
        --Percent = Percent + 0;
		TScolor = instance.parameters.Weak;
		TSdirection= "\236";
    end
    if TSKS_Signal == "Strong Bearish Crossover" then
        --PKSBearStrong:set(period-5,20*V_Step,"\234");
        --Percent = Percent + 20;
		TScolor = instance.parameters.StrongBear;
		TSdirection= "\234";
    end
    if TSKS_Signal == "Average Bearish Crossover" then
        --PKSBear:set(period-5,20*V_Step,"\238");
        --Percent = Percent + 10;
		TScolor = instance.parameters.Weak;
		TSdirection= "\238";
    end
    if TSKS_Signal == "Weak Bearish Crossover" then
        --PKSBearweak:set(period-5,20*V_Step,"\238");
        --Percent = Percent + 0;
		TScolor = instance.parameters.Weak;
		TSdirection= "\238";
    end
----------------------------------------------------
	local CScolor = instance.parameters.StrongBull;
	local CSdirection= " ";
    if CS_Signal == "Flat" then
        --PKSBearweak:set(period-0,20*V_Step,"\238");
		CScolor = instance.parameters.Weak;
		CSdirection= "\232";
    end
    if CS_Signal == "Bearish" then
        --PKSBearStrong:set(period-0,20*V_Step,"\234");
		CScolor = instance.parameters.StrongBear;
		CSdirection= "\234";
    end
    if CS_Signal == "Bullish" then
        --PKSBullStrong:set(period-0,20*V_Step,"\233");
		CScolor = instance.parameters.StrongBull;
		CSdirection= "\233";
    end



	-- Calculate the Percent Signal Strenght
	-- Older Version
    local Percent = 0;
	-- New Version
	if CS_Signal == "Bullish" then
		if S.PKS == "Strong Bullish Crossover" then				Percent = Percent + 40;					end
		if S.PKS == "Average Bullish Crossover" then			Percent = Percent + 20;					end
		if string.find(S.PA,"Bullish") ~= nil then				Percent = Percent + 20;					end
		if string.find(S.PA,"Flat") ~= nil then					Percent = Percent + 10;					end
		if source.close[period] > TL[period] then				Percent = Percent + 10;					end
		if source.close[period-Y] > TL[period-Y] then			Percent = Percent + 20;					end
		if source.close[period-Y] > TL[period] then				Percent = Percent + 5;					end
		if source.close[period-Y] > SL[period] then				Percent = Percent + 5;					end
	end
	if CS_Signal == "Bearish" then
		if S.PKS == "Strong Bearish Crossover" then				Percent = Percent + 40;					end
		if S.PKS == "Average Bearish Crossover" then			Percent = Percent + 20;					end
		if string.find(S.PA,"Bearish") ~= nil then				Percent = Percent + 20;					end
		if string.find(S.PA,"Flat") ~= nil then					Percent = Percent + 10;					end
		if source.close[period] < TL[period] then				Percent = Percent + 10;					end
		if source.close[period-Y] < TL[period-Y] then			Percent = Percent + 20;					end
		if source.close[period-Y] < TL[period] then				Percent = Percent + 5;					end
		if source.close[period-Y] < SL[period] then				Percent = Percent + 5;					end
	end

    drwText("--------------------------------------------------" ,1,-250,0,instance.parameters.TC,sF);

    if CS_Signal == "Flat" then
        drwText("Flat Waiting(" .. source:barSize() .. ") " .. source:instrument(),2,-250,13,instance.parameters.Weak,bF);
		drwText("nnnnnnnnnn",3,-250,30,core.rgb(37,37,37),bW);
		drwText("",4,-250,30,instance.parameters.StrongBear,bW);
    end
    if CS_Signal == "Bearish"  then
        drwText(Percent .. "% Bearisch (" .. source:barSize() .. ") " .. source:instrument(),2,-250,13,instance.parameters.StrongBear,bF);
        drwText("nnnnnnnnnn",3,-250,30,core.rgb(37,37,37),bW);
        if Percent >= 0  and Percent < 10 then
            drwText("",4,-250,30,instance.parameters.StrongBear,bW);
        end
        if Percent >= 10  and Percent < 20 then
            drwText("n",4,-250,30,instance.parameters.StrongBear,bW);
        end
        if Percent >= 20  and Percent < 30 then
            drwText("nn",4,-250,30,instance.parameters.StrongBear,bW);
        end
        if Percent >= 30  and Percent < 40 then
            drwText("nnn",4,-250,30,instance.parameters.StrongBear,bW);
        end
        if Percent >= 40  and Percent < 50 then
            drwText("nnnn",4,-250,30,instance.parameters.StrongBear,bW);
        end
        if Percent >= 50  and Percent < 60 then
            drwText("nnnnn",4,-250,30,instance.parameters.StrongBear,bW);
        end
        if Percent >= 60  and Percent < 70 then
            drwText("nnnnnn",4,-250,30,instance.parameters.StrongBear,bW);
        end
        if Percent >= 70  and Percent < 80 then
            drwText("nnnnnnn",4,-250,30,instance.parameters.StrongBear,bW);
        end
        if Percent >= 80  and Percent < 90 then
            drwText("nnnnnnnn",4,-250,30,instance.parameters.StrongBear,bW);
        end
        if Percent >= 90  and Percent < 100 then
            drwText("nnnnnnnnn",4,-250,30,instance.parameters.StrongBear,bW);
        end
        if Percent >= 100 then
            drwText("nnnnnnnnnn",4,-250,30,instance.parameters.StrongBear,bW);
        end
    end
    if CS_Signal == "Bullish" then
        drwText(Percent .. "% Bullish (" .. source:barSize() .. ") " .. source:instrument(),2,-250,13,instance.parameters.StrongBull,bF);
        drwText("nnnnnnnnnn",3,-250,30,core.rgb(37,37,37),bW);
        if Percent >= 0  and Percent < 10 then
            drwText("",4,-250,30,instance.parameters.StrongBull,bW);
        end
        if Percent >= 10  and Percent < 20 then
            drwText("n",4,-250,30,instance.parameters.StrongBull,bW);
        end
        if Percent >= 20  and Percent < 30 then
            drwText("nn",4,-250,30,instance.parameters.StrongBull,bW);
        end
        if Percent >= 30  and Percent < 40 then
            drwText("nnn",4,-250,30,instance.parameters.StrongBull,bW);
        end
        if Percent >= 40  and Percent < 50 then
            drwText("nnnn",4,-250,30,instance.parameters.StrongBull,bW);
        end
        if Percent >= 50  and Percent < 60 then
            drwText("nnnnn",4,-250,30,instance.parameters.StrongBull,bW);
        end
        if Percent >= 60  and Percent < 70 then
            drwText("nnnnnn",4,-250,30,instance.parameters.StrongBull,bW);
        end
        if Percent >= 70  and Percent < 80 then
            drwText("nnnnnnn",4,-250,30,instance.parameters.StrongBull,bW);
        end
        if Percent >= 80  and Percent < 90 then
            drwText("nnnnnnnn",4,-250,30,instance.parameters.StrongBull,bW);
        end
        if Percent >= 90  and Percent < 100 then
            drwText("nnnnnnnnn",4,-250,30,instance.parameters.StrongBull,bW);
        end
        if Percent >= 100 then
            drwText("nnnnnnnnnn",4,-250,30,instance.parameters.StrongBull,bW);
        end
    end
    
    
    drwText("PA       P/KS     TS/KS       CS   nCandle in",5,-250,67,instance.parameters.TC,sF);
	drwText(PAdirection,6,-250,83,PAcolor,sW);
	drwText(PKSdirection,7,-200,83,PKScolor,sW);
	drwText(TSdirection,8,-147,83,TScolor,sW);
	drwText(CSdirection,9,-94,83,CScolor,sW);

    drwText("--------------------------------------------------" ,12,-250,93,instance.parameters.TC,sF);
    drwText(text6_label,13,-250,107,instance.parameters.TC,sF);
    if EntryStart[2] == "Bull" then
        drwText("Pips earned: " .. round((source.close[period] - EntryStart[1])/point)*lots,14,-250,120,instance.parameters.TC,sF);
    end
    if EntryStart[2] == "Bear" then
        drwText("Pips earned: " .. round((EntryStart[1] - source.close[period])/point)*lots,14,-250,120,instance.parameters.TC,sF);
    end
    drwText("--------------------------------------------------" ,15,-250,133,instance.parameters.TC,sF);
    drwText("Price: " .. source.close[period],16,-250,140,instance.parameters.TC,bbF);
    drwText("--------------------------------------------------" ,17,-250,157,instance.parameters.TC,sF);
    drwText("Level 1 @ " .. rd(Level_1,4),18,-250,170,instance.parameters.TC,sF);
    drwText("Level 2 @ " .. rd(Level_2,4),19,-250,183,instance.parameters.TC,sF);
    drwText("Level 3 @ " .. rd(Level_3,4),20,-250,196,instance.parameters.TC,sF);
    drwText("Level 4 @ " .. rd(Level_4,4),21,-250,209,instance.parameters.TC,sF);
    drwText("Level 5 @ " .. rd(Level_5,4),22,-250,221,instance.parameters.TC,sF);
	local d2 , d1
	d2 = source:date(period);
    d1, d2 = core.getcandle(source:barSize(), d2, core.host:execute ("getTradingDayOffset"), core.host:execute ("getTradingWeekOffset"));
	core.host:execute("drawLine", 1, d1, Level_1, d2, Level_1, instance.parameters.TC, core.LINE_SOLID, 1, "Level 1");
	core.host:execute("drawLine", 2, d1, Level_2, d2, Level_2, instance.parameters.TC, core.LINE_SOLID, 1, "Level 2");
	core.host:execute("drawLine", 3, d1, Level_3, d2, Level_3, instance.parameters.TC, core.LINE_SOLID, 1, "Level 3");
	core.host:execute("drawLine", 4, d1, Level_4, d2, Level_4, instance.parameters.TC, core.LINE_SOLID, 1, "Level 4");
	core.host:execute("drawLine", 5, d1, Level_5, d2, Level_5, instance.parameters.TC, core.LINE_SOLID, 1, "Level 5");
    
end
function drwText(text,ID,x,y,color,f)
	if instance.parameters.Pos == "TopRight" then
		core.host:execute("drawLabel1", ID, x, core.CR_RIGHT, y, core.CR_TOP, core.H_Right, core.V_Bottom,
								 f, color, text);
	end
	if instance.parameters.Pos == "TopLeft" then
		core.host:execute("drawLabel1", ID, 240-x, core.CR_LEFT, 20 + y, core.CR_TOP, core.H_Right, core.V_Bottom,
								 f, color, text);
	end
end
function rd(i,y)
    local x = math.pow(10,y);
    return (math.floor( (i * x) + 1) / x);
end
function round(v)
    local nv = math.floor((v*1000) + 0.5)/1000;
    return nv;
end











