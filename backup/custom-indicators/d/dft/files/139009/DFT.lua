-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70626

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                           mario.jemic@gmail.com  |
--|                          https://AppliedMachineLearning.systems  |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                                  Patreon: https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Donchian Fibonacci Zones with Trading Features");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("per", "per", "", 24, 15, 60);
    indicator.parameters:addString("preunit", "prediction in atr or percent", "", "atr");
    indicator.parameters:addStringAlternative("preunit", "ATR", "", "atr");
    indicator.parameters:addStringAlternative("preunit", "Percent", "", "percent");
    indicator.parameters:addDouble("preamount", "added amount of prediction", "", 1, 0, 6);

    indicator.parameters:addColor("phb_color", "High border Color", "Color", core.rgb(0, 255, 255));
    indicator.parameters:addInteger("phb_width", "High border Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("phb_style", "High border Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("phb_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("phf_color", "Highest Fib Color", "Color", core.colors().Gray);
    indicator.parameters:addInteger("phf_width", "Highest Fib Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("phf_style", "Highest Fib Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("phf_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("pchf_color", "Centhi Fib Color", "Color", core.rgb(40, 40, 40));
    indicator.parameters:addInteger("pchf_width", "Centhi Fib Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("pchf_style", "Centhi Fib Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("pchf_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("pclf_color", "Centlo Fib Color", "Color", core.colors().Gray);
    indicator.parameters:addInteger("pclf_width", "Centlo Fib Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("pclf_style", "Centlo Fib Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("pclf_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("plf_color", "Lowest Fib Color", "Color", core.rgb(255, 80, 0));
    indicator.parameters:addInteger("plf_width", "Lowest Fib Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("plf_style", "Lowest Fib Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("plf_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("plb_color", "Low Border Color", "Color", core.colors().Black);
    indicator.parameters:addInteger("plb_width", "Low Border Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("plb_style", "Low Border Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("plb_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("swing_level_color_1", "Swing Level Color 1", "Color", core.colors().Green);
    indicator.parameters:addColor("swing_level_color_2", "Swing Level Color 2", "Color", core.colors().Red);
    indicator.parameters:addInteger("swing_level_width", "Swing Level Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("swing_level_style", "Swing Level Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("swing_level_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("schigh_color", "Expect #1 Color", "Color", core.colors().Teal);
    indicator.parameters:addInteger("schigh_width", "Expect #1 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("schigh_style", "Expect #1 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("schigh_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("sclow_color", "Expect #2 Color", "Color", core.colors().Teal);
    indicator.parameters:addInteger("sclow_width", "Expect #2 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("sclow_style", "Expect #2 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("sclow_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("pr1_color", "Predict #1 Color", "Color", core.colors().Blue);
    indicator.parameters:addInteger("pr1_width", "Predict #1 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("pr1_style", "Predict #1 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("pr1_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("pr2_color", "Predict #2 Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("pr2_width", "Predict #2 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("pr2_style", "Predict #2 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("pr2_style", core.FLAG_LINE_STYLE);
end

local source, per, preamount;
local lb, hb, leh, lel, hbtrue, hftrue, lftrue, atr, phb
local phf, pchf, pclf, plf, plb, swing_level, schigh, sclow, pr1, pr2
local ps1, ps2, ps3, ps4, ps5, ps6, ps7, ps8, ps9, ps10

function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    preamount = instance.parameters.preamount;
    per = instance.parameters.per;
    lb = instance:addInternalStream(source:first() + per, 0);
    hb = instance:addInternalStream(source:first() + per, 0);
    leh = instance:addInternalStream(lb:first() + 3, 0);
    lel = instance:addInternalStream(lb:first() + 3, 0);
    hbtrue = instance:addInternalStream(lb:first() + 3, 0);
    hftrue = instance:addInternalStream(lb:first() + 3, 0);
    lftrue = instance:addInternalStream(lb:first() + 3, 0);
    atr = core.indicators:create("ATR", source, per);

    phb = instance:addStream("phb", core.Line, "High border", "High border", instance.parameters.phb_color, 0, 0);
    phb:setWidth(instance.parameters.phb_width);
    phb:setStyle(instance.parameters.phb_style);

    phf = instance:addStream("phf", core.Line, "Highest fib", "Highest fib", instance.parameters.phf_color, 0, 0);
    phf:setWidth(instance.parameters.phf_width);
    phf:setStyle(instance.parameters.phf_style);

    pchf = instance:addStream("pchf", core.Line, "Centhi Fib", "Centhi Fib", instance.parameters.pchf_color, 0, 0);
    pchf:setWidth(instance.parameters.pchf_width);
    pchf:setStyle(instance.parameters.pchf_style);

    pclf = instance:addStream("pclf", core.Line, "centlo fib", "centlo fib", instance.parameters.pclf_color, 0, 0);
    pclf:setWidth(instance.parameters.pclf_width);
    pclf:setStyle(instance.parameters.pclf_style);

    plf = instance:addStream("plf", core.Line, "Lowest fib", "Lowest fib", instance.parameters.plf_color, 0, 0);
    plf:setWidth(instance.parameters.plf_width);
    plf:setStyle(instance.parameters.plf_style);

    plb = instance:addStream("plb", core.Line, "Low border", "Low border", instance.parameters.plb_color, 0, 0);
    plb:setWidth(instance.parameters.plb_width);
    plb:setStyle(instance.parameters.plb_style);

    swing_level = instance:addStream("swing_level", core.Line, "Swing level", "Swing level", instance.parameters.swing_level_color_1, 0, 0);
    swing_level:setWidth(instance.parameters.swing_level_width);
    swing_level:setStyle(instance.parameters.swing_level_style);

    schigh = instance:addStream("schigh", core.Line, "Expect", "Expect", instance.parameters.schigh_color, 0, 0);
    schigh:setWidth(instance.parameters.schigh_width);
    schigh:setStyle(instance.parameters.schigh_style);

    sclow = instance:addStream("sclow", core.Line, "Expect", "Expect", instance.parameters.sclow_color, 0, 0);
    sclow:setWidth(instance.parameters.sclow_width);
    sclow:setStyle(instance.parameters.sclow_style);

    pr1 = instance:addStream("pr1", core.Line, "Predict", "Predict", instance.parameters.pr1_color, 0, 0);
    pr1:setWidth(instance.parameters.pr1_width);
    pr1:setStyle(instance.parameters.pr1_style);

    pr2 = instance:addStream("pr2", core.Line, "Predict", "Predict", instance.parameters.pr2_color, 0, 0);
    pr2:setWidth(instance.parameters.pr2_width);
    pr2:setStyle(instance.parameters.pr2_style);

    ps1 = instance:createTextOutput("txt1", "evupin", "Wingdings", 8, core.H_Center, core.V_Bottom, core.colors().Blue);
    ps2 = instance:createTextOutput("txt2", "evupout", "Wingdings", 8, core.H_Center, core.V_Bottom, core.colors().Gray);
    ps3 = instance:createTextOutput("txt3", "evdownin", "Wingdings", 8, core.H_Center, core.V_Bottom, core.colors().Red);
    ps4 = instance:createTextOutput("txt4", "evdownout", "Wingdings", 8, core.H_Center, core.V_Bottom, core.colors().Gray);
    ps5 = instance:createTextOutput("txt5", "hbdtrue", "Wingdings", 8, core.H_Center, core.V_Bottom, core.colors().Blue);
    ps6 = instance:createTextOutput("txt6", "lbdtrue", "Wingdings", 8, core.H_Center, core.V_Bottom, core.colors().Red);
    ps7 = instance:createTextOutput("txt7", "chfdtrue", "Wingdings", 8, core.H_Center, core.V_Bottom, core.colors().Green);
    ps8 = instance:createTextOutput("txt8", "clfdtrue", "Wingdings", 8, core.H_Center, core.V_Bottom, core.colors().Maroon);
    ps9 = instance:createTextOutput("txt9", "txt9", "Wingdings", 8, core.H_Center, core.V_Bottom, core.colors().Blue);
    ps10 = instance:createTextOutput("txt10", "txt10", "Wingdings", 8, core.H_Center, core.V_Bottom, core.colors().Red);

    instance:createChannelGroup("Up trend zone", "ch1", phb, phf, instance.parameters.phb_color, 50, true);
    instance:createChannelGroup("Ranging zone", "ch2", pchf, pclf, instance.parameters.pchf_color, 50, true);
    instance:createChannelGroup("Down trend zone", "ch1", plf, plb, instance.parameters.plf_color, 50, true);
end

function evpup(period)
    return source.high[period] > hb[period - 1];
end

function evpdown(period)
    return source.low[period] < lb[period - 1];
end

function Update(period, mode)
    atr:update(mode);
    if period < lb:first() then
        return;
    end
    local _lb, _hb = mathex.minmax(source, core.rangeTo(period, per));
    lb[period] = _lb;
    hb[period] = _hb;
    local dist = hb[period] - lb[period];
    pchf[period] = hb[period] - dist * 0.382;
    pclf[period] = hb[period] - dist * 0.618;
    hbtrue[period] = 1;
    if not hb:hasData(period - 3) then
        return;
    end
    local tol = atr.DATA[period] * 0.2;
    local evhbstart = hb[period - 3] == hb[period - 2] and hb[period - 2] == hb[period - 1] and evpup(period);
    local evlbstart = lb[period - 3] == lb[period - 2] and lb[period - 2] == lb[period - 1] and evpdown(period);
    evhb = evhbstart or source.high[period - 1] == hb[period];
    local hf = hb[period] - dist * 0.236;
    leh[period] = leh[period - 1];
    if evhb then
        leh[period] = hf;
    end
    
    evlb = evlbstart or source.low[period - 1] == lb[period];
    local lf = hb[period] - dist * 0.764;
    lel[period] = lel[period - 1];
    if evlb then
        lel[period] = lf;
    end
    if evhb then
        hbtrue[period] = 1
    elseif evlb then
        hbtrue[period] = 0;
    else
        hbtrue[period] = hbtrue[period - 1];
    end
    
    if core.crossesOver(source.close, hf, period) then
        ps1:set(period, hb[period] + tol, "\217");
        hftrue[period] = 1;
    elseif core.crossesUnder(source.close, hf, period) then
        ps2:set(period, hb[period]+tol, "\251");
        hftrue[period] = 0;
    else
        hftrue[period] = hftrue[period - 1];
    end
    if core.crossesUnder(source.close, lf, period) then
        ps3:set(period, lb[period]-tol, "\218");
        lftrue[period] = 1;
    elseif core.crossesOver(source.close, lf, period) then
        ps4:set(period, lb[period]-tol, "\251");
        lftrue[period] = 0;
    else
        lftrue[period] = lftrue[period - 1];
    end
    cftrue = hftrue[period] == 0 and lftrue[period] == 0;
    hbdtrue = hftrue[period] == 1
    lbdtrue = lftrue[period] == 1
    chfdtrue = cftrue and hbtrue[period] == 1
    clfdtrue = cftrue and hbtrue[period] == 0
    phb[period] = phb[period - 1];
    plb[period] = plb[period - 1];
    plf[period] = plf[period - 1];
    phf[period] = phf[period - 1];
    if preunit == "atr" then
        pred = preamount * atr.DATA[period]
    else
        pred = preamount * source.close[period] / 100;
    end
    if hbdtrue then
        schigh[period] = hb[period]
        sclow[period] = hf
        if (evpup(period) or evpup(period - 1)) then
            prcahigh = hb[period] + pred;
            ps9:set(period, hb[period]+tol, "\116");
        end
        phb[period] = hb[period];
        ps5:set(period, hb[period], "\161");
        phf[period] = hf;
    elseif lbdtrue then
        schigh[period] = lf
        sclow[period] = lb[period];
        if (evpdown(period) or evpdown(period - 1)) then
            prcalow = lb[period] - pred;
            ps10:set(period, lb[period]-tol, "\116");
        end
        plb[period] = lb[period];
        ps6:set(period, lb[period], "\161");
        plf[period] = lf;
    elseif chfdtrue then
        schigh[period] = hf
        sclow[period] = pclf[period];
        ps7:set(period, pchf[period], "\161");
        phf[period] = hf;
    elseif clfdtrue then
        schigh[period] = pchf[period]
        sclow[period] = lf;
        ps8:set(period, pclf[period], "\161");
        plf[period] = lf;
    end
    if hbtrue[period] == 1 then
        swing_level[period] = leh[period];
        swing_level:setColor(period, instance.parameters.swing_level_color_1);
    else
        swing_level[period] = lel[period];
        swing_level:setColor(period, instance.parameters.swing_level_color_2);
    end
    if (evpup(period) or evpup(period - 1)) and preamount>0 then
        pr1[period] = prcahigh;
    end
    if (evpdown(period) or evpdown(period - 1)) and preamount>0 then
        pr2[period] = prcalow;
    end
end
