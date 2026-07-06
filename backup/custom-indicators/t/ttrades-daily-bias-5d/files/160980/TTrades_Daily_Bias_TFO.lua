-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76394
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
    indicator:name("TTrades Daily Bias [TFO]");
    indicator:description("TTrades Daily Bias [TFO]");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addBoolean("param1", "Daily Bias", "Apply TTrades bias concepts to the 1 Day timeframe", true);
    indicator.parameters:addBoolean("param2", "Weekly Bias", "Apply TTrades bias concepts to the 1 Week timeframe", false);
    indicator.parameters:addBoolean("param3", "Show Bias Reasoning", "Show the reason why a given bias is being established", true);
    indicator.parameters:addColor("param4", "Bull / Bear Bias Colors", "", core.colors().Teal);
    indicator.parameters:addColor("param5", "", "", core.colors().Red);
    indicator.parameters:addBoolean("param6", "Plot Daily Bias", "", true);
    indicator.parameters:addBoolean("param7", "Plot Weekly Bias", "", true);
    indicator.parameters:addString("param8", "", "", "Top");
    indicator.parameters:addStringAlternative("param8", "Top", "", "Top");
    indicator.parameters:addStringAlternative("param8", "Bottom", "", "Bottom");
    indicator.parameters:addString("param9", "", "", "Bottom");
    indicator.parameters:addStringAlternative("param9", "Top", "", "Top");
    indicator.parameters:addStringAlternative("param9", "Bottom", "", "Bottom");
    indicator.parameters:addColor("param10", "Before / After Hit Colors", "All previous high and low lines will start out as this color", core.colors().Blue);
    indicator.parameters:addColor("param11", "", "Once a previous high or low line is reached, it will become this color", core.colors().Red);
    indicator.parameters:addBoolean("param12", "Stop Extending Lines After Hit", "Once a previous high or low line is reached, its line will stop extending", false);
    indicator.parameters:addBoolean("param13", "Day Separator", "", true);
    indicator.parameters:addBoolean("param14", "Week Separator", "", true);
    indicator.parameters:addColor("param15", "", "", Graphics:GetColor(core.colors().Black + math.floor(80 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param16", "", "", Graphics:GetColor(core.colors().Black + math.floor(30 / 100 * 255) * 16777216));
    indicator.parameters:addInteger("param17", "Line Width", "", 1);
    indicator.parameters:addBoolean("param18", "Show Statistics", "Show statistics on bias accuracy\n\nSuccess Rate: how often has price successfully reached the assigned draw on liquidity?\n\nClose Thru Rate: from the number of times that price reached the assigned draw on liquidity, how often did it close through that level?\n\nSample Size: the total number of times that a given bias was assigned", true);
    indicator.parameters:addString("param19", "Position", "", "Top Right");
    indicator.parameters:addStringAlternative("param19", "Bottom Center", "", "Bottom Center");
    indicator.parameters:addStringAlternative("param19", "Bottom Left", "", "Bottom Left");
    indicator.parameters:addStringAlternative("param19", "Bottom Right", "", "Bottom Right");
    indicator.parameters:addStringAlternative("param19", "Middle Center", "", "Middle Center");
    indicator.parameters:addStringAlternative("param19", "Middle Left", "", "Middle Left");
    indicator.parameters:addStringAlternative("param19", "Middle Right", "", "Middle Right");
    indicator.parameters:addStringAlternative("param19", "Top Center", "", "Top Center");
    indicator.parameters:addStringAlternative("param19", "Top Left", "", "Top Left");
    indicator.parameters:addStringAlternative("param19", "Top Right", "", "Top Right");
    indicator.parameters:addString("param20", "Size", "", "Normal");
    indicator.parameters:addStringAlternative("param20", "Auto", "", "Auto");
    indicator.parameters:addStringAlternative("param20", "Tiny", "", "Tiny");
    indicator.parameters:addStringAlternative("param20", "Small", "", "Small");
    indicator.parameters:addStringAlternative("param20", "Normal", "", "Normal");
    indicator.parameters:addStringAlternative("param20", "Large", "", "Large");
    indicator.parameters:addStringAlternative("param20", "Huge", "", "Huge");
end

local source;
local plot1;
local plot2;
local plot3;
local plot4;
local plot5;
local plot6;
local plot7;
local plot8;
function CreateType_lines(ph_lineValue, pl_lineValue, hit_ph_lineValue, hit_pl_lineValue)
    return {
        ph_line = ph_lineValue or (nil),
        pl_line = pl_lineValue or (nil),
        hit_ph_line = hit_ph_lineValue or (false),
        hit_pl_line = hit_pl_lineValue or (false),
    };
end
function lines_Getph_line(self)
    if self == nil then return nil; end
    return self.ph_line;
end
function lines_Setph_line(self, val)
    if self == nil then return nil; end
    self.ph_line = val;
end
function lines_Getpl_line(self)
    if self == nil then return nil; end
    return self.pl_line;
end
function lines_Setpl_line(self, val)
    if self == nil then return nil; end
    self.pl_line = val;
end
function lines_Gethit_ph_line(self)
    if self == nil then return nil; end
    return self.hit_ph_line;
end
function lines_Sethit_ph_line(self, val)
    if self == nil then return nil; end
    self.hit_ph_line = val;
end
function lines_Gethit_pl_line(self)
    if self == nil then return nil; end
    return self.hit_pl_line;
end
function lines_Sethit_pl_line(self, val)
    if self == nil then return nil; end
    self.hit_pl_line = val;
end
function CreateType_info(phValue, plValue, chValue, clValue, coValue, p_upValue, biasValue, bias_phValue, bias_plValue, hit_phValue, hit_plValue, close_phValue, close_plValue)
    return {
        ph = phValue,
        pl = plValue,
        ch = chValue,
        cl = clValue,
        co = coValue,
        p_up = p_upValue,
        bias = biasValue or (0),
        bias_ph = bias_phValue or (0),
        bias_pl = bias_plValue or (0),
        hit_ph = hit_phValue or (0),
        hit_pl = hit_plValue or (0),
        close_ph = close_phValue or (0),
        close_pl = close_plValue or (0),
    };
end
function info_Getph(self)
    if self == nil then return nil; end
    return self.ph;
end
function info_Setph(self, val)
    if self == nil then return nil; end
    self.ph = val;
end
function info_Getpl(self)
    if self == nil then return nil; end
    return self.pl;
end
function info_Setpl(self, val)
    if self == nil then return nil; end
    self.pl = val;
end
function info_Getch(self)
    if self == nil then return nil; end
    return self.ch;
end
function info_Setch(self, val)
    if self == nil then return nil; end
    self.ch = val;
end
function info_Getcl(self)
    if self == nil then return nil; end
    return self.cl;
end
function info_Setcl(self, val)
    if self == nil then return nil; end
    self.cl = val;
end
function info_Getco(self)
    if self == nil then return nil; end
    return self.co;
end
function info_Setco(self, val)
    if self == nil then return nil; end
    self.co = val;
end
function info_Getp_up(self)
    if self == nil then return nil; end
    return self.p_up;
end
function info_Setp_up(self, val)
    if self == nil then return nil; end
    self.p_up = val;
end
function info_Getbias(self)
    if self == nil then return nil; end
    return self.bias;
end
function info_Setbias(self, val)
    if self == nil then return nil; end
    self.bias = val;
end
function info_Getbias_ph(self)
    if self == nil then return nil; end
    return self.bias_ph;
end
function info_Setbias_ph(self, val)
    if self == nil then return nil; end
    self.bias_ph = val;
end
function info_Getbias_pl(self)
    if self == nil then return nil; end
    return self.bias_pl;
end
function info_Setbias_pl(self, val)
    if self == nil then return nil; end
    self.bias_pl = val;
end
function info_Gethit_ph(self)
    if self == nil then return nil; end
    return self.hit_ph;
end
function info_Sethit_ph(self, val)
    if self == nil then return nil; end
    self.hit_ph = val;
end
function info_Gethit_pl(self)
    if self == nil then return nil; end
    return self.hit_pl;
end
function info_Sethit_pl(self, val)
    if self == nil then return nil; end
    self.hit_pl = val;
end
function info_Getclose_ph(self)
    if self == nil then return nil; end
    return self.close_ph;
end
function info_Setclose_ph(self, val)
    if self == nil then return nil; end
    self.close_ph = val;
end
function info_Getclose_pl(self)
    if self == nil then return nil; end
    return self.close_pl;
end
function info_Setclose_pl(self, val)
    if self == nil then return nil; end
    self.close_pl = val;
end
function Create_handle_bias_s(tf)
    local local_vars = {};
    Label:Prepare(500);
    signaler:Prepare(nameOnly);
    return {
        Clear = function()
        end,
        GetValue = function(n, period, mode)
            local_vars["_yloc"] = "price";
            _style = Triary((tf == "D"), "up", "down");
            _y = Triary((tf == "D"), info_Getcl(n), info_Getch(n));
            can_plot = Triary((tf == "D"), can_plot_d, can_plot_w);
            if SafeGreater(source.close:tick(period - 1), info_Getph(n)) then
                if (info_Getbias(n) == 1) then
                    info_Setclose_ph(n, SafePlus(info_Getclose_ph(n), 1));
                end
                info_Setbias(n, 1);
                if vars["bias_reason"] and can_plot then
                    local_vars["txt"] = "Close Above P" .. tf .. "H\nBias P" .. tf .. "H";
                    label_1_x = period;
                    Label:New(core.formatDate(label_1_x and source:date(label_1_x) or 0) .. "_1", "1", label_1_x, _y):SetText(local_vars["txt"]):SetColor(core.COLOR_BACKGROUND):SetTextColor(core.COLOR_LABEL):SetStyle(_style);
                end
            elseif SafeLess(source.close:tick(period), info_Getpl(n)) then
                if (info_Getbias(n) == (-1)) then
                    info_Setclose_pl(n, SafePlus(info_Getclose_pl(n), 1));
                end
                info_Setbias(n, (-1));
                if vars["bias_reason"] and can_plot then
                    local_vars["txt"] = "Close Below P" .. tf .. "L\nBias P" .. tf .. "L";
                    label_2_x = period;
                    Label:New(core.formatDate(label_2_x and source:date(label_2_x) or 0) .. "_2", "2", label_2_x, _y):SetText(local_vars["txt"]):SetColor(core.COLOR_BACKGROUND):SetTextColor(core.COLOR_LABEL):SetStyle(_style);
                end
            elseif SafeLess(source.close:tick(period), info_Getph(n)) and SafeGreater(source.close:tick(period - 1), info_Getpl(n)) and SafeGreater(info_Getch(n), info_Getph(n)) and SafeGreater(info_Getcl(n), info_Getpl(n)) then
                info_Setbias(n, (-1));
                if vars["bias_reason"] and can_plot then
                    local_vars["txt"] = "Failed to Close Above P" .. tf .. "H\nBias P" .. tf .. "L";
                    label_3_x = period;
                    Label:New(core.formatDate(label_3_x and source:date(label_3_x) or 0) .. "_3", "3", label_3_x, _y):SetText(local_vars["txt"]):SetColor(core.COLOR_BACKGROUND):SetTextColor(core.COLOR_LABEL):SetStyle(_style);
                end
            elseif SafeGreater(source.close:tick(period - 1), info_Getpl(n)) and SafeLess(source.close:tick(period), info_Getph(n)) and SafeLess(info_Getch(n), info_Getph(n)) and SafeLess(info_Getcl(n), info_Getpl(n)) then
                info_Setbias(n, 1);
                if vars["bias_reason"] and can_plot then
                    local_vars["txt"] = "Failed to Close Below P" .. tf .. "L\nBias P" .. tf .. "H";
                    label_4_x = period;
                    Label:New(core.formatDate(label_4_x and source:date(label_4_x) or 0) .. "_4", "4", label_4_x, _y):SetText(local_vars["txt"]):SetColor(core.COLOR_BACKGROUND):SetTextColor(core.COLOR_LABEL):SetStyle(_style);
                end
            elseif SafeLE(info_Getch(n), info_Getph(n)) and SafeGE(info_Getcl(n), info_Getpl(n)) then
                if info_Getp_up(n) then
                    info_Setbias(n, 1);
                end
                if vars["bias_reason"] and can_plot then
                    local_vars["txt"] = "Close Inside\nBias P" .. tf .. (Triary(info_Getp_up(n), "H", "L"));
                    label_5_x = period;
                    Label:New(core.formatDate(label_5_x and source:date(label_5_x) or 0) .. "_5", "5", label_5_x, _y):SetText(local_vars["txt"]):SetColor(core.COLOR_BACKGROUND):SetTextColor(core.COLOR_LABEL):SetStyle(_style);
                end
            else
                info_Setbias(n, 0);
                if vars["bias_reason"] and can_plot then
                    local_vars["txt"] = "Outside Bar but Closed Inside\nNo Bias";
                    label_6_x = period;
                    Label:New(core.formatDate(label_6_x and source:date(label_6_x) or 0) .. "_6", "6", label_6_x, _y):SetText(local_vars["txt"]):SetColor(core.COLOR_BACKGROUND):SetTextColor(core.COLOR_LABEL):SetStyle(_style);
                end
            end
            if (info_Getbias(n) == 1) then
                info_Setbias_ph(n, SafePlus(info_Getbias_ph(n), 1));
                if "once_per_bar" == "all" or vars["alert1_last_date"] ~= source:date(period) then
                    vars["alert1_last_date"] = source:date(period);
                    signaler:SignalEx(nil, "Bias P" .. tf .. "H", period, source);
                end
            elseif (info_Getbias(n) == (-1)) then
                info_Setbias_pl(n, SafePlus(info_Getbias_pl(n), 1));
                if "once_per_bar" == "all" or vars["alert2_last_date"] ~= source:date(period) then
                    vars["alert2_last_date"] = source:date(period);
                    signaler:SignalEx(nil, "Bias P" .. tf .. "L", period, source);
                end
            end
        end
    };
end
function Create_update_info_s(tf)
    local local_vars = {};
    local_vars["handle_biasFunc2"] = Create_handle_bias_s(tf);
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(n, period, mode)
            if firstCall then
                firstCall = false;
                local_vars["handle_biasFunc2"].Clear();
            else
            end
            if (Triary((tf == "D"), new_day, new_week)) then
                if not (info_Getch(n) == nil) then
                    local_vars["handle_biasFunc2"].GetValue(n, period, mode);
                    if SafeGE(source.close:tick(period - 1), info_Getco(n)) then
                        info_Setp_up(n, true);
                    else
                        info_Setp_up(n, false);
                    end
                    info_Setph(n, info_Getch(n));
                    info_Setpl(n, info_Getcl(n));
                    info_Setch(n, source.high:tick(period));
                    info_Setcl(n, source.low:tick(period));
                    info_Setco(n, source.open:tick(period));
                end
            end
            if info_Getch(n) == nil then
                info_Setch(n, source.high:tick(period));
                info_Setch(n, source.low:tick(period));
                return info_Getch(n);
            else
                info_Setch(n, SafeMax(source.high:tick(period), info_Getch(n)));
                info_Setcl(n, SafeMin(source.low:tick(period), info_Getcl(n)));
                return info_Getcl(n);
            end
        end
    };
end
function Create_update_lines_s(tf)
    local local_vars = {};
    time = instance:addInternalStream(0, 0);
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(L, n, period, mode)
            if firstCall then
                firstCall = false;
        time[period] = source:date(period) * 86400000;
            else
        time[period] = source:date(period) * 86400000;
            end
            local_vars["hit_high"] = false;
            local_vars["hit_low"] = false;
            can_plot = Triary((tf == "D"), can_plot_d, can_plot_w);
            if (Triary((tf == "D"), new_day, new_week)) then
                Array:Pop(L);
                _right = SafePlus(time:tick(period), SafeMultiply(Timeframe:InSeconds(tf, source), 1000));
                _style = Triary((tf == "D"), "solid", "dashed");
                L:Unshift(CreateType_lines(Line:New(time:tick(period), info_Getph(n), _right, info_Getph(n)):SetColor(Triary(can_plot, vars["before_raid_color"], nil)):SetStyle(_style):SetWidth(vars["line_width"]):SetXLoc(time:tick(period), _right, "bar_time"), Line:New(time:tick(period), info_Getpl(n), _right, info_Getpl(n)):SetColor(Triary(can_plot, vars["before_raid_color"], nil)):SetStyle(_style):SetWidth(vars["line_width"]):SetXLoc(time:tick(period), _right, "bar_time"), false, false));
            end
            local for1_from = 0;
            local for1_to = SafeMinus(L:Size(), 1);
            local for1_step = for1_from < for1_to and 1 or -1;
            if not for1_from or not for1_to then return; end
            for i = for1_from, for1_to, for1_step do
                x = Array:Get(L, i);
                if not (x.ph_line == nil) then
                    if SafeGE(source.high:tick(period), Line:GetY1(x.ph_line)) and not (x.hit_ph_line) then
                        if vars["stop_ext"] then
                            Line:SetX2(x.ph_line, time:tick(period));
                        end
                        if (info_Getbias(n) == 1) then
                            info_Sethit_ph(n, SafePlus(info_Gethit_ph(n), 1));
                        end
                        x.hit_ph_line = true;
                        if can_plot then
                            Line:SetColor(x.ph_line, vars["after_raid_color"]);
                        end
                        local_vars["hit_high"] = true;
                        if "once_per_bar" == "all" or vars["alert3_last_date"] ~= source:date(period) then
                            vars["alert3_last_date"] = source:date(period);
                            signaler:SignalEx(nil, "Hit P" .. tf .. "H", period, source);
                        end
                    end
                    if SafeLE(source.low:tick(period), Line:GetY1(x.pl_line)) and not (x.hit_pl_line) then
                        if vars["stop_ext"] then
                            Line:SetX2(x.pl_line, time:tick(period));
                        end
                        if (info_Getbias(n) == (-1)) then
                            info_Sethit_pl(n, SafePlus(info_Gethit_pl(n), 1));
                        end
                        x.hit_pl_line = true;
                        if can_plot then
                            Line:SetColor(x.pl_line, vars["after_raid_color"]);
                        end
                        local_vars["hit_low"] = true;
                        if "once_per_bar" == "all" or vars["alert4_last_date"] ~= source:date(period) then
                            vars["alert4_last_date"] = source:date(period);
                            signaler:SignalEx(nil, "Hit P" .. tf .. "L", period, source);
                        end
                    end
                end
            end
            return local_vars["hit_high"], local_vars["hit_low"];
        end
    };
end
function Create_get_table_pos_s(pos)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            if "Bottom Center" then
                return "bottom_center";
            elseif "Bottom Left" then
                return "bottom_left";
            elseif "Bottom Right" then
                return "bottom_right";
            elseif "Middle Center" then
                return "middle_center";
            elseif "Middle Left" then
                return "middle_left";
            elseif "Middle Right" then
                return "middle_right";
            elseif "Top Center" then
                return "top_center";
            elseif "Top Left" then
                return "top_left";
            elseif "Top Right" then
                return "top_right";
            end
        end
    };
