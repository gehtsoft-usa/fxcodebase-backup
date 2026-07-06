-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74447

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


function Init()
    indicator:name("ICT Donchian Smart Money Structure");
    indicator:description("ICT Donchian Smart Money Structure");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("param1", "Structure Period", "", 20);
    indicator.parameters:addBoolean("param2", "Structure Response", "", true);
    indicator.parameters:addInteger("param3", "", "", 7);
    indicator.parameters:addBoolean("param4", "Bullish Structure", "", true);
    indicator.parameters:addColor("param5", "", "", Graphics:GetColor(core.rgb(8, 236, 126)));
    indicator.parameters:addColor("param6", "", "", Graphics:GetColor(core.rgb(8, 236, 126)));
    indicator.parameters:addBoolean("param7", "Bearish Structure", "", true);
    indicator.parameters:addColor("param8", "", "", Graphics:GetColor(core.rgb(255, 34, 34)));
    indicator.parameters:addColor("param9", "", "", Graphics:GetColor(core.rgb(255, 34, 34)));
    indicator.parameters:addBoolean("param10", "Premium & Discount", "", true);
    indicator.parameters:addColor("param11", "", "", Graphics:GetColor(core.rgb(255, 34, 34) + math.floor(80 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param12", "", "", Graphics:GetColor(core.rgb(8, 236, 126) + math.floor(80 / 100 * 255) * 16777216));
    indicator.parameters:addBoolean("param13", "Donchian Channel", "", false);
    indicator.parameters:addBoolean("param14", "Structure Candles", "", true);
    indicator.parameters:addInteger("param15", "Structure Response", "", 40);
end

local source;
local vars = {};
local Up;
local Dn;
local iUp;
local iDn;
local pos;
local plot1;
local plot2;
local plot3;
local plot4;
local plot5;
local plot6;
local plot7;
local plot8;
function Create_CreateLabel(x, y, txt, col, z)
    local local_vars = {};
    Label:Prepare(500);
    return {
        GetValue = function(period, mode)
            label_1_x = (x:hasData(period) and x:tick(period) or nil);
            return Label:New(core.formatDate(label_1_x and source:date(label_1_x) or 0) .. "_1", "1", label_1_x, (y:hasData(period) and y:tick(period) or nil)):SetText(txt):SetColor(Color(nil)):SetTextColor(col):SetStyle(((z) and ("down") or ("up")));
        end
    };
end
function Create_CreateLine(x1, x2, y, col)
    local local_vars = {};
    Line:Prepare(500);
    return {
        GetValue = function(period, mode)
            return Line:New((x1:hasData(period) and x1:tick(period) or nil), 
                (x2:hasData(period) and x2:tick(period) or nil), b, (y:hasData(period) and y:tick(period) or nil)):SetColor(col);
        end
    };
end
function Create_DonCandles(high_, low_, close_, src_, factor_, candle_, length_)
    local local_vars = {};
    initial = instance:addInternalStream(0, 0);
    return {
        GetValue = function(period, mode)
            initial_value = 0.0;
            if initial_value then
                initial[period] = initial_value;
            else
                initial:setNoData(period);
            end
            if high_:first() > period - length_ then return; end
            Don_High = mathex.max(high_, core.rangeTo(period, length_));
            if low_:first() > period - length_ then return; end
            Don_Low = mathex.min(low_, core.rangeTo(period, length_));
            Norm = (SafeDivide((SafeMinus(close_:tick(period), Don_Low)), (SafeMinus(Don_High, Don_Low))));
            if initial:first() > period - 1 then return; end
            if initial:first() > period - 1 then return; end
            initial_value = ((candle_) and ((SafePlus(SafeMultiply(Norm, source.close:tick(period)), SafeMultiply(((SafeMinus(1, Norm))), Nz((initial:hasData(period - 1) and initial:tick(period - 1) or nil), source.close:tick(period)))))) or ((SafePlus(SafeMultiply(Norm, source.close:tick(period)), SafeMultiply(((SafeMinus(1, SafeMultiply(Norm, 2)))), Nz((initial:hasData(period - 1) and initial:tick(period - 1) or nil), source.close:tick(period)))))));
            if initial_value then
                initial[period] = initial_value;
            else
                initial:setNoData(period);
            end
            if initial:first() > period - 1 then return; end
            if initial:first() > period - 1 then return; end
            Factor = ((candle_) and (SafeMultiply((SafeMinus(1, Norm)), Nz((initial:hasData(period - 1) and initial:tick(period - 1) or nil), src_:tick(period)))) or (SafeMultiply((((factor_) and ((SafeMinus(1, SafeMultiply(Norm, 2)))) or ((SafeMinus(1, SafeDivide(Norm, 2)))))), Nz((initial:hasData(period - 1) and initial:tick(period - 1) or nil), src_:tick(period)))));
            output = SafePlus((SafeMultiply(Norm, src_:tick(period))), Factor);
            return output;
        end
    };
end
function Create_pricewick(h_, a)
    local local_vars = {};
    return {
        GetValue = function(period, mode)
            cond = SafeGreater((h_:hasData(period) and h_:tick(period) or nil), a:tick(period));
            return cond;
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
    vars["prd"] = instance.parameters.param1;
    vars["s1"] = instance.parameters.param2;
    vars["resp"] = instance.parameters.param3;
    vars["bull"] = instance.parameters.param4;
    vars["bull2"] = Graphics:AddTransparency(instance.parameters.param5, Graphics:GetTransparencyPercent(core.rgb(8, 236, 126)));
    vars["bull3"] = Graphics:AddTransparency(instance.parameters.param6, Graphics:GetTransparencyPercent(core.rgb(8, 236, 126)));
    vars["bear"] = instance.parameters.param7;
    vars["bear2"] = Graphics:AddTransparency(instance.parameters.param8, Graphics:GetTransparencyPercent(core.rgb(255, 34, 34)));
    vars["bear3"] = Graphics:AddTransparency(instance.parameters.param9, Graphics:GetTransparencyPercent(core.rgb(255, 34, 34)));
    vars["showPD"] = instance.parameters.param10;
    vars["prem"] = Graphics:AddTransparency(instance.parameters.param11, Graphics:GetTransparencyPercent(core.rgb(255, 34, 34) + math.floor(80 / 100 * 255) * 16777216));
    vars["disc"] = Graphics:AddTransparency(instance.parameters.param12, Graphics:GetTransparencyPercent(core.rgb(8, 236, 126) + math.floor(80 / 100 * 255) * 16777216));
    vars["don"] = instance.parameters.param13;
    vars["Candle"] = instance.parameters.param14;
    vars["length"] = instance.parameters.param15;
    Up = instance:addInternalStream(0, 0);
    Dn = instance:addInternalStream(0, 0);
    iUp = instance:addInternalStream(0, 0);
    iDn = instance:addInternalStream(0, 0);
    vars["__pivothigh1"] = CreatePivotHigh(source.high, vars["prd"], vars["prd"]);
    vars["__pivotlow1"] = CreatePivotLow(source.low, vars["prd"], vars["prd"]);
    pos = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc1_param1"] = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc1_param2"] = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc1"] = Create_CreateLabel(vars["CreateLabelFunc1_param1"], vars["CreateLabelFunc1_param2"], "CHoCH", vars["bull3"], true);
    vars["CreateLineFunc2_param1"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc2_param2"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc2_param3"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc2"] = Create_CreateLine(vars["CreateLineFunc2_param1"], vars["CreateLineFunc2_param2"], vars["CreateLineFunc2_param3"], vars["bull2"]);
    vars["CreateLabelFunc3_param1"] = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc3_param2"] = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc3"] = Create_CreateLabel(vars["CreateLabelFunc3_param1"], vars["CreateLabelFunc3_param2"], "SMS", vars["bull3"], true);
    vars["CreateLineFunc4_param1"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc4_param2"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc4_param3"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc4"] = Create_CreateLine(vars["CreateLineFunc4_param1"], vars["CreateLineFunc4_param2"], vars["CreateLineFunc4_param3"], vars["bull2"]);
    vars["CreateLabelFunc5_param1"] = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc5_param2"] = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc5"] = Create_CreateLabel(vars["CreateLabelFunc5_param1"], vars["CreateLabelFunc5_param2"], "BMS", vars["bull3"], true);
    vars["CreateLineFunc6_param1"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc6_param2"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc6_param3"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc6"] = Create_CreateLine(vars["CreateLineFunc6_param1"], vars["CreateLineFunc6_param2"], vars["CreateLineFunc6_param3"], vars["bull2"]);
    vars["CreateLabelFunc7_param1"] = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc7_param2"] = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc7"] = Create_CreateLabel(vars["CreateLabelFunc7_param1"], vars["CreateLabelFunc7_param2"], "CHoCH", vars["bear3"], false);
    vars["CreateLineFunc8_param1"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc8_param2"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc8_param3"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc8"] = Create_CreateLine(vars["CreateLineFunc8_param1"], vars["CreateLineFunc8_param2"], vars["CreateLineFunc8_param3"], vars["bear2"]);
    vars["CreateLabelFunc9_param1"] = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc9_param2"] = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc9"] = Create_CreateLabel(vars["CreateLabelFunc9_param1"], vars["CreateLabelFunc9_param2"], "SMS", vars["bear3"], false);
    vars["CreateLineFunc10_param1"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc10_param2"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc10_param3"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc10"] = Create_CreateLine(vars["CreateLineFunc10_param1"], vars["CreateLineFunc10_param2"], vars["CreateLineFunc10_param3"], vars["bear2"]);
    vars["CreateLabelFunc11_param1"] = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc11_param2"] = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc11"] = Create_CreateLabel(vars["CreateLabelFunc11_param1"], vars["CreateLabelFunc11_param2"], "BMS", vars["bear3"], false);
    vars["CreateLineFunc12_param1"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc12_param2"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc12_param3"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc12"] = Create_CreateLine(vars["CreateLineFunc12_param1"], vars["CreateLineFunc12_param2"], vars["CreateLineFunc12_param3"], vars["bear2"]);
    plot1 = instance:addStream("plot1", core.Line, "Range High", "Range High", vars["bear2"], 0, 0);
    plot1:setWidth(1);
    plot1:setStyle(core.LINE_SOLID);
    vars["r1"] = plot1;
    plot2 = instance:addStream("plot2", core.Line, "Range Low", "Range Low", vars["bull2"], 0, 0);
    plot2:setWidth(1);
    plot2:setStyle(core.LINE_SOLID);
    vars["r2"] = plot2;
    plot3 = instance:addStream("plot3", core.Line, "Premium", "Premium", core.colors().Blue, 0, 0);
    plot3:setWidth(1);
    plot3:setStyle(core.LINE_NONE);
    vars["p1"] = plot3;
    plot4 = instance:addStream("plot4", core.Line, "Premium", "Premium", core.colors().Blue, 0, 0);
    plot4:setWidth(1);
    plot4:setStyle(core.LINE_NONE);
    vars["p2"] = plot4;
    plot5 = instance:addStream("plot5", core.Line, "Discount", "Discount", core.colors().Blue, 0, 0);
    plot5:setWidth(1);
    plot5:setStyle(core.LINE_NONE);
    vars["d1"] = plot5;
    plot6 = instance:addStream("plot6", core.Line, "Discount", "Discount", core.colors().Blue, 0, 0);
    plot6:setWidth(1);
    plot6:setStyle(core.LINE_NONE);
    vars["d2"] = plot6;
    plot7 = instance:addStream("plot7", core.Line, "Equilibrium", "Equilibrium", core.colors().Blue, 0, 0);
    plot7:setWidth(1);
    plot7:setStyle(core.LINE_NONE);
    vars["m1"] = plot7;
    plot8 = instance:addStream("plot8", core.Line, "Equilibrium", "Equilibrium", core.colors().Blue, 0, 0);
    plot8:setWidth(1);
    plot8:setStyle(core.LINE_NONE);
    vars["m2"] = plot8;
    channel1_color = vars["prem"];
    instance:createChannelGroup("channel1", "channel1", vars["p1"], vars["p2"], Graphics:GetColor(channel1_color), 100 - Graphics:GetTransparencyPercent(channel1_color), true);
    channel2_color = vars["disc"];
    instance:createChannelGroup("channel2", "channel2", vars["d1"], vars["d2"], Graphics:GetColor(channel2_color), 100 - Graphics:GetTransparencyPercent(channel2_color), true);
    channel3_color = core.colors().Gray + math.floor(75 / 100 * 255) * 16777216;
    instance:createChannelGroup("channel3", "channel3", vars["m1"], vars["m2"], Graphics:GetColor(channel3_color), 100 - Graphics:GetTransparencyPercent(channel3_color), true);
    vars["DonCandlesFunc13_param1"] = instance:addInternalStream(0, 0);
    vars["DonCandlesFunc13_param2"] = instance:addInternalStream(0, 0);
    vars["DonCandlesFunc13"] = Create_DonCandles(vars["DonCandlesFunc13_param1"], vars["DonCandlesFunc13_param2"], source.close, source.open, true, false, vars["length"]);
    vars["DonCandlesFunc14_param1"] = instance:addInternalStream(0, 0);
    vars["DonCandlesFunc14_param2"] = instance:addInternalStream(0, 0);
    vars["DonCandlesFunc14"] = Create_DonCandles(vars["DonCandlesFunc14_param1"], vars["DonCandlesFunc14_param2"], source.close, source.high, false, false, vars["length"]);
    vars["DonCandlesFunc15_param1"] = instance:addInternalStream(0, 0);
    vars["DonCandlesFunc15_param2"] = instance:addInternalStream(0, 0);
    vars["DonCandlesFunc15"] = Create_DonCandles(vars["DonCandlesFunc15_param1"], vars["DonCandlesFunc15_param2"], source.close, source.low, false, false, vars["length"]);
    vars["DonCandlesFunc16_param1"] = instance:addInternalStream(0, 0);
    vars["DonCandlesFunc16_param2"] = instance:addInternalStream(0, 0);
    vars["DonCandlesFunc16"] = Create_DonCandles(vars["DonCandlesFunc16_param1"], vars["DonCandlesFunc16_param2"], source.close, source.close, true, false, vars["length"]);
    vars["pricewickFunc17_param1"] = instance:addInternalStream(0, 0);
    vars["pricewickFunc17"] = Create_pricewick(vars["pricewickFunc17_param1"], source.open);
    vars["pricewickFunc18_param1"] = instance:addInternalStream(0, 0);
    vars["pricewickFunc18"] = Create_pricewick(vars["pricewickFunc18_param1"], source.high);
    vars["pricewickFunc19_param1"] = instance:addInternalStream(0, 0);
    vars["pricewickFunc19"] = Create_pricewick(vars["pricewickFunc19_param1"], source.low);
    vars["pricewickFunc20_param1"] = instance:addInternalStream(0, 0);
    vars["pricewickFunc20"] = Create_pricewick(vars["pricewickFunc20_param1"], source.close);
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Label:Clear();
        Line:Clear();
        Up_value = Float(nil);
        if Up_value then
            Up[period] = Up_value;
        else
            Up:setNoData(period);
        end
        Dn_value = Float(nil);
        if Dn_value then
            Dn[period] = Dn_value;
        else
            Dn:setNoData(period);
        end
        iUp_value = Int(nil);
        if iUp_value then
            iUp[period] = iUp_value;
        else
            iUp:setNoData(period);
        end
        iDn_value = Int(nil);
        if iDn_value then
            iDn[period] = iDn_value;
        else
            iDn:setNoData(period);
        end
        pos_value = 0;
        if pos_value then
            pos[period] = pos_value;
        else
            pos:setNoData(period);
        end
    else
        Up_value = (Up:hasData(period - 1) and Up:tick(period - 1) or nil);
        if Up_value then
            Up[period] = Up_value;
        else
            Up:setNoData(period);
        end
        Dn_value = (Dn:hasData(period - 1) and Dn:tick(period - 1) or nil);
        if Dn_value then
            Dn[period] = Dn_value;
        else
            Dn:setNoData(period);
        end
        iUp_value = (iUp:hasData(period - 1) and iUp:tick(period - 1) or nil);
        if iUp_value then
            iUp[period] = iUp_value;
        else
            iUp:setNoData(period);
        end
        iDn_value = (iDn:hasData(period - 1) and iDn:tick(period - 1) or nil);
        if iDn_value then
            iDn[period] = iDn_value;
        else
            iDn:setNoData(period);
        end
        pos_value = (pos:hasData(period - 1) and pos:tick(period - 1) or nil);
        if pos_value then
            pos[period] = pos_value;
        else
            pos:setNoData(period);
        end
    end
    t1 = "Set the pivot period";
    t2 = "Set the response period. A low value returns a short-term structure and a high value returns a long-term structure. If you disable this option the pivot length above will be used.";
    t3 = "Enable the Donchian Channel.";
    t4 = "A high value returns the long-term structure and a low value returns the short-term structure.";
    b = period;
    if Up:first() > period - 1 then return; end
    Up_value = SafeMax((Up:hasData(period - 1) and Up:tick(period - 1) or nil), source.high:tick(period));
    if Up_value then
        Up[period] = Up_value;
    else
        Up:setNoData(period);
    end
    if Dn:first() > period - 1 then return; end
    Dn_value = SafeMin((Dn:hasData(period - 1) and Dn:tick(period - 1) or nil), source.low:tick(period));
    if Dn_value then
        Dn[period] = Dn_value;
    else
        Dn:setNoData(period);
    end
    pvtHi = vars["__pivothigh1"]:get(period);
    pvtLo = vars["__pivotlow1"]:get(period);
    if NumberToBool(pvtHi) then
        Up_value = pvtHi;
        if Up_value then
            Up[period] = Up_value;
        else
            Up:setNoData(period);
        end
    end
    if NumberToBool(pvtLo) then
        Dn_value = pvtLo;
        if Dn_value then
            Dn[period] = Dn_value;
        else
            Dn:setNoData(period);
        end
    end
    if Up:first() > period - 1 then return; end
    if Up:first() > period - 1 then return; end
    if SafeGreater((Up:hasData(period) and Up:tick(period) or nil), (Up:hasData(period - 1) and Up:tick(period - 1) or nil)) then
        iUp_value = b;
        if iUp_value then
            iUp[period] = iUp_value;
        else
            iUp:setNoData(period);
        end
        if iUp:first() > period - 1 then return; end
        centerBull = Round(SafeDivide((SafePlus((iUp:hasData(period - 1) and iUp:tick(period - 1) or nil), b)), 2));
        if Up:first() > period - 1 then return; end
        if Up:first() > period - 1 then return; end
        if Up:first() > period - ((vars["s1"]) and (vars["resp"]) or (vars["prd"])) then return; end
        if Up:first() > period - 1 then return; end
        if Up:first() > period - 1 then return; end
        if Up:first() > period - ((vars["s1"]) and (vars["resp"]) or (vars["prd"])) then return; end
        if ((pos:hasData(period) and pos:tick(period) or nil) <= 0) then
            if vars["bull"] then
                if Up:first() > period - 1 then return; end
                CreateLabelFunc1_param1_value = centerBull;
                if CreateLabelFunc1_param1_value then
                    vars["CreateLabelFunc1_param1"][period] = CreateLabelFunc1_param1_value;
                else
                    vars["CreateLabelFunc1_param1"]:setNoData(period);
                end
                CreateLabelFunc1_param2_value = (Up:hasData(period - 1) and Up:tick(period - 1) or nil);
                if CreateLabelFunc1_param2_value then
                    vars["CreateLabelFunc1_param2"][period] = CreateLabelFunc1_param2_value;
                else
                    vars["CreateLabelFunc1_param2"]:setNoData(period);
                end
                vars["CreateLabelFunc1"].GetValue(period, mode);
                if iUp:first() > period - 1 then return; end
                if Up:first() > period - 1 then return; end
                if Up:first() > period - 1 then return; end
                CreateLineFunc2_param1_value = (iUp:hasData(period - 1) and iUp:tick(period - 1) or nil);
                if CreateLineFunc2_param1_value then
                    vars["CreateLineFunc2_param1"][period] = CreateLineFunc2_param1_value;
                else
                    vars["CreateLineFunc2_param1"]:setNoData(period);
                end
                CreateLineFunc2_param2_value = (Up:hasData(period - 1) and Up:tick(period - 1) or nil);
                if CreateLineFunc2_param2_value then
                    vars["CreateLineFunc2_param2"][period] = CreateLineFunc2_param2_value;
                else
                    vars["CreateLineFunc2_param2"]:setNoData(period);
                end
                CreateLineFunc2_param3_value = (Up:hasData(period - 1) and Up:tick(period - 1) or nil);
                if CreateLineFunc2_param3_value then
                    vars["CreateLineFunc2_param3"][period] = CreateLineFunc2_param3_value;
                else
                    vars["CreateLineFunc2_param3"]:setNoData(period);
                end
                vars["CreateLineFunc2"].GetValue(period, mode);
            end
            pos_value = 1;
            if pos_value then
                pos[period] = pos_value;
            else
                pos:setNoData(period);
            end
        elseif ((pos:hasData(period) and pos:tick(period) or nil) == 1) and SafeGreater((Up:hasData(period) and Up:tick(period) or nil), (Up:hasData(period - 1) and Up:tick(period - 1) or nil)) and ((Up:hasData(period - 1) and Up:tick(period - 1) or nil) == (Up:hasData(period - ((vars["s1"]) and (vars["resp"]) or (vars["prd"]))) and Up:tick(period - ((vars["s1"]) and (vars["resp"]) or (vars["prd"]))) or nil)) then
            if vars["bull"] then
                if Up:first() > period - 1 then return; end
                CreateLabelFunc3_param1_value = centerBull;
                if CreateLabelFunc3_param1_value then
                    vars["CreateLabelFunc3_param1"][period] = CreateLabelFunc3_param1_value;
                else
                    vars["CreateLabelFunc3_param1"]:setNoData(period);
                end
                CreateLabelFunc3_param2_value = (Up:hasData(period - 1) and Up:tick(period - 1) or nil);
                if CreateLabelFunc3_param2_value then
                    vars["CreateLabelFunc3_param2"][period] = CreateLabelFunc3_param2_value;
                else
                    vars["CreateLabelFunc3_param2"]:setNoData(period);
                end
                vars["CreateLabelFunc3"].GetValue(period, mode);
                if iUp:first() > period - 1 then return; end
                if Up:first() > period - 1 then return; end
                if Up:first() > period - 1 then return; end
                CreateLineFunc4_param1_value = (iUp:hasData(period - 1) and iUp:tick(period - 1) or nil);
                if CreateLineFunc4_param1_value then
                    vars["CreateLineFunc4_param1"][period] = CreateLineFunc4_param1_value;
                else
                    vars["CreateLineFunc4_param1"]:setNoData(period);
                end
                CreateLineFunc4_param2_value = (Up:hasData(period - 1) and Up:tick(period - 1) or nil);
                if CreateLineFunc4_param2_value then
                    vars["CreateLineFunc4_param2"][period] = CreateLineFunc4_param2_value;
                else
                    vars["CreateLineFunc4_param2"]:setNoData(period);
                end
                CreateLineFunc4_param3_value = (Up:hasData(period - 1) and Up:tick(period - 1) or nil);
                if CreateLineFunc4_param3_value then
                    vars["CreateLineFunc4_param3"][period] = CreateLineFunc4_param3_value;
                else
                    vars["CreateLineFunc4_param3"]:setNoData(period);
                end
                vars["CreateLineFunc4"].GetValue(period, mode);
            end
            pos_value = 2;
            if pos_value then
                pos[period] = pos_value;
            else
                pos:setNoData(period);
            end
        elseif ((pos:hasData(period) and pos:tick(period) or nil) > 1) and SafeGreater((Up:hasData(period) and Up:tick(period) or nil), (Up:hasData(period - 1) and Up:tick(period - 1) or nil)) and ((Up:hasData(period - 1) and Up:tick(period - 1) or nil) == (Up:hasData(period - ((vars["s1"]) and (vars["resp"]) or (vars["prd"]))) and Up:tick(period - ((vars["s1"]) and (vars["resp"]) or (vars["prd"]))) or nil)) then
            if vars["bull"] then
                if Up:first() > period - 1 then return; end
                CreateLabelFunc5_param1_value = centerBull;
                if CreateLabelFunc5_param1_value then
                    vars["CreateLabelFunc5_param1"][period] = CreateLabelFunc5_param1_value;
                else
                    vars["CreateLabelFunc5_param1"]:setNoData(period);
                end
                CreateLabelFunc5_param2_value = (Up:hasData(period - 1) and Up:tick(period - 1) or nil);
                if CreateLabelFunc5_param2_value then
                    vars["CreateLabelFunc5_param2"][period] = CreateLabelFunc5_param2_value;
                else
                    vars["CreateLabelFunc5_param2"]:setNoData(period);
                end
                vars["CreateLabelFunc5"].GetValue(period, mode);
                if iUp:first() > period - 1 then return; end
                if Up:first() > period - 1 then return; end
                if Up:first() > period - 1 then return; end
                CreateLineFunc6_param1_value = (iUp:hasData(period - 1) and iUp:tick(period - 1) or nil);
                if CreateLineFunc6_param1_value then
                    vars["CreateLineFunc6_param1"][period] = CreateLineFunc6_param1_value;
                else
                    vars["CreateLineFunc6_param1"]:setNoData(period);
                end
                CreateLineFunc6_param2_value = (Up:hasData(period - 1) and Up:tick(period - 1) or nil);
                if CreateLineFunc6_param2_value then
                    vars["CreateLineFunc6_param2"][period] = CreateLineFunc6_param2_value;
                else
                    vars["CreateLineFunc6_param2"]:setNoData(period);
                end
                CreateLineFunc6_param3_value = (Up:hasData(period - 1) and Up:tick(period - 1) or nil);
                if CreateLineFunc6_param3_value then
                    vars["CreateLineFunc6_param3"][period] = CreateLineFunc6_param3_value;
                else
                    vars["CreateLineFunc6_param3"]:setNoData(period);
                end
                vars["CreateLineFunc6"].GetValue(period, mode);
            end
            pos_value = (pos:hasData(period) and pos:tick(period) or nil) + 1;
            if pos_value then
                pos[period] = pos_value;
            else
                pos:setNoData(period);
            end
        end
    elseif SafeLess((Up:hasData(period) and Up:tick(period) or nil), (Up:hasData(period - 1) and Up:tick(period - 1) or nil)) then
        iUp_value = b - vars["prd"];
        if iUp_value then
            iUp[period] = iUp_value;
        else
            iUp:setNoData(period);
        end
    end
    if Dn:first() > period - 1 then return; end
    if Dn:first() > period - 1 then return; end
    if SafeLess((Dn:hasData(period) and Dn:tick(period) or nil), (Dn:hasData(period - 1) and Dn:tick(period - 1) or nil)) then
        iDn_value = b;
        if iDn_value then
            iDn[period] = iDn_value;
        else
            iDn:setNoData(period);
        end
        if iDn:first() > period - 1 then return; end
        centerBear = Round(SafeDivide((SafePlus((iDn:hasData(period - 1) and iDn:tick(period - 1) or nil), b)), 2));
        if Dn:first() > period - 1 then return; end
        if Dn:first() > period - 1 then return; end
        if Dn:first() > period - ((vars["s1"]) and (vars["resp"]) or (vars["prd"])) then return; end
        if Dn:first() > period - 1 then return; end
        if Dn:first() > period - 1 then return; end
        if Dn:first() > period - ((vars["s1"]) and (vars["resp"]) or (vars["prd"])) then return; end
        if ((pos:hasData(period) and pos:tick(period) or nil) >= 0) then
            if vars["bear"] then
                if Dn:first() > period - 1 then return; end
                CreateLabelFunc7_param1_value = centerBear;
                if CreateLabelFunc7_param1_value then
                    vars["CreateLabelFunc7_param1"][period] = CreateLabelFunc7_param1_value;
                else
                    vars["CreateLabelFunc7_param1"]:setNoData(period);
                end
                CreateLabelFunc7_param2_value = (Dn:hasData(period - 1) and Dn:tick(period - 1) or nil);
                if CreateLabelFunc7_param2_value then
                    vars["CreateLabelFunc7_param2"][period] = CreateLabelFunc7_param2_value;
                else
                    vars["CreateLabelFunc7_param2"]:setNoData(period);
                end
                vars["CreateLabelFunc7"].GetValue(period, mode);
                if iDn:first() > period - 1 then return; end
                if Dn:first() > period - 1 then return; end
                if Dn:first() > period - 1 then return; end
                CreateLineFunc8_param1_value = (iDn:hasData(period - 1) and iDn:tick(period - 1) or nil);
                if CreateLineFunc8_param1_value then
                    vars["CreateLineFunc8_param1"][period] = CreateLineFunc8_param1_value;
                else
                    vars["CreateLineFunc8_param1"]:setNoData(period);
                end
                CreateLineFunc8_param2_value = (Dn:hasData(period - 1) and Dn:tick(period - 1) or nil);
                if CreateLineFunc8_param2_value then
                    vars["CreateLineFunc8_param2"][period] = CreateLineFunc8_param2_value;
                else
                    vars["CreateLineFunc8_param2"]:setNoData(period);
                end
                CreateLineFunc8_param3_value = (Dn:hasData(period - 1) and Dn:tick(period - 1) or nil);
                if CreateLineFunc8_param3_value then
                    vars["CreateLineFunc8_param3"][period] = CreateLineFunc8_param3_value;
                else
                    vars["CreateLineFunc8_param3"]:setNoData(period);
                end
                vars["CreateLineFunc8"].GetValue(period, mode);
            end
            pos_value = (-1);
            if pos_value then
                pos[period] = pos_value;
            else
                pos:setNoData(period);
            end
        elseif ((pos:hasData(period) and pos:tick(period) or nil) == (-1)) and SafeLess((Dn:hasData(period) and Dn:tick(period) or nil), (Dn:hasData(period - 1) and Dn:tick(period - 1) or nil)) and ((Dn:hasData(period - 1) and Dn:tick(period - 1) or nil) == (Dn:hasData(period - ((vars["s1"]) and (vars["resp"]) or (vars["prd"]))) and Dn:tick(period - ((vars["s1"]) and (vars["resp"]) or (vars["prd"]))) or nil)) then
            if vars["bear"] then
                if Dn:first() > period - 1 then return; end
                CreateLabelFunc9_param1_value = centerBear;
                if CreateLabelFunc9_param1_value then
                    vars["CreateLabelFunc9_param1"][period] = CreateLabelFunc9_param1_value;
                else
                    vars["CreateLabelFunc9_param1"]:setNoData(period);
                end
                CreateLabelFunc9_param2_value = (Dn:hasData(period - 1) and Dn:tick(period - 1) or nil);
                if CreateLabelFunc9_param2_value then
                    vars["CreateLabelFunc9_param2"][period] = CreateLabelFunc9_param2_value;
                else
                    vars["CreateLabelFunc9_param2"]:setNoData(period);
                end
                vars["CreateLabelFunc9"].GetValue(period, mode);
                if iDn:first() > period - 1 then return; end
                if Dn:first() > period - 1 then return; end
                if Dn:first() > period - 1 then return; end
                CreateLineFunc10_param1_value = (iDn:hasData(period - 1) and iDn:tick(period - 1) or nil);
                if CreateLineFunc10_param1_value then
                    vars["CreateLineFunc10_param1"][period] = CreateLineFunc10_param1_value;
                else
                    vars["CreateLineFunc10_param1"]:setNoData(period);
                end
                CreateLineFunc10_param2_value = (Dn:hasData(period - 1) and Dn:tick(period - 1) or nil);
                if CreateLineFunc10_param2_value then
                    vars["CreateLineFunc10_param2"][period] = CreateLineFunc10_param2_value;
                else
                    vars["CreateLineFunc10_param2"]:setNoData(period);
                end
                CreateLineFunc10_param3_value = (Dn:hasData(period - 1) and Dn:tick(period - 1) or nil);
                if CreateLineFunc10_param3_value then
                    vars["CreateLineFunc10_param3"][period] = CreateLineFunc10_param3_value;
                else
                    vars["CreateLineFunc10_param3"]:setNoData(period);
                end
                vars["CreateLineFunc10"].GetValue(period, mode);
            end
            pos_value = (-2);
            if pos_value then
                pos[period] = pos_value;
            else
                pos:setNoData(period);
            end
        elseif ((pos:hasData(period) and pos:tick(period) or nil) < (-1)) and SafeLess((Dn:hasData(period) and Dn:tick(period) or nil), (Dn:hasData(period - 1) and Dn:tick(period - 1) or nil)) and ((Dn:hasData(period - 1) and Dn:tick(period - 1) or nil) == (Dn:hasData(period - ((vars["s1"]) and (vars["resp"]) or (vars["prd"]))) and Dn:tick(period - ((vars["s1"]) and (vars["resp"]) or (vars["prd"]))) or nil)) then
            if vars["bear"] then
                if Dn:first() > period - 1 then return; end
                CreateLabelFunc11_param1_value = centerBear;
                if CreateLabelFunc11_param1_value then
                    vars["CreateLabelFunc11_param1"][period] = CreateLabelFunc11_param1_value;
                else
                    vars["CreateLabelFunc11_param1"]:setNoData(period);
                end
                CreateLabelFunc11_param2_value = (Dn:hasData(period - 1) and Dn:tick(period - 1) or nil);
                if CreateLabelFunc11_param2_value then
                    vars["CreateLabelFunc11_param2"][period] = CreateLabelFunc11_param2_value;
                else
                    vars["CreateLabelFunc11_param2"]:setNoData(period);
                end
                vars["CreateLabelFunc11"].GetValue(period, mode);
                if iDn:first() > period - 1 then return; end
                if Dn:first() > period - 1 then return; end
                if Dn:first() > period - 1 then return; end
                CreateLineFunc12_param1_value = (iDn:hasData(period - 1) and iDn:tick(period - 1) or nil);
                if CreateLineFunc12_param1_value then
                    vars["CreateLineFunc12_param1"][period] = CreateLineFunc12_param1_value;
                else
                    vars["CreateLineFunc12_param1"]:setNoData(period);
                end
                CreateLineFunc12_param2_value = (Dn:hasData(period - 1) and Dn:tick(period - 1) or nil);
                if CreateLineFunc12_param2_value then
                    vars["CreateLineFunc12_param2"][period] = CreateLineFunc12_param2_value;
                else
                    vars["CreateLineFunc12_param2"]:setNoData(period);
                end
                CreateLineFunc12_param3_value = (Dn:hasData(period - 1) and Dn:tick(period - 1) or nil);
                if CreateLineFunc12_param3_value then
                    vars["CreateLineFunc12_param3"][period] = CreateLineFunc12_param3_value;
                else
                    vars["CreateLineFunc12_param3"]:setNoData(period);
                end
                vars["CreateLineFunc12"].GetValue(period, mode);
            end
            pos_value = (pos:hasData(period) and pos:tick(period) or nil) - 1;
            if pos_value then
                pos[period] = pos_value;
            else
                pos:setNoData(period);
            end
        end
    elseif SafeGreater((Dn:hasData(period) and Dn:tick(period) or nil), (Dn:hasData(period - 1) and Dn:tick(period - 1) or nil)) then
        iDn_value = b - vars["prd"];
        if iDn_value then
            iDn[period] = iDn_value;
        else
            iDn:setNoData(period);
        end
    end
    PremiumTop = SafeMinus((Up:hasData(period) and Up:tick(period) or nil), SafeMultiply((SafeMinus((Up:hasData(period) and Up:tick(period) or nil), (Dn:hasData(period) and Dn:tick(period) or nil))), .1));
    PremiumBot = SafeMinus((Up:hasData(period) and Up:tick(period) or nil), SafeMultiply((SafeMinus((Up:hasData(period) and Up:tick(period) or nil), (Dn:hasData(period) and Dn:tick(period) or nil))), .25));
    DiscountTop = SafePlus((Dn:hasData(period) and Dn:tick(period) or nil), SafeMultiply((SafeMinus((Up:hasData(period) and Up:tick(period) or nil), (Dn:hasData(period) and Dn:tick(period) or nil))), .25));
    DiscountBot = SafePlus((Dn:hasData(period) and Dn:tick(period) or nil), SafeMultiply((SafeMinus((Up:hasData(period) and Up:tick(period) or nil), (Dn:hasData(period) and Dn:tick(period) or nil))), .1));
    MidTop = SafeMinus((Up:hasData(period) and Up:tick(period) or nil), SafeMultiply((SafeMinus((Up:hasData(period) and Up:tick(period) or nil), (Dn:hasData(period) and Dn:tick(period) or nil))), .45));
    MidBot = SafePlus((Dn:hasData(period) and Dn:tick(period) or nil), SafeMultiply((SafeMinus((Up:hasData(period) and Up:tick(period) or nil), (Dn:hasData(period) and Dn:tick(period) or nil))), .45));
    plot1[period] = ((vars["don"]) and ((Up:hasData(period) and Up:tick(period) or nil)) or (nil));
    plot2[period] = ((vars["don"]) and ((Dn:hasData(period) and Dn:tick(period) or nil)) or (nil));
    plot3[period] = ((vars["showPD"]) and (PremiumTop) or (nil));
    plot4[period] = ((vars["showPD"]) and (PremiumBot) or (nil));
    plot5[period] = ((vars["showPD"]) and (DiscountTop) or (nil));
    plot6[period] = ((vars["showPD"]) and (DiscountBot) or (nil));
    plot7[period] = ((vars["showPD"]) and (MidTop) or (nil));
    plot8[period] = ((vars["showPD"]) and (MidBot) or (nil));
    DonCandlesFunc13_param1_value = (Up:hasData(period) and Up:tick(period) or nil);
    if DonCandlesFunc13_param1_value then
        vars["DonCandlesFunc13_param1"][period] = DonCandlesFunc13_param1_value;
    else
        vars["DonCandlesFunc13_param1"]:setNoData(period);
    end
    DonCandlesFunc13_param2_value = (Dn:hasData(period) and Dn:tick(period) or nil);
    if DonCandlesFunc13_param2_value then
        vars["DonCandlesFunc13_param2"][period] = DonCandlesFunc13_param2_value;
    else
        vars["DonCandlesFunc13_param2"]:setNoData(period);
    end
    O = ((vars["Candle"]) and (vars["DonCandlesFunc13"].GetValue(period, mode)) or (nil));
    DonCandlesFunc14_param1_value = (Up:hasData(period) and Up:tick(period) or nil);
    if DonCandlesFunc14_param1_value then
        vars["DonCandlesFunc14_param1"][period] = DonCandlesFunc14_param1_value;
    else
        vars["DonCandlesFunc14_param1"]:setNoData(period);
    end
    DonCandlesFunc14_param2_value = (Dn:hasData(period) and Dn:tick(period) or nil);
    if DonCandlesFunc14_param2_value then
        vars["DonCandlesFunc14_param2"][period] = DonCandlesFunc14_param2_value;
    else
        vars["DonCandlesFunc14_param2"]:setNoData(period);
    end
    H = ((vars["Candle"]) and (vars["DonCandlesFunc14"].GetValue(period, mode)) or (nil));
    DonCandlesFunc15_param1_value = (Up:hasData(period) and Up:tick(period) or nil);
    if DonCandlesFunc15_param1_value then
        vars["DonCandlesFunc15_param1"][period] = DonCandlesFunc15_param1_value;
    else
        vars["DonCandlesFunc15_param1"]:setNoData(period);
    end
    DonCandlesFunc15_param2_value = (Dn:hasData(period) and Dn:tick(period) or nil);
    if DonCandlesFunc15_param2_value then
        vars["DonCandlesFunc15_param2"][period] = DonCandlesFunc15_param2_value;
    else
        vars["DonCandlesFunc15_param2"]:setNoData(period);
    end
    L = ((vars["Candle"]) and (vars["DonCandlesFunc15"].GetValue(period, mode)) or (nil));
    DonCandlesFunc16_param1_value = (Up:hasData(period) and Up:tick(period) or nil);
    if DonCandlesFunc16_param1_value then
        vars["DonCandlesFunc16_param1"][period] = DonCandlesFunc16_param1_value;
    else
        vars["DonCandlesFunc16_param1"]:setNoData(period);
    end
    DonCandlesFunc16_param2_value = (Dn:hasData(period) and Dn:tick(period) or nil);
    if DonCandlesFunc16_param2_value then
        vars["DonCandlesFunc16_param2"][period] = DonCandlesFunc16_param2_value;
    else
        vars["DonCandlesFunc16_param2"]:setNoData(period);
    end
    C = ((vars["Candle"]) and (vars["DonCandlesFunc16"].GetValue(period, mode)) or (nil));
    pricewickFunc17_param1_value = H;
    if pricewickFunc17_param1_value then
        vars["pricewickFunc17_param1"][period] = pricewickFunc17_param1_value;
    else
        vars["pricewickFunc17_param1"]:setNoData(period);
    end
    cond_open = vars["pricewickFunc17"].GetValue(period, mode);
    pricewickFunc18_param1_value = H;
    if pricewickFunc18_param1_value then
        vars["pricewickFunc18_param1"][period] = pricewickFunc18_param1_value;
    else
        vars["pricewickFunc18_param1"]:setNoData(period);
    end
    cond_high = vars["pricewickFunc18"].GetValue(period, mode);
    pricewickFunc19_param1_value = H;
    if pricewickFunc19_param1_value then
        vars["pricewickFunc19_param1"][period] = pricewickFunc19_param1_value;
    else
        vars["pricewickFunc19_param1"]:setNoData(period);
    end
    cond_low = vars["pricewickFunc19"].GetValue(period, mode);
    pricewickFunc20_param1_value = H;
    if pricewickFunc20_param1_value then
        vars["pricewickFunc20_param1"][period] = pricewickFunc20_param1_value;
    else
        vars["pricewickFunc20_param1"]:setNoData(period);
    end
    cond_close = vars["pricewickFunc20"].GetValue(period, mode);
    sign = ((((((cond_open or cond_high) or cond_low) or cond_close))) and (core.colors().Lime) or (core.colors().Red));
end
function Draw(stage, context)
    Label:Draw(stage, context);
    Line:Draw(stage, context);
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
end
Graphics = {};
Graphics.NextId = 2;
Graphics.Pens = {};
Graphics.Brushes = {};
Graphics.Fonts = {};
function Graphics:FindPen(width, color, style, context)
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
    if Graphics.Fonts[1] ~= nil then
        return Graphics.Fonts[1].Id;
    end
    local newFont = {};
    newFont.Id = Graphics.NextId;
    context:createFont(newFont.Id, "Arial", 0, context:pointsToPixels(10), context.LEFT);
    Graphics.NextId = Graphics.NextId + 1;
    Graphics.Fonts[#Graphics.Fonts + 1] = newFont;
    return newFont.Id;
end
function Graphics:SplitColorAndTransparency(clr)
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
    core.host:trace(math.floor(transparency * 100.0 / 255.0 + 0.5));
    return math.floor(transparency * 100.0 / 255.0 + 0.5);
end
function Graphics:AddTransparency(clr, transp)
    if clr == nil then
        return nil;
    end
    color, _ = Graphics:SplitColorAndTransparency(clr);
    return color + math.floor(transp / 100 * 255) * 16777216;
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
function SafeNegative(left)
    if left == nil then
        return nil;
    end
    return -left;
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
    if defaulValue == nil then
        defaulValue = 0;
    end
    return value and value or defaultValue;
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
Label = {};
Label.AllLabels = {};
Label.AllLabelsInOrder = {};
Label.AllSeries = {};
function Label:Clear()
    Label.AllLabels = {};
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
function Label:SetX(label, x)
    if label == nil then
        return;
    end
    label:SetX(x);
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
    newLabel.Style = "down";
    function newLabel:SetStyle(style)
        self.Style = style;
        return self;
    end
    function newLabel:getCoordinates(context, W, H)
        visible, y = context:pointOfPrice(self.Y);
        x1, x = context:positionOfBar(self.X)
        core.host:trace(self.Style);
        if self.Style == "left" then
            return x, y - H / 2, x + W, y + H / 2;
        end
        if self.Style == "down" then
            return x - W / 2, y - H, x + W / 2, y;
        end
        if self.Style == "up" then
            return x - W / 2, y, x + W / 2, y + H;
        end
        return x - W / 2, y - H / 2, x + W / 2, y + H / 2;
    end
    function newLabel:Draw(stage, context)
        if self.X == nil or self.Y == nil then
            return;
        end
        local W, H = context:measureText(Label.FontId, self.Text, context.LEFT);
        x_from, y_from, x_to, y_to = self:getCoordinates(context, W, H);
        if self.BGColor ~= nil then
            if self.BGPenId == nil then
                self.BGPenId = Graphics:FindPen(1, self.BGColor, core.LINE_SOLID, context);
            end
            if self.BGBrushId == nil then
                self.BGBrushId = Graphics:FindBrush(self.BGColor, context);
            end
            context:drawRectangle(self.BGPenId, self.BGBrushId, x_from - 1, y_from - 1, x_to + 1, y_to + 1, self.BgColorTransparency)
        end
        context:drawText(Label.FontId, self.Text, self.TextColor, -1, x_from, y_from, x_to, y_to, 0);
    end
    function newLabel:Get(index)
        return Label.AllSeries[self.SeriesId][index + 1];
    end
    self.AllLabels[id .. "_" .. seriesId] = newLabel;
    self.AllLabelsInOrder[#self.AllLabelsInOrder + 1] = newLabel
    if #self.AllLabelsInOrder > self.max_labels_count then
        table.remove(self.AllLines, 1);
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
    self:removeFromAllLabels(label);
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
function Label:removeFromAllLabels(label)
    for k, v in pairs(self.AllLabels) do
        if v == label then
            self.AllLabels[k] = nil;
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
    if Label.FontId == nil then
        Label.FontId = Graphics:FindFont("Arial", 0, context:pointsToPixels(10), context.LEFT, context);
    end
    for id, label in pairs(self.AllLabels) do
        label:Draw(stage, context);
    end
end
Line = {};
Line.AllLines = {};
function Line:Clear()
    Line.AllLines = {};
end
function Line:Prepare(max_lines_count)
    Line.max_lines_count = max_lines_count;
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
        x1 = self:converXToPoints(context, self.X1);
        x2 = self:converXToPoints(context, self.X2);
        _, y1 = context:pointOfPrice(self.Y1);
        _, y2 = context:pointOfPrice(self.Y2);
        if (x1 < context:left() and x2 < context:left()) then
            return;
        end
        context:drawLine(self.PenId, x1, y1, x2, y2, self.ColorTransparency);
        if self.Extend == "right" or self.Extend == "both" then
            local a, c = math2d.lineEquation(x1, y1, x2, y2);
            y3 = a * context:right() + c;
            context:drawLine(self.PenId, x2, y2, context:right(), y3, self.ColorTransparency);
        end
        if self.Extend == "left" or self.Extend == "both" then
            local a, c = math2d.lineEquation(x1, y1, x2, y2);
            y3 = a * context:left() + c;
            context:drawLine(self.PenId, x1, y1, context:left(), y3, self.ColorTransparency);
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