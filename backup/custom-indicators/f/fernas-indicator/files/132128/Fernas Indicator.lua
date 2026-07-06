-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69556

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
    indicator:name("Fernas Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("ANN Strategy Indicator");
    indicator.parameters:addDouble("threshold", "Threshold", "Threshold", 0.0014);
	indicator.parameters:addString("TF", "Bar Size to display High/Low", "", "D1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
    
    indicator.parameters:addGroup("Center Of Gravity Oscillator Calculation #1"); 	
	indicator.parameters:addInteger("FIR_N_1", "FIR (LWMA) number of periods", "No description", 10);
    indicator.parameters:addInteger("S_N_1", "Signal Line Smoothing Periods", "No description", 3);
    indicator.parameters:addString("PM_1", "Price Mode", "", "C");
    indicator.parameters:addStringAlternative("PM_1", "Close", "", "C");
    indicator.parameters:addStringAlternative("PM_1", "Median", "", "M");
    indicator.parameters:addStringAlternative("PM_1", "Typical", "", "T");
    indicator.parameters:addStringAlternative("PM_1", "Weighted", "", "W");
    indicator.parameters:addInteger("K_1", "Number of periods for %K", "The number of periods for %K.", 10, 2, 1000);
    indicator.parameters:addInteger("SD_1", "%D slowing periods", "The number of periods for slow %D.", 5, 2, 1000);
    indicator.parameters:addInteger("D_1", "Number of periods for %D", "The number of periods for %D.", 5, 2, 1000);

    indicator.parameters:addGroup("Center Of Gravity Oscillator Calculation #2");
	indicator.parameters:addInteger("FIR_N_2", "FIR (LWMA) number of periods", "No description", 10);
    indicator.parameters:addInteger("S_N_2", "Signal Line Smoothing Periods", "No description", 3);
    indicator.parameters:addString("PM_2", "Price Mode", "", "C");
    indicator.parameters:addStringAlternative("PM_2", "Close", "", "C");
    indicator.parameters:addStringAlternative("PM_2", "Median", "", "M");
    indicator.parameters:addStringAlternative("PM_2", "Typical", "", "T");
    indicator.parameters:addStringAlternative("PM_2", "Weighted", "", "W");
    indicator.parameters:addInteger("K_2", "Number of periods for %K", "The number of periods for %K.", 10, 2, 1000);
    indicator.parameters:addInteger("SD_2", "%D slowing periods", "The number of periods for slow %D.", 5, 2, 1000);
    indicator.parameters:addInteger("D_2", "Number of periods for %D", "The number of periods for %D.", 5, 2, 1000);

    indicator.parameters:addGroup("FTLM STLM RBCI in synchronization");
    indicator.parameters:addBoolean("S1", "Use 1. Filter", "", true);
	indicator.parameters:addBoolean("S2", "Use 2. Filter", "", true);
	indicator.parameters:addBoolean("S3", "Use 3. Filter", "", true);
	
	indicator.parameters:addGroup("MA Calculation"); 
	indicator.parameters:addInteger("Period", "MA Period", "Period" , 14);
	indicator.parameters:addString("Method", "MA Method", "Method" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("1. Filter Calculation"); 
	indicator.parameters:addString("Method1", "Selector", "Selector" , "FATL");
    indicator.parameters:addStringAlternative("Method1", "FTLM", "FTLM" , "FTLM");
    indicator.parameters:addStringAlternative("Method1", "STLM", "STLM" , "STLM");
    indicator.parameters:addStringAlternative("Method1", "FATL", "FATL" , "FATL");
	indicator.parameters:addStringAlternative("Method1", "SATL", "SATL" , "SATL");
	indicator.parameters:addStringAlternative("Method1", "RFTL", "RFTL" , "RFTL");
	indicator.parameters:addStringAlternative("Method1", "RSTL", "RSTL" , "RSTL");
	indicator.parameters:addStringAlternative("Method1", "RBCI", "RBCI" , "RBCI");
	indicator.parameters:addStringAlternative("Method1", "PCCI", "PCCI" , "PCCI");
	
	indicator.parameters:addGroup("2. Filter Calculation"); 
	indicator.parameters:addString("Method2", "Selector", "Selector" , "FTLM");
    indicator.parameters:addStringAlternative("Method2", "FTLM", "FTLM" , "FTLM");
    indicator.parameters:addStringAlternative("Method2", "STLM", "STLM" , "STLM");
    indicator.parameters:addStringAlternative("Method2", "FATL", "FATL" , "FATL");
	indicator.parameters:addStringAlternative("Method2", "SATL", "SATL" , "SATL");
	indicator.parameters:addStringAlternative("Method2", "RFTL", "RFTL" , "RFTL");
	indicator.parameters:addStringAlternative("Method2", "RSTL", "RSTL" , "RSTL");
	indicator.parameters:addStringAlternative("Method2", "RBCI", "RBCI" , "RBCI");
	indicator.parameters:addStringAlternative("Method2", "PCCI", "PCCI" , "PCCI");
	
	indicator.parameters:addGroup("3. Filter Calculation"); 
	indicator.parameters:addString("Method3", "Selector", "Selector" , "RBCI");
    indicator.parameters:addStringAlternative("Method3", "FTLM", "FTLM" , "FTLM");
    indicator.parameters:addStringAlternative("Method3", "STLM", "STLM" , "STLM");
    indicator.parameters:addStringAlternative("Method3", "FATL", "FATL" , "FATL");
	indicator.parameters:addStringAlternative("Method3", "SATL", "SATL" , "SATL");
	indicator.parameters:addStringAlternative("Method3", "RFTL", "RFTL" , "RFTL");
	indicator.parameters:addStringAlternative("Method3", "RSTL", "RSTL" , "RSTL");
	indicator.parameters:addStringAlternative("Method3", "RBCI", "RBCI" , "RBCI");
	indicator.parameters:addStringAlternative("Method3", "PCCI", "PCCI" , "PCCI");
    
    indicator.parameters:addColor("up_color", "Up color", "", core.colors().Green);
    indicator.parameters:addColor("down_color", "Down color", "", core.colors().Red);
end

local source, ann, d1, d2, FTLM, out, up_color, down_color;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    local profile = core.indicators:findIndicator("ANN STRATEGY INDICATOR");
    assert(profile ~= nil, "Please, download and install " .. "ANN STRATEGY INDICATOR" .. ".LUA indicator");
    local indicatorParams = profile:parameters();
    ann = core.indicators:create("ANN STRATEGY INDICATOR", source, instance.parameters.threshold, instance.parameters.TF);

    local profile = core.indicators:findIndicator("DINAPOLI PREFERRED STOCHASTIC CENTER OF GRAVITY OSCILLATOR");
    assert(profile ~= nil, "Please, download and install " .. "DINAPOLI PREFERRED STOCHASTIC CENTER OF GRAVITY OSCILLATOR" .. ".LUA indicator");
    
	--Dinapoli Preferred Stochastic Center Of Gravity Oscillator
	
	local indicatorParams = profile:parameters();
    indicatorParams:setInteger("FIR_N", instance.parameters.FIR_N_1);
    indicatorParams:setInteger("S_N", instance.parameters.S_N_1);
    indicatorParams:setInteger("K", instance.parameters.K_1);
    indicatorParams:setInteger("SD", instance.parameters.SD_1);
    indicatorParams:setInteger("D", instance.parameters.D_1);
    indicatorParams:setString("PM", instance.parameters.PM_1);
    d1 = core.indicators:create("DINAPOLI PREFERRED STOCHASTIC CENTER OF GRAVITY OSCILLATOR", source, indicatorParams)
    local indicatorParams = profile:parameters();
    indicatorParams:setInteger("FIR_N", instance.parameters.FIR_N_2);
    indicatorParams:setInteger("S_N", instance.parameters.S_N_2);
    indicatorParams:setInteger("K", instance.parameters.K_2);
    indicatorParams:setInteger("SD", instance.parameters.SD_2);
    indicatorParams:setInteger("D", instance.parameters.D_2);
    indicatorParams:setString("PM", instance.parameters.PM_2);
    d2 = core.indicators:create("DINAPOLI PREFERRED STOCHASTIC CENTER OF GRAVITY OSCILLATOR", source, indicatorParams)

    local profile = core.indicators:findIndicator("FTLM STLM RBCI IN SYNCHRONIZATION");
    assert(profile ~= nil, "Please, download and install " .. "FTLM STLM RBCI IN SYNCHRONIZATION" .. ".LUA indicator");
    local indicatorParams = profile:parameters();
    indicatorParams:setBoolean("S1", instance.parameters.S1);
    indicatorParams:setBoolean("S2", instance.parameters.S2);
    indicatorParams:setBoolean("S3", instance.parameters.S3);
    indicatorParams:setInteger("Period", instance.parameters.Period);
    indicatorParams:setString("Method", instance.parameters.Method);
    indicatorParams:setString("Method1", instance.parameters.Method1);
    indicatorParams:setString("Method2", instance.parameters.Method2);
    indicatorParams:setString("Method3", instance.parameters.Method3);
    FTLM = core.indicators:create("FTLM STLM RBCI IN SYNCHRONIZATION", source, indicatorParams)
    up_color = instance.parameters.up_color;
    down_color = instance.parameters.down_color;

    out = instance:addStream("out", core.Bar, "OUT", "OUT", up_color, 0, 0);

    core.host:execute("setTimer", 1, 1);
end

function Update(period, mode)
    ann:update(mode);
    d1:update(mode);
    d2:update(mode);
    FTLM:update(mode);
    core.host:trace("ann " .. ann.DATA[period])
    core.host:trace("d " .. d1.DATA[period])
    core.host:trace("ft " .. FTLM.DATA[period])
    if ann.DATA[period] == 1 and d1.DATA[period] == 1 and d2.DATA[period] == 1 and FTLM.DATA[period] == 1 then
        out[period] = 1;
        out:setColor(period, up_color);
    elseif ann.DATA[period] == -1 and d1.DATA[period] == -1 and d2.DATA[period] == -1 and FTLM.DATA[period] == -1 then
        out[period] = -1;
        out:setColor(period, down_color);
    end
end

local loaded = false;
function AsyncOperationFinished(cookie, successful, message, message1, message2)
    if cookie == 1 then
        if ann.DATA:hasData(ann.DATA:size() - 1) then
            if not loaded then
                loaded = true;
                instance:updateFrom(0);
            end
        else
            loaded = false;
        end
    end
end