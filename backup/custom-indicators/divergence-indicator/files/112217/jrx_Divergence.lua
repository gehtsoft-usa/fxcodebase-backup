-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64631
-- Id: 18076

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("JRX Divergence");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods to smooth", "", 8, 1, 10000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("UP_color", "Color of Uptrend", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DN_color", "Color of Downtend", "", core.rgb(0, 255, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first, first0, alive, jrx, jrx1;
local source;
local data;
local indicator;
local UP_color;
local DN_color;

-- Routine
function Prepare(nameOnly)
    source = instance.source;
    
    local name;
    name = profile:id() .. "(" .. source:name() .. "," .. instance.parameters.N .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	assert(core.indicators:findIndicator("JRX") ~= nil, "Please, download and install JRX.LUA indicator");    
	
    indicator = core.indicators:create("JRX", source, instance.parameters.N);
    first = indicator.DATA:first();

    data = instance:addStream("JRX", core.Line, name .. ".JRX", "JRX", instance.parameters.clr, indicator.DATA:first());
    data:setWidth(instance.parameters.width);
    data:setStyle(instance.parameters.style);
    UP_color = instance.parameters.UP_color;
    DN_color = instance.parameters.DN_color;
    UP = instance:createTextOutput ("Up", "Up", "Wingdings", 10, core.H_Center, core.V_Top, instance.parameters.UP_color, -1);
    DN = instance:createTextOutput ("Dn", "Dn", "Wingdings", 10, core.H_Center, core.V_Bottom, instance.parameters.DN_color, -1);
end

local pperiod = nil;
local pperiod1 = nil;
local line_id = 0;

-- Indicator calculation routine
function Update(period, mode)
    -- if recaclulation started - remove all
    if pperiod ~= nil and pperiod > period 
	or period <= first 	
	then
        core.host:execute("removeAll");
    end
    pperiod = period;
    -- process only candles which are already closed closed.
    if pperiod1 ~= nil and pperiod1 == source:serial(period) then
        return ;
    end
    
    period = period - 1;
	pperiod1 = source:serial(period);

    indicator:update(mode);
    if period >= first then
        data[period] = indicator.DATA[period];
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
            if indicator.DATA[curr] > indicator.DATA[prev] and source.low[curr] < source.low[prev] then
                DN:set(curr, indicator.DATA[curr], "\225", "Classic bullish");
                line_id = line_id + 1;
                core.host:execute("drawLine", line_id, source:date(prev), indicator.DATA[prev], source:date(curr), indicator.DATA[curr], DN_color);
            elseif indicator.DATA[curr] < indicator.DATA[prev] and source.low[curr] > source.low[prev] then
                DN:set(curr, indicator.DATA[curr], "\225", "Reversal bullish");
                line_id = line_id + 1;
                core.host:execute("drawLine", line_id, source:date(prev), indicator.DATA[prev], source:date(curr), indicator.DATA[curr], DN_color);
            end
        end
    end
end
function isTrough(period)
    local i;
    if indicator.DATA[period] < indicator.DATA[period - 1] and indicator.DATA[period] < indicator.DATA[period + 1] then
        for i = period - 1, first, -1 do
            if indicator.DATA[i] > indicator.DATA[period] then
                return true;
            elseif indicator.DATA[period] > indicator.DATA[i] then
                return false;
            end
        end
    end
    return false;
end

function prevTrough(period)
    local i;
    for i = period - 5, first, -1 do
        if indicator.DATA[i] <= indicator.DATA[i - 1] and indicator.DATA[i] < indicator.DATA[i - 2] and
           indicator.DATA[i] <= indicator.DATA[i + 1] and indicator.DATA[i] < indicator.DATA[i + 2] then
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
            if indicator.DATA[curr] < indicator.DATA[prev] and source.high[curr] > source.high[prev] then
                UP:set(curr, indicator.DATA[curr], "\226", "Classic bearish");
                line_id = line_id + 1;
                core.host:execute("drawLine", line_id, source:date(prev), indicator.DATA[prev], source:date(curr), indicator.DATA[curr], UP_color);
            elseif indicator.DATA[curr] > indicator.DATA[prev] and source.high[curr] < source.high[prev] then
                UP:set(curr, indicator.DATA[curr], "\226", "Reversal bearish");
                line_id = line_id + 1;
                core.host:execute("drawLine", line_id, source:date(prev), indicator.DATA[prev], source:date(curr), indicator.DATA[curr], UP_color);
            end
        end
    end
end

function isPeak(period)
    local i;
    if indicator.DATA[period] > indicator.DATA[period - 1] and indicator.DATA[period] > indicator.DATA[period + 1] then
        for i = period - 1, first, -1 do
            if indicator.DATA[i] < indicator.DATA[period] then
                return true;
            elseif indicator.DATA[period] < indicator.DATA[i] then
                return false;
            end
        end
    end
    return false;
end

function prevPeak(period)
    local i;
    for i = period - 5, first, -1 do
        if indicator.DATA[i] >= indicator.DATA[i - 1] and indicator.DATA[i] > indicator.DATA[i - 2] and
           indicator.DATA[i] >= indicator.DATA[i + 1] and indicator.DATA[i] > indicator.DATA[i + 2] then
           return i;
        end
    end
    return nil;
end
