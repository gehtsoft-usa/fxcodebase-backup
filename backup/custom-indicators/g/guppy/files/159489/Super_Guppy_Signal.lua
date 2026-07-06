-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&p=158067#p158067

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 
local vars = {};
function Init()
    indicator:name("Super Guppy Strategy");
    indicator:description("Super Guppy Strategy");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addBoolean("param1", "Test w/Shorts?", "", true);
    indicator.parameters:addBoolean("param2", "Use Early Signals?", "", true);
    indicator.parameters:addBoolean("param3", "Show 200 EMA?", "", false);
    indicator.parameters:addInteger("param4", "Max Days Back to Test", "", 100000, 0);
    indicator.parameters:addInteger("param5", "Min Days Back to Test", "", 0, 0);
    indicator.parameters:addInteger("param6", "Fast EMA 1", "", 3, 1);
    indicator.parameters:addInteger("param7", "Fast EMA 2", "", 6, 1);
    indicator.parameters:addInteger("param8", "Fast EMA 3", "", 9, 1);
    indicator.parameters:addInteger("param9", "Fast EMA 4", "", 12, 1);
    indicator.parameters:addInteger("param10", "Fast EMA 5", "", 15, 1);
    indicator.parameters:addInteger("param11", "Fast EMA 6", "", 18, 1);
    indicator.parameters:addInteger("param12", "Fast EMA 7", "", 21, 1);
    indicator.parameters:addInteger("param13", "Slow EMA 8", "", 24, 1);
    indicator.parameters:addInteger("param14", "Slow EMA 9", "", 27, 1);
    indicator.parameters:addInteger("param15", "Slow EMA 10", "", 30, 1);
    indicator.parameters:addInteger("param16", "Slow EMA 11", "", 33, 1);
    indicator.parameters:addInteger("param17", "Slow EMA 12", "", 36, 1);
    indicator.parameters:addInteger("param18", "Slow EMA 13", "", 39, 1);
    indicator.parameters:addInteger("param19", "Slow EMA 14", "", 42, 1);
    indicator.parameters:addInteger("param20", "Slow EMA 15", "", 45, 1);
    indicator.parameters:addInteger("param21", "Slow EMA 16", "", 48, 1);
    indicator.parameters:addInteger("param22", "Slow EMA 17", "", 51, 1);
    indicator.parameters:addInteger("param23", "Slow EMA 18", "", 54, 1);
    indicator.parameters:addInteger("param24", "Slow EMA 19", "", 57, 1);
    indicator.parameters:addInteger("param25", "Slow EMA 20", "", 60, 1);
    indicator.parameters:addInteger("param26", "Slow EMA 21", "", 63, 1);
    indicator.parameters:addInteger("param27", "Slow EMA 22", "", 66, 1);
    indicator.parameters:addInteger("param28", "EMA 200", "", 200, 1);
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
local plot9;
local plot10;
local plot11;
local plot12;
local plot13;
local plot14;
local plot15;
local plot16;
local plot17;
local plot18;
local plot19;
local plot20;
local plot21;
local plot22;
local plot23;
local plot24;
local plot25;
local plot26;
local plot27;
local plot28;
local plot29;
local plot30;
local time;
local signal1;
local signal2;
local signal3;
local signal4;
local signal5;
local signal6;
local signal7;
local signal8;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    vars["useShorts"] = instance.parameters.param1;
    vars["useEarlySignals"] = instance.parameters.param2;
    vars["show200Ema"] = instance.parameters.param3;
    vars["daysBackMax"] = instance.parameters.param4;
    vars["daysBackMin"] = instance.parameters.param5;
    vars["msBackMax"] = 1000 * 60 * 60 * 24 * vars["daysBackMax"];
    vars["msBackMin"] = 1000 * 60 * 60 * 24 * vars["daysBackMin"];
    vars["len1"] = instance.parameters.param6;
    vars["len2"] = instance.parameters.param7;
    vars["len3"] = instance.parameters.param8;
    vars["len4"] = instance.parameters.param9;
    vars["len5"] = instance.parameters.param10;
    vars["len6"] = instance.parameters.param11;
    vars["len7"] = instance.parameters.param12;
    vars["len8"] = instance.parameters.param13;
    vars["len9"] = instance.parameters.param14;
    vars["len10"] = instance.parameters.param15;
    vars["len11"] = instance.parameters.param16;
    vars["len12"] = instance.parameters.param17;
    vars["len13"] = instance.parameters.param18;
    vars["len14"] = instance.parameters.param19;
    vars["len15"] = instance.parameters.param20;
    vars["len16"] = instance.parameters.param21;
    vars["len17"] = instance.parameters.param22;
    vars["len18"] = instance.parameters.param23;
    vars["len19"] = instance.parameters.param24;
    vars["len20"] = instance.parameters.param25;
    vars["len21"] = instance.parameters.param26;
    vars["len22"] = instance.parameters.param27;
    vars["len23"] = instance.parameters.param28;
    vars["EMA1_source"] = instance:addInternalStream(0, 0);
    vars["EMA1"] = core.indicators:create("EMA", vars["EMA1_source"], vars["len1"]);
    vars["EMA2_source"] = instance:addInternalStream(0, 0);
    vars["EMA2"] = core.indicators:create("EMA", vars["EMA2_source"], vars["len2"]);
    vars["EMA3_source"] = instance:addInternalStream(0, 0);
    vars["EMA3"] = core.indicators:create("EMA", vars["EMA3_source"], vars["len3"]);
    vars["EMA4_source"] = instance:addInternalStream(0, 0);
    vars["EMA4"] = core.indicators:create("EMA", vars["EMA4_source"], vars["len4"]);
    vars["EMA5_source"] = instance:addInternalStream(0, 0);
    vars["EMA5"] = core.indicators:create("EMA", vars["EMA5_source"], vars["len5"]);
    vars["EMA6_source"] = instance:addInternalStream(0, 0);
    vars["EMA6"] = core.indicators:create("EMA", vars["EMA6_source"], vars["len6"]);
    vars["EMA7_source"] = instance:addInternalStream(0, 0);
    vars["EMA7"] = core.indicators:create("EMA", vars["EMA7_source"], vars["len7"]);
    vars["EMA8_source"] = instance:addInternalStream(0, 0);
    vars["EMA8"] = core.indicators:create("EMA", vars["EMA8_source"], vars["len8"]);
    vars["EMA9_source"] = instance:addInternalStream(0, 0);
    vars["EMA9"] = core.indicators:create("EMA", vars["EMA9_source"], vars["len9"]);
    vars["EMA10_source"] = instance:addInternalStream(0, 0);
    vars["EMA10"] = core.indicators:create("EMA", vars["EMA10_source"], vars["len10"]);
    vars["EMA11_source"] = instance:addInternalStream(0, 0);
    vars["EMA11"] = core.indicators:create("EMA", vars["EMA11_source"], vars["len11"]);
    vars["EMA12_source"] = instance:addInternalStream(0, 0);
    vars["EMA12"] = core.indicators:create("EMA", vars["EMA12_source"], vars["len12"]);
    vars["EMA13_source"] = instance:addInternalStream(0, 0);
    vars["EMA13"] = core.indicators:create("EMA", vars["EMA13_source"], vars["len13"]);
    vars["EMA14_source"] = instance:addInternalStream(0, 0);
    vars["EMA14"] = core.indicators:create("EMA", vars["EMA14_source"], vars["len14"]);
    vars["EMA15_source"] = instance:addInternalStream(0, 0);
    vars["EMA15"] = core.indicators:create("EMA", vars["EMA15_source"], vars["len15"]);
    vars["EMA16_source"] = instance:addInternalStream(0, 0);
    vars["EMA16"] = core.indicators:create("EMA", vars["EMA16_source"], vars["len16"]);
    vars["EMA17_source"] = instance:addInternalStream(0, 0);
    vars["EMA17"] = core.indicators:create("EMA", vars["EMA17_source"], vars["len17"]);
    vars["EMA18_source"] = instance:addInternalStream(0, 0);
    vars["EMA18"] = core.indicators:create("EMA", vars["EMA18_source"], vars["len18"]);
    vars["EMA19_source"] = instance:addInternalStream(0, 0);
    vars["EMA19"] = core.indicators:create("EMA", vars["EMA19_source"], vars["len19"]);
    vars["EMA20_source"] = instance:addInternalStream(0, 0);
    vars["EMA20"] = core.indicators:create("EMA", vars["EMA20_source"], vars["len20"]);
    vars["EMA21_source"] = instance:addInternalStream(0, 0);
    vars["EMA21"] = core.indicators:create("EMA", vars["EMA21_source"], vars["len21"]);
    vars["EMA22_source"] = instance:addInternalStream(0, 0);
    vars["EMA22"] = core.indicators:create("EMA", vars["EMA22_source"], vars["len22"]);
    vars["EMA23_source"] = instance:addInternalStream(0, 0);
    vars["EMA23"] = core.indicators:create("EMA", vars["EMA23_source"], vars["len23"]);
    vars["colFinal2"] = instance:addInternalStream(0, 0);
    plot1 = instance:addStream("plot1", core.Line, "", "", core.colors().Aqua, 0, 0);
    plot1:setWidth(2);
    plot1:setStyle(core.LINE_SOLID);
    vars["p1"] = plot1;
    plot2 = instance:addStream("plot2", core.Line, "", "", core.colors().Aqua, 0, 0);
    plot2:setWidth(1);
    plot2:setStyle(core.LINE_SOLID);
    plot3 = instance:addStream("plot3", core.Line, "", "", core.colors().Aqua, 0, 0);
    plot3:setWidth(1);
    plot3:setStyle(core.LINE_SOLID);
    plot4 = instance:addStream("plot4", core.Line, "", "", core.colors().Aqua, 0, 0);
    plot4:setWidth(1);
    plot4:setStyle(core.LINE_SOLID);
    plot5 = instance:addStream("plot5", core.Line, "", "", core.colors().Aqua, 0, 0);
    plot5:setWidth(1);
    plot5:setStyle(core.LINE_SOLID);
    plot6 = instance:addStream("plot6", core.Line, "", "", core.colors().Aqua, 0, 0);
    plot6:setWidth(1);
    plot6:setStyle(core.LINE_SOLID);
    plot7 = instance:addStream("plot7", core.Line, "", "", core.colors().Aqua, 0, 0);
    plot7:setWidth(2);
    plot7:setStyle(core.LINE_SOLID);
    vars["p2"] = plot7;
    plot8 = instance:addStream("plot8", core.Line, "", "", core.colors().Lime, 0, 0);
    plot8:setWidth(1);
    plot8:setStyle(core.LINE_SOLID);
    vars["p3"] = plot8;
    plot9 = instance:addStream("plot9", core.Line, "", "", core.colors().Lime, 0, 0);
    plot9:setWidth(1);
    plot9:setStyle(core.LINE_SOLID);
    plot10 = instance:addStream("plot10", core.Line, "", "", core.colors().Lime, 0, 0);
    plot10:setWidth(1);
    plot10:setStyle(core.LINE_SOLID);
    plot11 = instance:addStream("plot11", core.Line, "", "", core.colors().Lime, 0, 0);
    plot11:setWidth(1);
    plot11:setStyle(core.LINE_SOLID);
    plot12 = instance:addStream("plot12", core.Line, "", "", core.colors().Lime, 0, 0);
    plot12:setWidth(1);
    plot12:setStyle(core.LINE_SOLID);
    plot13 = instance:addStream("plot13", core.Line, "", "", core.colors().Lime, 0, 0);
    plot13:setWidth(1);
    plot13:setStyle(core.LINE_SOLID);
    plot14 = instance:addStream("plot14", core.Line, "", "", core.colors().Lime, 0, 0);
    plot14:setWidth(1);
    plot14:setStyle(core.LINE_SOLID);
    plot15 = instance:addStream("plot15", core.Line, "", "", core.colors().Lime, 0, 0);
    plot15:setWidth(1);
    plot15:setStyle(core.LINE_SOLID);
    plot16 = instance:addStream("plot16", core.Line, "", "", core.colors().Lime, 0, 0);
    plot16:setWidth(1);
    plot16:setStyle(core.LINE_SOLID);
    plot17 = instance:addStream("plot17", core.Line, "", "", core.colors().Lime, 0, 0);
    plot17:setWidth(1);
    plot17:setStyle(core.LINE_SOLID);
    plot18 = instance:addStream("plot18", core.Line, "", "", core.colors().Lime, 0, 0);
    plot18:setWidth(1);
    plot18:setStyle(core.LINE_SOLID);
    plot19 = instance:addStream("plot19", core.Line, "", "", core.colors().Lime, 0, 0);
    plot19:setWidth(1);
    plot19:setStyle(core.LINE_SOLID);
    plot20 = instance:addStream("plot20", core.Line, "", "", core.colors().Lime, 0, 0);
    plot20:setWidth(1);
    plot20:setStyle(core.LINE_SOLID);
    plot21 = instance:addStream("plot21", core.Line, "", "", core.colors().Lime, 0, 0);
    plot21:setWidth(1);
    plot21:setStyle(core.LINE_SOLID);
    plot22 = instance:addStream("plot22", core.Line, "", "", core.colors().Lime, 0, 0);
    plot22:setWidth(2);
    plot22:setStyle(core.LINE_SOLID);
    plot23 = instance:addStream("plot23", core.Line, "", "", core.colors().Blue, 0, 0);
    plot23:setWidth(2);
    plot23:setStyle(core.LINE_NONE);
    vars["p4"] = plot23;
    vars["isLong"] = instance:addInternalStream(0, 0);
    vars["isShort"] = instance:addInternalStream(0, 0);
    plot24 = instance:createTextOutput("plot24", "open long", "Arial", 12, core.H_Center, core.V_Bottom, core.colors().Green);
    plot25 = instance:createTextOutput("plot25", "close long", "Arial", 12, core.H_Center, core.V_Top, core.colors().Gray);
    plot26 = instance:createTextOutput("plot26", "open short", "Arial", 12, core.H_Center, core.V_Top, core.colors().Red);
    plot27 = instance:createTextOutput("plot27", "close short", "Arial", 12, core.H_Center, core.V_Bottom, core.colors().Black);
    plot28 = instance:createTextOutput("plot28", "long", "Arial", 12, core.H_Center, core.V_Bottom, core.colors().Green);
    plot29 = instance:createTextOutput("plot29", "short", "Arial", 12, core.H_Center, core.V_Top, core.colors().Red);
    plot30 = instance:createTextOutput("plot30", "close long", "Arial", 12, core.H_Center, core.V_Top, core.colors().Red);
    time = instance:addInternalStream(0, 0);
    signal1 = PineStrategy:CreateEntrySignalV4("LONG");
    signal2 = PineStrategy:CreateCloseSignalV4("LONG");
    signal3 = PineStrategy:CreateEntrySignalV4("short");
    signal4 = PineStrategy:CreateCloseSignalV4("short");
    signal5 = PineStrategy:CreateEntrySignalV4("LONG");
    signal6 = PineStrategy:CreateCloseSignalV4("LONG");
    signal7 = PineStrategy:CreateEntrySignalV4("short");
    signal8 = PineStrategy:CreateCloseSignalV4("short");
