-- Id: 15016

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62656

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
    indicator:name("Volume Indicator");
    indicator:description("Volume Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of Up", "Color of Volume", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down", "Color of Volume", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of Volume", core.rgb(0, 0, 255));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local first;
local source = nil;

-- Streams block
local Volume = nil;
 
local Up,Down,Neutral;
-- Routine
function Prepare(nameOnly)
     
	Up = instance.parameters.Up;
	Down = instance.parameters.Down; 
	Neutral = instance.parameters.Neutral;
    source = instance.source;
	 
    first = source.close:first();
	
 

    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
        Volume = instance:addStream("Volume", core.Bar, name, "Volume", Up, first); 
    Volume:setPrecision(math.max(2, instance.source:getPrecision()));
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

     
	
	if period < first or not  source:hasData(period) then
	return;
	end
	
 
        Volume[period] = source.volume[period];
		
		if Volume[period]>  Volume[period-1] then
			
			Volume:setColor(period, Up);
			
		elseif Volume[period]<  Volume[period-1] then
		   
			Volume:setColor(period, Down);
		else
		    Volume:setColor(period, Neutral);
		end
    
end

