-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76407
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
    indicator:name("ICT Institutional Order Flow (fadi)");
    indicator:description("ICT Institutional Order Flow (fadi)");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addBoolean("param1", "Short             ", "", false);
    indicator.parameters:addColor("param2", "", "", core.colors().Black);
    indicator.parameters:addColor("param3", "", "", core.colors().Black);
    indicator.parameters:addColor("param4", "", "", Graphics:GetColor(core.rgb(255, 255, 0)));
    indicator.parameters:addBoolean("param5", "Intermediate       ", "", true);
    indicator.parameters:addColor("param6", "", "", Graphics:GetColor(core.colors().Purple + math.floor(0 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param7", "", "", Graphics:GetColor(core.colors().Purple + math.floor(0 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param8", "", "", Graphics:GetColor(core.rgb(255, 255, 0)));
    indicator.parameters:addBoolean("param9", "Long             ", "", true);
    indicator.parameters:addColor("param10", "", "", Graphics:GetColor(core.colors().Blue + math.floor(0 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param11", "", "", Graphics:GetColor(core.colors().Blue + math.floor(0 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param12", "", "", Graphics:GetColor(core.rgb(255, 255, 0)));
    indicator.parameters:addString("param13", "Short            ", "", "High/Low");
    indicator.parameters:addStringAlternative("param13", "■", "", "■");
    indicator.parameters:addStringAlternative("param13", "□", "", "□");
    indicator.parameters:addStringAlternative("param13", "▣", "", "▣");
    indicator.parameters:addStringAlternative("param13", "◆", "", "◆");
    indicator.parameters:addStringAlternative("param13", "◇", "", "◇");
    indicator.parameters:addStringAlternative("param13", "◈", "", "◈");
    indicator.parameters:addStringAlternative("param13", "●", "", "●");
    indicator.parameters:addStringAlternative("param13", "○", "", "○");
    indicator.parameters:addStringAlternative("param13", "◉", "", "◉");
    indicator.parameters:addStringAlternative("param13", "▲▼", "", "▲▼");
    indicator.parameters:addStringAlternative("param13", "△▽", "", "△▽");
    indicator.parameters:addStringAlternative("param13", "↑↓", "", "↑↓");
    indicator.parameters:addStringAlternative("param13", "S/I/L Term", "", "S/I/L Term");
    indicator.parameters:addStringAlternative("param13", "High/Low", "", "High/Low");
    indicator.parameters:addString("param14", "", "", "tiny");
    indicator.parameters:addStringAlternative("param14", "tiny", "", "tiny");
    indicator.parameters:addStringAlternative("param14", "small", "", "small");
    indicator.parameters:addStringAlternative("param14", "normal", "", "normal");
    indicator.parameters:addStringAlternative("param14", "large", "", "large");
    indicator.parameters:addStringAlternative("param14", "huge", "", "huge");
    indicator.parameters:addString("param15", "Intermediate      ", "", "High/Low");
    indicator.parameters:addStringAlternative("param15", "■", "", "■");
    indicator.parameters:addStringAlternative("param15", "□", "", "□");
    indicator.parameters:addStringAlternative("param15", "▣", "", "▣");
    indicator.parameters:addStringAlternative("param15", "◆", "", "◆");
    indicator.parameters:addStringAlternative("param15", "◇", "", "◇");
    indicator.parameters:addStringAlternative("param15", "◈", "", "◈");
    indicator.parameters:addStringAlternative("param15", "●", "", "●");
    indicator.parameters:addStringAlternative("param15", "○", "", "○");
    indicator.parameters:addStringAlternative("param15", "◉", "", "◉");
    indicator.parameters:addStringAlternative("param15", "▲▼", "", "▲▼");
    indicator.parameters:addStringAlternative("param15", "△▽", "", "△▽");
    indicator.parameters:addStringAlternative("param15", "↑↓", "", "↑↓");
    indicator.parameters:addStringAlternative("param15", "S/I/L Term", "", "S/I/L Term");
    indicator.parameters:addStringAlternative("param15", "High/Low", "", "High/Low");
    indicator.parameters:addString("param16", "", "", "small");
    indicator.parameters:addStringAlternative("param16", "tiny", "", "tiny");
    indicator.parameters:addStringAlternative("param16", "small", "", "small");
    indicator.parameters:addStringAlternative("param16", "normal", "", "normal");
    indicator.parameters:addStringAlternative("param16", "large", "", "large");
    indicator.parameters:addStringAlternative("param16", "huge", "", "huge");
    indicator.parameters:addString("param17", "Long             ", "", "High/Low");
    indicator.parameters:addStringAlternative("param17", "■", "", "■");
    indicator.parameters:addStringAlternative("param17", "□", "", "□");
    indicator.parameters:addStringAlternative("param17", "▣", "", "▣");
    indicator.parameters:addStringAlternative("param17", "◆", "", "◆");
    indicator.parameters:addStringAlternative("param17", "◇", "", "◇");
    indicator.parameters:addStringAlternative("param17", "◈", "", "◈");
    indicator.parameters:addStringAlternative("param17", "●", "", "●");
    indicator.parameters:addStringAlternative("param17", "○", "", "○");
    indicator.parameters:addStringAlternative("param17", "◉", "", "◉");
    indicator.parameters:addStringAlternative("param17", "▲▼", "", "▲▼");
    indicator.parameters:addStringAlternative("param17", "△▽", "", "△▽");
    indicator.parameters:addStringAlternative("param17", "↑↓", "", "↑↓");
    indicator.parameters:addStringAlternative("param17", "S/I/L Term", "", "S/I/L Term");
    indicator.parameters:addStringAlternative("param17", "High/Low", "", "High/Low");
    indicator.parameters:addString("param18", "", "", "normal");
    indicator.parameters:addStringAlternative("param18", "tiny", "", "tiny");
    indicator.parameters:addStringAlternative("param18", "small", "", "small");
    indicator.parameters:addStringAlternative("param18", "normal", "", "normal");
    indicator.parameters:addStringAlternative("param18", "large", "", "large");
    indicator.parameters:addStringAlternative("param18", "huge", "", "huge");
    indicator.parameters:addInteger("param19", "Maximum number of labels    ", "", 50);
    indicator.parameters:addBoolean("param20", "Short             ", "", false);
    indicator.parameters:addColor("param21", "", "", Graphics:GetColor(core.colors().Black + math.floor(50 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param22", "", "", Graphics:GetColor(core.colors().Black + math.floor(50 / 100 * 255) * 16777216));
    indicator.parameters:addInteger("param23", "", "", 1);
    indicator.parameters:addBoolean("param24", "Intermediate       ", "", true);
    indicator.parameters:addColor("param25", "", "", Graphics:GetColor(core.colors().Purple + math.floor(50 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param26", "", "", Graphics:GetColor(core.colors().Purple + math.floor(50 / 100 * 255) * 16777216));
    indicator.parameters:addInteger("param27", "", "", 1);
    indicator.parameters:addBoolean("param28", "Long             ", "", true);
    indicator.parameters:addColor("param29", "", "", Graphics:GetColor(core.colors().Blue + math.floor(50 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param30", "", "", Graphics:GetColor(core.colors().Blue + math.floor(50 / 100 * 255) * 16777216));
    indicator.parameters:addInteger("param31", "", "", 1);
    indicator.parameters:addString("param32", "Open          ", "", "⎯⎯⎯");
    indicator.parameters:addStringAlternative("param32", "⎯⎯⎯", "", "⎯⎯⎯");
    indicator.parameters:addStringAlternative("param32", "----", "", "----");
    indicator.parameters:addStringAlternative("param32", "····", "", "····");
    indicator.parameters:addString("param33", "Claimed        ", "", "····");
    indicator.parameters:addStringAlternative("param33", "⎯⎯⎯", "", "⎯⎯⎯");
    indicator.parameters:addStringAlternative("param33", "----", "", "----");
    indicator.parameters:addStringAlternative("param33", "····", "", "····");
    indicator.parameters:addInteger("param34", "Extend", "", 5, 1);
    indicator.parameters:addInteger("param35", "Maximum number of lines", "", 50, 1, 250);
    indicator.parameters:addInteger("param36", "Maximum number of claimed lines", "", 5, 0, 250);
    indicator.parameters:addBoolean("param37", "Equal Levels", "", true);
    indicator.parameters:addColor("param38", "", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(67, 70, 81), 0)));
    indicator.parameters:addColor("param39", "", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(67, 70, 81), 0)));
    indicator.parameters:addInteger("param40", "", "", 1);
    indicator.parameters:addString("param41", "", "", "⎯⎯⎯");
    indicator.parameters:addStringAlternative("param41", "⎯⎯⎯", "", "⎯⎯⎯");
    indicator.parameters:addStringAlternative("param41", "----", "", "----");
    indicator.parameters:addStringAlternative("param41", "····", "", "····");
    indicator.parameters:addBoolean("param42", "link Levels  ", "", true);
    indicator.parameters:addColor("param43", "", "", core.colors().Gray);
    indicator.parameters:addInteger("param44", "      ", "", 1);
    indicator.parameters:addString("param45", "", "", "····");
    indicator.parameters:addStringAlternative("param45", "⎯⎯⎯", "", "⎯⎯⎯");
    indicator.parameters:addStringAlternative("param45", "----", "", "----");
    indicator.parameters:addStringAlternative("param45", "····", "", "····");
    indicator.parameters:addBoolean("param46", "Highlight   ", "", true);
    indicator.parameters:addColor("param47", "", "", Graphics:GetColor(core.colors().Blue + math.floor(90 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param48", "", "", Graphics:GetColor(core.colors().Orange + math.floor(90 / 100 * 255) * 16777216));
    indicator.parameters:addString("param49", "Claimed Style", "", "····");
    indicator.parameters:addStringAlternative("param49", "⎯⎯⎯", "", "⎯⎯⎯");
    indicator.parameters:addStringAlternative("param49", "----", "", "----");
    indicator.parameters:addStringAlternative("param49", "····", "", "····");
    indicator.parameters:addInteger("param50", "Distance Tolerance", "", 2);
    indicator.parameters:addInteger("param51", "Maximum number of Equal Levels", "", 20, 1);
    indicator.parameters:addInteger("param52", "Maximum number of Claimed Levels", "", 5, 1);
    indicator.parameters:addBoolean("param53", "Highlight    ", "", false);
    indicator.parameters:addColor("param54", "", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(186, 227, 197), 0)));
    indicator.parameters:addColor("param55", "", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(255, 194, 194), 0)));
    indicator.parameters:addBoolean("param56", "Require FVG", "", true);
    indicator.parameters:addInteger("param57", "Use last X bars to calculate", "", 100, 1);
    indicator.parameters:addInteger("param58", "Displacement Strength", "", 2);
    indicator.parameters:addBoolean("param59", "FVG    ", "", true);
    indicator.parameters:addColor("param60", "", "", Graphics:GetColor(core.rgb(56, 142, 60) + math.floor(0 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param61", "", "", Graphics:GetColor(core.rgb(24, 72, 204) + math.floor(0 / 100 * 255) * 16777216));
    indicator.parameters:addBoolean("param62", "iFVG    ", "", true);
    indicator.parameters:addColor("param63", "", "", Graphics:GetColor(core.colors().Purple + math.floor(0 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param64", "", "", Graphics:GetColor(core.colors().Orange + math.floor(0 / 100 * 255) * 16777216));
    indicator.parameters:addString("param65", "", "", "Always Display");
    indicator.parameters:addStringAlternative("param65", "Always Display", "", "Always Display");
    indicator.parameters:addStringAlternative("param65", "Same As Displacement", "", "Same As Displacement");
    indicator.parameters:addStringAlternative("param65", "Level 1", "", "Level 1");
    indicator.parameters:addStringAlternative("param65", "Level 2", "", "Level 2");
    indicator.parameters:addStringAlternative("param65", "Level 3", "", "Level 3");
    indicator.parameters:addStringAlternative("param65", "Level 4", "", "Level 4");
    indicator.parameters:addBoolean("param66", "Mitigation", "", true);
    indicator.parameters:addColor("param67", "", "", Graphics:GetColor(core.colors().Gray + math.floor(95 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param68", "", "", Graphics:GetColor(core.colors().Gray + math.floor(95 / 100 * 255) * 16777216));
    indicator.parameters:addString("param69", "", "", "Wick filled");
    indicator.parameters:addStringAlternative("param69", "None", "", "None");
    indicator.parameters:addStringAlternative("param69", "Wick Touched", "", "Wick Touched");
    indicator.parameters:addStringAlternative("param69", "Wick filled", "", "Wick filled");
    indicator.parameters:addStringAlternative("param69", "Body filled", "", "Body filled");
    indicator.parameters:addStringAlternative("param69", "Wick filled half", "", "Wick filled half");
    indicator.parameters:addStringAlternative("param69", "Body filled half", "", "Body filled half");
    indicator.parameters:addBoolean("param70", "Open                ", "", true);
    indicator.parameters:addString("param71", "", "", "····");
    indicator.parameters:addStringAlternative("param71", "⎯⎯⎯", "", "⎯⎯⎯");
    indicator.parameters:addStringAlternative("param71", "----", "", "----");
    indicator.parameters:addStringAlternative("param71", "····", "", "····");
    indicator.parameters:addInteger("param72", "", "", 1);
    indicator.parameters:addBoolean("param73", "Close                ", "", true);
    indicator.parameters:addString("param74", "", "", "····");
    indicator.parameters:addStringAlternative("param74", "⎯⎯⎯", "", "⎯⎯⎯");
    indicator.parameters:addStringAlternative("param74", "----", "", "----");
    indicator.parameters:addStringAlternative("param74", "····", "", "····");
    indicator.parameters:addInteger("param75", "", "", 1);
    indicator.parameters:addBoolean("param76", "C.E.    ", "", true);
    indicator.parameters:addColor("param77", "", "", Graphics:GetColor(core.colors().Black + math.floor(60 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param78", "", "", Graphics:GetColor(core.colors().Black + math.floor(60 / 100 * 255) * 16777216));
    indicator.parameters:addString("param79", "", "", "····");
    indicator.parameters:addStringAlternative("param79", "⎯⎯⎯", "", "⎯⎯⎯");
    indicator.parameters:addStringAlternative("param79", "----", "", "----");
    indicator.parameters:addStringAlternative("param79", "····", "", "····");
    indicator.parameters:addInteger("param80", "", "", 1);
    indicator.parameters:addBoolean("param81", "Link                ", "", true);
    indicator.parameters:addString("param82", " ", "", "⎯⎯⎯");
    indicator.parameters:addStringAlternative("param82", "⎯⎯⎯", "", "⎯⎯⎯");
    indicator.parameters:addStringAlternative("param82", "----", "", "----");
    indicator.parameters:addStringAlternative("param82", "····", "", "····");
    indicator.parameters:addInteger("param83", "", "", 2);
    indicator.parameters:addBoolean("param84", "Background Transparency", "", true);
    indicator.parameters:addInteger("param85", "", "", 95);
    indicator.parameters:addBoolean("param86", "Extend FVGs when overlapping with V.I.", "", false);
    indicator.parameters:addInteger("param87", "Max number of FVGs", "", 20);
    indicator.parameters:addInteger("param88", "Max number of iFVGs", "", 20);
    indicator.parameters:addBoolean("param89", "Volume Imbalance", "", true);
    indicator.parameters:addColor("param90", "", "", core.colors().Red);
    indicator.parameters:addColor("param91", "", "", core.colors().Red);
    indicator.parameters:addBoolean("param92", "Mitigated       ", "", true);
    indicator.parameters:addColor("param93", "", "", Graphics:GetColor(core.colors().Red + math.floor(95 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param94", "", "", Graphics:GetColor(core.colors().Red + math.floor(95 / 100 * 255) * 16777216));
    indicator.parameters:addBoolean("param95", "Background Transparency", "", true);
    indicator.parameters:addInteger("param96", "", "", 70);
    indicator.parameters:addInteger("param97", "Max number of Imbalances", "", 20, 1, 100);
    indicator.parameters:addBoolean("param98", "Open Gaps", "", true);
    indicator.parameters:addColor("param99", "", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(255, 204, 128), 0)));
    indicator.parameters:addColor("param100", "", "", Graphics:GetColor(Graphics:AddTransparency(core.rgb(255, 204, 128), 0)));
    indicator.parameters:addBoolean("param101", "Background Transparency", "", true);
    indicator.parameters:addInteger("param102", "", "", 70);
    indicator.parameters:addInteger("param103", "Max number of Gaps", "", 5);
end

local source;
local plot1_open;
local plot1_high;
local plot1_low;
local plot1_close;
local plot2_open;
local plot2_high;
local plot2_low;
local plot2_close;
function CreateType_Settings(period, liquidity_open_styleValue, liquidity_claimed_styleValue, ST_labelValue, IT_labelValue, LT_labelValue, ST_showValue, ST_text_sizeValue, ST_color_bullValue, ST_color_bearValue, ST_label_colorValue, ST_liquidity_showValue, ST_liquidity_open_colorValue, ST_liquidity_sizeValue, ST_liquidity_claimed_colorValue, IT_showValue, IT_text_sizeValue, IT_color_bullValue, IT_color_bearValue, IT_label_colorValue, IT_liquidity_showValue, IT_liquidity_open_colorValue, IT_liquidity_sizeValue, IT_liquidity_claimed_colorValue, LT_showValue, LT_text_sizeValue, LT_color_bullValue, LT_color_bearValue, LT_label_colorValue, LT_liquidity_showValue, LT_liquidity_open_colorValue, LT_liquidity_sizeValue, LT_liquidity_claimed_colorValue, max_labelsValue, liquidity_open_showValue, max_linesValue, max_claimed_linesValue, extendValue, EQ_showValue, EQ_maxValue, EQ_max_claimedValue, EQ_link_showValue, EQ_link_colorValue, EQ_link_styleValue, EQ_link_sizeValue, EQ_line_extendValue, EQ_color_bullValue, EQ_color_bearValue, EQ_styleValue, EQ_claimed_styleValue, EQ_sizeValue, EQ_shadeValue, EQ_shade_bullValue, EQ_shade_bearValue, EQ_ToleranceValue, displacement_showValue, displacement_fvgValue, displacement_lengthValue, displacement_factorValue, displacement_bullValue, displacement_bearValue)
    return {
        liquidity_open_style = liquidity_open_styleValue,
        liquidity_claimed_style = liquidity_claimed_styleValue,
        ST_label = ST_labelValue,
        IT_label = IT_labelValue,
        LT_label = LT_labelValue,
        ST_show = ST_showValue,
        ST_text_size = ST_text_sizeValue,
        ST_color_bull = ST_color_bullValue,
        ST_color_bear = ST_color_bearValue,
        ST_label_color = ST_label_colorValue,
        ST_liquidity_show = ST_liquidity_showValue,
        ST_liquidity_open_color = ST_liquidity_open_colorValue,
        ST_liquidity_size = ST_liquidity_sizeValue,
        ST_liquidity_claimed_color = ST_liquidity_claimed_colorValue,
        IT_show = IT_showValue,
        IT_text_size = IT_text_sizeValue,
        IT_color_bull = IT_color_bullValue,
        IT_color_bear = IT_color_bearValue,
        IT_label_color = IT_label_colorValue,
        IT_liquidity_show = IT_liquidity_showValue,
        IT_liquidity_open_color = IT_liquidity_open_colorValue,
        IT_liquidity_size = IT_liquidity_sizeValue,
        IT_liquidity_claimed_color = IT_liquidity_claimed_colorValue,
        LT_show = LT_showValue,
        LT_text_size = LT_text_sizeValue,
        LT_color_bull = LT_color_bullValue,
        LT_color_bear = LT_color_bearValue,
        LT_label_color = LT_label_colorValue,
        LT_liquidity_show = LT_liquidity_showValue,
        LT_liquidity_open_color = LT_liquidity_open_colorValue,
        LT_liquidity_size = LT_liquidity_sizeValue,
        LT_liquidity_claimed_color = LT_liquidity_claimed_colorValue,
        max_labels = max_labelsValue,
        liquidity_open_show = liquidity_open_showValue,
        max_lines = max_linesValue,
        max_claimed_lines = max_claimed_linesValue,
        extend = extendValue,
        EQ_show = EQ_showValue,
        EQ_max = EQ_maxValue,
        EQ_max_claimed = EQ_max_claimedValue,
        EQ_link_show = EQ_link_showValue,
        EQ_link_color = EQ_link_colorValue,
        EQ_link_style = EQ_link_styleValue,
        EQ_link_size = EQ_link_sizeValue,
        EQ_line_extend = EQ_line_extendValue,
        EQ_color_bull = EQ_color_bullValue,
        EQ_color_bear = EQ_color_bearValue,
        EQ_style = EQ_styleValue,
        EQ_claimed_style = EQ_claimed_styleValue,
        EQ_size = EQ_sizeValue,
        EQ_shade = EQ_shadeValue,
        EQ_shade_bull = EQ_shade_bullValue,
        EQ_shade_bear = EQ_shade_bearValue,
        EQ_Tolerance = EQ_ToleranceValue,
        displacement_show = displacement_showValue,
        displacement_fvg = displacement_fvgValue,
        displacement_length = displacement_lengthValue,
        displacement_factor = displacement_factorValue,
        displacement_bull = displacement_bullValue,
        displacement_bear = displacement_bearValue,
    };
end
function Settings_Getliquidity_open_style(self)
    if self == nil then return nil; end
    return self.liquidity_open_style;
end
function Settings_Setliquidity_open_style(self, val)
    if self == nil then return nil; end
    self.liquidity_open_style = val;
end
function Settings_Getliquidity_claimed_style(self)
    if self == nil then return nil; end
    return self.liquidity_claimed_style;
end
function Settings_Setliquidity_claimed_style(self, val)
    if self == nil then return nil; end
    self.liquidity_claimed_style = val;
end
function Settings_GetST_label(self)
    if self == nil then return nil; end
    return self.ST_label;
end
function Settings_SetST_label(self, val)
    if self == nil then return nil; end
    self.ST_label = val;
end
function Settings_GetIT_label(self)
    if self == nil then return nil; end
    return self.IT_label;
end
function Settings_SetIT_label(self, val)
    if self == nil then return nil; end
    self.IT_label = val;
end
function Settings_GetLT_label(self)
    if self == nil then return nil; end
    return self.LT_label;
end
function Settings_SetLT_label(self, val)
    if self == nil then return nil; end
    self.LT_label = val;
end
function Settings_GetST_show(self)
    if self == nil then return nil; end
    return self.ST_show;
end
function Settings_SetST_show(self, val)
    if self == nil then return nil; end
    self.ST_show = val;
end
function Settings_GetST_text_size(self)
    if self == nil then return nil; end
    return self.ST_text_size;
end
function Settings_SetST_text_size(self, val)
    if self == nil then return nil; end
    self.ST_text_size = val;
end
function Settings_GetST_color_bull(self)
    if self == nil then return nil; end
    return self.ST_color_bull;
end
function Settings_SetST_color_bull(self, val)
    if self == nil then return nil; end
    self.ST_color_bull = val;
end
function Settings_GetST_color_bear(self)
    if self == nil then return nil; end
    return self.ST_color_bear;
end
function Settings_SetST_color_bear(self, val)
    if self == nil then return nil; end
    self.ST_color_bear = val;
end
function Settings_GetST_label_color(self)
    if self == nil then return nil; end
    return self.ST_label_color;
end
function Settings_SetST_label_color(self, val)
    if self == nil then return nil; end
    self.ST_label_color = val;
end
function Settings_GetST_liquidity_show(self)
    if self == nil then return nil; end
    return self.ST_liquidity_show;
end
function Settings_SetST_liquidity_show(self, val)
    if self == nil then return nil; end
    self.ST_liquidity_show = val;
end
function Settings_GetST_liquidity_open_color(self)
    if self == nil then return nil; end
    return self.ST_liquidity_open_color;
end
function Settings_SetST_liquidity_open_color(self, val)
    if self == nil then return nil; end
    self.ST_liquidity_open_color = val;
end
function Settings_GetST_liquidity_size(self)
    if self == nil then return nil; end
    return self.ST_liquidity_size;
end
function Settings_SetST_liquidity_size(self, val)
    if self == nil then return nil; end
    self.ST_liquidity_size = val;
end
function Settings_GetST_liquidity_claimed_color(self)
    if self == nil then return nil; end
    return self.ST_liquidity_claimed_color;
end
function Settings_SetST_liquidity_claimed_color(self, val)
    if self == nil then return nil; end
    self.ST_liquidity_claimed_color = val;
end
function Settings_GetIT_show(self)
    if self == nil then return nil; end
    return self.IT_show;
end
function Settings_SetIT_show(self, val)
    if self == nil then return nil; end
    self.IT_show = val;
end
function Settings_GetIT_text_size(self)
    if self == nil then return nil; end
    return self.IT_text_size;
end
function Settings_SetIT_text_size(self, val)
    if self == nil then return nil; end
    self.IT_text_size = val;
end
function Settings_GetIT_color_bull(self)
    if self == nil then return nil; end
    return self.IT_color_bull;
end
function Settings_SetIT_color_bull(self, val)
    if self == nil then return nil; end
    self.IT_color_bull = val;
end
function Settings_GetIT_color_bear(self)
    if self == nil then return nil; end
    return self.IT_color_bear;
end
function Settings_SetIT_color_bear(self, val)
    if self == nil then return nil; end
    self.IT_color_bear = val;
end
function Settings_GetIT_label_color(self)
    if self == nil then return nil; end
    return self.IT_label_color;
end
function Settings_SetIT_label_color(self, val)
    if self == nil then return nil; end
    self.IT_label_color = val;
end
function Settings_GetIT_liquidity_show(self)
    if self == nil then return nil; end
    return self.IT_liquidity_show;
end
function Settings_SetIT_liquidity_show(self, val)
    if self == nil then return nil; end
    self.IT_liquidity_show = val;
end
function Settings_GetIT_liquidity_open_color(self)
    if self == nil then return nil; end
    return self.IT_liquidity_open_color;
end
function Settings_SetIT_liquidity_open_color(self, val)
    if self == nil then return nil; end
    self.IT_liquidity_open_color = val;
end
function Settings_GetIT_liquidity_size(self)
    if self == nil then return nil; end
    return self.IT_liquidity_size;
end
function Settings_SetIT_liquidity_size(self, val)
    if self == nil then return nil; end
    self.IT_liquidity_size = val;
end
function Settings_GetIT_liquidity_claimed_color(self)
    if self == nil then return nil; end
    return self.IT_liquidity_claimed_color;
end
function Settings_SetIT_liquidity_claimed_color(self, val)
    if self == nil then return nil; end
    self.IT_liquidity_claimed_color = val;
end
function Settings_GetLT_show(self)
    if self == nil then return nil; end
    return self.LT_show;
end
function Settings_SetLT_show(self, val)
    if self == nil then return nil; end
    self.LT_show = val;
end
function Settings_GetLT_text_size(self)
    if self == nil then return nil; end
    return self.LT_text_size;
end
function Settings_SetLT_text_size(self, val)
    if self == nil then return nil; end
    self.LT_text_size = val;
end
function Settings_GetLT_color_bull(self)
    if self == nil then return nil; end
    return self.LT_color_bull;
end
function Settings_SetLT_color_bull(self, val)
    if self == nil then return nil; end
    self.LT_color_bull = val;
end
function Settings_GetLT_color_bear(self)
    if self == nil then return nil; end
    return self.LT_color_bear;
end
function Settings_SetLT_color_bear(self, val)
    if self == nil then return nil; end
    self.LT_color_bear = val;
end
function Settings_GetLT_label_color(self)
    if self == nil then return nil; end
    return self.LT_label_color;
end
function Settings_SetLT_label_color(self, val)
    if self == nil then return nil; end
    self.LT_label_color = val;
end
function Settings_GetLT_liquidity_show(self)
    if self == nil then return nil; end
    return self.LT_liquidity_show;
end
function Settings_SetLT_liquidity_show(self, val)
    if self == nil then return nil; end
    self.LT_liquidity_show = val;
end
function Settings_GetLT_liquidity_open_color(self)
    if self == nil then return nil; end
    return self.LT_liquidity_open_color;
end
function Settings_SetLT_liquidity_open_color(self, val)
    if self == nil then return nil; end
    self.LT_liquidity_open_color = val;
end
function Settings_GetLT_liquidity_size(self)
    if self == nil then return nil; end
    return self.LT_liquidity_size;
end
function Settings_SetLT_liquidity_size(self, val)
    if self == nil then return nil; end
    self.LT_liquidity_size = val;
end
function Settings_GetLT_liquidity_claimed_color(self)
    if self == nil then return nil; end
    return self.LT_liquidity_claimed_color;
end
function Settings_SetLT_liquidity_claimed_color(self, val)
    if self == nil then return nil; end
    self.LT_liquidity_claimed_color = val;
end
function Settings_Getmax_labels(self)
    if self == nil then return nil; end
    return self.max_labels;
end
function Settings_Setmax_labels(self, val)
    if self == nil then return nil; end
    self.max_labels = val;
end
function Settings_Getliquidity_open_show(self)
    if self == nil then return nil; end
    return self.liquidity_open_show;
end
function Settings_Setliquidity_open_show(self, val)
    if self == nil then return nil; end
    self.liquidity_open_show = val;
end
function Settings_Getmax_lines(self)
    if self == nil then return nil; end
    return self.max_lines;
end
function Settings_Setmax_lines(self, val)
    if self == nil then return nil; end
    self.max_lines = val;
end
function Settings_Getmax_claimed_lines(self)
    if self == nil then return nil; end
    return self.max_claimed_lines;
end
function Settings_Setmax_claimed_lines(self, val)
    if self == nil then return nil; end
    self.max_claimed_lines = val;
end
function Settings_Getextend(self)
    if self == nil then return nil; end
    return self.extend;
end
function Settings_Setextend(self, val)
    if self == nil then return nil; end
    self.extend = val;
end
function Settings_GetEQ_show(self)
    if self == nil then return nil; end
    return self.EQ_show;
end
function Settings_SetEQ_show(self, val)
    if self == nil then return nil; end
    self.EQ_show = val;
end
function Settings_GetEQ_max(self)
    if self == nil then return nil; end
    return self.EQ_max;
end
function Settings_SetEQ_max(self, val)
    if self == nil then return nil; end
    self.EQ_max = val;
end
function Settings_GetEQ_max_claimed(self)
    if self == nil then return nil; end
    return self.EQ_max_claimed;
end
function Settings_SetEQ_max_claimed(self, val)
    if self == nil then return nil; end
    self.EQ_max_claimed = val;
end
function Settings_GetEQ_link_show(self)
    if self == nil then return nil; end
    return self.EQ_link_show;
end
function Settings_SetEQ_link_show(self, val)
    if self == nil then return nil; end
    self.EQ_link_show = val;
end
function Settings_GetEQ_link_color(self)
    if self == nil then return nil; end
    return self.EQ_link_color;
end
function Settings_SetEQ_link_color(self, val)
    if self == nil then return nil; end
    self.EQ_link_color = val;
end
function Settings_GetEQ_link_style(self)
    if self == nil then return nil; end
    return self.EQ_link_style;
end
function Settings_SetEQ_link_style(self, val)
    if self == nil then return nil; end
    self.EQ_link_style = val;
end
function Settings_GetEQ_link_size(self)
    if self == nil then return nil; end
    return self.EQ_link_size;
end
function Settings_SetEQ_link_size(self, val)
    if self == nil then return nil; end
    self.EQ_link_size = val;
end
function Settings_GetEQ_line_extend(self)
    if self == nil then return nil; end
    return self.EQ_line_extend;
end
function Settings_SetEQ_line_extend(self, val)
    if self == nil then return nil; end
    self.EQ_line_extend = val;
end
function Settings_GetEQ_color_bull(self)
    if self == nil then return nil; end
    return self.EQ_color_bull;
end
function Settings_SetEQ_color_bull(self, val)
    if self == nil then return nil; end
    self.EQ_color_bull = val;
end
function Settings_GetEQ_color_bear(self)
    if self == nil then return nil; end
    return self.EQ_color_bear;
end
function Settings_SetEQ_color_bear(self, val)
    if self == nil then return nil; end
    self.EQ_color_bear = val;
end
function Settings_GetEQ_style(self)
    if self == nil then return nil; end
    return self.EQ_style;
end
function Settings_SetEQ_style(self, val)
    if self == nil then return nil; end
    self.EQ_style = val;
end
function Settings_GetEQ_claimed_style(self)
    if self == nil then return nil; end
    return self.EQ_claimed_style;
end
function Settings_SetEQ_claimed_style(self, val)
    if self == nil then return nil; end
    self.EQ_claimed_style = val;
end
function Settings_GetEQ_size(self)
    if self == nil then return nil; end
    return self.EQ_size;
end
function Settings_SetEQ_size(self, val)
    if self == nil then return nil; end
    self.EQ_size = val;
end
function Settings_GetEQ_shade(self)
    if self == nil then return nil; end
    return self.EQ_shade;
end
function Settings_SetEQ_shade(self, val)
    if self == nil then return nil; end
    self.EQ_shade = val;
end
function Settings_GetEQ_shade_bull(self)
    if self == nil then return nil; end
    return self.EQ_shade_bull;
end
function Settings_SetEQ_shade_bull(self, val)
    if self == nil then return nil; end
    self.EQ_shade_bull = val;
end
function Settings_GetEQ_shade_bear(self)
    if self == nil then return nil; end
    return self.EQ_shade_bear;
end
function Settings_SetEQ_shade_bear(self, val)
    if self == nil then return nil; end
    self.EQ_shade_bear = val;
end
function Settings_GetEQ_Tolerance(self)
    if self == nil then return nil; end
    return self.EQ_Tolerance;
end
function Settings_SetEQ_Tolerance(self, val)
    if self == nil then return nil; end
    self.EQ_Tolerance = val;
end
function Settings_Getdisplacement_show(self)
    if self == nil then return nil; end
    return self.displacement_show;
end
function Settings_Setdisplacement_show(self, val)
    if self == nil then return nil; end
    self.displacement_show = val;
end
function Settings_Getdisplacement_fvg(self)
    if self == nil then return nil; end
    return self.displacement_fvg;
end
function Settings_Setdisplacement_fvg(self, val)
    if self == nil then return nil; end
    self.displacement_fvg = val;
end
function Settings_Getdisplacement_length(self)
    if self == nil then return nil; end
    return self.displacement_length;
end
function Settings_Setdisplacement_length(self, val)
    if self == nil then return nil; end
    self.displacement_length = val;
end
function Settings_Getdisplacement_factor(self)
    if self == nil then return nil; end
    return self.displacement_factor;
end
function Settings_Setdisplacement_factor(self, val)
    if self == nil then return nil; end
    self.displacement_factor = val;
end
function Settings_Getdisplacement_bull(self)
    if self == nil then return nil; end
    return self.displacement_bull;
end
function Settings_Setdisplacement_bull(self, val)
    if self == nil then return nil; end
    self.displacement_bull = val;
end
function Settings_Getdisplacement_bear(self)
    if self == nil then return nil; end
    return self.displacement_bear;
end
function Settings_Setdisplacement_bear(self, val)
    if self == nil then return nil; end
    self.displacement_bear = val;
end
function CreateType_Imbalance_Settings(period, showValue, color_bullValue, color_bearValue, fvg_typeValue, mitigated_showValue, mitigated_typeValue, mitigated_color_bullValue, mitigated_color_bearValue, mergeVIValue, styleValue, open_showValue, open_styleValue, open_sizeValue, close_showValue, close_styleValue, close_sizeValue, fillValue, fill_percentValue, CE_showValue, CE_styleValue, CE_sizeValue, CE_bull_colorValue, CE_bear_colorValue, link_showValue, link_styleValue, link_sizeValue, max_countValue, max_mitigated_countValue)
    return {
        show = showValue,
        color_bull = color_bullValue,
        color_bear = color_bearValue,
        fvg_type = fvg_typeValue,
        mitigated_show = mitigated_showValue,
        mitigated_type = mitigated_typeValue,
        mitigated_color_bull = mitigated_color_bullValue,
        mitigated_color_bear = mitigated_color_bearValue,
        mergeVI = mergeVIValue,
        style = styleValue,
        open_show = open_showValue,
        open_style = open_styleValue,
        open_size = open_sizeValue,
        close_show = close_showValue,
        close_style = close_styleValue,
        close_size = close_sizeValue,
        fill = fillValue,
        fill_percent = fill_percentValue,
        CE_show = CE_showValue,
        CE_style = CE_styleValue,
        CE_size = CE_sizeValue,
        CE_bull_color = CE_bull_colorValue,
        CE_bear_color = CE_bear_colorValue,
        link_show = link_showValue,
        link_style = link_styleValue,
        link_size = link_sizeValue,
        max_count = max_countValue,
        max_mitigated_count = max_mitigated_countValue,
    };
end
function Imbalance_Settings_Getshow(self)
    if self == nil then return nil; end
    return self.show;
end
function Imbalance_Settings_Setshow(self, val)
    if self == nil then return nil; end
    self.show = val;
end
function Imbalance_Settings_Getcolor_bull(self)
    if self == nil then return nil; end
    return self.color_bull;
end
function Imbalance_Settings_Setcolor_bull(self, val)
    if self == nil then return nil; end
    self.color_bull = val;
end
function Imbalance_Settings_Getcolor_bear(self)
    if self == nil then return nil; end
    return self.color_bear;
end
function Imbalance_Settings_Setcolor_bear(self, val)
    if self == nil then return nil; end
    self.color_bear = val;
end
function Imbalance_Settings_Getfvg_type(self)
    if self == nil then return nil; end
    return self.fvg_type;
end
function Imbalance_Settings_Setfvg_type(self, val)
    if self == nil then return nil; end
    self.fvg_type = val;
end
function Imbalance_Settings_Getmitigated_show(self)
    if self == nil then return nil; end
    return self.mitigated_show;
end
function Imbalance_Settings_Setmitigated_show(self, val)
    if self == nil then return nil; end
    self.mitigated_show = val;
end
function Imbalance_Settings_Getmitigated_type(self)
    if self == nil then return nil; end
    return self.mitigated_type;
end
function Imbalance_Settings_Setmitigated_type(self, val)
    if self == nil then return nil; end
    self.mitigated_type = val;
end
function Imbalance_Settings_Getmitigated_color_bull(self)
    if self == nil then return nil; end
    return self.mitigated_color_bull;
end
function Imbalance_Settings_Setmitigated_color_bull(self, val)
    if self == nil then return nil; end
    self.mitigated_color_bull = val;
end
function Imbalance_Settings_Getmitigated_color_bear(self)
    if self == nil then return nil; end
    return self.mitigated_color_bear;
end
function Imbalance_Settings_Setmitigated_color_bear(self, val)
    if self == nil then return nil; end
    self.mitigated_color_bear = val;
end
function Imbalance_Settings_GetmergeVI(self)
    if self == nil then return nil; end
    return self.mergeVI;
end
function Imbalance_Settings_SetmergeVI(self, val)
    if self == nil then return nil; end
    self.mergeVI = val;
end
function Imbalance_Settings_Getstyle(self)
    if self == nil then return nil; end
    return self.style;
end
function Imbalance_Settings_Setstyle(self, val)
    if self == nil then return nil; end
    self.style = val;
end
function Imbalance_Settings_Getopen_show(self)
    if self == nil then return nil; end
    return self.open_show;
end
function Imbalance_Settings_Setopen_show(self, val)
    if self == nil then return nil; end
    self.open_show = val;
end
function Imbalance_Settings_Getopen_style(self)
    if self == nil then return nil; end
    return self.open_style;
end
function Imbalance_Settings_Setopen_style(self, val)
    if self == nil then return nil; end
    self.open_style = val;
end
function Imbalance_Settings_Getopen_size(self)
    if self == nil then return nil; end
    return self.open_size;
end
function Imbalance_Settings_Setopen_size(self, val)
    if self == nil then return nil; end
    self.open_size = val;
end
function Imbalance_Settings_Getclose_show(self)
    if self == nil then return nil; end
    return self.close_show;
end
function Imbalance_Settings_Setclose_show(self, val)
    if self == nil then return nil; end
    self.close_show = val;
end
function Imbalance_Settings_Getclose_style(self)
    if self == nil then return nil; end
    return self.close_style;
end
function Imbalance_Settings_Setclose_style(self, val)
    if self == nil then return nil; end
    self.close_style = val;
end
function Imbalance_Settings_Getclose_size(self)
    if self == nil then return nil; end
    return self.close_size;
end
function Imbalance_Settings_Setclose_size(self, val)
    if self == nil then return nil; end
    self.close_size = val;
end
function Imbalance_Settings_Getfill(self)
    if self == nil then return nil; end
    return self.fill;
end
function Imbalance_Settings_Setfill(self, val)
    if self == nil then return nil; end
    self.fill = val;
end
function Imbalance_Settings_Getfill_percent(self)
    if self == nil then return nil; end
    return self.fill_percent;
end
function Imbalance_Settings_Setfill_percent(self, val)
    if self == nil then return nil; end
    self.fill_percent = val;
end
function Imbalance_Settings_GetCE_show(self)
    if self == nil then return nil; end
    return self.CE_show;
end
function Imbalance_Settings_SetCE_show(self, val)
    if self == nil then return nil; end
    self.CE_show = val;
end
function Imbalance_Settings_GetCE_style(self)
    if self == nil then return nil; end
    return self.CE_style;
end
function Imbalance_Settings_SetCE_style(self, val)
    if self == nil then return nil; end
    self.CE_style = val;
end
function Imbalance_Settings_GetCE_size(self)
    if self == nil then return nil; end
    return self.CE_size;
end
function Imbalance_Settings_SetCE_size(self, val)
    if self == nil then return nil; end
    self.CE_size = val;
end
function Imbalance_Settings_GetCE_bull_color(self)
    if self == nil then return nil; end
    return self.CE_bull_color;
end
function Imbalance_Settings_SetCE_bull_color(self, val)
    if self == nil then return nil; end
    self.CE_bull_color = val;
end
function Imbalance_Settings_GetCE_bear_color(self)
    if self == nil then return nil; end
    return self.CE_bear_color;
end
function Imbalance_Settings_SetCE_bear_color(self, val)
    if self == nil then return nil; end
    self.CE_bear_color = val;
end
function Imbalance_Settings_Getlink_show(self)
    if self == nil then return nil; end
    return self.link_show;
end
function Imbalance_Settings_Setlink_show(self, val)
    if self == nil then return nil; end
    self.link_show = val;
end
function Imbalance_Settings_Getlink_style(self)
    if self == nil then return nil; end
    return self.link_style;
end
function Imbalance_Settings_Setlink_style(self, val)
    if self == nil then return nil; end
    self.link_style = val;
end
function Imbalance_Settings_Getlink_size(self)
    if self == nil then return nil; end
    return self.link_size;
end
function Imbalance_Settings_Setlink_size(self, val)
    if self == nil then return nil; end
    self.link_size = val;
end
function Imbalance_Settings_Getmax_count(self)
    if self == nil then return nil; end
    return self.max_count;
end
function Imbalance_Settings_Setmax_count(self, val)
    if self == nil then return nil; end
    self.max_count = val;
end
function Imbalance_Settings_Getmax_mitigated_count(self)
    if self == nil then return nil; end
    return self.max_mitigated_count;
end
function Imbalance_Settings_Setmax_mitigated_count(self, val)
    if self == nil then return nil; end
    self.max_mitigated_count = val;
end
function CreateType_Pivot(period, indexValue, timeValue, priceValue, time_lastValue, claimedValue, isHighValue, isLowValue, isSHigherHighValue, isSLowerLowValue, isIHigherHighValue, isILowerLowValue, isLHigherHighValue, isLLowerLowValue, isSTValue, isITValue, isLTValue, lblValue, lnValue)
    return {
        index = indexValue or (0),
        time = timeValue or (0),
        price = priceValue or (0),
        time_last = time_lastValue or (0),
        claimed = claimedValue or (false),
        isHigh = isHighValue or (false),
        isLow = isLowValue or (false),
        isSHigherHigh = isSHigherHighValue or (false),
        isSLowerLow = isSLowerLowValue or (false),
        isIHigherHigh = isIHigherHighValue or (false),
        isILowerLow = isILowerLowValue or (false),
        isLHigherHigh = isLHigherHighValue or (false),
        isLLowerLow = isLLowerLowValue or (false),
        isST = isSTValue or (true),
        isIT = isITValue or (false),
        isLT = isLTValue or (false),
        lbl = lblValue or (nil),
        ln = lnValue or (nil),
    };
end
function Pivot_Getindex(self)
    if self == nil then return nil; end
    return self.index;
end
function Pivot_Setindex(self, val)
    if self == nil then return nil; end
    self.index = val;
end
function Pivot_Gettime(self)
    if self == nil then return nil; end
    return self.time;
end
function Pivot_Settime(self, val)
    if self == nil then return nil; end
    self.time = val;
end
function Pivot_Getprice(self)
    if self == nil then return nil; end
    return self.price;
end
function Pivot_Setprice(self, val)
    if self == nil then return nil; end
    self.price = val;
end
function Pivot_Gettime_last(self)
    if self == nil then return nil; end
    return self.time_last;
end
function Pivot_Settime_last(self, val)
    if self == nil then return nil; end
    self.time_last = val;
end
function Pivot_Getclaimed(self)
    if self == nil then return nil; end
    return self.claimed;
end
function Pivot_Setclaimed(self, val)
    if self == nil then return nil; end
    self.claimed = val;
end
function Pivot_GetisHigh(self)
    if self == nil then return nil; end
    return self.isHigh;
end
function Pivot_SetisHigh(self, val)
    if self == nil then return nil; end
    self.isHigh = val;
end
function Pivot_GetisLow(self)
    if self == nil then return nil; end
    return self.isLow;
end
function Pivot_SetisLow(self, val)
    if self == nil then return nil; end
    self.isLow = val;
end
function Pivot_GetisSHigherHigh(self)
    if self == nil then return nil; end
    return self.isSHigherHigh;
end
function Pivot_SetisSHigherHigh(self, val)
    if self == nil then return nil; end
    self.isSHigherHigh = val;
end
function Pivot_GetisSLowerLow(self)
    if self == nil then return nil; end
    return self.isSLowerLow;
end
function Pivot_SetisSLowerLow(self, val)
    if self == nil then return nil; end
    self.isSLowerLow = val;
end
function Pivot_GetisIHigherHigh(self)
    if self == nil then return nil; end
    return self.isIHigherHigh;
end
function Pivot_SetisIHigherHigh(self, val)
    if self == nil then return nil; end
    self.isIHigherHigh = val;
end
function Pivot_GetisILowerLow(self)
    if self == nil then return nil; end
    return self.isILowerLow;
end
function Pivot_SetisILowerLow(self, val)
    if self == nil then return nil; end
    self.isILowerLow = val;
end
function Pivot_GetisLHigherHigh(self)
    if self == nil then return nil; end
    return self.isLHigherHigh;
end
function Pivot_SetisLHigherHigh(self, val)
    if self == nil then return nil; end
    self.isLHigherHigh = val;
end
function Pivot_GetisLLowerLow(self)
    if self == nil then return nil; end
    return self.isLLowerLow;
end
function Pivot_SetisLLowerLow(self, val)
    if self == nil then return nil; end
    self.isLLowerLow = val;
end
function Pivot_GetisST(self)
    if self == nil then return nil; end
    return self.isST;
end
function Pivot_SetisST(self, val)
    if self == nil then return nil; end
    self.isST = val;
end
function Pivot_GetisIT(self)
    if self == nil then return nil; end
    return self.isIT;
end
function Pivot_SetisIT(self, val)
    if self == nil then return nil; end
    self.isIT = val;
end
function Pivot_GetisLT(self)
    if self == nil then return nil; end
    return self.isLT;
end
function Pivot_SetisLT(self, val)
    if self == nil then return nil; end
    self.isLT = val;
end
function Pivot_Getlbl(self)
    if self == nil then return nil; end
    return self.lbl;
end
function Pivot_Setlbl(self, val)
    if self == nil then return nil; end
    self.lbl = val;
end
function Pivot_Getln(self)
    if self == nil then return nil; end
    return self.ln;
end
function Pivot_Setln(self, val)
    if self == nil then return nil; end
    self.ln = val;
end
function CreateType_MarketStructure(period, nameValue, STValue, STHValue, ITHValue, LTHValue, STLValue, ITLValue, LTLValue, settingsValue)
    return {
        name = nameValue,
        ST = STValue,
        STH = STHValue,
        ITH = ITHValue,
        LTH = LTHValue,
        STL = STLValue,
        ITL = ITLValue,
        LTL = LTLValue,
        settings = settingsValue,
    };
end
function MarketStructure_Getname(self)
    if self == nil then return nil; end
    return self.name;
end
function MarketStructure_Setname(self, val)
    if self == nil then return nil; end
    self.name = val;
end
function MarketStructure_GetST(self)
    if self == nil then return nil; end
    return self.ST;
end
function MarketStructure_SetST(self, val)
    if self == nil then return nil; end
    self.ST = val;
end
function MarketStructure_GetSTH(self)
    if self == nil then return nil; end
    return self.STH;
end
function MarketStructure_SetSTH(self, val)
    if self == nil then return nil; end
    self.STH = val;
end
function MarketStructure_GetITH(self)
    if self == nil then return nil; end
    return self.ITH;
end
function MarketStructure_SetITH(self, val)
    if self == nil then return nil; end
    self.ITH = val;
end
function MarketStructure_GetLTH(self)
    if self == nil then return nil; end
    return self.LTH;
end
function MarketStructure_SetLTH(self, val)
    if self == nil then return nil; end
    self.LTH = val;
end
function MarketStructure_GetSTL(self)
    if self == nil then return nil; end
    return self.STL;
end
function MarketStructure_SetSTL(self, val)
    if self == nil then return nil; end
    self.STL = val;
end
function MarketStructure_GetITL(self)
    if self == nil then return nil; end
    return self.ITL;
end
function MarketStructure_SetITL(self, val)
    if self == nil then return nil; end
    self.ITL = val;
end
function MarketStructure_GetLTL(self)
    if self == nil then return nil; end
    return self.LTL;
end
function MarketStructure_SetLTL(self, val)
    if self == nil then return nil; end
    self.LTL = val;
end
function MarketStructure_Getsettings(self)
    if self == nil then return nil; end
    return self.settings;
end
function MarketStructure_Setsettings(self, val)
    if self == nil then return nil; end
    self.settings = val;
end
function CreateType_Box(period, openValue, closeValue, ceValue, linkValue, fillValue, label_openValue, label_closeValue, label_ceValue)
    return {
        open = openValue,
        close = closeValue,
        ce = ceValue,
        link = linkValue,
        fill = fillValue,
        label_open = label_openValue,
        label_close = label_closeValue,
        label_ce = label_ceValue,
    };
end
function Box_Getopen(self)
    if self == nil then return nil; end
    return self.open;
end
function Box_Setopen(self, val)
    if self == nil then return nil; end
    self.open = val;
end
function Box_Getclose(self)
    if self == nil then return nil; end
    return self.close;
end
function Box_Setclose(self, val)
    if self == nil then return nil; end
    self.close = val;
end
function Box_Getce(self)
    if self == nil then return nil; end
    return self.ce;
end
function Box_Setce(self, val)
    if self == nil then return nil; end
    self.ce = val;
end
function Box_Getlink(self)
    if self == nil then return nil; end
    return self.link;
end
function Box_Setlink(self, val)
    if self == nil then return nil; end
    self.link = val;
end
function Box_Getfill(self)
    if self == nil then return nil; end
    return self.fill;
end
function Box_Setfill(self, val)
    if self == nil then return nil; end
    self.fill = val;
end
function Box_Getlabel_open(self)
    if self == nil then return nil; end
    return self.label_open;
end
function Box_Setlabel_open(self, val)
    if self == nil then return nil; end
    self.label_open = val;
end
function Box_Getlabel_close(self)
    if self == nil then return nil; end
    return self.label_close;
end
function Box_Setlabel_close(self, val)
    if self == nil then return nil; end
    self.label_close = val;
end
function Box_Getlabel_ce(self)
    if self == nil then return nil; end
    return self.label_ce;
end
function Box_Setlabel_ce(self, val)
    if self == nil then return nil; end
    self.label_ce = val;
end
function CreateType_Imbalance(period, open_timeValue, close_timeValue, openValue, middleValue, closeValue, mitigatedValue, mitigated_timeValue, invertableValue, invertedValue, inverted_mitigatedValue, inverted_mitigated_timeValue, isbullishValue, boxValue)
    return {
        open_time = open_timeValue,
        close_time = close_timeValue,
        open = openValue,
        middle = middleValue,
        close = closeValue,
        mitigated = mitigatedValue,
        mitigated_time = mitigated_timeValue,
        invertable = invertableValue,
        inverted = invertedValue,
        inverted_mitigated = inverted_mitigatedValue,
        inverted_mitigated_time = inverted_mitigated_timeValue,
        isbullish = isbullishValue,
        box = boxValue,
    };
end
function Imbalance_Getopen_time(self)
    if self == nil then return nil; end
    return self.open_time;
end
function Imbalance_Setopen_time(self, val)
    if self == nil then return nil; end
    self.open_time = val;
end
function Imbalance_Getclose_time(self)
    if self == nil then return nil; end
    return self.close_time;
end
function Imbalance_Setclose_time(self, val)
    if self == nil then return nil; end
    self.close_time = val;
end
function Imbalance_Getopen(self)
    if self == nil then return nil; end
    return self.open;
end
function Imbalance_Setopen(self, val)
    if self == nil then return nil; end
    self.open = val;
end
function Imbalance_Getmiddle(self)
    if self == nil then return nil; end
    return self.middle;
end
function Imbalance_Setmiddle(self, val)
    if self == nil then return nil; end
    self.middle = val;
end
function Imbalance_Getclose(self)
    if self == nil then return nil; end
    return self.close;
end
function Imbalance_Setclose(self, val)
    if self == nil then return nil; end
    self.close = val;
end
function Imbalance_Getmitigated(self)
    if self == nil then return nil; end
    return self.mitigated;
end
function Imbalance_Setmitigated(self, val)
    if self == nil then return nil; end
    self.mitigated = val;
end
function Imbalance_Getmitigated_time(self)
    if self == nil then return nil; end
    return self.mitigated_time;
end
function Imbalance_Setmitigated_time(self, val)
    if self == nil then return nil; end
    self.mitigated_time = val;
end
function Imbalance_Getinvertable(self)
    if self == nil then return nil; end
    return self.invertable;
end
function Imbalance_Setinvertable(self, val)
    if self == nil then return nil; end
    self.invertable = val;
end
function Imbalance_Getinverted(self)
    if self == nil then return nil; end
    return self.inverted;
end
function Imbalance_Setinverted(self, val)
    if self == nil then return nil; end
    self.inverted = val;
end
function Imbalance_Getinverted_mitigated(self)
    if self == nil then return nil; end
    return self.inverted_mitigated;
end
function Imbalance_Setinverted_mitigated(self, val)
    if self == nil then return nil; end
    self.inverted_mitigated = val;
end
function Imbalance_Getinverted_mitigated_time(self)
    if self == nil then return nil; end
    return self.inverted_mitigated_time;
end
function Imbalance_Setinverted_mitigated_time(self, val)
    if self == nil then return nil; end
    self.inverted_mitigated_time = val;
end
function Imbalance_Getisbullish(self)
    if self == nil then return nil; end
    return self.isbullish;
end
function Imbalance_Setisbullish(self, val)
    if self == nil then return nil; end
    self.isbullish = val;
end
function Imbalance_Getbox(self)
    if self == nil then return nil; end
    return self.box;
end
function Imbalance_Setbox(self, val)
    if self == nil then return nil; end
    self.box = val;
end
function CreateType_ImbalanceStructure(period, typeValue, imbalanceValue, settingsValue)
    return {
        type = typeValue,
        imbalance = imbalanceValue,
        settings = settingsValue,
    };
end
function ImbalanceStructure_Gettype(self)
    if self == nil then return nil; end
    return self.type;
end
function ImbalanceStructure_Settype(self, val)
    if self == nil then return nil; end
    self.type = val;
end
function ImbalanceStructure_Getimbalance(self)
    if self == nil then return nil; end
    return self.imbalance;
end
function ImbalanceStructure_Setimbalance(self, val)
    if self == nil then return nil; end
    self.imbalance = val;
end
function ImbalanceStructure_Getsettings(self)
    if self == nil then return nil; end
    return self.settings;
end
function ImbalanceStructure_Setsettings(self, val)
    if self == nil then return nil; end
    self.settings = val;
end
function CreateType_EqualLevels(period, priceValue, startValue, endValue, start_timeValue, end_timeValue, start_indexValue, end_indexValue, isHighValue, isLowValue, isClaimedValue, claimed_timeValue, line_eqValue, line_linkValue, box_linkValue)
    return {
        price = priceValue,
        start = startValue,
        __end = endValue,
        start_time = start_timeValue,
        end_time = end_timeValue,
        start_index = start_indexValue,
        end_index = end_indexValue,
        isHigh = isHighValue,
        isLow = isLowValue,
        isClaimed = isClaimedValue,
        claimed_time = claimed_timeValue,
        line_eq = line_eqValue,
        line_link = line_linkValue,
        box_link = box_linkValue,
    };
end
function EqualLevels_Getprice(self)
    if self == nil then return nil; end
    return self.price;
end
function EqualLevels_Setprice(self, val)
    if self == nil then return nil; end
    self.price = val;
end
function EqualLevels_Getstart(self)
    if self == nil then return nil; end
    return self.start;
end
function EqualLevels_Setstart(self, val)
    if self == nil then return nil; end
    self.start = val;
end
function EqualLevels_Getend(self)
    if self == nil then return nil; end
    return self.__end;
end
function EqualLevels_Setend(self, val)
    if self == nil then return nil; end
    self.__end = val;
end
function EqualLevels_Getstart_time(self)
    if self == nil then return nil; end
    return self.start_time;
end
function EqualLevels_Setstart_time(self, val)
    if self == nil then return nil; end
    self.start_time = val;
end
function EqualLevels_Getend_time(self)
    if self == nil then return nil; end
    return self.end_time;
end
function EqualLevels_Setend_time(self, val)
    if self == nil then return nil; end
    self.end_time = val;
end
function EqualLevels_Getstart_index(self)
    if self == nil then return nil; end
    return self.start_index;
end
function EqualLevels_Setstart_index(self, val)
    if self == nil then return nil; end
    self.start_index = val;
end
function EqualLevels_Getend_index(self)
    if self == nil then return nil; end
    return self.end_index;
end
function EqualLevels_Setend_index(self, val)
    if self == nil then return nil; end
    self.end_index = val;
end
function EqualLevels_GetisHigh(self)
    if self == nil then return nil; end
    return self.isHigh;
end
function EqualLevels_SetisHigh(self, val)
    if self == nil then return nil; end
    self.isHigh = val;
end
function EqualLevels_GetisLow(self)
    if self == nil then return nil; end
    return self.isLow;
end
function EqualLevels_SetisLow(self, val)
    if self == nil then return nil; end
    self.isLow = val;
end
function EqualLevels_GetisClaimed(self)
    if self == nil then return nil; end
    return self.isClaimed;
end
function EqualLevels_SetisClaimed(self, val)
    if self == nil then return nil; end
    self.isClaimed = val;
end
function EqualLevels_Getclaimed_time(self)
    if self == nil then return nil; end
    return self.claimed_time;
end
function EqualLevels_Setclaimed_time(self, val)
    if self == nil then return nil; end
    self.claimed_time = val;
end
function EqualLevels_Getline_eq(self)
    if self == nil then return nil; end
    return self.line_eq;
end
function EqualLevels_Setline_eq(self, val)
    if self == nil then return nil; end
    self.line_eq = val;
end
function EqualLevels_Getline_link(self)
    if self == nil then return nil; end
    return self.line_link;
end
function EqualLevels_Setline_link(self, val)
    if self == nil then return nil; end
    self.line_link = val;
end
function EqualLevels_Getbox_link(self)
    if self == nil then return nil; end
    return self.box_link;
end
function EqualLevels_Setbox_link(self, val)
    if self == nil then return nil; end
    self.box_link = val;
end
function CreateType_Helper(period, nameValue)
    return {
        name = nameValue or ("Helper"),
    };
end
function Helper_Getname(self)
    if self == nil then return nil; end
    return self.name;
end
function Helper_Setname(self, val)
    if self == nil then return nil; end
    self.name = val;
end
function Create_f_highlightDisplacement()
    local local_vars = {};
    local_vars["candle_range"] = instance:addInternalStream(0, 0);
    local_vars["!std_stream"] = instance:addInternalStream(0, 0);
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            if (period ~= source:size() - 1 or mode == core.UpdateLast) then
                if Settings_Getdisplacement_show(vars["Trend_Settings"]) then
                    SafeSetFloat(local_vars["candle_range"], period, math.abs(source.open:tick(period) - source.close:tick(period)));
                    local_vars["fvg"] = Triary(SafeGreater(source.close:tick(period - 1), source.open:tick(period - 1)), SafeLess(source.high:tick(period - 2), source.low:tick(period)), SafeGreater(source.low:tick(period - 2), source.high:tick(period)));
                    SafeSetFloat(local_vars["!std_stream"], period, vars["std"]);
                    local_vars["!std_stream_index"] = 1;
                    return Triary(Settings_Getdisplacement_fvg(vars["Trend_Settings"]), SafeGreater(SafeGetFloat(local_vars["candle_range"], period - 1), SafeMultiply(SafeGetFloat(local_vars["!std_stream"], period - local_vars["!std_stream_index"]), Settings_Getdisplacement_factor(vars["Trend_Settings"]))) and local_vars["fvg"], SafeGreater(SafeGetFloat(local_vars["candle_range"], period), vars["std"]));
                else
                    return false;
                end
            end
        end
    };
end
function Create_clear__custom()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(imb, period, mode)
            if not (Imbalance_Getbox(imb) == nil) then
                Line:Delete(Box_Getopen(Imbalance_Getbox(imb)));
                Line:Delete(Box_Getclose(Imbalance_Getbox(imb)));
                Line:Delete(Box_Getce(Imbalance_Getbox(imb)));
                Line:Delete(Box_Getlink(Imbalance_Getbox(imb)));
                Linefill:Delete(Box_Getfill(Imbalance_Getbox(imb)));
                Label:Delete(Box_Getlabel_open(Imbalance_Getbox(imb)));
                Label:Delete(Box_Getlabel_close(Imbalance_Getbox(imb)));
                Label:Delete(Box_Getlabel_ce(Imbalance_Getbox(imb)));
                Imbalance_Setbox(imb, nil);
                return Imbalance_Getbox(imb);
            end
        end
    };
end
function Create_AddImbalance()
    local local_vars = {};
    local_vars["clear__customFunc6"] = Create_clear__custom();
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(IS, o, c, o_time, c_time, period, mode)
            if firstCall then
                firstCall = false;
                local_vars["clear__customFunc6"].Clear();
            else
            end
            local_vars["imb"] = CreateType_Imbalance(period);
            Imbalance_Setopen_time(local_vars["imb"], o_time);
            Imbalance_Setclose_time(local_vars["imb"], c_time);
            Imbalance_Setopen(local_vars["imb"], o);
            Imbalance_Setmiddle(local_vars["imb"], SafeDivide((SafePlus(o, c)), 2));
            Imbalance_Setclose(local_vars["imb"], c);
            Imbalance_Setisbullish(local_vars["imb"], SafeLess(o, c));
            if SafeGreater(ImbalanceStructure_Getimbalance(IS):Size(), 0) then
                Imbalance_Setinvertable(local_vars["imb"], (Imbalance_Getisbullish(local_vars["imb"]) ~= Imbalance_Getisbullish(Array:First(ImbalanceStructure_Getimbalance(IS)))));
            end
            ImbalanceStructure_Getimbalance(IS):Unshift(local_vars["imb"]);
            if SafeGreater(ImbalanceStructure_Getimbalance(IS):Size(), Imbalance_Settings_Getmax_count(ImbalanceStructure_Getsettings(IS))) then
                local_vars["temp"] = Array:Pop(ImbalanceStructure_Getimbalance(IS));
                local_vars["clear__customFunc6"].GetValue(local_vars["temp"], period, mode);
            end
            return IS;
        end
    };
end
function Create_GetFVGDisplacementLevel()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(helper, period, mode)
            Helper_Setname(helper, "FVG Displacement Level");
            if (Imbalance_Settings_Getfvg_type(vars["FVG_Settings"]) == "Same As Displacement") then
                local_vars["out"] = Settings_Getdisplacement_factor(vars["Trend_Settings"]);
            elseif (Imbalance_Settings_Getfvg_type(vars["FVG_Settings"]) == "Level 1") then
                local_vars["out"] = 1;
            elseif (Imbalance_Settings_Getfvg_type(vars["FVG_Settings"]) == "Level 2") then
                local_vars["out"] = 2;
            elseif (Imbalance_Settings_Getfvg_type(vars["FVG_Settings"]) == "Level 3") then
                local_vars["out"] = 3;
            elseif (Imbalance_Settings_Getfvg_type(vars["FVG_Settings"]) == "Level 4") then
                local_vars["out"] = 4;
            end
            return local_vars["out"];
        end
    };
end
function Create_UpdateImbalance()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(IS, c, c_time, period, mode)
            if SafeGreater(ImbalanceStructure_Getimbalance(IS):Size(), 0) then
                local_vars["imb"] = Array:First(ImbalanceStructure_Getimbalance(IS));
                Imbalance_Setclose(local_vars["imb"], c);
                Imbalance_Setclose_time(local_vars["imb"], c_time);
                Imbalance_Setmiddle(local_vars["imb"], SafeDivide((SafePlus(Imbalance_Getopen(local_vars["imb"]), c)), 2));
                return Imbalance_Getmiddle(local_vars["imb"]);
            end
        end
    };
end
function Create_FindImbalance()
    local local_vars = {};
    local_vars["FVG"] = instance:addInternalStream(0, 0);
    local_vars["AddImbalanceFunc5"] = Create_AddImbalance();
    time = instance:addInternalStream(0, 0);
    local_vars["!Gap_stream"] = instance:addInternalStream(0, 0);
    local_vars["!body_stream"] = instance:addInternalStream(0, 0);
    local_vars["!std_stream"] = instance:addInternalStream(0, 0);
    local_vars["GetFVGDisplacementLevelFunc7"] = Create_GetFVGDisplacementLevel();
    local_vars["UpdateImbalanceFunc8"] = Create_UpdateImbalance();
    local_vars["AddImbalanceFunc9"] = Create_AddImbalance();
    local_vars["clear__customFunc10"] = Create_clear__custom();
    local_vars["AddImbalanceFunc11"] = Create_AddImbalance();
    local_vars["AddImbalanceFunc12"] = Create_AddImbalance();
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(IS, period, mode)
            if firstCall then
                firstCall = false;
        time[period] = source:date(period) * 86400000;
                local_vars["AddImbalanceFunc5"].Clear();
                local_vars["GetFVGDisplacementLevelFunc7"].Clear();
                local_vars["UpdateImbalanceFunc8"].Clear();
                local_vars["AddImbalanceFunc9"].Clear();
                local_vars["clear__customFunc10"].Clear();
                local_vars["AddImbalanceFunc11"].Clear();
                local_vars["AddImbalanceFunc12"].Clear();
            else
        time[period] = source:date(period) * 86400000;
            end
            if (period ~= source:size() - 1 or mode == core.UpdateLast) then
                local_vars["Gap"] = (SafeGreater(source.low:tick(period), source.high:tick(period - 1)) or SafeLess(source.high:tick(period), source.low:tick(period - 1)));
                SafeSetBool(local_vars["FVG"], period, (SafeLess(source.high:tick(period), source.low:tick(period - 2)) or SafeGreater(source.low:tick(period), source.high:tick(period - 2))));
                if (ImbalanceStructure_Gettype(IS) == "GAP") and local_vars["Gap"] then
                    local_vars["o"] = Triary(SafeLess(source.high:tick(period), source.low:tick(period - 1)), source.low:tick(period - 1), source.high:tick(period - 1));
                    local_vars["c"] = Triary(SafeLess(source.high:tick(period), source.low:tick(period - 1)), source.high:tick(period), source.low:tick(period));
                    local_vars["AddImbalanceFunc5"].GetValue(IS, local_vars["o"], local_vars["c"], time:tick(period - 1), time:tick(period), period, mode);
                end
                SafeSetBool(local_vars["!Gap_stream"], period, local_vars["Gap"]);
                local_vars["!Gap_stream_index"] = 1;
                if (ImbalanceStructure_Gettype(IS) == "FVG") and ((Imbalance_Settings_Getshow(ImbalanceStructure_Getsettings(IS)) or Imbalance_Settings_Getshow(vars["iFVG_Settings"]))) and SafeGetBool(local_vars["FVG"], period) and not (local_vars["Gap"]) and not (SafeGetFloat(local_vars["!Gap_stream"], period - local_vars["!Gap_stream_index"])) then
                    local_vars["o"] = 0;
                    local_vars["c"] = 0;
                    if SafeGreater(source.low:tick(period), source.high:tick(period - 2)) then
                        if SafeGreater(math.min(source.open:tick(period), source.close:tick(period)), SafeMax(source.open:tick(period - 1), source.close:tick(period - 1))) and Imbalance_Settings_GetmergeVI(vars["FVG_Settings"]) then
                            local_vars["c"] = math.min(source.open:tick(period), source.close:tick(period));
                        else
                            local_vars["c"] = source.low:tick(period);
                        end
                        if SafeGreater(SafeMin(source.open:tick(period - 1), source.close:tick(period - 1)), SafeMax(source.open:tick(period - 2), source.close:tick(period - 2))) and Imbalance_Settings_GetmergeVI(vars["FVG_Settings"]) then
                            local_vars["o"] = SafeMax(source.open:tick(period - 2), source.close:tick(period - 2));
                        else
                            local_vars["o"] = source.high:tick(period - 2);
                        end
                    end
                    if SafeLess(source.high:tick(period), source.low:tick(period - 2)) then
                        if SafeLess(math.max(source.open:tick(period), source.close:tick(period)), SafeMin(source.open:tick(period - 1), source.close:tick(period - 1))) and Imbalance_Settings_GetmergeVI(vars["FVG_Settings"]) then
                            local_vars["c"] = math.max(source.open:tick(period), source.close:tick(period));
                        else
                            local_vars["c"] = source.high:tick(period);
                        end
                        if SafeGreater(SafeMin(source.open:tick(period - 2), source.close:tick(period - 2)), SafeMax(source.open:tick(period - 1), source.close:tick(period - 1))) and Imbalance_Settings_GetmergeVI(vars["FVG_Settings"]) then
                            local_vars["o"] = SafeMin(source.open:tick(period - 2), source.close:tick(period - 2));
                        else
                            local_vars["o"] = source.low:tick(period - 2);
                        end
                    end
                    local_vars["valid"] = false;
                    SafeSetFloat(local_vars["!body_stream"], period, vars["body"]);
                    local_vars["!body_stream_index"] = 1;
                    SafeSetFloat(local_vars["!std_stream"], period, vars["std"]);
                    local_vars["!std_stream_index"] = 1;
                    if ((Imbalance_Settings_Getfvg_type(vars["FVG_Settings"]) == "Always Display") or (Imbalance_Settings_Getfvg_type(vars["FVG_Settings"]) ~= "High Probability") and SafeGreater(SafeGetFloat(local_vars["!body_stream"], period - local_vars["!body_stream_index"]), SafeMultiply(SafeGetFloat(local_vars["!std_stream"], period - local_vars["!std_stream_index"]), local_vars["GetFVGDisplacementLevelFunc7"].GetValue(vars["helper"], period, mode)))) then
                        if Imbalance_Settings_GetmergeVI(vars["FVG_Settings"]) then
                            if ((SafeGreater(SafeMin(source.open:tick(period - 1), source.close:tick(period - 1)), SafeMax(source.open:tick(period - 2), source.close:tick(period - 2))) or SafeGreater(SafeMin(source.open:tick(period - 2), source.close:tick(period - 2)), SafeMax(source.open:tick(period - 1), source.close:tick(period - 1))))) and SafeGetBool(local_vars["FVG"], period - 1) then
                                local_vars["UpdateImbalanceFunc8"].GetValue(IS, local_vars["c"], time:tick(period), period, mode);
                            else
                                local_vars["AddImbalanceFunc9"].GetValue(IS, local_vars["o"], local_vars["c"], time:tick(period - 1), time:tick(period), period, mode);
                            end
                            if Imbalance_Settings_Getshow(ImbalanceStructure_Getsettings(vars["VI"]:Get())) and ((SafeGreater(SafeMin(source.open:tick(period - 1), source.close:tick(period - 1)), SafeMax(source.open:tick(period - 2), source.close:tick(period - 2))) or SafeGreater(SafeMin(source.open:tick(period - 2), source.close:tick(period - 2)), SafeMax(source.open:tick(period - 1), source.close:tick(period - 1))))) then
                                if SafeGreater(ImbalanceStructure_Getimbalance(vars["VI"]:Get()):Size(), 0) then
                                    local_vars["temp"] = ImbalanceStructure_Getimbalance(vars["VI"]:Get()):Shift();
                                    local_vars["clear__customFunc10"].GetValue(local_vars["temp"], period, mode);
                                end
                            end
                        else
                            local_vars["AddImbalanceFunc11"].GetValue(IS, local_vars["o"], local_vars["c"], time:tick(period - 1), time:tick(period), period, mode);
                        end
                    end
                end
                if (ImbalanceStructure_Gettype(IS) == "VI") and Imbalance_Settings_Getshow(ImbalanceStructure_Getsettings(IS)) and ((SafeGreater(math.min(source.open:tick(period), source.close:tick(period)), SafeMax(source.open:tick(period - 1), source.close:tick(period - 1))) or SafeLess(math.max(source.open:tick(period), source.close:tick(period)), SafeMin(source.open:tick(period - 1), source.close:tick(period - 1))))) and not (local_vars["Gap"]) and ((not (SafeGetBool(local_vars["FVG"], period)) and Imbalance_Settings_GetmergeVI(vars["FVG_Settings"]) or not (Imbalance_Settings_GetmergeVI(vars["FVG_Settings"])))) then
                    local_vars["c"] = Triary(SafeGreater(math.max(source.open:tick(period), source.close:tick(period)), SafeMin(source.open:tick(period - 1), source.close:tick(period - 1))), math.min(source.open:tick(period), source.close:tick(period)), math.max(source.open:tick(period), source.close:tick(period)));
                    local_vars["o"] = Triary(SafeGreater(math.min(source.open:tick(period), source.close:tick(period)), SafeMax(source.open:tick(period - 1), source.close:tick(period - 1))), SafeMax(source.open:tick(period - 1), source.close:tick(period - 1)), SafeMin(source.open:tick(period - 1), source.close:tick(period - 1)));
                    local_vars["AddImbalanceFunc12"].GetValue(IS, local_vars["o"], local_vars["c"], time:tick(period - 1), time:tick(period), period, mode);
                end
            end
            return IS;
        end
    };
end
function Create_CheckMitigated()
    local local_vars = {};
    local_vars["AddImbalanceFunc16"] = Create_AddImbalance();
    local_vars["AddImbalanceFunc17"] = Create_AddImbalance();
    time = instance:addInternalStream(0, 0);
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(IS, period, mode)
            if firstCall then
                firstCall = false;
                local_vars["AddImbalanceFunc16"].Clear();
                local_vars["AddImbalanceFunc17"].Clear();
        time[period] = source:date(period) * 86400000;
            else
        time[period] = source:date(period) * 86400000;
            end
            for _, imb in ipairs(Array:Enum(ImbalanceStructure_Getimbalance(IS))) do
                if (ImbalanceStructure_Gettype(IS) == "FVG") then
                    if Imbalance_Getisbullish(imb) and Imbalance_Getinvertable(imb) and not (Imbalance_Getinverted(imb)) then
                        Imbalance_Setinverted(imb, SafeLess(source.close:tick(period), Imbalance_Getopen(imb)));
                        if Imbalance_Getinverted(imb) then
                            local_vars["AddImbalanceFunc16"].GetValue(vars["iFVGs"]:Get(), Imbalance_Getclose(imb), Imbalance_Getopen(imb), Imbalance_Getopen_time(imb), Imbalance_Getclose_time(imb), period, mode);
                        end
                    end
                    if not (Imbalance_Getisbullish(imb)) and Imbalance_Getinvertable(imb) and not (Imbalance_Getinverted(imb)) then
                        Imbalance_Setinverted(imb, SafeGreater(source.close:tick(period), Imbalance_Getopen(imb)));
                        if Imbalance_Getinverted(imb) then
                            local_vars["AddImbalanceFunc17"].GetValue(vars["iFVGs"]:Get(), Imbalance_Getclose(imb), Imbalance_Getopen(imb), Imbalance_Getopen_time(imb), Imbalance_Getclose_time(imb), period, mode);
                        end
                    end
                end
                if not (Imbalance_Getmitigated(imb)) then
                    if "None" then
                        Imbalance_Setmitigated(imb, false);
                    elseif "Wick Touched" then
                        Imbalance_Setmitigated(imb, Triary(Imbalance_Getisbullish(imb), SafeLess(source.low:tick(period), Imbalance_Getclose(imb)), SafeGreater(source.high:tick(period), Imbalance_Getclose(imb))));
                    elseif "Wick filled" then
                        Imbalance_Setmitigated(imb, Triary(Imbalance_Getisbullish(imb), SafeLE(source.low:tick(period), Imbalance_Getopen(imb)), SafeGE(source.high:tick(period), Imbalance_Getopen(imb))));
                    elseif "Body filled" then
                        Imbalance_Setmitigated(imb, Triary(Imbalance_Getisbullish(imb), SafeLE(math.min(source.open:tick(period), source.close:tick(period)), Imbalance_Getopen(imb)), SafeGE(math.max(source.open:tick(period), source.close:tick(period)), Imbalance_Getopen(imb))));
                    elseif "Wick filled half" then
                        Imbalance_Setmitigated(imb, Triary(Imbalance_Getisbullish(imb), SafeLE(source.low:tick(period), Imbalance_Getmiddle(imb)), SafeGE(source.high:tick(period), Imbalance_Getmiddle(imb))));
                    elseif "Body filled half" then
                        Imbalance_Setmitigated(imb, Triary(Imbalance_Getisbullish(imb), SafeLE(math.min(source.open:tick(period), source.close:tick(period)), Imbalance_Getmiddle(imb)), SafeGE(math.max(source.open:tick(period), source.close:tick(period)), Imbalance_Getmiddle(imb))));
                    end
                    if Imbalance_Getmitigated(imb) then
                        Imbalance_Setmitigated_time(imb, time:tick(period));
                    end
                end
            end
            return IS;
        end
    };
end
function Create_LineStyle()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(helper, style, period, mode)
            Helper_Setname(helper, style);
            if (style == "----") then
                local_vars["out"] = "dashed";
            elseif (style == "····") then
                local_vars["out"] = "dotted";
            else
                local_vars["out"] = "solid";
            end
            return local_vars["out"];
        end
    };
end
function Create_render()
    local local_vars = {};
    time = instance:addInternalStream(0, 0);
    local_vars["LineStyleFunc22"] = Create_LineStyle();
    local_vars["LineStyleFunc23"] = Create_LineStyle();
    local_vars["LineStyleFunc24"] = Create_LineStyle();
    local_vars["LineStyleFunc25"] = Create_LineStyle();
    local_vars["clear__customFunc26"] = Create_clear__custom();
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(IS, period, mode)
            if firstCall then
                firstCall = false;
        time[period] = source:date(period) * 86400000;
                local_vars["LineStyleFunc22"].Clear();
                local_vars["LineStyleFunc23"].Clear();
                local_vars["LineStyleFunc24"].Clear();
                local_vars["LineStyleFunc25"].Clear();
                local_vars["clear__customFunc26"].Clear();
            else
        time[period] = source:date(period) * 86400000;
            end
            if Imbalance_Settings_Getshow(ImbalanceStructure_Getsettings(IS)) then
                for _, imb in ipairs(Array:Enum(ImbalanceStructure_Getimbalance(IS))) do
                    local_vars["c"] = nil;
                    local_vars["cce"] = nil;
                    local_vars["buffer"] = 0;
                    if Imbalance_Getmitigated(imb) then
                        local_vars["buffer"] = Triary(Imbalance_Getmitigated(imb), Imbalance_Getmitigated_time(imb), SafePlus(time:tick(period), SafeMultiply((SafeMinus(time:tick(period), time:tick(period - 1))), Settings_Getextend(vars["Trend_Settings"]))));
                        local_vars["c"] = Triary(Imbalance_Getisbullish(imb), Imbalance_Settings_Getmitigated_color_bull(ImbalanceStructure_Getsettings(IS)), Imbalance_Settings_Getmitigated_color_bear(ImbalanceStructure_Getsettings(IS)));
                        local_vars["cce"] = Triary(Imbalance_Getisbullish(imb), Imbalance_Settings_GetCE_bull_color(ImbalanceStructure_Getsettings(IS)), Imbalance_Settings_GetCE_bear_color(ImbalanceStructure_Getsettings(IS)));
                    else
                        local_vars["buffer"] = SafePlus(time:tick(period), SafeMultiply((SafeMinus(time:tick(period), time:tick(period - 1))), Settings_Getextend(vars["Trend_Settings"])));
                        local_vars["c"] = Triary(Imbalance_Getisbullish(imb), Imbalance_Settings_Getcolor_bull(ImbalanceStructure_Getsettings(IS)), Imbalance_Settings_Getcolor_bear(ImbalanceStructure_Getsettings(IS)));
                        local_vars["cce"] = Triary(Imbalance_Getisbullish(imb), Imbalance_Settings_GetCE_bull_color(ImbalanceStructure_Getsettings(IS)), Imbalance_Settings_GetCE_bear_color(ImbalanceStructure_Getsettings(IS)));
                    end
                    if Imbalance_Getbox(imb) == nil then
                        Imbalance_Setbox(imb, CreateType_Box(period));
                        Box_Setopen(Imbalance_Getbox(imb), Line:New(Imbalance_Getopen_time(imb), Imbalance_Getopen(imb), local_vars["buffer"], Imbalance_Getopen(imb)):SetColor(Triary(Imbalance_Settings_Getopen_show(ImbalanceStructure_Getsettings(IS)), local_vars["c"], vars["color_transparent"])):SetStyle(local_vars["LineStyleFunc22"].GetValue(vars["helper"], Imbalance_Settings_Getopen_style(ImbalanceStructure_Getsettings(IS)), period, mode)):SetWidth(Imbalance_Settings_Getopen_size(ImbalanceStructure_Getsettings(IS))):SetXLoc(Imbalance_Getopen_time(imb), local_vars["buffer"], "bar_time"));
                        Box_Setclose(Imbalance_Getbox(imb), Line:New(Imbalance_Getopen_time(imb), Imbalance_Getclose(imb), local_vars["buffer"], Imbalance_Getclose(imb)):SetColor(Triary(Imbalance_Settings_Getclose_show(ImbalanceStructure_Getsettings(IS)), local_vars["c"], vars["color_transparent"])):SetStyle(local_vars["LineStyleFunc23"].GetValue(vars["helper"], Imbalance_Settings_Getclose_style(ImbalanceStructure_Getsettings(IS)), period, mode)):SetWidth(Imbalance_Settings_Getclose_size(ImbalanceStructure_Getsettings(IS))):SetXLoc(Imbalance_Getopen_time(imb), local_vars["buffer"], "bar_time"));
                        if Imbalance_Settings_Getlink_show(ImbalanceStructure_Getsettings(IS)) then
                            Box_Setlink(Imbalance_Getbox(imb), Line:New(local_vars["buffer"], Imbalance_Getopen(imb), local_vars["buffer"], Imbalance_Getclose(imb)):SetColor(local_vars["c"]):SetStyle(local_vars["LineStyleFunc24"].GetValue(vars["helper"], Imbalance_Settings_Getlink_style(ImbalanceStructure_Getsettings(IS)), period, mode)):SetWidth(Imbalance_Settings_Getlink_size(ImbalanceStructure_Getsettings(IS))):SetXLoc(local_vars["buffer"], local_vars["buffer"], "bar_time"));
                        end
                        if Imbalance_Settings_Getfill(ImbalanceStructure_Getsettings(IS)) then
                            Box_Setfill(Imbalance_Getbox(imb), Linefill:New(Box_Getopen(Imbalance_Getbox(imb)), Box_Getclose(Imbalance_Getbox(imb))):SetColor(local_vars["c"] + math.floor(Imbalance_Settings_Getfill_percent(ImbalanceStructure_Getsettings(IS)) / 100 * 255) * 16777216));
                        end
                        if Imbalance_Settings_GetCE_show(ImbalanceStructure_Getsettings(IS)) then
                            Box_Setce(Imbalance_Getbox(imb), Line:New(Imbalance_Getopen_time(imb), Imbalance_Getmiddle(imb), local_vars["buffer"], Imbalance_Getmiddle(imb)):SetColor(local_vars["cce"]):SetStyle(local_vars["LineStyleFunc25"].GetValue(vars["helper"], Imbalance_Settings_GetCE_style(ImbalanceStructure_Getsettings(IS)), period, mode)):SetWidth(Imbalance_Settings_GetCE_size(ImbalanceStructure_Getsettings(IS))):SetXLoc(Imbalance_Getopen_time(imb), local_vars["buffer"], "bar_time"));
                        end
                    else
                        Line:SetColor(Box_Getopen(Imbalance_Getbox(imb)), local_vars["c"]);
                        Line:SetColor(Box_Getclose(Imbalance_Getbox(imb)), local_vars["c"]);
                        Line:SetColor(Box_Getlink(Imbalance_Getbox(imb)), local_vars["c"]);
                        Linefill:SetColor(Box_Getfill(Imbalance_Getbox(imb)), local_vars["c"] + math.floor(Imbalance_Settings_Getfill_percent(ImbalanceStructure_Getsettings(IS)) / 100 * 255) * 16777216);
                        Line:SetX2(Box_Getopen(Imbalance_Getbox(imb)), local_vars["buffer"]);
                        Line:SetY1(Box_Getclose(Imbalance_Getbox(imb)), Imbalance_Getclose(imb));
                        Line:SetXY2(Box_Getclose(Imbalance_Getbox(imb)), local_vars["buffer"], Imbalance_Getclose(imb));
                        Line:SetXY1(Box_Getlink(Imbalance_Getbox(imb)), local_vars["buffer"], Imbalance_Getopen(imb));
                        Line:SetXY2(Box_Getlink(Imbalance_Getbox(imb)), local_vars["buffer"], Imbalance_Getclose(imb));
                        Line:SetY1(Box_Getce(Imbalance_Getbox(imb)), Imbalance_Getmiddle(imb));
                        Line:SetXY2(Box_Getce(Imbalance_Getbox(imb)), local_vars["buffer"], Imbalance_Getmiddle(imb));
                    end
                    if Imbalance_Getmitigated(imb) and not (Imbalance_Settings_Getmitigated_show(ImbalanceStructure_Getsettings(IS))) then
                        local_vars["clear__customFunc26"].GetValue(imb, period, mode);
                    end
                end
            end
            return IS;
        end
    };
end
function Create_SkipEQPivot_i(idx)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(p, period, mode)
            local_vars["i"] = idx;
            if SafeGE(p:Size(), local_vars["i"]) then
            end
            return local_vars["i"];
        end
    };
end
function Create_FindLT()
    local local_vars = {};
    local_vars["SkipEQPivotFunc31"] = Create_SkipEQPivot_i(2);
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(MS, period, mode)
            if firstCall then
                firstCall = false;
                local_vars["SkipEQPivotFunc31"].Clear();
            else
            end
            if SafeGreater(MarketStructure_GetITH(MS):Size(), 2) then
                local_vars["h1"] = Array:First(MarketStructure_GetITH(MS));
                local_vars["h2"] = Array:Get(MarketStructure_GetITH(MS), 1);
                local_vars["h3"] = Array:Get(MarketStructure_GetITH(MS), 2);
                if SafeGreater(Pivot_Getprice(local_vars["h2"]), Pivot_Getprice(local_vars["h3"])) and SafeGreater(Pivot_Getprice(local_vars["h2"]), Pivot_Getprice(local_vars["h1"])) and not (Pivot_GetisLT(local_vars["h2"])) then
                    Pivot_SetisLT(local_vars["h2"], true);
                    if SafeGreater(MarketStructure_GetLTH(MS):Size(), 0) then
                        local_vars["p"] = Array:First(MarketStructure_GetLTH(MS));
                        if SafeLE(Pivot_Getprice(local_vars["p"]), Pivot_Getprice(local_vars["h2"])) then
                            Pivot_SetisLHigherHigh(local_vars["h2"], true);
                        end
                    end
                    MarketStructure_GetLTH(MS):Unshift(local_vars["h2"]);
                end
            end
            if SafeGreater(MarketStructure_GetITL(MS):Size(), 2) then
                local_vars["l1"] = Array:First(MarketStructure_GetITL(MS));
                local_vars["l2"] = Array:Get(MarketStructure_GetITL(MS), 1);
                local_vars["l3"] = Array:Get(MarketStructure_GetITL(MS), local_vars["SkipEQPivotFunc31"].GetValue(MarketStructure_GetITL(MS), period, mode));
                if SafeLess(Pivot_Getprice(local_vars["l2"]), Pivot_Getprice(local_vars["l3"])) and SafeLess(Pivot_Getprice(local_vars["l2"]), Pivot_Getprice(local_vars["l1"])) and not (Pivot_GetisLT(local_vars["l2"])) then
                    Pivot_SetisLT(local_vars["l2"], true);
                    if SafeGreater(MarketStructure_GetLTL(MS):Size(), 0) then
                        local_vars["p"] = Array:First(MarketStructure_GetLTL(MS));
                        if SafeGE(Pivot_Getprice(local_vars["p"]), Pivot_Getprice(local_vars["l2"])) then
                            Pivot_SetisLLowerLow(local_vars["l2"], true);
                        end
                    end
                    MarketStructure_GetLTL(MS):Unshift(local_vars["l2"]);
                end
            end
            return MS;
        end
    };
end
function Create_FindIT()
    local local_vars = {};
    local_vars["SkipEQPivotFunc33"] = Create_SkipEQPivot_i(2);
    local_vars["SkipEQPivotFunc34"] = Create_SkipEQPivot_i(2);
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(MS, period, mode)
            if firstCall then
                firstCall = false;
                local_vars["SkipEQPivotFunc33"].Clear();
                local_vars["SkipEQPivotFunc34"].Clear();
            else
            end
            if SafeGreater(MarketStructure_GetSTH(MS):Size(), 3) then
                local_vars["h1"] = Array:First(MarketStructure_GetSTH(MS));
                local_vars["h2"] = Array:Get(MarketStructure_GetSTH(MS), 1);
                local_vars["h3"] = Array:Get(MarketStructure_GetSTH(MS), local_vars["SkipEQPivotFunc33"].GetValue(MarketStructure_GetSTH(MS), period, mode));
                if SafeGreater(Pivot_Getprice(local_vars["h2"]), Pivot_Getprice(local_vars["h3"])) and SafeGreater(Pivot_Getprice(local_vars["h2"]), Pivot_Getprice(local_vars["h1"])) and not (Pivot_GetisIT(local_vars["h2"])) then
                    Pivot_SetisIT(local_vars["h2"], true);
                    if SafeGreater(MarketStructure_GetITH(MS):Size(), 0) then
                        local_vars["p"] = Array:First(MarketStructure_GetITH(MS));
                        if SafeLE(Pivot_Getprice(local_vars["p"]), Pivot_Getprice(local_vars["h2"])) then
                            Pivot_SetisIHigherHigh(local_vars["h2"], true);
                        end
                    end
                    MarketStructure_GetITH(MS):Unshift(local_vars["h2"]);
                end
            end
            if SafeGreater(MarketStructure_GetSTL(MS):Size(), 2) then
                local_vars["l1"] = Array:First(MarketStructure_GetSTL(MS));
                local_vars["l2"] = Array:Get(MarketStructure_GetSTL(MS), 1);
                local_vars["l3"] = Array:Get(MarketStructure_GetSTL(MS), local_vars["SkipEQPivotFunc34"].GetValue(MarketStructure_GetSTL(MS), period, mode));
                if SafeLess(Pivot_Getprice(local_vars["l2"]), Pivot_Getprice(local_vars["l3"])) and SafeLess(Pivot_Getprice(local_vars["l2"]), Pivot_Getprice(local_vars["l1"])) and not (Pivot_GetisIT(local_vars["l2"])) then
                    Pivot_SetisIT(local_vars["l2"], true);
                    if SafeGreater(MarketStructure_GetITL(MS):Size(), 0) then
                        local_vars["p"] = Array:First(MarketStructure_GetITL(MS));
                        if SafeGE(Pivot_Getprice(local_vars["p"]), Pivot_Getprice(local_vars["l2"])) then
                            Pivot_SetisILowerLow(local_vars["l2"], true);
                        end
                    end
                    MarketStructure_GetITL(MS):Unshift(local_vars["l2"]);
                end
            end
            return MS;
        end
    };
end
function Create_SkipEQHigh_i(idx)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(helper, period, mode)
            Helper_Setname(helper, "Skip EQ Highs");
            local_vars["i"] = idx;
            return local_vars["i"];
        end
    };
end
function Create_SkipEQLow_i(idx)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(helper, period, mode)
            Helper_Setname(helper, "Skip EQ Lows");
            local_vars["i"] = idx;
            return local_vars["i"];
        end
    };
end
function Create_testEQ()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(p1, p2, period, mode)
            local_vars["valid"] = true;
            Line:SetXY1(vars["tester"]:Get(), Pivot_Getindex(p1), Pivot_Getprice(p1));
            Line:SetXY2(vars["tester"]:Get(), Pivot_Getindex(p2), Pivot_Getprice(p2));
            local for1_from = SafePlus(Pivot_Getindex(p1), 1);
            local for1_to = SafeMinus(Pivot_Getindex(p2), 1);
            if for1_to ~= nil and for1_from ~= nil then
            local for1_step = for1_from < for1_to and 1 or -1;
            for i = for1_from, for1_to, for1_step do
                local_vars["isHigh"] = Pivot_GetisHigh(p1);
                local_vars["p"] = Line:GetPrice(vars["tester"]:Get(), i);
                local_vars["j"] = SafeMinus(period, i);
                if (local_vars["isHigh"] and SafeGreater(source.high:tick(period - local_vars["j"]), local_vars["p"]) or not (local_vars["isHigh"]) and SafeLess(source.low:tick(period - local_vars["j"]), local_vars["p"])) then
                    local_vars["valid"] = false;
                end
            end
            end
            return local_vars["valid"];
        end
    };
end
function Create_AddEQ()
    local local_vars = {};
    time = instance:addInternalStream(0, 0);
    local_vars["LineStyleFunc44"] = Create_LineStyle();
    local_vars["LineStyleFunc45"] = Create_LineStyle();
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(this, p1, p2, period, mode)
            if firstCall then
                firstCall = false;
        time[period] = source:date(period) * 86400000;
                local_vars["LineStyleFunc44"].Clear();
                local_vars["LineStyleFunc45"].Clear();
            else
        time[period] = source:date(period) * 86400000;
            end
            local_vars["eq"] = CreateType_EqualLevels(period);
            EqualLevels_Setstart(local_vars["eq"], Pivot_Getprice(p1));
            EqualLevels_Setstart_time(local_vars["eq"], Pivot_Gettime(p1));
            EqualLevels_Setstart_index(local_vars["eq"], Pivot_Getindex(p1));
            EqualLevels_Setend(local_vars["eq"], Pivot_Getprice(p2));
            EqualLevels_Setend_time(local_vars["eq"], Pivot_Gettime(p2));
            EqualLevels_Setend_index(local_vars["eq"], Pivot_Getindex(p2));
            EqualLevels_SetisHigh(local_vars["eq"], Pivot_GetisHigh(p1));
            EqualLevels_SetisLow(local_vars["eq"], Pivot_GetisLow(p1));
            if Settings_GetEQ_show(vars["Trend_Settings"]) then
                local_vars["start_time"] = 0;
                if EqualLevels_GetisHigh(local_vars["eq"]) then
                    EqualLevels_Setprice(local_vars["eq"], Triary(SafeGreater(EqualLevels_Getstart(local_vars["eq"]), EqualLevels_Getend(local_vars["eq"])), EqualLevels_Getstart(local_vars["eq"]), EqualLevels_Getend(local_vars["eq"])));
                    local_vars["start_time"] = Triary(SafeGreater(EqualLevels_Getstart(local_vars["eq"]), EqualLevels_Getend(local_vars["eq"])), EqualLevels_Getstart_time(local_vars["eq"]), EqualLevels_Getend_time(local_vars["eq"]));
                else
                    EqualLevels_Setprice(local_vars["eq"], Triary(SafeLess(EqualLevels_Getstart(local_vars["eq"]), EqualLevels_Getend(local_vars["eq"])), EqualLevels_Getstart(local_vars["eq"]), EqualLevels_Getend(local_vars["eq"])));
                    local_vars["start_time"] = Triary(SafeLess(EqualLevels_Getstart(local_vars["eq"]), EqualLevels_Getend(local_vars["eq"])), EqualLevels_Getstart_time(local_vars["eq"]), EqualLevels_Getend_time(local_vars["eq"]));
                end
                EqualLevels_Setline_eq(local_vars["eq"], Line:New(EqualLevels_Getstart_time(local_vars["eq"]), EqualLevels_Getprice(local_vars["eq"]), time:tick(period), EqualLevels_Getprice(local_vars["eq"])):SetColor(Triary(EqualLevels_GetisHigh(local_vars["eq"]), Settings_GetEQ_color_bull(vars["Trend_Settings"]), Settings_GetEQ_color_bear(vars["Trend_Settings"]))):SetStyle(local_vars["LineStyleFunc44"].GetValue(vars["helper"], Settings_GetEQ_style(vars["Trend_Settings"]), period, mode)):SetWidth(Settings_GetEQ_size(vars["Trend_Settings"])):SetXLoc(EqualLevels_Getstart_time(local_vars["eq"]), time:tick(period), "bar_time"));
                if Settings_GetEQ_link_show(vars["Trend_Settings"]) then
                    EqualLevels_Setline_link(local_vars["eq"], Line:New(EqualLevels_Getstart_time(local_vars["eq"]), EqualLevels_Getstart(local_vars["eq"]), EqualLevels_Getend_time(local_vars["eq"]), EqualLevels_Getend(local_vars["eq"])):SetColor(Settings_GetEQ_link_color(vars["Trend_Settings"])):SetStyle(local_vars["LineStyleFunc45"].GetValue(vars["helper"], Settings_GetEQ_link_style(vars["Trend_Settings"]), period, mode)):SetWidth(Settings_GetEQ_link_size(vars["Trend_Settings"])):SetXLoc(EqualLevels_Getstart_time(local_vars["eq"]), EqualLevels_Getend_time(local_vars["eq"]), "bar_time"));
                end
                if Settings_GetEQ_shade(vars["Trend_Settings"]) then
                    EqualLevels_Setbox_link(local_vars["eq"], Box:New(core.formatDate(Box:GetSerial(EqualLevels_Getstart_time(local_vars["eq"]), source, "bar_time") or 0), "1", EqualLevels_Getstart_time(local_vars["eq"]), EqualLevels_Getstart(local_vars["eq"]), EqualLevels_Getend_time(local_vars["eq"]), EqualLevels_Getend(local_vars["eq"])):SetBgColor(Triary(EqualLevels_GetisHigh(local_vars["eq"]), Settings_GetEQ_shade_bull(vars["Trend_Settings"]), Settings_GetEQ_shade_bear(vars["Trend_Settings"]))):SetBorderColor(vars["color_transparent"]):SetXLoc("bar_time"));
                end
                this:Unshift(local_vars["eq"]);
                if SafeGreater(this:Size(), SafePlus(Settings_GetEQ_max(vars["Trend_Settings"]), Settings_GetEQ_max_claimed(vars["Trend_Settings"]))) then
                    local_vars["t"] = Array:Pop(this);
                    Line:Delete(EqualLevels_Getline_eq(local_vars["t"]));
                    Line:Delete(EqualLevels_Getline_link(local_vars["t"]));
                    Box:Delete(EqualLevels_Getbox_link(local_vars["t"]));
                end
            end
            return this;
        end
    };
end
function Create_ProcessEQ()
    local local_vars = {};
    local_vars["testEQFunc41"] = Create_testEQ();
    local_vars["testEQFunc42"] = Create_testEQ();
    local_vars["AddEQFunc43"] = Create_AddEQ();
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(this, p1, p2, period, mode)
            if firstCall then
                firstCall = false;
                local_vars["testEQFunc41"].Clear();
                local_vars["testEQFunc42"].Clear();
                local_vars["AddEQFunc43"].Clear();
            else
            end
            local_vars["matched"] = false;
            for _, p in ipairs(Array:Enum(this)) do
                if (EqualLevels_Getstart_index(p) == Pivot_Getindex(p1)) and not (EqualLevels_GetisClaimed(p)) then
                    if (SafeLE(EqualLevels_Getend(p), Pivot_Getprice(p2)) and EqualLevels_GetisHigh(p) or SafeGE(EqualLevels_Getend(p), Pivot_Getprice(p2)) and EqualLevels_GetisLow(p)) then
                        if local_vars["testEQFunc41"].GetValue(p1, p2, period, mode) then
                            EqualLevels_Setend(p, Pivot_Getprice(p2));
                            EqualLevels_Setend_time(p, Pivot_Gettime(p2));
                            EqualLevels_Setend_index(p, Pivot_Getindex(p2));
                            Line:SetXY2(EqualLevels_Getline_link(p), EqualLevels_Getend_time(p), EqualLevels_Getend(p));
                            Box:SetRightBottom(EqualLevels_Getbox_link(p), EqualLevels_Getend_time(p), EqualLevels_Getend(p));
                        end
                    end
                    local_vars["matched"] = true;
                    break;
                end
                if (((EqualLevels_Getend_index(p) == Pivot_Getindex(p2)) or (EqualLevels_Getend_index(p) == Pivot_Getindex(p1)))) and (((EqualLevels_GetisLow(p) == Pivot_GetisLow(p1)) or (EqualLevels_GetisLow(p) == Pivot_GetisLow(p2)))) then
                    local_vars["matched"] = true;
                    break;
                end
            end
            if not (local_vars["matched"]) then
                if local_vars["testEQFunc42"].GetValue(p1, p2, period, mode) then
                    local_vars["AddEQFunc43"].GetValue(this, p1, p2, period, mode);
                end
            end
            return this;
        end
    };
end
function Create_findEQ()
    local local_vars = {};
    local_vars["ProcessEQFunc40"] = Create_ProcessEQ();
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(MS, pivot, period, mode)
            if firstCall then
                firstCall = false;
                local_vars["ProcessEQFunc40"].Clear();
            else
            end
            if (Settings_GetEQ_show(MarketStructure_Getsettings(MS)) or Settings_GetEQ_link_show(MarketStructure_Getsettings(MS))) then
                if SafeGreater(MarketStructure_GetST(MS):Size(), 2) then
                    for _, p in ipairs(Array:Enum(MarketStructure_GetST(MS))) do
                        if ((Pivot_GetisHigh(p) and Pivot_GetisHigh(pivot) or Pivot_GetisLow(p) and Pivot_GetisLow(pivot))) and (Pivot_Getindex(p) ~= Pivot_Getindex(pivot)) then
                            if SafeLess(SafeAbs(SafeMinus(Pivot_Getprice(p), Pivot_Getprice(pivot))), vars["spacing"]) then
                                local_vars["ProcessEQFunc40"].GetValue(vars["EQs"]:Get(), p, pivot, period, mode);
                            end
                        end
                    end
                end
            end
            return MS;
        end
    };
end
function Create_Add_b(isHigh)
    local local_vars = {};
    local_vars["findEQFunc39"] = Create_findEQ();
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(MS, p_price, p_time, p_index, period, mode)
            if firstCall then
                firstCall = false;
                local_vars["findEQFunc39"].Clear();
            else
            end
            local_vars["pivot"] = CreateType_Pivot(period);
            Pivot_Setprice(local_vars["pivot"], p_price);
            Pivot_Settime(local_vars["pivot"], p_time);
            Pivot_SetisST(local_vars["pivot"], true);
            Pivot_Setindex(local_vars["pivot"], p_index);
            MarketStructure_GetST(MS):Unshift(local_vars["pivot"]);
            if isHigh then
                Pivot_SetisHigh(local_vars["pivot"], true);
                if SafeGreater(MarketStructure_GetSTH(MS):Size(), 0) then
                    local_vars["p"] = Array:First(MarketStructure_GetSTH(MS));
                    if SafeLE(Pivot_Getprice(local_vars["p"]), p_price) then
                        Pivot_SetisSHigherHigh(local_vars["pivot"], true);
                    end
                end
                MarketStructure_GetSTH(MS):Unshift(local_vars["pivot"]);
            else
                Pivot_SetisLow(local_vars["pivot"], true);
                if SafeGreater(MarketStructure_GetSTL(MS):Size(), 0) then
                    local_vars["p"] = Array:First(MarketStructure_GetSTL(MS));
                    if SafeGE(Pivot_Getprice(local_vars["p"]), p_price) then
                        Pivot_SetisSLowerLow(local_vars["pivot"], true);
                    end
                end
                MarketStructure_GetSTL(MS):Unshift(local_vars["pivot"]);
            end
            local_vars["findEQFunc39"].GetValue(MS, local_vars["pivot"], period, mode);
            if SafeGreater(MarketStructure_GetST(MS):Size(), vars["MAX_BUFFER"]) then
                local_vars["temp"] = Array:Pop(MarketStructure_GetST(MS));
                Line:Delete(Pivot_Getln(local_vars["temp"]));
                Label:Delete(Pivot_Getlbl(local_vars["temp"]));
            end
            return MS;
        end
    };
end
function Create_FindST()
    local local_vars = {};
    local_vars["SkipEQHighFunc36"] = Create_SkipEQHigh_i(2);
    local_vars["SkipEQLowFunc37"] = Create_SkipEQLow_i(2);
    local_vars["AddFunc38"] = Create_Add_b(true);
    time = instance:addInternalStream(0, 0);
    local_vars["AddFunc46"] = Create_Add_b(false);
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(MS, period, mode)
            if firstCall then
                firstCall = false;
                local_vars["SkipEQHighFunc36"].Clear();
                local_vars["SkipEQLowFunc37"].Clear();
        time[period] = source:date(period) * 86400000;
                local_vars["AddFunc38"].Clear();
                local_vars["AddFunc46"].Clear();
            else
        time[period] = source:date(period) * 86400000;
            end
            local_vars["h"] = SafeGreater(source.high:tick(period - 1), source.high:tick(period - local_vars["SkipEQHighFunc36"].GetValue(vars["helper"], period, mode))) and SafeGreater(source.high:tick(period - 1), source.high:tick(period));
            local_vars["l"] = SafeLess(source.low:tick(period - 1), source.low:tick(period - local_vars["SkipEQLowFunc37"].GetValue(vars["helper"], period, mode))) and SafeLess(source.low:tick(period - 1), source.low:tick(period));
            if local_vars["h"] then
                local_vars["AddFunc38"].GetValue(MS, source.high:tick(period - 1), time:tick(period - 1), period - 1, period, mode);
            end
            if local_vars["l"] then
                local_vars["AddFunc46"].GetValue(MS, source.low:tick(period - 1), time:tick(period - 1), period - 1, period, mode);
            end
            return MS;
        end
    };
end
function Create_CheckClaimed()
    local local_vars = {};
    time = instance:addInternalStream(0, 0);
    local_vars["LineStyleFunc48"] = Create_LineStyle();
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(MS, period, mode)
            if firstCall then
                firstCall = false;
        time[period] = source:date(period) * 86400000;
                local_vars["LineStyleFunc48"].Clear();
            else
        time[period] = source:date(period) * 86400000;
            end
            local_vars["claimed"] = nil;
            if SafeGreater(MarketStructure_GetST(MS):Size(), 0) then
                local for2_from = SafeMinus(MarketStructure_GetST(MS):Size(), 1);
                local for2_to = 0;
                if for2_to ~= nil and for2_from ~= nil then
                local for2_step = for2_from < for2_to and 1 or -1;
                for i = for2_from, for2_to, for2_step do
                    local_vars["pivot"] = Array:Get(MarketStructure_GetST(MS), i);
                    if not (Pivot_Getclaimed(local_vars["pivot"])) then
                        if (Pivot_GetisHigh(local_vars["pivot"]) and SafeGreater(source.high:tick(period), Pivot_Getprice(local_vars["pivot"])) or Pivot_GetisLow(local_vars["pivot"]) and SafeLess(source.low:tick(period), Pivot_Getprice(local_vars["pivot"]))) then
                            Pivot_Setclaimed(local_vars["pivot"], true);
                            Pivot_Settime_last(local_vars["pivot"], time:tick(period));
                        end
                    end
                end
                end
            end
            for _, eq in ipairs(Array:Enum(vars["EQs"]:Get())) do
                if not (EqualLevels_GetisClaimed(eq)) then
                    if EqualLevels_GetisHigh(eq) then
                        EqualLevels_SetisClaimed(eq, SafeGreater(source.high:tick(period), EqualLevels_Getprice(eq)));
                    end
                    if EqualLevels_GetisLow(eq) then
                        EqualLevels_SetisClaimed(eq, SafeLess(source.low:tick(period), EqualLevels_Getprice(eq)));
                    end
                    if EqualLevels_GetisClaimed(eq) then
                        EqualLevels_Setclaimed_time(eq, time:tick(period));
                        vars["EQ_claimed"]:Get():Unshift(eq);
                        if SafeGreater(vars["EQ_claimed"]:Get():Size(), Settings_GetEQ_max_claimed(vars["Trend_Settings"])) then
                            local_vars["t"] = Array:Pop(vars["EQ_claimed"]:Get());
                            Line:Delete(EqualLevels_Getline_eq(local_vars["t"]));
                            Line:Delete(EqualLevels_Getline_link(local_vars["t"]));
                            Box:Delete(EqualLevels_Getbox_link(local_vars["t"]));
                        end
                    end
                    if not (EqualLevels_Getline_eq(eq) == nil) then
                        if not (EqualLevels_GetisClaimed(eq)) then
                            Line:SetX2(EqualLevels_Getline_eq(eq), SafePlus(time:tick(period), SafeMultiply((SafeMinus(time:tick(period), time:tick(period - 1))), Settings_Getextend(MarketStructure_Getsettings(MS)))));
                        else
                            Line:SetX2(EqualLevels_Getline_eq(eq), time:tick(period));
                            Line:SetStyle(EqualLevels_Getline_eq(eq), local_vars["LineStyleFunc48"].GetValue(vars["helper"], Settings_GetEQ_claimed_style(vars["Trend_Settings"]), period, mode));
                        end
                    end
                end
            end
            return local_vars["claimed"];
        end
    };
