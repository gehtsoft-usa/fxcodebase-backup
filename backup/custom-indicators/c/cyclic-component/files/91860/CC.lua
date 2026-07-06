-- Id: 10815

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60180

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
    indicator:name("Cyclic Component");
    indicator:description("Cyclic Component");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Length", "Length", "Length", 20);
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("CC_color", "Color of CC", "Color of CC", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Length;

local first;
local source = nil;

-- Streams block
local CC = nil;
local alpha,HP;
-- Routine
function Prepare(nameOnly)
    Length = instance.parameters.Length;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Length) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        HP = instance:addInternalStream(0, 0);
        alpha= (1 - math.sin (2* math.pi  / Length)) / math.cos(2* math.pi / Length);
        first = source:first()+3;
        CC = instance:addStream("CC", core.Line, name, "CC", instance.parameters.CC_color, first);
    CC:setPrecision(math.max(2, instance.source:getPrecision()));
		CC:setWidth(instance.parameters.width);
        CC:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
   
    HP[period] = 0.5*(1 + alpha)*(source[period] - source[period-1]) + alpha*HP[period-1];
	
 
	if period == source:first() then
	CC[period]=0; 
	elseif  period == source:first()+1 then	
	CC[period]=source[period]-source[period-1]; 
	else
	CC[period]  = (HP[period] + 2*HP[period-1] + 2*HP[period-2] + HP[period-3]) / 6;
	end
	
	 
end

--[[
alpha = (1 - Sine (360 / Length)) / Cosine(360 / Length);
HP = .5*(1 + alpha)*(Price - Price[1]) + alpha*HP[1];
SmoothHP = (HP + 2*HP[1] + 2*HP[2] + HP[3]) / 6;
IF CurrentBar < 4 Then SmoothHP = Price - Price[1];
IF CurrentBar = 1 THEN SmoothHP = 0;
]]
