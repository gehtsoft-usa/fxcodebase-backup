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
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 1, 1, 5);
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
local OpenLine=nil;

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
	
	
    OpenLine = instance:addStream("OpenLine", core.Dot, name .. ".OpenLine", "OpenLine", instance.parameters.Oclr, first);
    OpenLine:setWidth(instance.parameters.DotSize);
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
     OpenLine[period]=source.open[period];
     core.host:execute("drawLine", period, source:date(period), 0, source:date(period), 1000, instance.parameters.Vclr, instance.parameters.styleLinReg, instance.parameters.widthLinReg);
    else
     OpenLine[period]=OpenLine[period-1];
    end
   end 
end

