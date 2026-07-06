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
    indicator:name("Super Guppy R1.2 by JustUncleL");
    indicator:description("Super Guppy R1.2 by JustUncleL");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("param1", "Use Alternate Anchor TimeFrame (0=none, max=1440 (mins,D,W)", "", 0, 0, 1440);
    indicator.parameters:addString("param2", "EMA Source", "", "close");
    indicator.parameters:addStringAlternative("param2", "Open", "", "open");
    indicator.parameters:addStringAlternative("param2", "High", "", "high");
    indicator.parameters:addStringAlternative("param2", "Low", "", "low");
    indicator.parameters:addStringAlternative("param2", "Close", "", "close");
    indicator.parameters:addStringAlternative("param2", "Median", "", "median");
    indicator.parameters:addStringAlternative("param2", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("param2", "Weighted", "", "weighted");
    indicator.parameters:addStringAlternative("param2", "OHLC4", "", "ohlc4");
    indicator.parameters:addBoolean("param3", "Show Trend Break Arrow Alerts", "", true);
    indicator.parameters:addBoolean("param4", "Show Swing Arrow Alerts", "", true);
    indicator.parameters:addBoolean("param5", "Give Only Fast+Slow Confluence Alerts", "", false);
    indicator.parameters:addBoolean("param6", "Add Bar Colour Changes to Swing Alerts", "", false);
    indicator.parameters:addInteger("param7", "Alert Lookback Length", "", 6);
    indicator.parameters:addBoolean("param8", "Show Average Fast and Slow Guppy Curves", "", false);
    indicator.parameters:addBoolean("param9", "Show 200 EMA Curve", "", false);
    indicator.parameters:addBoolean("param10", "Filter Alerts with 200ema", "", false);
    indicator.parameters:addBoolean("param11", "Colour Candles to Guppy Trend state", "", false);
    indicator.parameters:addInteger("param12", "Fast EMA 1", "", 3, 1);
    indicator.parameters:addInteger("param13", "Fast EMA 2", "", 5, 1);
    indicator.parameters:addInteger("param14", "Fast EMA 3", "", 7, 1);
    indicator.parameters:addInteger("param15", "Fast EMA 4", "", 9, 1);
    indicator.parameters:addInteger("param16", "Fast EMA 5", "", 11, 1);
    indicator.parameters:addInteger("param17", "Fast EMA 6", "", 13, 1);
    indicator.parameters:addInteger("param18", "Fast EMA 7", "", 15, 1);
    indicator.parameters:addInteger("param19", "Fast EMA 8", "", 17, 1);
    indicator.parameters:addInteger("param20", "Fast EMA 9", "", 19, 1);
    indicator.parameters:addInteger("param21", "Fast EMA 10", "", 21, 1);
    indicator.parameters:addInteger("param22", "Fast EMA 11", "", 23, 1);
    indicator.parameters:addInteger("param23", "Slow EMA 1", "", 25, 1);
    indicator.parameters:addInteger("param24", "Slow EMA 2", "", 28, 1);
    indicator.parameters:addInteger("param25", "Slow EMA 3", "", 31, 1);
    indicator.parameters:addInteger("param26", "Slow EMA 4", "", 34, 1);
    indicator.parameters:addInteger("param27", "Slow EMA 5", "", 37, 1);
    indicator.parameters:addInteger("param28", "Slow EMA 6", "", 40, 1);
    indicator.parameters:addInteger("param29", "Slow EMA 7", "", 43, 1);
    indicator.parameters:addInteger("param30", "Slow EMA 8", "", 46, 1);
    indicator.parameters:addInteger("param31", "Slow EMA 9", "", 49, 1);
    indicator.parameters:addInteger("param32", "Slow EMA 10", "", 52, 1);
    indicator.parameters:addInteger("param33", "Slow EMA 11", "", 55, 1);
    indicator.parameters:addInteger("param34", "Slow EMA 12", "", 58, 1);
    indicator.parameters:addInteger("param35", "Slow EMA 13", "", 61, 1);
    indicator.parameters:addInteger("param36", "Slow EMA 14", "", 64, 1);
    indicator.parameters:addInteger("param37", "Slow EMA 15", "", 67, 1);
    indicator.parameters:addInteger("param38", "Slow EMA 16", "", 70, 1);
    indicator.parameters:addInteger("param39", "EMA 200 Length", "", 200, 1);
    signaler:Init(indicator.parameters);
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
local plot31_open;
local plot31_high;
local plot31_low;
local plot31_close;
local plot32;
local plot33;
local plot34;
local plot35;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    vars["anchor"] = instance.parameters.param1;
    vars["src"] = PineScriptUtils:CreateSource(source, instance.parameters.param2);
    vars["ShowBreak"] = instance.parameters.param3;
    vars["ShowSwing"] = instance.parameters.param4;
    vars["ShowCon"] = instance.parameters.param5;
    vars["uOCCswing"] = instance.parameters.param6;
    vars["Lookback"] = instance.parameters.param7;
    vars["ShowAvgs"] = instance.parameters.param8;
    vars["show200"] = instance.parameters.param9;
    vars["emaFilter"] = instance.parameters.param10;
    vars["clrBars"] = instance.parameters.param11;
    vars["lenF1"] = instance.parameters.param12;
    vars["lenF2"] = instance.parameters.param13;
    vars["lenF3"] = instance.parameters.param14;
    vars["lenF4"] = instance.parameters.param15;
    vars["lenF5"] = instance.parameters.param16;
    vars["lenF6"] = instance.parameters.param17;
    vars["lenF7"] = instance.parameters.param18;
    vars["lenF8"] = instance.parameters.param19;
    vars["lenF9"] = instance.parameters.param20;
    vars["lenF10"] = instance.parameters.param21;
    vars["lenF11"] = instance.parameters.param22;
    vars["lenS1"] = instance.parameters.param23;
    vars["lenS2"] = instance.parameters.param24;
    vars["lenS3"] = instance.parameters.param25;
    vars["lenS4"] = instance.parameters.param26;
    vars["lenS5"] = instance.parameters.param27;
    vars["lenS6"] = instance.parameters.param28;
    vars["lenS7"] = instance.parameters.param29;
    vars["lenS8"] = instance.parameters.param30;
    vars["lenS9"] = instance.parameters.param31;
    vars["lenS10"] = instance.parameters.param32;
    vars["lenS11"] = instance.parameters.param33;
    vars["lenS12"] = instance.parameters.param34;
    vars["lenS13"] = instance.parameters.param35;
    vars["lenS14"] = instance.parameters.param36;
    vars["lenS15"] = instance.parameters.param37;
    vars["lenS16"] = instance.parameters.param38;
    vars["len"] = instance.parameters.param39;
    vars["gold"] = Graphics:AddTransparency(core.rgb(255, 215, 0), 0);
    vars["AQUA"] = Graphics:AddTransparency(core.rgb(255, 255, 255), 0);
    vars["BLUE"] = Graphics:AddTransparency(core.rgb(0, 255, 255), 0);
    vars["GRAY"] = Graphics:AddTransparency(core.rgb(128, 128, 255), 128);
    mult = Triary(isdwm, Triary(isdaily, (Triary(((((vars["anchor"] == 0) or (Timeframe:Interval() <= 0)) or (Timeframe:Interval() >= vars["anchor"])) or (vars["anchor"] <= 1440)), 1, Round(vars["anchor"] / 1440))), Triary(isweekly, (Triary(((((vars["anchor"] == 0) or (Timeframe:Interval() <= 0)) or (Timeframe:Interval() >= vars["anchor"])) or (vars["anchor"] <= 7200)), 1, Round(vars["anchor"] / 7200))), Triary(ismonthly, (Triary(((((vars["anchor"] == 0) or (Timeframe:Interval() <= 0)) or (Timeframe:Interval() >= vars["anchor"])) or (vars["anchor"] <= 30240)), 1, Round(vars["anchor"] / 30240))), 1))), mult);
    mult = Triary(Timeframe:IsIntraday(), Triary((((vars["anchor"] == 0) or (Timeframe:Interval() <= 0)) or (Timeframe:Interval() >= vars["anchor"])), 1, Round(vars["anchor"] / Timeframe:Interval())), 1);
    vars["EMA1"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenF1"], mult));
    vars["EMA2"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenF2"], mult));
    vars["EMA3"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenF3"], mult));
    vars["EMA4"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenF4"], mult));
    vars["EMA5"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenF5"], mult));
    vars["EMA6"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenF6"], mult));
    vars["EMA7"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenF7"], mult));
    vars["EMA8"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenF8"], mult));
    vars["EMA9"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenF9"], mult));
    vars["EMA10"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenF10"], mult));
    vars["EMA11"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenF11"], mult));
    vars["EMA12"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenS1"], mult));
    vars["EMA13"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenS2"], mult));
    vars["EMA14"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenS3"], mult));
    vars["EMA15"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenS4"], mult));
    vars["EMA16"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenS5"], mult));
    vars["EMA17"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenS6"], mult));
    vars["EMA18"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenS7"], mult));
    vars["EMA19"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenS8"], mult));
    vars["EMA20"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenS9"], mult));
    vars["EMA21"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenS10"], mult));
    vars["EMA22"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenS11"], mult));
    vars["EMA23"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenS12"], mult));
    vars["EMA24"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenS13"], mult));
    vars["EMA25"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenS14"], mult));
    vars["EMA26"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenS15"], mult));
    vars["EMA27"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["lenS16"], mult));
    vars["EMA28"] = core.indicators:create("EMA", vars["src"], SafeMultiply(vars["len"], mult));
    plot1 = instance:addStream("plot1", core.Line, "Fast EMA 1", "Fast EMA 1", core.colors().Aqua, 0, 0);
    plot1:setWidth(2);
    plot1:setStyle(core.LINE_SOLID);
    vars["p1"] = plot1;
    plot2 = instance:addStream("plot2", core.Line, "Fast EMA 2", "Fast EMA 2", core.colors().Aqua, 0, 0);
    plot2:setWidth(1);
    plot2:setStyle(core.LINE_SOLID);
    plot3 = instance:addStream("plot3", core.Line, "Fast EMA 3", "Fast EMA 3", core.colors().Aqua, 0, 0);
    plot3:setWidth(1);
    plot3:setStyle(core.LINE_SOLID);
    plot4 = instance:addStream("plot4", core.Line, "Fast EMA 4", "Fast EMA 4", core.colors().Aqua, 0, 0);
    plot4:setWidth(1);
    plot4:setStyle(core.LINE_SOLID);
    plot5 = instance:addStream("plot5", core.Line, "Fast EMA 5", "Fast EMA 5", core.colors().Aqua, 0, 0);
    plot5:setWidth(1);
    plot5:setStyle(core.LINE_SOLID);
    plot6 = instance:addStream("plot6", core.Line, "Fast EMA 6", "Fast EMA 6", core.colors().Aqua, 0, 0);
    plot6:setWidth(1);
    plot6:setStyle(core.LINE_SOLID);
    plot7 = instance:addStream("plot7", core.Line, "Fast EMA 7", "Fast EMA 7", core.colors().Aqua, 0, 0);
    plot7:setWidth(1);
    plot7:setStyle(core.LINE_SOLID);
    plot8 = instance:addStream("plot8", core.Line, "Fast EMA 8", "Fast EMA 8", core.colors().Aqua, 0, 0);
    plot8:setWidth(1);
    plot8:setStyle(core.LINE_SOLID);
    plot9 = instance:addStream("plot9", core.Line, "Fast EMA 9", "Fast EMA 9", core.colors().Aqua, 0, 0);
    plot9:setWidth(1);
    plot9:setStyle(core.LINE_SOLID);
    plot10 = instance:addStream("plot10", core.Line, "Fast EMA 10", "Fast EMA 10", core.colors().Aqua, 0, 0);
    plot10:setWidth(1);
    plot10:setStyle(core.LINE_SOLID);
    plot11 = instance:addStream("plot11", core.Line, "Fast EMA 11", "Fast EMA 11", core.colors().Aqua, 0, 0);
    plot11:setWidth(1);
    plot11:setStyle(core.LINE_SOLID);
    vars["p2"] = plot11;
    plot12 = instance:createTextOutput("plot12", "Fast Avg", "Wingdings", 12, core.H_Center, core.V_Center, vars["gold"]);
    channel1_color = core.colors().Silver;
    instance:createChannelGroup("channel1", "channel1", vars["p1"], vars["p2"], Graphics:GetColor(channel1_color), 100 - 95, true);
    plot13 = instance:addStream("plot13", core.Line, "Slow EMA 1", "Slow EMA 1", core.colors().Lime, 0, 0);
    plot13:setWidth(2);
    plot13:setStyle(core.LINE_SOLID);
    vars["p3"] = plot13;
    plot14 = instance:addStream("plot14", core.Line, "Slow EMA 2", "Slow EMA 2", core.colors().Lime, 0, 0);
    plot14:setWidth(1);
    plot14:setStyle(core.LINE_SOLID);
    plot15 = instance:addStream("plot15", core.Line, "Slow EMA 3", "Slow EMA 3", core.colors().Lime, 0, 0);
    plot15:setWidth(1);
    plot15:setStyle(core.LINE_SOLID);
    plot16 = instance:addStream("plot16", core.Line, "Slow EMA 4", "Slow EMA 4", core.colors().Lime, 0, 0);
    plot16:setWidth(1);
    plot16:setStyle(core.LINE_SOLID);
    plot17 = instance:addStream("plot17", core.Line, "Slow EMA 5", "Slow EMA 5", core.colors().Lime, 0, 0);
    plot17:setWidth(1);
    plot17:setStyle(core.LINE_SOLID);
    plot18 = instance:addStream("plot18", core.Line, "Slow EMA 6", "Slow EMA 6", core.colors().Lime, 0, 0);
    plot18:setWidth(1);
    plot18:setStyle(core.LINE_SOLID);
    plot19 = instance:addStream("plot19", core.Line, "Slow EMA 7", "Slow EMA 7", core.colors().Lime, 0, 0);
    plot19:setWidth(1);
    plot19:setStyle(core.LINE_SOLID);
    plot20 = instance:addStream("plot20", core.Line, "Slow EMA 8", "Slow EMA 8", core.colors().Lime, 0, 0);
    plot20:setWidth(1);
    plot20:setStyle(core.LINE_SOLID);
    plot21 = instance:addStream("plot21", core.Line, "Slow EMA 9", "Slow EMA 9", core.colors().Lime, 0, 0);
    plot21:setWidth(1);
    plot21:setStyle(core.LINE_SOLID);
    plot22 = instance:addStream("plot22", core.Line, "Slow EMA 10", "Slow EMA 10", core.colors().Lime, 0, 0);
    plot22:setWidth(1);
    plot22:setStyle(core.LINE_SOLID);
    plot23 = instance:addStream("plot23", core.Line, "Slow EMA 11", "Slow EMA 11", core.colors().Lime, 0, 0);
    plot23:setWidth(1);
    plot23:setStyle(core.LINE_SOLID);
    plot24 = instance:addStream("plot24", core.Line, "Slow EMA 12", "Slow EMA 12", core.colors().Lime, 0, 0);
    plot24:setWidth(1);
    plot24:setStyle(core.LINE_SOLID);
    plot25 = instance:addStream("plot25", core.Line, "Slow EMA 13", "Slow EMA 13", core.colors().Lime, 0, 0);
    plot25:setWidth(1);
    plot25:setStyle(core.LINE_SOLID);
    plot26 = instance:addStream("plot26", core.Line, "Slow EMA 14", "Slow EMA 14", core.colors().Lime, 0, 0);
    plot26:setWidth(1);
    plot26:setStyle(core.LINE_SOLID);
    plot27 = instance:addStream("plot27", core.Line, "Slow EMA 15", "Slow EMA 15", core.colors().Lime, 0, 0);
    plot27:setWidth(1);
    plot27:setStyle(core.LINE_SOLID);
    plot28 = instance:addStream("plot28", core.Line, "Slow EMA 16", "Slow EMA 16", core.colors().Lime, 0, 0);
    plot28:setWidth(2);
    plot28:setStyle(core.LINE_SOLID);
    vars["p4"] = plot28;
    plot29 = instance:createTextOutput("plot29", "Slow Avg", "Wingdings", 12, core.H_Center, core.V_Center, core.colors().Fuchsia);
    channel2_color = core.colors().Silver;
    instance:createChannelGroup("channel2", "channel2", vars["p3"], vars["p4"], Graphics:GetColor(channel2_color), 100 - 95, true);
    plot30 = instance:createTextOutput("plot30", "EMA 200", "Wingdings", 12, core.H_Center, core.V_Center, core.colors().Black);
    plot31_open = instance:addStream("plot31_open", core.Line, "Open", "Open", core.colors().Black, 0, 0);
    plot31_high = instance:addStream("plot31_high", core.Line, "High", "High", core.colors().Black, 0, 0);
    plot31_low = instance:addStream("plot31_low", core.Line, "Low", "Low", core.colors().Black, 0, 0);
    plot31_close = instance:addStream("plot31_close", core.Line, "Close", "Close", core.colors().Black, 0, 0);
    instance:createCandleGroup("plot31", "plot31", plot31_open, plot31_high, plot31_low, plot31_close);
    vars["buy"] = 0;
    vars["sell"] = 0;
    vars["buybreak"] = 0;
    vars["sellbreak"] = 0;
    vars["__barssince1"] = CreateBarsSince();
    plot32 = instance:createTextOutput("plot32", "BUY Swing Arrow", "Wingdings", 12, core.H_Center, core.V_Center, core.colors().Lime, 0);
    vars["__barssince2"] = CreateBarsSince();
    plot33 = instance:createTextOutput("plot33", "SELL Swing Arrow", "Wingdings", 12, core.H_Center, core.V_Center, core.colors().Blue, 0);
    vars["__barssince3"] = CreateBarsSince();
    vars["__barssince4"] = CreateBarsSince();
    plot34 = instance:createTextOutput("plot34", "BUY Break Arrow", "Wingdings", 12, core.H_Center, core.V_Center, core.colors().Aqua, 0);
    vars["__barssince5"] = CreateBarsSince();
    vars["__barssince6"] = CreateBarsSince();
    plot35 = instance:createTextOutput("plot35", "SELL Break Arrow", "Wingdings", 12, core.H_Center, core.V_Center, core.colors().Blue, 0);
    vars["__barssince7"] = CreateBarsSince();
    vars["__barssince8"] = CreateBarsSince();
    vars["__barssince9"] = CreateBarsSince();
    vars["__barssince10"] = CreateBarsSince();
    signaler:Prepare(nameOnly);
    vars["__barssince11"] = CreateBarsSince();
    vars["__barssince12"] = CreateBarsSince();
    vars["__barssince13"] = CreateBarsSince();
    vars["__barssince14"] = CreateBarsSince();
    vars["__barssince15"] = CreateBarsSince();
    vars["__barssince16"] = CreateBarsSince();
end

function Update(period, mode)
    PineScriptUtils:UpdateSources(period, mode);
    mult = Triary(Timeframe:IsIntraday(), Triary((((vars["anchor"] == 0) or (Timeframe:Interval() <= 0)) or (Timeframe:Interval() >= vars["anchor"])), 1, Round(vars["anchor"] / Timeframe:Interval())), 1);
    mult = Triary(isdwm, Triary(isdaily, (Triary(((((vars["anchor"] == 0) or (Timeframe:Interval() <= 0)) or (Timeframe:Interval() >= vars["anchor"])) or (vars["anchor"] <= 1440)), 1, Round(vars["anchor"] / 1440))), Triary(isweekly, (Triary(((((vars["anchor"] == 0) or (Timeframe:Interval() <= 0)) or (Timeframe:Interval() >= vars["anchor"])) or (vars["anchor"] <= 7200)), 1, Round(vars["anchor"] / 7200))), Triary(ismonthly, (Triary(((((vars["anchor"] == 0) or (Timeframe:Interval() <= 0)) or (Timeframe:Interval() >= vars["anchor"])) or (vars["anchor"] <= 30240)), 1, Round(vars["anchor"] / 30240))), 1))), mult);
    vars["EMA1"]:update(mode);
    emaF1 = vars["EMA1"].DATA:tick(period);
    vars["EMA2"]:update(mode);
    emaF2 = vars["EMA2"].DATA:tick(period);
    vars["EMA3"]:update(mode);
    emaF3 = vars["EMA3"].DATA:tick(period);
    vars["EMA4"]:update(mode);
    emaF4 = vars["EMA4"].DATA:tick(period);
    vars["EMA5"]:update(mode);
    emaF5 = vars["EMA5"].DATA:tick(period);
    vars["EMA6"]:update(mode);
    emaF6 = vars["EMA6"].DATA:tick(period);
    vars["EMA7"]:update(mode);
    emaF7 = vars["EMA7"].DATA:tick(period);
    vars["EMA8"]:update(mode);
    emaF8 = vars["EMA8"].DATA:tick(period);
    vars["EMA9"]:update(mode);
    emaF9 = vars["EMA9"].DATA:tick(period);
    vars["EMA10"]:update(mode);
    emaF10 = vars["EMA10"].DATA:tick(period);
    vars["EMA11"]:update(mode);
    emaF11 = vars["EMA11"].DATA:tick(period);
    emafast = SafeDivide((SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(emaF1, emaF2), emaF3), emaF4), emaF5), emaF6), emaF7), emaF8), emaF9), emaF10), emaF11)), 11);
    vars["EMA12"]:update(mode);
    emaS1 = vars["EMA12"].DATA:tick(period);
    vars["EMA13"]:update(mode);
    emaS2 = vars["EMA13"].DATA:tick(period);
    vars["EMA14"]:update(mode);
    emaS3 = vars["EMA14"].DATA:tick(period);
    vars["EMA15"]:update(mode);
    emaS4 = vars["EMA15"].DATA:tick(period);
    vars["EMA16"]:update(mode);
    emaS5 = vars["EMA16"].DATA:tick(period);
    vars["EMA17"]:update(mode);
    emaS6 = vars["EMA17"].DATA:tick(period);
    vars["EMA18"]:update(mode);
    emaS7 = vars["EMA18"].DATA:tick(period);
    vars["EMA19"]:update(mode);
    emaS8 = vars["EMA19"].DATA:tick(period);
    vars["EMA20"]:update(mode);
    emaS9 = vars["EMA20"].DATA:tick(period);
    vars["EMA21"]:update(mode);
    emaS10 = vars["EMA21"].DATA:tick(period);
    vars["EMA22"]:update(mode);
    emaS11 = vars["EMA22"].DATA:tick(period);
    vars["EMA23"]:update(mode);
    emaS12 = vars["EMA23"].DATA:tick(period);
    vars["EMA24"]:update(mode);
    emaS13 = vars["EMA24"].DATA:tick(period);
    vars["EMA25"]:update(mode);
    emaS14 = vars["EMA25"].DATA:tick(period);
    vars["EMA26"]:update(mode);
    emaS15 = vars["EMA26"].DATA:tick(period);
    vars["EMA27"]:update(mode);
    emaS16 = vars["EMA27"].DATA:tick(period);
    emaslow = SafeDivide((SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(SafePlus(emaS1, emaS2), emaS3), emaS4), emaS5), emaS6), emaS7), emaS8), emaS9), emaS10), emaS11), emaS12), emaS13), emaS14), emaS15), emaS16)), 16);
    vars["EMA28"]:update(mode);
    ema200 = vars["EMA28"].DATA:tick(period);
    colfastL = (SafeGreater(emaF1, emaF2) and SafeGreater(emaF2, emaF3) and SafeGreater(emaF3, emaF4) and SafeGreater(emaF4, emaF5) and SafeGreater(emaF5, emaF6) and SafeGreater(emaF6, emaF7) and SafeGreater(emaF7, emaF8) and SafeGreater(emaF8, emaF9) and SafeGreater(emaF9, emaF10) and SafeGreater(emaF10, emaF11));
    colfastS = (SafeLess(emaF1, emaF2) and SafeLess(emaF2, emaF3) and SafeLess(emaF3, emaF4) and SafeLess(emaF4, emaF5) and SafeLess(emaF5, emaF6) and SafeLess(emaF6, emaF7) and SafeLess(emaF7, emaF8) and SafeLess(emaF8, emaF9) and SafeLess(emaF9, emaF10) and SafeLess(emaF10, emaF11));
    colslowL = (SafeGreater(emaS1, emaS2) and SafeGreater(emaS2, emaS3) and SafeGreater(emaS3, emaS4) and SafeGreater(emaS4, emaS5) and SafeGreater(emaS5, emaS6) and SafeGreater(emaS6, emaS7) and SafeGreater(emaS7, emaS8)) and (SafeGreater(emaS8, emaS9) and SafeGreater(emaS9, emaS10) and SafeGreater(emaS10, emaS11) and SafeGreater(emaS11, emaS12) and SafeGreater(emaS12, emaS13) and SafeGreater(emaS13, emaS14) and SafeGreater(emaS14, emaS15) and SafeGreater(emaS15, emaS16));
    colslowS = (SafeLess(emaS1, emaS2) and SafeLess(emaS2, emaS3) and SafeLess(emaS3, emaS4) and SafeLess(emaS4, emaS5) and SafeLess(emaS5, emaS6) and SafeLess(emaS6, emaS7) and SafeLess(emaS7, emaS8)) and (SafeLess(emaS8, emaS9) and SafeLess(emaS9, emaS10) and SafeLess(emaS10, emaS11) and SafeLess(emaS11, emaS12) and SafeLess(emaS12, emaS13) and SafeLess(emaS13, emaS14) and SafeLess(emaS14, emaS15) and SafeLess(emaS15, emaS16));
    colFinal = Triary(colfastL and SafeGreater(emaS1, emaS16), core.colors().Aqua, Triary(colfastS and SafeLess(emaS1, emaS16), core.colors().Blue, core.colors().Gray));
    colFinal2 = Triary(colslowL, core.colors().Lime, Triary(colslowS, core.colors().Red, core.colors().Gray));
    plot1[period] = emaF1;
    plot1:setColor(period, colFinal);
    plot2[period] = emaF2;
    plot2:setColor(period, colFinal);
    plot3[period] = emaF3;
    plot3:setColor(period, colFinal);
    plot4[period] = emaF4;
    plot4:setColor(period, colFinal);
    plot5[period] = emaF5;
    plot5:setColor(period, colFinal);
    plot6[period] = emaF6;
    plot6:setColor(period, colFinal);
    plot7[period] = emaF7;
    plot7:setColor(period, colFinal);
    plot8[period] = emaF8;
    plot8:setColor(period, colFinal);
    plot9[period] = emaF9;
    plot9:setColor(period, colFinal);
    plot10[period] = emaF10;
    plot10:setColor(period, colFinal);
    plot11[period] = emaF11;
    plot11:setColor(period, colFinal);
    PlotShape:SetValue(plot12, period, source, Triary(vars["ShowAvgs"], emafast, nil), "\161", "", plot12_series);
    plot13[period] = emaS1;
    plot13:setColor(period, colFinal2);
    plot14[period] = emaS2;
    plot14:setColor(period, colFinal2);
    plot15[period] = emaS3;
    plot15:setColor(period, colFinal2);
    plot16[period] = emaS4;
    plot16:setColor(period, colFinal2);
    plot17[period] = emaS5;
    plot17:setColor(period, colFinal2);
    plot18[period] = emaS6;
    plot18:setColor(period, colFinal2);
    plot19[period] = emaS7;
    plot19:setColor(period, colFinal2);
    plot20[period] = emaS8;
    plot20:setColor(period, colFinal2);
    plot21[period] = emaS9;
    plot21:setColor(period, colFinal2);
    plot22[period] = emaS10;
    plot22:setColor(period, colFinal2);
    plot23[period] = emaS11;
    plot23:setColor(period, colFinal2);
    plot24[period] = emaS12;
    plot24:setColor(period, colFinal2);
    plot25[period] = emaS13;
    plot25:setColor(period, colFinal2);
    plot26[period] = emaS14;
    plot26:setColor(period, colFinal2);
    plot27[period] = emaS15;
    plot27:setColor(period, colFinal2);
    plot28[period] = emaS16;
    plot28:setColor(period, colFinal2);
    PlotShape:SetValue(plot29, period, source, Triary(vars["ShowAvgs"], emaslow, nil), "\161", "", plot29_series);
    PlotShape:SetValue(plot30, period, source, Triary(vars["show200"], ema200, nil), "\161", "", plot30_series);
    c = Triary(colfastL and SafeGreater(emaS1, emaS16), vars["AQUA"], Triary(colfastS and SafeLess(emaS1, emaS16), vars["BLUE"], vars["GRAY"]));
    plot31_color = Triary(vars["clrBars"], c, nil);
    if plot31_color then
        plot31_open[period] = source.open[period];
        plot31_high[period] = source.high[period];
        plot31_low[period] = source.low[period];
        plot31_close[period] = source.close[period];
        plot31_open:setColor(period, plot31_color);
    else
        plot31_open:setNoData(period);
        plot31_high:setNoData(period);
        plot31_low:setNoData(period);
        plot31_close:setNoData(period);
    end
    vars["buy"] = Triary(SafeGreater(emafast, emaslow) and SafeGreater(emaS1, emaS16) and not (colslowS) and colfastL and ((not (vars["ShowCon"]) or colslowL)) and ((not (vars["emaFilter"]) or SafeGreater(emafast, ema200))), Triary(SafeGreater(Nz(vars["buy"]), 0), SafePlus(vars["buy"], 1), 1), 0);
    vars["sell"] = Triary(SafeLess(emafast, emaslow) and SafeLess(emaS1, emaS16) and not (colslowL) and colfastS and ((not (vars["ShowCon"]) or colslowS)) and ((not (vars["emaFilter"]) or SafeLess(emafast, ema200))), Triary(SafeGreater(Nz(vars["sell"]), 0), SafePlus(vars["sell"], 1), 1), 0);
    vars["buy"] = Triary((vars["buy"] > 1) and colfastL and (vars["uOCCswing"] and ((SafeLess(source.close:tick(period), source.open:tick(period - 1))) and ((source.close:tick(period) > source.open:tick(period))))), 1, vars["buy"]);
    vars["sell"] = Triary((vars["sell"] > 1) and colfastS and (vars["uOCCswing"] and ((SafeGreater(source.close:tick(period - 1), source.open:tick(period - 1))) and ((source.close:tick(period) < source.open:tick(period))))), 1, vars["sell"]);
    vars["buybreak"] = Triary(SafeGreater(emafast, emaslow) and not (colslowS) and ((not (vars["emaFilter"]) or SafeGreater(emafast, ema200))), Triary(SafeGreater(Nz(vars["buybreak"]), 0), SafePlus(vars["buybreak"], 1), 1), 0);
    vars["sellbreak"] = Triary(SafeLess(emafast, emaslow) and not (colslowL) and ((not (vars["emaFilter"]) or SafeLess(emafast, ema200))), Triary(SafeGreater(Nz(vars["sellbreak"]), 0), SafePlus(vars["sellbreak"], 1), 1), 0);
    PlotArrow:SetValue(plot32, period, Triary(vars["ShowSwing"] and (vars["buy"] == 1) and SafeGreater(vars["__barssince1"]:set(period, (Nz(vars["buy"], 1) == 1)), vars["Lookback"]), 1, nil), core.colors().Lime, core.colors().Blue);
    PlotArrow:SetValue(plot33, period, Triary(vars["ShowSwing"] and (vars["sell"] == 1) and SafeGreater(vars["__barssince2"]:set(period, (Nz(vars["sell"], 1) == 1)), vars["Lookback"]), (-1), nil), core.colors().Blue, core.colors().Red);
    PlotArrow:SetValue(plot34, period, Triary(vars["ShowBreak"] and (vars["buybreak"] == 1) and SafeGreater(vars["__barssince3"]:set(period, (Nz(vars["sellbreak"], 1) == 1)), vars["Lookback"]) and SafeGreater(vars["__barssince4"]:set(period, (Nz(vars["buybreak"], 1) == 1)), vars["Lookback"]), 1, nil), core.colors().Aqua, core.colors().Blue);
    PlotArrow:SetValue(plot35, period, Triary(vars["ShowBreak"] and (vars["sellbreak"] == 1) and SafeGreater(vars["__barssince5"]:set(period, (Nz(vars["buybreak"], 1) == 1)), vars["Lookback"]) and SafeGreater(vars["__barssince6"]:set(period, (Nz(vars["sellbreak"], 1) == 1)), vars["Lookback"]), (-1), nil), core.colors().Blue, core.colors().Blue);
    gAlert = ((vars["ShowSwing"] and ((((vars["buy"] == 1) and SafeGreater(vars["__barssince7"]:set(period, (Nz(vars["buy"], 1) == 1)), vars["Lookback"])) or ((vars["sell"] == 1) and SafeGreater(vars["__barssince8"]:set(period, (Nz(vars["sell"], 1) == 1)), vars["Lookback"]))))) or (vars["ShowBreak"] and (((vars["buybreak"] == 1) or (vars["sellbreak"] == 1))) and SafeGreater(vars["__barssince9"]:set(period, (Nz(vars["buybreak"], 1) == 1)), vars["Lookback"]) and SafeGreater(vars["__barssince10"]:set(period, (Nz(vars["sellbreak"], 1) == 1)), vars["Lookback"])));
    if gAlert and period == source:size() - 1 then
        signaler:SignalEx(1, "Guppy Alert", period, source);
    end
    if ((vars["ShowSwing"] and (vars["buy"] == 1) and SafeGreater(vars["__barssince11"]:set(period, (Nz(vars["buy"], 1) == 1)), vars["Lookback"])) or (vars["ShowBreak"] and (vars["buybreak"] == 1) and SafeGreater(vars["__barssince12"]:set(period, (Nz(vars["buybreak"], 1) == 1)), vars["Lookback"]) and SafeGreater(vars["__barssince13"]:set(period, (Nz(vars["sellbreak"], 1) == 1)), vars["Lookback"]))) and period == source:size() - 1 then
        signaler:SignalEx(2, "BUY", period, source);
    end
    if ((vars["ShowSwing"] and (vars["sell"] == 1) and SafeGreater(vars["__barssince14"]:set(period, (Nz(vars["sell"], 1) == 1)), vars["Lookback"])) or (vars["ShowBreak"] and (vars["sellbreak"] == 1) and SafeGreater(vars["__barssince15"]:set(period, (Nz(vars["buybreak"], 1) == 1)), vars["Lookback"]) and SafeGreater(vars["__barssince16"]:set(period, (Nz(vars["sellbreak"], 1) == 1)), vars["Lookback"]))) and period == source:size() - 1 then
        signaler:SignalEx(3, "SELL", period, source);
    end
end
function ReleaseInstance()
    signaler:ReleaseInstance();
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    signaler:AsyncOperationFinished(cookie, success, message, message1, message2);
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
function Timeframe:InSeconds(period, source)
    if timeframe == "M" then
        return "M1";
    elseif timeframe == "D" then
        return "D1";
    elseif timeframe == "t" then
        return "t1";
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
PlotArrow = {};
function PlotArrow:SetValue(plot, period, value, up_color, down_color)
    if not value then
        plot:setNoData(period);
        return;
    end
    if value >= 0 then
        plot:set(period, value, "\225", "\225");
        plot:setColor(period, up_color);
        return;
    end
    plot:set(period, value, "\226", "\226");
    plot:setColor(period, down_color);
end
function CreateBarsSince()
    local bs = {};
    bs.last_period = nil;
    function bs:set(period, condition)
        if condition then
            self.last_period = period;
        end
        if self.last_period == nil then
            return nil;
        end
        return period - self.last_period;
    end
    return bs;
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