end
function Create_DrawLiquidity()
    local local_vars = {};
    time = instance:addInternalStream(0, 0);
    local_vars["LineStyleFunc51"] = Create_LineStyle();
    local_vars["LineStyleFunc52"] = Create_LineStyle();
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(MS, pivot, period, mode)
            if firstCall then
                firstCall = false;
        time[period] = source:date(period) * 86400000;
                local_vars["LineStyleFunc51"].Clear();
                local_vars["LineStyleFunc52"].Clear();
            else
        time[period] = source:date(period) * 86400000;
            end
            local_vars["liquidity_open_color"] = Triary(Pivot_GetisLT(pivot) and Settings_GetLT_liquidity_show(MarketStructure_Getsettings(MS)), Settings_GetLT_liquidity_open_color(MarketStructure_Getsettings(MS)), Triary(Pivot_GetisIT(pivot) and Settings_GetIT_liquidity_show(MarketStructure_Getsettings(MS)), Settings_GetIT_liquidity_open_color(MarketStructure_Getsettings(MS)), Settings_GetST_liquidity_open_color(MarketStructure_Getsettings(MS))));
            local_vars["liquidity_claimed_color"] = Triary(Pivot_GetisLT(pivot) and Settings_GetLT_liquidity_show(MarketStructure_Getsettings(MS)), Settings_GetLT_liquidity_claimed_color(MarketStructure_Getsettings(MS)), Triary(Pivot_GetisIT(pivot) and Settings_GetIT_liquidity_show(MarketStructure_Getsettings(MS)), Settings_GetIT_liquidity_claimed_color(MarketStructure_Getsettings(MS)), Settings_GetST_liquidity_claimed_color(MarketStructure_Getsettings(MS))));
            local_vars["liquidity_size"] = Triary(Pivot_GetisLT(pivot) and Settings_GetLT_liquidity_show(MarketStructure_Getsettings(MS)), Settings_GetLT_liquidity_size(MarketStructure_Getsettings(MS)), Triary(Pivot_GetisIT(pivot) and Settings_GetIT_liquidity_show(MarketStructure_Getsettings(MS)), Settings_GetIT_liquidity_size(MarketStructure_Getsettings(MS)), Settings_GetST_liquidity_size(MarketStructure_Getsettings(MS))));
            if ((Settings_GetST_liquidity_show(MarketStructure_Getsettings(MS)) or Settings_GetIT_liquidity_show(MarketStructure_Getsettings(MS)) and Pivot_GetisIT(pivot)) or Settings_GetLT_liquidity_show(MarketStructure_Getsettings(MS)) and Pivot_GetisLT(pivot)) then
                if Pivot_Getln(pivot) == nil then
                    Pivot_Setln(pivot, Line:New(Pivot_Gettime(pivot), Pivot_Getprice(pivot), Triary(Pivot_Getclaimed(pivot), Pivot_Gettime_last(pivot), SafePlus(time:tick(period), SafeMultiply((SafeMinus(time:tick(period), time:tick(period - 1))), Settings_Getextend(MarketStructure_Getsettings(MS))))), Pivot_Getprice(pivot)):SetColor(Triary(Pivot_Getclaimed(pivot), local_vars["liquidity_claimed_color"], local_vars["liquidity_open_color"])):SetStyle(local_vars["LineStyleFunc51"].GetValue(vars["helper"], Triary(Pivot_Getclaimed(pivot), Settings_Getliquidity_claimed_style(MarketStructure_Getsettings(MS)), Settings_Getliquidity_open_style(MarketStructure_Getsettings(MS))), period, mode)):SetWidth(local_vars["liquidity_size"]):SetXLoc(Pivot_Gettime(pivot), Triary(Pivot_Getclaimed(pivot), Pivot_Gettime_last(pivot), SafePlus(time:tick(period), SafeMultiply((SafeMinus(time:tick(period), time:tick(period - 1))), Settings_Getextend(MarketStructure_Getsettings(MS))))), "bar_time"));
                else
                    Line:SetColor(Pivot_Getln(pivot), Triary(Pivot_Getclaimed(pivot), local_vars["liquidity_claimed_color"], local_vars["liquidity_open_color"]));
                    Line:SetWidth(Pivot_Getln(pivot), local_vars["liquidity_size"]);
                    Line:SetX2(Pivot_Getln(pivot), Triary(Pivot_Getclaimed(pivot), Pivot_Gettime_last(pivot), SafePlus(time:tick(period), SafeMultiply((SafeMinus(time:tick(period), time:tick(period - 1))), Settings_Getextend(MarketStructure_Getsettings(MS))))));
                    Line:SetStyle(Pivot_Getln(pivot), local_vars["LineStyleFunc52"].GetValue(vars["helper"], Triary(Pivot_Getclaimed(pivot), Settings_Getliquidity_claimed_style(MarketStructure_Getsettings(MS)), Settings_Getliquidity_open_style(MarketStructure_Getsettings(MS))), period, mode));
                end
            end
            return MS;
        end
    };
