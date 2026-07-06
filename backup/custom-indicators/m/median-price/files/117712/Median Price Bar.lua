-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65724

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
    indicator:name("Median Price Bar");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("replaceSource", "t");
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Median Period", "", 3, 2, 2000);
	
	indicator.parameters:addString("Method", "Method", "Method" , "S");
    indicator.parameters:addStringAlternative("Method", "Sort function", "Calculates the median value using sort function." , "S");
    indicator.parameters:addStringAlternative("Method", "Wirth's Kth-minimum function", "Calculates the median value using Wirth's Kth-minimum function." , "W");
 
end

 
 
local source;
local first;
local open, high, low, close;
local Open, High, Low, Close;

local Period,Method;

local Method=nil;

 
local Color;

-- initializes the instance of the indicator
function Prepare(onlyName)


    source=instance.source;

    Period = instance.parameters.Period;
	Method= instance.parameters.Method;
	
	   local name = profile:id() .. "(" .. source:name() .. ", "  .. Period .. ", " .. Method .. ")";
    instance:name(name);
	

    if onlyName then
        return ;
    end
	
    assert(core.indicators:findIndicator("MEDIAN PRICE") ~= nil, "Please, download and install MEDIAN PRICE.LUA indicator");
	
	Open = core.indicators:create("MEDIAN PRICE", source.open, Period);
    Close = core.indicators:create("MEDIAN PRICE", source.close, Period);
	High= core.indicators:create("MEDIAN PRICE", source.high, Period);
	Low = core.indicators:create("MEDIAN PRICE", source.low, Period);
    first = Open.DATA:first();	

 
    
 
    open = instance:addStream("open", core.Dot, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Dot, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Dot, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Dot, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "ZONE", open, high, low, close);
  
end

function Update(period, mode)
  
Open:update(mode);
High:update(mode);
Low:update(mode);
Close:update(mode);
 
  	if period < first  or not source:hasData(period) then 
    return;
    end 
	
 open[period]=Open.DATA[period];
 high[period]=High.DATA[period];
 low[period]=Low.DATA[period];
 close[period]=Close.DATA[period];
 
 
  
  
          
				   
end
