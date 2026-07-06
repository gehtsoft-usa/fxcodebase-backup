-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66273
-- Id: 
-- Based on request: http://fxcodebase.com/code/viewtopic.php?f=27&t=66265

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("On Balance Volume");
    indicator:description("Displays volume as a histogram");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volume Indicators");

    indicator.parameters:addColor("clrV", "Indicator Color", "", core.rgb(65, 105, 225));
    indicator.parameters:addColor("UP_color", "Color of Uptrend", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DN_color", "Color of Downtend", "", core.rgb(0, 255, 0));
end

local close;
local volume;
local first;
local V;
local UP;
local DN;
local source;

function Prepare(nameOnly)
    assert(instance.source:supportsVolume(), "The source must have volume");

    source = instance.source;
    close = instance.source.close;
    volume = instance.source.volume;
    first = instance.source:first();

    local name;
    name = profile:id() .. "(" .. instance.source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    DN_color = instance.parameters.DN_color;
    UP_color = instance.parameters.UP_color;

    V = instance:addStream("OBV", core.Line, name, "OBV", instance.parameters.clrV, first);
    V:setPrecision(0);

    UP = instance:createTextOutput("Up", "Up", "Wingdings", 10, core.H_Center, core.V_Top, instance.parameters.UP_color, -1);
    DN = instance:createTextOutput("Dn", "Dn", "Wingdings", 10, core.H_Center, core.V_Bottom, instance.parameters.DN_color, -1);

    instance:ownerDrawn(true);
    instance:drawOnMainChart(true);
end

local pperiod = nil;
local pperiod1 = nil;
local lines = {};

local init = false;
local init2 = false;
local UP_PEN = 1;
local DN_PEN = 2;
function Draw(stage, context) 
    if stage == 102 then
        if not init then
            context:createPen(UP_PEN, context.SOLID, 1, instance.parameters.UP_color);
            context:createPen(DN_PEN, context.SOLID, 1, instance.parameters.DN_color);
            init = true;
        end
        for _, line in ipairs(lines) do
            local x1 = context:positionOfDate(line.Date1);
            local x2 = context:positionOfDate(line.Date2);
            local visible, y1 = context:pointOfPrice(line.Price1);
            local visible, y2 = context:pointOfPrice(line.Price2);
            context:drawLine(line.IsDown and DN_PEN or UP_PEN, x1, y1, x2, y2);
        end
    elseif stage == 2 then
        if not init2 then
            context:createPen(UP_PEN, context.SOLID, 1, instance.parameters.UP_color);
            context:createPen(DN_PEN, context.SOLID, 1, instance.parameters.DN_color);
            init2 = true;
        end
        for _, line in ipairs(lines) do
            local x1 = context:positionOfDate(line.Date1);
            local x2 = context:positionOfDate(line.Date2);
            local visible, y1 = context:pointOfPrice(line.IndiVal1);
            local visible, y2 = context:pointOfPrice(line.IndiVal2);
            context:drawLine(line.IsDown and DN_PEN or UP_PEN, x1, y1, x2, y2);
        end
    end
end

function Update(period, mode)
    if period == first then
        V[period] = volume[period];
    elseif period > first then
        if close[period] > close[period - 1] then
            V[period] = V[period - 1] + volume[period];
        elseif close[period] < close[period - 1] then
            V[period] = V[period - 1] - volume[period];
        else
            V[period] = V[period - 1];
        end
    end
    if pperiod ~= nil and pperiod > period or period <= first then
        lines = {};
    end
    pperiod = period;
    -- process only candles which are already closed closed.
    if pperiod1 ~= nil and pperiod1 == source:serial(period) then
        return ;
    end
    
    period = period - 1;
    pperiod1 = source:serial(period);

    if period >= first then
        if period >= first + 2 then
            processBullish(period - 2);
            processBearish(period - 2);
        end
    end
end

function processBullish(period)
    if isTrough(period) then
        local curr, prev;
        curr = period;
        prev = prevTrough(period);
        if prev ~= nil then
            if V[curr] > V[prev] and source.low[curr] < source.low[prev] then
                DN:set(curr, V[curr], "\225", "Classic bullish");
                local line = {};
                line.Date1 = source:date(prev);
                line.Date2 = source:date(curr);
                line.IndiVal1 = V[prev];
                line.IndiVal2 = V[curr];
                line.Price1 = source.low[prev];
                line.Price2 = source.low[curr]
                line.IsDown = true;
                lines[#lines + 1] = line;
            elseif V[curr] < V[prev] and source.low[curr] > source.low[prev] then
                DN:set(curr, V[curr], "\225", "Reversal bullish");
                local line = {};
                line.Date1 = source:date(prev);
                line.Date2 = source:date(curr);
                line.IndiVal1 = V[prev];
                line.IndiVal2 = V[curr];
                line.Price1 = source.low[prev];
                line.Price2 = source.low[curr]
                line.IsDown = true;
                lines[#lines + 1] = line;
            end
        end
    end
end

function isTrough(period)
    local i;
    if V[period] < V[period - 1] and V[period] < V[period + 1] then
        for i = period - 1, first, -1 do
            if V[i] > V[period] then
                return true;
            elseif V[period] > V[i] then
                return false;
            end
        end
    end
    return false;
end

function prevTrough(period)
    local i;
    for i = period - 5, first, -1 do
        if V[i] <= V[i - 1] and V[i] < V[i - 2] and
           V[i] <= V[i + 1] and V[i] < V[i + 2] then
           return i;
        end
    end
    return nil;
end

function processBearish(period)
    if isPeak(period) then
        local curr, prev;
        curr = period;
        prev = prevPeak(period);
        if prev ~= nil then
            if V[curr] < V[prev] and source.high[curr] > source.high[prev] then
                UP:set(curr, V[curr], "\226", "Classic bearish");
                local line = {};
                line.Date1 = source:date(prev);
                line.Date2 = source:date(curr);
                line.IndiVal1 = V[prev];
                line.IndiVal2 = V[curr];
                line.Price1 = source.high[prev];
                line.Price2 = source.high[curr];
                line.IsDown = false;
                lines[#lines + 1] = line;
            elseif V[curr] > V[prev] and source.high[curr] < source.high[prev] then
                UP:set(curr, V[curr], "\226", "Reversal bearish");
                local line = {};
                line.Date1 = source:date(prev);
                line.Date2 = source:date(curr);
                line.IndiVal1 = V[prev];
                line.IndiVal2 = V[curr];
                line.Price1 = source.high[prev];
                line.Price2 = source.high[curr];
                line.IsDown = false;
                lines[#lines + 1] = line;
            end
        end
    end
end

function isPeak(period)
    local i;
    if V[period] > V[period - 1] and V[period] > V[period + 1] then
        for i = period - 1, first, -1 do
            if V[i] < V[period] then
                return true;
            elseif V[period] < V[i] then
                return false;
            end
        end
    end
    return false;
end

function prevPeak(period)
    local i;
    for i = period - 5, first, -1 do
        if V[i] >= V[i - 1] and V[i] > V[i - 2] and
           V[i] >= V[i + 1] and V[i] > V[i + 2] then
           return i;
        end
    end
    return nil;
end
