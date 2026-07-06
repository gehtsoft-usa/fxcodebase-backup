-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65713

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

function Init()
    indicator:name("SimpleGuy Indicator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	
	 indicator.parameters:addGroup("EMA Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	
	 indicator.parameters:addGroup("Non Lag MA Calculation");
    indicator.parameters:addInteger("Length", "Length", "Length", 9);
    indicator.parameters:addInteger("Filter", "Filter", "Filter", 0);
    indicator.parameters:addInteger("ColorBarBack", "ColorBarBack", "ColorBarBack", 2);
    indicator.parameters:addDouble("Deviation", "Deviation", "Deviation", 0);
	

	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Length, Filter, ColorBarBack, Deviation,Period; 
local EMA, NLMA;
local first;
local source = nil;
local Line1,Line2;

-- Routine
 function Prepare(nameOnly)  


     Period= instance.parameters.Period; 
	 
	 Length= instance.parameters.Length;
	 Filter= instance.parameters.Filter;
	 ColorBarBack= instance.parameters.ColorBarBack;
	 Deviation= instance.parameters.Deviation;
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " ..  Period  .. ", " ..  Length .. ", " ..  Filter .. ", " ..  ColorBarBack .. ", " ..  Deviation.. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	assert(core.indicators:findIndicator("SSNONLAGMA") ~= nil, "Please, download and install SSNONLAGMA.LUA indicator");
	
   
			
    source = instance.source;
	
	 EMA = core.indicators:create("EMA",source,Period);
	  NLMA = core.indicators:create("SSNONLAGMA",source,Length, Filter, ColorBarBack, Deviation);
	 first=math.max(EMA.DATA:first(), NLMA.DATA:first());
    
   
 
	Line1 = instance:addStream("Line1" , core.Line, " 1. Line"," 1. Line",instance.parameters.color1, first);
	Line1:setWidth(instance.parameters.width1);
    Line1:setStyle(instance.parameters.style1);
	
	Line1:setPrecision (6);
    
	 
	
end

-- Indicator calculation routine
function Update(period, mode)

  
   EMA:update(mode);
   NLMA:update(mode);
   if period < first then
   return;
   end
   
  
-- (Close / [non lag moving average] - [ema])


   
    Line1[period]=  source[period]/NLMA.DATA[period]- EMA.DATA[period];
 
   
end

