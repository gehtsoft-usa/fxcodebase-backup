-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Volume Adjusted Moving Average");
    indicator:description("Volume Weighted Moving Average (VWAP or VAMA) ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("Frame", "Period", "Period", 4);
    indicator.parameters:addColor("VAMA_color", "Color of VAMA", "Color of VAMA", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame;

local first;
local source = nil;



-- Streams block
local PriceTimesVolume;
local VAMA = nil;

-- Routine
function Prepare()
    Frame = instance.parameters.Frame;
    source = instance.source;
    first = source:first();
	
	PriceTimesVolume = instance:addInternalStream(first,0);
	VOLUME = instance:addInternalStream(first,0);

    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ")";
    instance:name(name);
    VAMA = instance:addStream("VAMA", core.Line, name, "VAMA", instance.parameters.VAMA_color, first);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period >= first and source:hasData(period) then
	
	PriceTimesVolume[period]=source.close[period] *source.volume[period];
	   
	    if period > Frame +1 then 
        VAMA[period] = core.sum(PriceTimesVolume,core.rangeTo (period, Frame))/core.sum(source.volume,core.rangeTo (period, Frame));
		end
    end
end

