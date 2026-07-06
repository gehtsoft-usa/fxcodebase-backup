-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64003

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
    indicator:name("EMA Trend Candle");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation");
	 indicator.parameters:addInteger("Period", "EMA Period", "", 15, 2, 1000);
 
	 indicator.parameters:addGroup("Price");
	indicator.parameters:addString("Price" , "Data Source", "", "close");
	indicator.parameters:addStringAlternative("Price" , "Close", "", "close");
    indicator.parameters:addStringAlternative("Price" , "Open", "", "open");
    indicator.parameters:addStringAlternative("Price", "High", "", "high");
    indicator.parameters:addStringAlternative("Price" , "Low", "", "low");
	indicator.parameters:addStringAlternative("Price", "Median", "", "median");
    indicator.parameters:addStringAlternative("Price" , "Typical", "", "typical");
	indicator.parameters:addStringAlternative("Price" , "Weighted ", "", "weighted");
	
	indicator.parameters:addStringAlternative("Price" , "Average (high+low+open+close)/4", "", "average");
	indicator.parameters:addStringAlternative("Price" , "Average median body (open+close)/2", "", "medianb");
	indicator.parameters:addStringAlternative("Price", "Trend biased price", "", "tbiased");
   
   
 
	indicator.parameters:addStringAlternative("Price" , "HA Close", "", "haclose");
    indicator.parameters:addStringAlternative("Price" , "HA Open", "", "haopen");
    indicator.parameters:addStringAlternative("Price", "HA High", "", "hahigh");
    indicator.parameters:addStringAlternative("Price" , "HA Low", "", "halow");
	indicator.parameters:addStringAlternative("Price", "HA Median", "", "hamedian");
    indicator.parameters:addStringAlternative("Price" , "HA Typical", "", "hatypical");
	indicator.parameters:addStringAlternative("Price" , "HA Weighted ", "", "haweighted");
	
		indicator.parameters:addStringAlternative("Price", "HA average", "", "haaverage");
    indicator.parameters:addStringAlternative("Price" , "HA median body", "", "hamedianb");
	indicator.parameters:addStringAlternative("Price" , "HA trend biased ", "", "hatbiased");
	
 
 
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.COLOR_UPCANDLE );
	indicator.parameters:addColor("Down", "Down color", "", core.COLOR_DOWNCANDLE );
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255));
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Up,Down, Neutral;
local first;
local source = nil;

local Price;
local Raw;
local EMA;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
local HA;
local alpha;
function Prepare(nameOnly)

    Up = instance.parameters.Up;
    Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;
   
    Period = instance.parameters.Period;
	Price = instance.parameters.Price;
	alpha = 2.0 / (1.0+Period);
	 
	source = instance.source; 
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. source:barSize()..", ".. Period..  ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	HA = core.indicators:create("HA", source);
	first= source.close:first();
	
	Raw = instance:addInternalStream(first, 0);
    EMA = instance:addInternalStream(first, 0);
    	
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
		
		HA:update(mode);
		
		if period < first then
		open:setColor(period, Neutral);
		return;
		end
	 
	    Raw[period]=  GetPrice(period);
	   
 
         EMA[period] = EMA[period-1]+alpha*(Raw[period]-EMA[period-1]);
				
       if  Raw[period] >   EMA[period] then
	   open:setColor(period, Up);
	   elseif  Raw[period] <   EMA[period] then
	   open:setColor(period, Down);
	   else
	    open:setColor(period, Neutral);
	   end
	   
	   
		
 end
 
 function GetPrice(period)
 
            if Price == "haclose" then
			return(HA.close[period]);
			elseif Price =="haopen" then
			return(HA.open[period]);
            elseif Price == "hahigh" then    
			return(HA.high[period]);
            elseif Price == "halow"  then     
			return(HA.low[period]);
            elseif Price == "hamedian" then   
			return((HA.high[period]+HA.low[period])/2.0);
            elseif Price == "hamedianb" then  
			return((HA.open[period]+HA.close[period])/2.0);
            elseif Price == "hatypical" then  
			return((HA.high[period]+HA.low[period]+HA.close[period])/3.0);
            elseif Price == "haweighted" then
			return((HA.high[period]+HA.low[period]+HA.close[period]+HA.close[period])/4.0);
            elseif Price == "haaverage" then  
			return((HA.high[period]+HA.low[period]+HA.close[period]+HA.open[period])/4.0);
            elseif Price == "hatbiased" then
               if (HA.close[period]>HA.open[period]) then
                     return((HA.high[period]+HA.close[period])/2.0);
               else
			        return((HA.low[period]+HA.close[period])/2.0); 
               end  
			 elseif Price == "average" then
	         return((source.high[period]+low[period]+source.close[period]+source.open[period])/4.0);
	         elseif Price == "medianb" then		     
			 return((source.open[period]+source.close[period])/2.0);
             elseif Price == "tbiased"  then 
			 
             if (source.close[period]>source.open[period]) then
             return((source.high[period]+source.close[period])/2.0);
             else  
			 return((source.low[period]+source.close[period])/2.0);
             end
			   
			   
            else
			       return source[Price][period];
			end   
 end
  
 
	  
       
 