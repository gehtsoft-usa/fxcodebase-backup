-- Id: 2001
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2438

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
    indicator:name("RSI Price Overlay");
    indicator:description("RSI Price Overlay");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
    indicator.parameters:addInteger("Period", "RSI Period", "", 14, 2, 1000);
	
	indicator.parameters:addGroup("Levels");
	indicator.parameters:addDouble("Buy", "Buy Level", "", 50);
	indicator.parameters:addDouble("Sell", "Sell Level", "", 50);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of Neutral", core.rgb(128, 128, 128));
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Price;
local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
local Up,Down,Neutral;

local Period; 
local RSI = nil;
local Buy,Sell;

function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Price= instance.parameters.Price;
	source = instance.source;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Neutral= instance.parameters.Neutral; 
	Buy= instance.parameters.Buy;
	Sell= instance.parameters.Sell;
	
      
    local name = profile:id() .. "(" .. source:name() ..", ".. Price..", ".. Period.. ")";
    instance:name(name);
	if nameOnly then
		return;
	end
	RSI=core.indicators:create("RSI",  source[Price], Period);
	
	first= RSI.DATA:first();
	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("MACD", "MACD", open, high, low, close);
	 
		
end

-- Indicator calculation routine
function Update(period, mode)
    
 
		
		 RSI:update(mode);
		   
		open[period]=source.open[period]
		close[period]=source.close[period];
		high[period]=source.high[period];
		low[period]=source.low[period];	                   
		   
		   if period < RSI.DATA:first() or not RSI.DATA:hasData(period)then
		   open:setColor(period, Neutral);
		   return;
		   end
		   
					
						 
							if RSI.DATA[period] > Buy then 	
							open:setColor(period, Up); 
							elseif RSI.DATA[period] < Sell then 
                            open:setColor(period, Down); 							
							else
							open:setColor(period, Neutral); 
							end
							
						 
	 
end				