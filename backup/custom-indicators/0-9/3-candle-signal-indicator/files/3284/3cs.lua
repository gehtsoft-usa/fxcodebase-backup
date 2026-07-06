-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1648


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
    indicator:name("3 candle indicator");
    indicator:description("3 candle indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addBoolean("Now", "Show current period", "Show current period", true);
    indicator.parameters:addGroup("Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "Arrow Size", 20);
    indicator.parameters:addColor("Top", "Color of Bullish bar", "Color of Bullish bar", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Bottom", "Color of Bearish bar", "Color of Bearish bar", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Now;
local Size;
-- Streams block
local up, down;

-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	Now= instance.parameters.Now;
	Size= instance.parameters.Size;

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    down = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Bottom, 0);
    up = instance:createTextOutput ("Down", "Down", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Top, 0);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
   	
	if Now then
	period=period-1;
	end
	
	if period < 3 or not  source:hasData(period) then	
	return;
	end
	
	
	
	down:setNoData (period);
	up:setNoData (period);
				             
							local Body= math.abs(source.close[period]-source.open[period]);	 
						   
							if  math.abs(source.close[period-2]-source.open[period-2]) < Body  and  math.abs(source.close[period-1]-source.open[period-1]) < Body then
							
									if source.close[period-1] < source.open[period-1]  and source.close[period] > source.open[period] then
									up:set(period, source.low[period], "\225"); 
									end
									
									if source.close[period-1] > source.open[period-1]  and source.close[period] < source.open[period] then
									down:set(period, source.high[period], "\226");						
									end
							end	
		 	
end

