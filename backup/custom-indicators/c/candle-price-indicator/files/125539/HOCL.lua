function Init()

    indicator:name("HOCL");
    indicator:description("High Open Close Low");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Indicators");
    indicator.parameters:addString("Stream", "Stream", "" , "Last");
    indicator.parameters:addStringAlternative("Stream", "Live", "" , "Live");
    indicator.parameters:addStringAlternative("Stream", "Last", "" , "Last");
    indicator.parameters:addBoolean("ShowPrices", "HOCL prices", "", true);
    indicator.parameters:addBoolean("ShowDistance", "HOCL distance", "HL: Total candle U: Upper shadow D: Down shadow", true);

end

local Stream;
local ShowPrices;
local ShowDistance;

local source = nil;
local first;
local PIPSIZE;

function Prepare(nameOnly)

	Stream = instance.parameters.Stream;
    ShowPrices = instance.parameters.ShowPrices;
	ShowDistance = instance.parameters.ShowDistance;

    source = instance.source;
    first = source:first();
    PIPSIZE = source:pipSize();

    local name = source:name();
    instance:name(name);
	
	if (nameOnly) then
        return;
    end

end

function Update(period)

    if period < first or (not source:hasData(period)) then
        return;
    end

    local candle;
    local textToShow = "";

    if (Stream == "Last") then
    	candle = period - 1;
    else
    	candle = period;
    end

    local high = source.high[candle];
    local open = source.open[candle];
    local close = source.close[candle];
    local low = source.low[candle];

    if (ShowPrices) then
        
        textToShow = "H:" .. high .. " O: " .. open .. " C: " .. close .. " L: " .. low .. " ";

    end

    if (ShowDistance) then

    	local shadowUp;
	    local shadowDown;
        local highlow;

        highlow = pipsDifference(high, low);

	    if close >= open then
	    	shadowUp = pipsDifference(high, close);
	    	shadowDown = pipsDifference(open, low);
	    else
	    	shadowUp = pipsDifference(high, open);
	    	shadowDown = pipsDifference(close, low);
	    end

	    textToShow = textToShow .. "HL:" .. highlow .. " U:" .. shadowUp .. " D:" .. shadowDown;

    end

    core.host:execute("setStatus", textToShow);

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