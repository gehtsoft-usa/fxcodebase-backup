-- Id: 15246
-- This is a port of Waddah_Attar_Explosion.mq4 
-- Original indicator Copyright � 2006, Eng. Waddah Attar, waddahattar@hotmail.com 

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Waddah Attar's Explosion Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("Sen", "Sensitivity", "", 150);
    indicator.parameters:addInteger("DeadZonePip", "Dead Zone in pips", "", 30);
    indicator.parameters:addColor("TG_color", "Color of postive trend", "", core.rgb(0, 192, 0));
    indicator.parameters:addColor("TR_color", "Color of negative trend", "", core.rgb(192, 0, 0));
    indicator.parameters:addColor("E_color", "Color of explosion line", "", core.rgb(128, 64, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Sen;
local DeadZonePip;

local first;
local firstBB;
local source = nil;

-- Streams block
local TG = nil;
local TR = nil;
local E = nil;

local EMAF = nil;
local EMAS = nil;
local BB_H = nil;
local BB_L = nil;

-- Routine
function Prepare()
    Sen = instance.parameters.Sen;
    DeadZonePip = instance.parameters.DeadZonePip;
    source = instance.source;

    EMAF = core.indicators:create("EMA", source.close, 20);
    EMAS = core.indicators:create("EMA", source.close, 40);
    first = EMAS.DATA:first() + 2;
    firstBB = source:first() + 20;
    BB_H = instance:addInternalStream(firstBB, 0);
    BB_L = instance:addInternalStream(firstBB, 0);

    local name = profile:id() .. "(" .. source:name() .. ", " .. Sen .. ", " .. DeadZonePip .. ")";
    instance:name(name);
    TG = instance:addStream("TG", core.Bar, name .. ".TG", "TG", instance.parameters.TG_color, first);
    TG:setPrecision(math.max(2, instance.source:getPrecision()));
    TR = instance:addStream("TR", core.Bar, name .. ".TR", "TR", instance.parameters.TR_color, first);
    TR:setPrecision(math.max(2, instance.source:getPrecision()));
    E = instance:addStream("E", core.Line, name .. ".E", "E", instance.parameters.E_color, first);
    E:setPrecision(math.max(2, instance.source:getPrecision()));
    E:addLevel(0);
    E:addLevel(DeadZonePip * source:pipSize());
end

-- Indicator calculation routine
function Update(period, mode)
    EMAF:update(mode);
    EMAS:update(mode);

    if period >= firstBB then
        local p = core.rangeTo(period, 20);
        local ml = core.avg(source.close, p);
        local d = core.stdev(source.close, p);
        BB_H[period] = ml + 2 * d;
        BB_L[period] = ml - 2 * d;
    end

    if period >= first then
        local trend, explosion;
        trend = (MACD(period) - MACD(period - 1)) * Sen;
        explosion = BB_H[period] - BB_L[period];
        if trend > 0 then
            TG[period] = trend;
            TR[period] = 0;
        elseif trend < 0 then
            TG[period] = 0;
            TR[period] = -trend;
        end
        E[period] = explosion;
    end
end

function MACD(period)
    return EMAF.DATA[period] - EMAS.DATA[period];
end