end
function Create_get_table_size_s(size)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            if "Tiny" then
                return "tiny";
            elseif "Small" then
                return "small";
            elseif "Normal" then
                return "normal";
            elseif "Large" then
                return "large";
            elseif "Huge" then
                return "huge";
            elseif "Auto" then
                return "auto";
            end
        end
    };
end
function Create_format_color_b(bull)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(n, L, period, mode)
            local_vars["result"] = nil;
            if Triary(bull, ((info_Getbias(n) == 1)), ((info_Getbias(n) == (-1)))) then
                if Triary(bull, (lines_Gethit_ph_line(Array:Get(L, 0))), (lines_Gethit_pl_line(Array:Get(L, 0)))) then
                    local_vars["result"] = vars["after_raid_color"] + math.floor(50 / 100 * 255) * 16777216;
                else
                    local_vars["result"] = vars["before_raid_color"] + math.floor(50 / 100 * 255) * 16777216;
                end
                if Triary(bull, (lines_Gethit_ph_line(Array:Get(L, 0))), (lines_Gethit_pl_line(Array:Get(L, 0)))) then
                    local_vars["result"] = vars["after_raid_color"] + math.floor(50 / 100 * 255) * 16777216;
                    return local_vars["result"];
                else
                    local_vars["result"] = vars["before_raid_color"] + math.floor(50 / 100 * 255) * 16777216;
                    return local_vars["result"];
                end
            end
        end
    };
