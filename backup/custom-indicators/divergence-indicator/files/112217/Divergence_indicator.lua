-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64631
-- Id: 18075

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
    indicator:name("Divergence indicator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addColor("UP_color", "Color of Uptrend", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DN_color", "Color of Downtend", "", core.rgb(0, 255, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local indic_source;
local source;
local loading = true;
local DN_color;
local UP_color;

-- Routine
function Prepare(nameOnly)
    indic_source = instance.source;
    DN_color = instance.parameters.DN_color;
    UP_color = instance.parameters.UP_color;
    
    local name;
    name = profile:id() .. "(" .. indic_source:name() .. ")";
    instance:name(name);
    
    if nameOnly then
        return;
    end

    source = core.host:execute("getSyncHistory", indic_source:instrument(), indic_source:barSize(), indic_source:isBid(), 0, 100, 101);

    first = indic_source:first();

    UP = instance:createTextOutput ("Up", "Up", "Wingdings", 10, core.H_Center, core.V_Top, instance.parameters.UP_color, -1);
    DN = instance:createTextOutput ("Dn", "Dn", "Wingdings", 10, core.H_Center, core.V_Bottom, instance.parameters.DN_color, -1);
end

function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end

local pperiod = nil;
local pperiod1 = nil;
local line_id = 0;

-- Indicator calculation routine
function Update(period, mode)
    if loading then
        return;
    end
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
            if indic_source[curr] > indic_source[prev] and source.low[curr] < source.low[prev] then
                DN:set(curr, indic_source[curr], "\225", "Classic bullish");
                line_id = line_id + 1;
                core.host:execute("drawLine", line_id, source:date(prev), indic_source[prev], source:date(curr), indic_source[curr], DN_color);
            elseif indic_source[curr] < indic_source[prev] and source.low[curr] > source.low[prev] then
                DN:set(curr, indic_source[curr], "\225", "Reversal bullish");
                line_id = line_id + 1;
                core.host:execute("drawLine", line_id, source:date(prev), indic_source[prev], source:date(curr), indic_source[curr], DN_color);
            end
        end
    end
end

function isTrough(period)
    local i;
    if indic_source[period] < indic_source[period - 1] and indic_source[period] < indic_source[period + 1] then
        for i = period - 1, first, -1 do
            if indic_source[i] > indic_source[period] then
                return true;
            elseif indic_source[period] > indic_source[i] then
                return false;
            end
        end
    end
    return false;
end

function prevTrough(period)
    local i;
    for i = period - 5, first, -1 do
        if indic_source[i] <= indic_source[i - 1] and indic_source[i] < indic_source[i - 2] and
           indic_source[i] <= indic_source[i + 1] and indic_source[i] < indic_source[i + 2] then
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
            if indic_source[curr] < indic_source[prev] and source.high[curr] > source.high[prev] then
                UP:set(curr, indic_source[curr], "\226", "Classic bearish");
                line_id = line_id + 1;
                core.host:execute("drawLine", line_id, source:date(prev), indic_source[prev], source:date(curr), indic_source[curr], UP_color);
            elseif indic_source[curr] > indic_source[prev] and source.high[curr] < source.high[prev] then
                UP:set(curr, indic_source[curr], "\226", "Reversal bearish");
                line_id = line_id + 1;
                core.host:execute("drawLine", line_id, source:date(prev), indic_source[prev], source:date(curr), indic_source[curr], UP_color);
            end
        end
    end
end

function isPeak(period)
    local i;
    if indic_source[period] > indic_source[period - 1] and indic_source[period] > indic_source[period + 1] then
        for i = period - 1, first, -1 do
            if indic_source[i] < indic_source[period] then
                return true;
            elseif indic_source[period] < indic_source[i] then
                return false;
            end
        end
    end
    return false;
end

function prevPeak(period)
    local i;
    for i = period - 5, first, -1 do
        if indic_source[i] >= indic_source[i - 1] and indic_source[i] > indic_source[i - 2] and
           indic_source[i] >= indic_source[i + 1] and indic_source[i] > indic_source[i + 2] then
           return i;
        end
    end
    return nil;
end
