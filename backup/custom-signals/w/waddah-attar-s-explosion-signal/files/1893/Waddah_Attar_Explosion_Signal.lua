-- Id: 673
-- This is a port of Waddah_Attar_Explosion.mq4 
-- Original indicator Copyright � 2006, Eng. Waddah Attar, waddahattar@hotmail.com 

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    strategy:name("Waddah Attar Explosion Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("");

    strategy.parameters:addInteger("Sen", "Sensitivity", "", 150);
    strategy.parameters:addInteger("DeadZonePip", "Dead Zone in pips", "", 30);
    strategy.parameters:addInteger("ExplosionPower", "Explosion Power", "", 15);
    strategy.parameters:addInteger("TrendPower", "Trend Power", "", 15);
    strategy.parameters:addString("Period", "Time frame", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound file", "", "");

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local WAD, WAD1, WAD2, WAD3;
local gSource;
local ExplosionPower;
local TrendPower;
local first;
local DeadZone;

-- Routine
function Prepare()
    local Sen;
    local DeadZonePip;
    local ShowAlert;

    Sen = instance.parameters.Sen;
    DeadZonePip = instance.parameters.DeadZonePip;
    ExplosionPower = instance.parameters.ExplosionPower;
    TrendPower = instance.parameters.TrendPower;

    ShowAlert = instance.parameters.ShowAlert;
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");

    ExtSetupSignal(profile:id() .. ":", ShowAlert);

    assert(instance.parameters.Period ~= "t1", "Can't be applied on ticks!");
    gSource = ExtSubscribe(2, nil, instance.parameters.Period, true, "bar");
    local ps = gSource:pipSize();
    if ps > 1 then
        ps = math.pow(10, -ps);
    end
    DeadZone = DeadZonePip * ps;
    assert(core.indicators:findIndicator("WADDAH_ATTAR_EXPLOSION") ~= nil, "WADDAH_ATTAR_EXPLOSION" .. " indicator must be installed");
    WAD = core.indicators:create("WADDAH_ATTAR_EXPLOSION", gSource, Sen, DeadZonePip);
    WAD1 = WAD:getStream(0);
    WAD2 = WAD:getStream(1);
    WAD3 = WAD:getStream(2);
    first = WAD1:first() + 2;
end

local PrevSignal = 0;

-- when tick source is updated
function ExtUpdate(id, source, period)
    if id == 2 then
        -- the WAD source is updated
        WAD:update(core.UpdateLast);
        if period > first then
            local trend1, trend2, explosion1, explosion2;
            local pwre, pwrt;

            if WAD1[period] ~= 0 then
                trend1 = WAD1[period];
            elseif WAD2[period] ~= 0 then
                trend1 = -WAD2[period];
            else
                trend1 = 0;
            end

            if WAD1[period - 2] ~= 0 then
                trend2 = WAD1[period - 2];
            elseif WAD2[period - 2] ~= 0 then
                trend2 = -WAD2[period - 2];
            else
                trend2 = 0;
            end

            explosion1 = WAD3[period];
            explosion2 = WAD3[period - 1];

            if trend1 > 0 and trend1 > explosion1 and trend1 > DeadZone and
               explosion1 > DeadZone and explosion1 > explosion2 and trend1 > trend2 and PrevSignal ~= 1 then
                pwrt = 100 * (trend1 - trend2) / trend1;
                pwre = 100 * (explosion1 - explosion2) / explosion1;
                if pwre >= ExplosionPower and pwrt >= TrendPower then
                    ExtSignal(gSource, period, "BUY", SoundFile);
                    PrevSignal = 1;
                end
            end

            if trend1 < 0 and math.abs(trend1) > explosion1 and math.abs(trend1) > DeadZone and
               explosion1 > DeadZone and explosion1 > explosion2 and math.abs(trend1) > math.abs(trend2) and PrevSignal ~= 2 then
                pwrt = 100 * (math.abs(trend1) - math.abs(trend2)) / math.abs(trend1);
                pwre = 100 * (explosion1 - explosion2) / explosion1;
                if pwre >= ExplosionPower and pwrt >= TrendPower then
                    ExtSignal(gSource, period, "SELL", SoundFile);
                    PrevSignal = 2;
                end
            end
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
