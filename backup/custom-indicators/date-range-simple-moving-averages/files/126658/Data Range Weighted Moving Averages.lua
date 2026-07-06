-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68525
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
    indicator:name("Data Range Weighted Moving Averages");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 14, 2, 2000);
	
	indicator.parameters:addDate ("Date1", "1. Date", "", 0)
	indicator.parameters:setFlag ("Date1", core.FLAG_DATETIME)
	
	
	indicator.parameters:addDate ("Date2", "2. Date", "", 0)
	indicator.parameters:setFlag ("Date2", core.FLAG_DATETIME)
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Date1, Date2; 
local Period; 
local first;
local source = nil;
local MA; 
local Line;  

 
-- Routine
 function Prepare(nameOnly)   
  
    Date1= instance.parameters.Date1;
	Date2= instance.parameters.Date2;
    Period= instance.parameters.Period;
	
	
	local Parameters= Period;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    if (Date1 == Date2) then
       error("Dates should differ");
    end
	
	 
			
    source = instance.source; 
    first=source:first();
	
	MA = core.indicators:create("WMA", source, Period);
   
 
	Line = instance:addStream("Line" , core.Line, "Line","Line",instance.parameters.color, first);
	Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period,mode)

    MA:update(mode);
	
	if period < source:first()  
	then 
	return;
	end
	
    
	
	if source:date(period )>= math.min(Date1, Date2)
	and source:date(period)<= math.max(Date1, Date2)
	then	
	
	    
			Line[period]=MA.DATA[period];
			 
 
	
	
 
	else
	Line[period]=nil;
	end
	
end


 
