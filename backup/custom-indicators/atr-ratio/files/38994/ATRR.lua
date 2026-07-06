-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=22601
-- Id: 7175

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
    indicator:name("ATR Ratio");
    indicator:description("ATR Ratio");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "First Period", " ", 2);
    indicator.parameters:addInteger("Period2", "Second Period", " ", 7);
	indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("Ratio_color", "Color of Ratio", "Color of Ratio", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period1;
local Period2;

local first;
local source = nil;
local One, Two;
-- Streams block
local Ratio = nil;

-- Routine
function Prepare(nameOnly)
    Period1 = instance.parameters.Period1;
    Period2 = instance.parameters.Period2;
    source = instance.source;
   

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period1) .. ", " .. tostring(Period2) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        One = core.indicators:create("ATR", source, Period1);
        Two = core.indicators:create("ATR", source, Period2);
        
         first = math.max(One.DATA:first(),Two.DATA:first());
        Ratio = instance:addStream("Ratio", core.Line, name, "Ratio", instance.parameters.Ratio_color, first);
		Ratio:setWidth(instance.parameters.width);
	    Ratio:setStyle(instance.parameters.style);
		
		Ratio:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not source:hasData(period) then
	return;
	end
	  One:update(mode);
	  Two:update(mode);
	  Ratio[period] = (One.DATA[period]/ Two.DATA[period])*100;
		
end

