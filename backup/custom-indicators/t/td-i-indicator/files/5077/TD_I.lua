-- Id: 1904
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2359

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("TD_I indicator");
    indicator:description("TD_I indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Shift", "Shift", "", 1);
    indicator.parameters:addInteger("Period", "Period", "", 8);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Shift;
local High_Diff;
local Low_Diff;
local Buff=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Shift=instance.parameters.Shift;
    first = source:first()+Shift+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Shift .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    High_Diff = instance:addInternalStream(first+Shift, 0);
    Low_Diff = instance:addInternalStream(first+Shift, 0);
    Buff = instance:addStream("Buff", core.Line, name .. ".Buff", "Buff", instance.parameters.clr, first);
    Buff:setPrecision(math.max(2, instance.source:getPrecision()));
	Buff:setWidth(instance.parameters.width);
    Buff:setStyle(instance.parameters.style);
end

function Update(period, mode)
   if (period<first+Shift) then
   return;
   end
   
    High_Diff[period]=math.max(0.,source.high[period]-source.high[period-Shift]);
    Low_Diff[period]=math.max(0.,source.low[period-Shift]-source.low[period]);
	
    if (period<first+Shift+Period) then
	return;
	end
	
     local High_Avg=mathex.avg(High_Diff,period-Period+1, period);
     local Low_Avg=mathex.avg(Low_Diff,period-Period+1, period);
	 
     if High_Avg~=0 or Low_Avg~=0 then
      Buff[period]=High_Avg*100./(High_Avg+Low_Avg);
     end  
 
end

