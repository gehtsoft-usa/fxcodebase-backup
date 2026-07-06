-- Id: 8279
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=28103

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Reverse Engineering RSI");
    indicator:description("Reverse Engineering RSI");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("WildPer", "Period", "Period", 14);
	indicator.parameters:addDouble("value3", "OB Level", "Level", 70);
	indicator.parameters:addDouble("value1", "Central Level", "Level", 50);
	indicator.parameters:addDouble("value2", "OS", "Level", 30);
	
	
   indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("color1", "Color of 1. Line", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("color2", "Color of 2. Line", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("color3", "Color of 3. Line", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local WildPer; 
local first;
local source = nil;

-- Streams block
local L1, L2, L3 ;
local K, ExpPer;
local AUC,ADC;

local value1 = 50;
local value2 = 30;
local value3 = 70;
 
-- Routine
function Prepare(nameOnly)
    WildPer = instance.parameters.WildPer;
    value = instance.parameters.value;
    source = instance.source;
	value1= instance.parameters.value1;
	value2= instance.parameters.value2;
	value3= instance.parameters.value3;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(WildPer)   .. ")";
    instance:name(name);
	
	ExpPer = 2 * WildPer - 1;	
	K = 2 / (ExpPer + 1);
	
    
    if (not (nameOnly)) then
		AUC = instance:addInternalStream(0, 0);
		ADC = instance:addInternalStream(0, 0);
        L1 = instance:addStream("L1", core.Line, name .. value1, value1, instance.parameters.color1, first);
		L1:setWidth(instance.parameters.width1);
        L1:setStyle(instance.parameters.style1);
        L2 = instance:addStream("L2", core.Line, name .. value2, value2, instance.parameters.color2, first);
		L2:setWidth(instance.parameters.width2);
        L2:setStyle(instance.parameters.style2);
        L3 = instance:addStream("L3", core.Line, name .. value3, value3, instance.parameters.color3, first);	
		L3:setWidth(instance.parameters.width3);
        L3:setStyle(instance.parameters.style3);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first   then
	return;
	end
      
 
	
	if(source[period] > source[period-1]) then
		AUC[period] = K * (source[period] - source[period-1]) + (1 - K) * AUC[period-1];
		ADC[period] = (1 - K) * ADC[period-1];	 
	else 
		AUC[period] = (1 - K) * AUC[period-1];
		ADC[period] = K * (source[period-1] - source[period]) + (1 - K) * ADC[period-1];
	end
	
		
	local x1 = (WildPer - 1) * (ADC[period] * value1 / (100 - value1) - AUC[period]);
	
	if(x1 >= 0) then 
		L1[period]  = source[period] + x1;
	else
		L1[period] =  source[period] + x1 * (100 - value1) / value1;
	end	
	
	
	local x2 = (WildPer - 1) * (ADC[period] * value2 / (100 - value2) - AUC[period]);
	
	if(x2 >= 0) then 
		L2[period]  = source[period] + x2;
	else
		L2[period] =  source[period] + x2 * (100 - value2) / value2;
	end

    local x3 = (WildPer - 1) * (ADC[period] * value3 / (100 - value3) - AUC[period]);
	
	if(x3 >= 0) then 
		L3[period]  = source[period] + x3;
	else
		L3[period] =  source[period] + x3 * (100 - value3) / value3;
	end		
	
	
	 
end

