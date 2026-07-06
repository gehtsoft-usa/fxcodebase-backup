-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75326
--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                               https://appliedmachinelearning.systems/contact/  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+
 

local vars = {};
function Init()
    indicator:name("Smart Money Concepts Probability (Expo)");
    indicator:description("Smart Money Concepts Probability (Expo)");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    vars["t1"] = "Set the pivot period";
    indicator.parameters:addInteger("param1", "Structure Period", vars["t1"], 20, 1);
    indicator.parameters:addBoolean("param2", "Structure Response  ", "", true);
    vars["t2"] = "Set the response period. A low value returns a short-term structure and a high value returns a long-term structure. If you disable this option the pivot length above will be used.";
    indicator.parameters:addInteger("param3", "", vars["t2"], 7, 1);
    indicator.parameters:addBoolean("param4", "Bullish Structure     ", "", true);
    indicator.parameters:addColor("param5", "", "", Graphics:GetColor(core.rgb(8, 236, 126)));
    indicator.parameters:addColor("param6", "", "", Graphics:GetColor(core.rgb(8, 236, 126)));
    indicator.parameters:addBoolean("param7", "Bearish Structure    ", "", true);
    indicator.parameters:addColor("param8", "", "", Graphics:GetColor(core.rgb(255, 34, 34)));
    indicator.parameters:addColor("param9", "", "", Graphics:GetColor(core.rgb(255, 34, 34)));
    indicator.parameters:addBoolean("param10", "Premium & Discount", "", true);
    indicator.parameters:addColor("param11", "", "", Graphics:GetColor(core.rgb(255, 34, 34) + math.floor(80 / 100 * 255) * 16777216));
    indicator.parameters:addColor("param12", "", "", Graphics:GetColor(core.rgb(8, 236, 126) + math.floor(80 / 100 * 255) * 16777216));
    indicator.parameters:addString("param13", "", "", "Right");
    indicator.parameters:addStringAlternative("param13", "Left", "", "Left");
    indicator.parameters:addStringAlternative("param13", "Right", "", "Right");
    indicator.parameters:addBoolean("param14", "Ticker ID", "", true);
    indicator.parameters:addBoolean("param15", "Timeframe", "", true);
    indicator.parameters:addBoolean("param16", "Probability Percentage", "", true);
    signaler:Init(indicator.parameters);
end

local source;
function Create_CreateLabel_i_f_s_b(x, y, txt, col, z)
    local local_vars = {};
    Label:Prepare(500);
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            label_1_x = SafeGetFloat(x, period);
            return Label:New(core.formatDate(label_1_x and source:date(label_1_x) or 0) .. "_1", "1", label_1_x, SafeGetFloat(y, period)):SetText(txt.Value):SetColor(Color(nil)):SetTextColor(col):SetStyle(Triary(z, "down", "up"));
        end
    };
end
function Create_CreateLine_i_f_f(x1, x2, y, col)
    local local_vars = {};
    Line:Prepare(500);
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            return Line:New(SafeGetFloat(x1, period), SafeGetFloat(x2, period), b, SafeGetFloat(y, period)):SetColor(col);
        end
    };
