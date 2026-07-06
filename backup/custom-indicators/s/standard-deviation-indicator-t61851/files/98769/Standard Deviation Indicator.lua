-- Id: 13648
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61851

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
    indicator:name("Standard Deviation Indicator");
    indicator:description("Standard Deviation Indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addString("Time", "Time for indicator", "Should be in the next format: hh:mm:ss", "00:30:00");
    indicator.parameters:addColor("STDDEV_color", "Color of STDDEV", "Color of STDDEV", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Time;

local first;
local source = nil;

-- Streams block
local STDDEV = nil;

-- Parses timespan in format hh:mm:ss
function parseTimespan(timespan)
    local hours, minutes, seconds = string.match(timespan, "(%d%d):(%d%d):(%d%d)");
    assert(hours ~= nil and minutes ~= nil and seconds ~= nil, "The time should be in the next format: hh:mm:ss");
    return hours / 24 + minutes / 1440 + seconds / 86400;
end

local timespan;

-- Routine
function Prepare(nameOnly)
    Time = instance.parameters.Time;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Time) .. ")";
    instance:name(name);
    
    timespan = parseTimespan(instance.parameters.Time);

    if (not (nameOnly)) then
        STDDEV = instance:addStream("STDDEV", core.Line, name, "STDDEV", instance.parameters.STDDEV_color, first);
    STDDEV:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

function getDatePeriod(fromDate)
    local fromDatePeriod = core.findDate(source, fromDate, false);
    if fromDatePeriod < 0 then
        return nil;
    end
    
    local fromDays, fromTime = math.modf(fromDate);
    local fromDateMs = math.floor(fromTime * 86400000 + 0.5);
    
    local foundDays, foundTime = math.modf(source:date(fromDatePeriod));
    local foundDateMs = math.floor(foundTime * 86400000 + 0.5);
    if foundDateMs < fromDateMs then
        return fromDatePeriod + 1;
    end
    return fromDatePeriod;
end

-- Indicator calculation routine
function Update(period)
    if period < first or not  source:hasData(period) then
	return;
	end
	
        local fromDate = source:date(period) - timespan;
        local fromDatePeriod = getDatePeriod(fromDate);
		
        if fromDatePeriod == nil 
		or  fromDatePeriod <= 0 
        or fromDatePeriod < source:first()  
		then
		return;
        end        
		STDDEV[period] = mathex.stdev(source, core.range(fromDatePeriod, period)) * (source[period] - source[fromDatePeriod]);
        
    
end
