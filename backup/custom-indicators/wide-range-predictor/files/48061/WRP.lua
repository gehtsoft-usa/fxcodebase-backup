-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27461
-- Id: 8041

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
    indicator:name("WideRangePredictor");
    indicator:description("WideRangePredictor");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
     indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 10);
	 indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Range_Up", "Color of Range Up", " ", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Range_Down", "Color of Range Down", " ", core.rgb(200, 0, 0));
	indicator.parameters:addColor("Range_MA", "Color of Body MA", " ", core.rgb(0, 0, 255));
	
    indicator.parameters:addColor("Body_Up", "Color of Body Up", " ", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Body_Down", "Color of Body Down", " ", core.rgb(0, 200, 0));
	indicator.parameters:addColor("Body_MA", "Color of Body MA", " ", core.rgb(0, 0, 255));
	
    indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of Neutral", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;

-- Streams block
local Range = nil;
local Body = nil;
local range, body;
local Neutral;
local Range_Up, Range_Down;
local Body_Up, Body_Down;
local Up, Down;
local Range_MA, Body_MA;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Range_MA = instance.parameters.Range_MA;
	Body_MA = instance.parameters.Body_MA;
	Range_Up = instance.parameters.Range_Up;
	Range_Down = instance.parameters.Range_Down;
    Body_Up = instance.parameters.Body_Up;
	Body_Down = instance.parameters.Body_Down;
    source = instance.source;
	Neutral = instance.parameters.Neutral;	 
	 
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Range = instance:addStream("Range", core.Bar, name .. ".Range", "Range", Neutral, first);
    Range:setPrecision(math.max(2, instance.source:getPrecision()));
        Body = instance:addStream("Body", core.Bar, name .. ".Body", "Body", Neutral, first);
    Body:setPrecision(math.max(2, instance.source:getPrecision()));
		
		range = core.indicators:create("MVA", Range, Period);
	    body = core.indicators:create("MVA", Body, Period);
		
		Up = instance:addStream("Range_MA", core.Line, name .. ".Range_MA", "Range_MA", Range_MA, range.DATA:first() );
    Up:setPrecision(math.max(2, instance.source:getPrecision()));
		Down = instance:addStream("Body_MA", core.Line, name .. ".Body_MA", "Body_MA",Body_MA, body.DATA:first());
    Down:setPrecision(math.max(2, instance.source:getPrecision()));
       
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


     if period < first   then 
	return;
	end

    Range:setColor(period, Neutral);
	Body:setColor(period, Neutral);
  
	
   Range[period] = source.high[period] - source.low[period];
   Body[period] = math.abs(source.close[period]-source.open[period]);
   

   
    range:update(mode);
	body:update(mode);
	
	if period < range.DATA:first() then
	 return;
	end
	
	Up[period]=range.DATA[period];
	Down[period]=body.DATA[period];
	
	if Range[period] > range.DATA[period] then
	Range:setColor(period, Range_Up);
	else
	Range:setColor(period, Range_Down);
	end

  
    if Body[period] > body.DATA[period] then
	Body:setColor(period, Body_Up);
    else
	Body:setColor(period, Body_Down);
    end	
end

