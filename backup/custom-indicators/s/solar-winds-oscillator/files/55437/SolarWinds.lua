-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32543
-- Id: 8621

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
    indicator:name("SolarWinds oscillator");
    indicator:description("SolarWinds oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 10);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Color 1", "Color 1", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr2", "Color 2", "Color 2", core.rgb(0, 128, 0));
    indicator.parameters:addColor("clr3", "Color 3", "Color 3", core.rgb(255, 0, 255));
    indicator.parameters:addColor("clr4", "Color 4", "Color 4", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clr5", "Color 5", "Color 5", core.rgb(128, 128, 128));
end

local first;
local source = nil;
local Period;
local Value;
local SW=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Value=instance:addInternalStream(first, 0);
    SW = instance:addStream("SW", core.Bar, name .. ".SW", "SW", instance.parameters.clr1, first);
    SW:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if period<first  then
   return;
   end
   
   
    local MinP, MaxP = mathex.minmax(source, core.rangeTo(period, Period));
    local Price = (source.high[period]+source.low[period])/2;
    local Res=MaxP-MinP;
    if Res~=0 then
     Value[period]=(((Price-MinP)/Res-0.5)+Value[period-1])*2/3;
    else
     Value[period]=0; 
    end
    Value[period]=math.min(math.max(Value[period],-1),1);
    if Value[period]~=1 then
     SW[period]=(math.log((1+Value[period])/(1-Value[period]))+SW[period-1])/2;
    else
     SW[period]=0;
    end
    if SW[period]>0 then
     if SW[period]>SW[period-1] then
      SW:setColor(period, instance.parameters.clr1);
     elseif SW[period]<SW[period-1] then
      SW:setColor(period, instance.parameters.clr2);
     else
      SW:setColor(period, instance.parameters.clr5);
     end
    else
     if SW[period]>SW[period-1] then
      SW:setColor(period, instance.parameters.clr3);
     elseif SW[period]<SW[period-1] then
      SW:setColor(period, instance.parameters.clr4);
     else
      SW:setColor(period, instance.parameters.clr5);
     end
    end
 
end

