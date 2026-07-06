-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68671

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


-- Indicator profile initialization routine

function Init()
    indicator:name("MACD Histogram Reversal");
    indicator:description("");
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
	
	
    indicator.parameters:addInteger("Period1", "Short Period", "", 12, 1, 2000);
    indicator.parameters:addInteger("Period2", "2. Period", "", 26, 1, 2000);	
    indicator.parameters:addInteger("Period3", "3. Period", "", 9, 1, 2000);
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Size", "", 15);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period1,Period2,Period3,Price; 
local first;
local source = nil;
local up, down;
local MACD;
local Size;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
	Period3= instance.parameters.Period3;
	Price= instance.parameters.Price;
	Size= instance.parameters.Size;
	
	
	local Parameters= Price..", ".. Period1..", "..Period2..", "..Period3;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	MACD = core.indicators:create("MACD", source[Price], Period1, Period2, Period3 );
    first=MACD.HISTOGRAM:first() ;
	
    up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom , instance.parameters.Up, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Down, 0);
	
end

-- Indicator calculation routine
function Update(period, mode)

    MACD:update(mode);
	
	if period < source:first() 	
	then
	return;
	end
	
	
	  down:setNoData(period);
      up:setNoData(period);
	  
	  
	 -- Potential Buy Reversal: Candle 2 closes above Candle 1 but paints a LOWER histogram value. 

      --Potential Sell Reversal: Candle 2 closes below Candle 1 but paints a HIGHER histogram value.
	  
	  if source.close[period] >  source.high[period-1] 
	  and MACD.HISTOGRAM[period] < MACD.HISTOGRAM[period-1]
	  then
	  up:set(period , source.low[period], "\217", source.low[period]);
	  
	  elseif source.close[period] <  source.low[period-1] 
	   and MACD.HISTOGRAM[period] > MACD.HISTOGRAM[period-1]
	  then
	  down:set(period , source.high[period], "\218", source.high[period-1]);
	  
	  end
				  
end
