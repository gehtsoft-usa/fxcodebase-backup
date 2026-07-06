-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10494

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
    indicator:name("AC_Sig indicator");
    indicator:description("AC_Sig indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("FastPeriod", "Fast period for AC", "", 5);
    indicator.parameters:addInteger("SlowPeriod", "Slow period for AC", "", 34);
    indicator.parameters:addInteger("MAPeriod", "MA period for AC", "", 5);
    indicator.parameters:addInteger("ATRPeriod", "ATR period", "", 15);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 4, 1, 5);
end

local first;
local source = nil;
local FastPeriod;
local SlowPeriod;
local MAPeriod;
local ATRPeriod;
local AC;
local ATR;
local AC_Sig=nil;

function Prepare()
    source = instance.source;
    FastPeriod=instance.parameters.FastPeriod;
    SlowPeriod=instance.parameters.SlowPeriod;
    MAPeriod=instance.parameters.MAPeriod;
    ATRPeriod=instance.parameters.ATRPeriod;
   
    AC = core.indicators:create("AC", source, FastPeriod, SlowPeriod, MAPeriod);
    ATR = core.indicators:create("ATR", source, ATRPeriod);
	 first =math.max(AC.DATA:first(),ATR.DATA:first());
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.FastPeriod .. ", " .. instance.parameters.SlowPeriod .. ", " .. instance.parameters.MAPeriod .. ", " .. instance.parameters.ATRPeriod .. ")";
    instance:name(name);
    AC_Sig = instance:addStream("AC_Sig", core.Dot, name .. ".AC_Sig", "AC_Sig", instance.parameters.UPclr, first);
    AC_Sig:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
   
    AC:update(mode);
    ATR:update(mode);
    local ac=AC.DATA;
    local atr=ATR.DATA;
    if ((ac[period-3]>0 and ac[period-2]>0 and ac[period-1]>0 and ac[period]>0) and (ac[period-3]>ac[period-2] and ac[period-1]>ac[period-2] and ac[period]>ac[period-1])) or
       ((ac[period-3]<0 and ac[period-2]<0 and ac[period-1]<0 and ac[period]>0) and (ac[period-3]>ac[period-2] and ac[period-1]>ac[period-2] and ac[period]>ac[period-1])) or
       ((ac[period-4]<0 and ac[period-3]<0 and ac[period-2]<0 and ac[period-1]<0 and ac[period]<0) and (ac[period-4]>ac[period-3] and ac[period-3]<ac[period-2] and ac[period-2]<ac[period-1] and ac[period-1]<ac[period])) then
     AC_Sig[period]=source.high[period]+atr[period]*3/8;  
     AC_Sig:setColor(period,instance.parameters.DNclr);
    end
    if ((ac[period-3]<0 and ac[period-2]<0 and ac[period-1]<0 and ac[period]<0) and (ac[period-3]<ac[period-2] and ac[period-1]<ac[period-2] and ac[period]<ac[period-1])) or
       ((ac[period-3]>0 and ac[period-2]>0 and ac[period-1]>0 and ac[period]<0) and (ac[period-3]<ac[period-2] and ac[period-1]<ac[period-2] and ac[period]<ac[period-1])) or
       ((ac[period-4]>0 and ac[period-3]>0 and ac[period-2]>0 and ac[period-1]>0 and ac[period]>0) and (ac[period-4]<ac[period-3] and ac[period-3]>ac[period-2] and ac[period-2]>ac[period-1] and ac[period-1]>ac[period])) then
     AC_Sig[period]=source.low[period]-atr[period]*3/8;  
     AC_Sig:setColor(period,instance.parameters.UPclr);
    end
  
end