end
function Create_format_result()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(hit, bias, period, mode)
            result = "";
            if SafeGreater(bias, 0) then
                result = Str:ToString(SafeDivide(math.floor(SafeMultiply(SafeDivide(hit, bias), 1000)), 10));
            else
                result = "0";
            end
            result = SafeConcat(result, "%");
            return result;
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
    vars["d_stats"] = instance.parameters.param1;
    vars["w_stats"] = instance.parameters.param2;
    vars["bias_reason"] = instance.parameters.param3;
    vars["bull_color"] = instance.parameters.param4;
    vars["bear_color"] = instance.parameters.param5;
    vars["d_bias_plot"] = instance.parameters.param6;
    vars["w_bias_plot"] = instance.parameters.param7;
    vars["d_bias_loc"] = instance.parameters.param8;
    vars["w_bias_loc"] = instance.parameters.param9;
    vars["before_raid_color"] = instance.parameters.param10;
    vars["after_raid_color"] = instance.parameters.param11;
    vars["stop_ext"] = instance.parameters.param12;
    vars["use_d_sep"] = instance.parameters.param13;
    vars["use_w_sep"] = instance.parameters.param14;
    vars["d_sep"] = Graphics:AddTransparency(instance.parameters.param15, Graphics:GetTransparencyPercent(core.colors().Black + math.floor(80 / 100 * 255) * 16777216));
    vars["w_sep"] = Graphics:AddTransparency(instance.parameters.param16, Graphics:GetTransparencyPercent(core.colors().Black + math.floor(30 / 100 * 255) * 16777216));
    vars["line_width"] = instance.parameters.param17;
    vars["tbl_show_stats"] = instance.parameters.param18;
    vars["tbl_loc"] = instance.parameters.param19;
    vars["tbl_size"] = instance.parameters.param20;
    Line:Prepare(500);
    vars["d_info"] = Variable:Create();
    vars["w_info"] = Variable:Create();
    vars["d_lines"] = Variable:Create();
    vars["w_lines"] = Variable:Create();
    vars["update_infoFunc1"] = Create_update_info_s("D");
    vars["update_linesFunc3"] = Create_update_lines_s("D");
    vars["update_infoFunc4"] = Create_update_info_s("W");
    vars["update_linesFunc5"] = Create_update_lines_s("W");
    plot1 = instance:createTextOutput("plot1", "PDH Raid", "Wingdings", 12, core.H_Center, core.V_Top, vars["after_raid_color"]);
    plot2 = instance:createTextOutput("plot2", "PDL Raid", "Wingdings", 12, core.H_Center, core.V_Bottom, vars["after_raid_color"]);
    plot3 = instance:createTextOutput("plot3", "PWH Raid", "Wingdings", 12, core.H_Center, core.V_Top, vars["after_raid_color"]);
    plot4 = instance:createTextOutput("plot4", "PWL Raid", "Wingdings", 12, core.H_Center, core.V_Bottom, vars["after_raid_color"]);
    plot5 = instance:createTextOutput("plot5", "Daily Bias", "Wingdings", 12, core.H_Center, core.V_Center, core.colors().Blue);
    plot6 = instance:createTextOutput("plot6", "Weekly Bias", "Wingdings", 12, core.H_Center, core.V_Center, core.colors().Blue);
    vars["stats"] = Variable:Create();
    vars["get_table_posFunc6"] = Create_get_table_pos_s(vars["tbl_loc"]);
    vars["get_table_sizeFunc7"] = Create_get_table_size_s(vars["tbl_size"]);
    vars["format_colorFunc8"] = Create_format_color_b(true);
    vars["format_colorFunc9"] = Create_format_color_b(false);
    vars["format_resultFunc10"] = Create_format_result();
    vars["format_resultFunc11"] = Create_format_result();
    vars["format_resultFunc12"] = Create_format_result();
    vars["format_resultFunc13"] = Create_format_result();
    vars["format_colorFunc14"] = Create_format_color_b(true);
    vars["format_colorFunc15"] = Create_format_color_b(false);
    vars["format_resultFunc16"] = Create_format_result();
    vars["format_resultFunc17"] = Create_format_result();
    vars["format_resultFunc18"] = Create_format_result();
    vars["format_resultFunc19"] = Create_format_result();
    plot7 = instance:addStream("plot7", core.Line, "Daily Bias", "Daily Bias", core.colors().Blue, 0, 0);
    plot7:setWidth(1);
    plot7:setStyle(core.LINE_NONE);
    plot8 = instance:addStream("plot8", core.Line, "Weekly Bias", "Weekly Bias", core.colors().Blue, 0, 0);
    plot8:setWidth(1);
    plot8:setStyle(core.LINE_NONE);
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Line:Clear();
        Label:Clear();
        Table:Clear();
        Str:Clear();
        vars["g_VIS"] = Str:NewVar("Bias");
        vars["g_PLT"] = Str:NewVar("Plotting");
        vars["g_STY"] = Str:NewVar("Style");
        vars["g_TBL"] = Str:NewVar("Table");
        vars["d_info"]:Clear();
        vars["w_info"]:Clear();
        vars["d_lines"]:Clear();
        vars["w_lines"]:Clear();
        vars["update_infoFunc1"].Clear();
        vars["update_linesFunc3"].Clear();
        vars["update_infoFunc4"].Clear();
        vars["update_linesFunc5"].Clear();
        vars["stats"]:Clear();
        vars["get_table_posFunc6"].Clear();
        vars["get_table_sizeFunc7"].Clear();
        vars["text_size"] = Str:NewVar(vars["get_table_sizeFunc7"].GetValue(period, mode));
        vars["format_colorFunc8"].Clear();
        vars["format_colorFunc9"].Clear();
        vars["format_resultFunc10"].Clear();
        vars["format_resultFunc11"].Clear();
        vars["format_resultFunc12"].Clear();
        vars["format_resultFunc13"].Clear();
        vars["format_colorFunc14"].Clear();
        vars["format_colorFunc15"].Clear();
        vars["format_resultFunc16"].Clear();
        vars["format_resultFunc17"].Clear();
        vars["format_resultFunc18"].Clear();
        vars["format_resultFunc19"].Clear();
    else
        SafeSetString(vars["g_VIS"], period, SafeGetString(vars["g_VIS"], period - 1));
        SafeSetString(vars["g_PLT"], period, SafeGetString(vars["g_PLT"], period - 1));
        SafeSetString(vars["g_STY"], period, SafeGetString(vars["g_STY"], period - 1));
        SafeSetString(vars["g_TBL"], period, SafeGetString(vars["g_TBL"], period - 1));
        SafeSetString(vars["text_size"], period, SafeGetString(vars["text_size"], period - 1));
    end
    new_day = Timeframe:Change("D", source, period);
    new_week = Timeframe:Change("W", source, period);
    can_plot_d = SafeLess(Timeframe:InSeconds(Timeframe:Period(), source), Timeframe:InSeconds("D", source));
    can_plot_w = SafeLess(Timeframe:InSeconds(Timeframe:Period(), source), Timeframe:InSeconds("W", source));
    if vars["use_d_sep"] and new_day and can_plot_d then
        Line:New(period, source.high:tick(period) * 1.000001, period, source.low:tick(period)):SetColor(vars["d_sep"]):SetExtend("both"):SetWidth(vars["line_width"]);
    end
    if vars["use_w_sep"] and new_week and can_plot_w then
        Line:New(period, source.high:tick(period) * 1.000001, period, source.low:tick(period)):SetColor(vars["w_sep"]):SetExtend("both"):SetWidth(vars["line_width"]);
    end
    if not vars["d_info"]:IsInitialized() then
        vars["d_info"]:Set(CreateType_info());
    end
    if not vars["w_info"]:IsInitialized() then
        vars["w_info"]:Set(CreateType_info());
    end
    if not vars["d_lines"]:IsInitialized() then
        vars["d_lines"]:Set(Array:New(1, CreateType_lines()));
    end
    if not vars["w_lines"]:IsInitialized() then
        vars["w_lines"]:Set(Array:New(1, CreateType_lines()));
    end
    vars["d_hit_high"] = false;
    vars["d_hit_low"] = false;
    vars["w_hit_high"] = false;
    vars["w_hit_low"] = false;
    if vars["d_stats"] and SafeLE(Timeframe:InSeconds(Timeframe:Period(), source), Timeframe:InSeconds("D", source)) then
        vars["update_infoFunc1"].GetValue(vars["d_info"]:Get(), period, mode);
        hr_ret_val, lr_ret_val = vars["update_linesFunc3"].GetValue(vars["d_lines"]:Get(), vars["d_info"]:Get(), period, mode);
        vars["hr"] = hr_ret_val;
        vars["lr"] = lr_ret_val;
        vars["d_hit_high"] = vars["hr"];
        vars["d_hit_low"] = vars["lr"];
    end
    if vars["w_stats"] and SafeLE(Timeframe:InSeconds(Timeframe:Period(), source), Timeframe:InSeconds("W", source)) then
        vars["update_infoFunc4"].GetValue(vars["w_info"]:Get(), period, mode);
        hr_ret_val, lr_ret_val = vars["update_linesFunc5"].GetValue(vars["w_lines"]:Get(), vars["w_info"]:Get(), period, mode);
        vars["hr"] = hr_ret_val;
        vars["lr"] = lr_ret_val;
        vars["w_hit_high"] = vars["hr"];
        vars["w_hit_low"] = vars["lr"];
    end
    PlotShape:SetValue(plot1, period, source, can_plot_d and vars["d_hit_high"], "\217", "", "abovebar", vars["after_raid_color"]);
    PlotShape:SetValue(plot2, period, source, can_plot_d and vars["d_hit_low"], "\218", "", "belowbar", vars["after_raid_color"]);
    PlotShape:SetValue(plot3, period, source, can_plot_w and vars["w_hit_high"], "\217", "", "abovebar", vars["after_raid_color"]);
    PlotShape:SetValue(plot4, period, source, can_plot_w and vars["w_hit_low"], "\218", "", "belowbar", vars["after_raid_color"]);
    PlotShape:SetValue(plot5, period, source, vars["d_bias_plot"], "\111", "", Triary((vars["d_bias_loc"] == "Top"), "top", "bottom"), Triary((info_Getbias(vars["d_info"]:Get()) == 1), vars["bull_color"], Triary((info_Getbias(vars["d_info"]:Get()) == (-1)), vars["bear_color"], nil)));
    PlotShape:SetValue(plot6, period, source, vars["w_bias_plot"], "\111", "", Triary((vars["w_bias_loc"] == "Top"), "top", "bottom"), Triary((info_Getbias(vars["w_info"]:Get()) == 1), vars["bull_color"], Triary((info_Getbias(vars["w_info"]:Get()) == (-1)), vars["bear_color"], nil)));
    if new_day and (info_Getbias(vars["d_info"]:Get()) == 1) and period == source:size() - 1 then
        signaler:SignalEx(5, "Bias PDH", period, source);
    end
    if new_day and (info_Getbias(vars["d_info"]:Get()) == (-1)) and period == source:size() - 1 then
        signaler:SignalEx(6, "Bias PDL", period, source);
    end
    if new_day and (info_Getbias(vars["d_info"]:Get()) == 0) and period == source:size() - 1 then
        signaler:SignalEx(7, "No Daily Bias", period, source);
    end
    if new_week and (info_Getbias(vars["w_info"]:Get()) == 1) and period == source:size() - 1 then
        signaler:SignalEx(8, "Bias PWH", period, source);
    end
    if new_week and (info_Getbias(vars["w_info"]:Get()) == (-1)) and period == source:size() - 1 then
        signaler:SignalEx(9, "Bias PWL", period, source);
    end
    if new_week and (info_Getbias(vars["w_info"]:Get()) == 0) and period == source:size() - 1 then
        signaler:SignalEx(10, "No Weekly Bias", period, source);
    end
    if vars["d_hit_high"] and period == source:size() - 1 then
        signaler:SignalEx(11, "Hit PDH", period, source);
    end
    if vars["d_hit_low"] and period == source:size() - 1 then
        signaler:SignalEx(12, "Hit PDL", period, source);
    end
    if vars["w_hit_high"] and period == source:size() - 1 then
        signaler:SignalEx(13, "Hit PWH", period, source);
    end
    if vars["w_hit_low"] and period == source:size() - 1 then
        signaler:SignalEx(14, "Hit PWL", period, source);
    end
    if not vars["stats"]:IsInitialized() then
        vars["stats"]:Set(Table:New("1", vars["get_table_posFunc6"].GetValue(period, mode), 20, 20):SetBorderWidth(1):SetBgColor(core.COLOR_BACKGROUND):SetBorderColor(core.COLOR_LABEL):SetFrameColor(core.COLOR_LABEL):SetFrameWidth(2));
    end
    if period == source:size() - 1 then
        Table:CellText(vars["stats"]:Get(), 0, 0, "Bias");
        Table:CellTextColor(vars["stats"]:Get(), 0, 0, core.COLOR_LABEL);
        Table:CellTextSize(vars["stats"]:Get(), 0, 0, SafeGetString(vars["text_size"], period));
        Table:CellTextHAlign(vars["stats"]:Get(), 0, 0, "center");
        if vars["tbl_show_stats"] then
            Table:CellText(vars["stats"]:Get(), 1, 0, "Success\nRate");
            Table:CellTextColor(vars["stats"]:Get(), 1, 0, core.COLOR_LABEL);
            Table:CellTextSize(vars["stats"]:Get(), 1, 0, SafeGetString(vars["text_size"], period));
            Table:CellTextHAlign(vars["stats"]:Get(), 1, 0, "center");
            Table:CellText(vars["stats"]:Get(), 2, 0, "Close Thru\nRate");
            Table:CellTextColor(vars["stats"]:Get(), 2, 0, core.COLOR_LABEL);
            Table:CellTextSize(vars["stats"]:Get(), 2, 0, SafeGetString(vars["text_size"], period));
            Table:CellTextHAlign(vars["stats"]:Get(), 2, 0, "center");
            Table:CellText(vars["stats"]:Get(), 3, 0, "Sample\nSize");
            Table:CellTextColor(vars["stats"]:Get(), 3, 0, core.COLOR_LABEL);
            Table:CellTextSize(vars["stats"]:Get(), 3, 0, SafeGetString(vars["text_size"], period));
            Table:CellTextHAlign(vars["stats"]:Get(), 3, 0, "center");
        end
        if vars["d_stats"] then
            Table:CellText(vars["stats"]:Get(), 0, 1, "PDH");
            Table:CellTextColor(vars["stats"]:Get(), 0, 1, core.COLOR_LABEL);
            Table:CellTextSize(vars["stats"]:Get(), 0, 1, SafeGetString(vars["text_size"], period));
            Table:CellTextHAlign(vars["stats"]:Get(), 0, 1, "center");
            Table:CellBGColor(vars["stats"]:Get(), 0, 1, vars["format_colorFunc8"].GetValue(vars["d_info"]:Get(), vars["d_lines"]:Get(), period, mode));
            Table:CellText(vars["stats"]:Get(), 0, 2, "PDL");
            Table:CellTextColor(vars["stats"]:Get(), 0, 2, core.COLOR_LABEL);
            Table:CellTextSize(vars["stats"]:Get(), 0, 2, SafeGetString(vars["text_size"], period));
            Table:CellTextHAlign(vars["stats"]:Get(), 0, 2, "center");
            Table:CellBGColor(vars["stats"]:Get(), 0, 2, vars["format_colorFunc9"].GetValue(vars["d_info"]:Get(), vars["d_lines"]:Get(), period, mode));
            if vars["tbl_show_stats"] then
                Table:CellText(vars["stats"]:Get(), 1, 1, vars["format_resultFunc10"].GetValue(info_Gethit_ph(vars["d_info"]:Get()), info_Getbias_ph(vars["d_info"]:Get()), period, mode));
                Table:CellTextColor(vars["stats"]:Get(), 1, 1, core.COLOR_LABEL);
                Table:CellTextSize(vars["stats"]:Get(), 1, 1, SafeGetString(vars["text_size"], period));
                Table:CellTextHAlign(vars["stats"]:Get(), 1, 1, "center");
                Table:CellText(vars["stats"]:Get(), 1, 2, vars["format_resultFunc11"].GetValue(info_Gethit_pl(vars["d_info"]:Get()), info_Getbias_pl(vars["d_info"]:Get()), period, mode));
                Table:CellTextColor(vars["stats"]:Get(), 1, 2, core.COLOR_LABEL);
                Table:CellTextSize(vars["stats"]:Get(), 1, 2, SafeGetString(vars["text_size"], period));
                Table:CellTextHAlign(vars["stats"]:Get(), 1, 2, "center");
                Table:CellText(vars["stats"]:Get(), 2, 1, vars["format_resultFunc12"].GetValue(info_Getclose_ph(vars["d_info"]:Get()), info_Gethit_ph(vars["d_info"]:Get()), period, mode));
                Table:CellTextColor(vars["stats"]:Get(), 2, 1, core.COLOR_LABEL);
                Table:CellTextSize(vars["stats"]:Get(), 2, 1, SafeGetString(vars["text_size"], period));
                Table:CellTextHAlign(vars["stats"]:Get(), 2, 1, "center");
                Table:CellText(vars["stats"]:Get(), 2, 2, vars["format_resultFunc13"].GetValue(info_Getclose_pl(vars["d_info"]:Get()), info_Gethit_pl(vars["d_info"]:Get()), period, mode));
                Table:CellTextColor(vars["stats"]:Get(), 2, 2, core.COLOR_LABEL);
                Table:CellTextSize(vars["stats"]:Get(), 2, 2, SafeGetString(vars["text_size"], period));
                Table:CellTextHAlign(vars["stats"]:Get(), 2, 2, "center");
                Table:CellText(vars["stats"]:Get(), 3, 1, Str:ToString(info_Getbias_ph(vars["d_info"]:Get())));
                Table:CellTextColor(vars["stats"]:Get(), 3, 1, core.COLOR_LABEL);
                Table:CellTextSize(vars["stats"]:Get(), 3, 1, SafeGetString(vars["text_size"], period));
                Table:CellTextHAlign(vars["stats"]:Get(), 3, 1, "center");
                Table:CellText(vars["stats"]:Get(), 3, 2, Str:ToString(info_Getbias_pl(vars["d_info"]:Get())));
                Table:CellTextColor(vars["stats"]:Get(), 3, 2, core.COLOR_LABEL);
                Table:CellTextSize(vars["stats"]:Get(), 3, 2, SafeGetString(vars["text_size"], period));
                Table:CellTextHAlign(vars["stats"]:Get(), 3, 2, "center");
            end
        end
        if vars["w_stats"] then
            Table:CellText(vars["stats"]:Get(), 0, 3, "PWH");
            Table:CellTextColor(vars["stats"]:Get(), 0, 3, core.COLOR_LABEL);
            Table:CellTextSize(vars["stats"]:Get(), 0, 3, SafeGetString(vars["text_size"], period));
            Table:CellTextHAlign(vars["stats"]:Get(), 0, 3, "center");
            Table:CellBGColor(vars["stats"]:Get(), 0, 3, vars["format_colorFunc14"].GetValue(vars["w_info"]:Get(), vars["w_lines"]:Get(), period, mode));
            Table:CellText(vars["stats"]:Get(), 0, 4, "PWL");
            Table:CellTextColor(vars["stats"]:Get(), 0, 4, core.COLOR_LABEL);
            Table:CellTextSize(vars["stats"]:Get(), 0, 4, SafeGetString(vars["text_size"], period));
            Table:CellTextHAlign(vars["stats"]:Get(), 0, 4, "center");
            Table:CellBGColor(vars["stats"]:Get(), 0, 4, vars["format_colorFunc15"].GetValue(vars["w_info"]:Get(), vars["w_lines"]:Get(), period, mode));
            if vars["tbl_show_stats"] then
                Table:CellText(vars["stats"]:Get(), 1, 3, vars["format_resultFunc16"].GetValue(info_Gethit_ph(vars["w_info"]:Get()), info_Getbias_ph(vars["w_info"]:Get()), period, mode));
                Table:CellTextColor(vars["stats"]:Get(), 1, 3, core.COLOR_LABEL);
                Table:CellTextSize(vars["stats"]:Get(), 1, 3, SafeGetString(vars["text_size"], period));
                Table:CellTextHAlign(vars["stats"]:Get(), 1, 3, "center");
                Table:CellText(vars["stats"]:Get(), 1, 4, vars["format_resultFunc17"].GetValue(info_Gethit_pl(vars["w_info"]:Get()), info_Getbias_pl(vars["w_info"]:Get()), period, mode));
                Table:CellTextColor(vars["stats"]:Get(), 1, 4, core.COLOR_LABEL);
                Table:CellTextSize(vars["stats"]:Get(), 1, 4, SafeGetString(vars["text_size"], period));
                Table:CellTextHAlign(vars["stats"]:Get(), 1, 4, "center");
                Table:CellText(vars["stats"]:Get(), 2, 3, vars["format_resultFunc18"].GetValue(info_Getclose_ph(vars["w_info"]:Get()), info_Gethit_ph(vars["w_info"]:Get()), period, mode));
                Table:CellTextColor(vars["stats"]:Get(), 2, 3, core.COLOR_LABEL);
                Table:CellTextSize(vars["stats"]:Get(), 2, 3, SafeGetString(vars["text_size"], period));
                Table:CellTextHAlign(vars["stats"]:Get(), 2, 3, "center");
                Table:CellText(vars["stats"]:Get(), 2, 4, vars["format_resultFunc19"].GetValue(info_Getclose_pl(vars["w_info"]:Get()), info_Gethit_pl(vars["w_info"]:Get()), period, mode));
                Table:CellTextColor(vars["stats"]:Get(), 2, 4, core.COLOR_LABEL);
                Table:CellTextSize(vars["stats"]:Get(), 2, 4, SafeGetString(vars["text_size"], period));
                Table:CellTextHAlign(vars["stats"]:Get(), 2, 4, "center");
                Table:CellText(vars["stats"]:Get(), 3, 3, Str:ToString(info_Getbias_ph(vars["w_info"]:Get())));
                Table:CellTextColor(vars["stats"]:Get(), 3, 3, core.COLOR_LABEL);
                Table:CellTextSize(vars["stats"]:Get(), 3, 3, SafeGetString(vars["text_size"], period));
                Table:CellTextHAlign(vars["stats"]:Get(), 3, 3, "center");
                Table:CellText(vars["stats"]:Get(), 3, 4, Str:ToString(info_Getbias_pl(vars["w_info"]:Get())));
                Table:CellTextColor(vars["stats"]:Get(), 3, 4, core.COLOR_LABEL);
                Table:CellTextSize(vars["stats"]:Get(), 3, 4, SafeGetString(vars["text_size"], period));
                Table:CellTextHAlign(vars["stats"]:Get(), 3, 4, "center");
            end
        end
    end
    plot7[period] = info_Getbias(vars["d_info"]:Get());
    plot8[period] = info_Getbias(vars["w_info"]:Get());
