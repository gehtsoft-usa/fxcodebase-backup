-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6008

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Triple Bollinger Bands");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Mode");
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");

    indicator:setTag("group", "Bollinger");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "", 20, 1, 10000);
    indicator.parameters:addDouble("D1", "Deviation for inner band", "", 1.0, 0.00001, 10000);
    indicator.parameters:addDouble("D2", "Deviation for mid band", "", 2.0, 0.00001, 10000);
    indicator.parameters:addDouble("D3", "Deviation for outer band", "", 3.0, 0.00001, 10000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("CS", "Midline Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("CS", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("CW", "Midline Width", "", 1, 1, 5);
    indicator.parameters:addColor("CC", "Midline Color", "", core.rgb(255, 0, 255));

    indicator.parameters:addInteger("IS", "Inner Band Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("IS", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("IW", "Inner Band Width", "", 1, 1, 5);
    indicator.parameters:addColor("IC", "Inner Band Color", "", core.rgb(127, 0, 0));

    indicator.parameters:addInteger("MS", "Mid Band Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("MS", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("MW", "Mid Band Width", "", 1, 1, 5);
    indicator.parameters:addColor("MC", "Mid Band Color", "", core.rgb(255, 128, 64));

    indicator.parameters:addInteger("OS", "Outer Band Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("OS", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("OW", "Outer Band Width", "", 1, 1, 5);
    indicator.parameters:addColor("OC", "Outer Band Color", "", core.rgb(255, 128, 64));

    indicator.parameters:addBoolean("HF", "Mid Area Between Bands", "", true);
    indicator.parameters:addColor("HC", "Mid Area Color", "", core.rgb(255, 255, 0));

    indicator.parameters:addColor("HC1", "Other Area Color", "", core.rgb(255, 255, 0));

    indicator.parameters:addInteger("HT", "Highlight Area Trasnsparency", "0 - opaque, 100 - transparent", 80, 0, 100);


    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Size", "Label Size", "", 10, 1, 100);

    indicator.parameters:addGroup("Alerts Sound");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

    indicator.parameters:addGroup("Alerts Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);

    Parameters(1, "Cental Line ")
    Parameters(2, "1. Band ")
    Parameters(3, "2. Band ")
    Parameters(4, "3. Band ")
end

function Parameters(id, Label)
    indicator.parameters:addGroup(Label .. " Alert");

    indicator.parameters:addBoolean("ON" .. id, "Show " .. Label .. " Alert", "", false);

    indicator.parameters:addFile("Up" .. id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up" .. id, core.FLAG_SOUND);

    indicator.parameters:addFile("Down" .. id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down" .. id, core.FLAG_SOUND);

    indicator.parameters:addString("Label" .. id, "Label", "", Label);
end

local Number = 4;

local N, D1, D2;
local first;
local source;
local M, OU, OD, IU, ID, OU1, OD1, IU1, ID1;
local HF;
local MU1, MD1;
local OU2, OD2;
local MU, MD;

--******************
local Up = {};
local Down = {};
local Label = {};
local ON = {};
local up = {};
local down = {};
local Size;
local Email;
local SendEmail;
local RecurrentSound, SoundFile;
local Show;
local Alert;
local PlaySound;
local Live;
local FIRST = true;
local U = {};
local D = {};
--*********************

function Prepare(onlyName)
    FIRST = true;
    Show = instance.parameters.Show;
    Live = instance.parameters.Live;

    local name = profile:id() .. "(" .. instance.source:name() .. ", " .. instance.parameters.N .. ", " ..  instance.parameters.D1 .. ", "  .. instance.parameters.D2 .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end
    source = instance.source;
    N = instance.parameters.N;
    D1 = instance.parameters.D1;
    D2 = instance.parameters.D2;
    D3 = instance.parameters.D3;
    first = source:first() + N - 1;

    M = instance:addStream("Mid", core.Line, name .. ".Mid", "Mid", instance.parameters.CC, first);
    M:setStyle(instance.parameters.CS);
    M:setWidth(instance.parameters.CW);
    IU = instance:addStream("InUp", core.Line, name .. ".InUp", "InUp", instance.parameters.IC, first);
    IU:setStyle(instance.parameters.IS);
    IU:setWidth(instance.parameters.IW);
    ID = instance:addStream("InDn", core.Line, name .. ".InDn", "InDn", instance.parameters.IC, first);
    ID:setStyle(instance.parameters.IS);
    ID:setWidth(instance.parameters.IW);
    OU = instance:addStream("OutUp", core.Line, name .. ".OutUp", "OutUp", instance.parameters.OC, first);
    OU:setStyle(instance.parameters.OS);
    OU:setWidth(instance.parameters.OW);
    OD = instance:addStream("OutDn", core.Line, name .. ".OutDn", "OutDn", instance.parameters.OC, first);
    OD:setStyle(instance.parameters.OS);
    OD:setWidth(instance.parameters.OW);

    MU = instance:addStream("MidUp", core.Line, name .. ".MidUp", "MidUp", instance.parameters.MC, first);
    MU:setStyle(instance.parameters.MS);
    MU:setWidth(instance.parameters.MW);
    MD = instance:addStream("MidDn", core.Line, name .. ".MidDn", "MidDn", instance.parameters.MC, first);
    MD:setStyle(instance.parameters.MS);
    MD:setWidth(instance.parameters.MW);

    HF = instance.parameters.HF;

    if HF then
        IU1 = instance:addInternalStream(first, 0);
        ID1 = instance:addInternalStream(first, 0);
        MU1 = instance:addInternalStream(first, 0);
        MD1 = instance:addInternalStream(first, 0);
        OU1 = instance:addInternalStream(first, 0);
        OD1 = instance:addInternalStream(first, 0);
        OU2 = instance:addInternalStream(first, 0);
        OD2 = instance:addInternalStream(first, 0);
        instance:createChannelGroup("MU", "U", MU1, IU1, instance.parameters.HC, 100 - instance.parameters.HT);
        instance:createChannelGroup("MD", "D", ID1, MD1, instance.parameters.HC, 100 - instance.parameters.HT);

        instance:createChannelGroup("OU", "U", OU1, OU2, instance.parameters.HC1, 100 - instance.parameters.HT);
        instance:createChannelGroup("OD", "D",  OD1,  OD2, instance.parameters.HC1, 100 - instance.parameters.HT);
    end

    Initialization();
end

function Initialization()
    Size = instance.parameters.Size;
    SendEmail = instance.parameters.SendEmail;

    local i;
    for i = 1, Number, 1 do
        Label[i] = instance.parameters:getString("Label" .. i);
        ON[i] = instance.parameters:getBoolean("ON" .. i);
    end

    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");

    PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        for i = 1, Number, 1 do
            Up[i] = instance.parameters:getString("Up" .. i);
            Down[i] = instance.parameters:getString("Down" .. i);
        end
    else
        for i = 1, Number, 1 do
            Up[i] = nil;
            Down[i] = nil;
        end
    end

    for i = 1, Number, 1 do
        assert(not(PlaySound) or (PlaySound and Up[i] ~= "") or (PlaySound and Up[i] ~= ""), "Sound file must be chosen");
        assert(not(PlaySound) or (PlaySound and Down[i] ~= "") or (PlaySound and Down[i] ~= ""), "Sound file must be chosen");
    end

    RecurrentSound = instance.parameters.RecurrentSound;

    for i = 1, Number, 1 do
        U[i] = nil;
        D[i] = nil;

        if i > 1 then
            U[i + 3] = nil;
            D[i + 3] = nil;
        end

        if ON[i] then
            up[i] = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Up, 0);
            down[i] = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Down, 0);
            if i > 1 then
                up[i+3] = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Up, 0);
                down[i + 3] = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Down, 0);
            end
        end
    end
end

function Calculate(period, mode)
    if period >= first then
        local m = core.avg(source, period - N + 1, period);
        local d = mathex.stdev(source, period - N + 1, period);

        M[period] = m;
        IU[period] = m + d * D1;
        ID[period] = m - d * D1;
        MU[period] = m + d * D2;
        MD[period] = m - d * D2;
        OU[period] = m + d * D3;
        OD[period] = m - d * D3;
        if HF then
            IU1[period] = m + d * D1;
            ID1[period] = m - d * D1;
            MU1[period] = m + d * D2;
            MD1[period] = m - d * D2;

            OU1[period] = m + d * D2;
            OD1[period] = m - d * D2;

            OU2[period] = m + d * D3;
            OD2[period] = m - d * D3;
        end
    end
end

function Update(period, mode)
    Calculate(period, mode);
    local i;
    for i = 1, Number, 1 do
        if ON[i] then
            down[i]:setNoData(period);
            up[i]:setNoData(period);
            if i > 1 then
                down[i + 3]:setNoData(period);
                up[i + 3]:setNoData(period);
            end
        end
    end

    if period < first then
        return;
    end

    Activate(1, period);
    Activate(2, period);
    Activate(3, period);
    Activate(4, period);
end

function Activate(id, period)
    local Shift = 0;

    if Live ~= "Live" then
        period = period - 1;
        Shift = 1;
    end

    if id == 1 and ON[id] then
        if source[period] > M[period] and source[period - 1] <= M[period - 1] then
            up[id]:set(period, M[period], "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Cross Over", period);
                if Show then
                    Pop(Label[id], " Cross Over " );
                end
            end
        elseif source[period] < M[period] and source[period - 1] >= M[period - 1] then
            down[id]:set(period, M[period], "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id], " Cross Under", period);
                if Show then
                    Pop(Label[id], " Cross Under " );
                end
            end
        end
    end

    if id == 2 and ON[id] then
        if source[period] > IU[period] and source[period - 1] <= IU[period - 1] then
            up[id]:set(period, IU[period], "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Top Line Cross Over", period);
                if Show then
                    Pop(Label[id], " Top Line Cross Over" );
                end
            end
        elseif source[period] < IU[period] and source[period - 1] >= IU[period - 1] then
            down[id]:set(period, IU[period], "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id], " Top Line Cross Under", period);
                if Show then
                    Pop(Label[id], " Top Line Cross Under ");
                end
            end
        end
    end

    if id == 3 and ON[id] then
        if source[period] > MU[period] and source[period - 1] <= MU[period - 1] then
            up[id]:set(period, MU[period], "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Top Line Cross Over", period);
                if Show then
                    Pop(Label[id], " Top Line Cross Over ");
                end
            end
        elseif source[period] < MU[period] and source[period - 1] >= MU[period - 1] then
            down[id]:set(period, MU[period], "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id], " Top Line Cross Under", period);
                if Show then
                    Pop(Label[id], " Top Line Cross Under ");
                end
            end
        end
    end

    if id == 4 and ON[id] then
        if source[period] > OU[period] and source[period - 1] <= OU[period - 1] then
            up[id]:set(period, OU[period], "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Top Line Cross Over", period);
                if Show then
                    Pop(Label[id], " Top Line Cross Over " );
                end
            end
        elseif source[period] < OU[period] and source[period - 1] >= OU[period - 1] then
            down[id]:set(period, OU[period], "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id], " Top Line Cross Under", period);
                if Show then
                    Pop(Label[id], " Top Line Cross Under ");
                end
            end
        end
    end
    ---------------------------------

    -----------------------------------
    if id == 2 and ON[id] then
        if source[period] > ID[period] and source[period - 1] <= ID[period - 1] then
            up[id + 3]:set(period, ID[period], "\108");
            D[id + 3] = nil;
            if U[id + 3] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id + 3] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Cross Over", period);
                if Show then
                    Pop(Label[id], " Cross Over ");
                end
            end
        elseif source[period] < ID[period] and source[period - 1] >= ID[period - 1] then
            down[id + 3]:set(period, ID[period], "\108");
            U[id + 3] = nil;
            if D[id + 3] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                D[id + 3] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id], " Cross Under", period);
                if Show then
                    Pop(Label[id], " Cross Under ");
                end
            end
        end
    end

    --2
    if id == 3 and ON[id] then
        if source[period] > MD[period] and source[period - 1] <= MD[period - 1] then
            up[id + 3]:set(period, MD[period], "\108");
            D[id + 3] = nil;
            if U[id + 3] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id + 3] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Bottom Line  Cross Over", period);
                if Show then
                    Pop(Label[id], "  Bottom Line Cross Over ");
                end
            end
        elseif source[period] < MD[period] and source[period - 1] >= MD[period - 1] then
            down[id + 3]:set(period, MD[period], "\108");
            U[id + 3] = nil;
            if D[id + 3] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                D[id + 3] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id], "  Bottom Line Cross Under", period);
                if Show then
                    Pop(Label[id], "  Bottom Line Cross Under ");
                end
            end
        end
    end

    --3
    if id == 4 and ON[id] then
        if source[period] > OD[period] and source[period - 1] <= OD[period - 1] then
            up[id + 3]:set(period, OD[period], "\108");
            D[id + 3] = nil;
            if U[id + 3] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id + 3] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], "  Bottom Line Cross Over", period);
                if Show then
                    Pop(Label[id], "  Bottom Line Cross Over ");
                end
            end
        elseif source[period] < OD[period] and source[period - 1] >= OD[period - 1] then
            down[id + 3]:set(period, OD[period], "\108");
            U[id + 3] = nil;
            if D[id + 3]~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                D[id + 3] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert( Label[id], "  Bottom Line Cross Under", period);
                if Show then
                    Pop(Label[id], "  Bottom Line Cross Under ");
                end
            end
        end
    end
    if FIRST then
        FIRST = false;
    end
end

function AsyncOperationFinished (cookie, success, message)
end

function Pop(label, note)
    terminal:alertMessage(source:instrument(), source[NOW], label .. " ( " .. source:instrument() .. " ) " ..  label .. " : " .. note, source:date(NOW));
end

function SoundAlert(Sound)
    if not PlaySound then
        return;
    end

    terminal:alertSound(Sound, RecurrentSound);
end

function EmailAlert( label, Subject, period)
    if not SendEmail then
        return
    end

    local date = source:date(period);
    local DATA = core.dateToTable(date);

    local delim = "\013\010";
    local Note = profile:id() .. delim .. " Label : " .. label .. delim .. " Alert : " .. Subject;
    local Symbol = "Instrument : " .. source:instrument();
    local Time = " Date : " .. DATA.month .. " / " .. DATA.day .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec;
    local text = Note .. delim .. Symbol .. delim .. Price .. delim .. Time;

    terminal:alertEmail(Email, profile:id(), text);
end
