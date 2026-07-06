-- Id: 19146
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65133

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


function Init()
    indicator:name("Stochastic %K Divergence");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("K", "K", "Parameter of stochastic", 5);
    indicator.parameters:addInteger("SD", "SD", "Parameter of stochastic", 3);
    indicator.parameters:addColor("D_color", "Color of Divergence line", "", core.rgb(0, 155, 255));
    indicator.parameters:addColor("UP_color", "Color of Uptrend", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DN_color", "Color of Downtend", "", core.rgb(0, 255, 0));
end

local DD;
local UP_color;
local DN_color;

local first;
local source = nil;

local D = nil;
local UP = nil;
local DN = nil;
local Stochastic = nil;
local lineid = nil;

function Prepare(nameOnly)
    DD = instance.parameters.DD;
    UP_color = instance.parameters.UP_color;
    DN_color = instance.parameters.DN_color;
    source = instance.source;
    Stochastic = core.indicators:create("STOCHASTIC", source, instance.parameters.K,instance.parameters.SD,3);
    first = Stochastic.DATA:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.K .. ", " .. instance.parameters.SD .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    D = instance:addStream("Stochastic", core.Line, name .. ".Stochastic", "Stochastic", instance.parameters.D_color, first, -1);
    D:addLevel(20);
    D:addLevel(80);
    UP = instance:createTextOutput ("Up", "Up", "Wingdings", 10, core.H_Center, core.V_Top, instance.parameters.UP_color, -1);
    DN = instance:createTextOutput ("Dn", "Dn", "Wingdings", 10, core.H_Center, core.V_Bottom, instance.parameters.DN_color, -1);
	
	D:setPrecision(math.max(2, instance.source:getPrecision()));
end

local pperiod = nil;
local pperiod1 = nil;
local line_id = 0;

function Update(period, mode)
    if pperiod ~= nil and pperiod > period then
        core.host:execute("removeAll");
    end
    pperiod = period;
    if pperiod1 ~= nil and pperiod1 == source:serial(period) then
        return ;
    end
    pperiod1 = source:serial(period)
    period = period - 1;

    Stochastic:update(mode);
    if period >= first then
        D[period] = Stochastic.K[period];
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
            if Stochastic.K[curr] > Stochastic.K[prev] and source.low[curr] < source.low[prev] then
                if I then
                    DN:set(curr, Stochastic.K[curr], "\225", "Classic bullish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), Stochastic.K[prev], source:date(curr), Stochastic.K[curr], DN_color);
                else
                    DN[period] = curr - prev;
                end
            elseif Stochastic.K[curr] < Stochastic.K[prev] and source.low[curr] > source.low[prev] then
                DN:set(curr, Stochastic.K[curr], "\225", "Reversal bullish");
                line_id = line_id + 1;
                core.host:execute("drawLine", line_id, source:date(prev), Stochastic.K[prev], source:date(curr), Stochastic.K[curr], DN_color);
            end
        end

    end
end

function isTrough(period)
    local i;
    if Stochastic.K[period] < Stochastic.K[period - 1] and Stochastic.K[period] < Stochastic.K[period + 1] then
        for i = period - 1, first, -1 do
            if Stochastic.K[i] > 80 then
                return true;
            elseif Stochastic.K[period] > Stochastic.K[i] then
                return false;
            end
        end
    end
    return false;
end

function prevTrough(period)
    local i;
    for i = period - 5, first, -1 do
        if Stochastic.K[i] <= Stochastic.K[i - 1] and Stochastic.K[i] < Stochastic.K[i - 2] and
           Stochastic.K[i] <= Stochastic.K[i + 1] and Stochastic.K[i] < Stochastic.K[i + 2] then
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
            if Stochastic.K[curr] < Stochastic.K[prev] and source.high[curr] > source.high[prev] then
                if I then
                    UP:set(curr, Stochastic.K[curr], "\226", "Classic bearish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), Stochastic.K[prev], source:date(curr), Stochastic.K[curr], UP_color);
                else
                    UP[period] = curr - prev;
                end
            elseif Stochastic.K[curr] > Stochastic.K[prev] and source.high[curr] < source.high[prev] then
                UP:set(curr, Stochastic.K[curr], "\226", "Reversal bearish");
                line_id = line_id + 1;
                core.host:execute("drawLine", line_id, source:date(prev), Stochastic.K[prev], source:date(curr), Stochastic.K[curr], UP_color);
            end
        end

    end
end

function isPeak(period)
    local i;
    if Stochastic.K[period] > Stochastic.K[period - 1] and Stochastic.K[period] > Stochastic.K[period + 1] then
        for i = period - 1, first, -1 do
            if Stochastic.K[i] < 20 then
                return true;
            elseif Stochastic.K[period] < Stochastic.K[i] then
                return false;
            end
        end
    end
    return false;
end

function prevPeak(period)
    local i;
    for i = period - 5, first, -1 do
        if Stochastic.K[i] >= Stochastic.K[i - 1] and Stochastic.K[i] > Stochastic.K[i - 2] and
           Stochastic.K[i] >= Stochastic.K[i + 1] and Stochastic.K[i] > Stochastic.K[i + 2] then
           return i;
        end
    end
    return nil;
end
