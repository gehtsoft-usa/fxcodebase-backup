-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27632
-- Id: 8079

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Trigger Line");
    indicator:description("Trigger Line");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("length", "Period", "Period", 24);
    indicator.parameters:addInteger("lsma_length", "LSMA Period", "LSMA Period", 6);
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("wt_color", "Color of wt", "Color of wt", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("lsma_ma_color", "Color of lsma_ma", "Color of lsma_ma", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local  length, lsma_length;

local first;
local source = nil;
local lengthvar;
-- Streams block
local wt = nil;
local lsma_ma = nil;

-- Routine
function Prepare(nameOnly)
    length = instance.parameters.length;
    lsma_length = instance.parameters.lsma_length;
	
	 lengthvar = length + 1; 
     lengthvar = lengthvar /3; 
	
    source = instance.source;
    first = source:first()+length;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(length) .. ", " .. tostring(lsma_length) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        wt = instance:addStream("wt", core.Line, name .. ".wt", "wt", instance.parameters.wt_color, first);
		wt:setWidth(instance.parameters.width1);
        wt:setStyle(instance.parameters.style1);
        lsma_ma = instance:addStream("lsma_ma", core.Line, name .. ".lsma_ma", "lsma_ma", instance.parameters.lsma_ma_color, first);
		lsma_ma:setWidth(instance.parameters.width2);
        lsma_ma:setStyle(instance.parameters.style2);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first   then
	return;
	end
		 
	 local sum = 0, i;      
	 
         for i = length ,  1  , -1 do                     
         sum  =sum +   ( i - lengthvar)*source[period-length +i]; 
         end
		 
		  wt[period] = sum*6/(length*(length+1));          
         lsma_ma[period] = wt[period-1] + (wt[period]-wt[period-1])* 2/(lsma_length+1);

   
end

