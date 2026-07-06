-- Id: 664
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
function Init()
    strategy:name("Breakout Indicator Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("");

    strategy.parameters:addGroup("Parameter");

    strategy.parameters:addString("PeriodBegin", "The hour and minute when the period begins", "", "00:00");
    strategy.parameters:addString("PeriodEnd", "The hour and minute when the period ends", "", "05:30");
    strategy.parameters:addString("BoxEnd", "The hour and minute when the box ends", "", "23:00");
    strategy.parameters:addString("Type", "The time type", "", "TD");
    strategy.parameters:addStringAlternative("Type", "Local Time", "", "LT");
    strategy.parameters:addStringAlternative("Type", "EST Time", "", "EST");
    strategy.parameters:addStringAlternative("Type", "GMT Time", "", "GMT");
    strategy.parameters:addStringAlternative("Type", "Trading Day time", "", "TD");


    strategy.parameters:addGroup("Signal");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
end

local SoundFile;
local I, P, H, L;
local gSource = nil;        -- the source stream
local gBid = nil;

function Prepare()
    ShowAlert = instance.parameters.ShowAlert;

    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "The sound file must be specified");

    ExtSetupSignal(profile:id() .. ":", ShowAlert);

    gBid = ExtSubscribe(1, nil, "m1", true, "close");
    gSource = ExtSubscribe(2, nil, "m15", true, "bar");

    assert(core.indicators:findIndicator("BREAKOUT") ~= nil, "BREAKOUT" .. " indicator must be installed");
    I = core.indicators:create("BREAKOUT", gSource, instance.parameters.PeriodBegin, instance.parameters.PeriodEnd, instance.parameters.BoxEnd, instance.parameters.Type, false);

    P = I:getStream(0);
    H = I:getStream(1);
    L = I:getStream(2);

    local name = profile:id() .. "(" .. instance.bid:instrument() .. "," .. instance.parameters.PeriodBegin  .. "," .. instance.parameters.PeriodEnd  .. "," .. instance.parameters.BoxEnd .. "," .. instance.parameters.Type .. ")";
    instance:name(name);
end

local BE_NONE = 0;      -- belongs to period
local BE_PERIOD = 1;    -- belongs to period
local BE_BOX = 2;       -- belongs to box


-- when tick source is updated
function ExtUpdate(id, source, period)
    if id == 2 then
        -- the m15 source is updated
        I:update(core.UpdateLast);
    elseif id == 1 then
        -- the new tick comes
        if P:hasData(NOW) then
            -- if we're currently in the box
            if P[NOW] == BE_BOX then
                if core.crossesOver(gBid, H, period, NOW) then
                    ExtSignal(gBid, period, "Price breaks high", SoundFile);
                elseif core.crossesUnder(gBid, H, period, NOW) then
                    ExtSignal(gBid, period, "Price returns to box", SoundFile);
                elseif core.crossesUnder(gBid, L, period, NOW) then
                    ExtSignal(gBid, period, "Price breaks low", SoundFile);
                elseif core.crossesOver(gBid, L, period, NOW) then
                    ExtSignal(gBid, period, "Price returns to box", SoundFile);
                end
            end
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
