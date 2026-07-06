-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3925
-- Id: 3653

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
    indicator:name("Difference");
    indicator:description("Difference");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	
  	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("K", "Number of periods", "", 1, 0, 1000);
	
	indicator.parameters:addString("Method", "Method", "Method" , "Absolute");
    indicator.parameters:addStringAlternative("Method", "Absolute", "Absolute" , "Absolute");
    indicator.parameters:addStringAlternative("Method", "Relativ", "Relativ" , "Relativ");
	 
  
    indicator.parameters:addGroup("Style");   
    indicator.parameters:addColor("Up_color", "Color of Up Bar", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down_color", "Color of Down Bar", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local K;
local Type;
local Method;
local first;
local source = nil;

-- Streams block
local Difference;

-- Routine
function Prepare(nameOnly)
	K = instance.parameters.K;
	Method= instance.parameters.Method;
    source = instance.source;
   

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(K)  .. ", " .. tostring(Method)  ..")";
	                                              
    instance:name(name);
		
    first =source:first()+K+1;

	
    if (not (nameOnly)) then
        Difference = instance:addStream("Difference", core.Bar, name, "Difference", instance.parameters.Up_color, first);
    Difference:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not source:hasData(period) then
        return;
	end
	
	
	if Method == "Absolute" then
	Difference[period]=source[period] - source[period-K];
	else
	Difference[period]=(source[period] - source[period-K]) / (source[period-K]/100);
	end

	if Difference[period]> Difference[period-1] then
	   Difference:setColor(period, instance.parameters.Up_color);
	else
	   Difference:setColor(period, instance.parameters.Down_color);
	end
end

