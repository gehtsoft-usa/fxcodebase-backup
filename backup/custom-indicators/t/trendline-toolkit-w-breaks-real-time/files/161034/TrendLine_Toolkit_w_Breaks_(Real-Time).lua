-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76403
--
-- ── Author ─────────────────────────────────────────────────────────────────────
-- Developed by: Mario Jemic
-- Email:        mario.jemic@gmail.com
-- Website:      https://mario-jemic.com
--
-- ── Support & Donations ────────────────────────────────────────────────────────
-- PayPal:        https://goo.gl/9Rj74e
-- Patreon:       https://tiny.cc/1ybwxz
-- BuyMeACoffee:  https://tiny.cc/bj7vxz
--
-- Crypto:
--  BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
--  SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
--  ETH/BNB/USDT/XRP (ERC20 & BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
--
-- ── Copyright ──────────────────────────────────────────────────────────────────
-- © 2025 Gehtsoft USA LLC — https://fxcodebase.com

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- <https://www.gnu.org/licenses/>.


local vars = {};
function Init()
    indicator:name("TrendLine Toolkit w/ Breaks (Real-Time)");
    indicator:description("TrendLine Toolkit w/ Breaks (Real-Time)");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    vars["tp"] = "Choose an oscillator source of which to base the Toolkit on.";
    indicator.parameters:addString("param1", "Source", vars["tp"], "close");
    indicator.parameters:addStringAlternative("param1", "Open", "", "open");
    indicator.parameters:addStringAlternative("param1", "High", "", "high");
    indicator.parameters:addStringAlternative("param1", "Low", "", "low");
    indicator.parameters:addStringAlternative("param1", "Close", "", "close");
    indicator.parameters:addStringAlternative("param1", "Median", "", "median");
    indicator.parameters:addStringAlternative("param1", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("param1", "Weighted", "", "weighted");
    indicator.parameters:addStringAlternative("param1", "OHLC4", "", "ohlc4");
    indicator.parameters:addStringAlternative("param1", "HLCC4", "", "hlcc4");
    vars["td"] = "The Mid-Line value of the oscillator, for example RSI & MFI use 50.";
    indicator.parameters:addInteger("param2", "Zeroing", vars["td"], 50);
    vars["ts"] = "Calibrates the Sensitivity of which TrendLines are detected, higher values result in more detections.";
    indicator.parameters:addDouble("param3", "Sensitivity ％", vars["ts"], 40, 0, 100);
    indicator.parameters:addString("param4", "Display", "", "Both");
    indicator.parameters:addStringAlternative("param4", "Both", "", "Both");
    indicator.parameters:addStringAlternative("param4", "Lines", "", "Lines");
    indicator.parameters:addStringAlternative("param4", "Labels", "", "Labels");
    indicator.parameters:addBoolean("param5", "Bullish", "", true);
    indicator.parameters:addBoolean("param6", "Bearish", "", true);
    vars["colup"] = Graphics:AddTransparency(core.rgb(17, 207, 119), 0);
    indicator.parameters:addColor("param7", "Colors", "", Graphics:GetColor(vars["colup"]));
    vars["coldn"] = Graphics:AddTransparency(core.rgb(209, 22, 69), 0);
    indicator.parameters:addColor("param8", "", "", Graphics:GetColor(vars["coldn"]));
    signaler:Init(indicator.parameters);
end

local source;
local plot1;
local plot2;
function CreateType_bar(period, oValue, hValue, lValue, cValue, iValue)
    return {
        o = oValue or (source.open:tick(period)),
        h = hValue or (source.high:tick(period)),
        l = lValue or (source.low:tick(period)),
        c = cValue or (source.close:tick(period)),
        i = iValue or (period),
    };
end
function bar_Geto(self)
    if self == nil then return nil; end
    return self.o;
end
function bar_Seto(self, val)
    if self == nil then return nil; end
    self.o = val;
end
function bar_Geth(self)
    if self == nil then return nil; end
    return self.h;
end
function bar_Seth(self, val)
    if self == nil then return nil; end
    self.h = val;
end
function bar_Getl(self)
    if self == nil then return nil; end
    return self.l;
end
function bar_Setl(self, val)
    if self == nil then return nil; end
    self.l = val;
end
function bar_Getc(self)
    if self == nil then return nil; end
    return self.c;
end
function bar_Setc(self, val)
    if self == nil then return nil; end
    self.c = val;
end
function bar_Geti(self)
    if self == nil then return nil; end
    return self.i;
end
function bar_Seti(self, val)
    if self == nil then return nil; end
    self.i = val;
end
function CreateType_osc(period, oValue, sValue)
    return {
        o = oValue or (nil),
        s = sValue or (nil),
    };
end
function osc_Geto(self)
    if self == nil then return nil; end
    return self.o;
end
function osc_Seto(self, val)
    if self == nil then return nil; end
    self.o = val;
end
function osc_Gets(self)
    if self == nil then return nil; end
    return self.s;
end
function osc_Sets(self, val)
    if self == nil then return nil; end
    self.s = val;
end
function CreateType_trailstop(period, sValue, dValue)
    return {
        s = sValue or (nil),
        d = dValue or (nil),
    };
end
function trailstop_Gets(self)
    if self == nil then return nil; end
    return self.s;
end
function trailstop_Sets(self, val)
    if self == nil then return nil; end
    self.s = val;
end
function trailstop_Getd(self)
    if self == nil then return nil; end
    return self.d;
end
function trailstop_Setd(self, val)
    if self == nil then return nil; end
    self.d = val;
end
function CreateType_trendLine(period, xValue, yValue, lValue, sValue, bValue)
    return {
        x = xValue or (nil),
        y = yValue or (nil),
        l = lValue or (nil),
        s = sValue or (nil),
        b = bValue or (false),
    };
end
function trendLine_Getx(self)
    if self == nil then return nil; end
    return self.x;
end
function trendLine_Setx(self, val)
    if self == nil then return nil; end
    self.x = val;
end
function trendLine_Gety(self)
    if self == nil then return nil; end
    return self.y;
end
function trendLine_Sety(self, val)
    if self == nil then return nil; end
    self.y = val;
end
function trendLine_Getl(self)
    if self == nil then return nil; end
    return self.l;
end
function trendLine_Setl(self, val)
    if self == nil then return nil; end
    self.l = val;
end
function trendLine_Gets(self)
    if self == nil then return nil; end
    return self.s;
end
function trendLine_Sets(self, val)
    if self == nil then return nil; end
    self.s = val;
end
function trendLine_Getb(self)
    if self == nil then return nil; end
    return self.b;
end
function trendLine_Setb(self, val)
    if self == nil then return nil; end
    self.b = val;
end
function CreateType_alerts(period, sValue, bValue, xValue, yValue)
    return {
        s = sValue or (false),
        b = bValue or (false),
        x = xValue or (false),
        y = yValue or (false),
    };
end
function alerts_Gets(self)
    if self == nil then return nil; end
    return self.s;
end
function alerts_Sets(self, val)
    if self == nil then return nil; end
    self.s = val;
end
function alerts_Getb(self)
    if self == nil then return nil; end
    return self.b;
end
function alerts_Setb(self, val)
    if self == nil then return nil; end
    self.b = val;
end
function alerts_Getx(self)
    if self == nil then return nil; end
    return self.x;
end
function alerts_Setx(self, val)
    if self == nil then return nil; end
    self.x = val;
end
function alerts_Gety(self)
    if self == nil then return nil; end
    return self.y;
end
function alerts_Sety(self, val)
    if self == nil then return nil; end
    self.y = val;
end
function CreateType_prompt(period, sValue, cValue)
    return {
        s = sValue or (""),
        c = cValue or (false),
    };
end
function prompt_Gets(self)
    if self == nil then return nil; end
    return self.s;
end
function prompt_Sets(self, val)
    if self == nil then return nil; end
    self.s = val;
end
function prompt_Getc(self)
    if self == nil then return nil; end
    return self.c;
end
function prompt_Setc(self, val)
    if self == nil then return nil; end
    self.c = val;
end
function Create_atr__custom_i(len)
    local local_vars = {};
    local_vars["SMMA1_source"] = instance:addInternalStream(0, 0);
    local_vars["SMMA1"] = core.indicators:create("SMMA", local_vars["SMMA1_source"], len);
    return {
        Clear = function()
        end,
        GetValue = function(b, period, mode)
            local_vars["tr"] = Triary(bar_Geth(b) == nil, SafeMinus(bar_Geth(b), bar_Getl(b)), SafeMax(SafeMax(SafeMinus(bar_Geth(b), bar_Getl(b)), SafeAbs(SafeMinus(bar_Geth(b), bar_Getc(b)))), SafeAbs(SafeMinus(bar_Getl(b), bar_Getc(b)))));
            SafeSetFloat(local_vars["SMMA1_source"], period, local_vars["tr"]);
            local_vars["SMMA1"]:update(mode);
            return Triary((len == 1), local_vars["tr"], local_vars["SMMA1"].DATA:tick(period));
        end
    };
end
function Create_src_s(src)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(b, period, mode)
            if (src == "oc2") then
                local_vars["x"] = SafeDivide((SafePlus(bar_Geto(b), bar_Getc(b))), 2);
            elseif (src == "hl2") then
                local_vars["x"] = SafeDivide((SafePlus(bar_Geth(b), bar_Getl(b))), 2);
            elseif (src == "hlc3") then
                local_vars["x"] = SafeDivide((SafePlus(SafePlus(bar_Geth(b), bar_Getl(b)), bar_Getc(b))), 3);
            elseif (src == "ohlc4") then
                local_vars["x"] = SafeDivide((SafePlus(SafePlus(SafePlus(bar_Geto(b), bar_Geth(b)), bar_Getl(b)), bar_Getc(b))), 4);
            elseif (src == "hlcc4") then
                local_vars["x"] = SafeDivide((SafePlus(SafePlus(SafePlus(bar_Geth(b), bar_Getl(b)), bar_Getc(b)), bar_Getc(b))), 4);
            end
            return local_vars["x"];
        end
    };
end
function Create_st_i(len)
    local local_vars = {};
    local_vars["atr__customFunc2"] = Create_atr__custom_i(len);
    local_vars["srcFunc3"] = Create_src_s("oc2");
    local_vars["!up_stream"] = instance:addInternalStream(0, 0);
    local_vars["srcFunc4"] = Create_src_s("oc2");
    local_vars["!dn_stream"] = instance:addInternalStream(0, 0);
    local_vars["!atr_stream"] = instance:addInternalStream(0, 0);
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(b, factor, period, mode)
            if firstCall then
                firstCall = false;
                local_vars["atr__customFunc2"].Clear();
                local_vars["srcFunc3"].Clear();
                local_vars["srcFunc4"].Clear();
            else
            end
            local_vars["atr"] = local_vars["atr__customFunc2"].GetValue(b, period, mode);
            local_vars["up"] = SafePlus(local_vars["srcFunc3"].GetValue(b, period, mode), SafeMultiply(factor, local_vars["atr"]));
            SafeSetFloat(local_vars["!up_stream"], period, local_vars["up"]);
            local_vars["!up_stream_index"] = 1;
            local_vars["!up_stream_index"] = 1;
            local_vars["!up_stream_index"] = 1;
            local_vars["up"] = Triary((SafeLess(local_vars["up"], Nz(SafeGetFloat(local_vars["!up_stream"], local_vars["!up_stream_index"]))) or SafeGreater(bar_Getc(b), Nz(SafeGetFloat(local_vars["!up_stream"], local_vars["!up_stream_index"])))), local_vars["up"], Nz(SafeGetFloat(local_vars["!up_stream"], local_vars["!up_stream_index"])));
            local_vars["dn"] = SafeMinus(local_vars["srcFunc4"].GetValue(b, period, mode), SafeMultiply(factor, local_vars["atr"]));
            SafeSetFloat(local_vars["!dn_stream"], period, local_vars["dn"]);
            local_vars["!dn_stream_index"] = 1;
            local_vars["!dn_stream_index"] = 1;
            local_vars["!dn_stream_index"] = 1;
            local_vars["dn"] = Triary((SafeGreater(local_vars["dn"], Nz(SafeGetFloat(local_vars["!dn_stream"], local_vars["!dn_stream_index"]))) or SafeLess(bar_Getc(b), Nz(SafeGetFloat(local_vars["!dn_stream"], local_vars["!dn_stream_index"])))), local_vars["dn"], Nz(SafeGetFloat(local_vars["!dn_stream"], local_vars["!dn_stream_index"])));
            local_vars["st"] = nil;
            local_vars["dir"] = nil;
            SafeSetFloat(local_vars["!atr_stream"], period, local_vars["atr"]);
            local_vars["!atr_stream_index"] = 1;
            local_vars["!up_stream_index"] = 1;
            if SafeGetFloat(local_vars["!atr_stream"], local_vars["!atr_stream_index"]) == nil then
                local_vars["dir"] = 1;
            elseif (local_vars["st"] == Nz(SafeGetFloat(local_vars["!up_stream"], local_vars["!up_stream_index"]))) then
                local_vars["dir"] = Triary(SafeGreater(bar_Getc(b), local_vars["up"]), (-1));
                local_vars["dir"] = local_vars["dir"];
            else
                local_vars["dir"] = Triary(SafeLess(bar_Getc(b), local_vars["dn"]), (-1));
                local_vars["dir"] = local_vars["dir"];
            end
            local_vars["st"] = Triary((local_vars["dir"] == (-1)), local_vars["dn"], local_vars["up"]);
            return CreateType_trailstop(period, local_vars["st"], local_vars["dir"]);
        end
    };
