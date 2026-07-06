-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=32688


--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
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

-- The indicator corresponds to the Bollinger Bands indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 5 "Trend System" (page 91-94)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Volume Adjusted Moving Average Bollinger Band");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Mode");
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Price", "CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price", "CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");

    indicator.parameters:addInteger("N", "Number of Periods", "", 20, 1, 10000);
    indicator.parameters:addDouble("Dev", "Number of standard deviations", "", 2.0, 0.0001, 1000.0);

    indicator.parameters:addGroup("Band Style");
    indicator.parameters:addColor("clrBBP", "Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthBBB", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleBBB", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleBBB", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addGroup("Average line");
    indicator.parameters:addBoolean("HideAve", "Hide average line", "", false);
    indicator.parameters:addColor("clrBBA", "Line Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthBBA", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleBBA", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleBBA", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addGroup("Highlight Area");
    indicator.parameters:addBoolean("ShowX", "Show Highlight", "", true);
    indicator.parameters:addColor("Top", "Top Area Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Bottom", "Bottom Area Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Transparency", "Highlight Area Transparency", "0 - opaque, 100 - transparent", 80, 0, 100);

    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Size", "Label Size", "", 10, 1, 100);

    indicator.parameters:addGroup("Alerts Sound");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

    indicator.parameters:addGroup("Alerts Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);

    Parameters(1, "Top Line")
    Parameters(2, "Central Line")
    Parameters(3, "Bottom Line")
end

function Parameters(id, Label)
    indicator.parameters:addGroup(Label .. " Alert");

    indicator.parameters:addBoolean("ON" .. id, "Show " .. Label .. " Alert", "", true);

    indicator.parameters:addFile("Up" .. id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up" .. id, core.FLAG_SOUND);

    indicator.parameters:addFile("Down" .. id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down" .. id, core.FLAG_SOUND);

    indicator.parameters:addString("Label" .. id, "Label", "", Label);
end

local Number = 3;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local Dev;

local first;
local source = nil;

local Price;

-- Streams block
local TL = nil;
local BL = nil;
local AL = nil;
local ALT, ALB;
local PriceTimesVolume;
local ShowX;

local Up = {};
local Down = {};
local Label = {};
local ON = {};
local Line;
local up = {};
local down = {};
local Size;
local Email;
local SendEmail;
local RecurrentSound, SoundFile;
local Show;
local Alert;
local Indicator;
local PlaySound;
local Live;
local FIRST = true;

local U = {};
local D = {};

-- Routine
function Prepare(nameOnly) 
    Price = instance.parameters.Price;
    ShowX = instance.parameters.ShowX;
    N = instance.parameters.N;
    Dev = instance.parameters.Dev;
    source = instance.source;

    FIRST = true;
    Show = instance.parameters.Show;
    Live = instance.parameters.Live;

    first = source:first(period) + N;
  

    local name = profile:id() .. "(" .. source:name() .. ", " .. Price .. ", " .. N .. ", " .. Dev .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	  assert(source:supportsVolume(), "The source must have volume");

    PriceTimesVolume = instance:addInternalStream(0, 0);

    ALT = instance:addInternalStream(0, 0);
    ALB = instance:addInternalStream(0, 0);
	
	
    TL = instance:addStream("TL", core.Line, name .. ".TL", "TL", instance.parameters.clrBBP, first)
    TL:setWidth(instance.parameters.widthBBB);
    TL:setStyle(instance.parameters.styleBBB);
    BL = instance:addStream("BL", core.Line, name .. ".BL", "BL", instance.parameters.clrBBP, first)
    BL:setWidth(instance.parameters.widthBBB);
    BL:setStyle(instance.parameters.styleBBB);
    if not instance.parameters.HideAve then
        AL = instance:addStream("AL", core.Line, name .. ".AL", "AL", instance.parameters.clrBBA, first);
        AL:setWidth(instance.parameters.widthBBA);
        AL:setStyle(instance.parameters.styleBBA);
    else
        AL = instance:addInternalStream(0, 0);
    end
    if ShowX then
        instance:createChannelGroup("MU", "U", TL, ALT, instance.parameters.Top, 100 - instance.parameters.Transparency);
        instance:createChannelGroup("MD", "D", BL, ALB, instance.parameters.Bottom, 100 - instance.parameters.Transparency);
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

        if ON[i] then
            up[i] = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Up, 0);
            down[i] = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Down, 0);
        end
    end
end

-- Indicator calculation routine
function Update(period, mode)
    Calculation(period, mode);

    local i;
    for i = 1, Number, 1 do
        if ON[i] then
            down[i]:setNoData (period);
            up[i]:setNoData (period);
        end
    end
    if period < first then
        return;
    end
    Activate(1, period);
    Activate(2, period);
    Activate(3, period);
end

function Activate(id, period)
    local Shift = 0;

    if Live ~= "Live" then
        period = period - 1;
        Shift = 1;
    end

    if id == 1 and ON[id] then
        if source.close[period] > TL[period] and source.close[period - 1] <= TL[period - 1] then
            up[id]:set(period, TL[period], "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Cross Over", period);

                if Show then
                    Pop(Label[id], " Cross Over ");
                end
            end
        elseif source.close[period] < TL[period] and source.close[period - 1] >= TL[period - 1] then
            down[id]:set(period, TL[period], "\108");
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

    if id == 3 and ON[id] then
        if source.close[period] > BL[period] and source.close[period - 1] <= BL[period - 1] then
            up[id]:set(period, BL[period], "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Cross Over", period);
                if Show then
                    Pop(Label[id], " Cross Over " );
                end

            end
        elseif source.close[period] < BL[period] and source.close[period - 1] >= BL[period - 1] then
            down[id]:set(period, BL[period], "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id], " Cross Under", period);
                if Show then
                    Pop(Label[id], " Cross Under ");
                end
            end
        end
    end

    if id == 2 and ON[id] then
        if source.close[period] > AL[period] and source.close[period - 1] <= AL[period - 1] then
            up[id]:set(period, AL[period], "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Cross Over", period);
                if Show then
                    Pop(Label[id], " Cross Over ");
                end
            end
        elseif source.close[period] < AL[period] and source.close[period - 1] >= AL[period - 1] then
            down[id]:set(period, AL[period], "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id], " Cross Under", period);
                if Show then
                    Pop(Label[id], " Cross Under ");
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
    terminal:alertMessage(source:instrument(), source[source:size() - 1], label .. " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) " .. label .. " : " .. note, source:date(NOW));
end

function SoundAlert(Sound)
    if not PlaySound then
        return;
    end

    terminal:alertSound(Sound, RecurrentSound);
end

function EmailAlert(label, Subject, period)
    if not SendEmail then
        return
    end
    local date = source:date(period);
    local DATA = core.dateToTable(date);
    local delim = "\013\010";
    local Note = profile:id() .. delim .. " Label : " .. label  .. delim .. " Alert : " .. Subject;
    local Symbol = "Instrument : " .. source:instrument();
    local TF = "Time Frame : " .. source:barSize();
    local Time = " Date : " .. DATA.month .. " / " .. DATA.day .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec;
    local text = Note .. delim ..  Symbol .. delim .. TF .. delim .. Time;

    terminal:alertEmail(Email, profile:id(), text);
end

function Calculation(period, mode)
    PriceTimesVolume[period] = source[Price][period] * source.volume[period];

    if period < first then
        return;
    end

    AL[period] =  mathex.sum(PriceTimesVolume, period - N + 1, period) / mathex.sum(source.volume, period - N + 1, period);
    ALT[period] = AL[period];
    ALB[period] = AL[period];

    local dAmount = 0;
    local i;
    for i = 0, N, 1 do
        dAmount = dAmount + math.pow((source[Price][period - i] - AL[period]), 2);
    end

    local d = math.sqrt(dAmount / N);
    local Dd = Dev * d;
    TL[period] = AL[period] + Dd;
    BL[period] = AL[period] - Dd;
end
