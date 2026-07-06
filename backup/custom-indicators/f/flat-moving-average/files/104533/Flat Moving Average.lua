-- Id: 15350

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63088

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Flat Moving Average");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Price" , "Data Source", "", "close");
    indicator.parameters:addStringAlternative("Price" , "Open", "", "open");
    indicator.parameters:addStringAlternative("Price", "High", "", "high");
    indicator.parameters:addStringAlternative("Price" , "Low", "", "low");
	indicator.parameters:addStringAlternative("Price" , "Close", "", "close");
	indicator.parameters:addStringAlternative("Price", "Median", "", "median");
    indicator.parameters:addStringAlternative("Price" , "Typical", "", "typical");
	indicator.parameters:addStringAlternative("Price" , "Weighted ", "", "weighted");	
 
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");	
	
    indicator.parameters:addInteger("Period", "MA Period", "Period" , 14);
	
	 indicator.parameters:addDouble("Delta", "Stong / Weak Delta (in Pips)", "Delta" , 10);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("StrongUp", "Strong Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("StrongDown", "Strong Down Trend Color", "", core.rgb(255, 0, 0));	
	indicator.parameters:addColor("Weak", "Weak Trend color", "", core.rgb(128,128, 128));
 
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Weak, StrongUp, StrongDown;
local first;
local source = nil;

local Price;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local Period, Method  ;
 
local MA, Delta;

function Prepare(nameOnly)

    Weak= instance.parameters.Weak;
	StrongUp= instance.parameters.StrongUp;
    StrongDown= instance.parameters.StrongDown;
    Delta= instance.parameters.Delta;
    Period = instance.parameters.Period;
	Price = instance.parameters.Price;
	Method= instance.parameters.Method; 

	source = instance.source; 
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. source:barSize()..", ".. Price..", " .. Method .. ", " .. Method
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA=core.indicators:create(Method,  source[Price], Period);
	first= MA.DATA:first();

    	
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
			open:setColor(period, Weak);	
			return;
			end
	
 
	
			   MA:update(mode);
			   
	 
		
		 
		
		if math.abs(((MA.DATA[period]-MA.DATA[period-1])/source:pipSize()))< Delta then
		open:setColor(period,Weak);	   
		else
			if MA.DATA[period]-MA.DATA[period-1] > 0  then
			open:setColor(period,StrongUp);
			else
			open:setColor(period,StrongDown);
			end		
		end
		
				

		
 end


