-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&p=147765#p147765

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 
 

function AddAverages(id, name, default)
    indicator.parameters:addString(id, name, "", default);
    indicator.parameters:addStringAlternative(id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative(id, "EMA", "", "EMA");
    indicator.parameters:addStringAlternative(id, "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative(id, "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative(id, "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative(id, "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative(id, "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative(id, "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative(id, "HMA", "", "HMA");
    indicator.parameters:addStringAlternative(id, "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative(id, "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative(id, "T3", "", "T3");
    indicator.parameters:addStringAlternative(id, "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative(id, "Median", "", "Median");
    indicator.parameters:addStringAlternative(id, "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative(id, "REMA", "", "REMA");
    indicator.parameters:addStringAlternative(id, "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative(id, "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative(id, "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative(id, "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative(id, "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative(id, "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative(id, "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative(id, "HPF", "", "HPF");
    indicator.parameters:addStringAlternative(id, "VAMA", "", "VAMA");
    indicator.parameters:addStringAlternative(id, "Regression", "", "REGRESSION");
end
function CreateAverages(period, method, source)
    if method == "MVA" or method == "EMA" or method == "ARSI"
       or method == "KAMA" or method == "LWMA" or method == "SMMA"
        or method == "VIDYA" or method == "REGRESSION"
    then
        --assert(core.indicators:findIndicator(method) ~= nil, method .. " indicator must be installed");
        return core.indicators:create(method, source, period);
    end
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES indicator");
    return core.indicators:create("AVERAGES", source, method, period);
end

function Init()
    indicator:name("2 MA Alert");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");

    local i;
    indicator.parameters:addInteger("sm_period", "First MA Period", "", 14);
    AddAverages("sm_method", "First MA Method", "MVA");
    indicator.parameters:addInteger("lm_period", "Second MA Period", "", 21);
    AddAverages("lm_method", "Second MA Method", "MVA");
    
    indicator.parameters:addGroup("Indicator Style");
    indicator.parameters:addColor("SHORT_color", "Short MA Line color", "(", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Short_width", "Short MA Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Short_style", "Short MA Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Short_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("LONG_color", "Long MA Line color", "(", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Long_width", "Long MA Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Long_style", "Long MA Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Long_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Down", "Up Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("Up", "Down Trend Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Size", "Label Size", "", 10, 1, 100);

    indicator.parameters:addGroup("Alerts Sound");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

    indicator.parameters:addGroup("Alerts Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

    Parameters(1, "Short MA / Long MA")
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

local Number = 1;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Up = {};
local Down = {};
local Label = {};
local ON = {};
local first;
local source = nil;
local Line;
local up = {};
local down = {};
local Size;
local Email;
local SendEmail;
local RecurrentSound, SoundFile;

local Indicator;
local PlaySound;

local U = {};
local D = {};
local SN, LN;
local SM, LM;

-- Streams block
local Short = nil;
local Long = nil;
local SHORT;
local LONG;

-- Routine
function Prepare(nameOnly)
    source = instance.source;

    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    SM = instance.parameters.SM;
    LM = instance.parameters.LM;

    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.sm_period .. ", " .. instance.parameters.sm_method 
        .. ", " .. instance.parameters.lm_period .. ", " .. instance.parameters.lm_method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    Short = CreateAverages(instance.parameters.sm_period, instance.parameters.sm_method, source);
    Long = CreateAverages(instance.parameters.lm_period, instance.parameters.lm_method, source);

    SHORT = instance:addStream("SHORT", core.Line, name .. ".SHORT", "SHORT", instance.parameters.SHORT_color, Short.DATA:first());
    SHORT:setWidth(instance.parameters.Short_width);
    SHORT:setStyle(instance.parameters.Short_style);

    LONG = instance:addStream("LONG", core.Line, name .. ".LONG", "LONG", instance.parameters.LONG_color, Long.DATA:first());
    LONG:setWidth(instance.parameters.Long_width);
    LONG:setStyle(instance.parameters.Long_style);

    first = math.max(Long.DATA:first(), Short.DATA:first());

    Initialization();
end

function  Initialization ()
    Size = instance.parameters.Size;
    SendEmail = instance.parameters.SendEmail;

    local i;
    for i = 1, Number, 1 do
        Label[i] = instance.parameters:getString("Label" .. i);
        ON[i]    = instance.parameters:getBoolean("ON" .. i);
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
            Up[i]   = instance.parameters:getString("Up" .. i);
            Down[i] = instance.parameters:getString("Down" .. i);
        end
    else
        for i = 1, Number, 1 do
            Up[i]   = nil;
            Down[i] = nil;
        end
    end

    for i = 1, Number, 1 do
        assert(not(PlaySound) or (PlaySound and Up[i]   ~= "") or (PlaySound and Up[i]   ~= ""), "Sound file must be chosen");
        assert(not(PlaySound) or (PlaySound and Down[i] ~= "") or (PlaySound and Down[i] ~= ""), "Sound file must be chosen");
    end

    RecurrentSound = instance.parameters.RecurrentSound;

    for i = 1, Number, 1 do
        U[i] = nil;
        D[i] = nil;
        if ON[i] then
            up[i]   = instance:createTextOutput("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Up, 0);
            down[i] = instance:createTextOutput("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Down, 0);
        end
    end
end

function Calculate(period, mode)
    Short:update(mode);
    Long:update(mode);

    if period < first then
        return;
    end
    SHORT[period] = Short.DATA[period];
    LONG[period]  = Long.DATA[period];
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first then
        return;
    end

    Calculate(period, mode);

    local i;
    for i = 1, Number, 1 do
        if ON[i] then
            down[i]:setNoData(period);
            up[i]:setNoData(period);
        end
    end

    Activate(1, period);
end

function Activate(id, period)
    if id == 1 and ON[id] then
        if SHORT[period - 1] < LONG[period - 1] and SHORT[period] > LONG[period] then
            up[id]:set(period, LONG[period], "\108");
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Cross Over");
            end
        elseif SHORT[period - 1] > LONG[period - 1] and SHORT[period] < LONG[period] then
            down[id]:set(period, LONG[period], "\108");
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
    terminal:alertSound(Sound, RecurrentSound);
end

function EmailAlert(Subject)
    if not SendEmail then
        return
    end

    local date = source:date(NOW);
    local DATA = core.dateToTable(date);
    local LABEL = DATA.month .. ", " .. DATA.day .. ", " .. DATA.hour .. ", " .. DATA.min .. ", " .. DATA.sec;
    terminal:alertEmail(Email, Subject, profile:id() .. "(" .. source:instrument() .. ")" .. source[NOW] .. ", " .. Subject .. ", " .. LABEL);
end
-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&p=147765#p147765

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 