end
function Create_exists()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(t, period, mode)
            return not (trendLine_Getx(t) == nil) and not (trendLine_Gety(t) == nil);
        end
    };
end
function Create_slope()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(t, period, mode)
            return SafeDivide((SafeMinus(chartpoint_Getprice(trendLine_Gety(t)), chartpoint_Getprice(trendLine_Getx(t)))), (SafeMinus(chartpoint_Getindex(trendLine_Gety(t)), chartpoint_Getindex(trendLine_Getx(t)))));
        end
    };
end
function Create_broke()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(t, o, period, mode)
            Line:SetExtend(trendLine_Getl(t), "none");
            Line:SetXY2(trendLine_Getl(t), bar_Geti(osc_Geto(o)), trendLine_Gets(t));
            return Line:Copy(trendLine_Getl(t));
        end
    };
end
function Create_dtl_i_b(m, p)
    local local_vars = {};
    local_vars["!mathex_max1_o.o.c"] = instance:addInternalStream(0, 0);
    local_vars["cross_1_x_src"] = instance:addInternalStream(0, 0);
    local_vars["cross_1_y_src"] = instance:addInternalStream(0, 0);
    local_vars["t"] = Variable:Create();
    local_vars["existsFunc6"] = Create_exists();
    local_vars["slopeFunc7"] = Create_slope();
    local_vars["slopeFunc8"] = Create_slope();
    local_vars["cross_2_x_src"] = instance:addInternalStream(0, 0);
    local_vars["cross_2_y_src"] = instance:addInternalStream(0, 0);
    local_vars["brokeFunc9"] = Create_broke();
    local_vars["brokeFunc10"] = Create_broke();
    local_vars["existsFunc11"] = Create_exists();
    Line:Prepare(500);
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(o, period, mode)
            if firstCall then
                firstCall = false;
        local_vars["t"]:Clear();
                local_vars["existsFunc6"].Clear();
                local_vars["slopeFunc7"].Clear();
                local_vars["slopeFunc8"].Clear();
                local_vars["brokeFunc9"].Clear();
                local_vars["brokeFunc10"].Clear();
                local_vars["existsFunc11"].Clear();
            else
            end
            SafeSetFloat(local_vars["!mathex_max1_o.o.c"], period, bar_Getc(osc_Geto(o)));
            local_vars["n"] = mathex.max(local_vars["!mathex_max1_o.o.c"], 0, period);
            SafeSetFloat(local_vars["cross_1_x_src"], period, bar_Getc(osc_Geto(o)));
            SafeSetFloat(local_vars["cross_1_y_src"], period, osc_Gets(o));
            local_vars["u"] = SafeCrossesOver(local_vars["cross_1_x_src"], local_vars["cross_1_y_src"], period) and (period ~= source:size() - 1 or mode == core.UpdateLast);
            if not local_vars["t"]:IsInitialized() then
                local_vars["t"]:Set(CreateType_trendLine(period));
            end
            trendLine_Setb(local_vars["t"]:Get(), false);
            trendLine_Sets(local_vars["t"]:Get(), Triary(local_vars["existsFunc6"].GetValue(local_vars["t"]:Get(), period, mode), Triary(trendLine_Gets(local_vars["t"]:Get()) == nil, (SafePlus(chartpoint_Getprice(trendLine_Gety(local_vars["t"]:Get())), local_vars["slopeFunc7"].GetValue(local_vars["t"]:Get(), period, mode))), (SafePlus(trendLine_Gets(local_vars["t"]:Get()), local_vars["slopeFunc8"].GetValue(local_vars["t"]:Get(), period, mode)))), nil));
            SafeSetFloat(local_vars["cross_2_x_src"], period, bar_Getc(osc_Geto(o)));
            SafeSetFloat(local_vars["cross_2_y_src"], period, trendLine_Gets(local_vars["t"]:Get()));
            if SafeCrossesUnder(local_vars["cross_2_x_src"], local_vars["cross_2_y_src"], period) and (period ~= source:size() - 1 or mode == core.UpdateLast) then
                local_vars["brokeFunc9"].GetValue(local_vars["t"]:Get(), o, period, mode);
                local_vars["t"]:Set(CreateType_trendLine(period));
                trendLine_Setb(local_vars["t"]:Get(), true);
            elseif SafeLess(local_vars["n"], trendLine_Gets(local_vars["t"]:Get())) and (period ~= source:size() - 1 or mode == core.UpdateLast) then
                local_vars["brokeFunc10"].GetValue(local_vars["t"]:Get(), o, period, mode);
                local_vars["t"]:Set(CreateType_trendLine(period));
                trendLine_Setb(local_vars["t"]:Get(), false);
            end
            if trendLine_Gety(local_vars["t"]:Get()) == nil and not (trendLine_Getx(local_vars["t"]:Get()) == nil) and SafeLess(bar_Getc(osc_Geto(o)), m) and local_vars["u"] then
                if SafeGreater(bar_Getl(osc_Geto(o)), chartpoint_Getprice(trendLine_Getx(local_vars["t"]:Get()))) then
                    trendLine_Sety(local_vars["t"]:Get(), ChartPoint:FromIndex(SafeMinus(bar_Geti(osc_Geto(o)), 1), bar_Getl(osc_Geto(o))));
                elseif SafeLess(bar_Getl(osc_Geto(o)), chartpoint_Getprice(trendLine_Getx(local_vars["t"]:Get()))) then
                    trendLine_Setx(local_vars["t"]:Get(), ChartPoint:FromIndex(SafeMinus(bar_Geti(osc_Geto(o)), 1), bar_Getl(osc_Geto(o))));
                end
            end
            if trendLine_Getx(local_vars["t"]:Get()) == nil and SafeLess(bar_Getc(osc_Geto(o)), m) and local_vars["u"] then
                trendLine_Setx(local_vars["t"]:Get(), ChartPoint:FromIndex(SafeMinus(bar_Geti(osc_Geto(o)), 1), bar_Getl(osc_Geto(o))));
            end
            if local_vars["existsFunc11"].GetValue(local_vars["t"]:Get(), period, mode) and trendLine_Getl(local_vars["t"]:Get()) == nil then
                trendLine_Setl(local_vars["t"]:Get(), Triary(p, Line:NewCP(trendLine_Getx(local_vars["t"]:Get()), trendLine_Gety(local_vars["t"]:Get())):SetColor(vars["colu"]):SetExtend("right"), nil));
            end
            return local_vars["t"]:Get();
        end
    };
