-- Id:  
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3890

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+


local indi_alerts = {};
indi_alerts.Version = "1.11";
indi_alerts.inverted_arrows = false;
local alert_stages = { 2, 2, 2, 2, 2, 2, 2, 2 };

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

    indi_alerts:AddParameters(indicator.parameters);
    indi_alerts:AddAlert("PA Signal Price against Kumo");
    indi_alerts:AddAlert("PKS Signal Price against Kijun (Strong)");
    indi_alerts:AddAlert("PKS Signal Price against Kijun (Average)");
    indi_alerts:AddAlert("PKS Signal Price against Kijun (Weak)");
    indi_alerts:AddAlert("TSKS Signal Tenkan against Kijun (Weak)");
    indi_alerts:AddAlert("TSKS Signal Tenkan against Kijun (Strong)");
    indi_alerts:AddAlert("TSKS Signal Tenkan against Kijun (Average)");
    indi_alerts:AddAlert("CS Chikou-Bias");
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
function Prepare(nameOnly)
    indi_alerts:Prepare();
    indi_alerts.source = instance.source;
    instance:drawOnMainChart(true);
    instance:ownerDrawn(true);
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
    if (nameOnly) then
        return;
    end

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
function Draw(stage, context) indi_alerts:Draw(stage, context, source); end

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

    for _, alert in ipairs(indi_alerts.Alerts) do Activate(alert, period, period ~= source:size() - 1); end
end

function Alert1B(period)
    return source.close[period] > SA[period] and source.close[period] > SB[period];
end
function Alert1S(period)
    return source.close[period] < SA[period] and source.close[period] < SB[period];
end
function Alert2B(period)
    return source.open[period]>TL[period] and TL[period] > SA[period] and TL[period] > SB[period];
end
function Alert2S(period)
    return source.open[period]<TL[period] and TL[period] < SA[period] and TL[period] < SB[period];
end
function Alert3B(period)
    return (source.open[period]>TL[period] and TL[period] < SA[period] and TL[period] > SB[period])
        or (source.open[period]>TL[period] and TL[period] > SA[period] and TL[period] < SB[period]);
end
function Alert3S(period)
    return (source.open[period]<TL[period] and TL[period] < SA[period] and TL[period] > SB[period])
        or (source.open[period]<TL[period] and TL[period] > SA[period] and TL[period] < SB[period]);
end
function Alert4B(period)
    return (source.open[period]>TL[period] and TL[period] < SA[period] and TL[period] < SB[period]);
end
function Alert4S(period)
    return (source.open[period]<TL[period] and TL[period] > SA[period] and TL[period] > SB[period]);
end
function Alert5B(period)
    return (SL[period-2]<=TL[period-2] and SL[period-1]>TL[period-1] and source.close[period-1] < SA[period-1] and source.close[period-1] < SB[period-1]);
end
function Alert5S(period)
    return (SL[period-2]>=TL[period-2] and SL[period-1]<TL[period-1] and source.close[period-1] > SA[period-1] and source.close[period-1] > SB[period-1]);
end
function Alert6B(period)
    return (SL[period-2]<=TL[period-2] and SL[period-1]>TL[period-1] and source.close[period-1] > SA[period-1] and source.close[period-1] > SB[period-1]);
end
function Alert6S(period)
    return (SL[period-2]>=TL[period-2] and SL[period-1]<TL[period-1] and source.close[period-1] < SA[period-1] and source.close[period-1] < SB[period-1]);
end
function Alert7B(period)
    return SL[period-2]<=TL[period-2] and SL[period-1]>TL[period-1] and
        ((source.close[period-1] > SA[period-1] and source.close[period-1] < SB[period-1]) or (source.close[period-1] < SA[period-1] and source.close[period-1] > SB[period-1]));
end
function Alert7S(period)
    return (SL[period-2]>=TL[period-2] and SL[period-1]<TL[period-1] and 
        ((source.close[period-1] > SA[period-1] and source.close[period-1] < SB[period-1]) or (source.close[period-1] < SA[period-1] and source.close[period-1] > SB[period-1]))) ;