end
function Create_getLabel()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(pivot, period, mode)
            local_vars["lbl"] = "";
            if Settings_GetST_show(vars["Trend_Settings"]) and Pivot_GetisST(pivot) and ((not (Pivot_GetisIT(pivot)) or not (Settings_GetIT_show(vars["Trend_Settings"])))) and ((not (Pivot_GetisLT(pivot)) or not (Settings_GetLT_show(vars["Trend_Settings"])))) then
                if "S/I/L Term" then
                    local_vars["lbl"] = SafeConcat(local_vars["lbl"], "ST");
                    local_vars["lbl"] = SafeConcat(local_vars["lbl"], (Triary(Pivot_GetisHigh(pivot), "H", "L")));
                elseif "High/Low" then
                    local_vars["lbl"] = SafeConcat(local_vars["lbl"], "ST");
                    local_vars["lbl"] = SafeConcat(local_vars["lbl"], (Triary(Pivot_GetisHigh(pivot), Triary(Pivot_GetisSHigherHigh(pivot), "-HH", "-LH"), Triary(Pivot_GetisSLowerLow(pivot), "-LL", "-HL"))));
                else
                    if (Str:Length(Settings_GetST_label(vars["Trend_Settings"])) == 1) then
                        local_vars["lbl"] = Settings_GetST_label(vars["Trend_Settings"]);
                    else
                        local_vars["symb"] = Str:Split(Settings_GetST_label(vars["Trend_Settings"]), "");
                        local_vars["lbl"] = SafeConcat(local_vars["lbl"], (Triary(Pivot_GetisHigh(pivot), Array:Get(local_vars["symb"], 1), Array:Get(local_vars["symb"], 0))));
                    end
                end
            end
            if Settings_GetIT_show(vars["Trend_Settings"]) and Pivot_GetisIT(pivot) and ((not (Pivot_GetisLT(pivot)) or not (Settings_GetLT_show(vars["Trend_Settings"])))) then
                if "S/I/L Term" then
                    local_vars["lbl"] = SafeConcat(local_vars["lbl"], "IT");
                    local_vars["lbl"] = SafeConcat(local_vars["lbl"], (Triary(Pivot_GetisHigh(pivot), "H", "L")));
                elseif "High/Low" then
                    local_vars["lbl"] = SafeConcat(local_vars["lbl"], "IT");
                    local_vars["lbl"] = SafeConcat(local_vars["lbl"], (Triary(Pivot_GetisHigh(pivot), Triary(Pivot_GetisIHigherHigh(pivot), "-HH", "-LH"), Triary(Pivot_GetisILowerLow(pivot), "-LL", "-HL"))));
                else
                    if (Str:Length(Settings_GetIT_label(vars["Trend_Settings"])) == 1) then
                        local_vars["lbl"] = Settings_GetIT_label(vars["Trend_Settings"]);
                    else
                        local_vars["symb"] = Str:Split(Settings_GetIT_label(vars["Trend_Settings"]), "");
                        local_vars["lbl"] = SafeConcat(local_vars["lbl"], (Triary(Pivot_GetisHigh(pivot), Array:Get(local_vars["symb"], 1), Array:Get(local_vars["symb"], 0))));
                    end
                end
            end
            if Settings_GetLT_show(vars["Trend_Settings"]) and Pivot_GetisLT(pivot) then
                if "S/I/L Term" then
                    local_vars["lbl"] = SafeConcat(local_vars["lbl"], "LT");
                    local_vars["lbl"] = SafeConcat(local_vars["lbl"], (Triary(Pivot_GetisHigh(pivot), "H", "L")));
                elseif "High/Low" then
                    local_vars["lbl"] = SafeConcat(local_vars["lbl"], "LT");
                    local_vars["lbl"] = SafeConcat(local_vars["lbl"], (Triary(Pivot_GetisHigh(pivot), Triary(Pivot_GetisLHigherHigh(pivot), "-HH", "-LH"), Triary(Pivot_GetisLLowerLow(pivot), "-LL", "-HL"))));
                else
                    if (Str:Length(Settings_GetLT_label(vars["Trend_Settings"])) == 1) then
                        local_vars["lbl"] = Settings_GetLT_label(vars["Trend_Settings"]);
                    else
                        local_vars["symb"] = Str:Split(Settings_GetLT_label(vars["Trend_Settings"]), "");
                        local_vars["lbl"] = SafeConcat(local_vars["lbl"], (Triary(Pivot_GetisHigh(pivot), Array:Get(local_vars["symb"], 1), Array:Get(local_vars["symb"], 0))));
                    end
                end
            end
            return local_vars["lbl"];
        end
    };
