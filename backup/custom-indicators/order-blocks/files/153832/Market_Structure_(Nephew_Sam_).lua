-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74457

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
local vars = {};
function Init()
    indicator:name("Market Structure (Nephew_Sam_)");
    indicator:description("Market Structure (Nephew_Sam_)");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("param1", "Pivot strength", "", 5);
    indicator.parameters:addBoolean("param2", "Show Zigzag", "", false);
    indicator.parameters:addBoolean("param3", "Show BOS Lines", "", false);
    indicator.parameters:addBoolean("param4", "Show HH/LL", "", true);
    indicator.parameters:addBoolean("param5", "Show Pattern Matches", "", true);
    indicator.parameters:addString("param6", "Bull 1", "", "LL,LH,LL,HH,HL");
    indicator.parameters:addString("param7", "", "", "BOS HL 1");
    indicator.parameters:addBoolean("param8", "", "", true);
    indicator.parameters:addString("param9", "Bull 2", "", "LL,LH,HL,LH,LL,HH,HL");
    indicator.parameters:addString("param10", "", "", "BOS HL 2");
    indicator.parameters:addBoolean("param11", "", "", true);
    indicator.parameters:addString("param12", "Bull 3", "", "LL,LH,LL,LH,HL,HH,HL");
    indicator.parameters:addString("param13", "", "", "BOS HL 3");
    indicator.parameters:addBoolean("param14", "", "", true);
    indicator.parameters:addString("param15", "Bull 4", "", "");
    indicator.parameters:addString("param16", "", "", "");
    indicator.parameters:addBoolean("param17", "", "", true);
    indicator.parameters:addString("param18", "Bull 5", "", "");
    indicator.parameters:addString("param19", "", "", "");
    indicator.parameters:addBoolean("param20", "", "", true);
    indicator.parameters:addString("param21", "Bull 6", "", "");
    indicator.parameters:addString("param22", "", "", "");
    indicator.parameters:addBoolean("param23", "", "", true);
    indicator.parameters:addString("param24", "Bull 7", "", "");
    indicator.parameters:addString("param25", "", "", "");
    indicator.parameters:addBoolean("param26", "", "", true);
    indicator.parameters:addString("param27", "Bear 1", "", "HH,HL,HH,LL,LH");
    indicator.parameters:addString("param28", "", "", "BOS LH 1");
    indicator.parameters:addBoolean("param29", "", "", true);
    indicator.parameters:addString("param30", "Bear 2", "", "HH,HL,LH,HL,HH,LL,LH");
    indicator.parameters:addString("param31", "", "", "BOS LH 2");
    indicator.parameters:addBoolean("param32", "", "", true);
    indicator.parameters:addString("param33", "Bear 3", "", "HH,HL,HH,HL,LH,LL,LH");
    indicator.parameters:addString("param34", "", "", "BOS LH 3");
    indicator.parameters:addBoolean("param35", "", "", true);
    indicator.parameters:addString("param36", "Bear 4", "", "");
    indicator.parameters:addString("param37", "", "", "");
    indicator.parameters:addBoolean("param38", "", "", true);
    indicator.parameters:addString("param39", "Bear 5", "", "");
    indicator.parameters:addString("param40", "", "", "");
    indicator.parameters:addBoolean("param41", "", "", true);
    indicator.parameters:addString("param42", "Bear 6", "", "");
    indicator.parameters:addString("param43", "", "", "");
    indicator.parameters:addBoolean("param44", "", "", true);
    indicator.parameters:addString("param45", "Bear 7", "", "");
    indicator.parameters:addString("param46", "", "", "");
    indicator.parameters:addBoolean("param47", "", "", true);
    indicator.parameters:addColor("param48", "HHLL Up Color", "", core.colors().Green);
    indicator.parameters:addColor("param49", "HHLL Down Color", "", core.colors().Red);
    indicator.parameters:addColor("param50", "Label Text Up Color", "", core.colors().White);
    indicator.parameters:addColor("param51", "Label Text Down Color", "", core.colors().White);
    indicator.parameters:addColor("param52", "Label BG Up Color", "", core.colors().Green);
    indicator.parameters:addColor("param53", "Label BG Down Color", "", core.colors().Red);
    indicator.parameters:addString("param54", "Zig Zag Line Style", "", "Dashed");
    indicator.parameters:addStringAlternative("param54", "Dashed", "", "Dashed");
    indicator.parameters:addStringAlternative("param54", "Dotted", "", "Dotted");
    indicator.parameters:addInteger("param55", "Zig zag Line Width", "", 1);
end

local source;
function Create_add_to_zigzag_f(arr, value)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            arr.Value:Unshift(SafeGetFloat(value, period));
            if SafeGreater(arr.Value:Size(), SafeGetFloat(vars["max_array_size"], period)) then
                return Array:Pop(arr.Value);
            end
        end
    };
end
function Create_add_to_zigzag_i(arr, value)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            arr.Value:Unshift(SafeGetFloat(value, period));
            if SafeGreater(arr.Value:Size(), SafeGetFloat(vars["max_array_size"], period)) then
                return Array:Pop(arr.Value);
            end
        end
    };
end
function Create_add_to_zigzag_s(arr, value)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            arr.Value:Unshift(value.Value);
            if SafeGreater(arr.Value:Size(), SafeGetFloat(vars["max_array_size"], period)) then
                return Array:Pop(arr.Value);
            end
        end
    };
