-- Id: 12160
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60926

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
    indicator:name("Aroon Horn");
    indicator:description("Aroon Horn");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 10);
	indicator.parameters:addDouble("Filter", "Filter", "Filter", 25);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb(0,255,0));
	indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255,0,0));
    indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of Neutral", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Filter;
local first;
local source = nil;
local Neutral,Up,Down;
-- Streams block
local AH = nil;
local Aroon;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Filter= instance.parameters.Filter;
	Neutral= instance.parameters.Neutral;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Filter)  .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Aroon = core.indicators:create("AROON", source, Period);
        first = Aroon.DATA:first();
        AH = instance:addStream("AH", core.Bar, name, "AH", Neutral, first);
		AH:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    Aroon:update(mode);
	
	 
	 
    if period < first  then
	return;
	end
	
	
    AH[period] =Aroon.UP[period] - Aroon.DOWN[period];
	 
	 
	         if ((AH[period] >= 0) and (AH[period] > Filter)) then
           
               AH:setColor(period,Up);
            elseif ((AH[period] < 0) and (AH[period] < (-1) * Filter)) then
            
               AH:setColor(period,Down);
            else
            
               AH:setColor(period,Neutral);
           end
           
end

