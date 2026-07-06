-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76390
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
    indicator:name("Price Action Volumetric Breaker Blocks [UAlgo]");
    indicator:description("Price Action Volumetric Breaker Blocks [UAlgo]");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("param1", "Swing Length", "", 8, 5);
    indicator.parameters:addInteger("param2", "Show Last X Order Blocks", "", 4, 1, 10);
    indicator.parameters:addString("param3", "Violation Check", "", "Wick");
    indicator.parameters:addStringAlternative("param3", "Wick", "", "Wick");
    indicator.parameters:addStringAlternative("param3", "Close", "", "Close");
    indicator.parameters:addString("param4", "Hide Overlap", "", "True");
    indicator.parameters:addStringAlternative("param4", "True", "", "True");
    indicator.parameters:addStringAlternative("param4", "False", "", "False");
    indicator.parameters:addColor("param5", "Colors", "", core.colors().Teal);
    indicator.parameters:addColor("param6", " ", "", core.colors().Red);
end

local source;
local time;
function CreateType_swing(yValue, xValue, crossedValue)
    return {
        y = yValue or (nil),
        x = xValue or (nil),
        crossed = crossedValue or (false),
    };
end
function swing_Gety(self)
    if self == nil then return nil; end
    return self.y;
end
function swing_Sety(self, val)
    if self == nil then return nil; end
    self.y = val;
end
function swing_Getx(self)
    if self == nil then return nil; end
    return self.x;
end
function swing_Setx(self, val)
    if self == nil then return nil; end
    self.x = val;
end
function swing_Getcrossed(self)
    if self == nil then return nil; end
    return self.crossed;
end
function swing_Setcrossed(self, val)
    if self == nil then return nil; end
    self.crossed = val;
end
function CreateType_bb(topValue, btmValue, barStartValue, bullishStrValue, bearishStrValue, bbBoxValue, bullishBoxValue, bearishBoxValue, volValue, brokenValue, seperatorLineValue, orderTextSeperatorValue)
    return {
        top = topValue or (nil),
        btm = btmValue or (nil),
        barStart = barStartValue,
        bullishStr = bullishStrValue,
        bearishStr = bearishStrValue,
        bbBox = bbBoxValue,
        bullishBox = bullishBoxValue,
        bearishBox = bearishBoxValue,
        vol = volValue,
        broken = brokenValue or (false),
        seperatorLine = seperatorLineValue,
        orderTextSeperator = orderTextSeperatorValue,
    };
end
function bb_Gettop(self)
    if self == nil then return nil; end
    return self.top;
end
function bb_Settop(self, val)
    if self == nil then return nil; end
    self.top = val;
end
function bb_Getbtm(self)
    if self == nil then return nil; end
    return self.btm;
end
function bb_Setbtm(self, val)
    if self == nil then return nil; end
    self.btm = val;
end
function bb_GetbarStart(self)
    if self == nil then return nil; end
    return self.barStart;
end
function bb_SetbarStart(self, val)
    if self == nil then return nil; end
    self.barStart = val;
end
function bb_GetbullishStr(self)
    if self == nil then return nil; end
    return self.bullishStr;
end
function bb_SetbullishStr(self, val)
    if self == nil then return nil; end
    self.bullishStr = val;
end
function bb_GetbearishStr(self)
    if self == nil then return nil; end
    return self.bearishStr;
end
function bb_SetbearishStr(self, val)
    if self == nil then return nil; end
    self.bearishStr = val;
end
function bb_GetbbBox(self)
    if self == nil then return nil; end
    return self.bbBox;
end
function bb_SetbbBox(self, val)
    if self == nil then return nil; end
    self.bbBox = val;
end
function bb_GetbullishBox(self)
    if self == nil then return nil; end
    return self.bullishBox;
end
function bb_SetbullishBox(self, val)
    if self == nil then return nil; end
    self.bullishBox = val;
end
function bb_GetbearishBox(self)
    if self == nil then return nil; end
    return self.bearishBox;
end
function bb_SetbearishBox(self, val)
    if self == nil then return nil; end
    self.bearishBox = val;
end
function bb_Getvol(self)
    if self == nil then return nil; end
    return self.vol;
end
function bb_Setvol(self, val)
    if self == nil then return nil; end
    self.vol = val;