end
function Draw(stage, context)
    Line:Draw(stage, context);
    Label:Draw(stage, context);
    Table:Draw(stage, context);
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
end
Str = {};
function Str:NewVar(value)
    local var = {};
    var.items = {};
    var.items[0] = value;
    function var:Get(period)
        if period < 0 then
            return nil;
        end
        return self.items[period];
    end
    function var:Set(period, value)
        self.items[period] = value;
    end
    return var;
end
function Str:Clear()
end
function Str:doFormat(pattern, values)
    local tokens = core.parseCsv(pattern, ",");
    local value = values[tonumber(tokens[0])];
    if value == nil then
        return "";
    end
    if tokens[1] == "number" then
        if tokens[2] == "percent" then
            return tostring(math.floor(value + 0.5)) .. "%";
        end
    end
    return tostring(value);
end
function Str:Format(pattern, value0, value1, value2, value3, value4, value5, value6, value7, value8, value9)
    local values = {};
    values[0] = value0;
    values[1] = value1;
    values[2] = value2;
    values[3] = value3;
    values[4] = value4;
    values[5] = value5;
    values[6] = value6;
    values[7] = value7;
    values[8] = value8;
    values[9] = value9;

    local tokens = core.parseCsv(pattern, "{");
    local result = "";
    for i, token in ipairs(tokens) do
        local subtokens, c = core.parseCsv(token, "}");
        if c == 1 then
            result = result .. token;
        else
            result = result .. Str:doFormat(subtokens[0], values) .. subtokens[1];
        end
    end
    return result;