end
function Create_utl_i_b(m, p)
    local local_vars = {};
    local_vars["!mathex_min1_o.o.c"] = instance:addInternalStream(0, 0);
    local_vars["cross_3_x_src"] = instance:addInternalStream(0, 0);
    local_vars["cross_3_y_src"] = instance:addInternalStream(0, 0);
    local_vars["t"] = Variable:Create();
    local_vars["existsFunc13"] = Create_exists();
    local_vars["slopeFunc14"] = Create_slope();
    local_vars["slopeFunc15"] = Create_slope();
    local_vars["cross_4_x_src"] = instance:addInternalStream(0, 0);
    local_vars["cross_4_y_src"] = instance:addInternalStream(0, 0);
    local_vars["brokeFunc16"] = Create_broke();
    local_vars["brokeFunc17"] = Create_broke();
    local_vars["existsFunc18"] = Create_exists();
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(o, period, mode)
            if firstCall then
                firstCall = false;
        local_vars["t"]:Clear();
                local_vars["existsFunc13"].Clear();
                local_vars["slopeFunc14"].Clear();
                local_vars["slopeFunc15"].Clear();
                local_vars["brokeFunc16"].Clear();
                local_vars["brokeFunc17"].Clear();
                local_vars["existsFunc18"].Clear();
            else
            end
            SafeSetFloat(local_vars["!mathex_min1_o.o.c"], period, bar_Getc(osc_Geto(o)));
            local_vars["n"] = mathex.min(local_vars["!mathex_min1_o.o.c"], 0, period);
            SafeSetFloat(local_vars["cross_3_x_src"], period, bar_Getc(osc_Geto(o)));
            SafeSetFloat(local_vars["cross_3_y_src"], period, osc_Gets(o));
            local_vars["d"] = SafeCrossesUnder(local_vars["cross_3_x_src"], local_vars["cross_3_y_src"], period) and (period ~= source:size() - 1 or mode == core.UpdateLast);
            if not local_vars["t"]:IsInitialized() then
                local_vars["t"]:Set(CreateType_trendLine(period));
            end
            trendLine_Setb(local_vars["t"]:Get(), false);
            trendLine_Sets(local_vars["t"]:Get(), Triary(local_vars["existsFunc13"].GetValue(local_vars["t"]:Get(), period, mode), Triary(trendLine_Gets(local_vars["t"]:Get()) == nil, (SafePlus(chartpoint_Getprice(trendLine_Gety(local_vars["t"]:Get())), local_vars["slopeFunc14"].GetValue(local_vars["t"]:Get(), period, mode))), (SafePlus(trendLine_Gets(local_vars["t"]:Get()), local_vars["slopeFunc15"].GetValue(local_vars["t"]:Get(), period, mode)))), nil));
            SafeSetFloat(local_vars["cross_4_x_src"], period, bar_Getc(osc_Geto(o)));
            SafeSetFloat(local_vars["cross_4_y_src"], period, trendLine_Gets(local_vars["t"]:Get()));
            if SafeCrossesOver(local_vars["cross_4_x_src"], local_vars["cross_4_y_src"], period) and (period ~= source:size() - 1 or mode == core.UpdateLast) then
                local_vars["brokeFunc16"].GetValue(local_vars["t"]:Get(), o, period, mode);
                local_vars["t"]:Set(CreateType_trendLine(period));
                trendLine_Setb(local_vars["t"]:Get(), true);
            elseif SafeGreater(local_vars["n"], trendLine_Gets(local_vars["t"]:Get())) and (period ~= source:size() - 1 or mode == core.UpdateLast) then
                local_vars["brokeFunc17"].GetValue(local_vars["t"]:Get(), o, period, mode);
                local_vars["t"]:Set(CreateType_trendLine(period));
                trendLine_Setb(local_vars["t"]:Get(), false);
            end
            if trendLine_Gety(local_vars["t"]:Get()) == nil and not (trendLine_Getx(local_vars["t"]:Get()) == nil) and SafeGreater(bar_Getc(osc_Geto(o)), m) and local_vars["d"] then
                if SafeLess(bar_Geth(osc_Geto(o)), chartpoint_Getprice(trendLine_Getx(local_vars["t"]:Get()))) then
                    trendLine_Sety(local_vars["t"]:Get(), ChartPoint:FromIndex(SafeMinus(bar_Geti(osc_Geto(o)), 1), bar_Geth(osc_Geto(o))));
                elseif SafeGreater(bar_Geth(osc_Geto(o)), chartpoint_Getprice(trendLine_Getx(local_vars["t"]:Get()))) then
                    trendLine_Setx(local_vars["t"]:Get(), ChartPoint:FromIndex(SafeMinus(bar_Geti(osc_Geto(o)), 1), bar_Geth(osc_Geto(o))));
                end
            end
            if trendLine_Getx(local_vars["t"]:Get()) == nil and SafeGreater(bar_Getc(osc_Geto(o)), m) and local_vars["d"] then
                trendLine_Setx(local_vars["t"]:Get(), ChartPoint:FromIndex(SafeMinus(bar_Geti(osc_Geto(o)), 1), bar_Geth(osc_Geto(o))));
            end
            if local_vars["existsFunc18"].GetValue(local_vars["t"]:Get(), period, mode) and trendLine_Getl(local_vars["t"]:Get()) == nil then
                trendLine_Setl(local_vars["t"]:Get(), Triary(p, Line:NewCP(trendLine_Getx(local_vars["t"]:Get()), trendLine_Gety(local_vars["t"]:Get())):SetColor(vars["cold"]):SetExtend("right"), nil));
            end
            return local_vars["t"]:Get();
        end
    };
