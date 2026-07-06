-- Id: 4500
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6235

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

function Init()
    indicator:name("Fast Forward");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	 
	 indicator.parameters:addGroup("Bar Color");
	 indicator.parameters:addColor("UP", "Up Trend ", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("DOWN", "Down Trend ", "", core.rgb(255, 0, 0));
	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block


local first;
local source = nil;

-- Streams block
local HZU = nil;
local HZL = nil;

local open=nil;
local close=nil;
local high=nil;
local low=nil;

local UP;
local DOWN;


-- Routine
function Prepare(nameOnly)
  	
	UP = instance.parameters.UP;
	DOWN = instance.parameters.DOWN;		
	
    source = instance.source;	
	first =source:first();	    

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
   
	
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    open:setPrecision(math.max(2, instance.source:getPrecision()));
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    high:setPrecision(math.max(2, instance.source:getPrecision()));
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    low:setPrecision(math.max(2, instance.source:getPrecision()));
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    close:setPrecision(math.max(2, instance.source:getPrecision()));
    instance:createCandleGroup("ZONE", "ZONE", open, high, low, close);
	
	
end

-- Indicator calculation routine
function Update(period, mode)

   local Up, Down;
   Up=math.max(source.close[period], source.open[period]);
   Down=math.min(source.close[period], source.open[period]);
   
   local Top, Bottom;
   
   Top= math.abs(source.high[period] - Up) ;
   Bottom= math.abs(source.low[period] - Down);
   
   
        if Top > Bottom then
		open[period]= math.max(open[period-1], close[period-1]);
		else	
		open[period]= math.min(open[period-1], close[period-1]);
		end	
  
      if  source.open[period] < source.close[period] then
     close[period]= open[period] - math.abs(   source.open[period] - source.close[period])  ;	  
     else
	  close[period]=open[period] + math.abs(   source.open[period] - source.close[period])  ;	
	 end
	 
	high[period]=  math.max(open[period], close[period]) + Top;
	low[period]=  math.min(open[period], close[period]) - Bottom;		


	if  source.open[period] < source.close[period] then
	open:setColor(period, UP);
	else
	open:setColor(period, DOWN);
	end	  
end