end
function Str:ToString(value, pattern)
    if value == nil then
        return "";
    end
    if pattern == nil then
        return tostring(value);
    end
    if pattern == "percent" then
        return win32.formatNumber(value, false, 2);
    end
    local luaPattern = "";
    local waitNumber = false;
    local digits = 0;
    for i = 1, #pattern do
        local char = string.sub(pattern, i, i);
        if not waitNumber then
            if char == "#" then
                waitNumber = true;
                luaPattern = luaPattern .. "%";
            else
                luaPattern = luaPattern .. char;
            end
        else
            if char == "." then
                luaPattern = luaPattern .. ".";
            elseif char == "#" then
                digits = digits + 1;
            else
                luaPattern = luaPattern .. digits .. "f";
                waitNumber = false;
                digits = 0;
            end
        end
    end
    if waitNumber then
        luaPattern = luaPattern .. digits .. "f";
        waitNumber = false;
        digits = 0;
    end
    
    return string.format(luaPattern, value);
end
function Str:Length(str)
    if str == nil then
        return 0;
    end
    return string.len(str);
end
function Str:ReplaceAll(str, from, to)
    if str == nil then
        return nil;
    end
    return string.gsub(str, from, to);
end
function Str:Upper(str)
    if str == nil then
        return nil;
    end
    return string.upper(str);
end
function Str:StartsWith(str, item)
    if str == nil then
        return nil;
    end
    return string.find(str, item) == 1;
end
function Str:Split(str, separator)
    if str == nil then
        return nil;
    end
    local items, c = core.parseCsv(str, separator);
    local arr = Array:NewString(0);
    for i = 0, c - 1 do
        arr:Push(items[i]);
    end
    return arr;
end
function SafeSetString(str, period, value)
    if str == nil then
        return;
    end
    str:Set(period, value);
end
function SafeGetString(str, period)
    if str == nil then
        return;
    end
    return str:Get(period);
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
    return math.floor(transparency * 100.0 / 255.0 + 0.5);
end
function Graphics:AddTransparency(clr, transp)
    if clr == nil then
        return nil;
    end
    color, _ = Graphics:SplitColorAndTransparency(clr);
    return color + math.floor(transp / 100 * 255) * 16777216;
