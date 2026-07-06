
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2511

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

 

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("ZeroLag With Alert");
    indicator:description("Zero Lag indicator from Futures & Commodities, Oct issue");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Lenth", "Inernal EMA length", 20);
    indicator.parameters:addInteger("GainLimit", "GainLimit", "Limit of gain term", 50);

    indicator.parameters:addGroup("Style Parameters");
    indicator.parameters:addInteger("width", " Grid Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", " Grid Style", " ", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("ZL_color", "Color of ZeroLag", "Color of ZeroLag", core.rgb(0, 255, 0));

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

    Parameters(1, "Price Slope change")
    Parameters(2, "Price / MA Cross")
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local N;
local gainLimit;

local first;
local source = nil;

-- Streams block
local EMAI = nil;
local ZL = nil;

local alpha;

function Parameters(id, Label)
    indicator.parameters:addGroup(Label .. " Alert");

    indicator.parameters:addBoolean("ON" .. id, "Show " .. Label .. " Alert", "", false);

    indicator.parameters:addFile("Up" .. id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up" .. id, core.FLAG_SOUND);

    indicator.parameters:addFile("Down" .. id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down" .. id, core.FLAG_SOUND);

    indicator.parameters:addString("Label" .. id, "Label", "", Label);
end

local Number = 2;

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
local PlaySound;
local FIRST = true;
local U = {};
local D = {};

-- Routine
function Prepare(nameOnly) 
    N = instance.parameters.N;

    FIRST = true;
    gainLimit = instance.parameters.GainLimit / 10;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. instance.parameters.GainLimit .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    EMAI = core.indicators:create("EMA", source, N);

    first = EMAI.DATA:first() + 1;

    alpha =  2.0 / (N + 1.0)

    ZL = instance:addStream("ZL", core.Line, name .. ".ZL", "ZL", instance.parameters.ZL_color, first);
    ZL:setWidth(instance.parameters.width);
    ZL:setStyle(instance.parameters.style);

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

function Calculate(period, mode)
    EMAI:update(mode);

    if period >= first and source:hasData(period) then
        local EMA = EMAI.DATA[period];

        local err = source[period] - ZL[period - 1]
        local gain = 0
        if math.abs(alpha * err) > 1e-9 then
          local diff = ZL[period - 1] - EMA
          gain = (err + alpha * diff) / (alpha * err)
        end
        -- Force gain to [-gainLimit; gainLimit] interval
        gain = math.max(math.min(gain, gainLimit), -gainLimit)

        -- Round gain to nearest value quanted by 0.1 interval
        if gain > 0 then
            gain = math.floor(gain * 10 + 0.5) / 10;
        else
            gain = math.ceil(gain * 10 - 0.5) / 10;
        end

        ZL[period] = alpha * (EMA + gain * err) + (1 - alpha) *  ZL[period - 1];
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    Calculate(period, mode);
    if period < first then
        return;
    end
    local i;
    for i = 1, Number, 1 do
        if ON[i] and i == 1 then
            down[i]:setNoData(period - 1);
            up[i]:setNoData(period - 1);
        elseif ON[i] and i == 2 then
            down[i]:setNoData(period);
            up[i]:setNoData(period);
        end
    end

    Activate(1, period);
    Activate(2, period);
end

function Activate(id, period)
    if id == 1 and ON[id] then
        if ZL[period - 2] < ZL[period - 1] and ZL[period - 3] >= ZL[period - 2] then
            up[id]:set(period - 2, ZL[period - 2], "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Slope Up");
            end
        elseif ZL[period - 2] > ZL[period - 1] and ZL[period - 3] <= ZL[period - 2] then
            down[id]:set(period-2, ZL[period-2], "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] .. " Slope Down");
            end
        end
    elseif id == 2 and ON[id] then
        if ZL[period] < source[period] and ZL[period - 1] >= source[period - 1] then
            up[id]:set(period, ZL[period], "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Cross Over");
            end
        elseif ZL[period] > source[period] and ZL[period - 1] <= source[period - 1] then
            down[id]:set(period, ZL[period], "\108");
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] .. " Cross Under");
            end
        end
    end
end

function SoundAlert(Sound)
    if not PlaySound then
        return;
    end

    if FIRST then
        FIRST = false;
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
    local LABEL = DATA.month .. ", " .. DATA.day .. ", " .. DATA.hour .. ", " .. DATA.min .. ", " .. DATA.sec;
    terminal:alertEmail(Email, Subject, profile:id() .. "(" .. source:instrument() .. ")" .. Subject .. ", " .. LABEL);
end
