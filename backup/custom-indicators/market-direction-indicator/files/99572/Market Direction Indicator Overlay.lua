-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62066


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
    indicator:name("Market Direction Indicator Overlay");
    indicator:description("Market Direction Indicator Overlay");
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
	
	indicator.parameters:addInteger("lenMA1", "Short Length", "Short Length", 13);
    indicator.parameters:addInteger("lenMA2", "Long Length", "Long Length", 55);
    indicator.parameters:addInteger("cutoff", "No-trend cutoff", "No-trend cutoff", 2);
	indicator.parameters:addBoolean("sbz", "Show Below Zero", "Show Below Zero", false);
	 
	 
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Neutral_color", "Color of Neutral", "Color of Neutral", core.rgb(128, 128, 128));
	indicator.parameters:addColor("UpUp_color", "Color of Up in Up Trend", "Color of Up Trend", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DownUp_color", "Color of Down in Up Trend", "Color of Up Trend", core.rgb(50,205,50));
	indicator.parameters:addColor("UpDown_color", "Color of Up in Down Trend", "Color of Down Trend", core.rgb(255, 0, 0));
	indicator.parameters:addColor("DownDown_color", "Color of Down in Down Trend", "Color of Down Trend", core.rgb(255, 153, 0));

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local lenMA1;
local lenMA2;
local cutoff;
local sbz;
local first;
local source = nil;
local Price;
-- Streams block
local mdi = nil;
local cp;
 
local open=nil;
local close=nil;
local high=nil;
local low=nil;
 
 

-- Routine
function Prepare(nameOnly) 
    lenMA1 = instance.parameters.lenMA1;
    lenMA2 = instance.parameters.lenMA2;
	Price = instance.parameters.Price;
    cutoff = instance.parameters.cutoff;
	sbz = instance.parameters.sbz;
    source = instance.source;
	first = source:first()+math.max(lenMA1, lenMA2);

	
	

    local name = profile:id() .. "(" .. source:name()  .. ", " .. tostring(Price) .. ", " .. tostring(lenMA1) .. ", " .. tostring(lenMA2) .. ", " .. tostring(cutoff) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
 
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), source:first())
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), source:first())
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), source:first())
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), source:first())
    instance:createCandleGroup("ZONE", "", open, high, low, close); 
 
	
   
        cp = instance:addInternalStream(0, 0);
		mdi = instance:addInternalStream(0, 0);		
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
   

    high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	
	
	
	
		
    if period < first or not source:hasData(period) then
	open:setColor(period, instance.parameters.Neutral_color);
	return;
	end
    
   
	cp[period]=Calculate(period);
    
	if sbz then
	mdi[period] =math.abs(100*( cp[period-1] - cp[period])/((source[Price][period]+source[Price][period-1])/2));
	else
	mdi[period] =100*( cp[period-1] - cp[period])/((source[Price][period]+source[Price][period-1])/2);
	end
	
	local Color;
	
	if mdi[period]<-cutoff then
		 if  mdi[period]>mdi[period-1] then
		 Color=instance.parameters.UpDown_color;
		 else
		 Color=instance.parameters.DownDown_color;
		 end
	elseif mdi[period]>cutoff then
		 if  mdi[period]>mdi[period-1] then
		 Color=instance.parameters.UpUp_color;
		 else
		 Color=instance.parameters.DownUp_color;
		 end
	else
	Color=instance.parameters.Neutral_color;
	end
    open:setColor(period, Color);
end


function Calculate(period)
return lenMA1*(mathex.sum(source[Price], period-lenMA2+1, period)) - lenMA2*(mathex.sum(source[Price], period-lenMA1+1, period)) / (lenMA2-lenMA1);
end
 