end
Timeframe = {};
function Timeframe:Period()
    local bar_size = instance.source:barSize();
    if bar_size == "t1" then
        return "t";
    elseif string.sub(bar_size, 1, 1) == "m" then
        local seconds = tonumber(string.sub(bar_size, 2));
        return tostring(seconds);
    elseif string.sub(bar_size, 1, 1) == "H" then
        local seconds = 60 * tonumber(string.sub(bar_size, 2));
        return tostring(seconds);
    elseif string.sub(bar_size, 1, 1) == "D" then
        return "D";
    elseif string.sub(bar_size, 1, 1) == "W" then
        return "D";
    elseif string.sub(bar_size, 1, 1) == "M" then
        return "M";
    end
    return "0";
end
function Timeframe:IsIntraday()
    local bar_size = instance.source:barSize();
    if bar_size == "t1" then
        return true;
    elseif string.sub(bar_size, 1, 1) == "m" then
        return true;
    elseif string.sub(bar_size, 1, 1) == "H" then
        return true;
    end
    return false;
end
function Timeframe:Interval()
    local bar_size = instance.source:barSize();
    if bar_size == "t1" then
        return "0";
    elseif string.sub(bar_size, 1, 1) == "m" then
        return tonumber(string.sub(bar_size, 2));
    elseif string.sub(bar_size, 1, 1) == "H" then
        return tonumber(string.sub(bar_size, 2));
    elseif string.sub(bar_size, 1, 1) == "D" then
        return "1";
    elseif string.sub(bar_size, 1, 1) == "W" then
        return "1";
    elseif string.sub(bar_size, 1, 1) == "M" then
        return "1";
    end
    return "0";
end
function Timeframe:InSeconds(timeframe, source)
    if timeframe == "M" then
        return 86400 * 30;
    elseif timeframe == "D" then
        return 86400;
    elseif timeframe == "t" then
        return 1;
    else
        local minutes = tonumber(timeframe);
        if minutes == nil then
            return nil;
        end
        return minutes * 60;
    end
    return nil;
end
function Timeframe:GetBarSize(timeframe)
    if timeframe == "M" then
        return "M1";
    elseif timeframe == "D" then
        return "D1";
    elseif timeframe == "t" then
        return "t1";
    else
        local minutes = tonumber(timeframe);
        if minutes == 1 then
            return "m1";
        elseif minutes == 5 then
            return "m5";
        elseif minutes == 15 then
            return "m15";
        elseif minutes == 30 then
            return "m30";
        elseif minutes == 60 then
            return "h1";
        elseif minutes == 120 then
            return "h2";
        elseif minutes == 180 then
            return "h3";
        elseif minutes == 240 then
            return "h4";
        elseif minutes == 360 then
            return "h6";
        elseif minutes == 480 then
            return "h8";
        end
    end
    return nil;
end
function Timeframe:Change(timeframe, source, period)
    if period <= 0 then
        return false;
    end
    local barSize = Timeframe:GetBarSize(timeframe);
    if barSize == nil then
        return false;
    end
    tradingWeekOffset = core.host:execute("getTradingWeekOffset");
    tradingDayOffset = core.host:execute("getTradingDayOffset");
    local currentDate = core.getcandle(barSize, source:date(period), tradingDayOffset, tradingWeekOffset);
    local prevDate = core.getcandle(barSize, source:date(period - 1), tradingDayOffset, tradingWeekOffset);
    return currentDate ~= prevDate;
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
    if value == nil then
        stream:setNoData(period);
        return;
    end
    stream[period] = value and 1 or 0;
end
function SafeGetBool(stream, period)
    if stream == nil or not stream:hasData(period) then
        return nil;
    end
    return stream[period] == 1;
end
function SafeSetFloat(stream, period, value)
    if value == nil then
        stream:setNoData(period);
        return;
    end
    stream[period] = value;
