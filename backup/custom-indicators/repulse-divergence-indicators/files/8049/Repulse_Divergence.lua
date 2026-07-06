-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3362
-- Id: 3083

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("Repulse Divergence");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("RepulsePeriod1", "RepulsePeriod1", "", 1);
    indicator.parameters:addInteger("RepulsePeriod2", "RepulsePeriod2", "", 5);
    indicator.parameters:addInteger("RepulsePeriod3", "RepulsePeriod3", "", 15);
    indicator.parameters:addInteger("RepulseLine", "RepulseLine", "", 1);
    
    indicator.parameters:addBoolean("I", "Indicator mode", "Keep true value to display labels and lines. Set this parameter to false when the indicator is used in another indicator.", true);
    indicator.parameters:addColor("D1_color", "Color of Repulse 1 line", "", core.rgb(0, 155, 255));
    indicator.parameters:addColor("D2_color", "Color of Repulse 2 line", "", core.rgb(0, 255, 255));
    indicator.parameters:addColor("D3_color", "Color of Repulse 3 line", "", core.rgb(0, 155, 155));
    indicator.parameters:addColor("UP_color", "Color of Uptrend", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DN_color", "Color of Downtend", "", core.rgb(0, 255, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local I;
local DD;
local UP_color;
local DN_color;

local first;
local source = nil;

-- Streams block
local D1 = nil;
local D2 = nil;
local D3 = nil;
local UP = nil;
local DN = nil;
local Repulse = nil;
local lineid = nil;
local RepulseOut;
local RepulseLine;

-- Routine
function Prepare(nameOnly)
    I = instance.parameters.I;
    DD = instance.parameters.DD;
    RepulseLine = instance.parameters.RepulseLine;
    UP_color = instance.parameters.UP_color;
    DN_color = instance.parameters.DN_color;
    source = instance.source;
	
	assert(core.indicators:findIndicator("REPULSE") ~= nil, "Please, download and install REPULSE.LUA indicator");   

    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.RepulsePeriod1 .. ", " .. instance.parameters.RepulsePeriod2 .. ", " .. instance.parameters.RepulsePeriod3 .. ", " .. instance.parameters.RepulseLine .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Repulse = core.indicators:create("REPULSE", source, instance.parameters.RepulsePeriod1, instance.parameters.RepulsePeriod2, instance.parameters.RepulsePeriod3);
    if RepulseLine==1 then
     RepulseOut=Repulse.Buff1;
    elseif RepulseLine==2 then
     RepulseOut=Repulse.Buff2;
    else
     RepulseOut=Repulse.Buff3;
    end 
    first = RepulseOut:first();
    D1 = instance:addStream("Repulse1", core.Line, name .. ".Repulse1", "Repulse1", instance.parameters.D1_color, first, -1);
    D1:setPrecision(math.max(2, instance.source:getPrecision()));
    D2 = instance:addStream("Repulse2", core.Line, name .. ".Repulse2", "Repulse2", instance.parameters.D2_color, first, -1);
    D2:setPrecision(math.max(2, instance.source:getPrecision()));
    D3 = instance:addStream("Repulse3", core.Line, name .. ".Repulse3", "Repulse3", instance.parameters.D3_color, first, -1);
    D3:setPrecision(math.max(2, instance.source:getPrecision()));
    if I then
        UP = instance:createTextOutput ("Up", "Up", "Wingdings", 10, core.H_Center, core.V_Top, instance.parameters.UP_color, -1);
        DN = instance:createTextOutput ("Dn", "Dn", "Wingdings", 10, core.H_Center, core.V_Bottom, instance.parameters.DN_color, -1);
    else
        UP = instance:addStream("UP", core.Bar, name .. ".UP", "UP", instance.parameters.UP_color, first, -1);
    UP:setPrecision(math.max(2, instance.source:getPrecision()));
        DN = instance:addStream("DN", core.Bar, name .. ".DN", "DN", instance.parameters.DN_color, first, -1);
    DN:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

local pperiod = nil;
local pperiod1 = nil;
local line_id = 0;

-- Indicator calculation routine
function Update(period, mode)
    -- if recaclulation started - remove all
    if pperiod ~= nil and pperiod > period then
        core.host:execute("removeAll");
    end
    pperiod = period;
    -- process only candles which are already closed closed.
    if pperiod1 ~= nil and pperiod1 == source:serial(period) then
        return ;
    end
    pperiod1 = source:serial(period)
    period = period - 1;

    Repulse:update(mode);
    if period >= first then
        D1[period] = Repulse.Buff1[period];
        D2[period] = Repulse.Buff2[period];
        D3[period] = Repulse.Buff3[period];
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
            if RepulseOut[curr] > RepulseOut[prev] and source.low[curr] < source.low[prev] then
                if I then
                    DN:set(curr, RepulseOut[curr], "\225", "Classic bullish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), RepulseOut[prev], source:date(curr), RepulseOut[curr], DN_color);
                else
                    DN[period] = curr - prev;
                end
            elseif RepulseOut[curr] < RepulseOut[prev] and source.low[curr] > source.low[prev] then
                if I then
                    DN:set(curr, RepulseOut[curr], "\225", "Reversal bullish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), RepulseOut[prev], source:date(curr), RepulseOut[curr], DN_color);
                else
                    DN[period] = -(curr - prev);
                end
            end
        end

    end
end

function isTrough(period)
    local i;
    if RepulseOut[period] < 0 and RepulseOut[period] < RepulseOut[period - 1] and RepulseOut[period] < RepulseOut[period + 1] then
        for i = period - 1, first, -1 do
            if RepulseOut[i] > 0 then
                return true;
            elseif RepulseOut[period] > RepulseOut[i] then
                return false;
            end
        end
    end
    return false;
end

function prevTrough(period)
    local i;
    for i = period - 5, first, -1 do
        if RepulseOut[i] <= RepulseOut[i - 1] and RepulseOut[i] < RepulseOut[i - 2] and
           RepulseOut[i] <= RepulseOut[i + 1] and RepulseOut[i] < RepulseOut[i + 2] then
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
            if RepulseOut[curr] < RepulseOut[prev] and source.high[curr] > source.high[prev] then
                if I then
                    UP:set(curr, RepulseOut[curr], "\226", "Classic bearish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), RepulseOut[prev], source:date(curr), RepulseOut[curr], UP_color);
                else
                    UP[period] = curr - prev;
                end
            elseif RepulseOut[curr] > RepulseOut[prev] and source.high[curr] < source.high[prev] then
                if I then
                    UP:set(curr, RepulseOut[curr], "\226", "Reversal bearish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), RepulseOut[prev], source:date(curr), RepulseOut[curr], UP_color);
                else
                    UP[period] = -(curr - prev);
                end
            end
        end

    end
end

function isPeak(period)
    local i;
    if RepulseOut[period] > 0 and RepulseOut[period] > RepulseOut[period - 1] and RepulseOut[period] > RepulseOut[period + 1] then
        for i = period - 1, first, -1 do
            if RepulseOut[i] < 0 then
                return true;
            elseif RepulseOut[period] < RepulseOut[i] then
                return false;
            end
        end
    end
    return false;
end

function prevPeak(period)
    local i;
    for i = period - 5, first, -1 do
        if RepulseOut[i] >= RepulseOut[i - 1] and RepulseOut[i] > RepulseOut[i - 2] and
           RepulseOut[i] >= RepulseOut[i + 1] and RepulseOut[i] > RepulseOut[i + 2] then
           return i;
        end
    end
    return nil;
end
