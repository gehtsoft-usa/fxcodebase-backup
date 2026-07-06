-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7636

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
    indicator:name("WATR indicator");
    indicator:description("WATR indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("WATR_K", "WATR_K", "", 10);
    indicator.parameters:addDouble("WATR_M", "WATR_M", "", 4);
    indicator.parameters:addInteger("ATR_Period", "ATR_Period", "", 21);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UpClr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DnClr", "DN Color", "DN Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 1, 1, 5);
end

local first;
local source = nil;
local WATR_K;
local WATR_M;
local ATR_Period;
local Up=nil;
local Dn=nil;
local ATR;
local UpBuff;
local DnBuff;

function Prepare(nameOnly)   
    source = instance.source;
    WATR_K=instance.parameters.WATR_K;
    WATR_M=instance.parameters.WATR_M;
    ATR_Period=instance.parameters.ATR_Period;
	
	   local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.WATR_K .. ", " .. instance.parameters.WATR_M .. ", " .. instance.parameters.ATR_Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
   
    ATR=core.indicators:create("ATR", source, ATR_Period);
	 first = ATR.DATA:first() ;
    UpBuff = instance:addInternalStream(0, 0);
    DnBuff = instance:addInternalStream(0, 0);
 
    Up = instance:addStream("Up", core.Dot, name .. ".Up", "Up", instance.parameters.UpClr, first);
    Dn = instance:addStream("Dn", core.Dot, name .. ".Dn", "Dn", instance.parameters.DnClr, first);
    Up:setWidth(instance.parameters.DotSize);
    Dn:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)
   if (period<first ) then
   return;
   end
   
    ATR:update(mode);
    if AntiTrendBar(period) then
     Up[period]=Up[period-1];
     Dn[period]=Dn[period-1];
    else
     if TrendUp(period) then
      Up[period]=source.close[period]-WATR_K*source:pipSize()-WATR_M*ATR.DATA[period];
      if Up[period]<Up[period-1] then
       Up[period]=Up[period-1];
      end
      Dn[period]=nil;
     else
      Dn[period]=source.close[period]+WATR_K*source:pipSize()+WATR_M*ATR.DATA[period];
      if Dn[period]>Dn[period-1] then
       Dn[period]=Dn[period-1];
      end
      Up[period]=nil;
     end
    end
    
    if TrendUp(period) and source.close[period]<Up[period] then
     Dn[period]=source.close[period]+WATR_K*source:pipSize()+WATR_M*ATR.DATA[period];
     Up[period]=nil;
    end
    if TrendUp(period)==false and source.close[period]>Dn[period] then
     Up[period]=source.close[period]-WATR_K*source:pipSize()-WATR_M*ATR.DATA[period];
     Dn[period]=nil;
    end
 
end

function TrendUp(period)
 if source.close[period-1]>Up[period-1] and Up[period-1]>0 then
  return true;
 else
  return false;
 end
end

function AntiTrendBar(period)
 local TU=TrendUp(period);
 if (TU and source.close[period]<source.open[period]) or (TU==false and source.close[period]>source.open[period]) then
  return true;
 else
  return false;
 end
end


