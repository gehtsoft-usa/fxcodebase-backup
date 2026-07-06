-- Id: 13466
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61734

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
    indicator:name("Price MA position Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("MA Calculation");	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	  
	indicator.parameters:addInteger("Period", "MA Period ", "", 10, 1, 2000);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	 
 
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Color of Up in Uptrend", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UpDn", "Color of Down in Up Trend", "", core.rgb(0, 200, 0))
	indicator.parameters:addColor("DnUp", "Color of Up in Down Trend", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Dn", "Color of  Down in Down Trend", "", core.rgb(200, 0, 0));
	indicator.parameters:addColor("NoUp", "Color of Up in Neutral Trend", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("NoDown", "Color of Down in Neutral Trend", "", core.rgb(0, 0, 200));
	
	indicator.parameters:addGroup("Line Style");
	indicator.parameters:addColor("Color", "Color of MA Line", "", core.rgb(128, 128, 128));
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil; 

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local Show;
local Out;
local Indicator;
local Period ;
local Method
local Price;
local Color;
function Prepare(nameOnly)
  
	Show = instance.parameters.Show;
	 
	
	One= instance.parameters.One;
	Two= instance.parameters.Two;
	 
	source = instance.source;
	
	local name = profile:id() .. "(" .. source:name() 	..  ")";
	instance:name(name); 
	if nameOnly then
		return;
	end
 
	first=   source:first() ;

	Price= instance.parameters.Price;
	Period= instance.parameters.Period;
	Method= instance.parameters.Method;
	Color= instance.parameters.Color;
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	Indicator=core.indicators:create(Method,  source[Price] , Period);
	first=math.max(first,Indicator.DATA:first());
	
		 
		Out = instance:addStream("OUT", core.Line, name, "MA",  Color, Indicator.DATA:first());
		 

    	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)
	
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
	  
	Indicator:update(mode);	
	Out[period]=Indicator.DATA[period];
	 
	
   if period < first then
   open:setColor(period, instance.parameters.No);
   return;
   end
	 
		              if  source.close[period] > Out[period]
					  and source.low[period] > Out[period]
					  then 
							 if source.close[period]>source.open[period] then
							  open:setColor(period, instance.parameters.Up);	
							 else
							 open:setColor(period, instance.parameters.UpDn);	
							 end
					  elseif  source.close[period] < Out[period]
					  and source.high[period] < Out[period]
					  then
							 if source.close[period]>source.open[period] then
							 open:setColor(period, instance.parameters.DnUp);	
							 else
							 open:setColor(period, instance.parameters.Dn);	
							 end
					  else
		                    if source.close[period]>source.open[period] then
							 open:setColor(period, instance.parameters.NoUp);	
							 else
							 open:setColor(period, instance.parameters.NoDown);	
							 end
					  end
					  
		 
 end