end
function bb_Getbroken(self)
    if self == nil then return nil; end
    return self.broken;
end
function bb_Setbroken(self, val)
    if self == nil then return nil; end
    self.broken = val;
end
function bb_GetseperatorLine(self)
    if self == nil then return nil; end
    return self.seperatorLine;
end
function bb_SetseperatorLine(self, val)
    if self == nil then return nil; end
    self.seperatorLine = val;
end
function bb_GetorderTextSeperator(self)
    if self == nil then return nil; end
    return self.orderTextSeperator;
end
function bb_SetorderTextSeperator(self, val)
    if self == nil then return nil; end
    self.orderTextSeperator = val;
end
function CreateType_market(msbOrBosValue, directionValue, marketLineValue, lastLineTimeValue, marketLabelValue)
    return {
        msbOrBos = msbOrBosValue,
        direction = directionValue,
        marketLine = marketLineValue,
        lastLineTime = lastLineTimeValue,
        marketLabel = marketLabelValue,
    };
end
function market_GetmsbOrBos(self)
    if self == nil then return nil; end
    return self.msbOrBos;
end
function market_SetmsbOrBos(self, val)
    if self == nil then return nil; end
    self.msbOrBos = val;
end
function market_Getdirection(self)
    if self == nil then return nil; end
    return self.direction;
end
function market_Setdirection(self, val)
    if self == nil then return nil; end
    self.direction = val;
end
function market_GetmarketLine(self)
    if self == nil then return nil; end
    return self.marketLine;
end
function market_SetmarketLine(self, val)
    if self == nil then return nil; end
    self.marketLine = val;
end
function market_GetlastLineTime(self)
    if self == nil then return nil; end
    return self.lastLineTime;
end
function market_SetlastLineTime(self, val)
    if self == nil then return nil; end
    self.lastLineTime = val;
end
function market_GetmarketLabel(self)
    if self == nil then return nil; end
    return self.marketLabel;
end
function market_SetmarketLabel(self, val)
    if self == nil then return nil; end
    self.marketLabel = val;
end
function Create_calculateStrengths()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(barIndex, period, mode)
            local_vars["bullishStrength"] = 0.0;
            local_vars["bearishStrength"] = 0.0;
            local_vars["barsToConsider"] = vars["swingLength"];
            local for2_from = 0;
            local for2_to = local_vars["barsToConsider"] - 1;
            local for2_step = for2_from < for2_to and 1 or -1;
            if not for2_from or not for2_to then return; end
            for i = for2_from, for2_to, for2_step do
                if (barIndex - i >= 0) then
                    openn = source.open:tick(period - barIndex - i);
                    highh = source.high:tick(period - barIndex - i);
                    loww = source.low:tick(period - barIndex - i);
                    closee = source.close:tick(period - barIndex - i);
                    volumee = source.volume:tick(period - barIndex - i);
                    if SafeGreater(openn, closee) then
                        local_vars["bearishStrength"] = SafePlus(local_vars["bearishStrength"], volumee);
                    else
                        local_vars["bullishStrength"] = SafePlus(local_vars["bullishStrength"], volumee);
                    end
                end
            end
            return local_vars["bullishStrength"], local_vars["bearishStrength"];
        end
    };
end
function Create_isOverlapping()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(newBlock, existingArray, period, mode)
            local_vars["flag"] = false;
            if SafeGreater(existingArray:Size(), 0) then
                local for3_from = 0;
                local for3_to = SafeMinus(existingArray:Size(), 1);
                local for3_step = for3_from < for3_to and 1 or -1;
                if not for3_from or not for3_to then return; end
                for i = for3_from, for3_to, for3_step do
                    existingBlock = Array:Get(existingArray, i);
                    if (SafeGE(bb_Gettop(newBlock), bb_Getbtm(existingBlock)) and SafeLE(bb_Gettop(newBlock), bb_Gettop(existingBlock)) or SafeGE(bb_Getbtm(newBlock), bb_Getbtm(existingBlock)) and SafeLE(bb_Getbtm(newBlock), bb_Gettop(existingBlock))) then
                        local_vars["flag"] = true;
                    end
                end
            end
            return local_vars["flag"];
        end
    };
