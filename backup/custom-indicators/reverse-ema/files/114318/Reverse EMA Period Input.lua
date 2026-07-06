-- Id: 18862

-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=65010

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Reverse EMA");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 10); 
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("color", "Line Color", "Line Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local AA,CC;
local first;
local source = nil;
local RE1,RE2,RE3,RE4,RE5,RE6,RE7,RE8,EMA;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;

    AA = 2.0 / (Period + 1.0);
	CC = 1 - AA;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(AA).. ", " .. tostring(CC).. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
 
	EMA= instance:addInternalStream(0, 0);
	RE1= instance:addInternalStream(0, 0);
	RE2= instance:addInternalStream(0, 0);
	RE3= instance:addInternalStream(0, 0);
	RE4= instance:addInternalStream(0, 0);
	RE5= instance:addInternalStream(0, 0);
	RE6= instance:addInternalStream(0, 0);
	RE7= instance:addInternalStream(0, 0);
	RE8= instance:addInternalStream(0, 0);
 
	
 
	  
        Wave = instance:addStream("Wave", core.Line, name .. ".Wave", "Wave", instance.parameters.color, first);
    Wave:setPrecision(math.max(2, instance.source:getPrecision()));
		Wave:setWidth(instance.parameters.width);
        Wave:setStyle(instance.parameters.style);
		Wave:addLevel(0);   
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

--Classic EMA
EMA[period] = AA*source[period] + CC*EMA[period-1];

--Compute Reverse EMA
RE1[period] = CC*EMA[period] + EMA[period-1];
RE2[period] =  math.pow(CC, 2)*RE1[period] + RE1[period-1];
RE3[period] =  math.pow(CC, 4)*RE2[period] + RE2[period-1];
RE4[period] =  math.pow(CC, 8)*RE3[period] + RE3[period-1];
RE5[period] =  math.pow(CC, 16)*RE4[period] + RE4[period-1];
RE6[period] =  math.pow(CC, 32)*RE5[period] + RE5[period-1];
RE7[period] =  math.pow(CC, 64)*RE6[period] + RE6[period-1];
RE8[period] =  math.pow(CC, 128)*RE7[period] + RE7[period-1]


--Indicator as difference
Wave[period] = EMA[period] - AA*RE8[period];

end

 