end
function Create_notify()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(p, period, mode)
            if prompt_Getc(p) then
                if "once_per_bar_close" == "all" or local_vars["alert5_last_date"] ~= source:date(period) then
                    local_vars["alert5_last_date"] = source:date(period);
                    signaler:SignalEx(nil, prompt_Gets(p), period, source);
                end
            end
        end
    };
end
function Create_any()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(a, period, mode)
            if alerts_Gets(a) then
                local_vars["s"] = vars["upt"];
            elseif alerts_Getb(a) then
                local_vars["s"] = vars["dnt"];
            elseif alerts_Getx(a) then
                local_vars["s"] = vars["dnb"];
            elseif alerts_Gety(a) then
                local_vars["s"] = vars["upb"];
            else
                local_vars["s"] = nil;
            end
            return CreateType_prompt(period, local_vars["s"], not (local_vars["s"] == nil));
        end
    };
end
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    vars["src"] = PineScriptUtils:CreateSource(source, instance.parameters.param1);
    vars["trs"] = instance.parameters.param2;
    vars["mlt"] = instance.parameters.param3;
    vars["dsp"] = instance.parameters.param4;
    vars["brd"] = instance.parameters.param5;
    vars["bhd"] = instance.parameters.param6;
    vars["colup"] = Graphics:AddTransparency(core.rgb(17, 207, 119), 0);
    vars["colu"] = Graphics:AddTransparency(instance.parameters.param7, Graphics:GetTransparencyPercent(vars["colup"]));
    vars["coldn"] = Graphics:AddTransparency(core.rgb(209, 22, 69), 0);
    vars["cold"] = Graphics:AddTransparency(instance.parameters.param8, Graphics:GetTransparencyPercent(vars["coldn"]));
    vars["stFunc1"] = Create_st_i(10);
    vars["dtlFunc5"] = Create_dtl_i_b(vars["trs"], vars["brd"]);
    vars["utlFunc12"] = Create_utl_i_b(vars["trs"], vars["bhd"]);
    vars["existsFunc19"] = Create_exists();
    vars["!Change1_exists"] = instance:addInternalStream(0, 0);
    vars["existsFunc20"] = Create_exists();
    vars["existsFunc21"] = Create_exists();
    vars["!Change2_exists"] = instance:addInternalStream(0, 0);
    vars["existsFunc22"] = Create_exists();
    vars["colnt"] = Graphics:AddTransparency(core.rgb(123, 134, 53), 120);
    vars["dnb"] = "Bearish Breakout";
    plot1 = instance:createTextOutput("plot1", vars["dnb"], "Arial", 12, core.H_Center, core.V_Center, vars["colnt"]);
    vars["upb"] = "Bullish Breakout";
    plot2 = instance:createTextOutput("plot2", vars["upb"], "Arial", 12, core.H_Center, core.V_Center, vars["colnt"]);
    signaler:Prepare(nameOnly);
    vars["notifyFunc23"] = Create_notify();
    vars["anyFunc24"] = Create_any();
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Line:Clear();
        vars["stFunc1"].Clear();
        vars["dtlFunc5"].Clear();
        vars["utlFunc12"].Clear();
        vars["existsFunc19"].Clear();
        vars["existsFunc20"].Clear();
        vars["existsFunc21"].Clear();
        vars["existsFunc22"].Clear();
        vars["anyFunc24"].Clear();
        vars["notifyFunc23"].Clear();
    else
    end
    vars["_"] = "  \r\n                           +-----------------------+\r\n                           ┃       Constants       ┃\r\n                           +-----------------------+                                                                                                                                                                                   ";
    vars["ts"] = "Calibrates the Sensitivity of which TrendLines are detected, higher values result in more detections.";
    vars["td"] = "The Mid-Line value of the oscillator, for example RSI & MFI use 50.";
    vars["tp"] = "Choose an oscillator source of which to base the Toolkit on.";
    vars["tm"] = "Maximum timespan to detect a Divergence.";
    vars["gt"] = "TrendLine Settings";
    vars["gu"] = "UI Options";
    vars["dnt"] = "Bearish TrendLine";
    vars["upt"] = "Bullish TrendLine";
    vars["dnb"] = "Bearish Breakout";
    vars["upb"] = "Bullish Breakout";
    vars["colup"] = Graphics:AddTransparency(core.rgb(17, 207, 119), 0);
    vars["coldn"] = Graphics:AddTransparency(core.rgb(209, 22, 69), 0);
    vars["colsm"] = Graphics:AddTransparency(core.rgb(255, 94, 0), 0);
    vars["colnt"] = Graphics:AddTransparency(core.rgb(123, 134, 53), 120);
    vars["_"] = "  \r\n                           +-----------------------+\r\n                           ┃        Inputs         ┃\r\n                           +-----------------------+                                                                                                                                                                                   ";
    PineScriptUtils:UpdateSources(period, mode);
    vars["_"] = "  \r\n                           +-----------------------+\r\n                           ┃         UDTs          ┃\r\n                           +-----------------------+                                                                                                                                                                                   ";
    vars["_"] = "  \r\n                           +-----------------------+\r\n                           ┃        Methods        ┃\r\n                           +-----------------------+                                                                                                                                                                                   ";
    vars["_"] = "  \r\n                           +-----------------------+\r\n                           ┃         Calc          ┃\r\n                           +-----------------------+                                                                                                                                                                                   ";
    vars["b"] = CreateType_bar(period, Nz(vars["src"]:tick(period - 1)), SafeMax(Nz(vars["src"]:tick(period - 1)), vars["src"]:tick(period)), SafeMin(Nz(vars["src"]:tick(period - 1)), vars["src"]:tick(period)), vars["src"]:tick(period));
    vars["f"] = SafePlus(1, (100 - vars["mlt"]) / 100);
    vars["st"] = vars["stFunc1"].GetValue(vars["b"], vars["f"], period, mode);
    vars["o"] = CreateType_osc(period, vars["b"], trailstop_Gets(vars["st"]));
    vars["d"] = vars["dtlFunc5"].GetValue(vars["o"], period, mode);
    vars["u"] = vars["utlFunc12"].GetValue(vars["o"], period, mode);
    SafeSetBool(vars["!Change1_exists"], period, vars["existsFunc20"].GetValue(vars["d"], period, mode));
    SafeSetBool(vars["!Change2_exists"], period, vars["existsFunc22"].GetValue(vars["u"], period, mode));
    vars["a"] = CreateType_alerts(period, vars["existsFunc19"].GetValue(vars["d"], period, mode) and not (Change(vars["!Change1_exists"], 1, period)), vars["existsFunc21"].GetValue(vars["u"], period, mode) and not (Change(vars["!Change2_exists"], 1, period)), trendLine_Getb(vars["d"]), trendLine_Getb(vars["u"]));
    vars["_"] = "  \r\n                           +-----------------------+\r\n                           ┃        Visuals        ┃\r\n                           +-----------------------+                                                                                                                                                                                   ";
    PlotShape:SetValue(plot1, period, source, Triary(trendLine_Getb(vars["d"]) and vars["brd"] and (vars["dsp"] ~= "Lines"), osc_Gets(vars["o"]), nil), "𝐁▾", "𝐁▾", "absolute", vars["colnt"]);
    PlotShape:SetValue(plot2, period, source, Triary(trendLine_Getb(vars["u"]) and vars["bhd"] and (vars["dsp"] ~= "Lines"), osc_Gets(vars["o"]), nil), "𝐁▴", "𝐁▴", "absolute", vars["colnt"]);
    vars["_"] = "  \r\n                           +-----------------------+\r\n                           ┃        Alerts         ┃\r\n                           +-----------------------+                                                                                                                                                                                   ";
    if alerts_Gets(vars["a"]) and period == source:size() - 1 then
        signaler:SignalEx(1, vars["upt"], period, source);
    end
    if alerts_Getb(vars["a"]) and period == source:size() - 1 then
        signaler:SignalEx(2, vars["dnt"], period, source);
    end
    if alerts_Getx(vars["a"]) and period == source:size() - 1 then
        signaler:SignalEx(3, vars["dnb"], period, source);
    end
    if alerts_Gety(vars["a"]) and period == source:size() - 1 then
        signaler:SignalEx(4, vars["upb"], period, source);
    end
    vars["notifyFunc23"].GetValue(vars["anyFunc24"].GetValue(vars["a"], period, mode), period, mode);
