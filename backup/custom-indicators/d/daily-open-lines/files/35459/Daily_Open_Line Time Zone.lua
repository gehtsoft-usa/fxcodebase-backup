-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=20169

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
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
    indicator:name("Daily open line indicator");
    indicator:description("Daily open line indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Time", "Time Zone", "", 4);
    indicator.parameters:addIntegerAlternative("Time", "EST", "", 1);
    indicator.parameters:addIntegerAlternative("Time", "Coordinated Universal Time", "", 2);
    indicator.parameters:addIntegerAlternative("Time", "The user's local time zone", "", 3);
    indicator.parameters:addIntegerAlternative("Time","The display time zone", "", 4);
    indicator.parameters:addIntegerAlternative("Time", "Server time zone", "", 5);
    indicator.parameters:addIntegerAlternative("Time", "Financial time ", "", 6); 

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 1, 1, 5);
end

local first;
local source = nil;
--local OpenHour;
local DailyOpenLine=nil;
local Last;
local Size1, Size2;
local Time;
function Prepare(nameOnly)  
   
    source = instance.source;
	local s, e;
    s, e = core.getcandle("D1",0, 0, 0);
	Size1= e-s;
	 s, e = core.getcandle(source:barSize(),0, 0, 0);
	Size2= e-s;
	
    Time=instance.parameters.Time;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    DailyOpenLine = instance:addStream("DailyOpenLine", core.Dot, name .. ".DailyOpenLine", "DailyOpenLine", instance.parameters.clr, first);
    DailyOpenLine:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)

   if Size1 <= Size2 then
   return;
   end
   
 
   
   if (period<first) then
   return;
   end
   
     local tickday,ticktimenum,ticktime; 
	ticktimenum = core.host:execute("convertTime", 1, Time, source:date(period));   -- EST->Display
    ticktime = core.dateToTable(ticktimenum);
    tickday = ticktime.day;
   
   
    local tickday=core.dateToTable(source:date(period)).day;
     
    if tickday~= Last then
     Last=tickday;
	 DailyOpenLine[period]=source.open[period];  
   
    else
     DailyOpenLine[period]=DailyOpenLine[period-1];
    end
  
end

