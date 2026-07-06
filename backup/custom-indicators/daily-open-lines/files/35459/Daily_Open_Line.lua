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
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 1, 1, 5);
end

local first;
local source = nil;
local OpenHour;
local DailyOpenLine=nil;
local Last;
function Prepare(nameOnly)  
    Last=0;
    source = instance.source;
    OpenHour=instance.parameters.OpenHour;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.OpenHour .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    DailyOpenLine = instance:addStream("DailyOpenLine", core.Dot, name .. ".DailyOpenLine", "DailyOpenLine", instance.parameters.clr, first);
    DailyOpenLine:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)
   if (period>first) then
    local H_Curr=core.dateToTable(source:date(period)).hour;
   local D_Curr=core.dateToTable(source:date(period)).day;
  
 
   
    if OpenHour<= H_Curr and Last ~= D_Curr then
	Last = D_Curr;
     DailyOpenLine[period]=source.open[period];
    else
     DailyOpenLine[period]=DailyOpenLine[period-1];
    end
   end 
end

