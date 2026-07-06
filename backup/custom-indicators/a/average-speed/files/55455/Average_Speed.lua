-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32557
-- Id: 8646

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("Average speed");
    indicator:description("Average speed");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 3);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "Up color", "Up color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "Dn color", "Dn color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Period;
local Speed;
local AS=nil;
local pipSize;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Speed = instance:addInternalStream(source:first()+1, 0);
	first = source:first()+Period;
    AS = instance:addStream("AS", core.Bar, name .. ".AS", "AS", instance.parameters.UPclr, first);
    AS:setPrecision(math.max(2, instance.source:getPrecision()));
    pipSize=source:pipSize();
end

function Update(period, mode)
   if period<source:first()+1 then
   return;
   end
   
    local dt=source:date(period)-source:date(period-1);
    Speed[period]=math.abs(source[period]-source[period-1])/(pipSize*dt);
	
    if period<first  then
	return;
	end
	
     AS[period]=mathex.avg(Speed, period-Period+1, period);
     if AS[period]>=AS[period-1] then
      AS:setColor(period, instance.parameters.UPclr);
     else
      AS:setColor(period, instance.parameters.DNclr);
     end
    
   
end

