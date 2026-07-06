-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66692
 

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
    indicator:name("Corrected T3 average");
    indicator:description("Corrected T3 average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 10);
	 indicator.parameters:addDouble("Hot", "Hot", "Hot", 0.7);
	 
	indicator.parameters:addGroup("Style");	
 
    indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Average Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Average Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addInteger("width2", "CA Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "CA Line style", "", core.LINE_DASH);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Hot;

local first;
local source = nil;
 
-- Streams block
local CA , Average;

local EMA1, EMA2, EMA3, EMA3, EMA5, EMA6;
local b, b2, b3, c1, c2, c3, c4; 
local Up, Down;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period; 
    Hot = instance.parameters.Hot;
    source = instance.source;
    
	
	 

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Hot) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	
	
	 b = Hot;
	 b2 = (b * b);
	 b3 = (b * b * b);
	 
	 c1 = -b3;
	 c2 = (3 * b2) + (3 * b3);
	 c3 = (-6 * b2) - (3 * b) - (3 * b3);
	 c4 = 1 + (3 * b) + b3 + (3 * b2);

 
        EMA1 = core.indicators:create("EMA", source, Period);
		EMA2 = core.indicators:create("EMA", EMA1.DATA, Period);
		EMA3 = core.indicators:create("EMA", EMA2.DATA, Period);
		EMA4 = core.indicators:create("EMA", EMA3.DATA, Period);
		EMA5 = core.indicators:create("EMA", EMA4.DATA, Period);
		EMA6 = core.indicators:create("EMA", EMA5.DATA, Period);
		
		first = EMA6.DATA:first();
		
	    
		
        Average = instance:addStream("Average", core.Line, name, "Average", Up, first);
		Average:setWidth(instance.parameters.width1);
        Average:setStyle(instance.parameters.style1);
		
		CA = instance:addStream("CA", core.Line, name, "Average", Down, first);
		CA:setWidth(instance.parameters.width2);
        CA:setStyle(instance.parameters.style2);
		
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    
	
	 
	EMA1:update(mode);
	EMA2:update(mode);
	EMA3:update(mode);
	EMA4:update(mode);
	EMA5:update(mode);	
	EMA6:update(mode);
	
	
	if period <  first then
	return;
	end
	
	Average[period]= c1 * EMA6.DATA[period] + c2 * EMA5.DATA[period] + c3 * EMA4.DATA[period] + c4 * EMA3.DATA[period];
	
	local Std = mathex.stdev (source, period-Period+1, period);
	local v1= math.pow  (Std ,2);
    local v2= math.pow ( (CA[period-1] - Average[period]),2);
    
	
      local  k=0;
	  
	  if  v2<v1  or v2==0  then
      k=0;
	  else
	  k=1-v1/v2;
	  end
	  
    CA[period]=CA[period-1]+k*(Average[period]-CA[period-1]);   
	
	
	if Average[period]>CA[period] then
	CA:setColor(period, Up);
	Average:setColor(period, Up);
	else
	CA:setColor(period, Down);
	Average:setColor(period, Down);
	end
    
end
 