-- Id: 16106

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63516

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
    indicator:name("Tick Histogram");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
 
    indicator.parameters:addInteger("Duration", "MA Duration in seconds", "MA Duration in seconds", 60);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;
-- Streams block
local Duration;
local Up, Down;
-- Routine
function Prepare(nameOnly)
    
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
    source = instance.source; 
	 first=source:first();
 
	local s, e;	
	 s, e = core.getcandle("m1", core.now(), 0, 0);
	 
    Duration= ((e - s)/60)*instance.parameters.Duration; 
	
  

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	 
    if   (nameOnly) then
        return;
    end
        Change = instance:addStream("Change", core.Bar, name .. ".Change", "Change",  Up, source:first()); 
    Change:setPrecision(math.max(2, instance.source:getPrecision()));
     
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
 
	
		local p= core.findDate (source, (source:date(period)-Duration), false);
	
	if p==-1
	or p< source:first()+1 
	or p> period
    then
    return;
    end 
	
		
       Change[period]= source[period]-source[p];
	   
	   if  Change[period]> 0 then
	   Change:setColor(period, Up);
	   else
       Change:setColor(period, Down);
	   end
	 
end
 