end
function Create_Current_i(v)
    local local_vars = {};
    local_vars["str"] = "";
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            val1 = Float(nil);
            val2 = Float(nil);
            if (SafeGetFloat(v, period) >= 0) then
                if (SafeGetFloat(v, period) == 1) then
                    local_vars["str"] = "SMS: ";
                    val1 = Matrix:Get(vars["vals"], 0, 1);
                    val2 = Matrix:Get(vars["vals"], 0, 3);
                elseif (SafeGetFloat(v, period) == 2) then
                    local_vars["str"] = "BMS: ";
                    val1 = Matrix:Get(vars["vals"], 1, 1);
                    val2 = Matrix:Get(vars["vals"], 1, 3);
                elseif (SafeGetFloat(v, period) > 2) then
                    local_vars["str"] = "BMS: ";
                    val1 = Matrix:Get(vars["vals"], 2, 1);
                    val2 = Matrix:Get(vars["vals"], 2, 3);
                end
            elseif (SafeGetFloat(v, period) <= 0) then
                if (SafeGetFloat(v, period) == (-1)) then
                    local_vars["str"] = "SMS: ";
                    val1 = Matrix:Get(vars["vals"], 3, 1);
                    val2 = Matrix:Get(vars["vals"], 3, 3);
                elseif (SafeGetFloat(v, period) == (-2)) then
                    local_vars["str"] = "BMS: ";
                    val1 = Matrix:Get(vars["vals"], 4, 1);
                    val2 = Matrix:Get(vars["vals"], 4, 3);
                elseif (SafeGetFloat(v, period) < (-2)) then
                    local_vars["str"] = "BMS: ";
                    val1 = Matrix:Get(vars["vals"], 5, 1);
                    val2 = Matrix:Get(vars["vals"], 5, 3);
                end
            end
            return local_vars["str"], val1, val2;
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
    vars["t1"] = "Set the pivot period";
    vars["t2"] = "Set the response period. A low value returns a short-term structure and a high value returns a long-term structure. If you disable this option the pivot length above will be used.";
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
    vars["hlloc"] = instance.parameters.param13;
    vars["Up"] = instance:addInternalStream(0, 0);
    vars["Dn"] = instance:addInternalStream(0, 0);
    vars["iUp"] = instance:addInternalStream(0, 0);
    vars["iDn"] = instance:addInternalStream(0, 0);
    vars["__pivothigh1"] = CreatePivotHigh(source.high, vars["prd"], vars["prd"]);
    vars["__pivotlow1"] = CreatePivotLow(source.low, vars["prd"], vars["prd"]);
    vars["pos"] = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc1_param1"] = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc1_param2"] = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc1_param3"] = {};
    vars["CreateLabelFunc1"] = Create_CreateLabel_i_f_s_b(vars["CreateLabelFunc1_param1"], vars["CreateLabelFunc1_param2"], vars["CreateLabelFunc1_param3"], vars["bull3"], true);
    vars["CreateLineFunc2_param1"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc2_param2"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc2_param3"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc2"] = Create_CreateLine_i_f_f(vars["CreateLineFunc2_param1"], vars["CreateLineFunc2_param2"], vars["CreateLineFunc2_param3"], vars["bull2"]);
    vars["CreateLabelFunc3_param1"] = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc3_param2"] = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc3_param3"] = {};
    vars["CreateLabelFunc3"] = Create_CreateLabel_i_f_s_b(vars["CreateLabelFunc3_param1"], vars["CreateLabelFunc3_param2"], vars["CreateLabelFunc3_param3"], vars["bull3"], true);
    vars["CreateLineFunc4_param1"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc4_param2"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc4_param3"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc4"] = Create_CreateLine_i_f_f(vars["CreateLineFunc4_param1"], vars["CreateLineFunc4_param2"], vars["CreateLineFunc4_param3"], vars["bull2"]);
    vars["CreateLabelFunc5_param1"] = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc5_param2"] = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc5_param3"] = {};
    vars["CreateLabelFunc5"] = Create_CreateLabel_i_f_s_b(vars["CreateLabelFunc5_param1"], vars["CreateLabelFunc5_param2"], vars["CreateLabelFunc5_param3"], vars["bull3"], true);
    vars["CreateLineFunc6_param1"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc6_param2"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc6_param3"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc6"] = Create_CreateLine_i_f_f(vars["CreateLineFunc6_param1"], vars["CreateLineFunc6_param2"], vars["CreateLineFunc6_param3"], vars["bull2"]);
    vars["CreateLabelFunc7_param1"] = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc7_param2"] = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc7_param3"] = {};
    vars["CreateLabelFunc7"] = Create_CreateLabel_i_f_s_b(vars["CreateLabelFunc7_param1"], vars["CreateLabelFunc7_param2"], vars["CreateLabelFunc7_param3"], vars["bear3"], false);
    vars["CreateLineFunc8_param1"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc8_param2"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc8_param3"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc8"] = Create_CreateLine_i_f_f(vars["CreateLineFunc8_param1"], vars["CreateLineFunc8_param2"], vars["CreateLineFunc8_param3"], vars["bear2"]);
    vars["CreateLabelFunc9_param1"] = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc9_param2"] = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc9_param3"] = {};
    vars["CreateLabelFunc9"] = Create_CreateLabel_i_f_s_b(vars["CreateLabelFunc9_param1"], vars["CreateLabelFunc9_param2"], vars["CreateLabelFunc9_param3"], vars["bear3"], false);
    vars["CreateLineFunc10_param1"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc10_param2"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc10_param3"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc10"] = Create_CreateLine_i_f_f(vars["CreateLineFunc10_param1"], vars["CreateLineFunc10_param2"], vars["CreateLineFunc10_param3"], vars["bear2"]);
    vars["CreateLabelFunc11_param1"] = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc11_param2"] = instance:addInternalStream(0, 0);
    vars["CreateLabelFunc11_param3"] = {};
    vars["CreateLabelFunc11"] = Create_CreateLabel_i_f_s_b(vars["CreateLabelFunc11_param1"], vars["CreateLabelFunc11_param2"], vars["CreateLabelFunc11_param3"], vars["bear3"], false);
    vars["CreateLineFunc12_param1"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc12_param2"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc12_param3"] = instance:addInternalStream(0, 0);
    vars["CreateLineFunc12"] = Create_CreateLine_i_f_f(vars["CreateLineFunc12_param1"], vars["CreateLineFunc12_param2"], vars["CreateLineFunc12_param3"], vars["bear2"]);
    vars["CurrentFunc13_param1"] = instance:addInternalStream(0, 0);
    vars["CurrentFunc13"] = Create_Current_i(vars["CurrentFunc13_param1"]);
    signaler:Prepare(nameOnly);
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Table:Clear();
        Label:Clear();
        Line:Clear();
        Linefill:Clear();
        Box:Clear();
        vars["alert_bool"] = Array:NewBool():Push(instance.parameters.param14):Push(instance.parameters.param15):Push(instance.parameters.param16);
        SafeSetFloat(vars["Up"], period, Float(nil));
        SafeSetFloat(vars["Dn"], period, Float(nil));
        SafeSetFloat(vars["iUp"], period, Int(nil));
        SafeSetFloat(vars["iDn"], period, Int(nil));
        vars["vals"] = Matrix:NewFloat(9, 4, 0.0);
        vars["txt"] = Array:NewString(2, "");
        vars["tbl"] = Matrix:NewTable(1, 1, Table:New("1", "top_right", 2, 3):SetBorderWidth((-2)):SetBorderColor(core.colors().Bg_color):SetFrameColor(core.colors().Gray + math.floor(50 / 100 * 255) * 16777216):SetFrameWidth(3));
        SafeSetFloat(vars["pos"], period, 0);
        vars["CreateLabelFunc1"].Clear();
        vars["CreateLineFunc2"].Clear();
        vars["CreateLabelFunc3"].Clear();
        vars["CreateLineFunc4"].Clear();
        vars["CreateLabelFunc5"].Clear();
        vars["CreateLineFunc6"].Clear();
        vars["CreateLabelFunc7"].Clear();
        vars["CreateLineFunc8"].Clear();
        vars["CreateLabelFunc9"].Clear();
        vars["CreateLineFunc10"].Clear();
        vars["CreateLabelFunc11"].Clear();
        vars["CreateLineFunc12"].Clear();
        vars["CurrentFunc13"].Clear();
        vars["hi"] = Line:New(nil, nil, nil, nil):SetColor(vars["bear2"]);
        vars["lo"] = Line:New(nil, nil, nil, nil):SetColor(vars["bull2"]);
        vars["fill"] = Linefill:New(vars["hi"], vars["lo"]):SetColor(nil);
        vars["premium"] = Box:New(core.formatDate(source:date(0)), "1", nil, nil, nil, nil):SetBgColor(vars["prem"]):SetBorderColor(nil);
        vars["discount"] = Box:New(core.formatDate(source:date(0)), "2", nil, nil, nil, nil):SetBgColor(vars["disc"]):SetBorderColor(nil);
        vars["mid"] = Box:New(core.formatDate(source:date(0)), "3", nil, nil, nil, nil):SetBgColor(core.colors().Gray + math.floor(80 / 100 * 255) * 16777216):SetBorderColor(nil);
        label_2_x = nil;
        vars["prob1"] = Label:New(core.formatDate(label_2_x and source:date(label_2_x) or 0) .. "_2", "2", label_2_x, nil):SetText(nil):SetColor(Color(nil)):SetTextColor(core.COLOR_LABEL):SetStyle("left");
        label_3_x = nil;
        vars["prob2"] = Label:New(core.formatDate(label_3_x and source:date(label_3_x) or 0) .. "_3", "3", label_3_x, nil):SetText(nil):SetColor(Color(nil)):SetTextColor(core.COLOR_LABEL):SetStyle("left");
    else
        SafeSetFloat(vars["Up"], period, SafeGetFloat(vars["Up"], period - 1));
        SafeSetFloat(vars["Dn"], period, SafeGetFloat(vars["Dn"], period - 1));
        SafeSetFloat(vars["iUp"], period, SafeGetFloat(vars["iUp"], period - 1));
        SafeSetFloat(vars["iDn"], period, SafeGetFloat(vars["iDn"], period - 1));
        SafeSetFloat(vars["pos"], period, SafeGetFloat(vars["pos"], period - 1));
    end
    b = period;
    if vars["Up"]:first() > period - (1) then return; end
    SafeSetFloat(vars["Up"], period, SafeMax(SafeGetFloat(vars["Up"], period - 1), source.high:tick(period)));
    if vars["Dn"]:first() > period - (1) then return; end
    SafeSetFloat(vars["Dn"], period, SafeMin(SafeGetFloat(vars["Dn"], period - 1), source.low:tick(period)));
    pvtHi = vars["__pivothigh1"]:get(period);
    pvtLo = vars["__pivotlow1"]:get(period);
    if NumberToBool(pvtHi) then
        SafeSetFloat(vars["Up"], period, pvtHi);
    end
    if NumberToBool(pvtLo) then
        SafeSetFloat(vars["Dn"], period, pvtLo);
    end
    if vars["Up"]:first() > period - (1) then return; end
    if vars["Up"]:first() > period - (1) then return; end
    if SafeGreater(SafeGetFloat(vars["Up"], period), SafeGetFloat(vars["Up"], period - 1)) then
        SafeSetFloat(vars["iUp"], period, b);
        if vars["iUp"]:first() > period - (1) then return; end
        centerBull = Round(SafeDivide((SafePlus(SafeGetFloat(vars["iUp"], period - 1), b)), 2));
        if vars["Up"]:first() > period - (1) then return; end
        if vars["Up"]:first() > period - (1) then return; end
        if vars["Up"]:first() > period - (Triary(vars["s1"], vars["resp"], vars["prd"])) then return; end
        if vars["Up"]:first() > period - (1) then return; end
        if vars["Up"]:first() > period - (1) then return; end
        if vars["Up"]:first() > period - (Triary(vars["s1"], vars["resp"], vars["prd"])) then return; end
        if (SafeGetFloat(vars["pos"], period) <= 0) then
            if vars["bull"] then
                if vars["Up"]:first() > period - (1) then return; end
                vars["CreateLabelFunc1_param3"].Value = "CHoCH";
                SafeSetFloat(vars["CreateLabelFunc1_param1"], period, centerBull);
                SafeSetFloat(vars["CreateLabelFunc1_param2"], period, SafeGetFloat(vars["Up"], period - 1));
                vars["CreateLabelFunc1"].GetValue(period, mode);
                if vars["iUp"]:first() > period - (1) then return; end
                if vars["Up"]:first() > period - (1) then return; end
                if vars["Up"]:first() > period - (1) then return; end
                SafeSetFloat(vars["CreateLineFunc2_param1"], period, SafeGetFloat(vars["iUp"], period - 1));
                SafeSetFloat(vars["CreateLineFunc2_param2"], period, SafeGetFloat(vars["Up"], period - 1));
                SafeSetFloat(vars["CreateLineFunc2_param3"], period, SafeGetFloat(vars["Up"], period - 1));
                vars["CreateLineFunc2"].GetValue(period, mode);
            end
            SafeSetFloat(vars["pos"], period, 1);
            Matrix:Set(vars["vals"], 6, 0, SafePlus(Matrix:Get(vars["vals"], 6, 0), 1));
        elseif (SafeGetFloat(vars["pos"], period) == 1) and SafeGreater(SafeGetFloat(vars["Up"], period), SafeGetFloat(vars["Up"], period - 1)) and (SafeGetFloat(vars["Up"], period - 1) == SafeGetFloat(vars["Up"], period - Triary(vars["s1"], vars["resp"], vars["prd"]))) then
            if vars["bull"] then
                if vars["Up"]:first() > period - (1) then return; end
                vars["CreateLabelFunc3_param3"].Value = "SMS";
                SafeSetFloat(vars["CreateLabelFunc3_param1"], period, centerBull);
                SafeSetFloat(vars["CreateLabelFunc3_param2"], period, SafeGetFloat(vars["Up"], period - 1));
                vars["CreateLabelFunc3"].GetValue(period, mode);
                if vars["iUp"]:first() > period - (1) then return; end
                if vars["Up"]:first() > period - (1) then return; end
                if vars["Up"]:first() > period - (1) then return; end
                SafeSetFloat(vars["CreateLineFunc4_param1"], period, SafeGetFloat(vars["iUp"], period - 1));
                SafeSetFloat(vars["CreateLineFunc4_param2"], period, SafeGetFloat(vars["Up"], period - 1));
                SafeSetFloat(vars["CreateLineFunc4_param3"], period, SafeGetFloat(vars["Up"], period - 1));
                vars["CreateLineFunc4"].GetValue(period, mode);
            end
            SafeSetFloat(vars["pos"], period, 2);
            Matrix:Set(vars["vals"], 6, 1, SafePlus(Matrix:Get(vars["vals"], 6, 1), 1));
        elseif (SafeGetFloat(vars["pos"], period) > 1) and SafeGreater(SafeGetFloat(vars["Up"], period), SafeGetFloat(vars["Up"], period - 1)) and (SafeGetFloat(vars["Up"], period - 1) == SafeGetFloat(vars["Up"], period - Triary(vars["s1"], vars["resp"], vars["prd"]))) then
            if vars["bull"] then
                if vars["Up"]:first() > period - (1) then return; end
                vars["CreateLabelFunc5_param3"].Value = "BMS";
                SafeSetFloat(vars["CreateLabelFunc5_param1"], period, centerBull);
                SafeSetFloat(vars["CreateLabelFunc5_param2"], period, SafeGetFloat(vars["Up"], period - 1));
                vars["CreateLabelFunc5"].GetValue(period, mode);
                if vars["iUp"]:first() > period - (1) then return; end
                if vars["Up"]:first() > period - (1) then return; end
                if vars["Up"]:first() > period - (1) then return; end
                SafeSetFloat(vars["CreateLineFunc6_param1"], period, SafeGetFloat(vars["iUp"], period - 1));
                SafeSetFloat(vars["CreateLineFunc6_param2"], period, SafeGetFloat(vars["Up"], period - 1));
                SafeSetFloat(vars["CreateLineFunc6_param3"], period, SafeGetFloat(vars["Up"], period - 1));
                vars["CreateLineFunc6"].GetValue(period, mode);
            end
            SafeSetFloat(vars["pos"], period, SafeGetFloat(vars["pos"], period) + 1);
            Matrix:Set(vars["vals"], 6, 2, SafePlus(Matrix:Get(vars["vals"], 6, 2), 1));
        end
    elseif SafeLess(SafeGetFloat(vars["Up"], period), SafeGetFloat(vars["Up"], period - 1)) then
        SafeSetFloat(vars["iUp"], period, b - vars["prd"]);
    end
    if vars["Dn"]:first() > period - (1) then return; end
    if vars["Dn"]:first() > period - (1) then return; end
    if SafeLess(SafeGetFloat(vars["Dn"], period), SafeGetFloat(vars["Dn"], period - 1)) then
        SafeSetFloat(vars["iDn"], period, b);
        if vars["iDn"]:first() > period - (1) then return; end
        centerBear = Round(SafeDivide((SafePlus(SafeGetFloat(vars["iDn"], period - 1), b)), 2));
        if vars["Dn"]:first() > period - (1) then return; end
        if vars["Dn"]:first() > period - (1) then return; end
        if vars["Dn"]:first() > period - (Triary(vars["s1"], vars["resp"], vars["prd"])) then return; end
        if vars["Dn"]:first() > period - (1) then return; end
        if vars["Dn"]:first() > period - (1) then return; end
        if vars["Dn"]:first() > period - (Triary(vars["s1"], vars["resp"], vars["prd"])) then return; end
        if (SafeGetFloat(vars["pos"], period) >= 0) then
            if vars["bear"] then
                if vars["Dn"]:first() > period - (1) then return; end
                vars["CreateLabelFunc7_param3"].Value = "CHoCH";
                SafeSetFloat(vars["CreateLabelFunc7_param1"], period, centerBear);
                SafeSetFloat(vars["CreateLabelFunc7_param2"], period, SafeGetFloat(vars["Dn"], period - 1));
                vars["CreateLabelFunc7"].GetValue(period, mode);
                if vars["iDn"]:first() > period - (1) then return; end
                if vars["Dn"]:first() > period - (1) then return; end
                if vars["Dn"]:first() > period - (1) then return; end
                SafeSetFloat(vars["CreateLineFunc8_param1"], period, SafeGetFloat(vars["iDn"], period - 1));
                SafeSetFloat(vars["CreateLineFunc8_param2"], period, SafeGetFloat(vars["Dn"], period - 1));
                SafeSetFloat(vars["CreateLineFunc8_param3"], period, SafeGetFloat(vars["Dn"], period - 1));
                vars["CreateLineFunc8"].GetValue(period, mode);
            end
            SafeSetFloat(vars["pos"], period, (-1));
            Matrix:Set(vars["vals"], 7, 0, SafePlus(Matrix:Get(vars["vals"], 7, 0), 1));
        elseif (SafeGetFloat(vars["pos"], period) == (-1)) and SafeLess(SafeGetFloat(vars["Dn"], period), SafeGetFloat(vars["Dn"], period - 1)) and (SafeGetFloat(vars["Dn"], period - 1) == SafeGetFloat(vars["Dn"], period - Triary(vars["s1"], vars["resp"], vars["prd"]))) then
            if vars["bear"] then
                if vars["Dn"]:first() > period - (1) then return; end
                vars["CreateLabelFunc9_param3"].Value = "SMS";
                SafeSetFloat(vars["CreateLabelFunc9_param1"], period, centerBear);
                SafeSetFloat(vars["CreateLabelFunc9_param2"], period, SafeGetFloat(vars["Dn"], period - 1));
                vars["CreateLabelFunc9"].GetValue(period, mode);
                if vars["iDn"]:first() > period - (1) then return; end
                if vars["Dn"]:first() > period - (1) then return; end
                if vars["Dn"]:first() > period - (1) then return; end
                SafeSetFloat(vars["CreateLineFunc10_param1"], period, SafeGetFloat(vars["iDn"], period - 1));
                SafeSetFloat(vars["CreateLineFunc10_param2"], period, SafeGetFloat(vars["Dn"], period - 1));
                SafeSetFloat(vars["CreateLineFunc10_param3"], period, SafeGetFloat(vars["Dn"], period - 1));
                vars["CreateLineFunc10"].GetValue(period, mode);
            end
            SafeSetFloat(vars["pos"], period, (-2));
            Matrix:Set(vars["vals"], 7, 1, SafePlus(Matrix:Get(vars["vals"], 7, 1), 1));
        elseif (SafeGetFloat(vars["pos"], period) < (-1)) and SafeLess(SafeGetFloat(vars["Dn"], period), SafeGetFloat(vars["Dn"], period - 1)) and (SafeGetFloat(vars["Dn"], period - 1) == SafeGetFloat(vars["Dn"], period - Triary(vars["s1"], vars["resp"], vars["prd"]))) then
            if vars["bear"] then
                if vars["Dn"]:first() > period - (1) then return; end
                vars["CreateLabelFunc11_param3"].Value = "BMS";
                SafeSetFloat(vars["CreateLabelFunc11_param1"], period, centerBear);
                SafeSetFloat(vars["CreateLabelFunc11_param2"], period, SafeGetFloat(vars["Dn"], period - 1));
                vars["CreateLabelFunc11"].GetValue(period, mode);
                if vars["iDn"]:first() > period - (1) then return; end
                if vars["Dn"]:first() > period - (1) then return; end
                if vars["Dn"]:first() > period - (1) then return; end
                SafeSetFloat(vars["CreateLineFunc12_param1"], period, SafeGetFloat(vars["iDn"], period - 1));
                SafeSetFloat(vars["CreateLineFunc12_param2"], period, SafeGetFloat(vars["Dn"], period - 1));
                SafeSetFloat(vars["CreateLineFunc12_param3"], period, SafeGetFloat(vars["Dn"], period - 1));
                vars["CreateLineFunc12"].GetValue(period, mode);
            end
            SafeSetFloat(vars["pos"], period, SafeGetFloat(vars["pos"], period) - 1);
            Matrix:Set(vars["vals"], 7, 2, SafePlus(Matrix:Get(vars["vals"], 7, 2), 1));
        end
    elseif SafeGreater(SafeGetFloat(vars["Dn"], period), SafeGetFloat(vars["Dn"], period - 1)) then
        SafeSetFloat(vars["iDn"], period, b - vars["prd"]);
    end
    if NumberToBool(Change(vars["pos"], period, 1)) then
        if vars["pos"]:first() > period - (1) then return; end
        if vars["pos"]:first() > period - (1) then return; end
        if ((SafeGetFloat(vars["pos"], period) > 0) and SafeGreater(SafeGetFloat(vars["pos"], period - 1), 0) or (SafeGetFloat(vars["pos"], period) < 0) and SafeLess(SafeGetFloat(vars["pos"], period - 1), 0)) then
            if SafeLess(Matrix:Get(vars["vals"], 8, 0), Matrix:Get(vars["vals"], 8, 1)) then
                Matrix:Set(vars["vals"], 8, 2, SafePlus(Matrix:Get(vars["vals"], 8, 2), 1));
            else
                Matrix:Set(vars["vals"], 8, 3, SafePlus(Matrix:Get(vars["vals"], 8, 3), 1));
            end
        else
            if SafeGreater(Matrix:Get(vars["vals"], 8, 0), Matrix:Get(vars["vals"], 8, 1)) then
                Matrix:Set(vars["vals"], 8, 2, SafePlus(Matrix:Get(vars["vals"], 8, 2), 1));
            else
                Matrix:Set(vars["vals"], 8, 3, SafePlus(Matrix:Get(vars["vals"], 8, 3), 1));
            end
        end
        buC0 = Matrix:Get(vars["vals"], 0, 0);
        buC1 = Matrix:Get(vars["vals"], 0, 2);
        buS0 = Matrix:Get(vars["vals"], 1, 0);
        buS1 = Matrix:Get(vars["vals"], 1, 2);
        buB0 = Matrix:Get(vars["vals"], 2, 0);
        buB1 = Matrix:Get(vars["vals"], 2, 2);
        beC0 = Matrix:Get(vars["vals"], 3, 0);
        beC1 = Matrix:Get(vars["vals"], 3, 2);
        beS0 = Matrix:Get(vars["vals"], 4, 0);
        beS1 = Matrix:Get(vars["vals"], 4, 2);
        beB0 = Matrix:Get(vars["vals"], 5, 0);
        beB1 = Matrix:Get(vars["vals"], 5, 2);
        tbuC = Matrix:Get(vars["vals"], 6, 0);
        tbuS = Matrix:Get(vars["vals"], 6, 1);
        tbuB = Matrix:Get(vars["vals"], 6, 2);
        tbeC = Matrix:Get(vars["vals"], 7, 0);
        tbeS = Matrix:Get(vars["vals"], 7, 1);
        tbeB = Matrix:Get(vars["vals"], 7, 2);
        if vars["pos"]:first() > period - (1) then return; end
        if vars["pos"]:first() > period - (1) then return; end
        if (((SafeGetFloat(vars["pos"], period - 1) == 1) or (SafeGetFloat(vars["pos"], period - 1) == 0))) and (SafeGetFloat(vars["pos"], period) < 0) then
            Matrix:Set(vars["vals"], 0, 0, SafePlus(buC0, 1));
            Matrix:Set(vars["vals"], 0, 1, Round(SafeMultiply((SafeDivide((SafePlus(buC0, 1)), tbuC)), 100), 2));
        end
        if vars["pos"]:first() > period - (1) then return; end
        if vars["pos"]:first() > period - (1) then return; end
        if (((SafeGetFloat(vars["pos"], period - 1) == 1) or (SafeGetFloat(vars["pos"], period - 1) == 0))) and (SafeGetFloat(vars["pos"], period) == 2) then
            Matrix:Set(vars["vals"], 0, 2, SafePlus(buC1, 1));
            Matrix:Set(vars["vals"], 0, 3, Round(SafeMultiply((SafeDivide((SafePlus(buC1, 1)), tbuC)), 100), 2));
        end
        if vars["pos"]:first() > period - (1) then return; end
        if (SafeGetFloat(vars["pos"], period - 1) == 2) and (SafeGetFloat(vars["pos"], period) < 0) then
            Matrix:Set(vars["vals"], 1, 0, SafePlus(buS0, 1));
            Matrix:Set(vars["vals"], 1, 1, Round(SafeMultiply((SafeDivide((SafePlus(buS0, 1)), tbuS)), 100), 2));
        end
        if vars["pos"]:first() > period - (1) then return; end
        if (SafeGetFloat(vars["pos"], period - 1) == 2) and (SafeGetFloat(vars["pos"], period) > 2) then
            Matrix:Set(vars["vals"], 1, 2, SafePlus(buS1, 1));
            Matrix:Set(vars["vals"], 1, 3, Round(SafeMultiply((SafeDivide((SafePlus(buS1, 1)), tbuS)), 100), 2));
        end
        if vars["pos"]:first() > period - (1) then return; end
        if SafeGreater(SafeGetFloat(vars["pos"], period - 1), 2) and (SafeGetFloat(vars["pos"], period) < 0) then
            Matrix:Set(vars["vals"], 2, 0, SafePlus(buB0, 1));
            Matrix:Set(vars["vals"], 2, 1, Round(SafeMultiply((SafeDivide((SafePlus(buB0, 1)), tbuB)), 100), 2));
        end
        if vars["pos"]:first() > period - (1) then return; end
        if vars["pos"]:first() > period - (1) then return; end
        if SafeGreater(SafeGetFloat(vars["pos"], period - 1), 2) and SafeGreater(SafeGetFloat(vars["pos"], period), SafeGetFloat(vars["pos"], period - 1)) then
            Matrix:Set(vars["vals"], 2, 2, SafePlus(buB1, 1));
            Matrix:Set(vars["vals"], 2, 3, Round(SafeMultiply((SafeDivide((SafePlus(buB1, 1)), tbuB)), 100), 2));
        end
        if vars["pos"]:first() > period - (1) then return; end
        if vars["pos"]:first() > period - (1) then return; end
        if (((SafeGetFloat(vars["pos"], period - 1) == (-1)) or (SafeGetFloat(vars["pos"], period - 1) == 0))) and (SafeGetFloat(vars["pos"], period) > 0) then
            Matrix:Set(vars["vals"], 3, 0, SafePlus(beC0, 1));
            Matrix:Set(vars["vals"], 3, 1, Round(SafeMultiply((SafeDivide((SafePlus(beC0, 1)), tbeC)), 100), 2));
        end
        if vars["pos"]:first() > period - (1) then return; end
        if vars["pos"]:first() > period - (1) then return; end
        if (((SafeGetFloat(vars["pos"], period - 1) == (-1)) or (SafeGetFloat(vars["pos"], period - 1) == 0))) and (SafeGetFloat(vars["pos"], period) == (-2)) then
            Matrix:Set(vars["vals"], 3, 2, SafePlus(beC1, 1));
            Matrix:Set(vars["vals"], 3, 3, Round(SafeMultiply((SafeDivide((SafePlus(beC1, 1)), tbeC)), 100), 2));
        end
        if vars["pos"]:first() > period - (1) then return; end
        if (SafeGetFloat(vars["pos"], period - 1) == (-2)) and (SafeGetFloat(vars["pos"], period) > 0) then
            Matrix:Set(vars["vals"], 4, 0, SafePlus(beS0, 1));
            Matrix:Set(vars["vals"], 4, 1, Round(SafeMultiply((SafeDivide((SafePlus(beS0, 1)), tbeS)), 100), 2));
        end
        if vars["pos"]:first() > period - (1) then return; end
        if (SafeGetFloat(vars["pos"], period - 1) == (-2)) and (SafeGetFloat(vars["pos"], period) < (-2)) then
            Matrix:Set(vars["vals"], 4, 2, SafePlus(beS1, 1));
            Matrix:Set(vars["vals"], 4, 3, Round(SafeMultiply((SafeDivide((SafePlus(beS1, 1)), tbeS)), 100), 2));
        end
        if vars["pos"]:first() > period - (1) then return; end
        if SafeLess(SafeGetFloat(vars["pos"], period - 1), (-2)) and (SafeGetFloat(vars["pos"], period) > 0) then
            Matrix:Set(vars["vals"], 5, 0, SafePlus(beB0, 1));
            Matrix:Set(vars["vals"], 5, 1, Round(SafeMultiply((SafeDivide((SafePlus(beB0, 1)), tbeB)), 100), 2));
        end
        if vars["pos"]:first() > period - (1) then return; end
        if vars["pos"]:first() > period - (1) then return; end
        if SafeLess(SafeGetFloat(vars["pos"], period - 1), (-2)) and SafeLess(SafeGetFloat(vars["pos"], period), SafeGetFloat(vars["pos"], period - 1)) then
            Matrix:Set(vars["vals"], 5, 2, SafePlus(beB1, 1));
            Matrix:Set(vars["vals"], 5, 3, Round(SafeMultiply((SafeDivide((SafePlus(beB1, 1)), tbeB)), 100), 2));
        end
        SafeSetFloat(vars["CurrentFunc13_param1"], period, SafeGetFloat(vars["pos"], period));
        str_ret_val, val1_ret_val, val2_ret_val = vars["CurrentFunc13"].GetValue(period, mode);
        vars["str"] = str_ret_val;
        vars["val1"] = val1_ret_val;
        vars["val2"] = val2_ret_val;
        Array:Set(vars["txt"], 0, SafeConcat("CHoCH: ", Str:ToString(vars["val1"], "percent")));
        Array:Set(vars["txt"], 1, SafeConcat(vars["str"], Str:ToString(vars["val2"], "percent")));
        Matrix:Set(vars["vals"], 8, 0, vars["val1"]);
        Matrix:Set(vars["vals"], 8, 1, vars["val2"]);
        if Array:Includes(vars["alert_bool"], true) then
            vars["st1"] = SymInfo:GetTicker();
            vars["st2"] = Timeframe:Period();
            st3 = Str:ToString(Array:Join(vars["txt"], "\n"));
            str_vals = Array:NewString():Push(vars["st1"]):Push(vars["st2"]):Push(st3);
            output = Array:NewString(0, nil);
            local for1_from = 0;
            local for1_to = SafeMinus(vars["alert_bool"]:Size(), 1);
            local for1_step = for1_from < for1_to and 1 or -1;
            if not for1_from or not for1_to then return; end
            for x = for1_from, for1_to, for1_step do
                if Array:Get(vars["alert_bool"], x) then
                    output:Push(Array:Get(str_vals, x));
                end
            end
            if "once_per_bar_close" == "all" or vars["alert1_last_date"] ~= source:date(period) then
                vars["alert1_last_date"] = source:date(period);
                signaler:SignalEx(Array:Join(output, "\n"), period, source);
            end
        end
    end
    PremiumTop = SafeMinus(SafeGetFloat(vars["Up"], period), SafeMultiply((SafeMinus(SafeGetFloat(vars["Up"], period), SafeGetFloat(vars["Dn"], period))), .1));
    PremiumBot = SafeMinus(SafeGetFloat(vars["Up"], period), SafeMultiply((SafeMinus(SafeGetFloat(vars["Up"], period), SafeGetFloat(vars["Dn"], period))), .25));
    DiscountTop = SafePlus(SafeGetFloat(vars["Dn"], period), SafeMultiply((SafeMinus(SafeGetFloat(vars["Up"], period), SafeGetFloat(vars["Dn"], period))), .25));
    DiscountBot = SafePlus(SafeGetFloat(vars["Dn"], period), SafeMultiply((SafeMinus(SafeGetFloat(vars["Up"], period), SafeGetFloat(vars["Dn"], period))), .1));
    MidTop = SafeMinus(SafeGetFloat(vars["Up"], period), SafeMultiply((SafeMinus(SafeGetFloat(vars["Up"], period), SafeGetFloat(vars["Dn"], period))), .45));
    MidBot = SafePlus(SafeGetFloat(vars["Dn"], period), SafeMultiply((SafeMinus(SafeGetFloat(vars["Up"], period), SafeGetFloat(vars["Dn"], period))), .45));
    if period == source:size() - 1 and vars["showPD"] then
        loc = Triary((vars["hlloc"] == "Left"), SafeMin(SafeGetFloat(vars["iUp"], period), SafeGetFloat(vars["iDn"], period)), SafeMax(SafeGetFloat(vars["iUp"], period), SafeGetFloat(vars["iDn"], period)));
        Line:SetXY1(vars["hi"], loc, SafeGetFloat(vars["Up"], period));
        Line:SetXY2(vars["hi"], b, SafeGetFloat(vars["Up"], period));
        Line:SetXY1(vars["lo"], loc, SafeGetFloat(vars["Dn"], period));
        Line:SetXY2(vars["lo"], b, SafeGetFloat(vars["Dn"], period));
        Linefill:SetColor(vars["fill"], core.colors().Gray + math.floor(90 / 100 * 255) * 16777216);
        Box:SetLeftTop(vars["premium"], loc, PremiumTop);
        Box:SetRightBottom(vars["premium"], b, PremiumBot);
        Box:SetLeftTop(vars["discount"], loc, DiscountTop);
        Box:SetRightBottom(vars["discount"], b, DiscountBot);
        Box:SetLeftTop(vars["mid"], loc, MidTop);
        Box:SetRightBottom(vars["mid"], b, MidBot);
    end
    if period == source:size() - 1 then
        str1 = Triary((SafeGetFloat(vars["pos"], period) < 0), Array:Get(vars["txt"], 0), Array:Get(vars["txt"], 1));
        str2 = Triary((SafeGetFloat(vars["pos"], period) > 0), Array:Get(vars["txt"], 0), Array:Get(vars["txt"], 1));
        Label:SetXY(vars["prob1"], b, SafeGetFloat(vars["Up"], period));
        Label:SetText(vars["prob1"], str1);
        Label:SetXY(vars["prob2"], b, SafeGetFloat(vars["Dn"], period));
        Label:SetText(vars["prob2"], str2);
    end
    if period == source:size() - 1 then
        W = Matrix:Get(vars["vals"], 8, 2);
        L = Matrix:Get(vars["vals"], 8, 3);
        WR = Round(SafeMultiply(SafeDivide(W, (SafePlus(W, L))), 100), 2);
        tbl_vals = Array:NewString():Push(SafeConcat("WIN: ", Str:ToString(W))):Push(SafeConcat("LOSS: ", Str:ToString(L))):Push(SafeConcat("Profitability: ", Str:ToString(WR, "percent")));
        tbl_col = Array:NewColor():Push(core.colors().Green):Push(core.colors().Red):Push(core.COLOR_LABEL);
        local for2_from = 0;
        local for2_to = 2;
        local for2_step = for2_from < for2_to and 1 or -1;
        if not for2_from or not for2_to then return; end
        for i = for2_from, for2_to, for2_step do
            Table:CellText(Matrix:Get(vars["tbl"], 0, 0), 0, i, Array:Get(tbl_vals, i));
            Table:CellTextColor(Matrix:Get(vars["tbl"], 0, 0), 0, i, Array:Get(tbl_col, i));
            Table:CellTextSize(Matrix:Get(vars["tbl"], 0, 0), 0, i, "auto");
            Table:CellTextHAlign(Matrix:Get(vars["tbl"], 0, 0), 0, i, "center");
        end
    end
end
function Draw(stage, context)
    Table:Draw(stage, context);
    Label:Draw(stage, context);
    Line:Draw(stage, context);
    Linefill:Draw(stage, context);
    Box:Draw(stage, context);
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
    if not stream:hasData(period) then
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

Matrix = {};
function Matrix:Get(matrix, row, column)
    if matrix == nil then
        return nil;
    end
    return matrix:Get(row, column);
end
function Matrix:Set(matrix, row, column, value)
    if matrix == nil then
        return nil;
    end
    return matrix:Set(row, column, value);
end
function Matrix:NewFloat(rows, columns, initial_value)
    return Matrix:NewMatrix(rows, columns, initial_value);
end
function Matrix:NewTable(rows, columns, initial_value)
    return Matrix:NewMatrix(rows, columns, initial_value);
end
function Matrix:NewMatrix(rows, columns, initial_value)
    local matrix = {};
    matrix.rows = {};
    for i = 1, rows, 1 do
        matrix.rows[i] = {};
        for ii = 1, columns, 1 do
            matrix.rows[i][ii] = initial_value;
        end
    end
    function matrix:Get(row, column)
        return self.rows[row + 1][column + 1];
    end
    function matrix:Set(row, column, value)
        self.rows[row + 1][column + 1] = value;
    end
    return matrix;
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
function Array:NewArray(size, initialValue)
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
        local arrayCopy = Array:NewArray(self.size, nil);
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
    return Array:NewArray(size, initialValue);
end
function Array:NewInt(size, initialValue)
    return Array:NewArray(size, initialValue);
end
function Array:NewFloat(size, initialValue)
    return Array:NewArray(size, initialValue);
end
function Array:NewLabel(size, initialValue)
    return Array:NewArray(size, initialValue);
end
function Array:NewString(size, initialValue)
    return Array:NewArray(size, initialValue);
end
function Array:NewBox(size, initialValue)
    return Array:NewArray(size, initialValue);
end
function Array:NewBool(size, initialValue)
    return Array:NewArray(size, initialValue);
end
function Array:NewColor(size, initialValue)
    return Array:NewArray(size, initialValue);
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
    function newTable:drawCell(context, row, column, rowHeights, columnWidths, yStart, xStart)
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
        if self.BgBrushId ~= nil then
            context:drawRectangle(self.FramePenId, self.BgBrushId, rectangle_x1, rectangle_y1, rectangle_x2, rectangle_y2, self.bgcolor_transparency)
        end
        context:drawText(Table.FontId, self.rows[row][column].text, self.rows[row][column].text_color, -1, 
            text_x1, text_y1, text_x2, text_y2, 0);
    end
    function newTable:Draw(stage, context)
        if self.bgcolor ~= nil and self.BgBrushId == nil then
            self.BgBrushId = Graphics:FindBrush(self.bgcolor, context);
        end
        if self.FramePenId == nil then
            self.FramePenId = Graphics:FindPen(self.border_width, self.border_color, self.border_style, context);
        end
        local rowHeights, columnWidths, total_height, total_width = self:measureCells(context);
        
        local rowDirection = self:getRowDirection();
        local columnDirection = self:getColumnDirection();
        local yStart = rowDirection == 1 and context:top() or context:bottom() - total_height;
        local totalRows = #self.rows;
        for rowIt = 1, totalRows do
            local row = rowIt;
            local xStart = columnDirection == 1 and context:left() or (context:right() - total_width); 
            local totalCoumns = #self.rows[rowIt];
            for columnIt = 1, totalCoumns do
                local column = columnIt;
                if not self.rows[row][column].skip then
                    self:drawCell(context, row, column, rowHeights, columnWidths, yStart, xStart);
                end
                xStart = xStart + columnWidths[column];
            end
            yStart = yStart + rowHeights[row];
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
        local x1 = self:converXToPoints(context, self.X1);
        local x2 = self:converXToPoints(context, self.X2);
        local _, y1 = context:pointOfPrice(self.Y1);
        local _, y2 = context:pointOfPrice(self.Y2);
        context:drawLine(self.PenId, x1, y1, x2, y2, self.ColorTransparency);
        if self.Extend == "right" or self.Extend == "both" then
            local a, c = math2d.lineEquation(x1, y1, x2, y2);
            local y3 = a * context:right() + c;
            context:drawLine(self.PenId, x2, y2, context:right(), y3, self.ColorTransparency);
        end
        if self.Extend == "left" or self.Extend == "both" then
            local a, c = math2d.lineEquation(x1, y1, x2, y2);
            local y3 = a * context:left() + c;
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
function Change(source, period, length)
    if period < length then
        return nil;
    end
    if not source:hasData(period) or not source:hasData(period - length) then
        return nil;
    end
    return source[period] - source[period - length];
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
SymInfo = {};
function SymInfo:GetType()
    local offer = core.host:findTable("offers"):find("Instrument", instance.source:instrument());
    if offer == nil then
        return "";
    end
    if offer.InstrumentType == 1 then
        return "forex";
    elseif offer.InstrumentType == 2 then
        return "index";
    elseif offer.InstrumentType == 3 then
        return "commodity";
    elseif offer.InstrumentType == 4 then
        return "";
    elseif offer.InstrumentType == 5 then
        return "";
    elseif offer.InstrumentType == 6 then
        return "";
    elseif offer.InstrumentType == 7 then
        return "";
    elseif offer.InstrumentType == 8 then
        return "";
    elseif offer.InstrumentType == 9 then
        return "crypto";
    end
    return "";
end
function SymInfo:GetBaseCurrency()
    local offer = core.host:findTable("offers"):find("Instrument", instance.source:instrument());
    if offer == nil then
        return "";
    end
    return offer.ContractCurrency;
end
function SymInfo:GetCurrency()
    local offer = core.host:findTable("offers"):find("Instrument", instance.source:instrument());
    if offer == nil then
        return "";
    end
    return offer.Instrument;
end
function SymInfo:GetTicker()
    return instance.source:instrument();
end
Timeframe = {};
function Timeframe:Period()
    local bar_size = instance.source:barSize();
    if bar_size == "t1" then
        return "t";
    elseif string.sub(bar_size, 1, 1) == "m" then
        local seconds = 60 * tonumber(string.sub(bar_size, 2));
        return tostring(seconds);
    elseif string.sub(bar_size, 1, 1) == "H" then
        local seconds = 60 * 60 * tonumber(string.sub(bar_size, 2));
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
function signaler:SignalEx(message, period, source)
    source = self:getSource(getSource);
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
    source = self:getSource(getSource);
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
        _, y1 = context:pointOfPrice(self.Top);
        _, x1 = context:positionOfBar(self.Left);
        _, y2 = context:pointOfPrice(self.Bottom);
        _, x2 = context:positionOfBar(self.Right);
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
--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
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