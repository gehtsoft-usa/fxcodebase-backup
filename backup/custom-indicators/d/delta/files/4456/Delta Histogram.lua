-- Id: 14757
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2156

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

function Init()
    indicator:name("Delta Histogram");
    indicator:description("Delta Histogram");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Line Style");	 
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
local Price = nil;
local Delta = nil; 
local ROW;
local Up, Down;
 
-- Routine
function Prepare(nameOnly)
    
    source = instance.source;
    first = source:first(); 
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Size=instance.parameters.Size;
	 
    local name = profile:id() .. "(" .. source:name()  .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	ROW= instance:addInternalStream(first, 0);
    Price = instance:addInternalStream(first+1, 0);
	Delta = instance:addInternalStream(first+1, 0);
	
    Histogram = instance:addStream("Histogram", core.Bar, name .. ".Histogram", "Histogram", instance.parameters.Up, first+1);
    Histogram:setPrecision(math.max(2, instance.source:getPrecision()));
	
end
 
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    
	if period < first or not  source:hasData(period) then
	return;
	end
	
	ROW[period]=(source.close[period]+source.open[period]+source.high[period]+source.low[period])/4;
	
			 
	if period < first+1 then
	return;
	end		
			   local DIV = math.log10(ROW[period-1]/ROW[period]);
			
				 Price[period] = ROW[period];		
			   
				 Delta[period] =  ROW[period] + DIV;
		 
                 Histogram[period]=Price[period]-Delta[period]; 
				 
				 if Histogram[period] > 0 then
				 Histogram:setColor(period, Up);
				 else
				 Histogram:setColor(period, Down);
                 end

end