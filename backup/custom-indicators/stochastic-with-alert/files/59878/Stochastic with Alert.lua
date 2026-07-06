-- Id: 9036
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=35371

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+

-- The indicator corresponds to the Stochastic indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 6 "Momentum and Oscillators" (page 135-137)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Stochastic with Alert");
    indicator:description("Shows the location of the current close relative to the high/low range over a set number of periods.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("K", "Number of periods for %K", "", 5, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "", 3, 2, 1000);
    indicator.parameters:addInteger("D", "Number of periods for %D", "", 3, 2, 1000);

    indicator.parameters:addString("MVAT_K", "The type of smoothing algorithm for %K", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K", "Fast Smoothed", "", "FS");

    indicator.parameters:addString("MVAT_D", "The type of smoothing algorithm for %D", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "EMA", "", "EMA");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrFirst", "K Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthFirst", "K Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleFirst", "K Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleFirst", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addColor("clrSecond", "D Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthSecond", "D Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleSecond", "D Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSecond", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addGroup("Levels");
    -- Overbought/oversold level
    indicator.parameters:addInteger("overbought", "Overbought Level", "", 80, 0, 100);
    indicator.parameters:addInteger("oversold", "Oversold Level", "", 20, 0, 100);
    indicator.parameters:addInteger("level_overboughtsold_width", "OverboughtSold Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "OverboughtSold Line Style", "", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "OverboughtSold Line Color", "", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addGroup("Mode");
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");

    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addBoolean("overlay", "Show Overlay", "", false);    
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
    indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);

    Parameters(1, "K/D  Line")
    Parameters(2, "K / OverBought")
    Parameters(3, "K / OverDold")
end

function Parameters( id, Label)
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

local overlay;
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
local PlaySound;
local Live;
local FIRST = true;
local OnlyOnce;
local U = {};
local D = {};

local OnlyOnceFlag;

--////////
local k;
local d;
local sd;
local averageTypeK = nil;
local averageTypeD = nil;

local source = nil;
local mins = nil;
local maxes = nil;
local mva = nil;
local FastK = nil;
local fastkFirst = nil;
local kFirst = nil;
local dFirst = nil;
local isFS = nil;
local overlayup = {};
local overlaydown = {};
-- Streams block
local K = nil;
local DLine = nil;
local OB, OS;
-- Routine
function Prepare(nameOnly)
    OnlyOnceFlag = true;
    FIRST = true;
    OnlyOnce = instance.parameters.OnlyOnce;
    Show = instance.parameters.Show;
    Live = instance.parameters.Live;
    overlay = instance.parameters.overlay;    

    OB = instance.parameters.overbought;
    OS = instance.parameters.oversold;
    assert(instance.parameters.oversold < instance.parameters.overbought, "OverSold is bigger then OverBought");

    k = instance.parameters.K;
    d = instance.parameters.D;
    sd = instance.parameters.SD;
    source = instance.source;

    FIRST = true;


    averageTypeK = instance.parameters.MVAT_K;
    averageTypeD = instance.parameters.MVAT_D;

    local name = profile:id() .. "(" .. source:name() .. ", " .. k .. ", " .. d .. ", " .. sd .. ", " .. averageTypeK .. ", " .. averageTypeD .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    mins = instance:addInternalStream(source:first() + k, 0);
    maxes = instance:addInternalStream(source:first() + k, 0);
    FastK = instance:addInternalStream(mins:first(), 0);

    fastkFirst = FastK:first();
    if averageTypeK ~= "FS" then
    assert(core.indicators:findIndicator(averageTypeK) ~= nil, averageTypeK .. " indicator must be installed");
        mva = core.indicators:create(averageTypeK, FastK, sd);
        K = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.clrFirst, mva.DATA:first());
        isFS = false;
    else
        K = instance:addStream("K", core.Line, name .. ".K", "K", instance.parameters.clrFirst, FastK:first() + sd);
        isFS = true;
    end
    K:setWidth(instance.parameters.widthFirst);
    K:setStyle(instance.parameters.styleFirst);
    K:setPrecision(2);

    kFirst = K:first();

    assert(core.indicators:findIndicator(averageTypeD) ~= nil, averageTypeD .. " indicator must be installed");
    signalLine = core.indicators:create(averageTypeD, K, d);
    DLine = instance:addStream("D", core.Line, name .. ".D", "D", instance.parameters.clrSecond, signalLine.DATA:first());
    DLine:setWidth(instance.parameters.widthSecond);
    DLine:setStyle(instance.parameters.styleSecond);
    DLine:setPrecision(2);
    dFirst = DLine:first();

    DLine:addLevel(0);
    DLine:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    DLine:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    DLine:addLevel(100);

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
            up[i] = instance:createTextOutput("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Up, 0);
            down[i] = instance:createTextOutput("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Down, 0);
            if overlay then
                overlayup[i] = instance:createTextOutput("OverlayUp", "OverlayUp", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Up, 0);
                overlaydown[i] = instance:createTextOutput("OverlayDn", "OverlayDn", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Down, 0);    
                core.host:execute("attachTextToChart", "OverlayUp");
                core.host:execute("attachTextToChart", "OverlayDn");
            end
        end
    end
end

function Calculate(period, mode)
   if period >= fastkFirst then
        local minLow, maxHigh = mathex.minmax(source, period - k + 1, period);
        mins[period] = source.close[period] - minLow;
        maxes[period] = maxHigh - minLow;
        if maxes[period] > 0 then
            FastK[period] = mins[period] / maxes[period] * 100;
        else
            FastK[period] = 50;
        end
    end
    if isFS == false then
        mva:update(mode);
        if period >= kFirst then
            K[period] = mva.DATA[period];
        end
    else
        if period >= kFirst then
            local sumMax = mathex.sum(maxes, period - sd + 1, period);
            if sumMax == 0 then
                K[period] = 50;
            else
                local sumMin = mathex.sum(mins, period - sd + 1, period);
                K[period] = sumMin / sumMax * 100;
            end
        end
    end
    signalLine:update(mode);
    if period >= dFirst then
        DLine[period] = signalLine.DATA[period];
    end
end

-- Indicator calculation routine
function Update(period, mode)
    if period <= signalLine.DATA:first() then
        return;
    end

    Calculate(period, mode);

    local i;
    for i = 1, Number, 1 do
        if ON[i] then
            down[i]:setNoData(period);
            up[i]:setNoData(period);
            if overlay then
                overlaydown[i]:setNoData(period); 
                overlayup[i]:setNoData(period);         
            end 
        end
    end

    Activate(1, period)
    Activate(2, period)
    Activate(3, period)
end

function Activate(id, period)
    local Shift = 0;

    if Live ~= "Live" then
        period = period - 1;
        Shift = 1;
    end

    if id == 1 and ON[id] then
        if K[period - 1] <= DLine[period - 1] and K[period] > DLine[period] then
            up[id]:set(period, DLine[period], "\108");
            if overlay then
                overlayup[id]:set(period, source.low[period], "\217");
            end

            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                OnlyOnceFlag = false;
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Cross Over", period);
                if Show then
                    Pop(Label[id], " Cross Over ");
                end
            end
        elseif K[period - 1] >= DLine[period - 1] and K[period] < DLine[period] then
            down[id]:set(period, DLine[period], "\108");
            if overlay then
                overlaydown[id]:set(period, source.high[period], "\218");
            end

            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                OnlyOnceFlag = false;
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id], " Cross Under", period);
                if Show then
                    Pop(Label[id], " Cross Under ");
                end
            end
        end
    elseif id == 2 and ON[id] then
        if K[period - 1] <= OB and K[period] > OB then
            up[id]:set(period, OB, "\108");
            if overlay then 
                overlayup[id]:set(period, source.low[period], "\217");
            end

            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                OnlyOnceFlag = false;
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Cross Over", period);
                if Show then
                    Pop(Label[id], " Cross Over ");
                end
            end
        elseif K[period - 1] >= OB and K[period] < OB then
            down[id]:set(period, OB, "\108");
            if overlay then
                overlaydown[id]:set(period, source.high[period], "\218");
            end

            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                OnlyOnceFlag = false;
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id], " Cross Under", period);
                if Show then
                    Pop(Label[id], " Cross Under ");
                end
            end
        end
    elseif id == 3 and ON[id] then
        if K[period - 1] <= OS and K[period] > OS then
            up[id]:set(period, OS, "\108");
            if overlay then
                overlayup[id]:set(period, source.low[period], "\217");    
            end

            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                OnlyOnceFlag = false;
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id], " Cross Over", period);
                if Show then
                    Pop(Label[id], " Cross Over " );
                end
            end
        elseif K[period - 1] >= OS and K[period] < OS then
            down[id]:set(period, OS, "\108");
            if overlay then
                overlaydown[id]:set(period, source.high[period], "\218");       
            end

            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                OnlyOnceFlag = false;
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
    terminal:alertMessage(source:instrument(), source[NOW], label .. " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) "  ..   label .. " : " .. note, source:date(NOW));
end

function SoundAlert(Sound)
    if not PlaySound then
        return;
    end

    if OnlyOnce and OnlyOnceFlag == false then
        return;
    end

    terminal:alertSound(Sound, RecurrentSound);
end

function EmailAlert( label, Subject)
    if not SendEmail then
        return
    end

    if OnlyOnce and OnlyOnceFlag == false then
        return;
    end


    local date = source:date(source:size() - 1);
    local DATA = core.dateToTable (date);

    local delim = "\013\010";
    local Note = profile:id() .. delim .. " Label : " .. label .. delim .. " Alert : " .. Subject ;
    local Symbol = "Instrument : " .. source:instrument();
    local TF = "Time Frame : " .. source:barSize();
    local Time = " Date : " .. DATA.month .. " / " .. DATA.day .. " Time:  " .. DATA.hour .. " / " .. DATA.min .. " / " .. DATA.sec;

    local text = Note .. delim .. Symbol .. delim .. TF .. delim .. Time;
    terminal:alertEmail(Email, profile:id(), text);
end


--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+
