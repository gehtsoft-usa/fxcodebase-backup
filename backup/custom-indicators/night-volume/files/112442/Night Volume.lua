-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64657
-- Id: 18148

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Night Volume ");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 

    indicator.parameters:addGroup("Calculation");
	 indicator.parameters:addInteger("Start", "Session Start", "", 0, 0 , 24);
    indicator.parameters:addDouble("Period", "Session Period", "", 8.5, 0 , 24);
 
	
 
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Bar Color","", core.rgb(0, 0, 255));
	indicator.parameters:addColor("High", "High Volume Color","", core.rgb(0, 255,0));
	indicator.parameters:addColor("Low", "Low Volume Color","", core.rgb(255, 0,0));
	
	indicator.parameters:addColor("average", "Average Color","", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
  

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
 
local first;
local source = nil;
local Volume; 
local Period;
local Hour;

local Start;
local EndTime=nil;
local StartTime=nil;
local High, Low;
-- Routine
function Prepare(nameOnly)
    
    Period = instance.parameters.Period; 
	Start = instance.parameters.Start;
	High = instance.parameters.High;
	Low = instance.parameters.Low;
	 
	source = instance.source;
    first = source:first();
	Hour=1/24;
	
    local name = profile:id() .. "(" .. source:name()   .. ")";
    instance:name(name); 
    if nameOnly then
        return;
    end
	
	EndTime=nil;
	
    Volume = instance:addStream("Volume", core.Bar, name .. ".Volume", "Volume", instance.parameters.color,source:first());
    Volume:setPrecision(math.max(2, instance.source:getPrecision()));
	 
	
end


function Update(period)
   
   if period < first then
   return;
   end 
   
    Volume[period]=0;
	
	
	date_table= core.dateToTable ( source:date(period));
    start_time= core.datetime (date_table.year, date_table.month, date_table.day, Start, 0, 0)   
	end_time=start_time+Period*Hour;
	
    
   p1=core.findDate (source, start_time, false)
   p2=core.findDate (source, end_time, false);
	

  if p1 == -1
  or p2 == -1 
  then
  return;
  end
  
 
  if period >= p1
  and period <= p2 then  
   Volume[period]= mathex.sum(source.volume, p1, period);  
  end
  
  
  if period -1 == p2 
  and Volume[period-1]~=0
  then
  Level=Volume[period-1]/(p2-p1);
  Volume[period]= source.volume[period];
  
	  if Volume[period]> Level then
	  Volume:setColor(period, High);
	  else
	   Volume:setColor(period, Low);
	  end
  
  end
  
  
   if period == p2 then
   Level=Volume[period]/(p2-p1);
   core.host:execute ("drawLine", source:serial(p2), source:date(p1), Level, source:date(p2), Level, instance.parameters.average, instance.parameters.style, instance.parameters.width);
   end
 
	 
end 