end
function Create_getLabelSettings()
    local local_vars = {};
    local_vars["getLabelFunc55"] = Create_getLabel();
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(MS, pivot, period, mode)
            if firstCall then
                firstCall = false;
                local_vars["getLabelFunc55"].Clear();
            else
            end
            local_vars["lbl_color"] = nil;
            local_vars["lbl_text_size"] = nil;
            local_vars["txt_color"] = nil;
            local_vars["lbl_style"] = nil;
            if Settings_GetST_show(MarketStructure_Getsettings(MS)) then
                local_vars["lbl_color"] = Settings_GetST_label_color(MarketStructure_Getsettings(MS));
                local_vars["lbl_text_size"] = Settings_GetST_text_size(MarketStructure_Getsettings(MS));
                local_vars["txt_color"] = Triary(Pivot_GetisHigh(pivot), Settings_GetST_color_bull(MarketStructure_Getsettings(MS)), Settings_GetST_color_bear(MarketStructure_Getsettings(MS)));
            end
            if Settings_GetIT_show(MarketStructure_Getsettings(MS)) then
                if Pivot_GetisIT(pivot) then
                    local_vars["lbl_color"] = Settings_GetIT_label_color(MarketStructure_Getsettings(MS));
                    local_vars["lbl_text_size"] = Settings_GetIT_text_size(MarketStructure_Getsettings(MS));
                    local_vars["txt_color"] = Triary(Pivot_GetisHigh(pivot), Settings_GetIT_color_bull(MarketStructure_Getsettings(MS)), Settings_GetIT_color_bear(MarketStructure_Getsettings(MS)));
                end
            end
            if Settings_GetLT_show(MarketStructure_Getsettings(MS)) then
                if Pivot_GetisLT(pivot) then
                    local_vars["lbl_color"] = Settings_GetLT_label_color(MarketStructure_Getsettings(MS));
                    local_vars["lbl_text_size"] = Settings_GetLT_text_size(MarketStructure_Getsettings(MS));
                    local_vars["txt_color"] = Triary(Pivot_GetisHigh(pivot), Settings_GetLT_color_bull(MarketStructure_Getsettings(MS)), Settings_GetLT_color_bear(MarketStructure_Getsettings(MS)));
                end
            end
            if ((Settings_GetST_show(MarketStructure_Getsettings(MS)) or Settings_GetIT_show(MarketStructure_Getsettings(MS))) or Settings_GetLT_show(MarketStructure_Getsettings(MS))) then
                local_vars["lbl_style"] = Triary(Pivot_GetisHigh(pivot), "down", "up");
            end
            return local_vars["lbl_color"], local_vars["lbl_text_size"], local_vars["txt_color"], local_vars["lbl_style"], local_vars["getLabelFunc55"].GetValue(pivot, period, mode);
        end
    };
