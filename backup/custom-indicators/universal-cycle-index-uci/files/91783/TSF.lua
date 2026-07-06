-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60163

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Time Series Forecast");
    indicator:description("Time Series Forecast");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
	
    indicator.parameters:addInteger("Period", "Period", "Period", 5);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("TSF_color", "Color of TSF", "Color of TSF", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Volatility_color", "Color of Volatility", "Color of Volatility", core.rgb(255, 0, 0));
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

local first;
local source = nil;

-- Streams block
local TSF = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first()+Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        TSF = instance:addStream("TSF", core.Line, name, "TSF", instance.parameters.TSF_color, first);
		TSF:setWidth(instance.parameters.width);
        TSF:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first   then
	return;
	end

    local  A, B;
	
        A,B = LinReg(Period, source, period);
        TSF[period] =  B + (A * (Period - 1 - Period));
    
end


function LinReg(nLRlen, aArray, period)  
    local xSum = 0;
    local ySum = 0;
    local i = 0;
	
    for i = 0, nLRlen-1, 1 do
   	xSum = xSum+ i;
    ySum = ySum + aArray[period-i];
    end
	
	
    local  xAvg = xSum/nLRlen;
    local yAvg = ySum/nLRlen;
    local aSum1 = 0;
    local aSum2 = 0;
   
    for i = 0, nLRlen-1, 1 do
        aSum1 =aSum1+ (i-xAvg) * (aArray[period-i]-yAvg); 
        aSum2 =aSum2 + (i-xAvg)*(i-xAvg);
    end
	
    local  A = (aSum1 / aSum2);    
    local  B = yAvg - (A*xAvg);   
    
    return A, B;
end