end
function Create_drawBox()
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(volatilityBlock, period, mode)
            bb_SetbullishBox(volatilityBlock, Box:New(core.formatDate(Box:GetSerial(bb_GetbarStart(volatilityBlock), source, "bar_time") or 0), "1", bb_GetbarStart(volatilityBlock), bb_Gettop(volatilityBlock), time:tick(period), SafePlus(bb_Getbtm(volatilityBlock), SafeDivide((SafeMinus(bb_Gettop(volatilityBlock), bb_Getbtm(volatilityBlock))), 2))):SetBgColor(vars["upBbColor"] + math.floor(40 / 100 * 255) * 16777216):SetBorderColor(nil):SetXLoc("bar_time"));
            bb_SetbearishBox(volatilityBlock, Box:New(core.formatDate(Box:GetSerial(bb_GetbarStart(volatilityBlock), source, "bar_time") or 0), "2", bb_GetbarStart(volatilityBlock), SafePlus(bb_Getbtm(volatilityBlock), SafeDivide((SafeMinus(bb_Gettop(volatilityBlock), bb_Getbtm(volatilityBlock))), 2)), time:tick(period), bb_Getbtm(volatilityBlock)):SetBgColor(vars["downBbColor"] + math.floor(40 / 100 * 255) * 16777216):SetBorderColor(nil):SetXLoc("bar_time"));
            bb_SetbbBox(volatilityBlock, Box:New(core.formatDate(Box:GetSerial(bb_GetbarStart(volatilityBlock), source, "bar_time") or 0), "3", bb_GetbarStart(volatilityBlock), bb_Gettop(volatilityBlock), time:tick(period), bb_Getbtm(volatilityBlock)):SetBgColor(core.colors().Gray + math.floor(80 / 100 * 255) * 16777216):SetBorderColor(nil):SetXLoc("bar_time"));
            bb_SetseperatorLine(volatilityBlock, Line:New(bb_GetbarStart(volatilityBlock), SafePlus(bb_Getbtm(volatilityBlock), SafeDivide((SafeMinus(bb_Gettop(volatilityBlock), bb_Getbtm(volatilityBlock))), 2)), time:tick(period), SafePlus(bb_Getbtm(volatilityBlock), SafeDivide((SafeMinus(bb_Gettop(volatilityBlock), bb_Getbtm(volatilityBlock))), 2))):SetColor(core.colors().Gray + math.floor(50 / 100 * 255) * 16777216):SetStyle("dashed"):SetWidth(1):SetXLoc(bb_GetbarStart(volatilityBlock), time:tick(period), "bar_time"));
            bb_SetorderTextSeperator(volatilityBlock, Line:New(bb_GetbarStart(volatilityBlock), bb_Gettop(volatilityBlock), bb_GetbarStart(volatilityBlock), bb_Getbtm(volatilityBlock)):SetColor(core.colors().Gray + math.floor(50 / 100 * 255) * 16777216):SetStyle("solid"):SetXLoc(bb_GetbarStart(volatilityBlock), bb_GetbarStart(volatilityBlock), "bar_time"));
            return local_vars["volatilityBlock.orderTextSeperator"];
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
    vars["swingLength"] = instance.parameters.param1;
    vars["showLastXBb"] = instance.parameters.param2;
    vars["violationType"] = instance.parameters.param3;
    vars["hideOverlap"] = instance.parameters.param4;
    vars["upBbColor"] = instance.parameters.param5;
    vars["downBbColor"] = instance.parameters.param6;
    vars["bullishBb"] = Variable:Create();
    vars["bearishBb"] = Variable:Create();
    vars["marketStructure"] = Variable:Create();
    vars["top"] = instance:addInternalStream(0, 0);
    vars["btm"] = instance:addInternalStream(0, 0);
    vars["__pivothigh1"] = CreatePivotHigh(source.high, vars["swingLength"], vars["swingLength"]);
    vars["__pivotlow1"] = CreatePivotLow(source.low, vars["swingLength"], vars["swingLength"]);
    vars["topp"] = Variable:Create();
    vars["btmm"] = Variable:Create();
    time = instance:addInternalStream(0, 0);
    Line:Prepare(500);
    Label:Prepare(500);
    vars["calculateStrengthsFunc1"] = Create_calculateStrengths();
    vars["isOverlappingFunc2"] = Create_isOverlapping();
    vars["calculateStrengthsFunc3"] = Create_calculateStrengths();
    vars["isOverlappingFunc4"] = Create_isOverlapping();
    vars["drawBoxFunc5"] = Create_drawBox();
    vars["drawBoxFunc6"] = Create_drawBox();
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Line:Clear();
        Label:Clear();
        Box:Clear();
        vars["bullishBb"]:Clear();
        vars["bearishBb"]:Clear();
        vars["marketStructure"]:Clear();
        SafeSetFloat(vars["top"], period, nil);
        SafeSetFloat(vars["btm"], period, nil);
        vars["topp"]:Clear();
        vars["btmm"]:Clear();
        time[period] = source:date(period) * 86400000;
        vars["calculateStrengthsFunc1"].Clear();
        vars["isOverlappingFunc2"].Clear();
        vars["calculateStrengthsFunc3"].Clear();
        vars["isOverlappingFunc4"].Clear();
        vars["drawBoxFunc5"].Clear();
        vars["drawBoxFunc6"].Clear();
    else
        SafeSetFloat(vars["top"], period, SafeGetFloat(vars["top"], period - 1));
        SafeSetFloat(vars["btm"], period, SafeGetFloat(vars["btm"], period - 1));
        time[period] = source:date(period) * 86400000;
    end
    if not vars["bullishBb"]:IsInitialized() then
        vars["bullishBb"]:Set(Array:New(0, nil));
    end
    if not vars["bearishBb"]:IsInitialized() then
        vars["bearishBb"]:Set(Array:New(0, nil));
    end
    if not vars["marketStructure"]:IsInitialized() then
        vars["marketStructure"]:Set(CreateType_market(nil, nil, nil, 0));
    end
    SafeSetFloat(vars["top"], period, vars["__pivothigh1"]:get(period));
    SafeSetFloat(vars["btm"], period, vars["__pivotlow1"]:get(period));
    if not vars["topp"]:IsInitialized() then
        vars["topp"]:Set(CreateType_swing());
    end
    if not vars["btmm"]:IsInitialized() then
        vars["btmm"]:Set(CreateType_swing());
    end
    if not (SafeGetFloat(vars["top"], period) == nil) then
        if time:first() > period - (vars["swingLength"]) then return; end
        swing_Setx(vars["topp"]:Get(), time:tick(period - vars["swingLength"]));
        swing_Sety(vars["topp"]:Get(), source.high:tick(period - vars["swingLength"]));
        swing_Setcrossed(vars["topp"]:Get(), false);
    end
    if not (SafeGetFloat(vars["btm"], period) == nil) then
        if time:first() > period - (vars["swingLength"]) then return; end
        swing_Setx(vars["btmm"]:Get(), time:tick(period - vars["swingLength"]));
        swing_Sety(vars["btmm"]:Get(), source.low:tick(period - vars["swingLength"]));
        swing_Setcrossed(vars["btmm"]:Get(), false);
    end
    if SafeLess(source.close:tick(period), swing_Gety(vars["btmm"]:Get())) and (swing_Getcrossed(vars["btmm"]:Get()) == false) then
        swing_Setcrossed(vars["btmm"]:Get(), true);
        market_SetmsbOrBos(vars["marketStructure"]:Get(), Triary(market_GetmsbOrBos(vars["marketStructure"]:Get()) == nil, "msb", Triary((market_Getdirection(vars["marketStructure"]:Get()) == (-1)), "bos", "msb")));
        market_Setdirection(vars["marketStructure"]:Get(), (-1));
        vars["lineColor"] = core.colors().Red;
        market_SetmarketLine(vars["marketStructure"]:Get(), Line:New(swing_Getx(vars["btmm"]:Get()), swing_Gety(vars["btmm"]:Get()), time:tick(period), swing_Gety(vars["btmm"]:Get())):SetColor(vars["lineColor"]):SetXLoc(swing_Getx(vars["btmm"]:Get()), time:tick(period), "bar_time"));
        market_SetlastLineTime(vars["marketStructure"]:Get(), swing_Getx(vars["btmm"]:Get()));
        labelText = Triary((market_GetmsbOrBos(vars["marketStructure"]:Get()) == "msb"), "MSB", "BOS");
        labelX = Round(SafeDivide((SafePlus(swing_Getx(vars["btmm"]:Get()), time:tick(period))), 2));
        label_1_x = labelX;
        market_SetmarketLabel(vars["marketStructure"]:Get(), Label:New(core.formatDate(Label:GetSerial(label_1_x, source, "bar_time") or 0) .. "_1", "1", label_1_x, swing_Gety(vars["btmm"]:Get())):SetText(labelText):SetColor(core.colors().White + math.floor(100 / 100 * 255) * 16777216):SetTextColor(vars["lineColor"]):SetStyle("up"):SetSize("tiny"):SetXLoc("bar_time"));
        vars["highAndGreenTop"] = 0;
        vars["highAndGreenBtm"] = 0;
        vars["highAndGreenTime"] = 0;
        vars["selectedIndex"] = 0;
        vars["vol"] = nil;
        if time:first() > period - (1) then return; end
        local for1_from = 1;
        local for1_to = SafeDivide((SafeMinus(time:tick(period), swing_Getx(vars["btmm"]:Get()))), (SafeMinus(time:tick(period), time:tick(period - 1))));
        local for1_step = for1_from < for1_to and 1 or -1;
        if not for1_from or not for1_to then return; end
        for i = for1_from, for1_to, for1_step do
            if SafeGreater(source.close:tick(period - i), source.open:tick(period - i)) and SafeGreater(source.high:tick(period - i), vars["highAndGreenTop"]) then
                vars["highAndGreenTop"] = source.high:tick(period - i);
                vars["highAndGreenBtm"] = source.low:tick(period - i);
                if time:first() > period - (i) then return; end
                vars["highAndGreenTime"] = time:tick(period - i);
                vars["vol"] = source.volume:tick(period - i);
                vars["selectedIndex"] = i;
            end
        end
        bullishStrength_ret_val, bearishStrength_ret_val = vars["calculateStrengthsFunc1"].GetValue(vars["selectedIndex"], period, mode);
        vars["bullishStrength"] = bullishStrength_ret_val;
        vars["bearishStrength"] = bearishStrength_ret_val;
        newOb = CreateType_bb(vars["highAndGreenTop"], vars["highAndGreenBtm"], vars["highAndGreenTime"]);
        bb_SetbullishStr(newOb, vars["bullishStrength"]);
        bb_SetbearishStr(newOb, vars["bearishStrength"]);
        bb_Setvol(newOb, vars["vol"]);
        bb_Setbroken(newOb, false);
        if not (vars["isOverlappingFunc2"].GetValue(newOb, vars["bearishBb"]:Get(), period, mode)) and (vars["hideOverlap"] == "True") then
            vars["bearishBb"]:Get():Push(newOb);
        end
        if (vars["hideOverlap"] == "False") then
            vars["bearishBb"]:Get():Push(newOb);
        end
        if SafeGreater(vars["bearishBb"]:Get():Size(), vars["showLastXBb"]) then
            local for4_from = 0;
            local for4_to = SafeMinus(vars["bearishBb"]:Get():Size(), 1);
            local for4_step = for4_from < for4_to and 1 or -1;
            if not for4_from or not for4_to then return; end
            for i = for4_from, for4_to, for4_step do
                currentBb = Array:Get(vars["bearishBb"]:Get(), i);
                if not (bb_GetbbBox(currentBb) == nil) then
                    oldOb = vars["bearishBb"]:Get():Shift();
                    Box:Delete(bb_GetbullishBox(oldOb));
                    Box:Delete(bb_GetbearishBox(oldOb));
                    Box:Delete(bb_GetbbBox(oldOb));
                    Line:Delete(bb_GetseperatorLine(oldOb));
                    Line:Delete(bb_GetorderTextSeperator(oldOb));
                end
            end
        end
    elseif SafeGreater(source.close:tick(period), swing_Gety(vars["topp"]:Get())) and (swing_Getcrossed(vars["topp"]:Get()) == false) then
        swing_Setcrossed(vars["topp"]:Get(), true);
        market_SetmsbOrBos(vars["marketStructure"]:Get(), Triary(market_GetmsbOrBos(vars["marketStructure"]:Get()) == nil, "msb", Triary((market_Getdirection(vars["marketStructure"]:Get()) == 1), "bos", "msb")));
        market_Setdirection(vars["marketStructure"]:Get(), 1);
        vars["lineColor"] = core.colors().Green;
        vars["marketStructure.marketLine"] = Line:New(swing_Getx(vars["topp"]:Get()), swing_Gety(vars["topp"]:Get()), time:tick(period), swing_Gety(vars["topp"]:Get())):SetColor(vars["lineColor"]):SetXLoc(swing_Getx(vars["topp"]:Get()), time:tick(period), "bar_time");
        market_SetlastLineTime(vars["marketStructure"]:Get(), swing_Getx(vars["topp"]:Get()));
        labelText = Triary((market_GetmsbOrBos(vars["marketStructure"]:Get()) == "msb"), "MSB", "BOS");
        labelX = Round(SafeDivide((SafePlus(swing_Getx(vars["topp"]:Get()), time:tick(period))), 2));
        label_2_x = labelX;
        vars["marketStructure.marketLabel"] = Label:New(core.formatDate(Label:GetSerial(label_2_x, source, "bar_time") or 0) .. "_2", "2", label_2_x, swing_Gety(vars["topp"]:Get())):SetText(labelText):SetColor(core.colors().White + math.floor(100 / 100 * 255) * 16777216):SetTextColor(vars["lineColor"]):SetStyle("down"):SetSize("tiny"):SetXLoc("bar_time");
        vars["lowAndRedBtm"] = 999999999999;
        vars["lowAndRedTop"] = nil;
        vars["lowAndRedTime"] = 0;
        vars["selectedIndex"] = 0;
        vars["vol"] = nil;
        if time:first() > period - (1) then return; end
        local for5_from = 1;
        local for5_to = SafeDivide((SafeMinus(time:tick(period), swing_Getx(vars["topp"]:Get()))), (SafeMinus(time:tick(period), time:tick(period - 1))));
        local for5_step = for5_from < for5_to and 1 or -1;
        if not for5_from or not for5_to then return; end
        for i = for5_from, for5_to, for5_step do
            if SafeLess(source.close:tick(period), source.open:tick(period - i)) and (source.low:tick(period) < vars["lowAndRedBtm"]) then
                vars["lowAndRedBtm"] = source.low:tick(period - i);
                vars["lowAndRedTop"] = source.high:tick(period - i);
                if time:first() > period - (i) then return; end
                vars["lowAndRedTime"] = time:tick(period - i);
                vars["vol"] = source.volume:tick(period - i);
                vars["selectedIndex"] = i;
            end
        end
        bullishStrength_ret_val, bearishStrength_ret_val = vars["calculateStrengthsFunc3"].GetValue(vars["selectedIndex"], period, mode);
        vars["bullishStrength"] = bullishStrength_ret_val;
        vars["bearishStrength"] = bearishStrength_ret_val;
        newOb = CreateType_bb(vars["lowAndRedTop"], vars["lowAndRedBtm"], vars["lowAndRedTime"]);
        bb_SetbullishStr(newOb, vars["bullishStrength"]);
        bb_SetbearishStr(newOb, vars["bearishStrength"]);
        bb_Setvol(newOb, vars["vol"]);
        bb_Setbroken(newOb, false);
        if not (vars["isOverlappingFunc4"].GetValue(newOb, vars["bullishBb"]:Get(), period, mode)) and (vars["hideOverlap"] == "True") then
            vars["bullishBb"]:Get():Push(newOb);
        end
        if (vars["hideOverlap"] == "False") then
            vars["bullishBb"]:Get():Push(newOb);
        end
        if SafeGreater(vars["bullishBb"]:Get():Size(), vars["showLastXBb"]) then
            local for6_from = 0;
            local for6_to = SafeMinus(vars["bullishBb"]:Get():Size(), 1);
            local for6_step = for6_from < for6_to and 1 or -1;
            if not for6_from or not for6_to then return; end
            for i = for6_from, for6_to, for6_step do
                currentBb = Array:Get(vars["bullishBb"]:Get(), i);
                if not (bb_GetbbBox(currentBb) == nil) then
                    oldOb = vars["bullishBb"]:Get():Shift();
                    Box:Delete(bb_GetbullishBox(oldOb));
                    Box:Delete(bb_GetbearishBox(oldOb));
                    Box:Delete(bb_GetbbBox(oldOb));
                    Line:Delete(bb_GetseperatorLine(oldOb));
                    Line:Delete(bb_GetorderTextSeperator(oldOb));
                end
            end
        end
    end
    if SafeGreater(vars["bullishBb"]:Get():Size(), 0) then
        local for7_from = 0;
        local for7_to = SafeMinus(vars["bullishBb"]:Get():Size(), 1);
        local for7_step = for7_from < for7_to and 1 or -1;
        if not for7_from or not for7_to then return; end
        for i = for7_from, for7_to, for7_step do
            currentBb = Array:Get(vars["bullishBb"]:Get(), i);
            if SafeLess(source.close:tick(period), bb_Getbtm(currentBb)) and (bb_Getbroken(currentBb) == false) then
                bb_Setbroken(currentBb, true);
                vars["drawBoxFunc5"].GetValue(currentBb, period, mode);
            end
            totalStr = SafePlus(bb_GetbullishStr(currentBb), bb_GetbearishStr(currentBb));
            bullishBoxWidth = SafeMultiply(SafeDivide(bb_GetbullishStr(currentBb), totalStr), (SafeMinus(SafeDivide((SafePlus(Box:GetLeft(bb_GetbbBox(currentBb)), time:tick(period))), 2), bb_GetbarStart(currentBb))));
            bearishBoxWidth = SafeMultiply(SafeDivide(bb_GetbearishStr(currentBb), totalStr), (SafeMinus(SafeDivide((SafePlus(Box:GetLeft(bb_GetbbBox(currentBb)), time:tick(period))), 2), bb_GetbarStart(currentBb))));
            Box:SetRight(bb_GetbullishBox(currentBb), Round(SafePlus(bb_GetbarStart(currentBb), bullishBoxWidth)));
            Box:SetRight(bb_GetbearishBox(currentBb), Round(SafePlus(bb_GetbarStart(currentBb), bearishBoxWidth)));
            Box:SetRight(bb_GetbbBox(currentBb), time:tick(period));
            Line:SetXY2(bb_GetseperatorLine(currentBb), SafeDivide((SafePlus(Box:GetLeft(bb_GetbbBox(currentBb)), time:tick(period))), 2), SafePlus(bb_Getbtm(currentBb), SafeDivide((SafeMinus(bb_Gettop(currentBb), bb_Getbtm(currentBb))), 2)));
            Line:SetXY1(bb_GetorderTextSeperator(currentBb), SafeDivide((SafePlus(Box:GetLeft(bb_GetbbBox(currentBb)), time:tick(period))), 2), bb_Gettop(currentBb));
            Line:SetXY2(bb_GetorderTextSeperator(currentBb), SafeDivide((SafePlus(Box:GetLeft(bb_GetbbBox(currentBb)), time:tick(period))), 2), bb_Getbtm(currentBb));
            violation = ((vars["violationType"] == "Wick") and SafeGreater(source.high:tick(period), bb_Gettop(currentBb)) or (vars["violationType"] == "Close") and SafeGreater(source.close:tick(period), bb_Gettop(currentBb)));
            if violation and bb_Getbroken(currentBb) then
                Box:Delete(bb_GetbullishBox(currentBb));
                Box:Delete(bb_GetbearishBox(currentBb));
                Box:Delete(bb_GetbbBox(currentBb));
                Line:Delete(bb_GetseperatorLine(currentBb));
                Line:Delete(bb_GetorderTextSeperator(currentBb));
                Array:Remove(vars["bullishBb"]:Get(), i);
            end
        end
    end
    if SafeGreater(vars["bearishBb"]:Get():Size(), 0) then
        local for8_from = 0;
        local for8_to = SafeMinus(vars["bearishBb"]:Get():Size(), 1);
        local for8_step = for8_from < for8_to and 1 or -1;
        if not for8_from or not for8_to then return; end
        for i = for8_from, for8_to, for8_step do
            currentBb = Array:Get(vars["bearishBb"]:Get(), i);
            if SafeGreater(source.close:tick(period - 1), bb_Gettop(currentBb)) and (bb_Getbroken(currentBb) == false) then
                bb_Setbroken(currentBb, true);
                vars["drawBoxFunc6"].GetValue(currentBb, period, mode);
            end
            totalStr = SafePlus(bb_GetbullishStr(currentBb), bb_GetbearishStr(currentBb));
            bullishBoxWidth = SafeMultiply(SafeDivide(bb_GetbullishStr(currentBb), totalStr), (SafeMinus(SafeDivide((SafePlus(Box:GetLeft(bb_GetbbBox(currentBb)), time:tick(period))), 2), bb_GetbarStart(currentBb))));
            bearishBoxWidth = SafeMultiply(SafeDivide(bb_GetbearishStr(currentBb), totalStr), (SafeMinus(SafeDivide((SafePlus(Box:GetLeft(bb_GetbbBox(currentBb)), time:tick(period))), 2), bb_GetbarStart(currentBb))));
            Box:SetRight(bb_GetbullishBox(currentBb), Round(SafePlus(bb_GetbarStart(currentBb), bullishBoxWidth)));
            Box:SetRight(bb_GetbearishBox(currentBb), Round(SafePlus(bb_GetbarStart(currentBb), bearishBoxWidth)));
            Box:SetRight(bb_GetbbBox(currentBb), time:tick(period));
            Line:SetXY2(bb_GetseperatorLine(currentBb), SafeDivide((SafePlus(Box:GetLeft(bb_GetbbBox(currentBb)), time:tick(period))), 2), SafePlus(bb_Getbtm(currentBb), SafeDivide((SafeMinus(bb_Gettop(currentBb), bb_Getbtm(currentBb))), 2)));
            Line:SetXY1(bb_GetorderTextSeperator(currentBb), SafeDivide((SafePlus(Box:GetLeft(bb_GetbbBox(currentBb)), time:tick(period))), 2), bb_Gettop(currentBb));
            Line:SetXY2(bb_GetorderTextSeperator(currentBb), SafeDivide((SafePlus(Box:GetLeft(bb_GetbbBox(currentBb)), time:tick(period))), 2), bb_Getbtm(currentBb));
            violation = ((vars["violationType"] == "Wick") and SafeLess(source.low:tick(period), bb_Getbtm(currentBb)) or (vars["violationType"] == "Close") and SafeLess(source.close:tick(period), bb_Getbtm(currentBb)));
            if violation and bb_Getbroken(currentBb) then
                Box:Delete(bb_GetbullishBox(currentBb));
                Box:Delete(bb_GetbearishBox(currentBb));
                Box:Delete(bb_GetbbBox(currentBb));
                Line:Delete(bb_GetseperatorLine(currentBb));
                Line:Delete(bb_GetorderTextSeperator(currentBb));
                Array:Remove(vars["bearishBb"]:Get(), i);
            end
        end
    end