end
function Alert8B(period)
    return CS[period-Y] > source.high[period-Y];
end
function Alert8S(period)
    return CS[period-Y] < source.low[period-Y];
end

function Activate(alert, period, historical_period)
    if indi_alerts.Live ~= "Live" then period = period - 1; end
    alert.Alert[period] = 0;
    if not alert.ON then
        if indi_alerts.FIRST then indi_alerts.FIRST = false; end
        return;
    end
    if period < Y then
        return;
    end
    --PA Signal Price against Kumo
    if alert.id == 1 then
        if Alert1B(period) and not Alert1B(period - 1) then
            alert:UpAlert(source, period, alert.Label .. ". Bullish", source.high[period], historical_period);
        elseif Alert1S(period) and not Alert1S(period - 1) then
            alert:DownAlert(source, period, alert.Label .. ". Bearish", source.low[period], historical_period);
        end
    end
    --PKS Signal Price against Kijun (Strong)
    if alert.id == 2 then
        if Alert2B(period) and not Alert2B(period - 1) then
            alert:UpAlert(source, period, alert.Label .. ". Strong Bullish Crossover", source.high[period], historical_period);
        elseif Alert2S(period) and not Alert2S(period - 1) then
            alert:DownAlert(source, period, alert.Label .. ". Strong Bearish Crossover", source.low[period], historical_period);
        end
    end

    --PKS Signal Price against Kijun (Average)
    if alert.id == 3 then
        if Alert3B(period) and not Alert3B(period - 1) then
            alert:UpAlert(source, period, alert.Label .. ". Average Bullish Crossover", source.high[period], historical_period);
        elseif Alert3S(period) and not Alert3S(period - 1) then
            alert:DownAlert(source, period, alert.Label .. ". Average Bearish Crossover", source.low[period], historical_period);
        end
    end
    
    --PKS Signal Price against Kijun (Weak)
    if alert.id == 4 then
        if Alert4B(period) and not Alert4B(period - 1) then
            alert:UpAlert(source, period, alert.Label .. ". Weak Bullish Crossover", source.high[period], historical_period);
        elseif Alert4S(period) and not Alert4S(period - 1) then
            alert:DownAlert(source, period, alert.Label .. ". Weak Bearish Crossover", source.low[period], historical_period);
        end
    end
    --TSKS Signal Tenkan against Kijun (Weak)
    if alert.id == 5 then
        if Alert5B(period) and not Alert5B(period - 1) then
            alert:UpAlert(source, period, alert.Label .. ". Weak Bullish Crossover", source.high[period], historical_period);
        elseif Alert5S(period) and not Alert5S(period - 1) then
            alert:DownAlert(source, period, alert.Label .. ". Weak Bearish Crossover", source.low[period], historical_period);
        end
    end
    --TSKS Signal Tenkan against Kijun (Strong)
    if alert.id == 6 then
        if Alert6B(period) and not Alert6B(period - 1) then
            alert:UpAlert(source, period, alert.Label .. ". Strong Bullish Crossover", source.high[period], historical_period);
        elseif Alert6S(period) and not Alert6S(period - 1) then
            alert:DownAlert(source, period, alert.Label .. ". Strong Bearish Crossover", source.low[period], historical_period);
        end
    end
    --TSKS Signal Tenkan against Kijun (Average)
    if alert.id == 7 then
        if Alert7B(period) and not Alert7B(period - 1) then
            alert:UpAlert(source, period, alert.Label .. ". Average Bullish Crossover", source.high[period], historical_period);
        elseif Alert7S(period) and not Alert7S(period - 1) then
            alert:DownAlert(source, period, alert.Label .. ". Average Bearish Crossover", source.low[period], historical_period);
        end
    end
    --CS Chikou-Bias
    if alert.id == 8 then
        if Alert8B(period) and not Alert8B(period - 1) then
            alert:UpAlert(source, period, alert.Label .. ". Bullish", source.high[period], historical_period);
        elseif Alert8S(period) and not Alert8S(period - 1) then
            alert:DownAlert(source, period, alert.Label .. ". Bearish", source.low[period], historical_period);
        end
    end

    if indi_alerts.FIRST then indi_alerts.FIRST = false; end
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

