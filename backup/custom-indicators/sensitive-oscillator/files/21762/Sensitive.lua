-- Id: 5435
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10502

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
    indicator:name("Sensitive oscillator");
    indicator:description("Sensitive oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 150);
    indicator.parameters:addInteger("Sensitive", "Sensitive", "", 7);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Period;
local Sensitive;
local Buff=nil;
local MAopen;
local MAclose;
local MAhigh;
local MAlow;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Sensitive=instance.parameters.Sensitive;
    first = source:first()+math.max(Period,Sensitive);
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Sensitive .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    MAopen=core.indicators:create("MVA", source.open, Period);
    MAclose=core.indicators:create("MVA", source.close, Period);
    MAhigh=core.indicators:create("MVA", source.high, Period);
    MAlow=core.indicators:create("MVA", source.low, Period);
    Buff = instance:addStream("Buff", core.Bar, name .. ".Sensitive", "Sensitive", instance.parameters.UPclr, first);
    Buff:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    MAopen:update(mode);
    MAclose:update(mode);
    MAhigh:update(mode);
    MAlow:update(mode);
    local min,max=mathex.minmax(source ,period-Sensitive+1, period);
   --local min=mathex.min(source.low,core.rangeTo(period,Sensitive));
    Buff[period]=(5*MAclose.DATA[period]-5*MAopen.DATA[period]+max+min-MAhigh.DATA[period]-MAlow.DATA[period])*source.volume[period];
    if Buff[period]>0 then
     Buff:setColor(period,instance.parameters.UPclr);
    else
     Buff:setColor(period,instance.parameters.DNclr);
    end
    
end

