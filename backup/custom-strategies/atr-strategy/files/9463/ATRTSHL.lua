--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("ATR Trailing Stop (High/Low)");
    indicator:description("ATR Trailing Stop(High/Low)");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    --indicator.parameters:addDouble("P", "Percentage ", "Percentage ", 3);
	indicator.parameters:addInteger("AP", "ATR period ", "ATR Period ", 14);
	indicator.parameters:addDouble("AM", "ATR multiplicator ", "ATR multiplicator ", 3.5);
    indicator.parameters:addColor("PTS_color", "Color of PTS", "Color of PTS", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Multiplicator=nil;
local Frame=nil;

local first;
local source = nil;

-- Streams block
local PTS = nil;
local STOP;
local ATR=nil;


-- Routine
function Prepare()
    Multiplicator = instance.parameters.AM;
	Frame = instance.parameters.AP;
	source = instance.source;
    first = source:first();
	
	ATR= core.indicators:create("ATR", source, Frame);
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ", " .. Multiplicator .. ")";
    instance:name(name);
    PTS = instance:addStream("PTS", core.Line, name, "PTS", instance.parameters.PTS_color, first);
end

local direction = nil

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    -- Reset direction if
    if mode == core.UpdateAll then
        direction = nil
    end
    
    if period >= Frame and source:hasData(period) then
	
        ATR:update(mode);
        STOP=ATR.DATA[period] * Multiplicator;

        if direction == nil then
            direction = (source.open[period] < source.close[period]) and 'u' or 'd'
            PTS[period] = (direction == 'u') and (source.close[period] + STOP) or (source.close[period] - STOP)
        else
            if source.low[period] < PTS[period-1] and  source.low[period-1] > PTS[period-1] then
               direction = 'u'
               PTS[period] = source.close[period]+STOP;
            elseif source.high[period] > PTS[period-1] and  source.high[period-1] < PTS[period-1] then
               direction = 'd' 
               PTS[period] = source.close[period]-STOP;
            else
                if direction == 'u' then
                    PTS[period]= math.min(PTS[period-1],source.close[period]+STOP);					
                elseif direction == 'd' then
                    PTS[period]= math.max(PTS[period-1],source.close[period]-STOP);
                end
            end
        end
    end	
	
end