end
function Draw(stage, context)
    Line:Draw(stage, context);
    Label:Draw(stage, context);
    Box:Draw(stage, context);
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
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
function CreatePivotHigh(source, leftbars, rightbars)
    local pivot = {};
    pivot.Source = source;
    pivot.LeftBars = leftbars;
    pivot.RightBars = rightbars;
    function pivot:get(period)
        if period - self.RightBars - self.LeftBars - 1 < 0 or not self.Source:hasData(period - self.RightBars) then
            return nil;
        end
        local ref = self.Source:tick(period - self.RightBars);
        for i = period - self.RightBars - self.LeftBars, period - self.RightBars - 1 do
            if not self.Source:hasData(i) or self.Source:tick(i) >= ref then
                return nil;
            end
        end
        for i = period - self.LeftBars + 1, period do
            if not self.Source:hasData(i) or self.Source:tick(i) >= ref then
                return nil;
            end
        end
        return ref;
    end
    return pivot;
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
function CreatePivotLow(source, leftbars, rightbars)
    local pivot = {};
    pivot.Source = source;
    pivot.LeftBars = leftbars;
    pivot.RightBars = rightbars;
    function pivot:get(period)
        if period - self.RightBars - self.LeftBars - 1 < 0 or not self.Source:hasData(period - self.RightBars) then
            return nil;
        end
        local ref = self.Source:tick(period - self.RightBars);
        for i = period - self.RightBars - self.LeftBars, period - self.RightBars - 1 do
            if not self.Source:hasData(i) or self.Source:tick(i) <= ref then
                return nil;
            end
        end
        for i = period - self.LeftBars + 1, period do
            if not self.Source:hasData(i) or self.Source:tick(i) <= ref then
                return nil;
            end
        end
        return ref;
    end
    return pivot;
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
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=76390
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