-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=9806

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
    indicator:name("MACD Overlay");
    indicator:description("MACD Overlay");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
     indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SN", "Short EMA", "(SN)No Description", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long EMA", "(LN)No Description", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal Line", "(IN)No Description", 9, 2, 1000);
	
	indicator.parameters:addString("Price", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price", "close", "", "close");
    indicator.parameters:addStringAlternative("Price", "open", "", "open");
    indicator.parameters:addStringAlternative("Price", "high", "", "high");
    indicator.parameters:addStringAlternative("Price", "low", "", "low");
    indicator.parameters:addStringAlternative("Price", "median", "", "median");
    indicator.parameters:addStringAlternative("Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price", "weighted", "", "weighted");
	
	 indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("UpClr", "Up (MACD>0)", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DownClr", "Down (MACD<0)", "", core.rgb( 255,0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local SN;
local LN;
local IN;
local Price;
local first;
local source = nil;

-- Streams block
local MACD = nil;

local Up, Down;

local HZU = nil;
local HZL = nil;

local open=nil;
local close=nil;
local high=nil;
local low=nil;

-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    Price = instance.parameters.Price;
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
    Up = instance.parameters.UpClr;
    Down = instance.parameters.DownClr;
    
--    instance:setLabelColor(Up);
	
	 if (LN <= SN) then
       error("The short EMA period must be smaller than long EMA period");
    end
	
	
    source = instance.source;
 

	MACD = core.indicators:create("MACD",source[Price], SN , LN , IN);
	 first = MACD.SIGNAL:first();
	
     
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "Overlay", open, high, low, close);
  
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not  source:hasData(period) then
       return;
    end
	
	high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	
	
	MACD:update(mode);
	
	
	
	
        if MACD.MACD[period] > 0 then
	  open:setColor(period, Up);  
	else
	    open:setColor(period, Down);  	
	end
	
end