end
function Create_DrawLabel()
    local local_vars = {};
    local_vars["getLabelSettingsFunc54"] = Create_getLabelSettings();
    Label:Prepare(500);
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(MS, pivot, period, mode)
            if firstCall then
                firstCall = false;
                local_vars["getLabelSettingsFunc54"].Clear();
            else
            end
            lbl_color_ret_val, lbl_text_size_ret_val, txt_color_ret_val, lbl_style_ret_val, lbl_ret_val = local_vars["getLabelSettingsFunc54"].GetValue(MS, pivot, period, mode);
            local_vars["lbl_color"] = lbl_color_ret_val;
            local_vars["lbl_text_size"] = lbl_text_size_ret_val;
            local_vars["txt_color"] = txt_color_ret_val;
            local_vars["lbl_style"] = lbl_style_ret_val;
            local_vars["lbl"] = lbl_ret_val;
            if Pivot_Getlbl(pivot) == nil then
                label_1_x = Pivot_Gettime(pivot);
                Pivot_Setlbl(pivot, Label:New(core.formatDate(Label:GetSerial(label_1_x, source, "bar_time") or 0) .. "_1", "1", label_1_x, Pivot_Getprice(pivot)):SetText(local_vars["lbl"]):SetColor(local_vars["lbl_color"]):SetTextColor(local_vars["txt_color"]):SetStyle(local_vars["lbl_style"]):SetSize(local_vars["lbl_text_size"]):SetXLoc("bar_time"));
            else
                Label:SetStyle(Pivot_Getlbl(pivot), local_vars["lbl_style"]);
                Label:SetColor(Pivot_Getlbl(pivot), local_vars["lbl_color"]);
                Label:SetSize(Pivot_Getlbl(pivot), local_vars["lbl_text_size"]);
                Label:SetTextColor(Pivot_Getlbl(pivot), local_vars["txt_color"]);
                Label:SetText(Pivot_Getlbl(pivot), local_vars["lbl"]);
            end
            return MS;
        end
    };