end

function Update(period, mode)
    if period == 0 or mode == core.UpdateAll then
        SafeSetBool(vars["isLong"], period, false);
        SafeSetBool(vars["isShort"], period, false);
        time[period] = source:date(period) * 86400000;
    else
        SafeSetBool(vars["isLong"], period, SafeGetBool(vars["isLong"], period - 1));
        SafeSetBool(vars["isShort"], period, SafeGetBool(vars["isShort"], period - 1));
        time[period] = source:date(period) * 86400000;
    end
    src = source.close:tick(period);
    SafeSetFloat(vars["EMA1_source"], period, src);
    vars["EMA1"]:update(mode);
    ema1 = vars["EMA1"].DATA:tick(period);
    SafeSetFloat(vars["EMA2_source"], period, src);
    vars["EMA2"]:update(mode);
    ema2 = vars["EMA2"].DATA:tick(period);
    SafeSetFloat(vars["EMA3_source"], period, src);
    vars["EMA3"]:update(mode);
    ema3 = vars["EMA3"].DATA:tick(period);
    SafeSetFloat(vars["EMA4_source"], period, src);
    vars["EMA4"]:update(mode);
    ema4 = vars["EMA4"].DATA:tick(period);
    SafeSetFloat(vars["EMA5_source"], period, src);
    vars["EMA5"]:update(mode);
    ema5 = vars["EMA5"].DATA:tick(period);
    SafeSetFloat(vars["EMA6_source"], period, src);
    vars["EMA6"]:update(mode);
    ema6 = vars["EMA6"].DATA:tick(period);
    SafeSetFloat(vars["EMA7_source"], period, src);
    vars["EMA7"]:update(mode);
    ema7 = vars["EMA7"].DATA:tick(period);
    SafeSetFloat(vars["EMA8_source"], period, src);
    vars["EMA8"]:update(mode);
    ema8 = vars["EMA8"].DATA:tick(period);
    SafeSetFloat(vars["EMA9_source"], period, src);
    vars["EMA9"]:update(mode);
    ema9 = vars["EMA9"].DATA:tick(period);
    SafeSetFloat(vars["EMA10_source"], period, src);
    vars["EMA10"]:update(mode);
    ema10 = vars["EMA10"].DATA:tick(period);
    SafeSetFloat(vars["EMA11_source"], period, src);
    vars["EMA11"]:update(mode);
    ema11 = vars["EMA11"].DATA:tick(period);
    SafeSetFloat(vars["EMA12_source"], period, src);
    vars["EMA12"]:update(mode);
    ema12 = vars["EMA12"].DATA:tick(period);
    SafeSetFloat(vars["EMA13_source"], period, src);
    vars["EMA13"]:update(mode);
    ema13 = vars["EMA13"].DATA:tick(period);
    SafeSetFloat(vars["EMA14_source"], period, src);
    vars["EMA14"]:update(mode);
    ema14 = vars["EMA14"].DATA:tick(period);
    SafeSetFloat(vars["EMA15_source"], period, src);
    vars["EMA15"]:update(mode);
    ema15 = vars["EMA15"].DATA:tick(period);
    SafeSetFloat(vars["EMA16_source"], period, src);
    vars["EMA16"]:update(mode);
    ema16 = vars["EMA16"].DATA:tick(period);
    SafeSetFloat(vars["EMA17_source"], period, src);
    vars["EMA17"]:update(mode);
    ema17 = vars["EMA17"].DATA:tick(period);
    SafeSetFloat(vars["EMA18_source"], period, src);
    vars["EMA18"]:update(mode);
    ema18 = vars["EMA18"].DATA:tick(period);
    SafeSetFloat(vars["EMA19_source"], period, src);
    vars["EMA19"]:update(mode);
    ema19 = vars["EMA19"].DATA:tick(period);
    SafeSetFloat(vars["EMA20_source"], period, src);
    vars["EMA20"]:update(mode);
    ema20 = vars["EMA20"].DATA:tick(period);
    SafeSetFloat(vars["EMA21_source"], period, src);
    vars["EMA21"]:update(mode);
    ema21 = vars["EMA21"].DATA:tick(period);
    SafeSetFloat(vars["EMA22_source"], period, src);
    vars["EMA22"]:update(mode);
    ema22 = vars["EMA22"].DATA:tick(period);
    SafeSetFloat(vars["EMA23_source"], period, src);
    vars["EMA23"]:update(mode);
    ema23 = vars["EMA23"].DATA:tick(period);
    colfastL = (SafeGreater(ema1, ema2) and SafeGreater(ema2, ema3) and SafeGreater(ema3, ema4) and SafeGreater(ema4, ema5) and SafeGreater(ema5, ema6) and SafeGreater(ema6, ema7));
    colfastS = (SafeLess(ema1, ema2) and SafeLess(ema2, ema3) and SafeLess(ema3, ema4) and SafeLess(ema4, ema5) and SafeLess(ema5, ema6) and SafeLess(ema6, ema7));
    colslowL = SafeGreater(ema8, ema9) and SafeGreater(ema9, ema10) and SafeGreater(ema10, ema11) and SafeGreater(ema11, ema12) and SafeGreater(ema12, ema13) and SafeGreater(ema13, ema14) and SafeGreater(ema14, ema15) and SafeGreater(ema15, ema16) and SafeGreater(ema16, ema17) and SafeGreater(ema17, ema18) and SafeGreater(ema18, ema19) and SafeGreater(ema19, ema20) and SafeGreater(ema20, ema21) and SafeGreater(ema21, ema22);
    colslowS = SafeLess(ema8, ema9) and SafeLess(ema9, ema10) and SafeLess(ema10, ema11) and SafeLess(ema11, ema12) and SafeLess(ema12, ema13) and SafeLess(ema13, ema14) and SafeLess(ema14, ema15) and SafeLess(ema15, ema16) and SafeLess(ema16, ema17) and SafeLess(ema17, ema18) and SafeLess(ema18, ema19) and SafeLess(ema19, ema20) and SafeLess(ema20, ema21) and SafeLess(ema21, ema22);
    colFinal = Triary(colfastL and colslowL, core.colors().Aqua, Triary(colfastS and colslowS, core.colors().Orange, core.colors().Gray));
    SafeSetFloat(vars["colFinal2"], period, Triary(colslowL, core.colors().Lime, Triary(colslowS, core.colors().Red, core.colors().Gray)));
    plot1[period] = ema1;
    plot1:setColor(period, colFinal);
    plot2[period] = ema2;
    plot2:setColor(period, colFinal);
    plot3[period] = ema3;
    plot3:setColor(period, colFinal);
    plot4[period] = ema4;
    plot4:setColor(period, colFinal);
    plot5[period] = ema5;
    plot5:setColor(period, colFinal);
    plot6[period] = ema6;
    plot6:setColor(period, colFinal);
    plot7[period] = ema7;
    plot7:setColor(period, colFinal);
    plot8[period] = ema8;
    plot8:setColor(period, SafeGetFloat(vars["colFinal2"], period));
    plot9[period] = ema9;
    plot9:setColor(period, SafeGetFloat(vars["colFinal2"], period));
    plot10[period] = ema10;
    plot10:setColor(period, SafeGetFloat(vars["colFinal2"], period));
    plot11[period] = ema11;
    plot11:setColor(period, SafeGetFloat(vars["colFinal2"], period));
    plot12[period] = ema12;
    plot12:setColor(period, SafeGetFloat(vars["colFinal2"], period));
    plot13[period] = ema13;
    plot13:setColor(period, SafeGetFloat(vars["colFinal2"], period));
    plot14[period] = ema14;
    plot14:setColor(period, SafeGetFloat(vars["colFinal2"], period));
    plot15[period] = ema15;
    plot15:setColor(period, SafeGetFloat(vars["colFinal2"], period));
    plot16[period] = ema16;
    plot16:setColor(period, SafeGetFloat(vars["colFinal2"], period));
    plot17[period] = ema17;
    plot17:setColor(period, SafeGetFloat(vars["colFinal2"], period));
    plot18[period] = ema18;
    plot18:setColor(period, SafeGetFloat(vars["colFinal2"], period));
    plot19[period] = ema19;
    plot19:setColor(period, SafeGetFloat(vars["colFinal2"], period));
    plot20[period] = ema20;
    plot20:setColor(period, SafeGetFloat(vars["colFinal2"], period));
    plot21[period] = ema21;
    plot21:setColor(period, SafeGetFloat(vars["colFinal2"], period));
    plot22[period] = ema22;
    plot22:setColor(period, SafeGetFloat(vars["colFinal2"], period));
    plot23[period] = Triary((vars["show200Ema"] == true), ema23, nil);
    long = not (SafeGetBool(vars["isLong"], period)) and ((((SafeGetFloat(vars["colFinal2"], period) == core.colors().Lime) and (SafeGetFloat(vars["colFinal2"], period - 1) == core.colors().Gray)) or ((SafeGetFloat(vars["colFinal2"], period) == core.colors().Gray) and (SafeGetFloat(vars["colFinal2"], period - 1) == core.colors().Red))));
    short = not (SafeGetBool(vars["isShort"], period)) and ((((SafeGetFloat(vars["colFinal2"], period) == core.colors().Gray) and (SafeGetFloat(vars["colFinal2"], period - 1) == core.colors().Lime)) or ((SafeGetFloat(vars["colFinal2"], period) == core.colors().Red) and (SafeGetFloat(vars["colFinal2"], period - 1) == core.colors().Gray))));
    if long then
        SafeSetBool(vars["isLong"], period, true);
        SafeSetBool(vars["isShort"], period, false);
    end
    if short then
        SafeSetBool(vars["isLong"], period, false);
        SafeSetBool(vars["isShort"], period, true);
    end
    openLong = (SafeGetFloat(vars["colFinal2"], period) == core.colors().Lime) and (SafeGetFloat(vars["colFinal2"], period - 1) == core.colors().Gray);
    closeLong = (SafeGetFloat(vars["colFinal2"], period) == core.colors().Gray) and (SafeGetFloat(vars["colFinal2"], period - 1) == core.colors().Lime);
    openShort = (SafeGetFloat(vars["colFinal2"], period) == core.colors().Red) and (SafeGetFloat(vars["colFinal2"], period - 1) == core.colors().Gray);
    closeShort = (SafeGetFloat(vars["colFinal2"], period) == core.colors().Gray) and (SafeGetFloat(vars["colFinal2"], period - 1) == core.colors().Red);
    PlotShape:SetValue(plot24, period, source, openLong and not (vars["useEarlySignals"]), "open long", "open long", "belowbar");
    PlotShape:SetValue(plot25, period, source, closeLong and not (vars["useEarlySignals"]), "close long", "close long", "abovebar");
    PlotShape:SetValue(plot26, period, source, openShort and vars["useShorts"] and not (vars["useEarlySignals"]), "open short", "open short", "abovebar");
    PlotShape:SetValue(plot27, period, source, closeShort and vars["useShorts"] and not (vars["useEarlySignals"]), "close short", "close short", "belowbar");
    PlotShape:SetValue(plot28, period, source, long and vars["useEarlySignals"], "long", "long", "belowbar");
    PlotShape:SetValue(plot29, period, source, short and vars["useEarlySignals"] and vars["useShorts"], "short", "short", "abovebar");
    PlotShape:SetValue(plot30, period, source, short and vars["useEarlySignals"] and not (vars["useShorts"]), "close long", "close long", "abovebar");
    isWithinTimeBounds = (((vars["msBackMax"] == 0) or ((time:tick(period) > (core.host:execute("getServerTime") * 86400000 - vars["msBackMax"]))))) and (((vars["msBackMin"] == 0) or ((time:tick(period) < (core.host:execute("getServerTime") * 86400000 - vars["msBackMin"])))));
    signal1:Execute(period, "LONG", true, nil, nil, nil, nil, nil, nil, openLong and isWithinTimeBounds and not (vars["useEarlySignals"]), nil);
    signal2:Execute(period, "LONG", closeLong and isWithinTimeBounds and not (vars["useEarlySignals"]), nil, 100.0, nil, nil);
    signal3:Execute(period, "short", false, nil, nil, nil, nil, nil, nil, openShort and vars["useShorts"] and isWithinTimeBounds and not (vars["useEarlySignals"]), nil);
    signal4:Execute(period, "short", closeShort and vars["useShorts"] and isWithinTimeBounds and not (vars["useEarlySignals"]), nil, 100.0, nil, nil);
    signal5:Execute(period, "LONG", true, nil, nil, nil, nil, nil, nil, long and isWithinTimeBounds and vars["useEarlySignals"], nil);
    signal6:Execute(period, "LONG", short and isWithinTimeBounds and vars["useEarlySignals"], nil, 100.0, nil, nil);
    signal7:Execute(period, "short", false, nil, nil, nil, nil, nil, nil, short and vars["useShorts"] and isWithinTimeBounds and vars["useEarlySignals"], nil);
    signal8:Execute(period, "short", long and vars["useShorts"] and isWithinTimeBounds and not (vars["useEarlySignals"]), nil, 100.0, nil, nil);
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
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
PlotShape = {};
function PlotShape:SetValue(plot, period, source, value, text, label, location)
    if not value then
        plot:setNoData(period);
        return;
    end
    if location == "abovebar" or location == "top" then
        plot:set(period, source.high[period], text, label);
        return;
    end
    if location == "belowbar" or location == "bottom" then
        plot:set(period, source.low[period], text, label);
        return;
    end
    plot:set(period, value, text, label);
