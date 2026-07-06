-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=13772

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("TRENDADVISOR Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	
		
	indicator.parameters:addGroup("MA Calculation");
	indicator.parameters:addInteger("SP", "Short MA Period", "", 50, 2, 1000);
    indicator.parameters:addInteger("LP", "Long MA Period", "", 200, 2, 1000);	 	 

	 indicator.parameters:addGroup("Price");
	indicator.parameters:addString("Price" , "Data Source", "", "close");
    indicator.parameters:addStringAlternative("Price" , "Open", "", "open");
    indicator.parameters:addStringAlternative("Price", "High", "", "high");
    indicator.parameters:addStringAlternative("Price" , "Low", "", "low");
	indicator.parameters:addStringAlternative("Price" , "Close", "", "close");
	indicator.parameters:addStringAlternative("Price", "Median", "", "median");
    indicator.parameters:addStringAlternative("Price" , "Typical", "", "typical");
	indicator.parameters:addStringAlternative("Price" , "Weighted ", "", "weighted");	

	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn", "Down color", "", core.rgb(255, 0, 0));
   
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


local SP, LP;
local Short;
local Long;

local One, Two, Three;


 function Prepare(nameOnly) 
 
    SP= instance.parameters.SP;
	LP= instance.parameters.LP;   
	Price = instance.parameters.Price;	
	 
	source = instance.source;
	
	    local name = profile:id() .. "(" .. source:name() ..", ".. SP ..", ".. LP.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
		
	if (LP <= SP) then
       error("The short MA period must be smaller than long MA period");
    end
	
	
	
		Short=core.indicators:create("MVA",  source[Price], SP);
	    Long=core.indicators:create("MVA",  source[Price], LP);
		

   

	
	
	first= math.max(Short.DATA:first(), Long.DATA:first() );

    	
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
	
			if period < first then
			return;
			end
		
			   Short:update(mode);
			   Long:update(mode);
			   

local Condition;


--	/* Phase filter */
if ( source.close[period] > Short.DATA[period])
and not  (source.close[period] > Long.DATA[period] )
and not  (Short.DATA[period] > Long.DATA[period] )
then
 Condition= 1;
elseif  (source.close[period] > Short.DATA[period])
and   (source.close[period] > Long.DATA[period] )
and not  (Short.DATA[period] > Long.DATA[period] )
then
 Condition= 2;
elseif  (source.close[period] > Short.DATA[period])
and   (source.close[period] > Long.DATA[period] )
and   (Short.DATA[period] > Long.DATA[period] )
then
 Condition= 3;
elseif  not (source.close[period] > Short.DATA[period])
and   (source.close[period] > Long.DATA[period] )
and   (Short.DATA[period] > Long.DATA[period] )
then
 Condition= 4;
elseif  not (source.close[period] > Short.DATA[period])
and  not (source.close[period] > Long.DATA[period] )
and   (Short.DATA[period] > Long.DATA[period] )
then
 Condition= 5;
elseif  not (source.close[period] > Short.DATA[period]) 
and not  (source.close[period] > Long.DATA[period] )
and  not (Short.DATA[period] > Long.DATA[period] )
then
 Condition= 6;
end
		   
		if Condition < 4     then		
		open:setColor(period, instance.parameters.Up);
        else
		open:setColor(period, instance.parameters.Dn);		
		end
		
		
				

		
 end