end
function Create_renderMS()
    local local_vars = {};
    local_vars["DrawLiquidityFunc50"] = Create_DrawLiquidity();
    local_vars["DrawLabelFunc53"] = Create_DrawLabel();
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(MS, period, mode)
            if firstCall then
                firstCall = false;
                local_vars["DrawLiquidityFunc50"].Clear();
                local_vars["DrawLabelFunc53"].Clear();
            else
            end
            local_vars["add"] = 0;
            local_vars["claim"] = 0;
            for _, pivot in ipairs(Array:Enum(MarketStructure_GetST(MS))) do
                if (Pivot_Getclaimed(pivot) and SafeLess(local_vars["claim"], Settings_Getmax_claimed_lines(MarketStructure_Getsettings(MS))) or not (Pivot_Getclaimed(pivot)) and SafeLess(local_vars["add"], Settings_Getmax_lines(MarketStructure_Getsettings(MS)))) then
                    local_vars["DrawLiquidityFunc50"].GetValue(MS, pivot, period, mode);
                    if Pivot_Getclaimed(pivot) then
                        local_vars["claim"] = local_vars["claim"] + 1;
                    else
                        local_vars["add"] = local_vars["add"] + 1;
                    end
                end
                if (local_vars["claim"] == Settings_Getmax_claimed_lines(MarketStructure_Getsettings(MS))) and (local_vars["add"] == Settings_Getmax_lines(MarketStructure_Getsettings(MS))) then
                    break;
                end
            end
            local_vars["add"] = 0;
            for _, pivot in ipairs(Array:Enum(MarketStructure_GetST(MS))) do
                if ((Settings_GetST_show(MarketStructure_Getsettings(MS)) or Settings_GetIT_show(MarketStructure_Getsettings(MS)) and Pivot_GetisIT(pivot)) or Settings_GetLT_show(MarketStructure_Getsettings(MS)) and Pivot_GetisLT(pivot) and SafeLess(local_vars["add"], Settings_Getmax_labels(MarketStructure_Getsettings(MS)))) then
                    local_vars["DrawLabelFunc53"].GetValue(MS, pivot, period, mode);
                    local_vars["add"] = local_vars["add"] + 1;
                end
                if (local_vars["add"] == Settings_Getmax_labels(MarketStructure_Getsettings(MS))) then
                    break;
                end
            end
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
    vars["!1"] = instance.parameters.param1;
    vars["!2"] = instance.parameters.param2;
    vars["!3"] = instance.parameters.param3;
    vars["!4"] = Graphics:AddTransparency(instance.parameters.param4, Graphics:GetTransparencyPercent(core.rgb(255, 255, 0)));
    vars["!5"] = instance.parameters.param5;
    vars["!6"] = Graphics:AddTransparency(instance.parameters.param6, Graphics:GetTransparencyPercent(core.colors().Purple + math.floor(0 / 100 * 255) * 16777216));
    vars["!7"] = Graphics:AddTransparency(instance.parameters.param7, Graphics:GetTransparencyPercent(core.colors().Purple + math.floor(0 / 100 * 255) * 16777216));
    vars["!8"] = Graphics:AddTransparency(instance.parameters.param8, Graphics:GetTransparencyPercent(core.rgb(255, 255, 0)));
    vars["!9"] = instance.parameters.param9;
    vars["!10"] = Graphics:AddTransparency(instance.parameters.param10, Graphics:GetTransparencyPercent(core.colors().Blue + math.floor(0 / 100 * 255) * 16777216));
    vars["!11"] = Graphics:AddTransparency(instance.parameters.param11, Graphics:GetTransparencyPercent(core.colors().Blue + math.floor(0 / 100 * 255) * 16777216));
    vars["!12"] = Graphics:AddTransparency(instance.parameters.param12, Graphics:GetTransparencyPercent(core.rgb(255, 255, 0)));
    vars["!13"] = instance.parameters.param13;
    vars["!14"] = instance.parameters.param14;
    vars["!15"] = instance.parameters.param15;
    vars["!16"] = instance.parameters.param16;
    vars["!17"] = instance.parameters.param17;
    vars["!18"] = instance.parameters.param18;
    vars["!19"] = instance.parameters.param19;
    vars["!20"] = instance.parameters.param20;
    vars["!21"] = Graphics:AddTransparency(instance.parameters.param21, Graphics:GetTransparencyPercent(core.colors().Black + math.floor(50 / 100 * 255) * 16777216));
    vars["!22"] = Graphics:AddTransparency(instance.parameters.param22, Graphics:GetTransparencyPercent(core.colors().Black + math.floor(50 / 100 * 255) * 16777216));
    vars["!23"] = instance.parameters.param23;
    vars["!24"] = instance.parameters.param24;
    vars["!25"] = Graphics:AddTransparency(instance.parameters.param25, Graphics:GetTransparencyPercent(core.colors().Purple + math.floor(50 / 100 * 255) * 16777216));
    vars["!26"] = Graphics:AddTransparency(instance.parameters.param26, Graphics:GetTransparencyPercent(core.colors().Purple + math.floor(50 / 100 * 255) * 16777216));
    vars["!27"] = instance.parameters.param27;
    vars["!28"] = instance.parameters.param28;
    vars["!29"] = Graphics:AddTransparency(instance.parameters.param29, Graphics:GetTransparencyPercent(core.colors().Blue + math.floor(50 / 100 * 255) * 16777216));
    vars["!30"] = Graphics:AddTransparency(instance.parameters.param30, Graphics:GetTransparencyPercent(core.colors().Blue + math.floor(50 / 100 * 255) * 16777216));
    vars["!31"] = instance.parameters.param31;
    vars["!32"] = instance.parameters.param32;
    vars["!33"] = instance.parameters.param33;
    vars["!34"] = instance.parameters.param34;
    vars["!35"] = instance.parameters.param35;
    vars["!36"] = instance.parameters.param36;
    vars["!37"] = instance.parameters.param37;
    vars["!38"] = Graphics:AddTransparency(instance.parameters.param38, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(67, 70, 81), 0)));
    vars["!39"] = Graphics:AddTransparency(instance.parameters.param39, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(67, 70, 81), 0)));
    vars["!40"] = instance.parameters.param40;
    vars["!41"] = instance.parameters.param41;
    vars["!42"] = instance.parameters.param42;
    vars["!43"] = instance.parameters.param43;
    vars["!44"] = instance.parameters.param44;
    vars["!45"] = instance.parameters.param45;
    vars["!46"] = instance.parameters.param46;
    vars["!47"] = Graphics:AddTransparency(instance.parameters.param47, Graphics:GetTransparencyPercent(core.colors().Blue + math.floor(90 / 100 * 255) * 16777216));
    vars["!48"] = Graphics:AddTransparency(instance.parameters.param48, Graphics:GetTransparencyPercent(core.colors().Orange + math.floor(90 / 100 * 255) * 16777216));
    vars["!49"] = instance.parameters.param49;
    vars["!50"] = instance.parameters.param51;
    vars["!51"] = instance.parameters.param52;
    vars["!52"] = instance.parameters.param53;
    vars["!53"] = Graphics:AddTransparency(instance.parameters.param54, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(186, 227, 197), 0)));
    vars["!54"] = Graphics:AddTransparency(instance.parameters.param55, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(255, 194, 194), 0)));
    vars["!55"] = instance.parameters.param56;
    vars["!56"] = instance.parameters.param57;
    vars["!57"] = instance.parameters.param58;
    vars["!58"] = instance.parameters.param59;
    vars["!59"] = Graphics:AddTransparency(instance.parameters.param60, Graphics:GetTransparencyPercent(core.rgb(56, 142, 60) + math.floor(0 / 100 * 255) * 16777216));
    vars["!60"] = Graphics:AddTransparency(instance.parameters.param61, Graphics:GetTransparencyPercent(core.rgb(24, 72, 204) + math.floor(0 / 100 * 255) * 16777216));
    vars["!61"] = instance.parameters.param62;
    vars["!62"] = Graphics:AddTransparency(instance.parameters.param63, Graphics:GetTransparencyPercent(core.colors().Purple + math.floor(0 / 100 * 255) * 16777216));
    vars["!63"] = Graphics:AddTransparency(instance.parameters.param64, Graphics:GetTransparencyPercent(core.colors().Orange + math.floor(0 / 100 * 255) * 16777216));
    vars["!64"] = instance.parameters.param65;
    vars["!65"] = instance.parameters.param66;
    vars["!66"] = Graphics:AddTransparency(instance.parameters.param67, Graphics:GetTransparencyPercent(core.colors().Gray + math.floor(95 / 100 * 255) * 16777216));
    vars["!67"] = Graphics:AddTransparency(instance.parameters.param68, Graphics:GetTransparencyPercent(core.colors().Gray + math.floor(95 / 100 * 255) * 16777216));
    vars["!68"] = instance.parameters.param69;
    vars["!69"] = instance.parameters.param70;
    vars["!70"] = instance.parameters.param71;
    vars["!71"] = instance.parameters.param72;
    vars["!72"] = instance.parameters.param73;
    vars["!73"] = instance.parameters.param74;
    vars["!74"] = instance.parameters.param75;
    vars["!75"] = instance.parameters.param76;
    vars["!76"] = Graphics:AddTransparency(instance.parameters.param77, Graphics:GetTransparencyPercent(core.colors().Black + math.floor(60 / 100 * 255) * 16777216));
    vars["!77"] = Graphics:AddTransparency(instance.parameters.param78, Graphics:GetTransparencyPercent(core.colors().Black + math.floor(60 / 100 * 255) * 16777216));
    vars["!78"] = instance.parameters.param79;
    vars["!79"] = instance.parameters.param80;
    vars["!80"] = instance.parameters.param81;
    vars["!81"] = instance.parameters.param82;
    vars["!82"] = instance.parameters.param83;
    vars["!83"] = instance.parameters.param84;
    vars["!84"] = instance.parameters.param85;
    vars["!85"] = instance.parameters.param86;
    vars["!86"] = instance.parameters.param87;
    vars["!87"] = instance.parameters.param88;
    vars["!88"] = instance.parameters.param89;
    vars["!89"] = instance.parameters.param92;
    vars["!90"] = Graphics:AddTransparency(instance.parameters.param93, Graphics:GetTransparencyPercent(core.colors().Red + math.floor(95 / 100 * 255) * 16777216));
    vars["!91"] = Graphics:AddTransparency(instance.parameters.param94, Graphics:GetTransparencyPercent(core.colors().Red + math.floor(95 / 100 * 255) * 16777216));
    vars["!92"] = instance.parameters.param95;
    vars["!93"] = instance.parameters.param96;
    vars["!94"] = instance.parameters.param97;
    vars["!95"] = instance.parameters.param98;
    vars["!96"] = instance.parameters.param101;
    vars["!97"] = instance.parameters.param102;
    vars["!98"] = instance.parameters.param103;
    vars["Term"] = Variable:Create();
    vars["ST_array"] = Variable:Create();
    vars["IT_array"] = Variable:Create();
    vars["LT_array"] = Variable:Create();
    vars["STH_array"] = Variable:Create();
    vars["ITH_array"] = Variable:Create();
    vars["LTH_array"] = Variable:Create();
    vars["STL_array"] = Variable:Create();
    vars["ITL_array"] = Variable:Create();
    vars["LTL_array"] = Variable:Create();
    vars["FVGs"] = Variable:Create();
    vars["imbalance_array"] = Variable:Create();
    vars["iFVGs"] = Variable:Create();
    vars["iimbalance_array"] = Variable:Create();
    vars["VI"] = Variable:Create();
    vars["VI_array"] = Variable:Create();
    vars["Gaps"] = Variable:Create();
    vars["Gap_array"] = Variable:Create();
    vars["EQs"] = Variable:Create();
    vars["labels"] = Variable:Create();
    vars["EQ_claimed"] = Variable:Create();
    vars["tester"] = Variable:Create();
    Line:Prepare(500);
    vars["stdev_1"] = instance:addInternalStream(0, 0);
    vars["median"] = Variable:Create();
    vars["ATR1"] = core.indicators:create("ATR", source, vars["length"]);
    vars["f_highlightDisplacementFunc1"] = Create_f_highlightDisplacement();
    plot1_open = instance:addStream("plot1_open", core.Line, "Open", "Open", core.colors().Black, 0, (-(-1)));
    plot1_high = instance:addStream("plot1_high", core.Line, "High", "High", core.colors().Black, 0, (-(-1)));
    plot1_low = instance:addStream("plot1_low", core.Line, "Low", "Low", core.colors().Black, 0, (-(-1)));
    plot1_close = instance:addStream("plot1_close", core.Line, "Close", "Close", core.colors().Black, 0, (-(-1)));
    instance:createCandleGroup("plot1", "plot1", plot1_open, plot1_high, plot1_low, plot1_close);
    vars["f_highlightDisplacementFunc2"] = Create_f_highlightDisplacement();
    plot2_open = instance:addStream("plot2_open", core.Line, "Open", "Open", core.colors().Black, 0, SafeNegative(nil));
    plot2_high = instance:addStream("plot2_high", core.Line, "High", "High", core.colors().Black, 0, SafeNegative(nil));
    plot2_low = instance:addStream("plot2_low", core.Line, "Low", "Low", core.colors().Black, 0, SafeNegative(nil));
    plot2_close = instance:addStream("plot2_close", core.Line, "Close", "Close", core.colors().Black, 0, SafeNegative(nil));
    instance:createCandleGroup("plot2", "plot2", plot2_open, plot2_high, plot2_low, plot2_close);
    vars["f_highlightDisplacementFunc3"] = Create_f_highlightDisplacement();
    vars["FindImbalanceFunc4"] = Create_FindImbalance();
    vars["FindImbalanceFunc13"] = Create_FindImbalance();
    vars["FindImbalanceFunc14"] = Create_FindImbalance();
    vars["CheckMitigatedFunc15"] = Create_CheckMitigated();
    vars["CheckMitigatedFunc18"] = Create_CheckMitigated();
    vars["CheckMitigatedFunc19"] = Create_CheckMitigated();
    vars["CheckMitigatedFunc20"] = Create_CheckMitigated();
    vars["renderFunc21"] = Create_render();
    vars["renderFunc27"] = Create_render();
    vars["renderFunc28"] = Create_render();
    vars["renderFunc29"] = Create_render();
    vars["FindLTFunc30"] = Create_FindLT();
    vars["FindITFunc32"] = Create_FindIT();
    vars["FindSTFunc35"] = Create_FindST();
    vars["CheckClaimedFunc47"] = Create_CheckClaimed();
    vars["renderMSFunc49"] = Create_renderMS();
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Line:Clear();
        Linefill:Clear();
        Box:Clear();
        Label:Clear();
        vars["Term"]:Clear();
        vars["ST_array"]:Clear();
        vars["IT_array"]:Clear();
        vars["LT_array"]:Clear();
        vars["STH_array"]:Clear();
        vars["ITH_array"]:Clear();
        vars["LTH_array"]:Clear();
        vars["STL_array"]:Clear();
        vars["ITL_array"]:Clear();
        vars["LTL_array"]:Clear();
        vars["FVGs"]:Clear();
        vars["imbalance_array"]:Clear();
        vars["iFVGs"]:Clear();
        vars["iimbalance_array"]:Clear();
        vars["VI"]:Clear();
        vars["VI_array"]:Clear();
        vars["Gaps"]:Clear();
        vars["Gap_array"]:Clear();
        vars["EQs"]:Clear();
        vars["labels"]:Clear();
        vars["EQ_claimed"]:Clear();
        vars["tester"]:Clear();
        vars["median"]:Clear();
        vars["f_highlightDisplacementFunc1"].Clear();
        vars["f_highlightDisplacementFunc2"].Clear();
        vars["f_highlightDisplacementFunc3"].Clear();
        vars["FindImbalanceFunc4"].Clear();
        vars["FindImbalanceFunc13"].Clear();
        vars["FindImbalanceFunc14"].Clear();
        vars["CheckMitigatedFunc15"].Clear();
        vars["CheckMitigatedFunc18"].Clear();
        vars["CheckMitigatedFunc19"].Clear();
        vars["CheckMitigatedFunc20"].Clear();
        vars["renderFunc21"].Clear();
        vars["renderFunc27"].Clear();
        vars["renderFunc28"].Clear();
        vars["renderFunc29"].Clear();
        vars["FindSTFunc35"].Clear();
        vars["FindITFunc32"].Clear();
        vars["FindLTFunc30"].Clear();
        vars["CheckClaimedFunc47"].Clear();
        vars["renderMSFunc49"].Clear();
    else
    end
    vars["MAX_BUFFER"] = 1000;
    vars["ICT_Group"] = "ICT Market Structure ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
    vars["ICT_Labelas"] = "Label Format ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
    vars["settings_liquidity"] = "Liquidity Levels ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
    vars["settings_liquidity_style"] = "Liquidity Style ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
    vars["settings_eq"] = "Relative Equal Highs and Lows ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
    vars["settings_displacement"] = "Displacement ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
    vars["FVG_Group"] = "Fair Value Gap ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
    vars["FVG_HP_Group"] = "For High Probability Fair Value Gap ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
    vars["Imb_Group"] = "Volume Imbalance ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
    vars["Gap_Group"] = "Open Gaps ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━";
    vars["inline_st"] = "ST";
    vars["inline_st_liquidity"] = "ST liquidity";
    vars["inline_it"] = "IT";
    vars["inline_it_liquidity"] = "IT liquidity";
    vars["inline_lt"] = "LT";
    vars["inline_lt_liquidity"] = "LT liquidity";
    vars["inline_liquidity_open"] = "open liquidity";
    vars["inline_liquidity_claimed"] = "claimed liquidity";
    vars["inline_eq"] = "EQ";
    vars["inline_eq_link"] = "EQ Link";
    vars["inline_eq_shade"] = "EQ Shade";
    vars["inline_displacement"] = "displacement";
    vars["Trend_Settings"] = CreateType_Settings(period);
    vars["FVG_Settings"] = CreateType_Imbalance_Settings(period);
    vars["iFVG_Settings"] = CreateType_Imbalance_Settings(period);
    vars["VI_Settings"] = CreateType_Imbalance_Settings(period);
    vars["Gap_Settings"] = CreateType_Imbalance_Settings(period);
    Settings_SetST_show(vars["Trend_Settings"], vars["!1"]);
    Settings_SetST_color_bull(vars["Trend_Settings"], vars["!2"]);
    Settings_SetST_color_bear(vars["Trend_Settings"], vars["!3"]);
    Settings_SetST_label_color(vars["Trend_Settings"], vars["!4"]);
    Settings_SetIT_show(vars["Trend_Settings"], vars["!5"]);
    Settings_SetIT_color_bull(vars["Trend_Settings"], vars["!6"]);
    Settings_SetIT_color_bear(vars["Trend_Settings"], vars["!7"]);
    Settings_SetIT_label_color(vars["Trend_Settings"], vars["!8"]);
    Settings_SetLT_show(vars["Trend_Settings"], vars["!9"]);
    Settings_SetLT_color_bull(vars["Trend_Settings"], vars["!10"]);
    Settings_SetLT_color_bear(vars["Trend_Settings"], vars["!11"]);
    Settings_SetLT_label_color(vars["Trend_Settings"], vars["!12"]);
    Settings_SetST_label(vars["Trend_Settings"], vars["!13"]);
    Settings_SetST_text_size(vars["Trend_Settings"], vars["!14"]);
    Settings_SetIT_label(vars["Trend_Settings"], vars["!15"]);
    Settings_SetIT_text_size(vars["Trend_Settings"], vars["!16"]);
    Settings_SetLT_label(vars["Trend_Settings"], vars["!17"]);
    Settings_SetLT_text_size(vars["Trend_Settings"], vars["!18"]);
    Settings_Setmax_labels(vars["Trend_Settings"], vars["!19"]);
    Settings_SetST_liquidity_show(vars["Trend_Settings"], vars["!20"]);
    Settings_SetST_liquidity_open_color(vars["Trend_Settings"], vars["!21"]);
    Settings_SetST_liquidity_claimed_color(vars["Trend_Settings"], vars["!22"]);
    Settings_SetST_liquidity_size(vars["Trend_Settings"], vars["!23"]);
    Settings_SetIT_liquidity_show(vars["Trend_Settings"], vars["!24"]);
    Settings_SetIT_liquidity_open_color(vars["Trend_Settings"], vars["!25"]);
    Settings_SetIT_liquidity_claimed_color(vars["Trend_Settings"], vars["!26"]);
    Settings_SetIT_liquidity_size(vars["Trend_Settings"], vars["!27"]);
    Settings_SetLT_liquidity_show(vars["Trend_Settings"], vars["!28"]);
    Settings_SetLT_liquidity_open_color(vars["Trend_Settings"], vars["!29"]);
    Settings_SetLT_liquidity_claimed_color(vars["Trend_Settings"], vars["!30"]);
    Settings_SetLT_liquidity_size(vars["Trend_Settings"], vars["!31"]);
    Settings_Setliquidity_open_style(vars["Trend_Settings"], vars["!32"]);
    Settings_Setliquidity_claimed_style(vars["Trend_Settings"], vars["!33"]);
    Settings_Setextend(vars["Trend_Settings"], vars["!34"]);
    Settings_Setmax_lines(vars["Trend_Settings"], vars["!35"]);
    Settings_Setmax_claimed_lines(vars["Trend_Settings"], vars["!36"]);
    Settings_SetEQ_show(vars["Trend_Settings"], vars["!37"]);
    Settings_SetEQ_color_bull(vars["Trend_Settings"], vars["!38"]);
    Settings_SetEQ_color_bear(vars["Trend_Settings"], vars["!39"]);
    Settings_SetEQ_size(vars["Trend_Settings"], vars["!40"]);
    Settings_SetEQ_style(vars["Trend_Settings"], vars["!41"]);
    Settings_SetEQ_link_show(vars["Trend_Settings"], vars["!42"]);
    Settings_SetEQ_link_color(vars["Trend_Settings"], vars["!43"]);
    Settings_SetEQ_link_size(vars["Trend_Settings"], vars["!44"]);
    Settings_SetEQ_link_style(vars["Trend_Settings"], vars["!45"]);
    Settings_SetEQ_shade(vars["Trend_Settings"], vars["!46"]);
    Settings_SetEQ_shade_bull(vars["Trend_Settings"], vars["!47"]);
    Settings_SetEQ_shade_bear(vars["Trend_Settings"], vars["!48"]);
    Settings_SetEQ_claimed_style(vars["Trend_Settings"], vars["!49"]);
    Settings_SetEQ_Tolerance(vars["Trend_Settings"], instance.parameters.param50 / 10);
    Settings_SetEQ_max(vars["Trend_Settings"], vars["!50"]);
    Settings_SetEQ_max_claimed(vars["Trend_Settings"], vars["!51"]);
    Settings_Setdisplacement_show(vars["Trend_Settings"], vars["!52"]);
    Settings_Setdisplacement_bull(vars["Trend_Settings"], vars["!53"]);
    Settings_Setdisplacement_bear(vars["Trend_Settings"], vars["!54"]);
    Settings_Setdisplacement_fvg(vars["Trend_Settings"], vars["!55"]);
    Settings_Setdisplacement_length(vars["Trend_Settings"], vars["!56"]);
    Settings_Setdisplacement_factor(vars["Trend_Settings"], vars["!57"]);
    Imbalance_Settings_Setshow(vars["FVG_Settings"], vars["!58"]);
    Imbalance_Settings_Setcolor_bull(vars["FVG_Settings"], vars["!59"]);
    Imbalance_Settings_Setcolor_bear(vars["FVG_Settings"], vars["!60"]);
    Imbalance_Settings_Setshow(vars["iFVG_Settings"], vars["!61"]);
    Imbalance_Settings_Setcolor_bull(vars["iFVG_Settings"], vars["!62"]);
    Imbalance_Settings_Setcolor_bear(vars["iFVG_Settings"], vars["!63"]);
    Imbalance_Settings_Setfvg_type(vars["FVG_Settings"], vars["!64"]);
    Imbalance_Settings_Setmitigated_show(vars["FVG_Settings"], vars["!65"]);
    Imbalance_Settings_Setmitigated_color_bull(vars["FVG_Settings"], vars["!66"]);
    Imbalance_Settings_Setmitigated_color_bear(vars["FVG_Settings"], vars["!67"]);
    Imbalance_Settings_Setmitigated_type(vars["FVG_Settings"], vars["!68"]);
    Imbalance_Settings_Setmitigated_show(vars["iFVG_Settings"], Imbalance_Settings_Getmitigated_show(vars["FVG_Settings"]));
    Imbalance_Settings_Setmitigated_color_bull(vars["iFVG_Settings"], Imbalance_Settings_Getmitigated_color_bull(vars["FVG_Settings"]));
    Imbalance_Settings_Setmitigated_color_bear(vars["iFVG_Settings"], Imbalance_Settings_Getmitigated_color_bear(vars["FVG_Settings"]));
    Imbalance_Settings_Setmitigated_type(vars["iFVG_Settings"], Imbalance_Settings_Getmitigated_type(vars["FVG_Settings"]));
    Imbalance_Settings_Setopen_show(vars["FVG_Settings"], vars["!69"]);
    Imbalance_Settings_Setopen_style(vars["FVG_Settings"], vars["!70"]);
    Imbalance_Settings_Setopen_size(vars["FVG_Settings"], vars["!71"]);
    Imbalance_Settings_Setopen_show(vars["iFVG_Settings"], Imbalance_Settings_Getopen_show(vars["FVG_Settings"]));
    Imbalance_Settings_Setopen_style(vars["iFVG_Settings"], Imbalance_Settings_Getopen_style(vars["FVG_Settings"]));
    Imbalance_Settings_Setopen_size(vars["iFVG_Settings"], Imbalance_Settings_Getopen_size(vars["FVG_Settings"]));
    Imbalance_Settings_Setclose_show(vars["FVG_Settings"], vars["!72"]);
    Imbalance_Settings_Setclose_style(vars["FVG_Settings"], vars["!73"]);
    Imbalance_Settings_Setclose_size(vars["FVG_Settings"], vars["!74"]);
    Imbalance_Settings_Setclose_show(vars["iFVG_Settings"], Imbalance_Settings_Getclose_show(vars["FVG_Settings"]));
    Imbalance_Settings_Setclose_style(vars["iFVG_Settings"], Imbalance_Settings_Getclose_style(vars["FVG_Settings"]));
    Imbalance_Settings_Setclose_size(vars["iFVG_Settings"], Imbalance_Settings_Getclose_size(vars["FVG_Settings"]));
    Imbalance_Settings_SetCE_show(vars["FVG_Settings"], vars["!75"]);
    Imbalance_Settings_SetCE_bull_color(vars["FVG_Settings"], vars["!76"]);
    Imbalance_Settings_SetCE_bear_color(vars["FVG_Settings"], vars["!77"]);
    Imbalance_Settings_SetCE_style(vars["FVG_Settings"], vars["!78"]);
    Imbalance_Settings_SetCE_size(vars["FVG_Settings"], vars["!79"]);
    Imbalance_Settings_Setlink_show(vars["FVG_Settings"], vars["!80"]);
    Imbalance_Settings_Setlink_style(vars["FVG_Settings"], vars["!81"]);
    Imbalance_Settings_Setlink_size(vars["FVG_Settings"], vars["!82"]);
    Imbalance_Settings_Setfill(vars["FVG_Settings"], vars["!83"]);
    Imbalance_Settings_Setfill_percent(vars["FVG_Settings"], vars["!84"]);
    Imbalance_Settings_SetmergeVI(vars["FVG_Settings"], vars["!85"]);
    Imbalance_Settings_Setmax_count(vars["FVG_Settings"], vars["!86"]);
    Imbalance_Settings_Setmax_count(vars["iFVG_Settings"], vars["!87"]);
    Imbalance_Settings_SetCE_show(vars["iFVG_Settings"], Imbalance_Settings_GetCE_show(vars["FVG_Settings"]));
    Imbalance_Settings_SetCE_bull_color(vars["iFVG_Settings"], Imbalance_Settings_GetCE_bull_color(vars["FVG_Settings"]));
    Imbalance_Settings_SetCE_bear_color(vars["iFVG_Settings"], Imbalance_Settings_GetCE_bear_color(vars["FVG_Settings"]));
    Imbalance_Settings_SetCE_style(vars["iFVG_Settings"], Imbalance_Settings_GetCE_style(vars["FVG_Settings"]));
    Imbalance_Settings_Setlink_show(vars["iFVG_Settings"], Imbalance_Settings_Getlink_show(vars["FVG_Settings"]));
    Imbalance_Settings_Setlink_style(vars["iFVG_Settings"], Imbalance_Settings_Getlink_style(vars["FVG_Settings"]));
    Imbalance_Settings_Setlink_size(vars["iFVG_Settings"], Imbalance_Settings_Getlink_size(vars["FVG_Settings"]));
    Imbalance_Settings_Setfill(vars["iFVG_Settings"], Imbalance_Settings_Getfill(vars["FVG_Settings"]));
    Imbalance_Settings_Setfill_percent(vars["iFVG_Settings"], Imbalance_Settings_Getfill_percent(vars["FVG_Settings"]));
    Imbalance_Settings_SetmergeVI(vars["iFVG_Settings"], Imbalance_Settings_GetmergeVI(vars["FVG_Settings"]));
    Imbalance_Settings_Setshow(vars["VI_Settings"], vars["!88"]);
    Imbalance_Settings_Setcolor_bull(vars["VI_Settings"], instance.parameters.param90 + math.floor(100 / 100 * 255) * 16777216);
    Imbalance_Settings_Setcolor_bear(vars["VI_Settings"], instance.parameters.param91 + math.floor(100 / 100 * 255) * 16777216);
    Imbalance_Settings_Setmitigated_show(vars["VI_Settings"], vars["!89"]);
    Imbalance_Settings_Setmitigated_type(vars["VI_Settings"], "Body filled");
    Imbalance_Settings_Setmitigated_color_bull(vars["VI_Settings"], vars["!90"]);
    Imbalance_Settings_Setmitigated_color_bear(vars["VI_Settings"], vars["!91"]);
    Imbalance_Settings_SetCE_show(vars["VI_Settings"], false);
    Imbalance_Settings_Setopen_show(vars["VI_Settings"], false);
    Imbalance_Settings_Setclose_show(vars["VI_Settings"], false);
    Imbalance_Settings_Setfill(vars["VI_Settings"], vars["!92"]);
    Imbalance_Settings_Setfill_percent(vars["VI_Settings"], vars["!93"]);
    Imbalance_Settings_SetmergeVI(vars["VI_Settings"], false);
    Imbalance_Settings_Setmax_count(vars["VI_Settings"], vars["!94"]);
    Imbalance_Settings_Setshow(vars["Gap_Settings"], vars["!95"]);
    Imbalance_Settings_Setcolor_bull(vars["Gap_Settings"], Graphics:AddTransparency(instance.parameters.param99, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(255, 204, 128), 0))) + math.floor(100 / 100 * 255) * 16777216);
    Imbalance_Settings_Setcolor_bear(vars["Gap_Settings"], Graphics:AddTransparency(instance.parameters.param100, Graphics:GetTransparencyPercent(Graphics:AddTransparency(core.rgb(255, 204, 128), 0))) + math.floor(100 / 100 * 255) * 16777216);
    Imbalance_Settings_Setmitigated_show(vars["Gap_Settings"], false);
    Imbalance_Settings_Setmitigated_type(vars["Gap_Settings"], "Body filled");
    Imbalance_Settings_Setmitigated_color_bull(vars["Gap_Settings"], Imbalance_Settings_Getcolor_bull(vars["VI_Settings"]));
    Imbalance_Settings_Setmitigated_color_bear(vars["Gap_Settings"], Imbalance_Settings_Getcolor_bear(vars["VI_Settings"]));
    Imbalance_Settings_SetCE_show(vars["Gap_Settings"], false);
    Imbalance_Settings_Setopen_show(vars["Gap_Settings"], true);
    Imbalance_Settings_Setclose_show(vars["Gap_Settings"], true);
    Imbalance_Settings_Setfill(vars["Gap_Settings"], vars["!96"]);
    Imbalance_Settings_Setfill_percent(vars["Gap_Settings"], vars["!97"]);
    Imbalance_Settings_SetmergeVI(vars["Gap_Settings"], false);
    Imbalance_Settings_Setmax_count(vars["Gap_Settings"], vars["!98"]);
    vars["color_transparent"] = core.rgb(255, 255, 0);
    vars["helper"] = CreateType_Helper(period);
    if not vars["Term"]:IsInitialized() then
        vars["Term"]:Set(CreateType_MarketStructure(period, "Term"));
    end
    if not vars["ST_array"]:IsInitialized() then
        vars["ST_array"]:Set(Array:New(0, nil));
    end
    if not vars["IT_array"]:IsInitialized() then
        vars["IT_array"]:Set(Array:New(0, nil));
    end
    if not vars["LT_array"]:IsInitialized() then
        vars["LT_array"]:Set(Array:New(0, nil));
    end
    if not vars["STH_array"]:IsInitialized() then
        vars["STH_array"]:Set(Array:New(0, nil));
    end
    if not vars["ITH_array"]:IsInitialized() then
        vars["ITH_array"]:Set(Array:New(0, nil));
    end
    if not vars["LTH_array"]:IsInitialized() then
        vars["LTH_array"]:Set(Array:New(0, nil));
    end
    if not vars["STL_array"]:IsInitialized() then
        vars["STL_array"]:Set(Array:New(0, nil));
    end
    if not vars["ITL_array"]:IsInitialized() then
        vars["ITL_array"]:Set(Array:New(0, nil));
    end
    if not vars["LTL_array"]:IsInitialized() then
        vars["LTL_array"]:Set(Array:New(0, nil));
    end
    MarketStructure_SetST(vars["Term"]:Get(), vars["ST_array"]:Get());
    MarketStructure_SetSTH(vars["Term"]:Get(), vars["STH_array"]:Get());
    MarketStructure_SetITH(vars["Term"]:Get(), vars["ITH_array"]:Get());
    MarketStructure_SetLTH(vars["Term"]:Get(), vars["LTH_array"]:Get());
    MarketStructure_SetSTL(vars["Term"]:Get(), vars["STL_array"]:Get());
    MarketStructure_SetITL(vars["Term"]:Get(), vars["ITL_array"]:Get());
    MarketStructure_SetLTL(vars["Term"]:Get(), vars["LTL_array"]:Get());
    MarketStructure_Setsettings(vars["Term"]:Get(), vars["Trend_Settings"]);
    if not vars["FVGs"]:IsInitialized() then
        vars["FVGs"]:Set(CreateType_ImbalanceStructure(period));
    end
    if not vars["imbalance_array"]:IsInitialized() then
        vars["imbalance_array"]:Set(Array:New(0, nil));
    end
    ImbalanceStructure_Settype(vars["FVGs"]:Get(), "FVG");
    ImbalanceStructure_Setimbalance(vars["FVGs"]:Get(), vars["imbalance_array"]:Get());
    ImbalanceStructure_Setsettings(vars["FVGs"]:Get(), vars["FVG_Settings"]);
    if not vars["iFVGs"]:IsInitialized() then
        vars["iFVGs"]:Set(CreateType_ImbalanceStructure(period));
    end
    if not vars["iimbalance_array"]:IsInitialized() then
        vars["iimbalance_array"]:Set(Array:New(0, nil));
    end
    ImbalanceStructure_Settype(vars["iFVGs"]:Get(), "iFVG");
    ImbalanceStructure_Setimbalance(vars["iFVGs"]:Get(), vars["iimbalance_array"]:Get());
    ImbalanceStructure_Setsettings(vars["iFVGs"]:Get(), vars["iFVG_Settings"]);
    if not vars["VI"]:IsInitialized() then
        vars["VI"]:Set(CreateType_ImbalanceStructure(period));
    end
    if not vars["VI_array"]:IsInitialized() then
        vars["VI_array"]:Set(Array:New(0, nil));
    end
    ImbalanceStructure_Settype(vars["VI"]:Get(), "VI");
    ImbalanceStructure_Setimbalance(vars["VI"]:Get(), vars["VI_array"]:Get());
    ImbalanceStructure_Setsettings(vars["VI"]:Get(), vars["VI_Settings"]);
    if not vars["Gaps"]:IsInitialized() then
        vars["Gaps"]:Set(CreateType_ImbalanceStructure(period));
    end
    if not vars["Gap_array"]:IsInitialized() then
        vars["Gap_array"]:Set(Array:New(0, nil));
    end
    ImbalanceStructure_Settype(vars["Gaps"]:Get(), "GAP");
    ImbalanceStructure_Setimbalance(vars["Gaps"]:Get(), vars["Gap_array"]:Get());
    ImbalanceStructure_Setsettings(vars["Gaps"]:Get(), vars["Gap_Settings"]);
    if not vars["EQs"]:IsInitialized() then
        vars["EQs"]:Set(Array:New(0, nil));
    end
    if not vars["labels"]:IsInitialized() then
        vars["labels"]:Set(Array:New(0, nil));
    end
    if not vars["EQ_claimed"]:IsInitialized() then
        vars["EQ_claimed"]:Set(Array:New(0, nil));
    end
    if not vars["tester"]:IsInitialized() then
        vars["tester"]:Set(Line:New(nil, nil, nil, nil):SetColor(vars["color_transparent"]));
    end
    vars["body"] = math.abs(source.open:tick(period) - source.close:tick(period));
    vars["stdev_1"][period] = math.abs(source.open:tick(period) - source.close:tick(period));
    vars["std"] = SafeMathExStdev(vars["stdev_1"], period, Settings_Getdisplacement_length(vars["Trend_Settings"]));
    if not vars["median"]:IsInitialized() then
        vars["median"]:Set(Array:New(0, nil));
    end
    vars["length"] = 14;
    vars["ATR1"]:update(mode);
    vars["median"]:Get():Unshift(vars["ATR1"].DATA:tick(period));
    if SafeGreater(vars["median"]:Get():Size(), vars["length"]) then
        Array:Pop(vars["median"]:Get());
    end
    vars["spacing"] = SafeMultiply(Array:Median(vars["median"]:Get()), Settings_GetEQ_Tolerance(vars["Trend_Settings"]));
    vars["displaced"] = vars["f_highlightDisplacementFunc1"].GetValue(period, mode);
    vars["candle"] = Triary((source.open:tick(period) < source.close:tick(period)), Settings_Getdisplacement_bull(vars["Trend_Settings"]), Settings_Getdisplacement_bear(vars["Trend_Settings"]));
    if Settings_Getdisplacement_fvg(vars["Trend_Settings"]) then
        vars["candle"] = Triary(SafeLess(source.open:tick(period - 1), source.close:tick(period - 1)), Settings_Getdisplacement_bull(vars["Trend_Settings"]), Settings_Getdisplacement_bear(vars["Trend_Settings"]));
    end
    plot1_color = Triary(vars["f_highlightDisplacementFunc2"].GetValue(period, mode) and Settings_Getdisplacement_fvg(vars["Trend_Settings"]), vars["candle"], nil);
    if plot1_color then
        plot1_open[period] = source.open[period];
        plot1_high[period] = source.high[period];
        plot1_low[period] = source.low[period];
        plot1_close[period] = source.close[period];
        plot1_open:setColor(period, Graphics:GetColor(plot1_color));
    else
        plot1_open:setNoData(period);
        plot1_high:setNoData(period);
        plot1_low:setNoData(period);
        plot1_close:setNoData(period);
    end
    plot2_color = Triary(vars["f_highlightDisplacementFunc3"].GetValue(period, mode) and not (Settings_Getdisplacement_fvg(vars["Trend_Settings"])), vars["candle"], nil);
    if plot2_color then
        plot2_open[period] = source.open[period];
        plot2_high[period] = source.high[period];
        plot2_low[period] = source.low[period];
        plot2_close[period] = source.close[period];
        plot2_open:setColor(period, Graphics:GetColor(plot2_color));
    else
        plot2_open:setNoData(period);
        plot2_high:setNoData(period);
        plot2_low:setNoData(period);
        plot2_close:setNoData(period);
    end
    if (period - period < 1000) then
        if ((period ~= source:size() - 1 or mode == core.UpdateLast) or period == source:size() - 2) then
            vars["FindImbalanceFunc4"].GetValue(vars["FVGs"]:Get(), period, mode);
            vars["FindImbalanceFunc13"].GetValue(vars["VI"]:Get(), period, mode);
            vars["FindImbalanceFunc14"].GetValue(vars["Gaps"]:Get(), period, mode);
        end
        vars["CheckMitigatedFunc15"].GetValue(vars["FVGs"]:Get(), period, mode);
        vars["CheckMitigatedFunc18"].GetValue(vars["iFVGs"]:Get(), period, mode);
        vars["CheckMitigatedFunc19"].GetValue(vars["VI"]:Get(), period, mode);
        vars["CheckMitigatedFunc20"].GetValue(vars["Gaps"]:Get(), period, mode);
        if period == source:size() - 1 then
            vars["renderFunc21"].GetValue(vars["FVGs"]:Get(), period, mode);
            vars["renderFunc27"].GetValue(vars["iFVGs"]:Get(), period, mode);
            vars["renderFunc28"].GetValue(vars["VI"]:Get(), period, mode);
            vars["renderFunc29"].GetValue(vars["Gaps"]:Get(), period, mode);
        end
        if (period ~= source:size() - 1 or mode == core.UpdateLast) then
            vars["FindLTFunc30"].GetValue(vars["FindITFunc32"].GetValue(vars["FindSTFunc35"].GetValue(vars["Term"]:Get(), period, mode), period, mode), period, mode);
            vars["CheckClaimedFunc47"].GetValue(vars["Term"]:Get(), period, mode);
        end
        if period == source:size() - 1 then
            vars["renderMSFunc49"].GetValue(vars["Term"]:Get(), period, mode);
        end
    end