end
function Draw(stage, context)
    Line:Draw(stage, context);
end
function ReleaseInstance()
    signaler:ReleaseInstance();
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    signaler:AsyncOperationFinished(cookie, success, message, message1, message2);
end
Graphics = {};
Graphics.NextId = 1;
Graphics.Pens = {};
Graphics.Brushes = {};
Graphics.Fonts = {};
function Graphics:FindPen(width, color, style, context)
    if color == nil then
        return -1;
    end
    for i, pen in ipairs(Graphics.Pens) do
        if pen.Width == width and pen.Color == color then
            context:createPen(pen.Id, context:convertPenStyle(style), width, color);
            return pen.Id;
        end
    end
    local newPen = {};
    newPen.Id = Graphics.NextId;
    newPen.Width = width;
    newPen.Color = color;

    context:createPen(newPen.Id, context:convertPenStyle(style), width, color);
    Graphics.NextId = Graphics.NextId + 1;
    Graphics.Pens[#Graphics.Pens + 1] = newPen;
    return newPen.Id;
end
function Graphics:FindBrush(color, context)
    if color == nil then
        return -1;
    end
    for i, brush in ipairs(Graphics.Brushes) do
        if brush.Color == color then
            context:createSolidBrush(brush.Id, color)
            return brush.Id;
        end
    end
    local newBrush = {};
    newBrush.Id = Graphics.NextId;
    newBrush.Color = color;
    context:createSolidBrush(newBrush.Id, color)
    Graphics.NextId = Graphics.NextId + 1;
    Graphics.Brushes[#Graphics.Brushes + 1] = newBrush;
    return newBrush.Id;
end
function Graphics:FindFont(font, xSize, ySize, corner, context)
    for i, font in ipairs(self.Fonts) do
        if font.xSize == xSize and font.Name == font then
            return font.Id;
        end
    end
    local newFont = {};
    newFont.Id = Graphics.NextId;
    newFont.xSize = xSize;
    newFont.Name = font;
    context:createFont(newFont.Id, font, 0, xSize, context.LEFT);
    Graphics.NextId = Graphics.NextId + 1;
    Graphics.Fonts[#Graphics.Fonts + 1] = newFont;
    return newFont.Id;
end
function Graphics:SplitColorAndTransparency(clr)
    if clr == nil then
        return nil, nil;
    end
    local transparency = (math.floor(clr / 16777216) % 255);
    local color = clr - transparency * 16777216;
    return color, transparency;
end
function Graphics:GetColor(clr)
    local color, transparency = self:SplitColorAndTransparency(clr);
    return color;
end
function Graphics:GetTransparency(clr)
    local color, transparency = self:SplitColorAndTransparency(clr);
    return transparency;
end
function Graphics:GetTransparencyPercent(clr)
    local color, transparency = self:SplitColorAndTransparency(clr);
    if transparency == nil then
        return nil;
    end
    return math.floor(transparency * 100.0 / 255.0 + 0.5);
end
function Graphics:AddTransparency(clr, transp)
    if clr == nil or transp == nil then
        return nil;
    end
    color, _ = Graphics:SplitColorAndTransparency(clr);
    return color + math.floor(transp / 100 * 255) * 16777216;
end
PineScriptUtils = {};
PineScriptUtils.Sources = {};
function PineScriptUtils:CreateSource(source, sourceType)
    if sourceType ~= "ohlc4" then
        return source[sourceType];
    end
    local newSource = {};
    newSource.Stream = instance:addInternalStream(0, 0);
    function newSource:Update(period, mode)
        self.Stream[period] = (source.open[period] + source.high[period] + source.low[period] + source.close[period]) / 4;
    end
    self.Sources[#self.Sources + 1] = newSource;
    return newSource.Stream;
end
function PineScriptUtils:UpdateSources(period, mode)
    for i, src in ipairs(self.Sources) do
        src:Update(period, mode);
    end
end
function PineScriptUtils:TimeframeFromLength(length)
    if length == "t" then
        return "t1"
    elseif length == "D" then
        return "D1";
    elseif length == "W" then
        return "W1";
    elseif length == "M" then
        return "M1";
    end
    local length_number = tonumber(length);
    if length_number < 3600 then
        return "m" .. tostring(length_number / 60);
    end
    return "H" .. tostring(length_number / 3600)
end
function PineScriptUtils:ParseSession(session)
    local session_info = {};
    local _, _, from_hour, from_minute, to_hour, to_minute = string.find(session, "(%d%d)(%d%d)-(%d%d)(%d%d)");
    session_info.from_hour = from_hour and tonumber(from_hour) or 0;
    session_info.from_minute = from_minute and tonumber(from_minute) or 0;
    session_info.from = (session_info.from_hour * 60.0 + session_info.from_minute) * 60.0;
    session_info.to_hour = to_hour and tonumber(to_hour) or 23;
    session_info.to_minute = to_minute and tonumber(to_minute) or 59;
    session_info.to = (session_info.to_hour * 60.0 + session_info.to_minute) * 60.0;
    function session_info:IsInRange(time)
        time = math.floor(time * 86400 + 0.5);
        if self.from < self.to then
            return time >= self.from and time <= self.to;
        end
        if self.from > self.to then
            return time > self.from or time < self.to;
        end
    
        return time == self.from;
    end
    return session_info;
end
function PineScriptUtils:Time(period, timeframe_length, session, timezone)
    local timeframe = PineScriptUtils:TimeframeFromLength(timeframe_length);
    if PineScriptUtils.tradingWeekOffset == nil then
        PineScriptUtils.tradingWeekOffset = core.host:execute("getTradingWeekOffset");
        PineScriptUtils.tradingDayOffset = core.host:execute("getTradingDayOffset");
    end
    local s, e = core.getcandle(timeframe, instance.source:date(period), PineScriptUtils.tradingDayOffset, PineScriptUtils.tradingWeekOffset);
    local session_info = PineScriptUtils:ParseSession(session);
    if not session_info:IsInRange(s % 1) then
        return nil;
    end
    
    return s * 86400000;
end
function PineScriptUtils:WeekOfYear(time, timezone)
    local time_ole = time / 86400000;
    local date_table = core.dateToTable(time_ole)
    date_table.month = 1;
    date_table.day = 1;
    date_table.hour = 0;
    date_table.min = 0;
    date_table.sec = 0;
    local first_day_ole = core.tableToDate(date_table);
    date_table = core.dateToTable(first_day_ole);
    first_day_ole = first_day_ole - date_table.wday + 1;
    return math.floor(time_ole - first_day_ole / 7);
end

function Timestamp(year, month, day, hour, minute, second, tz)
    local date = {};
    date.month = month;
    date.day = day;
    date.year = year;
    date.hour = hour;
    date.min = minute;
    date.sec = second;
    return core.tableToDate(date);
end

function BarSizeInMS(barSize)
    local s, e = core.getcandle(barSize, core.now(), 0, 0)
    return (e - s) * 86400000;
end

function NumberToBool(n)
    return n ~= nil and n ~= 0;
end

function GetTrueRange(source, period)
    if period == 0 then
        return nil;
    end
    local num1 = math.abs(source.high[period] - source.low[period]);
    local num2 = math.abs(source.high[period] - source.close[period - 1]);
    local num3 = math.abs(source.close[period - 1] - source.low[period]);
    return math.max(num1, num2, num3);
end
function SafeMinus(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left - right;
end
function SafeMultiply(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left * right;
end
function SafePlus(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left + right;
end
function SafeConcat(left, right)
    if left == nil then
        return right;
    end
    if right == nil then
        return left;
    end
    return left .. right;
end
function SafeDivide(left, right)
    if left == nil or right == nil or right == 0 then
        return nil;
    end
    return left / right;
end
function SafeGreater(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left > right;
end
function SafeGE(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left >= right;
end
function SafeLess(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left < right;
end
function SafeLE(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return left <= right;
end
function SafeMax(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return math.max(left, right);
end
function SafeMin(left, right)
    if left == nil or right == nil then
        return nil;
    end
    return math.min(left, right);
end
function SafeAbs(value)
    if value == nil then
        return nil;
    end
    return math.abs(value);
end
function SafeNegative(left)
    if left == nil then
        return nil;
    end
    return -left;
end
function SafeSetBool(stream, period, value)
    if period == nil then
        return;
    end
    if value == nil then
        stream:setNoData(period);
        return;
    end
    stream[period] = value and 1 or 0;
end
function SafeGetBool(stream, period)
    if stream == nil or period == nil or not stream:hasData(period) then
        return nil;
    end
    return stream[period] == 1;
end
function SafeSetFloat(stream, period, value)
    if period == nil then
        return;
    end
    if value == nil then
        stream:setNoData(period);
        return;
    end
    stream[period] = value;
end
function SafeGetFloat(stream, period)
    if stream == nil or period == nil then
        return nil;
    end
    if not stream:hasData(period) then
        return nil;
    end
    return stream[period];
end
function Float(number)
    return number and number or nil;
end
function Int(number)
    return number and number or nil;
end
function Color(color)
    return color and color or nil;
end
function ToLine(line)
    return line;
end
function ToBox(box)
    return box;
end
function Round(num, idp)
    if num == nil then
        return nil;
    end
    if idp and idp > 0 then
        local mult = 10 ^ idp
        return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end
function Nz(value, defaultValue)
    if defaultValue == nil then
        defaultValue = 0;
    end
    return value and value or defaultValue;
end
function Triary(condition, trueValue, falseValue)
    if condition == nil or condition == false then
        return falseValue;
    end
    return trueValue;
end
function SafeCrossesUnder(val1, val2, period)
    if val1 == nil or val2 == nil or period < 2 then
        return false;
    end
    return core.crossesUnder(val1, val2, period);
end
function SafeCrossesOver(val1, val2, period)
    if val1 == nil or val2 == nil or period < 2 then
        return false;
    end
    return core.crossesOver(val1, val2, period);
end
function SafeCrosses(val1, val2, period)
    if val1 == nil or val2 == nil or period < 2 then
        return false;
    end
    return core.crosses(val1, val2, period);
end
function SafeCos(val)
    if val == nil then
        return nil;
    end
    return math.cos(val);
end
function SafeSin(val)
    if val == nil then
        return nil;
    end
    return math.sin(val);
end
function SafeMathExMax(source, period, length)
    if source:size() < length then
        return nil;
    end
    return mathex.max(source, core.rangeTo(period, length));
end
function SafeMathExMin(source, period, length)
    if source:size() < length then
        return nil;
    end
    return mathex.min(source, core.rangeTo(period, length));
end
function SafeMathExStdev(source, period, length)
    if source:size() < length then
        return nil;
    end
    return mathex.stdev(source, core.rangeTo(period, length));
end
Variable = {};
function Variable:Create()
    local var = {};
    var._init = false;
    function var:Clear()
        self._init = false;
        self._value = nil;
    end
    function var:Get()
        return self._value;
    end
    function var:Set(value)
        self._value = value;
        self._init = true;
    end
    function var:IsInitialized()
        return self._value;
    end
    return var;
end
ChartPoint = {};
function ChartPoint:FromIndex(index, price)
    core.host:trace("CP " .. tostring(index) .. " " .. tostring(price))
    local point = {};
    point.x = index;
    point.y = price;
    return point;
end
function chartpoint_Getprice(chartPoint)
    if chartPoint == nil then
        return nil;
    end
    return chartPoint.y;
end
function chartpoint_Getindex(chartPoint)
    if chartPoint == nil then
        return nil;
    end
    return chartPoint.x;
end
Line = {};
Line.AllLines = {};
function Line:GetAll()
    local array = {};
    array.arr = Line.AllLines;
    return array;
end
function Line:Clear()
    Line.AllLines = {};
end
function Line:Prepare(max_lines_count)
    Line.max_lines_count = max_lines_count;
end
function Line:GetPrice(line, x)
    if line == nil then
        return nil;
    end
    return line:GetPrice(x);
end
function Line:SetXY1(line, x, y)
    if line == nil then
        return;
    end
    line:SetXY1(x, y);
end
function Line:SetXY2(line, x, y)
    if line == nil then
        return;
    end
    line:SetXY2(x, y);
end
function Line:SetX1(line, x)
    if line == nil then
        return;
    end
    line:SetX1(x);
end
function Line:SetX2(line, x)
    if line == nil then
        return;
    end
    line:SetX2(x);
end
function Line:SetY1(line, y)
    if line == nil then
        return;
    end
    line:SetY1(y);
end
function Line:SetY2(line, y)
    if line == nil then
        return;
    end
    line:SetY2(y);
end
function Line:GetX1(line)
    if line == nil then
        return;
    end
    return line:GetX1();
end
function Line:GetX2(line)
    if line == nil then
        return;
    end
    return line:GetX2();
end
function Line:GetY1(line)
    if line == nil then
        return;
    end
    return line:GetY1();
end
function Line:GetY2(line)
    if line == nil then
        return;
    end
    return line:GetY2();
end
function Line:SetColor(line, clr)
    if line == nil then
        return;
    end
    line:SetColor(clr);
end
function Line:SetWidth(line, width)
    if line == nil then
        return;
    end
    line:SetWidth(width);
end
function Line:SetStyle(line, style)
    if line == nil then
        return;
    end
    line:SetStyle(style);
end
function Line:SetExtend(line, extend)
    if line == nil then
        return;
    end
    line:SetExtend(extend);
end
function Line:SetXLoc(line, x1, x2, xloc)
    if line == nil then
        return;
    end
    line:SetXLoc(x1, x2, xloc);
end
function Line:Copy(line)
    if line == nil then
        return nil;
    end
    local newLine = Line:New(line.X1, line.Y1, line.X2, line.Y2);
    newLine.XLoc = line.XLoc;
    newLine.Color = line.Color;
    newLine.Width = line.Width;
    newLine.Extend = line.Extend;
    newLine.Style = line.Style;
    return newLine;
end
function Line:NewCP(p1, p2)
    return Line:New(p1.x, p1.y, p2.x, p2.y);
end
function Line:New(x1, y1, x2, y2)
    local newLine = {};
    newLine.X1 = x1;
    newLine.Y1 = y1;
    newLine.X2 = x2;
    newLine.Y2 = y2;
    function newLine:SetXY1(x, y)
        self.X1 = x;
        self.Y1 = y;
        return self;
    end
    function newLine:SetXY2(x, y)
        self.X2 = x;
        self.Y2 = y;
        return self;
    end
    function newLine:SetX1(x)
        self.X1 = x;
        return self;
    end
    function newLine:SetX2(x)
        self.X2 = x;
        return self;
    end
    newLine.XLoc = "bar_index";
    function newLine:SetXLoc(x1, x2, xloc)
        newLine.X1 = x1;
        newLine.X2 = x2;
        newLine.XLoc = xloc;
        return self;
    end
    function newLine:SetY1(y)
        self.Y1 = y;
        return self;
    end
    function newLine:SetY2(y)
        self.Y2 = y;
        return self;
    end
    function newLine:GetX1()
        return self.X1;
    end
    function newLine:GetX2()
        return self.X2;
    end
    function newLine:GetY1()
        return self.Y1;
    end
    function newLine:GetY2()
        return self.Y2;
    end
    newLine.Color = core.colors().Blue;
    function newLine:SetColor(clr)
        self.ColorTransparency = (math.floor(clr / 16777216) % 255);
        self.Color = clr - self.ColorTransparency * 16777216;
        self.PenId = nil;
        return self;
    end
    newLine.Width = 1;
    function newLine:SetWidth(width)
        self.Width = width;
        self.PenId = nil;
        return self;
    end
    newLine.Extend = "none";
    function newLine:SetExtend(extend)
        self.Extend = extend;
        return self;
    end
    newLine.Style = "solid";
    function newLine:SetStyle(style)
        self.Style = style;
        self.PenId = nil;
        return self;
    end
    function newLine:GetPrice(x)
        local a, c = math2d.lineEquation(self.X1, self.Y1, self.X2, self.Y2);
        return a * x + c;
    end
    function newLine:getStyleForContext()
        if self.Style == "solid" or self.Style == "arrow_left" or self.Style == "arrow_both" or self.Style == "arrow_right" then
            return core.LINE_SOLID;
        elseif self.Style == "dotted" then
            return core.LINE_DOT;
        elseif self.Style == "dashed" then
            return core.LINE_DASH;
        end
        return core.LINE_SOLID;
    end
    function newLine:converXToPoints(context, x)
        if self.XLoc == "bar_time" then
            return context:positionOfDate(x / 86400000);
        end
        local _, x1 = context:positionOfBar(x);
        return x1;
    end
    function newLine:Draw(stage, context)
        if self.Y1 == nil or self.Y2 == nil or self.X1 == nil or self.X2 == nil or self.Width == nil then
            return;
        end
        if self.PenId == nil then
            self.PenId = Graphics:FindPen(self.Width, self.Color, self:getStyleForContext(), context);
        end
        local x1;
        local x2;
        if (self.XLoc == "bar_time") then
            _, x1 = context:positionOfDate(self.X1 / 86400000.0)
            _, x2 = context:positionOfDate(self.X2 / 86400000.0)
        else
            x1 = self:converXToPoints(context, self.X1);
            x2 = self:converXToPoints(context, self.X2);
        end
        local _, y1 = context:pointOfPrice(self.Y1);
        local _, y2 = context:pointOfPrice(self.Y2);
        context:drawLine(self.PenId, x1, y1, x2, y2, self.ColorTransparency);
        if self.Extend == "right" or self.Extend == "both" then
            if x1 == x2 then
                if y1 >= y2 then
                    context:drawLine(self.PenId, x1, y1, x1, context:top(), self.ColorTransparency);
                else
                    context:drawLine(self.PenId, x1, y1, x1, context:bottom(), self.ColorTransparency);
                end
            else
                local a, c = math2d.lineEquation(x1, y1, x2, y2);
                if a ~= nil and c ~= nil then
                    local y3 = a * context:right() + c;
                    context:drawLine(self.PenId, x2, y2, context:right(), y3, self.ColorTransparency);
                end
            end
        end
        if self.Extend == "left" or self.Extend == "both" then
            if x1 == x2 then
                if y1 >= y2 then
                    context:drawLine(self.PenId, x1, y2, x1, context:bottom(), self.ColorTransparency);
                else
                    context:drawLine(self.PenId, x1, y2, x1, context:top(), self.ColorTransparency);
                end
            else
                local a, c = math2d.lineEquation(x1, y1, x2, y2);
                if a ~= nil and c ~= nil then
                    local y3 = a * context:left() + c;
                    context:drawLine(self.PenId, x1, y1, context:left(), y3, self.ColorTransparency);
                end
            end
        end
    end
    Line:AddNewLine(newLine);
    return newLine;
end
function Line:AddNewLine(newLine)
    self.AllLines[#self.AllLines + 1] = newLine;
    if #self.AllLines > self.max_lines_count then
        table.remove(self.AllLines, 1);
    end
end
function Line:Delete(line)
    for i = 1, #self.AllLines do
        if self.AllLines[i] == line then
            table.remove(self.AllLines, i);
            return;
        end
    end
end
function Line:Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    for i, value in ipairs(self.AllLines) do
        value:Draw(stage, context);
    end
end
function Change(source, length, period)
    if period < length then
        return nil;
    end
    if not source:hasData(period) or not source:hasData(period - length) then
        return nil;
    end
    return source[period] - source[period - length];
end
PlotShape = {};
function PlotShape:SetValue(plot, period, source, value, text, label, location, color)
    local clr, transp = Graphics:SplitColorAndTransparency(color);
    if not value or transp == 100 or clr == nil then
        plot:setNoData(period);
        return;
    end
    if location == "abovebar" or location == "top" then
        plot:set(period, source.high[period], text, label, clr);
        return;
    end
    if location == "belowbar" or location == "bottom" then
        plot:set(period, source.low[period], text, label, clr);
        return;
    end
    plot:set(period, value, text, label, clr);
end
signaler = {};
signaler.Name = "Signaler";
signaler.Debug = false;
signaler.Version = "1.7";

signaler._show_alert = nil;
signaler._sound_file = nil;
signaler._recurrent_sound = nil;
signaler._email = nil;
signaler._ids_start = nil;
signaler._advanced_alert_timer = nil;
signaler._tz = nil;
signaler._alerts = {};
signaler._commands = {};
signaler.lastIndexSerial = {};

function signaler:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function signaler:OnNewModule(module) end
function signaler:RegisterModule(modules) 
    if modules == nil then
        self._ids_start = 100; 
        return;
    end
    for _, module in pairs(modules) do 
        self:OnNewModule(module); 
        module:OnNewModule(self); 
    end 
    modules[#modules + 1] = self; 
    self._ids_start = (#modules) * 100; 
end

function signaler:ToJSON(item)
    local json = {};
    function json:AddStr(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":\"%s\"", separator, tostring(name), tostring(value));
    end
    function json:AddNumber(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":%f", separator, tostring(name), value or 0);
    end
    function json:AddBool(name, value)
        local separator = "";
        if self.str ~= nil then
            separator = ",";
        else
            self.str = "";
        end
        self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), value and "true" or "false");
    end
    function json:ToString()
        return "{" .. (self.str or "") .. "}";
    end
    
    local first = true;
    for idx,t in pairs(item) do
        local stype = type(t)
        if stype == "number" then
            json:AddNumber(idx, t);
        elseif stype == "string" then
            json:AddStr(idx, t);
        elseif stype == "boolean" then
            json:AddBool(idx, t);
        elseif stype == "function" or stype == "table" then
            --do nothing
        else
            core.host:trace(tostring(idx) .. " " .. tostring(stype));
        end
    end
    return json:ToString();
end

function signaler:ArrayToJSON(arr)
    local str = "[";
    for i, t in ipairs(self._alerts) do
        local json = self:ToJSON(t);
        if str == "[" then
            str = str .. json;
        else
            str = str .. "," .. json;
        end
    end
    return str .. "]";
end

function signaler:AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == self._advanced_alert_timer and (self.last_req == nil or not self.last_req:loading()) then
        if #self._alerts > 0 then
            local data = self:ArrayToJSON(self._alerts);
            self._alerts = {};
            
            self.last_req = http_lua.createRequest();
            local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
                self._advanced_alert_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
            self.last_req:setRequestHeader("Content-Type", "application/json");
            self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

            self.last_req:start("https://profitrobots.com/api/v1/notification", "POST", query);
        elseif #self._commands > 0 then
            local data = self:ArrayToJSON(self._commands);
            self._commands = {};
            
            self.last_req = http_lua.createRequest();
            local query = string.format('{"Key":"%s","StrategyName":"%s","Platform":"FXTS2","Notifications":%s}',
                self._external_executer_key, string.gsub(self.StrategyName or "", '"', '\\"'), data);
            self.last_req:setRequestHeader("Content-Type", "application/json");
            self.last_req:setRequestHeader("Content-Length", tostring(string.len(query)));

            self.last_req:start("https://profitrobots.com/api/v1/notification", "POST", query);
        end
    end
end
function signaler:FormatEmail(source, period, message)
    --format email subject
    local subject = message .. "(" .. source:instrument() .. ")";
    --format email text
    local delim = "\013\010";
    local signalDescr = "Signal: " .. (self.StrategyName or "");
    local symbolDescr = "Symbol: " .. source:instrument();
    local messageDescr = "Message: " .. message;
    local ttime = core.dateToTable(core.host:execute("convertTime", core.TZ_EST, self._ToTime, source:date(period)));
    local dateDescr = string.format("Time:  %02i/%02i %02i:%02i", ttime.month, ttime.day, ttime.hour, ttime.min);
    local priceDescr = "Price: " .. source[period];
    local text = "You have received this message because the following signal alert was received:"
        .. delim .. signalDescr .. delim .. symbolDescr .. delim .. messageDescr .. delim .. dateDescr .. delim .. priceDescr;
    return subject, text;
end
function signaler:getSource(source)
    if source == nil then
        if instance.source ~= nil then
            source = instance.source;
        elseif instance.bid ~= nil then
            source = instance.bid;
        else
            local pane = core.host.Window.CurrentPane;
            source = pane.Data:getStream(0);
        end
    end
    return source;
end
function signaler:SignalEx(index, message, period, source)
    source = self:getSource(source);
    if index ~= nil then
        if (self.lastIndexSerial[index] == source:serial(period)) then
            return;
        end
        self.lastIndexSerial[index] = source:serial(period);
    end
    local interval = string.find(message, "{{interval}}");
    if interval ~= nil then
        message = string.sub(message, 1, interval - 1)
            .. source:barSize()
            .. string.sub(message, interval + string.len("{{interval}}"));
    end
    local close = string.find(message, "{{close}}");
    if close ~= nil then
        message = string.sub(message, 1, interval - 1)
            .. win32.formatNumber(source.close[period], false, source:getDisplayPrecision())
            .. string.sub(message, interval + string.len("{{close}}"));
    end
    self:Signal(message, source);
end
function signaler:Signal(message, source)
    source = self:getSource(source);
    if self._show_alert then
        terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW));
    end

    if self._sound_file ~= nil then
        terminal:alertSound(self._sound_file, self._recurrent_sound);
    end

    if self._email ~= nil then
        terminal:alertEmail(self._email, profile:id().. " : " .. message, self:FormatEmail(source, NOW, message));
    end

    if self._advanced_alert_key ~= nil then
        self:AlertTelegram(message, source:instrument(), source:barSize());
    end

    if self._signaler_debug_alert then
        core.host:trace(message);
    end

    if self._show_popup then
        local subject, text = self:FormatEmail(source, NOW, message);
        core.host:execute("prompt", self._ids_start + 2, subject, text);
    end

    if self._dde_alerts then
        dde_server:set(self.dde_topic, self.dde_alerts, message);
    end
end

function signaler:SendCommand(command)
    if self._external_executer_key == nil or core.host.Trading:getTradingProperty("isSimulation") or command == "" then
        return;
    end
    local command = 
    {
        Text = command
    };
    self._commands[#self._commands + 1] = command;
end

function signaler:AlertTelegram(message, instrument, timeframe)
    if core.host.Trading:getTradingProperty("isSimulation") then
        return;
    end
    local alert = {};
    alert.Text = message or "";
    alert.Instrument = instrument or "";
    alert.TimeFrame = timeframe or "";
    self._alerts[#self._alerts + 1] = alert;
end

function signaler:Init(parameters)
    parameters:addInteger("signaler_ToTime", "Convert the date to", "", 6)
    parameters:addIntegerAlternative("signaler_ToTime", "EST", "", 1)
    parameters:addIntegerAlternative("signaler_ToTime", "UTC", "", 2)
    parameters:addIntegerAlternative("signaler_ToTime", "Local", "", 3)
    parameters:addIntegerAlternative("signaler_ToTime", "Server", "", 4)
    parameters:addIntegerAlternative("signaler_ToTime", "Financial", "", 5)
    parameters:addIntegerAlternative("signaler_ToTime", "Display", "", 6)
    
    parameters:addBoolean("signaler_show_alert", "Show Alert", "", true);
    parameters:addBoolean("signaler_play_sound", "Play Sound", "", false);
    parameters:addFile("signaler_sound_file", "Sound File", "", "");
    parameters:setFlag("signaler_sound_file", core.FLAG_SOUND);
    parameters:addBoolean("signaler_recurrent_sound", "Recurrent Sound", "", true);
    parameters:addBoolean("signaler_send_email", "Send Email", "", false);
    parameters:addString("signaler_email", "Email", "", "");
    parameters:setFlag("signaler_email", core.FLAG_EMAIL);
    if indicator ~= nil and strategy == nil then
        parameters:addBoolean("signaler_show_popup", "Show Popup", "", false);
    end
    parameters:addBoolean("signaler_debug_alert", "Print Into Log", "", false);
    if DDEAlertsSupport then
        parameters:addBoolean("signaler_dde_export", "DDE Export", "You can export the alert into the Excel or any other application with DDE support (=Service Name|DDE Topic!Alerts)", false);
        parameters:addString("signaler_dde_service", "Service Name", "The service name must be unique amoung all running instances of the strategy", "TS2ALERTS");
        parameters:addString("signaler_dde_topic", "DDE Topic", "", "");
    end

    parameters:addGroup("  Telegram/Discord/Other platforms");
    parameters:addBoolean("use_advanced_alert", "Send Advanced Alert", "Telegram/Discord/other platform (like MT4)", false)
	parameters:addString("advanced_alert_key", "Advanced Alert Key",
        "You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys", "");

    parameters:addGroup("  Trade coping");
    parameters:addBoolean("use_external_executer", "Send Command To Another Platform", "Like MT4/MT5/FXTS2", false)
    parameters:addString("external_executer_key", "Platform Key", "You can get a key on ProfitRobots.com", "");
end

function signaler:Prepare(name_only)
    self._ToTime = instance.parameters.signaler_ToTime
    if self._ToTime == 1 then
        self._ToTime = core.TZ_EST
    elseif self._ToTime == 2 then
        self._ToTime = core.TZ_UTC
    elseif self._ToTime == 3 then
        self._ToTime = core.TZ_LOCAL
    elseif self._ToTime == 4 then
        self._ToTime = core.TZ_SERVER
    elseif self._ToTime == 5 then
        self._ToTime = core.TZ_FINANCIAL
    elseif self._ToTime == 6 then
        self._ToTime = core.TZ_TS
    end
    self._dde_alerts = instance.parameters.signaler_dde_export;
    if self._dde_alerts then
        assert(instance.parameters.signaler_dde_topic ~= "", "You need to specify the DDE topic");
        require("ddeserver_lua");
        self.dde_server = ddeserver_lua.new(instance.parameters.signaler_dde_service);
        self.dde_topic = self.dde_server:addTopic(instance.parameters.signaler_dde_topic);
        self.dde_alerts = self.dde_server:addValue(self.dde_topic, "Alerts");
    end

    if instance.parameters.signaler_play_sound then
        self._sound_file = instance.parameters.signaler_sound_file;
        assert(self._sound_file ~= "", "Sound file must be chosen");
    end
    self._show_alert = instance.parameters.signaler_show_alert;
    self._recurrent_sound = instance.parameters.signaler_recurrent_sound;
    self._show_popup = instance.parameters.signaler_show_popup;
    self._signaler_debug_alert = instance.parameters.signaler_debug_alert;
    if instance.parameters.signaler_send_email then
        self._email = instance.parameters.signaler_email;
        assert(self._email ~= "", "E-mail address must be specified");
    end
    --do what you usually do in prepare
    if name_only then
        return;
    end

    if instance.parameters.advanced_alert_key ~= "" and instance.parameters.use_advanced_alert then
        self._advanced_alert_key = instance.parameters.advanced_alert_key;
    end
    if instance.parameters.external_executer_key ~= "" and instance.parameters.use_external_executer then
        self._external_executer_key = instance.parameters.external_executer_key;
    end
    if self.external_executer_key ~= nil or self._advanced_alert_key ~= nil then
        require("http_lua");
        self._advanced_alert_timer = self._ids_start + 1;
        core.host:execute("setTimer", self._advanced_alert_timer, 1);
    end
end

function signaler:ReleaseInstance()
    if self.dde_server ~= nil then
        self.dde_server:close();
    end
end

signaler:RegisterModule(Modules);
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76403
--
-- ── Author ─────────────────────────────────────────────────────────────────────
-- Developed by: Mario Jemic
-- Email:        mario.jemic@gmail.com
-- Website:      https://mario-jemic.com
--
-- ── Support & Donations ────────────────────────────────────────────────────────
-- PayPal:        https://goo.gl/9Rj74e
-- Patreon:       https://tiny.cc/1ybwxz
-- BuyMeACoffee:  https://tiny.cc/bj7vxz
--
-- Crypto:
--  BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
--  SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
--  ETH/BNB/USDT/XRP (ERC20 & BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
--
-- ── Copyright ──────────────────────────────────────────────────────────────────
-- © 2025 Gehtsoft USA LLC — https://fxcodebase.com

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- <https://www.gnu.org/licenses/>.