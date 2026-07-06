-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68183

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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

--[[

Indicator based on Shay Campbells’ E-Mini Swing Trading System where he uses a technique to enter the market based on pull backs of the price based upon a Moving Average Distribution indicator.

Using a very short moving average of median price does a good job of defining a usable equilibrium point. 

 A distribution can then be calculated around that equilibrium by subtracting the equilibrium point from the market price.

To normalize these readings for volatility, this result is then divided by the recent daily range of price.

Buy Signal=  Trend Direction is Up (6 to 9 month Mov Ave) and the MA Distribution registers a significant Pullback, i.e, negative value.
Sell Signal=  Trend Direction is Down and the MA Distribution registers a significant Pullback, i.e, positive value.”
]]


-- Indicator profile initialization routine

function Init()
    indicator:name("Moving Average Distribution");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("1. MA Calculation"); 
    indicator.parameters:addInteger("Period1", "Period", "", 20, 2, 2000);
 
	
	indicator.parameters:addGroup("ADX Calculation"); 
    indicator.parameters:addInteger("Period2", "Period", "", 20, 2, 2000); 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period1;
local Period2; 
local first;
local source = nil;
 
local Oscillator;  
 

local Range;
-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    Period1= instance.parameters.Period1; 
    
	
	Period2= instance.parameters.Period2;
 
	
	
	local Parameters= Period1   ..  ", " ..Period2 ;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    Range= instance:addInternalStream(0, 0);
			
    source = instance.source;
    first=source:first()+math.max(Period1, Period2); 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",instance.parameters.Up, first); 
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
    
	Range[period]=source.high[period]-source.low[period];
	
    
	
    if period < first then
	return;
	end
	
	local ATR=mathex.avg(Range, period-Period2+1, period);

	local MA=mathex.avg(source.median, period-Period1+1, period);
	
	local diff=source.median[period]-MA;
	
    
	Oscillator[period]=(diff*100)/ATR;
	
	
	if Oscillator[period] > 0 then
	Oscillator:setColor(period, instance.parameters.Up);
	else
	Oscillator:setColor(period, instance.parameters.Down);
	end
	
	
	
				  
end
 
