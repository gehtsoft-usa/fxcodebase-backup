-- Id: 1542
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2094

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
    indicator:name("Dynamic High/Low Band Overlay");
    indicator:description("Dynamic High/Low Band Overlay");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("Frame", "Look Back Periods", "No description", 14,2,2000);
    indicator.parameters:addDouble("Step", "Step", "Step", 0.7071, 0, 1);
    indicator.parameters:addColor("UP_color", "Color of Up", "Color of UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down_color", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame;
local Step;

local first;
local source = nil;

-- Streams block
local UP = nil;
local DOWN = nil;

-- Routine
function Prepare(nameOnly)
    Frame = instance.parameters.Frame;
    Step = instance.parameters.Step;
    source = instance.source;
    first = source:first()+Frame;

    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ", " .. Step .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    UP = instance:addStream("UP", core.Line, name .. ".Up", "Up", instance.parameters.UP_color, first);
    DOWN = instance:addStream("DOWN", core.Line, name .. ".Down", "Down", instance.parameters.Down_color, first);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period >= first and source:hasData(period) then
	
	    local Top, Bottom;
		local MAX,MIN;
		local RANGE;
		--local X,Y;
		RANGE=core.range(period-Frame,period);
		MAX,Top= core.max(source.high,RANGE);
		MIN,Bottom= core.min(source.low,RANGE);
		--X= period-Top;
		--Y=period-Bottom;
	
        UP[period]= MAX*Step - (MIN*Step)+MIN;            
		DOWN[period] =MAX-(MAX*Step-MIN*Step);
		
		
	    -- High Peak = ((highest[Y](High))*X - (lowest[Y](Low))*X)+lowest[Y](low)
        -- Low Peak = highest[Y](high)- ((highest[Y](High))*X-(lowest[Y](Low))*X)
		
    end
end