end
function Draw(stage, context)
    Line:Draw(stage, context);
    Linefill:Draw(stage, context);
    Box:Draw(stage, context);
    Label:Draw(stage, context);
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
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
    if array == nil then
        return;
    end
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
    if array == nil then
        return;
    end
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
function Array:Median(array)
    if array == nil then
        return nil;
    end
    return array:Median();
end
function Array:First(array, value)
    if array == nil then
        return nil;
    end
    return array:First(value);
end
function Array:Last(array, value)
    if array == nil then
        return nil;
    end
    return array:Last(value);
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
    function newArray:Median()
        local items = {};
        for i, v in ipairs(self.arr) do
            items[i] = v;
        end
        table.sort(items);
        local center = self.size / 2;
        if self.size % 2 == 1 then
            return items[center];
        else
            return (items[center] + items[center + 1]) / 2;
        end
    end
    function newArray:First()
        if self.size == 0 then
            return;
        end
        return self.arr[1];
    end
    function newArray:Last()
        if self.size == 0 then
            return;
        end
        return self.arr[self.size];
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
Linefill = {};
Linefill.AllLinefills = {};
function Linefill:Clear()
    Linefill.AllLinefills = {};
end
function Linefill:SetColor(Linefill, clr)
    if Linefill == nil then
        return;
    end
    Linefill:SetColor(clr);
