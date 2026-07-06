-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3729
-- Id: 18107

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
    indicator:name("Tick Time Frame TImed Cumulative Price Bar");
    indicator:description("Tick Time Frame Timed Cumulative Price Bar");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	 indicator:setTag("replaceSource", "t");
    indicator.parameters:addGroup("Calculation"); 

    indicator.parameters:addInteger("DurationOf", "Duration of Candle in seconds", "Duration in seconds", 100);
  
	

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;

-- Streams block

local DurationOf;
local open, close, high, low;
-- Routine
function Prepare(nameOnly)
    DurationOf = instance.parameters.DurationOf;

    source = instance.source;
    first=source:first();
	
	local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    
     if (not (nameOnly)) then
		open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    open:setPrecision(math.max(2, instance.source:getPrecision()));
		high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    high:setPrecision(math.max(2, instance.source:getPrecision()));
		low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    low:setPrecision(math.max(2, instance.source:getPrecision()));
		close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    close:setPrecision(math.max(2, instance.source:getPrecision()));
		instance:createCandleGroup("ZONE", "", open, high, low, close);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


    if period <= first then
	return;
	end
	
	
	local P1, P2;
    local One=1/86400;
	P1= core.findDate (source, source:date(period)-One*DurationOf, false);
	
	 
	if P1==-1 
	or P1< first+1 
	or P1 >= period 
    then
    return;
    end
	
	    min,max=mathex.minmax (source, P1 , period);
        open[period] =  source[P1];
		close[period] = source[period]
		high[period] =  max;
		low[period] =   min;
 

		 
end
 