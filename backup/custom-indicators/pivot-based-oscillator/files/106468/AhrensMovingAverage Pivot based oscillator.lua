-- Id: 16120
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63526

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
    indicator:name("Pivot based oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period1", "Period", "Period",13); 
	
	
	indicator.parameters:addInteger("Period2", "Period", "Period",21); 
	
	
	indicator.parameters:addInteger("Period3", "Period", "Period",34); 
	
	indicator.parameters:addGroup("Style");	 
    indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb(0, 255, 0));	
    indicator.parameters:addColor("Down", "Color of Up", "Color of Down", core.rgb(255, 0, 0));

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period1 , ma1;
local Period2 , ma2;
local Period3 , ma3;
local PP;
local first;
local source = nil;
local Up, Down;
-- Routine
function Prepare(nameOnly)
    Period1 = instance.parameters.Period1; 
	Period2 = instance.parameters.Period2; 
	Period3 = instance.parameters.Period3; 
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;	
	
	assert(core.indicators:findIndicator("AHRENS MOVING AVERAGE") ~= nil, "Please, download and install AHRENS MOVING AVERAGE.LUA indicator");
	
    source = instance.source;
	
	
	local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
    if   (nameOnly) then
        return;
    end
	
	
	ma1 = core.indicators:create("AHRENS MOVING AVERAGE", source, Period1);
	ma2 = core.indicators:create("AHRENS MOVING AVERAGE", source, Period2);
	ma3 = core.indicators:create("AHRENS MOVING AVERAGE", source, Period3);
    first = math.max(ma1.DATA:first(),ma2.DATA:first(),ma3.DATA:first()); 
 

  
        PP = instance:addStream("PP", core.Bar, name .. ".PP", "PP", Up, first ); 
  
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    
	ma1:update(mode);
	ma2:update(mode);
	ma3:update(mode);
	
    if period < first or not source:hasData(period) then
	return;
	end
	
	local Differential1= ma1.DATA[period]-ma3.DATA[period];
	local Differential2= ma2.DATA[period]-ma3.DATA[period];
	local Differential3= ma1.DATA[period]-ma2.DATA[period];
 
	 
        PP[period] = (Differential1+Differential2+Differential3)/3;
		
		if PP[period]>PP[period-1] then
		PP:setColor(period, Up);
		else
		PP:setColor(period, Down);
		end
		
    
end

