-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63162

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
    indicator:name("Wide Range Body Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Lookback", "Lookback Period ", "Period", 14);
	indicator.parameters:addDouble("MinimumSize", "Minimum Body Size in Pips", "Minimum Size", 0);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of Up Candle", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down Candle", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Color of Neutral Candle", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("Candle", "Wide Range Body Candle", "", core.rgb(0, 0, 255));
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;
local MinimumSize;
-- Streams block
local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
local Up,Down,Candle,Neutral;
-- Routine
function Prepare(nameOnly)
	MinimumSize= instance.parameters.MinimumSize;
	Lookback= instance.parameters.Lookback;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Candle= instance.parameters.Candle;
	Neutral= instance.parameters.Neutral;
    source = instance.source;
    first = source:first()+Lookback;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Lookback).. ", " .. tostring(MinimumSize) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	Range = instance:addInternalStream(0, 0); 	 

    open = instance:addStream("open", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("high", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("low", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("close", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
	if period < first then
	open:setColor(period,Neutral);
	return;
	end
	
	Range[period]=source.high[period]-source.low[period];
	max=mathex.max(Range,period-Lookback, period-1);
	
			 
  			
			
	
	if  Range [period]> max then
    open:setColor(period,Candle);
	else
	    if close[period]> open[period]then
		 open:setColor(period,Up);
		else
		 open:setColor(period,Down);
		end
		
	end

end