function AsyncOperationFinished(cookie, success, message, message1, message2)
    indi_alerts:AsyncOperationFinished(cookie, success, message, message1, message2)
end

indi_alerts.last_id = 0;
indi_alerts.FIRST = true;
indi_alerts._alerts = {};
indi_alerts._advanced_alert_timer = nil;
function indi_alerts:AddParameters(parameters)
    indicator.parameters:addGroup("Alert Mode");  
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");
    indicator.parameters:addBoolean("strategy_output", "Output for strategies", "Used by the strategies", false);

    indicator.parameters:addInteger("ToTime", "Convert the date to", "", 6)
    indicator.parameters:addIntegerAlternative("ToTime", "EST", "", 1)
    indicator.parameters:addIntegerAlternative("ToTime", "UTC", "", 2)
    indicator.parameters:addIntegerAlternative("ToTime", "Local", "", 3)
    indicator.parameters:addIntegerAlternative("ToTime", "Server", "", 4)
    indicator.parameters:addIntegerAlternative("ToTime", "Financial", "", 5)
    indicator.parameters:addIntegerAlternative("ToTime", "Display", "", 6)
    
    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
    
    indicator.parameters:addGroup("Alerts");
    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
    indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    
    indicator.parameters:addGroup("Alerts Sound");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);    
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
    
    indicator.parameters:addGroup("Alerts Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

    indicator.parameters:addGroup("External Alerts");
    indicator.parameters:addBoolean("use_advanced_alert", "Send Advanced Alert", "Telegram/Discord/other platform (like MT4)", false)
	indicator.parameters:addString("advanced_alert_key", "Advanced Alert Key",
		"You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for Discord/other platform keys", "")
end

function indi_alerts:AsyncOperationFinished(cookie, success, message, message1, message2) if cookie == self._advanced_alert_timer and #self._alerts > 0 then if self._advanced_alert_key == nil then return; end local data = self:ArrayToJSON(self._alerts); self._alerts = {}; local req = http_lua.createRequest(); local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}', self._advanced_alert_key, string.gsub(self.StrategyName or "", '"', '\\"'), data); req:setRequestHeader("Content-Type", "application/json"); req:setRequestHeader("Content-Length", tostring(string.len(query))); req:start("http://profitrobots.com/api/v1/notification", "POST", query); end end
function indi_alerts:ToJSON(item)
    local json = {};
    function json:AddStr(name, value) local separator = ""; if self.str ~= nil then separator = ","; else self.str = ""; end self.str = self.str .. string.format("%s\"%s\":\"%s\"", separator, tostring(name), tostring(value)); end
    function json:AddNumber(name, value) local separator = ""; if self.str ~= nil then separator = ","; else self.str = ""; end self.str = self.str .. string.format("%s\"%s\":%f", separator, tostring(name), value or 0); end
    function json:AddBool(name, value) local separator = ""; if self.str ~= nil then separator = ","; else self.str = ""; end self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), value and "true" or "false"); end
    function json:ToString() return "{" .. (self.str or "") .. "}"; end
    local first = true; for idx,t in pairs(item) do  local stype = type(t) if stype == "number" then json:AddNumber(idx, t); elseif stype == "string" then json:AddStr(idx, t); elseif stype == "boolean" then json:AddBool(idx, t); elseif stype == "function" or stype == "table" then else core.host:trace(tostring(idx) .. " " .. tostring(stype)); end end
    return json:ToString();
