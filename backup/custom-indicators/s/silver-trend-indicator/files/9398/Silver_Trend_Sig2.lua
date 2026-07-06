-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3844

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
    indicator:name("Silver trend indicator");
    indicator:description("Silver trende indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Border", "Border", "", 30);
    indicator.parameters:addInteger("Period", "Period", "", 9);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP", "Color UP", "Color UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN", "Color DN", "Color DN", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Dot size", "Dot size", 3, 1, 5);
end

local first;
local source = nil;
local Border;
local Period;
local BuffUP=nil;
local BiffDN=nil;
local Trigger;
local HL;

function Prepare(nameOnly)
    source = instance.source;
    Border=instance.parameters.Border;
    Period=instance.parameters.Period;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Border .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Trigger=instance:addInternalStream(first, 0);
    HL=instance:addInternalStream(first, 0);
    BuffUP = instance:addStream("BuffUP", core.Dot, name .. ".UP", "UP", instance.parameters.clrUP, first);
    BuffDN = instance:addStream("BuffDN", core.Dot, name .. ".DN", "DN", instance.parameters.clrDN, first);
    BuffUP:setWidth(instance.parameters.widthLinReg);
    BuffDN:setWidth(instance.parameters.widthLinReg);
end

function Update(period, mode)
   if (period>first+Period and period<source:size()-1) then
    HL[period]=source.high[period]-source.low[period];
    local Max=core.max(source.high,core.rangeTo(period,Period));
    local Min=core.min(source.low,core.rangeTo(period,Period));
    local Range=(Max-Min)*Border/100;
    local R=mathex.lwma(HL,core.rangeTo(period,Period))*0.5;
    if source.close[period]<Min+Range then
     if Trigger[period-1]<0 then
      BuffDN[-Trigger[period-1]]=nil;
     end
     Trigger[period]=-period;
     BuffDN[period]=source.low[period]-R;
    elseif source.close[period]>Max-Range then
     if Trigger[period-1]>0 then
      BuffUP[Trigger[period-1]]=nil;
     end
     Trigger[period]=period;
     BuffUP[period]=source.high[period]+R;
    else
     Trigger[period]=Trigger[period-1]; 
    end
   elseif period>=first then
    Trigger[period]=0; 
    HL[period]=source.high[period]-source.low[period];
   end 
end

