-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=43376

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
    indicator:name("Inside Bar");
    indicator:description("Inside Bar");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

     indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Color of Up Candle", "", core.COLOR_UPCANDLE );
	indicator.parameters:addColor("Dn", "Color of Down Color", "", core.COLOR_DOWNCANDLE )
	indicator.parameters:addColor("UP", "Color of Inside Bar Up Candle ", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DN", "Color of Inside Bar Dn Candle ", "", core.rgb(0, 200, 0));
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;


local first;
local source = nil;

-- Streams block
 

-- Routine
function Prepare(nameOnly)
   
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);

    if (not (nameOnly)) then
    open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);    
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


    if period < first   then
	return;
	end
	
	open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
	if source.high[period] < source.high[period-1]  and source.low[period] >  source.low[period-1]  then
	   if source.close[period] > source.close[period-1] then		
		open:setColor(period, instance.parameters.UP);
		else
		open:setColor(period, instance.parameters.DN);
		end
	else
		if source.close[period] > source.close[period-1] then		
		open:setColor(period, instance.parameters.Up);
		else
		open:setColor(period, instance.parameters.Dn);
		end
	end				  
				
    
end

