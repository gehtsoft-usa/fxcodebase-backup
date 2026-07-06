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
    indicator:name("Daily lines indicator");
    indicator:description("Daily lines indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("OpenHour", "Open hour", "", 4, 0, 23);
    indicator.parameters:addInteger("OpenMinute", "Open minute", "", 15, 0, 59);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Oclr", "Open line color", "Open line color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Hwidth", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("Hstyle", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Hstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Vclr", "Vertical line color", "Vertical line color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Vertical line width", "Vertical line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Vertical line style", "Vertical line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local OpenHour;
local OpenMinute;
local OpenTime;
local OpenLine1=nil;
local OpenLine2=nil;

function Prepare(nameOnly)  
    source = instance.source;
    OpenHour=instance.parameters.OpenHour;
    OpenMinute=instance.parameters.OpenMinute;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.OpenHour .. ", " .. instance.parameters.OpenMinute .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    OpenLine1 = instance:addStream("OpenLine1", core.Line, name .. ".OpenLine1", "OpenLine1", instance.parameters.Oclr, first);
    OpenLine1:setWidth(instance.parameters.Hwidth);
    OpenLine1:setStyle(instance.parameters.Hstyle);
    OpenLine2 = instance:addStream("OpenLine2", core.Line, name .. ".OpenLine2", "OpenLine2", instance.parameters.Oclr, first);
    OpenLine2:setWidth(instance.parameters.Hwidth);
    OpenLine2:setStyle(instance.parameters.Hstyle);
    OpenTime=OpenHour*60+OpenMinute;
end

function Update(period, mode)
   if (period>first) then
    local Table_Curr=core.dateToTable(source:date(period));
    local Table_Prev=core.dateToTable(source:date(period-1));
    local T_Curr=Table_Curr.hour*60+Table_Curr.min;
    local T_Prev=Table_Prev.hour*60+Table_Prev.min;
    if T_Prev>=1380 then
     T_Prev=T_Prev-1440;
    end
    if OpenTime>T_Prev and OpenTime<=T_Curr then
     if OpenLine2[period-1]>0 then
      OpenLine1[period]=source.open[period];
     else
      OpenLine2[period]=source.open[period];
     end 
     core.host:execute("drawLine", period, source:date(period), 0, source:date(period), 1000, instance.parameters.Vclr, instance.parameters.styleLinReg, instance.parameters.widthLinReg);
    else
     if OpenLine1[period-1]>0 then
      OpenLine1[period]=OpenLine1[period-1];
     else
      OpenLine2[period]=OpenLine2[period-1];
     end 
    end
   elseif period==first then
    OpenLine1[period]=nil;
    OpenLine2[period]=nil; 
   end 
end

