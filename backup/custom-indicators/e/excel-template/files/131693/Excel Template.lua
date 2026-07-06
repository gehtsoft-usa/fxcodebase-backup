-- Id: 23087
-- Id:  
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67053

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Excel Template")
    indicator:description("Excel Template")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("MA Calculation")
    indicator.parameters:addInteger("Period", "Period", "", 50, 1, 2000)
    indicator.parameters:addString("Method", "Method", "Method", "MVA")
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA", "MVA")
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA", "EMA")
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA", "LWMA")
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA", "TMA")
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA", "SMMA")
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA", "KAMA")
    indicator.parameters:addStringAlternative("Method", "HMA", "HMA", "HMA")
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA", "WMA")
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA", "VIDYA")

    indicator.parameters:addString("Price", "CLOSE", "", "close")
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open")
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high")
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low")
    indicator.parameters:addStringAlternative("Price", "CLOSE", "", "close")
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median")
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical")
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted")

    indicator.parameters:addGroup("Channel Calculation")
    indicator.parameters:addString("Type", "Shift Type", "", "ATR")
    indicator.parameters:addStringAlternative("Type", "ATR", "", "ATR")
    indicator.parameters:addStringAlternative("Type", "PIP", "", "PIP")

    indicator.parameters:addInteger("AtrPeriod", "ATR Period", "", 50, 1, 2000)
    indicator.parameters:addDouble("Size", "Shift in Pips", "", 50, 0, 2000)

    indicator.parameters:addBoolean("Show", "Show Channel", "", true)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Up", "Color of Uptrend", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Down", "Color of Downtrend", "", core.rgb(255, 0, 0))

    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)

    indicator.parameters:addGroup("Alerts")
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false)
    indicator.parameters:addFile("SoundFile", "Sound File", "", "")
    indicator.parameters:setFlag("SoundFile", core.FLAG_SOUND)
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false)
    indicator.parameters:addString("signaler_dde_service", "Service Name", "The service name must be unique amoung all running instances of the strategy", "TS2ALERTS");
    indicator.parameters:addString("signaler_dde_topic", "DDE Topic", "", "");
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Method, Period, Type

local first
local source = nil
local Size
-- Streams block
local MA = nil
local Indicator
local Price
local Top, Bottom
local ATR, AtrPeriod
-- Routine
local LastTime
local PlaySound, PlaySound, RecurrentSound, SoundFile

function SoundAlert()
    if not PlaySound then
        return
    end

    terminal:alertSound(SoundFile, RecurrentSound)
end

local dde_server;
local dde_topic;
local dde_alerts_1;
local dde_alerts_2;
local dde_alerts_3;
function Prepare(nameOnly)
    Size = instance.parameters.Size
    Show = instance.parameters.Show
    Type = instance.parameters.Type
    Method = instance.parameters.Method
    Period = instance.parameters.Period
    Price = instance.parameters.Price
    AtrPeriod = instance.parameters.AtrPeriod
    source = instance.source
    first = source:first()

    PlaySound = instance.parameters.PlaySound
    if PlaySound then
        SoundFile = instance.parameters.SoundFile
    else
        SoundFile = nil
    end
    assert(not (PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be chosen")
    RecurrentSound = instance.parameters.RecurrentSound

    LastTime = nil

    local name =
        profile:id() ..
        "(" ..
            source:name() ..
                ", " ..
                    tostring(Price) ..
                        ", " .. tostring(Method) .. ", " .. tostring(Period) .. ", " .. tostring(Type) .. ")"
    instance:name(name)

    if (not (nameOnly)) then
        require("ddeserver_lua");
        dde_server = ddeserver_lua.new(instance.parameters.signaler_dde_service);
        dde_topic = dde_server:addTopic(instance.parameters.signaler_dde_topic);
        dde_alerts_1 = dde_server:addValue(dde_topic, "Alerts1");
        dde_alerts_2 = dde_server:addValue(dde_topic, "Alerts2");
        dde_alerts_3 = dde_server:addValue(dde_topic, "Alerts3");

        assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
        Indicator = core.indicators:create(Method, source[Price], Period)
        ATR = core.indicators:create("ATR", source, AtrPeriod)
        first = Indicator.DATA:first()

        MA = instance:addStream("MA", core.Line, name, "MA", instance.parameters.Up, first)
        MA:setWidth(instance.parameters.width)
        MA:setStyle(instance.parameters.style)

        if Show then
            Top = instance:addStream("TOP", core.Line, name, "Top", instance.parameters.Up, first)
            Bottom = instance:addStream("BOTTOM", core.Line, name, "Bottom", instance.parameters.Down, first)
        else
            Top = instance:addInternalStream(0, 0)
            Bottom = instance:addInternalStream(0, 0)
        end
    end
end

function ReleaseInstance()
    dde_server:close();
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not source:hasData(period) then
        return
    end

    Indicator:update(mode)
    ATR:update(mode)

    local Shift

    if Type == "ATR" then
        Shift = ATR.DATA[period]
    else
        Shift = Size * source:pipSize()
    end

    MA[period] = Indicator.DATA[period]
    Top[period] = MA[period] + Shift
    Bottom[period] = MA[period] - Shift

    if MA[period] > MA[period - 1] then
        MA:setColor(period, instance.parameters.Up)
    elseif MA[period] < MA[period - 1] then
        MA:setColor(period, instance.parameters.Down)
    end

    if
        source.close[source:size() - 1] > Bottom[Bottom:size() - 1] and
            source.close[source:size() - 1] < Top[Top:size() - 1]
     then
        if period == source:size() - 1 and LastTime ~= source:date(period) then
            LastTime = source:date(period)
            SoundAlert()
            dde_server:set(dde_topic, dde_alerts_1, "Cross on " .. source:instrument() .. " " .. core.formatDate(source:date(period)) .. " #1");
            dde_server:set(dde_topic, dde_alerts_2, "Cross on " .. source:instrument() .. " " .. core.formatDate(source:date(period)) .. " #2");
            dde_server:set(dde_topic, dde_alerts_3, "Cross on " .. source:instrument() .. " " .. core.formatDate(source:date(period)) .. " #3");
        end
    end
end

function AsyncOperationFinished(cookie, success, message)
end
