-- Id: 1930
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
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addInteger("Size", "Size", "Size", 12);
end

local first;
local source = nil;
local MeanUP=nil;
local MeanDN=nil;
local Buff=nil;
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
    Buff = instance:addInternalStream(first, 0);
    MeanUP = instance:addStream("MeanUP", core.Line, name .. ".UP", "UP", instance.parameters.clrUP, first);
    MeanDN = instance:addStream("MeanDN", core.Line, name .. ".DN", "DN", instance.parameters.clrDN, first);
    PrevBuff = instance:createTextOutput ("Prev", "Prev", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.clrPrev, first);
    MeanUP:setWidth(instance.parameters.widthLinReg);
    MeanUP:setStyle(instance.parameters.styleLinReg);
    MeanDN:setWidth(instance.parameters.widthLinReg);
    MeanDN:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if (period>first) then
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
      
      if period>=shift+1 then
       Buff[period]=core.avg(source,core.range(shift+1,period));
       if Buff[period]>Buff[period-1] then
        MeanUP[period]=Buff[period];
        if Buff[period-1]<Buff[period-2] then
         MeanUP[period-1]=Buff[period-1];
        end
       else
        MeanDN[period]=Buff[period];
        if Buff[period-1]>Buff[period-2] then
         MeanDN[period-1]=Buff[period-1];
        end
       end
       if period>shift then
        PrevBuff:set(period, Buff[shift], "\159", "");
       end 
      end 
    
   end 
end