end
PineStrategy = {};
PineStrategy.streams = {};
function PineStrategy:CreateEntrySignalV4(id)
    local signal = {};
    if self.streams["entry_signal" .. id] == nil then
        self.streams["entry_signal" .. id] = instance:addStream("entry_signal" .. id, core.Line, "Entry Signal Entry " .. id, "Entry Signal " .. id, core.colors().Red, 0, 0);
    end
    signal.stream = self.streams["entry_signal" .. id];
    function signal:Execute(period, id, long, qty, limit, stop, oca_name, oca_type, comment, when, alert_message)
        if when then
            self.stream[period] = long and 1 or -1;
        end
    end
    return signal;
end
function PineStrategy:EntryV4(id, long, qty, limit, stop, oca_name, oca_type, comment, when, alert_message)
    if not when then
        return;
    end
    core.host:trace(alert_message or id);
end
function PineStrategy:EntryV5(id, direction, qty, limit, stop, oca_name, oca_type, comment, when, alert_message)
    if not when then
        return;
    end
    core.host:trace(alert_message or id);
end
function PineStrategy:CreateCloseSignalV4(id)
    local signal = {};
    if self.streams["close_signal" .. id] == nil then
        self.streams["close_signal" .. id] = instance:addStream("close_signal" .. id, core.Line, "Close Signal Entry " .. id, "Close Signal " .. id, core.colors().Blue, 0, 0);
    end
    signal.stream = self.streams["close_signal" .. id];
    function signal:Execute(period, id, when, qty, qty_percent, comment, alert_message)
        if when then
            self.stream[period] = 1;
        end
    end
    return signal;
end
function PineStrategy:CloseV4(id, when, qty, qty_percent, comment, alert_message)
    if not when then
        return;
    end
    core.host:trace(alert_message or id);
end
function PineStrategy:CloseV5(id, comment, qty, qty_percent, alert_message, immediately, disable_alert)
    if disable_alert == true then
        return;
    end
    core.host:trace(alert_message or id);
end
-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&p=158067#p158067

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+  