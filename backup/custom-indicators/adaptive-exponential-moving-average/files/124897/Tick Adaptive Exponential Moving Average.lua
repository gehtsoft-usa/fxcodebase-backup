-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67772

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
    indicator:name("Tick Adaptive Exponential Moving Average");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("1. MA Calculation"); 
    indicator.parameters:addInteger("Period1", "Period", "", 30, 1, 2000); 
	
	indicator.parameters:addGroup("2. MA Calculation"); 
    indicator.parameters:addInteger("Period2", "Period", "", 30, 1, 2000);
  
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period1;
local Period2; 
local first;
local source = nil;
 
local MA;  
 
local MLTP1;

-- Routine
 function Prepare(nameOnly)   
 
    Period1= instance.parameters.Period1;
	
	Period2= instance.parameters.Period2;
	
	
	local Parameters= Period1 ..  ", " ..Period2 ;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    first=source:first()+Period2;
  
	 
    MLTP1=2/(Period1+1); 
 
	MA = instance:addStream("AEMA" , core.Line, " AEMA"," AEMA",instance.parameters.color, first);
	MA:setWidth(instance.parameters.width);
    MA:setStyle(instance.parameters.style);
    MA:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)
 
    
 
	
    if period < first then
	return;
	end
	
	local min,max=mathex.minmax(source, period-Period2+1, period);
	
	local   MLTP2=math.abs((source [period]-min)-(max-source [period]))/ (max-min);
	local Rate=MLTP1*(1+MLTP2);	
	
	if period <= Period1 then
	MA[period]=mathex.avg(source , period-Period1+1, period);
	else
	MA[period]= MA[period-1]+Rate*(source [period-1]-MA[period-1]);
	
	end
	
 
end
 