end
function Linefill:New(line1, line2)
    for i, fill in ipairs(Linefill.AllLinefills) do
        if fill.Line1 == line1 and fill.Line2 == line2 then
            return fill;
        end
    end
    local newLinefill = {};
    newLinefill.Line1 = line1;
    newLinefill.Line2 = line2;
    newLinefill.Color = core.colors().Blue;
    function newLinefill:SetColor(clr, transparency)
        self.Color = clr;
        if clr ~= nil then
            self.ColorTransparency = transparency and transparency or (math.floor(clr / 16777216) % 255);
        else
            self.ColorTransparency = nil;
        end
        self.PenId = nil;
        self.BrushId = nil;
    end
    function newLinefill:Draw(stage, context)
        if self.Line1 == nil or self.Line2 == nil then
            return;
        end
        if self.PenId == nil then
            self.PenId = Graphics:FindPen(1, self.Color, core.LINE_SOLID, context);
        end
        if self.BrushId == nil then
            self.BrushId = Graphics:FindBrush(self.Color, context);
        end
        
        local points = context:createPoints();
        _, y1 = context:pointOfPrice(self.Line1:GetY1());
        _, x1 = context:positionOfBar(self.Line1:GetX1());
        _, y2 = context:pointOfPrice(self.Line1:GetY2());
        _, x2 = context:positionOfBar(self.Line1:GetX2());
        points:add(x1, y1);
        points:add(x2, y2);
        _, y1 = context:pointOfPrice(self.Line2:GetY1());
        _, x1 = context:positionOfBar(self.Line2:GetX1());
        _, y2 = context:pointOfPrice(self.Line2:GetY2());
        _, x2 = context:positionOfBar(self.Line2:GetX2());
        points:add(x2, y2);
        points:add(x1, y1);
        context:drawPolygon(self.PenId, self.BrushId, points, self.ColorTransparency);
    end
    self.AllLinefills[#self.AllLinefills + 1] = newLinefill;
    return newLinefill;
end
function Linefill:Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    for i, value in ipairs(self.AllLinefills) do
        value:Draw(stage, context);
    end
end
Box = {};
Box.AllBoxs = {};
Box.AllSeries = {};
function Box:Clear()
    Box.AllBoxs = {};
    Box.AllSeries = {};
end
function Box:GetSerial(value, source, xloc)
    if value == nil then
        return nil;
    end
    if xloc == "bar_time" then
        return value / 86400000.;
    end
    if value < 0 or value >= source:size() then
        return nil;
    end
    return source:date(value);
end
function Box:SetLeftTop(box, left, top)
    if box == nil then
        return;
    end
    box:SetLeft(left);
    box:SetTop(top);
end
function Box:SetRightBottom(box, right, bottom)
    if box == nil then
        return;
    end
    box:SetRight(right);
    box:SetBottom(bottom);
end
function Box:SetRight(box, right)
    if box == nil then
        return;
    end
    box:SetRight(right);
end
function Box:SetTop(box, top)
    if box == nil then
        return;
    end
    box:SetTop(top);
end
function Box:SetBottom(box, bottom)
    if box == nil then
        return;
    end
    box:SetBottom(bottom);
end
function Box:SetLeft(box, left)
    if box == nil then
        return;
    end
    box:SetLeft(left);
end
function Box:GetBottom(box)
    if box == nil then
        return nil;
    end
    return box:GetBottom();
end
function Box:GetTop(box)
    if box == nil then
        return nil;
    end
    return box:GetTop();
end
function Box:GetLeft(box)
    if box == nil then
        return nil;
    end
    return box:GetLeft();
end
function Box:GetRight(box)
    if box == nil then
        return nil;
    end
    return box:GetRight();
end
function Box:SetText(box, text)
    if box == nil then
        return;
    end
    box:SetText(text);
end
function Box:SetTextColor(box, text_color)
    if box == nil then
        return;
    end
    box:SetTextColor(text_color);
end
function Box:SetTextHAlign(box, text_halign)
    if box == nil then
        return;
    end
    box:SetTextHAlign(text_halign);
end
function Box:SetTextSize(box, text_size)
    if box == nil then
        return;
    end
    box:SetTextSize(text_size);
end
function Box:SetBorderStyle(box, style)
    if box == nil then
        return;
    end
    box:SetBorderStyle(style);
end
function Box:New(id, seriesId, left, top, right, bottom)
    local newBox = {};
    newBox.SeriesId = seriesId;
    newBox.Left = left;
    function newBox:SetLeft(left)
        self.Left = left;
        return self;
    end
    function newBox:SetXLoc(val)
        self.XLoc = val;
        return self;
    end
    function newBox:GetLeft()
        return self.Left;
    end
    newBox.Top = top;
    function newBox:SetTop(top)
        self.Top = top;
        return self;
    end
    function newBox:GetTop()
        return self.Top;
    end
    newBox.Right = right;
    function newBox:SetRight(right)
        self.Right = right;
        return self;
    end
    function newBox:GetRight()
        return self.Right;
    end
    newBox.Bottom = bottom;
    function newBox:SetBottom(bottom)
        self.Bottom = bottom;
        return self;
    end
    function newBox:GetBottom()
        return self.Bottom;
    end
    newBox.BorderWidth = 1;
    newBox.BgColor = core.colors().Blue;
    function newBox:SetBgColor(clr)
        color, transparency = Graphics:SplitColorAndTransparency(clr);
        self.BgColorTransparency = transparency;
        self.BgColor = color;
        self.BrushId = nil;
        return self;
    end
    newBox.BorderColor = core.colors().Blue;
    function newBox:SetBorderColor(clr)
        color, transparency = Graphics:SplitColorAndTransparency(clr);
        self.BorderColor_transparency = transparency;
        self.BorderColor = color;
        self.PenId = nil;
        return self;
    end
    newBox.BorderStyle = "solid";
    newBox.BorderStyleIndicore = core.LINE_SOLID;
    function newBox:SetBorderStyle(style)
        self.BorderStyle = style;
        if style == "solid" or style == "arrow_right" or style == "arrow_left" or style == "arrow_both" then
            newBox.BorderStyleIndicore = core.LINE_SOLID;
        elseif style == "dotted" then
            newBox.BorderStyleIndicore = core.LINE_DOT;
        elseif style == "dashed" then
            newBox.BorderStyleIndicore = core.LINE_DASH;
        end
        self.PenId = nil;
        return self;
    end
    newBox.Text = nil;
    function newBox:SetText(text)
        self.Text = text;
        return self;
    end
    newBox.TextColor = nil;
    function newBox:SetTextColor(text_color)
        self.TextColor = text_color;
        return self;
    end
    newBox.TextHAlign = nil;
    function newBox:SetTextHAlign(text_halign)
        self.TextHAlign = text_halign;
        return self;
    end
    newBox.TextSize = nil;
    function newBox:SetTextSize(text_size)
        self.TextSize = text_size;
        return self;
    end
    function newBox:getCoordinates(context, x, y, W, H)
        return x - W / 2, y - H / 2, x + W / 2, y + H / 2;
    end
    function newBox:Draw(stage, context)
        if self.Top == nil or self.Left == nil or self.Bottom == nil or self.Right == nil then
            return;
        end
        if self.PenId == nil then
            self.PenId = Graphics:FindPen(self.BorderWidth, self.BorderColor, self.BorderStyleIndicore, context);
        end
        if self.BrushId == nil then
            self.BrushId = Graphics:FindBrush(self.BgColor, context);
        end
        local x1, x2;
        if self.XLoc == "bar_index" then
            _, x1 = context:positionOfBar(self.Left);
            _, x2 = context:positionOfBar(self.Right);
        else
            _, x1 = context:positionOfDate(self.Left / 86400000.);
            _, x2 = context:positionOfDate(self.Right / 86400000.);
        end
        _, y1 = context:pointOfPrice(self.Top);
        _, y2 = context:pointOfPrice(self.Bottom);
        if (x1 == x2) then
            x2 = x1 + 1;
        end
        if (y1 == y2) then
            y2 = y1 + 1
        end
        context:drawRectangle(self.PenId, self.BrushId, x1, y1, x2, y2, self.BgColorTransparency)
        context:drawRectangle(self.PenId, -1, x1, y1, x2, y2)
        if self.Text ~= nil and self.Text ~= "" then
            if self.FontId == nil then
                self.FontId = Graphics:FindFont("Arial", 10, 0, context.LEFT, context);
            end
            local W, H = context:measureText(self.FontId, self.Text, context.LEFT);
            local x_from, y_from, x_to, y_to = self:getCoordinates(context, (x1 + x2) / 2, (y1 + y2) / 2, W, H);
            context:drawText(self.FontId, self.Text, self.TextColor, -1, x_from, y_from, x_to, y_to, 0);
        end
    end
    function newBox:Get(index)
        return Box.AllSeries[self.SeriesId][index + 1];
    end
    self.AllBoxs[id .. "_" .. seriesId] = newBox;
    if self.AllSeries[seriesId] == nil then
        self.AllSeries[seriesId] = {};
    end
    table.insert(self.AllSeries[seriesId], 1, newBox);
    return newBox;
end
function Box:Delete(box)
    if box == nil then
        return;
    end
    self:removeFromAllBoxes(box);
    self:removeFromSeries(box);
end
function Box:removeFromSeries(box)
    for i = 1, #self.AllSeries[box.SeriesId] do
        if self.AllSeries[box.SeriesId][i] == box then
            table.remove(self.AllSeries[box.SeriesId], i);
            return;
        end
    end
end
function Box:removeFromAllBoxes(box)
    for key, value in pairs(self.AllBoxs) do
        if value == box then
            self.AllBoxs[key] = nil;
            return;
        end
    end
end
function Box:Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    for id, Box in pairs(self.AllBoxs) do
        Box:Draw(stage, context);
    end
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
function Label:GetSerial(value, source, xloc)
    if value == nil then
        return nil;
    end
    if xloc == "bar_time" then
        return value / 86400000.;
    end
    if value < 0 or value >= source:size() then
        return nil;
    end
    return source:date(value);
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
function Label:SetXLoc(label, x, xloc)
    if label == nil then
        return;
    end
    label:SetX(x);
    label:SetXLoc(xloc);
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
    function newLabel:SetXLoc(val)
        self.xloc = val;
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
        local x1, x;
        if self.xloc == "bar_index" then
            x1, x = context:positionOfBar(self.X)
        else
            x1, x = context:positionOfDate(self.X / 86400000.);
        end
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
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76407
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