-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2775
-- Id: 2420

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

function Init()
    indicator:name("ROC Trend Oscillator");
    indicator:description("ROC Trend Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("One", "1. ROC  Period", "No description", 14,2, 2000);
    indicator.parameters:addInteger("Two", "2. Period", "No description", 21,2, 2000);
    indicator.parameters:addColor("Up_color", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down_color", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local One;
local Two;

local first;
local source = nil;
local DATA={};

-- Streams block
local Up = nil;
local Down = nil;
local RAW;

-- Routine
function Prepare(nameOnly)
    One = instance.parameters.One;
    Two = instance.parameters.Two;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. One .. ", " .. Two .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	DATA[1] = core.indicators:create("ROC", source, One);
	DATA[2] = core.indicators:create("ROC", source, Two);
	
	first = math.max(DATA[1].DATA:first(),DATA[2].DATA:first())+1;
	
	RAW=instance:addInternalStream(source:first(), 0);
    Up = instance:addStream("Up", core.Bar, name .. ".Up", "Up", instance.parameters.Up_color, first);
    Up:setPrecision(math.max(2, instance.source:getPrecision()));
    Down = instance:addStream("Down", core.Bar, name .. ".Down", "Down", instance.parameters.Down_color, first);
    Down:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period >= first and source:hasData(period) then
	
	DATA[1]:update(mode);
	DATA[2]:update(mode);
	
			 
			RAW[period]= DATA[1].DATA[period] - (0 - DATA[2].DATA[period]);
			
					if  RAW[period] > RAW[period-1] then
					Up[period] = RAW[period];
					Down[period] = nil;
					else
					Up[period] = nil;
					Down[period] = RAW[period];
					end
			
		 
        
    end
end

