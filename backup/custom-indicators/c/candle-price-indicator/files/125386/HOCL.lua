function Init()

    indicator:name("HOCL");
    indicator:description("High Open Close Low");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Indicators");
    indicator.parameters:addString("Stream", "Stream", "" , "Last");
    indicator.parameters:addStringAlternative("Stream", "Live", "" , "Live");
    indicator.parameters:addStringAlternative("Stream", "Last", "" , "Last");
    indicator.parameters:addBoolean("Shadow", "Show shadows", "U: Upper shadow D: Down shadow", true);

end

local Stream;
local Shadow;

local source = nil;
local first;

function Prepare(nameOnly)

	Stream = instance.parameters.Stream;
	Shadow = instance.parameters.Shadow;

    source = instance.source;
    first = source:first();

    local name = source:name();
    instance:name(name);
	
	if (nameOnly) then
        return;
    end

end

function Update(period)

    if period < first or (not source:hasData(period)) then
        return ;
    end

    local candle;

    if (Stream == "Last") then
    	candle = period - 1;
    else
    	candle = period;
    end

    local high = source.high[candle];
    local open = source.open[candle];
    local close = source.close[candle];
    local low = source.low[candle];

    local hocl = "H:" .. high .. " O: " .. open .. " C: " .. close .. " L: " .. low;

    if (Shadow) then

    	local shadowUp;
	    local shadowDown;

	    local size = source:pipSize();

	    if close >= open then
	    	shadowUp = pipsDifference(high, close);
	    	shadowDown = pipsDifference(open, low);
	    else
	    	shadowUp = pipsDifference(high, open);
	    	shadowDown = pipsDifference(close, low);
	    end

	    hocl = hocl .. " U:" .. shadowUp .. " D:" .. shadowDown;

    end

    core.host:execute("setStatus", hocl);

end

function pipsDifference(x, y)

	local FLOATPOSITION = 1
	local floatSize = source:pipSize();
	local difference = x - y;
	local result = difference / floatSize;
	local fixedNumber = fixFloat(result, FLOATPOSITION);

	return fixedNumber;
	
end

function fixFloat(number, floatNumber)

	local POWER = 10;
	local fixedNumber;

    floatNumber = POWER ^ floatNumber;
    fixedNumber = math.ceil(number * floatNumber) / floatNumber;

    return fixedNumber;

end