end
function Create_update_zigzag_f_s_b(arr, value, __direction, _skip)
    local local_vars = {};
    local_vars["add_to_zigzagFunc5_param1"] = {};
    local_vars["add_to_zigzagFunc5"] = Create_add_to_zigzag_f(local_vars["add_to_zigzagFunc5_param1"], value);
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(period, mode)
            if firstCall then
                firstCall = false;
                local_vars["add_to_zigzagFunc5"].Clear();
            else
            end
            if (arr.Value:Size() == 0) then
                local_vars["add_to_zigzagFunc5_param1"].Value = arr.Value;
                return local_vars["add_to_zigzagFunc5"].GetValue(period, mode);
            else
                if _skip then
                    Array:Set(arr.Value, 0, SafeGetFloat(value, period));
                elseif ((__direction.Value == "ph") and SafeGreater(SafeGetFloat(value, period), Array:Get(arr.Value, 0)) or (__direction.Value == "pl") and SafeLess(SafeGetFloat(value, period), Array:Get(arr.Value, 0))) then
                    Array:Set(arr.Value, 0, SafeGetFloat(value, period));
                end
                return 0.;
            end
        end
    };
end
function Create_update_zigzag_i_s_b(arr, value, __direction, _skip)
    local local_vars = {};
    local_vars["add_to_zigzagFunc7_param1"] = {};
    local_vars["add_to_zigzagFunc7"] = Create_add_to_zigzag_f(local_vars["add_to_zigzagFunc7_param1"], value);
    local firstCall = true;
    return {
        Clear = function()
            firstCall = true;
        end,
        GetValue = function(period, mode)
            if firstCall then
                firstCall = false;
                local_vars["add_to_zigzagFunc7"].Clear();
            else
            end
            if (arr.Value:Size() == 0) then
                local_vars["add_to_zigzagFunc7_param1"].Value = arr.Value;
                return local_vars["add_to_zigzagFunc7"].GetValue(period, mode);
            else
                if _skip then
                    Array:Set(arr.Value, 0, SafeGetFloat(value, period));
                elseif ((__direction.Value == "ph") and SafeGreater(SafeGetFloat(value, period), Array:Get(arr.Value, 0)) or (__direction.Value == "pl") and SafeLess(SafeGetFloat(value, period), Array:Get(arr.Value, 0))) then
                    Array:Set(arr.Value, 0, SafeGetFloat(value, period));
                end
                return 0.;
            end
        end
    };
end
function Create_isMatching_s(_str, _arr)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            if (_str.Value == "") then
                return false;
            else
                hhll_join = Array:Join(_arr.Value, ",");
                _temp0 = Str:ReplaceAll(_str.Value, " ", "");
                _temp1 = Str:Upper(_str.Value);
                _temp2 = Str:Split(_str.Value, ",");
                Array:Reverse(_temp2);
                _temp3 = Array:Join(_temp2, ",");
                return Str:StartsWith(hhll_join, _temp3);
            end
        end
    };
