-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&p=158539#p158539

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("RSI Divergence");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("N", "Periods for RSI Indicator ", "", 7);
	indicator.parameters:addBoolean("I", "Indicator mode", "Keep true value to display labels and lines. Set this parameter to false when the indicator is used in another indicator.", true);
    indicator.parameters:addGroup("Style");	 
    indicator.parameters:addColor("D_color", "Color of Divergence line", "", core.rgb(0, 155, 255));
    indicator.parameters:addColor("UP_color", "Color of Uptrend", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DN_color", "Color of Downtend", "", core.rgb(0, 255, 0));
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local I;
local DD;
local UP_color;
local DN_color;

local first;
local source = nil;

-- Streams block
local D = nil;
local UP = nil;
local DN = nil;
local RSI = nil;
local lineid = nil;

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    I = instance.parameters.I;
    DD = instance.parameters.DD;
    UP_color = instance.parameters.UP_color;
    DN_color = instance.parameters.DN_color;
    source = instance.source;
    RSI = core.indicators:create("RSI", source.close, N);
    first = RSI.DATA:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    D = instance:addStream("RSI", core.Line, name .. ".RSI", "RSI", instance.parameters.D_color, first, -1);
    D:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	D:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    D:setPrecision(math.max(2, instance.source:getPrecision()));
	
    if I then
        UP = instance:createTextOutput ("Up", "Up", "Wingdings", 10, core.H_Center, core.V_Top, instance.parameters.UP_color, -1);
        DN = instance:createTextOutput ("Dn", "Dn", "Wingdings", 10, core.H_Center, core.V_Bottom, instance.parameters.DN_color, -1);
    else
        UP = instance:addStream("UP", core.Bar, name .. ".UP", "UP", instance.parameters.D_color, first, -1);
        DN = instance:addStream("DN", core.Bar, name .. ".DN", "DN", instance.parameters.D_color, first, -1);
		UP:setPrecision(math.max(2, instance.source:getPrecision()));
		DN:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

local pperiod = nil;
local pperiod1 = nil;
local line_id = 0;

-- Indicator calculation routine
function Update(period, mode)
    RSI:update(mode);
    
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

    --core.host:trace('Process ' .. core.formatDate(source:date(period)) .. ", mode = " .. mode)
    if period >= first then
        D[period] = RSI.DATA[period];
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
            if RSI.DATA[curr] > RSI.DATA[prev] and source.low[curr] < source.low[prev] then
                if I then
                    DN:set(curr, RSI.DATA[curr], "\225", "Classic bullish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), RSI.DATA[prev], source:date(curr), RSI.DATA[curr], DN_color);
                else
                    DN[period] = curr - prev;
                end
            elseif RSI.DATA[curr] < RSI.DATA[prev] and source.low[curr] > source.low[prev] then
                if I then
                    DN:set(curr, RSI.DATA[curr], "\225", "Reversal bullish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), RSI.DATA[prev], source:date(curr), RSI.DATA[curr], DN_color);
                else
                    DN[period] = -(curr - prev);
                end
            end
        end

    end
end

function isTrough(period)
    local i;
    if RSI.DATA[period] < 30 and RSI.DATA[period] < RSI.DATA[period - 1] and RSI.DATA[period] < RSI.DATA[period + 1] then
        for i = period - 1, first, -1 do
            if RSI.DATA[i] > 30 then
                return true;
            elseif RSI.DATA[period] > RSI.DATA[i] then
                return false;
            end
        end
    end
    return false;
end

function prevTrough(period)
    local i;
    for i = period - 5, first, -1 do
        if RSI.DATA[i] <= RSI.DATA[i - 1] and RSI.DATA[i] < RSI.DATA[i - 2] and
           RSI.DATA[i] <= RSI.DATA[i + 1] and RSI.DATA[i] < RSI.DATA[i + 2] then
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
            if RSI.DATA[curr] < RSI.DATA[prev] and source.high[curr] > source.high[prev] then
                if I then
                    UP:set(curr, RSI.DATA[curr], "\226", "Classic bearish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), RSI.DATA[prev], source:date(curr), RSI.DATA[curr], UP_color);
                else
                    UP[period] = curr - prev;
                end
            elseif RSI.DATA[curr] > RSI.DATA[prev] and source.high[curr] < source.high[prev] then
                if I then
                    UP:set(curr, RSI.DATA[curr], "\226", "Reversal bearish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), RSI.DATA[prev], source:date(curr), RSI.DATA[curr], UP_color);
                else
                    UP[period] = -(curr - prev);
                end
            end
        end

    end
end

function isPeak(period)
    local i;
    if RSI.DATA[period] > 70 and RSI.DATA[period] > RSI.DATA[period - 1] and RSI.DATA[period] > RSI.DATA[period + 1] then
        for i = period - 1, first, -1 do
            if RSI.DATA[i] < 70 then
                return true;
            elseif RSI.DATA[period] < RSI.DATA[i] then
                return false;
            end
        end
    end
    return false;
end

function prevPeak(period)
    local i;
    for i = period - 5, first, -1 do
        if RSI.DATA[i] >= RSI.DATA[i - 1] and RSI.DATA[i] > RSI.DATA[i - 2] and
           RSI.DATA[i] >= RSI.DATA[i + 1] and RSI.DATA[i] > RSI.DATA[i + 2] then
           return i;
        end
    end
    return nil;
end
-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&p=158539#p158539

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