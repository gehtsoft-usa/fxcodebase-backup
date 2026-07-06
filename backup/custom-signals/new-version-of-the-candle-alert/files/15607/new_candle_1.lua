-- Id: 4710
-- More information about this indicator can be found at:
-- http://fxcodebase.com/

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
--
function Init()
    strategy:name("Multi-instrument new candle alert");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Shows an alert when the candle of chosen time frame is finished and when the first tick of a particular candle appears");
    strategy:type(core.Signal);

    strategy.parameters:addString("Label", "Label for the strategy and/or alerts", "", "New Candle Alert");

    -- create 9 different parameters set for timeframe/instrument
    AddParametersGroup(1, true, "EUR/USD", "m1");
    local i;
    for i = 2, 9, 1 do
        AddParametersGroup(i, false, "", "");
    end

    -- create alert parameters
    strategy.parameters:addGroup("Alert");
    strategy.parameters:addBoolean("ShowAlert", "Show Text Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
end

--
-- Add one parameter group
-- default      boolean flag which makes watch parameters enabled and expands the group by default
--
function AddParametersGroup(group, default, instrument, timeframe)
    strategy.parameters:addGroup("Timeframe/Instrument " .. group, default);
    strategy.parameters:addBoolean("E" .. group, "Watch end of the candle", "", default);
    strategy.parameters:addBoolean("S" .. group, "Watch the first tick of the candle", "", default);
    strategy.parameters:addString("I" .. group, "Watch instrument", "Choose the instrument to watch", instrument);
    strategy.parameters:setFlag("I" .. group, core.FLAG_INSTRUMENTS);
    strategy.parameters:addString("TF" .. group, "Timeframe", "", timeframe);
    strategy.parameters:setFlag("TF" .. group, core.FLAG_PERIODS);
end

local name;
local instruments = {};
local alerts = {};
local tradingDayOffset, tradingWeekOffset;
local ShowAlert, PlaySound, Soundfile, RecurrentSound;

function Prepare(onlyName)
    name = profile:id() .. "(" .. instance.parameters.Label .. ")";
    instance:name(name);

    for i = 1, 9, 1 do
        if instance.parameters["E"..i] and instance.parameters["S"..i] and (instance.parameters["TF" .. i] == "t1" or instance.parameters["TF" .. i] == "T") then
            assert(false, "The time frame must not be a tick");
        end
    end

    ShowAlert = instance.parameters.ShowAlert;
    PlaySound = instance.parameters.PlaySound;
    SoundFile = instance.parameters.SoundFile;
    RecurrentSound = instance.parameters.RecurrentSound;

    assert((not PlaySound) or (PlaySound and SoundFile ~= "" and SoundFile ~= nil), "The sound file must be chosen");

    if onlyName then
        return ;
    end


    tradingDayOffset = core.host:execute("getTradingDayOffset");
    tradingWeekOffset = core.host:execute("getTradingWeekOffset");

    local i, alert, instrument, now;

    for i = 1, 9, 1 do
        alert = {};
        alert.watchEnd = instance.parameters["E" .. i];
        alert.watchStart = instance.parameters["S" .. i];

        if alert.watchEnd or alert.watchStart then
            alert.timeFrame = instance.parameters["TF" .. i];
            alert.instrument = instance.parameters["I" .. i];
            if instruments[alert.instrument] == nil then
                if alert.instrument == instance.bid:instrument() then
                    instrument = {};
                    instrument.data = instance.bid;
                    instrument.loaded = true;
                else
                    instrument = {};
                    instrument.data = core.host:execute("getHistory", i, alert.instrument, "t1", 0, 0, true);
                    -- workaround for the 2011-II bug: t1 collections are returned as a bar collections
                    if instrument.data:isBar() then
                        instrument.org_data = instrument.data;
                        instrument.data = instrument.data.close;
                    end
                    instrument.loaded = false;
                end
                instruments[alert.instrument] = instrument;
            end
            now = core.host:execute("getServerTime");
            alert.currentStart, alert.currentEnd = core.getcandle(alert.timeFrame, now, tradingDayOffset, tradingWeekOffset)
            alert.hasTick = true;
        end
        alerts[i] = alert;
    end

    core.host:execute("setTimer", 100, 1);
end

function Update()
end

function AsyncOperationFinished(cookie, success, message)
    if cookie >= 1 and cookie <= 9 and alerts[cookie] ~= nil and instruments[alerts[cookie].instrument] ~= nil then
        instruments[alerts[cookie].instrument].loaded = true;
    elseif cookie == 100 then
        -- check condition every second
        local i, alert, instrument, now, curr, rate, t1, t2;
        now = core.host:execute("getServerTime");
        for i = 1, 9, 1 do
            alert = alerts[i];
            instrument = instruments[alert.instrument];
            if instrument ~= nil and instrument.loaded and instrument.data:size() > 0 then
                curr = instrument.data:date(instrument.data:size() - 1);
                rate = instrument.data[instrument.data:size() - 1];
            else
                curr = nil;
            end
            if alert.watchEnd then
                -- if time frame is ended and there is at least one tick since start of the
                -- current time frame
                if now >= alert.currentEnd and curr ~= nil and curr >= alert.currentStart then
                    if ShowAlert then
                        t1 = core.dateToTable(core.host:execute("convertTime", core.TZ_EST, core.TZ_TS, alert.currentStart));
                        terminal:alertMessage(alert.instrument, rate,
                                              string.format("%s: %s[%s] bar at %02i/%02i %02i:%02i is ended", name, alert.instrument, alert.timeFrame, t1.month, t1.day, t1.hour, t1.min),
                                              now);
                    end
                    if PlaySound then
                        terminal:alertSound(SoundFile, RecurrentSound);
                    end
                    alert.currentStart, alert.currentEnd = core.getcandle (alert.timeFrame, now, tradingDayOffset, tradingWeekOffset);
                    alert.hasTick = false;
                end
            end

            if alert.watchStart and curr ~= nil and curr >= alert.currentStart and alert.hasTick == false then
                if curr >= alert.currentEnd then
                    alert.currentStart, alert.currentEnd = core.getcandle (alert.timeFrame, now, tradingDayOffset, tradingWeekOffset);
                    alert.hasTick = false;
                end
                -- if the current tick in the instrument is after the current start
                -- and we didn't signalled for the start
                alert.hasTick = true;
                if ShowAlert then
                    t1 = core.dateToTable(core.host:execute("convertTime", core.TZ_EST, core.TZ_TS, alert.currentStart));
                    t2 = core.dateToTable(core.host:execute("convertTime", core.TZ_EST, core.TZ_TS, curr));

                    terminal:alertMessage(alert.instrument, rate,
                                          string.format("%s: %s[%s] bar at %02i/%02i %02i:%02i is started by tick at %02i/%02i %02i:%02i:%02i", name, alert.instrument, alert.timeFrame, t1.month, t1.day, t1.hour, t1.min, t2.month, t2.day, t2.hour, t2.min, t2.sec),
                                          now);
                end
                alert.currentStart, alert.currentEnd = core.getcandle (alert.timeFrame, now, tradingDayOffset, tradingWeekOffset);
                alert.hasTick = true;
            end
        end
    end
end



