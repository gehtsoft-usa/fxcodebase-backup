-- Id: 860
-- Indicator profile initialization routine
function Init()
    strategy:name("John Ehlers' Center Of Gravity strategy");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("");

    strategy.parameters:addGroup("Parameters");
    strategy.parameters:addInteger("FIR_N", "FIR (LWMA) number of periods", "No description", 10);
    strategy.parameters:addInteger("S_N", "strategy Line Smoothing Periods", "No description", 3);
    strategy.parameters:addString("PM", "Price Mode", "", "C");
    strategy.parameters:addStringAlternative("PM", "Close", "", "C");
    strategy.parameters:addStringAlternative("PM", "Median", "", "M");
    strategy.parameters:addStringAlternative("PM", "Typical", "", "T");
    strategy.parameters:addStringAlternative("PM", "Weighted", "", "W");
    strategy.parameters:addString("Period", "Timeframe", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
end

local SoundFile;
local gSource = nil;
local gJecog = nil;
local b1, b2;
local first;

function Prepare()
    local ShowAlert = instance.parameters.ShowAlert;
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");
    assert(instance.parameters.Period ~= "t1", "Signal cannot be applied on ticks");
    ExtSetupSignal("JECOG signal:", ShowAlert);
    gSource = ExtSubscribe(1, nil, instance.parameters.Period, true, "bar");
    assert(core.indicators:findIndicator("JECOG") ~= nil, "JECOG" .. " indicator must be installed");
    gJecog = core.indicators:create("JECOG", gSource, instance.parameters.FIR_N, instance.parameters.S_N, instance.parameters.PM);
    b1 = gJecog:getStream(0);
    b2 = gJecog:getStream(1);
    first = b2:first() + 1;
    local name = profile:id() .. "(" .. instance.bid:instrument() .. "(" .. instance.parameters.Period  .. "," .. instance.parameters.FIR_N .. "," .. instance.parameters.S_N .. "," .. instance.parameters.PM .. ")";
    instance:name(name);
end

function ExtUpdate(id, source, period)
    if id == 1 and period >= first then
        gJecog:update(core.UpdateLast);
        if core.crossesOver(b1, b2, period) then
            ExtSignal(gSource, period, "CG over SIG", SoundFile);
        elseif core.crossesOver(b2, b1, period) then
            ExtSignal(gSource, period, "CG under SIG", SoundFile);
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
