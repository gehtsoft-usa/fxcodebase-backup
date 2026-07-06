-- More information about this indicator can be found at:
-- http://fxcodebase.com

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("The Fibonacci time retracement");
    indicator:description("The indicator lets you define the time lines in Fibonacci's level terms");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addString("D", "Date", "The date to draw the 0 line", "mm/dd/yyyy");
    indicator.parameters:addString("T", "The time to draw the 0 line", "", "hh:mm");
    indicator.parameters:addInteger("N", "Number of bars ", "", 0);
    indicator.parameters:addBoolean("S", "Show Labels ", "", true);
    indicator.parameters:addDouble("L1", "The line", "Set -1 to do not draw the line", 0);
    indicator.parameters:addDouble("L2", "The line", "Set -1 to do not draw the line", 0.382);
    indicator.parameters:addDouble("L3", "The line", "Set -1 to do not draw the line", 0.5);
    indicator.parameters:addDouble("L4", "The line", "Set -1 to do not draw the line", 0.618);
    indicator.parameters:addDouble("L5", "The line", "Set -1 to do not draw the line", 0.786);
    indicator.parameters:addDouble("L6", "The line", "Set -1 to do not draw the line", 1);
    indicator.parameters:addDouble("L7", "The line", "Set -1 to do not draw the line", 1.272);
    indicator.parameters:addDouble("L8", "The line", "Set -1 to do not draw the line", 1.382);
    indicator.parameters:addDouble("L9", "The line", "Set -1 to do not draw the line", 1.5);
    indicator.parameters:addDouble("L10", "The line", "Set -1 to do not draw the line", 1.618);
    indicator.parameters:addDouble("L11", "The line", "Set -1 to do not draw the line", 2);
    indicator.parameters:addDouble("L12", "The line", "Set -1 to do not draw the line", 2.618);
    indicator.parameters:addColor("color", "Color of lines", "Color of D", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local D;
local T;
local N;
local L1;
local lines = {};
local candle = nil;
local color;

local first;
local source = nil;

-- Streams block
local DUMMY = nil;
local pdate = "(%d%d?)/(%d%d?)/(%d%d?%d?%d?)";
local ptime = "(%d%d?):(%d%d?)";
local barSize;


-- Routine
function Prepare(nameOnly)
    color = instance.parameters.color;
    D = instance.parameters.D;
    T = instance.parameters.T;
    N = instance.parameters.N;
    S = instance.parameters.S;

    source = instance.source;
    first = source:first();

    local l, e;
    l, e = core.getcandle(source:barSize(), 0, 0);
    barSize = e - l;

    local i;
    for i = 1, 12, 1 do
        lines[i] = instance.parameters:getDouble("L" .. i);
    end

    -- parse date/time
    local t = {};
    local a, b, c;
    if D == "mm/dd/yyyy" then
        a = 1;
        b = 1;
        c = 1;
    else
        a, b, c = string.match(D, pdate);
    end
    assert (a ~= nil, "Can't recognize the date");
    t.day = tonumber(b);
    t.month = tonumber(a);
    t.year = tonumber(c);
    if t.year < 80 then
        t.year = t.year + 2000;
    elseif t.year >= 80 and t.year < 100 then
        t.year = t.year + 1900;
    end
    if T == "hh:mm" then
        a = 0;
        b = 0;
    else
        a, b = string.match(T, ptime);
    end

    local name = profile:id() .. "(" .. source:name() .. ", " .. D .. " " .. T .. ", " .. N .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    assert(a ~= nil, "Can't recognize the time");
    t.hour = tonumber(a);
    t.min = tonumber(b);
    t.sec = 0;
    candle = core.tableToDate(t);
    candle = core.host:execute("convertTime", 4, 1, candle);

    DUMMY = instance:addStream("D", core.Line, name, "D", color, first);
end

local prevCandle = nil;

-- Indicator calculation routine
function Update(period, mode)


 if period < source:size() - 1 then
 return;
 end
  
 
    if prevCandle ~= nil and source:serial(period) == prevCandle then
        return ;
    else
        prevCandle = source:serial(period);
    end
	
	

   
        local p = core.findDate (source, candle, false);
        if p == -1 then
		return;
		end
		
		
            local h, l;
            l, h = mathex.minmax(source,period-p+1, period);
            local i;
            for i = 1, 12, 1 do
                if lines[i] >= 0 then
                    local bar = p + math.floor(N * lines[i]);
                    local date;
                    if bar >= source:size() then
                        date = source:date(period) + (bar - source:size() + 1) * barSize;
                    else
                        date = source:date(bar);
                    end
                    core.host:execute("drawLine", i, date, l, date, h, color);
                    if S then
                        core.host:execute("drawLabel", i, date, h, " " .. lines[i]);
                    end
                end
            end
       
end
 