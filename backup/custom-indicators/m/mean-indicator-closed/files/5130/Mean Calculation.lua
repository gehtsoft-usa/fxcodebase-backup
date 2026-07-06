-- Id: 18546
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2378

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Mean indicator");
    indicator:description("Mean indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	 
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN", "DN Color", "DN Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrPrev", "Prev Color", "Prev Color", core.rgb(0, 0, 255));
    
end

local first;
local source = nil;
local Mean=nil;
local PrevBuff=nil;
local Size;
function Prepare(nameOnly)
    source = instance.source;
	Size=instance.parameters.Size;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Mean  = instance:addStream("Mean", core.Line, name .. ".Mean", "Mean", instance.parameters.clrUP, first);
    PrevBuff = instance:addStream("PrevBuff", core.Line, name .. ".PrevBuff", "PrevBuff", instance.parameters.clrPrev, first);
    
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
   
      local d1,t1;
      d1,t1=source:date(period);
      local table1=core.dateToTable(d1);
      local CurD=table1.year*372+table1.month*31+table1.day;
      local shift=period;
      local PrevD=CurD;
      while PrevD==CurD and shift>first do
       local d2,t2;
       d2,t2=source:date(shift);
       local table2=core.dateToTable(d2);
       PrevD=table2.year*372+table2.month*31+table2.day;
       shift=shift-1;
      end
      shift=shift+1;
      
       if period<shift+1 then
	   return;
	   end
	   
	   
       Mean[period]=core.avg(source,core.range(shift+1,period));	
   
	   
	   if Mean[period] > Mean[period-1] then
       Mean:setColor(period,  instance.parameters.clrUP);
	 
	   else
       Mean:setColor(period,  instance.parameters.clrDN);
	   
	   end
	   
       PrevBuff[period]= Mean[shift];        
      
   
end

