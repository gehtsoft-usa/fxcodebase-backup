-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69055


--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("Weekly Volume Weighted Average Price (VWAP)")
    indicator:description("Weekly Volume Weighted Average Price (VWAP)")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)
    indicator:setTag("group", "Volume Indicators")

    indicator.parameters:addGroup("Band Parameters")
    indicator.parameters:addBoolean("BAND", "Show Bands", "", true)
    Add(1, 1)
    Add(2, 2)
    Add(3, 3)
    Add(4, 4)
    Add(5, 5)

    indicator.parameters:addGroup("VWAP Parameters")

    indicator.parameters:addString("Price", "Price Source", "", "close")
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open")
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high")
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low")
    indicator.parameters:addStringAlternative("Price", "CLOSE", "", "close")
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median")
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical")
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted")

    indicator.parameters:addString("StartTime", "Start Time for Trading, NY TZ", "", "00:00:00");
    indicator.parameters:addString("StopTime", "Stop Time for Trading, NY TZ", "", "23:15:00");

    indicator.parameters:addGroup("Style Parameters")
    indicator.parameters:addColor("VAMA_color", "Color of VWAP Central Line", "", core.rgb(0, 0, 255))
    indicator.parameters:addInteger("width", "Width", "", 1, 1, 5)
    indicator.parameters:addInteger("style", "Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)

    AddStyle(1, core.rgb(128, 128, 128))
    AddStyle(2, core.rgb(255, 0, 0))
    AddStyle(3, core.rgb(255, 128, 0))
    AddStyle(4, core.rgb(128, 255, 0))
    AddStyle(5, core.rgb(0, 255, 0))
end

function AddStyle(id, Color)
    indicator.parameters:addColor("Color" .. id, id .. ". Deviation Band Color ", "", Color)
    indicator.parameters:addInteger("Width" .. id, "Width", "", 1, 1, 5)
    indicator.parameters:addInteger("Style" .. id, "Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("Style" .. id, core.FLAG_LINE_STYLE)
end

function Add(id, Level)
    indicator.parameters:addBoolean("On" .. id, "Show " .. id .. ". Deviation Band", "", true)
    indicator.parameters:addDouble("Level" .. id, id .. ". Multiplier", "", Level)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
local On = {}
local first
local source = nil
local PriceTimesVolume
local VAMA = nil
local host
local offset
local weekoffset
local s = nil
local e = nil
local START = nil
local Price
local RAW
local DEV
local UP = {}
local DOWN = {}
local BAND
local Level = {}
local Style = {}
local Width = {}
local Color = {}
local OpenTime, CloseTime;
function Prepare(nameOnly)
    Price = instance.parameters.Price

    Type = instance.parameters.Type
    BAND = instance.parameters.BAND
    source = instance.source
    first = source:first()

    local name = profile:id() .. "(" .. source:name() .. ")"
    instance:name(name)
    if nameOnly then
        return;
    end

    OpenTime, valid = ParseTime(instance.parameters.StartTime);
    assert(valid, "Time " .. instance.parameters.StartTime .. " is invalid");
    CloseTime, valid = ParseTime(instance.parameters.StopTime);
    assert(valid, "Time " .. instance.parameters.StopTime .. " is invalid");

    local i
    for i = 1, 5, 1 do
        Level[i] = instance.parameters:getDouble("Level" .. i)
        On[i] = instance.parameters:getBoolean("On" .. i)
        Style[i] = instance.parameters:getDouble("Style" .. i)
        Width[i] = instance.parameters:getDouble("Width" .. i)
        Color[i] = instance.parameters:getDouble("Color" .. i)

        if BAND then
            RAW = instance:addInternalStream(0, 0)
            if On[i] then
                UP[i] = instance:addStream("UP" .. i, core.Line, name, i, Color[i], first)
                UP[i]:setWidth(Width[i])
                UP[i]:setStyle(Style[i])

                DOWN[i] = instance:addStream("DOWN" .. i, core.Line, name, i, Color[i], first)
                DOWN[i]:setWidth(Width[i])
                DOWN[i]:setStyle(Style[i])
            end
        end
    end

    host = core.host
    offset = host:execute("getTradingDayOffset")
    weekoffset = host:execute("getTradingWeekOffset")

    PriceTimesVolume = instance:addInternalStream(first, 0)

    VAMA = instance:addStream("VAMA", core.Line, name, "VAMA", instance.parameters.VAMA_color, first)
    VAMA:setWidth(instance.parameters.width)
    VAMA:setStyle(instance.parameters.style)
end

function ParseTime(time)
    local pos = string.find(time, ":");
    if pos == nil then
        return nil, false;
    end
    local h = tonumber(string.sub(time, 1, pos - 1));
    time = string.sub(time, pos + 1);
    pos = string.find(time, ":");
    if pos == nil then
        return nil, false;
    end
    local m = tonumber(string.sub(time, 1, pos - 1));
    local s = tonumber(string.sub(time, pos + 1));
    return (h / 24.0 +  m / 1440.0 + s / 86400.0),                          -- time in ole format
           ((h >= 0 and h < 24 and m >= 0 and m < 60 and s >= 0 and s < 60) or (h == 24 and m == 0 and s == 0)); -- validity flag
end

local start = nil;
function Update(period)
    if period < first or not source:hasData(period) then
        return
    end

    local date = source:date(period);
    local dt = core.dateToTable(date);
    if dt.wday == 8 or dt.wday == 1
        or (dt.wday == 7 and math.floor(date) + CloseTime < date) 
        or (dt.wday == 2 and math.floor(date) + OpenTime > date)
        or (start ~= nil and start > period)
    then
        start = nil;
        return;
    end
    if start == nil then
        start = period;
    end

    PriceTimesVolume[period] = source[Price][period] * source.volume[period]
    VAMA[period] =
        core.sum(PriceTimesVolume, core.range(start, period)) / core.sum(source.volume, core.range(start, period))

    if BAND then
        RAW[period] = source[Price][period] - VAMA[period]
        DEV = core.stdev(RAW, core.range(start, period))

        for i = 1, 5, 1 do
            if On[i] then
                UP[i][period] = VAMA[period] + DEV * Level[i]
                DOWN[i][period] = VAMA[period] - DEV * Level[i]
            end
        end
    end
end