end
function SafeGetFloat(stream, period)
    if stream == nil then
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
        if self.Y1 == nil or self.Y2 == nil or self.X1 == nil or self.X2 == nil then
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
    self.AllLines[#self.AllLines + 1] = newLine;
    if #self.AllLines > self.max_lines_count then
        table.remove(self.AllLines, 1);
    end
    return newLine;
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
Array = {};
function Array:Enum(array)
    if array == nil then
        return {};
    end
    return array.arr;
end
function Array:Clear(array)
    if array == nil then
        return;
    end
    array:Clear();
end
function Array:Copy(array)
    if array == nil then
        return;
    end
    return array:Copy();
end
function Array:Get(array, index)
    if array == nil then
        return;
    end
    return array:Get(index);
end
function Array:Join(array, separator)
    if array == nil then
        return;
    end
    return array:Join(separator);
end
function Array:Reverse(array)
    if array == nil then
        return;
    end
    return array:Reverse();
end
function Array:Remove(array, index)
    if array == nil then
        return;
    end
    return array:Remove(index);
end
function Array:Max(array)
    local maxVal = array:Get(0);
    for i = 1, array:Size() - 1 do
        local val = array:Get(i);
        if maxVal == nil or (val ~= nil and maxVal < val) then
            maxVal = val;
        end
    end
    return maxVal;
end
function Array:Min(array)
    local minVal = array:Get(0);
    for i = 1, array:Size() - 1 do
        local val = array:Get(i);
        if minVal == nil or (val ~= nil and minVal > val) then
            minVal = val;
        end
    end
    return minVal;
end
function Array:Pop(array)
    if array == nil then
        return nil;
    end
    return array:Pop();
end
function Array:Set(array, index, value)
    if array == nil then
        return;
    end
    array:Set(index, value);
end
function Array:Fill(array, value, from, to)
    if array == nil then
        return;
    end
    array:Fill(value, from, to);
end
function Array:IndexOf(array, value)
    if array == nil then
        return -1;
    end
    return array:IndexOf(value);
end
function Array:Includes(array, value)
    if array == nil then
        return nil;
    end
    return array:Includes(value);
end
function Array:New(size, initialValue)
    local newArray = {};
    newArray.arr = {};
    if size ~= nil then
        newArray.size = size;
        for i = 1, size, 1 do
            newArray.arr[i] = initialValue;
        end
    else
        newArray.size = 0;
    end
    function newArray:Push(item) self.size = self.size + 1; self.arr[#self.arr + 1] = item; return self; end
    function newArray:Get(index) return self.arr[index + 1]; end
    function newArray:Set(index, value) self.arr[index + 1] = value; end
    function newArray:Max() return Array:Max(self); end
    function newArray:Min() return Array:Min(self); end
    function newArray:Size() return self.size; end
    function newArray:Clear()
        self.arr = {};
        self.size = 0;
    end
    function newArray:Pop()
        local lastVal = self.arr[self.size];
        table.remove(self.arr, self.size);
        self.size = self.size - 1;
        return lastVal;
    end
    function newArray:Fill(value, from, to)
        if to == nil then
            to = self.size - 1;
        end
        for i = from, to, 1 do
            self.arr[i + 1] = value;
        end
    end
    function newArray:IndexOf(value)
        for i, v in ipairs(self.arr) do
            if v == value then
                return i;
            end
        end
        return -1;
    end
    function newArray:Includes(value)
        for i, v in ipairs(self.arr) do
            if v == value then
                return true;
            end
        end
        return false;
    end
    function newArray:Sum()
        local sum = 0;
        for i, v in ipairs(self.arr) do
            sum = sum + v;
        end
        return sum;
    end
    function newArray:Copy()
        local arrayCopy = Array:New(self.size, nil);
        for i = 1, self.size, 1 do
            arrayCopy.arr[i] = self.arr[i];
        end
        return arrayCopy;
    end
    function newArray:Reverse()
        local half = math.floor(self.size / 2);
        for i = 1, half, 1 do
            local swapped = self.arr[self.size - i + 1];
            self.arr[self.size - i + 1] = self.arr[i];
            self.arr[i] = swapped;
        end
    end
    function newArray:Unshift(value)
        local nextValue = value;
        for i = 1, self.size, 1 do
            local current = self.arr[i];
            self.arr[i] = nextValue;
            nextValue = current;
        end
        self.arr[self.size + 1] = nextValue;
        self.size = self.size + 1;
    end
    function newArray:Join(separator)
        if self.size == 0 then
            return "";
        end
        local str = tostring(self.arr[1]);
        for i = 2, self.size, 1 do
            if self.arr[i] ~= nil then
                str = str .. separator .. tostring(self.arr[i]);
            end
        end
        return str;
    end
    function newArray:Shift()
        local value = self.arr[1];
        table.remove(self.arr, 1);
        self.size = self.size - 1;
        return value;
    end
    function newArray:Remove(index)
        local value = self.arr[index];
        table.remove(self.arr, index);
        self.size = self.size - 1;
        return value;
    end
    function newArray:Slice(from, to)
        local slice = {};
        slice.Parent = self;
        slice.From = from;
        slice.To = to;
        function slice:Get(index)
            return self.Parent:Get(index + self.From);
        end
        function slice:Size()
            return self.To - self.From;
        end
        function slice:Max()
            return Array:Max(self);
        end
        function slice:Min()
            return Array:Min(self);
        end
        return slice;
    end
    return newArray;
end
function Array:NewLine(size, initialValue)
    return Array:New(size, initialValue);
end
function Array:NewInt(size, initialValue)
    return Array:New(size, initialValue);
end
function Array:NewFloat(size, initialValue)
    return Array:New(size, initialValue);
end
function Array:NewLabel(size, initialValue)
    return Array:New(size, initialValue);
end
function Array:NewString(size, initialValue)
    return Array:New(size, initialValue);
end
function Array:NewBox(size, initialValue)
    return Array:New(size, initialValue);
end
function Array:NewBool(size, initialValue)
    return Array:New(size, initialValue);
end
function Array:NewColor(size, initialValue)
    return Array:New(size, initialValue);
end
Label = {};
Label.AllLabelsInOrder = {};
Label.AllSeries = {};
function Label:Clear()
    Label.AllSeries = {};
    Label.AllLabelsInOrder = {};
end
function Label:Prepare(max_labels_count)
    Label.max_labels_count = max_labels_count;
end
function Label:Get(label, index)
    if label == nil then
        return;
    end
    return label:Get(index);
end
function Label:SetText(label, text)
    if label == nil then
        return;
    end
    label:SetText(text);
end
function Label:SetTooltip(label, text)
    if label == nil then
        return;
    end
    label:SetTooltip(text);
end
function Label:SetSize(label, size)
    if label == nil then
        return;
    end
    label:SetSize(size);
end
function Label:SetX(label, x)
    if label == nil then
        return;
    end
    label:SetX(x);
end
function Label:SetXY(label, x, y)
    if label == nil then
        return;
    end
    label:SetX(x);
    label:SetY(y);
end
function Label:SetY(label, y)
    if label == nil then
        return;
    end
    label:SetY(y);
end
function Label:GetX(label)
    if label == nil then
        return;
    end
    return label:GetX();
end
function Label:GetY(label)
    if label == nil then
        return;
    end
    return label:GetY();
end
function Label:SetStyle(label, style)
    if label == nil then
        return;
    end
    return label:SetStyle(style);
end
function Label:New(id, seriesId, period, price)
    local newLabel = {};
    newLabel.SeriesId = seriesId;
    newLabel.X = period;
    function newLabel:SetX(x)
        self.X = x;
        return self;
    end
    function newLabel:GetX()
        return self.X;
    end
    newLabel.Y = price;
    function newLabel:SetY(y)
        self.Y = y;
        return self;
    end
    function newLabel:GetY()
        return self.Y;
    end
    newLabel.Text = "";
    function newLabel:SetText(text)
        self.Text = text;
        return self;
    end
    newLabel.BGColor = nil;
    function newLabel:SetColor(clr)
        if clr ~= nil then
            self.BgColorTransparency = (math.floor(clr / 16777216) % 256);
            self.BGColor = clr - self.BgColorTransparency * 16777216;
        else
            self.BgColorTransparency = nil;
            self.BGColor = nil;
        end
        self.BGPenId = nil;
        self.BGBrushId = nil;
        return self;
    end
    newLabel.TextColor = core.colors().Black;
    function newLabel:SetTextColor(clr)
        self.TextColor = clr;
        return self;
    end
    function newLabel:SetTooltip(tooltip)
        return self;
    end
    newLabel.Style = "down";
    function newLabel:SetStyle(style)
        self.Style = style;
        return self;
    end
    function newLabel:getCoordinates(context, W, H)
        local visible, y = context:pointOfPrice(self.Y);
        local x1, x = context:positionOfBar(self.X)
        if self.Style == "left" then
            return x1, y - H / 2, x1 + W, y + H / 2;
        end
        if self.Style == "down" then
            return x1 - W / 2, y - H, x1 + W / 2, y;
        end
        if self.Style == "up" then
            return x1 - W / 2, y, x1 + W / 2, y + H;
        end
        return x1 - W / 2, y - H / 2, x1 + W / 2, y + H / 2;
    end
    newLabel.Size = "auto";
    function newLabel:SetSize(size)
        self.Size = size;
        return self;
    end
    function newLabel:GetDefaultSize()
        if self.Size == "tiny" then
            return 7, 7;
        end
        if self.Size == "auto" or self.Size == "small" then
            return 10, 10;
        end
        if self.Size == "normal" then
            return 12, 12;
        end
        if self.Size == "large" then
            return 14, 14;
        end
        return 16, 16;
    end
    function newLabel:Draw(stage, context)
        if self.X == nil or self.Y == nil then
            return;
        end
        if self.FontId == nil then
            local defFontSize = self:GetDefaultSize();
            self.FontId = Graphics:FindFont("Arial", 0, defFontSize, context.LEFT, context);
        end
        local W, H;
        if self.Text == nil or self.Text == "" then
            W, H = self:GetDefaultSize()
        else
            W, H = context:measureText(self.FontId, self.Text, context.LEFT);
        end
        local x_from, y_from, x_to, y_to = self:getCoordinates(context, W, H);
        if self.BGColor ~= nil then
            if self.BGPenId == nil then
                self.BGPenId = Graphics:FindPen(1, self.BGColor, core.LINE_SOLID, context);
            end
            if self.BGBrushId == nil then
                self.BGBrushId = Graphics:FindBrush(self.BGColor, context);
            end
            if self.Style == "down" then
                local ySize = math.abs(y_from - y_to);
                y_from = y_from - ySize / 2;
                y_to = y_to - ySize / 2;
                local points = context:createPoints();
                points:add(x_from, y_to);
                points:add(x_to, y_to);
                points:add((x_to + x_from) / 2, y_to + ySize / 2);
                context:drawPolygon(self.BGPenId, self.BGBrushId, points, self.BgColorTransparency);
                context:drawRectangle(self.BGPenId, self.BGBrushId, x_from - 1, y_from - 1, x_to + 1, y_to + 1, self.BgColorTransparency);
            elseif self.Style == "up" then
                local ySize = math.abs(y_from - y_to);
                y_from = y_from + ySize / 2;
                y_to = y_to + ySize / 2;
                local points = context:createPoints();
                points:add(x_from, y_from - 1);
                points:add(x_to, y_from - 1);
                points:add((x_to + x_from) / 2, y_from - ySize / 2);
                context:drawPolygon(self.BGPenId, self.BGBrushId, points, self.BgColorTransparency);
                context:drawRectangle(self.BGPenId, self.BGBrushId, x_from - 1, y_from - 1, x_to + 1, y_to + 1, self.BgColorTransparency);
            elseif self.Style == "none" then
            else
                context:drawRectangle(self.BGPenId, self.BGBrushId, x_from - 1, y_from - 1, x_to + 1, y_to + 1, self.BgColorTransparency);
            end
        end
        context:drawText(self.FontId, self.Text, self.TextColor, -1, x_from, y_from, x_to, y_to, 0);
    end
    function newLabel:Get(index)
        return Label.AllSeries[self.SeriesId][index + 1];
    end
    self.AllLabelsInOrder[#self.AllLabelsInOrder + 1] = newLabel
    if #self.AllLabelsInOrder > self.max_labels_count then
        Label:Delete(self.AllLabelsInOrder[1]);
    end
    if self.AllSeries[seriesId] == nil then
        self.AllSeries[seriesId] = {};
    end
    table.insert(self.AllSeries[seriesId], 1, newLabel);
    return newLabel;
end
function Label:Delete(label)
    if label == nil then
        return;
    end
    self:removeFromAllLabelsByOrder(label);
    self:removeFromSeries(label);
end
function Label:removeFromSeries(label)
    for i = 1, #self.AllSeries[label.SeriesId] do
        if self.AllSeries[label.SeriesId][i] == label then
            table.remove(self.AllSeries[label.SeriesId], i);
            return;
        end
    end
end
function Label:removeFromAllLabelsByOrder(label)
    for i = 1, #self.AllLabelsInOrder do
        if self.AllLabelsInOrder[i] == label then
            table.remove(self.AllLabelsInOrder, i);
            return;
        end
    end
end
function Label:Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    for i = 1, #self.AllLabelsInOrder do
        self.AllLabelsInOrder[i]:Draw(stage, context);
    end
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
Table = {};
Table.AllTables = {};
function Table:Clear()
    Table.AllTables = {};
end
function Table:MergeCells(table, start_column, start_row, end_column, end_row)
    if table == nil then
        return;
    end
    table:MergeCells(start_column, start_row, end_column, end_row);
end
function Table:CellText(table, column, row, text)
    if table == nil then
        return;
    end
    table:CellText(column, row, text)
end
function Table:CellTextColor(table, column, row, color)
    if table == nil then
        return;
    end
    table:CellTextColor(column, row, color)
end
function Table:CellBGColor(table, column, row, color)
    if table == nil then
        return;
    end
    table:CellBGColor(column, row, color)
end
function Table:CellTextSize(table, column, row, size)
    if table == nil then
        return;
    end
    table:CellTextSize(column, row, size)
end
function Table:CellTextHAlign(table, column, row, halign)
    if table == nil then
        return;
    end
    table:CellTextHAlign(column, row, halign)
end
function Table:New(id, position, columns, rows)
    local newTable = {};
    newTable.offset = 5;
    newTable.position = position;
    newTable.border_width = 1;
    function newTable:SetBorderWidth(width)
        self.border_width = width;
        return self;
    end
    newTable.bgcolor = nil;
    function newTable:SetBgColor(color)
        local clr, transp = Graphics:SplitColorAndTransparency(color);
        self.bgcolor = clr;
        self.bgcolor_transparency = transp;
        return self;
    end
    newTable.border_color = core.colors().Gray;
    newTable.border_style = core.LINE_SOLID;
    function newTable:SetBorderColor(color)
        local clr, transp = Graphics:SplitColorAndTransparency(color);
        self.border_color = clr;
        self.border_color_transparency = transp;
        return self;
    end
    newTable.frame_color = core.colors().Gray;
    function newTable:SetFrameColor(color)
        local clr, transp = Graphics:SplitColorAndTransparency(color);
        self.frame_color = clr;
        self.frame_color_transparency = transp;
        return self;
    end
    newTable.frame_width = 1;
    function newTable:SetFrameWidth(width)
        self.frame_width = width;
        return self;
    end
    newTable.rows = {};
    for i = 1, rows, 1 do
        newTable.rows[i] = {};
        for ii = 1, columns, 1 do
            local cell = {};
            cell.text = "";
            cell.text_color = core.COLOR_LABEL;
            cell.text_halign = "middle";
            cell.text_size = "normal";
            cell.cache = {};
            newTable.rows[i][ii] = cell;
        end
    end
    function newTable:CellText(column, row, text)
        if self.rows[row + 1][column + 1].text ~= text then
            self.rows[row + 1][column + 1].cache = {};
        end
        self.rows[row + 1][column + 1].text = text;
        return self;
    end
    function newTable:CellTextColor(column, row, color)
        local clr, transp = Graphics:SplitColorAndTransparency(color);
        self.rows[row + 1][column + 1].text_color = clr;
        return self;
    end
    function newTable:CellBGColor(column, row, color)
        local clr, transp = Graphics:SplitColorAndTransparency(color);
        self.rows[row + 1][column + 1].bg_color = clr;
        return self;
    end
    function newTable:CellTextSize(column, row, size)
        if self.rows[row + 1][column + 1].text_size ~= size then
            self.rows[row + 1][column + 1].cache = {};
        end
        self.rows[row + 1][column + 1].text_size = size;
        return self;
    end
    function newTable:CellTextHAlign(column, row, halign)
        if self.rows[row + 1][column + 1].text_halign ~= halign then
            self.rows[row + 1][column + 1].cache = {};
        end
        self.rows[row + 1][column + 1].text_halign = halign;
        return self;
    end
    function newTable:MergeCells(start_column, start_row, end_column, end_row)
        for columnIndex = start_column + 1, end_column + 1 do
            for rowIndex = start_row + 1, end_row + 1 do
                if columnIndex ~= start_column + 1 or rowIndex ~= start_row + 1 then
                    self.rows[rowIndex][columnIndex].skip = true;
                else
                    self.rows[rowIndex][columnIndex].skip = nil;
                    self.rows[rowIndex][columnIndex].till_row = end_row + 1;
                    self.rows[rowIndex][columnIndex].till_column = end_column + 1;
                end
            end
        end
        return self;
    end
    function newTable:getRowDirection()
        if self.position == "top_left" or self.position == "top_right" or self.position == "top_middle" then
            return 1;
        end
        if self.position == "bottom_left" or self.position == "bottom_right" or self.position == "bottom_middle" then
            return -1;
        end
        return 0;
    end
    function newTable:getColumnDirection()
        if self.position == "top_left" or self.position == "bottom_left" or self.position == "middle_left" then
            return 1;
        end
        if self.position == "top_right" or self.position == "bottom_right" or self.position == "middle_right" then
            return -1;
        end
        return 0;
    end
    function newTable:measureCells(context)
        local columnWidths = {};
        local rowHeights = {};
        local total_height = 0;
        local total_width = 0;
        for row = 1, #self.rows do
            for column = 1, #self.rows[row] do
                local W, H;
                if self.rows[row][column].cache.W ~= nil then
                    W = self.rows[row][column].cache.W;
                    H = self.rows[row][column].cache.H;
                else
                    if self.rows[row][column].text ~= nil then
                        W, H = context:measureText(Table.FontId, self.rows[row][column].text, context.LEFT);
                        if W > 0 then
                            W = W + self.offset * 2;
                        end
                        if H > 0 then
                            H = H + self.offset * 2;
                        end
                    else
                        W, H = 0, 0;
                    end
                    self.rows[row][column].cache.W = W;
                    self.rows[row][column].cache.H = H;
                end
                if columnWidths[column] == nil or columnWidths[column] < W then
                    columnWidths[column] = W;
                end
                if rowHeights[row] == nil or rowHeights[row] < H then
                    rowHeights[row] = H;
                end
            end
            total_height = total_height + rowHeights[row];
        end
        for i = 1, #columnWidths do
            total_width = total_width + columnWidths[i];
        end
        return rowHeights, columnWidths, total_height, total_width;
    end
    function newTable:getCellWidth(row, column, columnWidths)
        local w = columnWidths[column];
        local shift = 0;
        if self.rows[row][column].till_column ~= nil and self.rows[row][column].till_column ~= column then
            for i = column + 1, self.rows[row][column].till_column do
                w = w + columnWidths[i];
                shift = shift + columnWidths[i];
            end
        end
        return w, shift;
    end
    function newTable:getCellHeight(row, column, rowHeights)
        local h = rowHeights[row];
        local shift = 0;
        if self.rows[row][column].till_row ~= nil and self.rows[row][column].till_row ~= row then
            for i = row + 1, self.rows[row][column].till_row do
                h = h + rowHeights[i];
                shift = shift + rowHeights[i];
            end
        end
        return h, shift;
    end
    function newTable:getLabelXCoordinates(rectangle_x1, rectangle_x2, width, align)
        local x = (rectangle_x1 + rectangle_x2) / 2;
        if align == "left" then
            local text_x1 = rectangle_x1;
            local text_x2 = text_x1 + width;
            return text_x1, text_x2;
        elseif align == "right" then
            local text_x2 = rectangle_x2;
            local text_x1 = text_x2 - width;
            return text_x1, text_x2;
        end
        local text_x1 = x - width / 2;
        local text_x2 = text_x1 + width;
        return text_x1, text_x2;
    end
    function newTable:drawCell(context, row, column, rowHeights, columnWidths, yStart, xStart, totalRows, totalColumns)
        local rectangle_x1;
        local rectangle_x2;
        local rectangle_y1;
        local rectangle_y2;
        local width, w_shift = self:getCellWidth(row, column, columnWidths);
        local height, h_shift = self:getCellHeight(row, column, rowHeights);
        rectangle_y1 = yStart;
        rectangle_y2 = yStart + height;
        rectangle_x1 = xStart;
        rectangle_x2 = xStart + width;
        local text_x1, text_x2 = self:getLabelXCoordinates(rectangle_x1, rectangle_x2, self.rows[row][column].cache.W,
            self.rows[row][column].text_halign);
        local y = (rectangle_y1 + rectangle_y2) / 2;
        local text_y1 = y - self.rows[row][column].cache.H / 2;
        local text_y2 = y + self.rows[row][column].cache.H;
        text_x1 = text_x1 + self.offset;
        text_x2 = text_x2 - self.offset;
        text_y1 = text_y1 + self.offset;
        text_y2 = text_y2 - self.offset;
        local bgBrush = self.BgBrushId;
        if self.rows[row][column].bg_color ~= nil then
            if self.rows[row][column].bg_brushId == nil then
                self.rows[row][column].bg_brushId = Graphics:FindBrush(self.rows[row][column].bg_color, context);
            end
            bgBrush = self.rows[row][column].bg_brushId;
        end
        if bgBrush ~= nil then
            context:drawRectangle(self.FramePenId, bgBrush, rectangle_x1, rectangle_y1, rectangle_x2, rectangle_y2, self.bgcolor_transparency)
        end
        if self.BorderPenId ~= nil then
            if totalRows ~= row then
                context:drawLine(self.BorderPenId, rectangle_x1, rectangle_y2, rectangle_x2, rectangle_y2);
            end
            if totalColumns ~= column then
                context:drawLine(self.BorderPenId, rectangle_x2, rectangle_y1, rectangle_x2, rectangle_y2);
            end
        end
        context:drawText(Table.FontId, self.rows[row][column].text, self.rows[row][column].text_color, -1, 
            text_x1, text_y1, text_x2, text_y2, 0);
    end
    function newTable:Draw(stage, context)
        if self.bgcolor ~= nil and self.BgBrushId == nil then
            self.BgBrushId = Graphics:FindBrush(self.bgcolor, context);
        end
        if self.FramePenId == nil and self.frame_color ~= nil then
            self.FramePenId = Graphics:FindPen(self.frame_width or 1, self.frame_color, self.frame_style or core.LINE_SOLID, context);
        end
        if self.BorderPenId == nil and self.border_color ~= nil then
            self.BorderPenId = Graphics:FindPen(self.border_width or 1, self.border_color, self.border_style or core.LINE_SOLID, context);
        end
        local rowHeights, columnWidths, total_height, total_width = self:measureCells(context);
        
        local rowDirection = self:getRowDirection();
        local columnDirection = self:getColumnDirection();
        local x = columnDirection == 1 and context:left() or (context:right() - total_width);
        local y = rowDirection == 1 and context:top() or context:bottom() - total_height;
        local maxX = x;
        local yStart = y;
        local totalRows = #self.rows;
        for rowIt = 1, totalRows do
            local row = rowIt;
            local xStart = x; 
            local totalCoumns = #self.rows[rowIt];
            for columnIt = 1, totalCoumns do
                local column = columnIt;
                if not self.rows[row][column].skip then
                    self:drawCell(context, row, column, rowHeights, columnWidths, yStart, xStart, totalRows, totalCoumns);
                end
                xStart = xStart + columnWidths[column];
            end
            maxX = math.max(maxX, xStart);
            yStart = yStart + rowHeights[row];
        end
        if self.FramePenId ~= nil then
            context:drawLine(self.FramePenId, x, y, x, yStart);
            context:drawLine(self.FramePenId, maxX, y, maxX, yStart);
            context:drawLine(self.FramePenId, x, y, maxX, y);
            context:drawLine(self.FramePenId, x, yStart, maxX, yStart);
        end
    end
    self.AllTables[id] = newTable;
    return newTable;
end
function Table:Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if Table.FontId == nil then
        Table.FontId = Graphics:FindFont("Arial", 0, context:pointsToPixels(10), context.LEFT, context);
    end
    for id, table in pairs(self.AllTables) do
        table:Draw(stage, context);
    end
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76394
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