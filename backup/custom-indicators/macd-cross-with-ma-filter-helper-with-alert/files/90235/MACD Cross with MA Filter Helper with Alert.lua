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

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59718

function Init()
    indicator:name("MACD Cross with MA Filter Helper with Alert");
    indicator:description("MACD Cross with MA Filter Helper with Alert");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Mode");
    indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "Live", "", "Live");

    indicator.parameters:addGroup("Calculation");

    indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price", "CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");

    indicator.parameters:addString("Smooth_Method", "Smooth method", "", "MVA");
    indicator.parameters:addStringAlternative("Smooth_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Smooth_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Smooth_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Smooth_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Smooth_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Smooth_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Smooth_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Smooth_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Smooth_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Smooth_Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("Fast_Period", "Fast MA period", "", 12);
    indicator.parameters:addInteger("Slow_Period", "Slow MA period", "", 26);
    indicator.parameters:addString("Signal_Method", "Signal method", "", "MVA");
    indicator.parameters:addStringAlternative("Signal_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Signal_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Signal_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Signal_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Signal_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Signal_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Signal_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Signal_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Signal_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Signal_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Signal_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Signal_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Signal_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Signal_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Signal_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Signal_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Signal_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Signal_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Signal_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Signal_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Signal_Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("Signal_Period", "Signal period", "", 9);

    indicator.parameters:addString("MA_Method", "Filter Signal method", "", "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("MA_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("MA_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("MA_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("MA_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("MA_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MA_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("MA_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("MA_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("MA_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("MA_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("MA_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("MA_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("MA_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("MA_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("MA_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("MA_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("MA_Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("MA_Period", "Signal period", "", 9);

    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Size", "Label Size", "", 20, 1, 100);

    indicator.parameters:addGroup("Alerts Sound");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
    indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);

    indicator.parameters:addGroup("Alerts Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

    Parameters(1, "MACD/Signal ", true)
    Parameters(2, "Price/MA ", false)
    Parameters(3, "MACD/Signal  - Price/MA Consensus", false)
    Parameters(4, "MACD/Zero ", false)
    Parameters(5, "Histogram/Zero ", false)
end

function Parameters(id, Label, flag)
    indicator.parameters:addGroup(Label .. " Alert");

    indicator.parameters:addBoolean("ON" .. id, "Show " .. Label .. " Alert", "", flag);

    indicator.parameters:addFile("Up" .. id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up" .. id, core.FLAG_SOUND);

    indicator.parameters:addFile("Down" .. id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down" .. id, core.FLAG_SOUND);

    indicator.parameters:addString("Label" .. id, "Label", "", Label);
end

local Number = 5;

local first;
local source = nil;
local Smooth_Method;
local Fast_Period;
local Slow_Period;
local Signal_Method;
local Signal_Period;
local Fast_MA, Slow_MA;
local Pbuff = nil;
local Mbuff = nil;
local pipSize;
local Signal_MA;
local Hist = nil;
local Show;
local MA_Method, MA_Period;
local MA, ma;

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

local Alert;
local Indicator;
local PlaySound;

local FIRST = true;
local CuttOffPeriod;

local U = {};
local D = {};
local Price;
local Live;
function Prepare(nameOnly) 
    Live = instance.parameters.Live;

    FIRST = true;
    Price = instance.parameters.Price;
    source = instance.source;
    MA_Method = instance.parameters.MA_Method
    MA_Period = instance.parameters.MA_Period;
    Smooth_Method = instance.parameters.Smooth_Method;
    Show = instance.parameters.Show;
    Fast_Period = instance.parameters.Fast_Period;
    Slow_Period = instance.parameters.Slow_Period;
    Signal_Method = instance.parameters.Signal_Method;
    Signal_Period = instance.parameters.Signal_Period;
	
	

  

    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Smooth_Method .. ", " .. instance.parameters.Fast_Period .. ", " .. instance.parameters.Slow_Period .. ", " .. instance.parameters.Signal_Method .. ", " .. instance.parameters.Signal_Period .. ", " .. instance.parameters.MA_Method .. ", " .. instance.parameters.MA_Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    

    Fast_MA = core.indicators:create("AVERAGES", source[Price], Smooth_Method, Fast_Period, false);
    Slow_MA = core.indicators:create("AVERAGES", source[Price], Smooth_Method, Slow_Period, false);
	
	  first = math.max(Fast_MA.DATA:first(), Slow_MA.DATA:first());

    MA = core.indicators:create("AVERAGES", source[Price], MA_Method, MA_Period, false);
    ma = instance:addInternalStream(0, 0);

    Pbuff = instance:addInternalStream(0, 0)
    Mbuff = instance:addInternalStream(0, 0)

    Hist = instance:addInternalStream(0, 0);

    Signal_MA = core.indicators:create("AVERAGES", Pbuff, Signal_Method, Signal_Period, false);

    pipSize = source:pipSize();

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
            up[i] = instance:createTextOutput("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Up, 0);
            down[i] = instance:createTextOutput("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Down, 0);
        end
    end
end

function Update(period, mode)
    if period < first then
        return;
    end
    Calculation(period, mode);

    local i;
    for i = 1, Number, 1 do
        if ON[i] then
            down[i]:setNoData(period);
            up[i]:setNoData(period);
        end
    end

    Activate(1, period)
    Activate(2, period)
    Activate(3, period)
    Activate(4, period)
    Activate(5, period)
end

function Activate(id, period)
    if period < first + 1 then
        return;
    end
    local Shift = 0;
    if Live ~= "Live" then
        period = period - 1;
        Shift = 1;
    end

    if id == 1 and ON[id] then
        if Pbuff[period - 1 ] <= Mbuff[period - 1] and Pbuff[period] > Mbuff[period] then
            up[id]:set(period, source.low[period], "\217");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                if Show then
                    Pop(Label[id], " Cross Over ", period);
                end
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Cross Over");
            end
        elseif Pbuff[period - 1] >= Mbuff[period - 1] and Pbuff[period] < Mbuff[period] then
            down[id]:set(period, source.high[period], "\218");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                if Show then
                    Pop(Label[id], " Cross Under ", period);
                end
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] .. " Cross Under");
            end
        end
    end

    if id == 2 and ON[id] then
        if source[Price][period - 1] <= ma[period - 1] and source[Price][period] > ma[period] then
            up[id]:set(period, source.low[period], "\217");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                if Show then
                    Pop(Label[id], " Cross Over ", period);
                end
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Cross Over");
            end
        elseif source[Price][period - 1] >= ma[period - 1] and source[Price][period] < ma[period] then
            down[id]:set(period, source.high[period], "\218");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                if Show then
                    Pop(Label[id], " Cross Under ", period);
                end
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] .. " Cross Under");
            end
        end
    end

    if id == 3 and ON[id] then
        if Pbuff[period - 1] <= Mbuff[period - 1] and Pbuff[period] > Mbuff[period] and source[Price][period] > ma[period] then
            up[id]:set(period, source.low[period], "\217");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                if Show then
                    Pop(Label[id], " Cross Over ", period);
                end
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Cross Over");
            end
        elseif Pbuff[period - 1] >= Mbuff[period - 1] and Pbuff[period] < Mbuff[period] and source[Price][period] < ma[period] then
            down[id]:set(period, source.high[period], "\218");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                if Show then
                    Pop(Label[id], " Cross Under ", period);
                end
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] .. " Cross Under");
            end
        end
    end

    if id == 4 and ON[id] then
        if Pbuff[period - 1] <= 0 and Pbuff[period] > 0 then
            up[id]:set(period, source.low[period], "\217");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                if Show then
                    Pop(Label[id], " Cross Over ", period);
                end
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Cross Over");
            end
        elseif Pbuff[period - 1 ] >= 0 and Pbuff[period] < 0 then
            down[id]:set(period, source.high[period], "\218");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                if Show then
                    Pop(Label[id], " Cross Under ", period);
                end
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] .. " Cross Under");
            end
        end
    end

    if id == 5 and ON[id] then
        if Hist[period - 1] <= 0 and Hist[period] > 0 then
            up[id]:set(period, source.low[period], "\217");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                if Show then
                    Pop(Label[id], " Cross Over ", period);
                end
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Cross Over");
            end
        elseif Hist[period - 1] >= 0 and Hist[period] < 0 then
            down[id]:set(period, source.high[period], "\218");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 - Shift and not FIRST then
                if Show then
                    Pop(Label[id], " Cross Under ", period);
                end
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] .. " Cross Under");
            end
        end
    end

    if FIRST then
        FIRST = false;
    end
end

function Pop(label, note,period)
    terminal:alertMessage(source:instrument(), source[source:size() - 1], label .. " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) " .. label .. " : " .. note, source:date(period ));
end

function AsyncOperationFinished (cookie, success, message)
end

function SoundAlert(Sound)
    if not PlaySound then
        return;
    end

    terminal:alertSound(Sound, RecurrentSound);
end

function EmailAlert(Subject)
    if not SendEmail then
        return
    end
    local date = source:date(NOW);
    local DATA = core.dateToTable(date);
    local LABEL = DATA.month .. ", " .. DATA.day .. ", " .. DATA.hour  .. ", " .. DATA.min .. ", " .. DATA.sec;
    terminal:alertEmail(Email, Subject, profile:id() .. "(" .. source:instrument() .. ")" .. Subject .. ", " .. LABEL);
end

function Calculation(period, mode)
    if period < first then
        return;
    end
    Fast_MA:update(mode);
    Slow_MA:update(mode);

    Pbuff[period] = (Fast_MA.DATA[period] - Slow_MA.DATA[period]) / pipSize;
    Signal_MA:update(mode);
    Mbuff[period] = Signal_MA.DATA[period];
    Hist[period] = Pbuff[period] - Mbuff[period];
    if Pbuff[period] > Mbuff[period] then
        Pbuff:setColor(period, instance.parameters.UPclr);
        Mbuff:setColor(period, instance.parameters.UPclr);
    else
        Pbuff:setColor(period, instance.parameters.DNclr);
        Mbuff:setColor(period, instance.parameters.DNclr);
    end

    MA:update(mode);
    if period < MA.DATA:first() then
        return;
    end
    ma[period] = MA.DATA[period];
end
