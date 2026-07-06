-- Id: 908
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1338

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

function Init()
    indicator:name("Range Bar Oscilator");
    indicator:description("Generates a signal when the bar openes/closes above / below one third of Range");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("U", "Color of Up Bar", "Color of Up Bar", core.rgb(0, 0, 255));
     indicator.parameters:addColor("D", "Color of Down Bar", "Color of Down Bar", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local UPC=nil
local DOWNC=nil;


local first;
local source = nil;

local Range;


-- Streams block
local up =nil;
local down=nil;
local neutral=nil;

-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	
	UPC=instance.parameters.U;
	DOWNC=instance.parameters.D;
	
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. "1/3" .. ")";		
    instance:name(name);
    if nameOnly then
        return;
    end
   
	up=instance:addStream("UP", core.Bar, name .. ". UP BAR", "UP BAR", UPC, first);
    up:setPrecision(math.max(2, instance.source:getPrecision()));
	down=instance:addStream("DOWN", core.Bar, name .. "DOWN BAR", "DOWN BAR", DOWNC, first);
    down:setPrecision(math.max(2, instance.source:getPrecision()));
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period >= first and source:hasData(period) then
	
	   	 Range=(source.high[period] - source.low[period])/3;
		
		up[period]= nil;
		down[period]= nil;
		
		
         if source.open[period] <  source.low[period] + Range and source.close[period] >  source.high[period] - Range then 	 
          up[period]= 1;
	 
		 end
		 
		 if source.open[period] >  source.high[period] - Range  and source.close[period] <  source.low[period] + Range then 	
		  down[period]=1;
		 
		 end 
    end
end