end
function Create_addToString_s_s(_str, _val)
    local local_vars = {};
    return {
        Clear = function()
        end,
        GetValue = function(period, mode)
            _temp0 = Triary((_str.Value == ""), _str.Value, _str.Value .. "\n");
            return SafeConcat(_temp0, _val.Value);
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
    vars["length"] = instance.parameters.param1;
    vars["showzz"] = instance.parameters.param2;
    vars["showbosline"] = instance.parameters.param3;
    vars["showhhll"] = instance.parameters.param4;
    vars["showPatternMatch"] = instance.parameters.param5;
    vars["bullCond1"] = instance.parameters.param6;
    vars["bullTxt1"] = instance.parameters.param7;
    vars["bullBool1"] = instance.parameters.param8;
    vars["bullCond2"] = instance.parameters.param9;
    vars["bullTxt2"] = instance.parameters.param10;
    vars["bullBool2"] = instance.parameters.param11;
    vars["bullCond3"] = instance.parameters.param12;
    vars["bullTxt3"] = instance.parameters.param13;
    vars["bullBool3"] = instance.parameters.param14;
    vars["bullCond4"] = instance.parameters.param15;
    vars["bullTxt4"] = instance.parameters.param16;
    vars["bullBool4"] = instance.parameters.param17;
    vars["bullCond5"] = instance.parameters.param18;
    vars["bullTxt5"] = instance.parameters.param19;
    vars["bullBool5"] = instance.parameters.param20;
    vars["bullCond6"] = instance.parameters.param21;
    vars["bullTxt6"] = instance.parameters.param22;
    vars["bullBool6"] = instance.parameters.param23;
    vars["bullCond7"] = instance.parameters.param24;
    vars["bullTxt7"] = instance.parameters.param25;
    vars["bullBool7"] = instance.parameters.param26;
    vars["bearCond1"] = instance.parameters.param27;
    vars["bearTxt1"] = instance.parameters.param28;
    vars["bearBool1"] = instance.parameters.param29;
    vars["bearCond2"] = instance.parameters.param30;
    vars["bearTxt2"] = instance.parameters.param31;
    vars["bearBool2"] = instance.parameters.param32;
    vars["bearCond3"] = instance.parameters.param33;
    vars["bearTxt3"] = instance.parameters.param34;
    vars["bearBool3"] = instance.parameters.param35;
    vars["bearCond4"] = instance.parameters.param36;
    vars["bearTxt4"] = instance.parameters.param37;
    vars["bearBool4"] = instance.parameters.param38;
    vars["bearCond5"] = instance.parameters.param39;
    vars["bearTxt5"] = instance.parameters.param40;
    vars["bearBool5"] = instance.parameters.param41;
    vars["bearCond6"] = instance.parameters.param42;
    vars["bearTxt6"] = instance.parameters.param43;
    vars["bearBool6"] = instance.parameters.param44;
    vars["bearCond7"] = instance.parameters.param45;
    vars["bearTxt7"] = instance.parameters.param46;
    vars["bearBool7"] = instance.parameters.param47;
    vars["upcol"] = instance.parameters.param48;
    vars["dncol"] = instance.parameters.param49;
    vars["uplabeltextcol"] = instance.parameters.param50;
    vars["dnlabeltextcol"] = instance.parameters.param51;
    vars["uplabelcol"] = instance.parameters.param52;
    vars["dnlabelcol"] = instance.parameters.param53;
    vars["zzstyle"] = instance.parameters.param54;
    vars["zzwidth"] = instance.parameters.param55;
    vars["max_array_size"] = instance:addInternalStream(0, 0);
    vars["__highestbars1"] = CreateHighestBars(source.high, vars["length"]);
    vars["__lowestbars1"] = CreateLowestBars(source.low, vars["length"]);
    vars["add_to_zigzagFunc1_param1"] = {};
    vars["add_to_zigzagFunc1_param2"] = instance:addInternalStream(0, 0);
    vars["add_to_zigzagFunc1"] = Create_add_to_zigzag_f(vars["add_to_zigzagFunc1_param1"], vars["add_to_zigzagFunc1_param2"]);
    vars["add_to_zigzagFunc2_param1"] = {};
    vars["add_to_zigzagFunc2_param2"] = instance:addInternalStream(0, 0);
    vars["add_to_zigzagFunc2"] = Create_add_to_zigzag_i(vars["add_to_zigzagFunc2_param1"], vars["add_to_zigzagFunc2_param2"]);
    vars["add_to_zigzagFunc3_param1"] = {};
    vars["add_to_zigzagFunc3_param2"] = {};
    vars["add_to_zigzagFunc3"] = Create_add_to_zigzag_s(vars["add_to_zigzagFunc3_param1"], vars["add_to_zigzagFunc3_param2"]);
    vars["update_zigzagFunc4_param1"] = {};
    vars["update_zigzagFunc4_param2"] = instance:addInternalStream(0, 0);
    vars["update_zigzagFunc4_param3"] = {};
    vars["update_zigzagFunc4"] = Create_update_zigzag_f_s_b(vars["update_zigzagFunc4_param1"], vars["update_zigzagFunc4_param2"], vars["update_zigzagFunc4_param3"], false);
    vars["update_zigzagFunc6_param1"] = {};
    vars["update_zigzagFunc6_param2"] = instance:addInternalStream(0, 0);
    vars["update_zigzagFunc6_param3"] = {};
    vars["update_zigzagFunc6"] = Create_update_zigzag_i_s_b(vars["update_zigzagFunc6_param1"], vars["update_zigzagFunc6_param2"], vars["update_zigzagFunc6_param3"], true);
    Line:Prepare(50);
    Label:Prepare(500);
    vars["isMatchingFunc8_param1"] = {};
    vars["isMatchingFunc8_param2"] = {};
    vars["isMatchingFunc8"] = Create_isMatching_s(vars["isMatchingFunc8_param1"], vars["isMatchingFunc8_param2"]);
    vars["isMatchingFunc9_param1"] = {};
    vars["isMatchingFunc9_param2"] = {};
    vars["isMatchingFunc9"] = Create_isMatching_s(vars["isMatchingFunc9_param1"], vars["isMatchingFunc9_param2"]);
    vars["isMatchingFunc10_param1"] = {};
    vars["isMatchingFunc10_param2"] = {};
    vars["isMatchingFunc10"] = Create_isMatching_s(vars["isMatchingFunc10_param1"], vars["isMatchingFunc10_param2"]);
    vars["isMatchingFunc11_param1"] = {};
    vars["isMatchingFunc11_param2"] = {};
    vars["isMatchingFunc11"] = Create_isMatching_s(vars["isMatchingFunc11_param1"], vars["isMatchingFunc11_param2"]);
    vars["isMatchingFunc12_param1"] = {};
    vars["isMatchingFunc12_param2"] = {};
    vars["isMatchingFunc12"] = Create_isMatching_s(vars["isMatchingFunc12_param1"], vars["isMatchingFunc12_param2"]);
    vars["isMatchingFunc13_param1"] = {};
    vars["isMatchingFunc13_param2"] = {};
    vars["isMatchingFunc13"] = Create_isMatching_s(vars["isMatchingFunc13_param1"], vars["isMatchingFunc13_param2"]);
    vars["isMatchingFunc14_param1"] = {};
    vars["isMatchingFunc14_param2"] = {};
    vars["isMatchingFunc14"] = Create_isMatching_s(vars["isMatchingFunc14_param1"], vars["isMatchingFunc14_param2"]);
    vars["isMatchingFunc15_param1"] = {};
    vars["isMatchingFunc15_param2"] = {};
    vars["isMatchingFunc15"] = Create_isMatching_s(vars["isMatchingFunc15_param1"], vars["isMatchingFunc15_param2"]);
    vars["isMatchingFunc16_param1"] = {};
    vars["isMatchingFunc16_param2"] = {};
    vars["isMatchingFunc16"] = Create_isMatching_s(vars["isMatchingFunc16_param1"], vars["isMatchingFunc16_param2"]);
    vars["isMatchingFunc17_param1"] = {};
    vars["isMatchingFunc17_param2"] = {};
    vars["isMatchingFunc17"] = Create_isMatching_s(vars["isMatchingFunc17_param1"], vars["isMatchingFunc17_param2"]);
    vars["isMatchingFunc18_param1"] = {};
    vars["isMatchingFunc18_param2"] = {};
    vars["isMatchingFunc18"] = Create_isMatching_s(vars["isMatchingFunc18_param1"], vars["isMatchingFunc18_param2"]);
    vars["isMatchingFunc19_param1"] = {};
    vars["isMatchingFunc19_param2"] = {};
    vars["isMatchingFunc19"] = Create_isMatching_s(vars["isMatchingFunc19_param1"], vars["isMatchingFunc19_param2"]);
    vars["isMatchingFunc20_param1"] = {};
    vars["isMatchingFunc20_param2"] = {};
    vars["isMatchingFunc20"] = Create_isMatching_s(vars["isMatchingFunc20_param1"], vars["isMatchingFunc20_param2"]);
    vars["isMatchingFunc21_param1"] = {};
    vars["isMatchingFunc21_param2"] = {};
    vars["isMatchingFunc21"] = Create_isMatching_s(vars["isMatchingFunc21_param1"], vars["isMatchingFunc21_param2"]);
    vars["addToStringFunc22_param1"] = {};
    vars["addToStringFunc22_param2"] = {};
    vars["addToStringFunc22"] = Create_addToString_s_s(vars["addToStringFunc22_param1"], vars["addToStringFunc22_param2"]);
    vars["addToStringFunc23_param1"] = {};
    vars["addToStringFunc23_param2"] = {};
    vars["addToStringFunc23"] = Create_addToString_s_s(vars["addToStringFunc23_param1"], vars["addToStringFunc23_param2"]);
    vars["addToStringFunc24_param1"] = {};
    vars["addToStringFunc24_param2"] = {};
    vars["addToStringFunc24"] = Create_addToString_s_s(vars["addToStringFunc24_param1"], vars["addToStringFunc24_param2"]);
    vars["addToStringFunc25_param1"] = {};
    vars["addToStringFunc25_param2"] = {};
    vars["addToStringFunc25"] = Create_addToString_s_s(vars["addToStringFunc25_param1"], vars["addToStringFunc25_param2"]);
    vars["addToStringFunc26_param1"] = {};
    vars["addToStringFunc26_param2"] = {};
    vars["addToStringFunc26"] = Create_addToString_s_s(vars["addToStringFunc26_param1"], vars["addToStringFunc26_param2"]);
    vars["addToStringFunc27_param1"] = {};
    vars["addToStringFunc27_param2"] = {};
    vars["addToStringFunc27"] = Create_addToString_s_s(vars["addToStringFunc27_param1"], vars["addToStringFunc27_param2"]);
    vars["addToStringFunc28_param1"] = {};
    vars["addToStringFunc28_param2"] = {};
    vars["addToStringFunc28"] = Create_addToString_s_s(vars["addToStringFunc28_param1"], vars["addToStringFunc28_param2"]);
    vars["addToStringFunc29_param1"] = {};
    vars["addToStringFunc29_param2"] = {};
    vars["addToStringFunc29"] = Create_addToString_s_s(vars["addToStringFunc29_param1"], vars["addToStringFunc29_param2"]);
    vars["addToStringFunc30_param1"] = {};
    vars["addToStringFunc30_param2"] = {};
    vars["addToStringFunc30"] = Create_addToString_s_s(vars["addToStringFunc30_param1"], vars["addToStringFunc30_param2"]);
    vars["addToStringFunc31_param1"] = {};
    vars["addToStringFunc31_param2"] = {};
    vars["addToStringFunc31"] = Create_addToString_s_s(vars["addToStringFunc31_param1"], vars["addToStringFunc31_param2"]);
    vars["addToStringFunc32_param1"] = {};
    vars["addToStringFunc32_param2"] = {};
    vars["addToStringFunc32"] = Create_addToString_s_s(vars["addToStringFunc32_param1"], vars["addToStringFunc32_param2"]);
    vars["addToStringFunc33_param1"] = {};
    vars["addToStringFunc33_param2"] = {};
    vars["addToStringFunc33"] = Create_addToString_s_s(vars["addToStringFunc33_param1"], vars["addToStringFunc33_param2"]);
    vars["addToStringFunc34_param1"] = {};
    vars["addToStringFunc34_param2"] = {};
    vars["addToStringFunc34"] = Create_addToString_s_s(vars["addToStringFunc34_param1"], vars["addToStringFunc34_param2"]);
    vars["addToStringFunc35_param1"] = {};
    vars["addToStringFunc35_param2"] = {};
    vars["addToStringFunc35"] = Create_addToString_s_s(vars["addToStringFunc35_param1"], vars["addToStringFunc35_param2"]);
    vars["bosBearMatchPattern"] = "HL,HH,LL";
    vars["bosBullMatchPattern"] = "LH,LL,HH";
    vars["isMatchingFunc36_param1"] = {};
    vars["isMatchingFunc36_param2"] = {};
    vars["isMatchingFunc36"] = Create_isMatching_s(vars["isMatchingFunc36_param1"], vars["isMatchingFunc36_param2"]);
    vars["isMatchingFunc37_param1"] = {};
    vars["isMatchingFunc37_param2"] = {};
    vars["isMatchingFunc37"] = Create_isMatching_s(vars["isMatchingFunc37_param1"], vars["isMatchingFunc37_param2"]);
    instance:ownerDrawn(true);
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        Line:Clear();
        Label:Clear();
        Table:Clear();
        Str:Clear();
        vars["GRP1"] = Str:NewVar("Settings");
        vars["GRP2"] = Str:NewVar("Bull Patterns");
        vars["GRP3"] = Str:NewVar("Bear Patterns");
        vars["GRP4"] = Str:NewVar("Styles");
        SafeSetFloat(vars["max_array_size"], period, 10);
        vars["direction"] = Str:NewVar("na");
        vars["zigzag_price"] = Array:NewFloat(0, nil);
        vars["zigzag_barindex"] = Array:NewInt(0, nil);
        vars["zigzag_hhll"] = Array:NewString(0, nil);
        vars["add_to_zigzagFunc1"].Clear();
        vars["add_to_zigzagFunc2"].Clear();
        vars["add_to_zigzagFunc3"].Clear();
        vars["update_zigzagFunc4"].Clear();
        vars["update_zigzagFunc6"].Clear();
            vars["zzline"] = nil;
            vars["zzlabel"] = nil;
            vars["pattern_label_bull"] = nil;
            vars["pattern_label_bear"] = nil;
        vars["isMatchingFunc8"].Clear();
        vars["isMatchingFunc9"].Clear();
        vars["isMatchingFunc10"].Clear();
        vars["isMatchingFunc11"].Clear();
        vars["isMatchingFunc12"].Clear();
        vars["isMatchingFunc13"].Clear();
        vars["isMatchingFunc14"].Clear();
        vars["isMatchingFunc15"].Clear();
        vars["isMatchingFunc16"].Clear();
        vars["isMatchingFunc17"].Clear();
        vars["isMatchingFunc18"].Clear();
        vars["isMatchingFunc19"].Clear();
        vars["isMatchingFunc20"].Clear();
        vars["isMatchingFunc21"].Clear();
        vars["addToStringFunc22"].Clear();
        vars["addToStringFunc23"].Clear();
        vars["addToStringFunc24"].Clear();
        vars["addToStringFunc25"].Clear();
        vars["addToStringFunc26"].Clear();
        vars["addToStringFunc27"].Clear();
        vars["addToStringFunc28"].Clear();
        vars["addToStringFunc29"].Clear();
        vars["addToStringFunc30"].Clear();
        vars["addToStringFunc31"].Clear();
        vars["addToStringFunc32"].Clear();
        vars["addToStringFunc33"].Clear();
        vars["addToStringFunc34"].Clear();
        vars["addToStringFunc35"].Clear();
        vars["isMatchingFunc36"].Clear();
        vars["isMatchingFunc37"].Clear();
    else
        SafeSetString(vars["GRP1"], period, SafeGetString(vars["GRP1"], period - 1));
        SafeSetString(vars["GRP2"], period, SafeGetString(vars["GRP2"], period - 1));
        SafeSetString(vars["GRP3"], period, SafeGetString(vars["GRP3"], period - 1));
        SafeSetString(vars["GRP4"], period, SafeGetString(vars["GRP4"], period - 1));
        SafeSetFloat(vars["max_array_size"], period, SafeGetFloat(vars["max_array_size"], period - 1));
        SafeSetString(vars["direction"], period, SafeGetString(vars["direction"], period - 1));
    end
    pivoth = Triary((vars["__highestbars1"]:get(period) == 0), source.high:tick(period), nil);
    pivotl = Triary((vars["__lowestbars1"]:get(period) == 0), source.low:tick(period), nil);
    iff_ = Triary(NumberToBool(pivotl) and pivoth == nil, "pl", SafeGetString(vars["direction"], period));
    SafeSetString(vars["direction"], period, Triary(NumberToBool(pivoth) and pivotl == nil, "ph", iff_));
    oldzigzag_price = Array:Copy(vars["zigzag_price"]);
    oldzigzag_barindex = Array:Copy(vars["zigzag_barindex"]);
    oldzigzag_hhll = Array:Copy(vars["zigzag_hhll"]);
    direction_changed = (SafeGetString(vars["direction"], period) ~= SafeGetString(vars["direction"], period - 1));
    if (NumberToBool(pivoth) or NumberToBool(pivotl)) then
        if direction_changed then
            vars["add_to_zigzagFunc1_param1"].Value = vars["zigzag_price"];
            SafeSetFloat(vars["add_to_zigzagFunc1_param2"], period, Triary((SafeGetString(vars["direction"], period) == "ph"), pivoth, pivotl));
            vars["add_to_zigzagFunc1"].GetValue(period, mode);
            vars["add_to_zigzagFunc2_param1"].Value = vars["zigzag_barindex"];
            SafeSetFloat(vars["add_to_zigzagFunc2_param2"], period, period);
            vars["add_to_zigzagFunc2"].GetValue(period, mode);
            if SafeGE(vars["zigzag_price"]:Size(), 3) then
                _text = Triary((SafeGetString(vars["direction"], period) == "ph"), Triary(SafeGreater(Array:Get(vars["zigzag_price"], 0), Array:Get(vars["zigzag_price"], 2)), "HH", "LH"), Triary(SafeLess(Array:Get(vars["zigzag_price"], 0), Array:Get(vars["zigzag_price"], 2)), "LL", "HL"));
                vars["add_to_zigzagFunc3_param1"].Value = vars["zigzag_hhll"];
                vars["add_to_zigzagFunc3_param2"].Value = _text;
                vars["add_to_zigzagFunc3"].GetValue(period, mode);
            end
        else
            vars["update_zigzagFunc4_param1"].Value = vars["zigzag_price"];
            vars["update_zigzagFunc4_param3"].Value = SafeGetString(vars["direction"], period);
            SafeSetFloat(vars["update_zigzagFunc4_param2"], period, Triary((SafeGetString(vars["direction"], period) == "ph"), pivoth, pivotl));
            vars["update_zigzagFunc4"].GetValue(period, mode);
            vars["update_zigzagFunc6_param1"].Value = vars["zigzag_barindex"];
            vars["update_zigzagFunc6_param3"].Value = SafeGetString(vars["direction"], period);
            SafeSetFloat(vars["update_zigzagFunc6_param2"], period, period);
            vars["update_zigzagFunc6"].GetValue(period, mode);
            if SafeGE(vars["zigzag_price"]:Size(), 3) then
                _text = Triary((SafeGetString(vars["direction"], period) == "ph"), Triary(SafeGreater(Array:Get(vars["zigzag_price"], 0), Array:Get(vars["zigzag_price"], 2)), "HH", "LH"), Triary(SafeLess(Array:Get(vars["zigzag_price"], 0), Array:Get(vars["zigzag_price"], 2)), "LL", "HL"));
                Array:Set(vars["zigzag_hhll"], 0, _text);
            end
        end
    end
    if SafeGE(vars["zigzag_price"]:Size(), 3) and SafeGE(vars["zigzag_hhll"]:Size(), 3) then
        price0 = Array:Get(vars["zigzag_price"], 0);
        price1 = Array:Get(vars["zigzag_price"], 1);
        price2 = Array:Get(vars["zigzag_price"], 2);
        old_price0 = Array:Get(oldzigzag_price, 0);
        old_price1 = Array:Get(oldzigzag_price, 1);
        barindex0 = Round(Array:Get(vars["zigzag_barindex"], 0));
        barindex1 = Round(Array:Get(vars["zigzag_barindex"], 1));
        old_barindex0 = Round(Array:Get(oldzigzag_barindex, 0));
        old_barindex1 = Round(Array:Get(oldzigzag_barindex, 1));
        zigzag0 = Array:Get(vars["zigzag_hhll"], 0);
        zigzag1 = Array:Get(vars["zigzag_hhll"], 1);
        old_zigzag0 = Array:Get(oldzigzag_hhll, 0);
        old_zigzag1 = Array:Get(oldzigzag_hhll, 1);
        hhlltxt = Triary((SafeGetString(vars["direction"], period) == "ph"), Triary(SafeGreater(price0, price2), "HH", "LH"), Triary(SafeLess(price0, price2), "LL", "HL"));
        txtcol = Triary((SafeGetString(vars["direction"], period) == "ph"), Triary(SafeGreater(price0, price2), vars["upcol"], vars["dncol"]), Triary(SafeLess(price0, price2), vars["dncol"], vars["upcol"]));
        if (price0 ~= old_price0) and (barindex0 ~= old_barindex0) then
            if (price1 == old_price1) and (barindex1 == old_barindex1) then
                Line:Delete(vars["zzline"]);
                Label:Delete(vars["zzlabel"]);
                Label:Delete(vars["pattern_label_bull"]);
                Label:Delete(vars["pattern_label_bear"]);
            end
            if vars["showzz"] then
                vars["zzline"] = Line:New(barindex0, price0, barindex1, price1):SetColor(Triary((SafeGetString(vars["direction"], period) == "ph"), vars["upcol"], vars["dncol"])):SetStyle(Triary((vars["zzstyle"] == "Dashed"), "dashed", "dotted")):SetWidth(vars["zzwidth"]);
            end
            if vars["showhhll"] then
                label_1_x = barindex0;
                vars["zzlabel"] = Label:New(core.formatDate(label_1_x and source:date(label_1_x) or 0) .. "_1", "1", label_1_x, price0):SetText(hhlltxt):SetTextColor(txtcol):SetStyle("none");
            end
            if vars["showPatternMatch"] then
                vars["isMatchingFunc8_param1"].Value = vars["bullCond1"];
                vars["isMatchingFunc8_param2"].Value = vars["zigzag_hhll"];
                bull1Met = Triary(vars["bullBool1"], vars["isMatchingFunc8"].GetValue(period, mode), false);
                vars["isMatchingFunc9_param1"].Value = vars["bullCond2"];
                vars["isMatchingFunc9_param2"].Value = vars["zigzag_hhll"];
                bull2Met = Triary(vars["bullBool2"], vars["isMatchingFunc9"].GetValue(period, mode), false);
                vars["isMatchingFunc10_param1"].Value = vars["bullCond3"];
                vars["isMatchingFunc10_param2"].Value = vars["zigzag_hhll"];
                bull3Met = Triary(vars["bullBool3"], vars["isMatchingFunc10"].GetValue(period, mode), false);
                vars["isMatchingFunc11_param1"].Value = vars["bullCond4"];
                vars["isMatchingFunc11_param2"].Value = vars["zigzag_hhll"];
                bull4Met = Triary(vars["bullBool4"], vars["isMatchingFunc11"].GetValue(period, mode), false);
                vars["isMatchingFunc12_param1"].Value = vars["bullCond5"];
                vars["isMatchingFunc12_param2"].Value = vars["zigzag_hhll"];
                bull5Met = Triary(vars["bullBool5"], vars["isMatchingFunc12"].GetValue(period, mode), false);
                vars["isMatchingFunc13_param1"].Value = vars["bullCond6"];
                vars["isMatchingFunc13_param2"].Value = vars["zigzag_hhll"];
                bull6Met = Triary(vars["bullBool6"], vars["isMatchingFunc13"].GetValue(period, mode), false);
                vars["isMatchingFunc14_param1"].Value = vars["bullCond7"];
                vars["isMatchingFunc14_param2"].Value = vars["zigzag_hhll"];
                bull7Met = Triary(vars["bullBool7"], vars["isMatchingFunc14"].GetValue(period, mode), false);
                vars["isMatchingFunc15_param1"].Value = vars["bearCond1"];
                vars["isMatchingFunc15_param2"].Value = vars["zigzag_hhll"];
                bear1Met = Triary(vars["bearBool1"], vars["isMatchingFunc15"].GetValue(period, mode), false);
                vars["isMatchingFunc16_param1"].Value = vars["bearCond2"];
                vars["isMatchingFunc16_param2"].Value = vars["zigzag_hhll"];
                bear2Met = Triary(vars["bearBool2"], vars["isMatchingFunc16"].GetValue(period, mode), false);
                vars["isMatchingFunc17_param1"].Value = vars["bearCond3"];
                vars["isMatchingFunc17_param2"].Value = vars["zigzag_hhll"];
                bear3Met = Triary(vars["bearBool3"], vars["isMatchingFunc17"].GetValue(period, mode), false);
                vars["isMatchingFunc18_param1"].Value = vars["bearCond4"];
                vars["isMatchingFunc18_param2"].Value = vars["zigzag_hhll"];
                bear4Met = Triary(vars["bearBool4"], vars["isMatchingFunc18"].GetValue(period, mode), false);
                vars["isMatchingFunc19_param1"].Value = vars["bearCond5"];
                vars["isMatchingFunc19_param2"].Value = vars["zigzag_hhll"];
                bear5Met = Triary(vars["bearBool5"], vars["isMatchingFunc19"].GetValue(period, mode), false);
                vars["isMatchingFunc20_param1"].Value = vars["bearCond6"];
                vars["isMatchingFunc20_param2"].Value = vars["zigzag_hhll"];
                bear6Met = Triary(vars["bearBool6"], vars["isMatchingFunc20"].GetValue(period, mode), false);
                vars["isMatchingFunc21_param1"].Value = vars["bearCond7"];
                vars["isMatchingFunc21_param2"].Value = vars["zigzag_hhll"];
                bear7Met = Triary(vars["bearBool7"], vars["isMatchingFunc21"].GetValue(period, mode), false);
                bullPatternText = "";
                vars["addToStringFunc22_param1"].Value = bullPatternText;
                vars["addToStringFunc22_param2"].Value = vars["bullTxt1"];
                bullPatternText = Triary(bull1Met, vars["addToStringFunc22"].GetValue(period, mode), bullPatternText);
                vars["addToStringFunc23_param1"].Value = bullPatternText;
                vars["addToStringFunc23_param2"].Value = vars["bullTxt2"];
                bullPatternText = Triary(bull2Met, vars["addToStringFunc23"].GetValue(period, mode), bullPatternText);
                vars["addToStringFunc24_param1"].Value = bullPatternText;
                vars["addToStringFunc24_param2"].Value = vars["bullTxt3"];
                bullPatternText = Triary(bull3Met, vars["addToStringFunc24"].GetValue(period, mode), bullPatternText);
                vars["addToStringFunc25_param1"].Value = bullPatternText;
                vars["addToStringFunc25_param2"].Value = vars["bullTxt4"];
                bullPatternText = Triary(bull4Met, vars["addToStringFunc25"].GetValue(period, mode), bullPatternText);
                vars["addToStringFunc26_param1"].Value = bullPatternText;
                vars["addToStringFunc26_param2"].Value = vars["bullTxt5"];
                bullPatternText = Triary(bull5Met, vars["addToStringFunc26"].GetValue(period, mode), bullPatternText);
                vars["addToStringFunc27_param1"].Value = bullPatternText;
                vars["addToStringFunc27_param2"].Value = vars["bullTxt6"];
                bullPatternText = Triary(bull6Met, vars["addToStringFunc27"].GetValue(period, mode), bullPatternText);
                vars["addToStringFunc28_param1"].Value = bullPatternText;
                vars["addToStringFunc28_param2"].Value = vars["bullTxt7"];
                bullPatternText = Triary(bull7Met, vars["addToStringFunc28"].GetValue(period, mode), bullPatternText);
                bearPatternText = "";
                vars["addToStringFunc29_param1"].Value = bearPatternText;
                vars["addToStringFunc29_param2"].Value = vars["bearTxt1"];
                bearPatternText = Triary(bear1Met, vars["addToStringFunc29"].GetValue(period, mode), bearPatternText);
                vars["addToStringFunc30_param1"].Value = bearPatternText;
                vars["addToStringFunc30_param2"].Value = vars["bearTxt2"];
                bearPatternText = Triary(bear2Met, vars["addToStringFunc30"].GetValue(period, mode), bearPatternText);
                vars["addToStringFunc31_param1"].Value = bearPatternText;
                vars["addToStringFunc31_param2"].Value = vars["bearTxt3"];
                bearPatternText = Triary(bear3Met, vars["addToStringFunc31"].GetValue(period, mode), bearPatternText);
                vars["addToStringFunc32_param1"].Value = bearPatternText;
                vars["addToStringFunc32_param2"].Value = vars["bearTxt4"];
                bearPatternText = Triary(bear4Met, vars["addToStringFunc32"].GetValue(period, mode), bearPatternText);
                vars["addToStringFunc33_param1"].Value = bearPatternText;
                vars["addToStringFunc33_param2"].Value = vars["bearTxt5"];
                bearPatternText = Triary(bear5Met, vars["addToStringFunc33"].GetValue(period, mode), bearPatternText);
                vars["addToStringFunc34_param1"].Value = bearPatternText;
                vars["addToStringFunc34_param2"].Value = vars["bearTxt6"];
                bearPatternText = Triary(bear6Met, vars["addToStringFunc34"].GetValue(period, mode), bearPatternText);
                vars["addToStringFunc35_param1"].Value = bearPatternText;
                vars["addToStringFunc35_param2"].Value = vars["bearTxt7"];
                bearPatternText = Triary(bear7Met, vars["addToStringFunc35"].GetValue(period, mode), bearPatternText);
                label_2_x = barindex0;
                vars["pattern_label_bull"] = Label:New(core.formatDate(label_2_x and source:date(label_2_x) or 0) .. "_2", "2", label_2_x, price0):SetText(Triary((bullPatternText ~= ""), bullPatternText, "")):SetColor(vars["uplabelcol"]):SetTextColor(vars["uplabeltextcol"]):SetStyle(Triary((bullPatternText ~= ""), "up", "none"));
                label_3_x = barindex0;
                vars["pattern_label_bear"] = Label:New(core.formatDate(label_3_x and source:date(label_3_x) or 0) .. "_3", "3", label_3_x, price0):SetText(Triary((bearPatternText ~= ""), bearPatternText, "")):SetColor(vars["dnlabelcol"]):SetTextColor(vars["dnlabeltextcol"]):SetStyle(Triary((bearPatternText ~= ""), "down", "none"));
            end
        end
    end
    if SafeGE(vars["zigzag_price"]:Size(), 3) and SafeGE(vars["zigzag_hhll"]:Size(), 3) and vars["showbosline"] then
        vars["isMatchingFunc36_param1"].Value = vars["bosBullMatchPattern"];
        vars["isMatchingFunc36_param2"].Value = vars["zigzag_hhll"];
        vars["isBullMatching"] = vars["isMatchingFunc36"].GetValue(period, mode);
        vars["isMatchingFunc37_param1"].Value = vars["bosBearMatchPattern"];
        vars["isMatchingFunc37_param2"].Value = vars["zigzag_hhll"];
        vars["isBearMatching"] = vars["isMatchingFunc37"].GetValue(period, mode);
        if vars["isBearMatching"] and not (vars["isBearMatching"]) then
            _bi = Array:Get(vars["zigzag_barindex"], 2);
            Line:New(period - SafeMinus(period, _bi), source.low:tick(period - SafeMinus(period, _bi)), period, source.low:tick(period - SafeMinus(period, _bi))):SetColor(vars["dncol"]);
            label_4_x = period;
            Label:New(core.formatDate(label_4_x and source:date(label_4_x) or 0) .. "_4", "4", label_4_x, source.low:tick(period - SafeMinus(period, _bi))):SetText("bos         "):SetTextColor(vars["dncol"]):SetStyle("none"):SetSize("small");
        end
        if vars["isBullMatching"] and not (vars["isBullMatching"]) then
            _bi = Array:Get(vars["zigzag_barindex"], 2);
            Line:New(period - SafeMinus(period, _bi), source.high:tick(period - SafeMinus(period, _bi)), period, source.high:tick(period - SafeMinus(period, _bi))):SetColor(vars["upcol"]);
            label_5_x = period;
            Label:New(core.formatDate(label_5_x and source:date(label_5_x) or 0) .. "_5", "5", label_5_x, source.high:tick(period - SafeMinus(period, _bi))):SetText("bos         "):SetTextColor(vars["upcol"]):SetStyle("none"):SetSize("small");
        end
    end
    if period == source:size() - 1 then
        _table = Table:New("1", "bottom_left", 1, 2);
        Table:CellText(_table, 0, 0, "@Nephew_Sam_");
        Table:CellTextColor(_table, 0, 0, core.colors().Gray + math.floor(50 / 100 * 255) * 16777216);
        Table:CellTextSize(_table, 0, 0, "small");
    end
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
    if pattern == nil then
        return tostring(value);
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

function CreateHighestBars(source, length)
    local highestbars = {};
    highestbars.Source = source;
    highestbars.Length = length;
    function highestbars:get(period)
        if period < self.Length then
            return nil;
        end
        local _, pos = mathex.max(self.Source, core.rangeTo(period, self.Length));
        return period - pos;
    end
    return highestbars;
end
function CreateLowestBars(source, length)
    local lowestbars = {};
    lowestbars.Source = source;
    lowestbars.Length = length;
    function lowestbars:get(period)
        if period < self.Length then
            return nil;
        end
        local _, pos = mathex.min(self.Source, core.rangeTo(period, self.Length));
        return period - pos;
    end
    return lowestbars;
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
function Array:NewArray(size, initialValue)
    local newArray = {};
    newArray.arr = {};
    newArray.size = size;
    for i = 1, size, 1 do
        newArray.arr[i] = initialValue;
    end
    function newArray:Push(item) self.size = self.size + 1; self.arr[#self.arr + 1] = item; end
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
    self.AllLabels[id .. "_" .. seriesId] = newLabel;
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
    for id, label in pairs(self.AllLabels) do
        label:Draw(stage, context);
    end
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