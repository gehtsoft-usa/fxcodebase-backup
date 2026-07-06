-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59655

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
    indicator:name("Time Averaged Price");
    indicator:description("Time Averaged Price");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");

    indicator.parameters:addInteger("Period", "Period", "Period", 0, 0, 2000);
	
	indicator.parameters:addString("Price", "Period Price Source", "", "median");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
	
 
	
	indicator.parameters:addGroup("Style");

    indicator.parameters:addColor("MA_color", "Color of TAP", "Color of TAP", core.rgb(255, 0, 0));
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
local MaPeriod;
local Price;
local first;
local source = nil;
local Method;
-- Streams block
local   Raw 

-- Routine
function Prepare(nameOnly)
    Period =  instance.parameters.Period;
	Method = instance.parameters.Method;
	Price = instance.parameters.Price;
    MaPeriod = instance.parameters.MaPeriod;
    source = instance.source;
	 
	
	 
   

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(Price) .. ")";
    instance:name(name);
	
	Period=Period+1;
	
	 first = source:first()+Period;

    if   (nameOnly) then
        return;
    end
        Raw = instance:addStream("TAP", core.Line, name, "TAP", instance.parameters.MA_color, first);
		Raw:setWidth(instance.parameters.width);
        Raw:setStyle(instance.parameters.style);
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period )

    if period < first then
	return;
	end
	local min, max;
	
	min,max= mathex.minmax(source, period-Period+1 , period )
	
	if Price == "median" then
	Raw[period]= (min+max)/2;
	elseif Price == "typical" then
	Raw[period]= (min+max+source.close[period])/3;
	elseif Price == "weighted" then
	Raw[period]= (min+max+source.close[period]*2)/4;
	elseif Price == "open" then
	Raw[period]= source.open[period-Period+1];
	elseif Price == "close" then
	Raw[period]= source.close[period];
	elseif Price == "high" then
	Raw[period]= max;
	elseif Price == "low" then
	Raw[period]= min;
	end
 
	
	
     
    
 
end

