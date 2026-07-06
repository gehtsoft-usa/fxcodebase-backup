-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63567

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

 
 
function Init()
    indicator:name("Automatic Regression Channel");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup("Calculation" );
    indicator.parameters:addInteger("Period", "Period","", 20);
 
    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Top", "Top Line Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Central", "Central Line Color","", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Bottom", "Bottom Line Color","", core.rgb(255, 0, 0));
	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
   
end

local Period, Top, Bottom, Central;
local source; 
local CentralLine;
local width, style;
local from, a, b, dev, raff;

function Prepare(nameOnly)
  
	 
	Top=instance.parameters.Top;
	Bottom=instance.parameters.Bottom;
	Central=instance.parameters.Central;
	Period=instance.parameters.Period;
	width=instance.parameters.width;
	style=instance.parameters.style;
	
	source = instance.source;
	first=source:first()+Period
	
	 local name = profile:id() .. " " .. source:name() ;
	instance:name(name );
	
	if   (nameOnly) then
        return;
    end
	
	from = instance:addInternalStream(first, 0);
	a = instance:addInternalStream(first, 0);
	b = instance:addInternalStream(first, 0);
	dev = instance:addInternalStream(first, 0);
	raff = instance:addInternalStream(first, 0);
 
   

	
	CentralLine = instance:addStream("CentralLine", core.Line, name .. ". CentralLine", "CentralLine", Central, first);
	TopLine = instance:addStream("TopLine", core.Line, name .. ". TopLine", "TopLine", Top, first);
	BottomLine = instance:addStream("BottomLine", core.Line, name .. ". BottomLine", "BottomLine", Central, first);
end

 
function Update(period)

local x;
if period < first then
return;
end


a[period]=a[period-1];
b[period]=b[period-1];
dev[period]=dev[period-1];
raff[period]=raff[period-1];

if period == first then
a[period], b[period], dev[period], raff[period]=  mathex.regChannel (source, period-Period+1, period);
from[period]=period-Period+1;
end

x = (period - from[period]+ 1);
CentralLine[period] = a[period] * x + b[period];
TopLine[period] = CentralLine[period] + dev[period];
BottomLine[period] = CentralLine[period] - dev[period];

	if source.close[period]> TopLine[period]  
	then
		a[period], b[period], dev[period], raff[period]=  mathex.regChannel (source, period-Period+1, period);
		from[period]=period-Period+1;
	end

	if source.close[period]< BottomLine[period]  
	then
	   a[period], b[period], dev[period], raff[period]=  mathex.regChannel (source, period-Period+1, period);
	   from[period]=period-Period+1;
	end 

x = (period - from[period]+ 1);
CentralLine[period] = a[period] * x + b[period];

TopLine[period] = CentralLine[period] + dev[period];
BottomLine[period] = CentralLine[period] - dev[period];

        
end
 