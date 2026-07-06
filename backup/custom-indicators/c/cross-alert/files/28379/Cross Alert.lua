-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=14980
-- Id: 6120

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- This indicator gives you the ability to define up to two lines.
-- If the selected indicator cross that line, Audio and On Screen Alert is given.

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=14980

function Init()
    indicator:name("Cross Alert");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("INDICATOR", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR", core.FLAG_INDICATOR);

    indicator.parameters:addInteger("Number", "Data Stream Number", "", 1, 1, 100);

    indicator.parameters:addBoolean("First", "First Level On/Off", "", false);
    indicator.parameters:addDouble("One", "First Level Value", "", 0);

    indicator.parameters:addBoolean("Second", "Second Level On/Off", "", false);
    indicator.parameters:addDouble("Two", "Second Level Value", "", 0);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0));

    indicator.parameters:addInteger("Size", "Font Size", "", 10, 1, 100);

    indicator.parameters:addGroup("Alerts");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    indicator.parameters:addFile("SoundFile", "Sound File", "", "");
    indicator.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

    indicator.parameters:addGroup("Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local Number;
local INDICATOR;
local final = {};
local FIRST = 1;
local source;
local Indicator = nil;
local Count;
local TEMP;
local INDEX = {};
local Up, Down, Neutral;
local One, Two;
local First, Second;
local up1, down1, up2, down2;
local Size;

local Email;
local SendEmail;

local UO, UT, DO, DT;
local PlaySound, RecurrentSound, SoundFile;

function SoundAlert()
    terminal:alertSound(SoundFile, RecurrentSound);
end

function EmailAlert(Subject)
    terminal:alertEmail(Email, Subject, profile:id() .. "(" .. source:instrument() .. ")" .. source.close[source:size() - 1] .. ", " .. Subject .. ", " .. source:date(NOW));
end

function Prepare(nameOnly)
    SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");

    Size = instance.parameters.Size;
    One = instance.parameters.One;
    Two = instance.parameters.Two;
    First = instance.parameters.First;
    Second = instance.parameters.Second;
    INDICATOR = instance.parameters.INDICATOR;

    PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be chosen");
    RecurrentSound = instance.parameters.RecurrentSound;

    source = instance.source;
    Number = instance.parameters.Number;
    Number = Number - 1;

    Up = instance.parameters.Up;
    Down = instance.parameters.Down;
    Neutral = instance.parameters.Neutral;

    local name = profile:id();
    local i;
    UO = nil;
    UT = nil;
    DO = nil;
    DT = nil;

    name = name .. ", ("  ..  INDICATOR .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    local tmpprofile = core.indicators:findIndicator(instance.parameters:getString("INDICATOR"));
    local tmpparams = instance.parameters:getCustomParameters("INDICATOR");
    if tmpprofile:requiredSource() == core.Tick then
        TEMP = tmpprofile:createInstance(source.close, tmpparams);
    else
        TEMP = tmpprofile:createInstance(source, tmpparams);
    end

    Count = TEMP:getStreamCount();
    if Number >= Count then
        Number = Count;
        assert(false, "Incorrect index of stream. The indicator has only " .. Count .. " stream(s).");
    end
    i = Number;
    INDEX[i] = TEMP:getStream(i);
    FIRST = math.max(FIRST, INDEX[i]:first());

    if First then
        up1 = instance:createTextOutput("Up1", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Up, 0);
        down1 = instance:createTextOutput("Dn1", "Dn", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Down, 0);
    end
    if Second then
        up2 = instance:createTextOutput("Up2", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Up, 0);
        down2 = instance:createTextOutput("Dn2", "Dn", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Down, 0);
    end
end

function Update(period, mode)
    if period < FIRST + 1 then
        return;
    end

    TEMP:update(mode);

    if First then
        if core.crossesOver(INDEX[Number], One, period) then
            up1:set(period, source.low[period], "\108");
            down1:setNoData(period);
            DO = nil;

            if period == source:size() - 1 and UO ~= source:date(period) then
                UO = source:date(period);
                SoundAlert();
                EmailAlert("Cross Over");
            end
        elseif core.crossesUnder(INDEX[Number], One, period) then
            down1:set(period, source.high[period], "\108");
            up1:setNoData(period);
            UO = nil;

            if period == source:size() - 1 and DO ~= source:date(period) then
                DO = source:date(period);
                SoundAlert();
                EmailAlert("Cross Under");
            end
        end
    end

    if Second then
        if core.crossesOver(INDEX[Number], Two, period) then
            up2:set(period, source.low[period], "\108");
            down2:setNoData(period);
            DT = nil;
            if period == source:size() - 1 and UT ~= source:date(period) then
                UT = source:date(period);
                SoundAlert();
                EmailAlert("Cross Over");
            end
        elseif core.crossesUnder(INDEX[Number], Two, period) then
            down2:set(period, source.high[period], "\108");
            up2:setNoData(period);
            UT = nil;
            if period == source:size() - 1 and DT ~= source:date(period) then
                DT = source:date(period);
                SoundAlert();
                EmailAlert("Cross Under");
            end
        end
    end
end
