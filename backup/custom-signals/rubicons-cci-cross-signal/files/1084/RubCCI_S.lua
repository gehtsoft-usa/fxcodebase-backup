-- Id: 350
--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--|                                 Support our efforts by donating  | 
--|                                    Paypal: http://goo.gl/cEP5h5  |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

function Init()
    strategy:name("Rubicon CCI signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Signals when CCI crosses +/-100 and the signal is confirmed by EMA(CCI) cross of the same level");

    strategy.parameters:addGroup("Parameters");

    strategy.parameters:addInteger("CCI", "CCI Parameter", "", 10);
    strategy.parameters:addInteger("EMA", "EMA Parameter", "", 3);
	indicator.parameters:addInteger("OB", "OB Level", "OB Level",100);
	indicator.parameters:addInteger("OS", "OS Level", "OS Level",-100);

    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addString("Period", "Timeframe", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
end
local OB,OS;
local SoundFile;
local RubCCI;
local CCI;
local EMA;
local SHORT, LONG;
local gSource = nil;        -- the source stream

function Prepare()
    local FastN, SlowN;
	
	OB= instance.parameters.OB;
	OS= instance.parameters.OS;

    ShowAlert = instance.parameters.ShowAlert;
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");
    assert(instance.parameters.Period ~= "t1", "Signal cannot be applied on ticks");

    SHORT = "Short";
    LONG = "Long";

    ExtSetupSignal("Rubicon CCI:", ShowAlert);

    gSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");

    assert(core.indicators:findIndicator("RUBCCI") ~= nil, "RUBCCI" .. " indicator must be installed");
    RubCCI = core.indicators:create("RUBCCI", gSource, instance.parameters.CCI, instance.parameters.EMA, OB, OS);
    CCI = RubCCI:getStream(4);
    EMA = RubCCI:getStream(5);

    local name = profile:id() .. "(" .. instance.bid:instrument() .. "(" .. instance.parameters.Period  .. ")" .. instance.parameters.CCI .. "," .. instance.parameters.EMA .. ")";
    instance:name(name);
end

-- when tick source is updated
function ExtUpdate(id, source, period)
    -- update moving average
    RubCCI:update(core.UpdateLast);

    if period >= EMA:first() + 6 and period >= CCI:first() + 6 then
        if core.crossesOver(EMA, -100, period) then
            for i = period, period - 5, -1 do
                if core.crossesOver(CCI, -100, i) then
                    ExtSignal(gSource, period, LONG, SoundFile);
                    break;
                end
            end
        elseif core.crossesUnder(EMA, 100, period) then
            for i = period, period - 5, -1 do
                if core.crossesUnder(CCI, 100, i) then
                    ExtSignal(gSource, period, SHORT, SoundFile);
                    break;
                end
            end
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
