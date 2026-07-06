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
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3715

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Polynomial regression Range With Alert");
    indicator:description("Polynomial regression Range With Alert");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");

    indicator.parameters:addInteger("Period", "Period", "", 50);
    indicator.parameters:addInteger("Power", "Power", "", 2, 1, 9);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 1);

    indicator.parameters:addString("TF", " Time frame", "", "D1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);

    indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "Open", "", "open");
    indicator.parameters:addStringAlternative("Price", "High", "", "high");
    indicator.parameters:addStringAlternative("Price", "Low", "", "low");
    indicator.parameters:addStringAlternative("Price", "Close", "", "close");
    indicator.parameters:addStringAlternative("Price", "Median", "", "median");
    indicator.parameters:addStringAlternative("Price", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("Price", "Weighted", "", "weighted");
	indicator.parameters:addStringAlternative("Price", "High/Low", "", "High/Low");


    indicator.parameters:addGroup("Style");

    indicator.parameters:addColor("Color", "Line Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Widht", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE);

    indicator.parameters:addGroup("Alerts Sound");
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

    indicator.parameters:addGroup("Alerts Email");
    indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

    Parameters(1, "Top Line");
    Parameters(2, "Bottom Line");
	Parameters(3, "Cental Line")
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

local Number = 3;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Price;
local first;
local source = nil;
 local TF;
 
-- Streams block
local day_offset, week_offset;
local Deviation, Period, Power ;
local Color, Widht, Style;
local Source;
local loading = true;
local IndicatorShift, PriceShift;
local Deviation, Period, Power;
local Indicator;

local U = {};
local D = {};

-- Parameters block
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
local Alert;
local PlaySound;

local FIRST = true;
-- Routine
function Prepare(nameOnly)
    FIRST = true;
    IndicatorShift = instance.parameters.IndicatorShift;   
    PriceShift = instance.parameters.PriceShift;
    TF = instance.parameters.TF;
    Type = instance.parameters.Type;
    Color = instance.parameters.Color;
    Widht = instance.parameters.Widht;
    Style = instance.parameters.Style;
    Price = instance.parameters.Price;
    Deviation = instance.parameters.Deviation;
	Period = instance.parameters.Period;
	Power = instance.parameters.Power;
    source = instance.source;

    local s, e, s1, e1;
    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    s1, e1 = core.getcandle(TF, core.now(), 0, 0);
    assert((e - s) <= (e1 - s1), "The chosen time frame must be equal to or bigger than the chart time frame!");
	assert(core.indicators:findIndicator("POLYNOMIAL_REGRESSION") ~= nil, "Please, download and install POLYNOMIAL_REGRESSION.LUA indicator");    

	 --Polynomial_Regression
    day_offset = core.host:execute("getTradingDayOffset");
    week_offset = core.host:execute("getTradingWeekOffset");

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Power) .. ", " .. tostring(Deviation) .. ", " .. tostring(TF)   .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    local Test = core.indicators:create("POLYNOMIAL_REGRESSION", source.close, Period,Power,Deviation);
    first = Test.DATA:first();

    SourceData = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), math.min(300,first), 2, 1);
    loading = true;
    Indicator = core.indicators:create("POLYNOMIAL_REGRESSION", SourceData.close, Period,Power,Deviation);

    Initialization();
end

function Initialization()
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
    end
end

function Calculate(period)
    if period < source:size() - 1 or loading then
        return;
    end

    Indicator:update(core.UpdateAll );

    if not Indicator.DATA:hasData(Indicator.DATA:size()-1) then
        return;
    end

    local Top = nil;
    local Bottom = nil;
    local Central = nil; 
	    
        Top = Indicator.BuffBandUp[Indicator.BuffBandUp:size()-1];
        Bottom = Indicator.BuffBandDn[Indicator.BuffBandDn:size()-1];
		Central = Indicator.BuffReg[Indicator.BuffReg:size()-1]; 
 

    core.host:execute("setStatus", "Top :" .. string.format("%." .. source:getPrecision () .. "f", Top) .. ", Bottom :" .. string.format("%." .. source:getPrecision () .. "f", Bottom));
    local fromDate = nil;
    local toDate = nil;

    local date = source:date(period);
    fromDate, toDate = core.getcandle(TF, date, day_offset, week_offset);

    if fromDate ~= nil and Top ~= nil then
        core.host:execute("drawLine", 1, fromDate, Top, toDate, Top, Color, Style, Widht);
        core.host:execute("drawLine", 2, fromDate, Bottom, toDate, Bottom, Color, Style, Widht);
		core.host:execute("drawLine", 3, fromDate, Central, toDate, Central, Color, Style, Widht);
    end

    return Top, Bottom, Central;
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    local Top, Bottom, Central;
    Top, Bottom, Central = Calculate(period);
    if Top == nil then
        return;
    end

    Activate(1, period, Top, Bottom, Central);
    Activate(2, period, Top, Bottom, Central);
	Activate(3, period, Top, Bottom, Central)
end

function Activate(id, period, Top, Bottom)
    if id == 1 and ON[id] then
        if source.close[period - 1] < Top and source.close[period] > Top then
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Cross Over");
            end
        elseif source.close[period - 1] > Top and source.close[period] < Top then
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] .. " Cross Under");
            end
        end
    elseif id == 2 and ON[id] then
        if source.close[period - 1] < Bottom and source.close[period] > Bottom then
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Cross Over");
            end
        elseif source.close[period - 1] > Bottom and source.close[period] < Bottom then
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] .. " Cross Under");
            end
        end
    elseif id == 3 and ON[id] then
        if source.close[period - 1] < Central and source.close[period] > Central then
            D[id] = nil;
            if U[id] ~= source:serial(period) and period == source:size() - 1 then
                U[id] = source:serial(period);
                SoundAlert(Up[id]);
                EmailAlert(Label[id] .. " Cross Over");
            end
        elseif source.close[period - 1] > Central and source.close[period] < Central then
            U[id] = nil;
            if D[id] ~= source:serial(period) and period == source:size() - 1 then
                D[id] = source:serial(period);
                SoundAlert(Down[id]);
                EmailAlert(Label[id] .. " Cross Under");
            end
        end
    end
end

function AsyncOperationFinished(cookie)
    if cookie == 1 then
        loading = true;
        core.host:execute("setStatus", "Loading");
    elseif cookie == 2 then
        loading = false;
        core.host:execute("setStatus", "Loaded");
        instance:updateFrom(0);		
    else
        return 0;
    end

    return core.ASYNC_REDRAW;
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
    terminal:alertEmail(Email, profile:id(), "(" .. source:instrument() .. ")" .. Subject .. ", " .. LABEL);
end