end
function indi_alerts:ArrayToJSON(arr) local str = "["; for i, t in ipairs(self._alerts) do local json = self:ToJSON(t); if str == "[" then str = str .. json; else str = str .. "," .. json; end end return str .. "]"; end
function indi_alerts:AddAlert(label)
    self.last_id = self.last_id + 1;
    indicator.parameters:addGroup(label .. " Alert");

    indicator.parameters:addBoolean("ON" .. self.last_id , "Show " .. label .." Alert" , "", true);

    indicator.parameters:addString("drawing_mode" .. self.last_id, "Drawing mode", "", "arrows");
    indicator.parameters:addStringAlternative("drawing_mode" .. self.last_id, "Arrows", "", "arrows");
    indicator.parameters:addStringAlternative("drawing_mode" .. self.last_id, "Vertical lines", "", "vlines");

    indicator.parameters:addFile("Up" .. self.last_id, label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up" .. self.last_id, core.FLAG_SOUND);
    indicator.parameters:addInteger("UpSymbol" .. self.last_id, "Up Symbol", "", 217);
    indicator.parameters:addColor("UpColor" .. self.last_id, "Up Color", "", core.rgb(0, 255, 0));
    
    indicator.parameters:addFile("Down" .. self.last_id, label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down" .. self.last_id, core.FLAG_SOUND);
    indicator.parameters:addInteger("DownSymbol" .. self.last_id, "Down Symbol", "", 218);
    indicator.parameters:addColor("DownColor" .. self.last_id, "Down Color", "", core.rgb(255, 0, 0));

    indicator.parameters:addString("Label" .. self.last_id, "Label", "", label);
end

function indi_alerts:AddSingleAlert(Label)
    self.last_id = self.last_id + 1;
    indicator.parameters:addGroup(Label .. " Alert");

    indicator.parameters:addBoolean("ON" .. self.last_id , "Show " .. Label .." Alert" , "", true);

    indicator.parameters:addFile("Up" .. self.last_id, Label .. " Sound", "", "");
    indicator.parameters:setFlag("Up" .. self.last_id, core.FLAG_SOUND);
    indicator.parameters:addInteger("UpSymbol" .. self.last_id, "Symbol", "", 217);
    indicator.parameters:addColor("UpColor" .. self.last_id, "Color", "", core.rgb(0, 255, 0));
    
    indicator.parameters:addString("Label" .. self.last_id, "Label", "", Label);
end

function indi_alerts:DrawAlert(context, alert, period)
    if not alert.Alert:hasData(period) then
        return;
    end

    if alert.Alert[period] == 1 then
        local x = context:positionOfBar(period);
        if alert.DrawingMode == "arrows" then
            visible, y = context:pointOfPrice(alert.AlertLevel[period]);
            width, height = context:measureText(self._stages[alert.Stage].FONT_ID, alert.UpSymbol, 0);
            local x1 = x - width / 2;
            local x2 = x + width / 2;
            local y1, y2;
            if self.inverted_arrows then
                y1 = y;
                y2 = y + height;
            else
                y1 = y - height;
                y2 = y;
            end
			context:drawText(self._stages[alert.Stage].FONT_ID, alert.UpSymbol, alert.UpColor, -1, x1, y1, x2, y2, 0);
        else
            context:drawLine(alert.UpLinePen, x, context:top(), x, context:bottom());
        end
	elseif alert.Alert[period] == -1 then
        local x = context:positionOfBar(period);
        if alert.DrawingMode == "arrows" then
            visible, y = context:pointOfPrice(alert.AlertLevel[period]);
            width, height = context:measureText(self._stages[alert.Stage].FONT_ID, alert.DownSymbol, 0);
            local x1 = x - width / 2;
            local x2 = x + width / 2;
            local y1, y2;
            if self.inverted_arrows then
                y1 = y - height;
                y2 = y;
            else
                y1 = y;
                y2 = y + height;
            end
            context:drawText(self._stages[alert.Stage].FONT_ID, alert.DownSymbol, alert.DownColor, -1, x1, y1, x2, y2, 0);
        else
            context:drawLine(alert.DownLinePen, x, context:top(), x, context:bottom());
        end
    end
end
indi_alerts.NextId = 1;
indi_alerts._stages = {};
function indi_alerts:Draw(stage, context)
    if self._stages[stage] == nil then
        self._stages[stage] = {};
        self._stages[stage].createFont = false;
        for _, level in ipairs(self.Alerts) do
            if level.Stage == stage then
                if level.DrawingMode == "vlines" then
                    level.UpLinePen = self.NextId;
                    self.NextId = self.NextId + 1;
                    level.DownLinePen = self.NextId;
                    self.NextId = self.NextId + 1;
                    context:createPen(level.UpLinePen, context.SOLID, 1, level.UpColor);
                    context:createPen(level.DownLinePen, context.SOLID, 1, level.DownColor);
                else
                    self._stages[stage].createFont = true;
                end
            end
        end
        if self._stages[stage].createFont and self._stages[stage].FONT_ID == nil then
            self._stages[stage].FONT_ID = self.NextId;
			self.NextId = self.NextId + 1;
            context:createFont(self._stages[stage].FONT_ID, "Wingdings", context:pointsToPixels(self.Size), context:pointsToPixels(self.Size), 0);
        end
    end
    for period = math.max(context:firstBar(), self.source:first()), math.min(context:lastBar(), self.source:size()-1), 1 do
        for _, level in ipairs(self.Alerts) do
            if level.Stage == stage then
                self:DrawAlert(context, level, period);
            end
        end
    end
end
indi_alerts.Alerts = {};
function indi_alerts:GetTimezone()
    local tz = instance.parameters.ToTime;
    if tz == 1 then
        return core.TZ_EST
    elseif tz == 2 then
        return core.TZ_UTC
    elseif tz == 3 then
        return core.TZ_LOCAL
    elseif tz == 4 then
        return core.TZ_SERVER
    elseif tz == 5 then
        return core.TZ_FINANCIAL
    elseif tz == 6 then
        return core.TZ_TS
    end
end
function indi_alerts:Prepare()
    self.Show = instance.parameters.Show;
    self.Live = instance.parameters.Live;
    self.ShowAlert = instance.parameters.ShowAlert;
    self.ToTime = self:GetTimezone();
    
    self.Size = instance.parameters.Size;
    self.SendEmail = instance.parameters.SendEmail;

    self.PlaySound = instance.parameters.PlaySound;
    local i;
    for i = 1, 100 do 
        local on = instance.parameters:getBoolean("ON" .. i);
        if on == nil then
            break;
        end 
        local alert = {};
        alert.id = i;
        alert.Stage = alert_stages[i];
        alert.Label = instance.parameters:getString("Label" .. i);
        alert.ON = on;
        alert.DrawingMode = instance.parameters:getString("drawing_mode" .. i);
        alert.UpSymbol = string.char(instance.parameters:getInteger("UpSymbol" .. i));
        local down_symbol = instance.parameters:getInteger("DownSymbol" .. i);
        if down_symbol ~= nil then
            alert.DownSymbol = string.char(down_symbol);
        end
        alert.UpColor = instance.parameters:getColor("UpColor" .. i);
        alert.DownColor = instance.parameters:getColor("DownColor" .. i);
        alert.Up = self.PlaySound and instance.parameters:getString("Up" .. i) or nil;
        alert.Down = self.PlaySound and instance.parameters:getString("Down" .. i) or nil;
        if alert.DownSymbol == nil then
            alert.DownSymbol = alert.UpSymbol;
            alert.DownColor = alert.UpColor;
            alert.Down = alert.Up;
        end
        assert(not(self.PlaySound) or (self.PlaySound and alert.Up ~= "") or (self.PlaySound and alert.Up ~= ""), "Sound file must be chosen"); 
        assert(not(self.PlaySound) or (self.PlaySound and alert.Down ~= "") or (self.PlaySound and alert.Down ~= ""), "Sound file must be chosen");
        alert.U = nil;
        alert.D = nil;
        if instance.parameters.strategy_output then
            alert.Alert = instance:addStream("strat_signal_" .. i, core.Dot, "strat_signal_" .. i, "Strategy signal #" .. i, core.rgb(0, 0, 0), 0, 0);
        else
            alert.Alert = instance:addInternalStream(0, 0);
        end
        alert.AlertLevel = instance:addInternalStream(0, 0);
        function alert:DownAlert(source, period, text, level, historical_period)
            shift = indi_alerts.Live ~= "Live" and 1 or 0;
            self.Alert[period] = -1;
            self.AlertLevel[period] = level;
            self.U = nil;
            if self.D ~= source:serial(period) and period == source:size() - 1 - shift and not indi_alerts.FIRST then
                self.D = source:serial(period);
                if not historical_period then
                    indi_alerts:SoundAlert(self.Down);
                    indi_alerts:EmailAlert(self.Label, text, period);
                    indi_alerts:SendAlert(self.Label, text, period);
                    if indi_alerts.Show then
                        indi_alerts:Pop(self.Label, text);
                    end
                end
            end
        end
        function alert:UpAlert(source, period, text, level, historical_period)
            shift = indi_alerts.Live ~= "Live" and 1 or 0;
            self.Alert[period] = 1;
            self.AlertLevel[period] = level;
            self.D = nil;
            if self.U ~= source:serial(period) and period == source:size() - 1 - shift and not indi_alerts.FIRST then
                self.U = source:serial(period);
                if not historical_period then
                    indi_alerts:SoundAlert(self.Up);
                    indi_alerts:EmailAlert(self.Label, text, period);
                    indi_alerts:SendAlert(self.Label, text, period);
                    if indi_alerts.Show then
                        indi_alerts:Pop(self.Label, text);
                    end
                end
            end
        end
        function alert:GetLast(period)
            for i = period, 0, -1 do
                if self.Alert:hasData(i) and self.Alert[i] ~= 0 then
                    return self.Alert[i], i, self.AlertLevel[i];
                end
            end
        end
        self.Alerts[#self.Alerts + 1] = alert;
    end

    self.Email = self.SendEmail and instance.parameters.Email or nil;
    assert(not(self.SendEmail) or (self.SendEmail and self.Email ~= ""), "E-mail address must be specified");
    self.RecurrentSound = instance.parameters.RecurrentSound;

    if instance.parameters.advanced_alert_key ~= "" and instance.parameters.use_advanced_alert then
        self._advanced_alert_key = instance.parameters.advanced_alert_key;
        require("http_lua");
        self._advanced_alert_timer = 1234;
        core.host:execute("setTimer", self._advanced_alert_timer, 1);
    end
end

function indi_alerts:Pop(label, note)
    core.host:execute("prompt", 1, label, self.source:instrument() .. " " .. label .. " : " .. note);
end

function indi_alerts:SoundAlert(Sound)
    if not self.PlaySound then
        return;
    end
    terminal:alertSound(Sound, self.RecurrentSound);
end

function indi_alerts:EmailAlert(label, Subject, period)
    if not self.SendEmail then
        return
    end

    local now = self.source:date(period);
    now = core.host:execute("convertTime", core.TZ_EST, self.ToTime, now);
    local DATA = core.dateToTable(now)
    local delim = "\013\010";  
    local Note = profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject;   
    local Symbol = "Instrument : " .. self.source:instrument() ;
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
    local TF = "Time Frame : " .. source:barSize()
    local text = Note  .. delim ..  Symbol .. delim .. TF .. delim .. Time;
    terminal:alertEmail(self.Email, profile:id(), text);
end

function indi_alerts:SendAlert(label, Subject, period)
    if not self.ShowAlert then
        return;
    end
    
    local now = self.source:date(period);
    now = core.host:execute("convertTime", core.TZ_EST, self.ToTime, now);
    local DATA = core.dateToTable(now)
    local delim = "\013\010";  
    local Note = profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject;
    local Symbol= "Instrument : " .. self.source:instrument() ;
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
    local TF = "Time Frame : " .. source:barSize()
    local text = Note  .. delim ..  Symbol .. delim .. TF .. delim .. Time;
    terminal:alertMessage(self.source:instrument(), self.source[NOW], text, self.source:date(NOW));
end

function indi_alerts:AlertTelegram(message, instrument, timeframe) local alert = {}; alert.Text = message or ""; alert.Instrument = instrument or ""; alert.TimeFrame = timeframe or ""; self._alerts[#self._alerts + 1] = alert; end
