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
    indicator.parameters:addInteger("OpenHour", "Open hour", "", 0, 0, 23);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local OpenHour;
local DailyOpenLine1=nil;
local DailyOpenLine2=nil;

function Prepare(nameOnly)  
    source = instance.source;
    OpenHour=instance.parameters.OpenHour;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.OpenHour .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    DailyOpenLine1 = instance:addStream("DailyOpenLine1", core.Line, name .. ".DailyOpenLine1", "DailyOpenLine1", instance.parameters.clr, first);
    DailyOpenLine1:setWidth(instance.parameters.widthLinReg);
    DailyOpenLine1:setStyle(instance.parameters.styleLinReg);
    DailyOpenLine2 = instance:addStream("DailyOpenLine2", core.Line, name .. ".DailyOpenLine2", "DailyOpenLine2", instance.parameters.clr, first);
    DailyOpenLine2:setWidth(instance.parameters.widthLinReg);
    DailyOpenLine2:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if (period>first) then
    local H_Curr=core.dateToTable(source:date(period)).hour;
    local H_Prev=core.dateToTable(source:date(period-1)).hour;
    if H_Prev==23 then
     H_Prev=-1;
    end
    if OpenHour>H_Prev and OpenHour<=H_Curr then
     if DailyOpenLine2[period-1]>0 then
      DailyOpenLine1[period]=source.open[period];
     else
      DailyOpenLine2[period]=source.open[period];
     end 
    else
     if DailyOpenLine1[period-1]>0 then
      DailyOpenLine1[period]=DailyOpenLine1[period-1];
     else
      DailyOpenLine2[period]=DailyOpenLine2[period-1];
     end 
    end
   elseif period==first then
    DailyOpenLine1[period]=nil;
    DailyOpenLine2[period]=nil; 
   end 
end

