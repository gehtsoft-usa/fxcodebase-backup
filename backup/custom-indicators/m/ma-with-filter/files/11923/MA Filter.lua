-- Id: 4170
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4807

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
    indicator:name("MA Filter");
    indicator:description("MA Filter");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("MA");
	indicator.parameters:addString("Method", "Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addInteger("PERIOD", "Period", "Averege  Period", 20);
	
	indicator.parameters:addGroup("Filter");
	indicator.parameters:addInteger("Shift", "Shift", "Shift", 0, 0, 2000);
	indicator.parameters:addInteger("MIN", "Min. Difference in Pips", "", 0);
	

	indicator.parameters:addGroup("Style");
	   indicator.parameters:addColor("UP", "Color of Up", "", core.rgb( 0, 255, 0));
    indicator.parameters:addColor("DOWN", "Color of Down", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("NEUTRAL", "Color of Neutral", "Color of Neutral", core.rgb(128, 128, 128));
	
	 indicator.parameters:addInteger("width","Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Method;
local PERIOD;
local Shift;
local UP,DOWN, NEUTRAL;
local MIN;

local first;
local source = nil;

-- Streams block
local MA = nil;


local Indicator;

-- Routine
function Prepare(nameOnly)
    MIN = instance.parameters.MIN;
    UP = instance.parameters.UP;
	DOWN = instance.parameters.DOWN;
	NEUTRAL = instance.parameters.NEUTRAL;
    PERIOD = instance.parameters.PERIOD;
    Method = instance.parameters.Method;
	Shift = instance.parameters.Shift;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. Method .. ", " .. PERIOD .. ", " .. Shift .. ", " .. MIN .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	Indicator= core.indicators:create(Method, source, PERIOD);
    first = Indicator.DATA:first()+math.abs(Shift)+1;
    MA = instance:addStream("MA", core.Line, name .. ".MA", "MA", core.rgb(255, 0, 0), first);
	MA:setWidth(instance.parameters.width);
    MA:setStyle(instance.parameters.style);
 
	
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

  

    if period < first or not source:hasData(period) then	
	return;
	end
	
	
	
	Indicator:update(mode);	
	
	MA[period] = Indicator.DATA[period];
	
	if Indicator.DATA[period] >  Indicator.DATA[period-Shift] and  math.abs(Indicator.DATA[period] -  Indicator.DATA[period-Shift]) >= MIN*source:pipSize() then
	MA:setColor(period, UP);	
	elseif Indicator.DATA[period] <  Indicator.DATA[period-Shift] and  math.abs(Indicator.DATA[period] -  Indicator.DATA[period-Shift] ) >= MIN*source:pipSize()  then
	MA:setColor(period, DOWN);	
	else
	MA:setColor(period, NEUTRAL);
	end
	
        
	
       
   
end

