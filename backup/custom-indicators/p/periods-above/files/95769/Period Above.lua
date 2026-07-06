-- Id: 12420
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61114

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
    indicator:name("Period Above");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
   
   
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("PA_Up", "Color of PA Up", "Color of PA", core.rgb(0, 255, 0));
	indicator.parameters:addColor("PA_Down", "Color of PA Down", "Color of PA", core.rgb(255, 0, 0));

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period,Method;
local MA;
local first;
local source = nil;

-- Streams block
local PA = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Method= instance.parameters.Method;
    source = instance.source;
    

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(Method)  .. ")";
    instance:name(name);

    if (not (nameOnly)) then
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
		MA = core.indicators:create(Method, source,Period);
		first = MA.DATA:first();
        PA = instance:addStream("PA", core.Bar, name, "PA", instance.parameters.PA_Up, first);
    PA:setPrecision(math.max(2, instance.source:getPrecision()));
		 
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    MA:update(mode);
	
    if period < first or not source:hasData(period) then
	return;
	end
	
	    if source[period]> MA.DATA[period] then
		 PA[period] = PA[period-1]+1;
		elseif source[period]< MA.DATA[period] then
		 PA[period] = PA[period-1]-1;
		end
	
	
	if (source[period]> MA.DATA[period] and source[period-1]< MA.DATA[period-1])	
	then
	PA[period]=1;
	elseif (source[period]< MA.DATA[period] and source[period-1]> MA.DATA[period-1])
	then
	PA[period]=-1;
	end
	
	if    PA[period] >0 then 
	PA:setColor(period, instance.parameters.PA_Up);	
	else
	PA:setColor(period, instance.parameters.PA_Down);	
	end
    
end

