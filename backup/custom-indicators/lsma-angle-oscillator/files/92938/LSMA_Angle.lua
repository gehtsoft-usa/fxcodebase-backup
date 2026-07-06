-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60373
-- Id: 11253

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
    indicator:name("LSMA angle indicator");
    indicator:description("LSMA angle indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 25);
    indicator.parameters:addInteger("AngleTreshold", "Angle treshold", "", 15);
    indicator.parameters:addInteger("StartShift", "Start shift", "", 4);
    indicator.parameters:addInteger("EndShift", "End shift", "", 0);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("PUPclr", "Positive UP color", "Positive UP color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("PDNclr", "Positive DN color", "Positive DN color", core.rgb(0, 255, 255));
    indicator.parameters:addColor("NUPclr", "Negative UP color", "Negative UP color", core.rgb(255, 128, 192));
    indicator.parameters:addColor("NDNclr", "Negative DN color", "Negative DN color", core.rgb(255, 0, 255));
    indicator.parameters:addColor("Nclr", "Neutral color", "Neutral color", core.rgb(128, 128, 128));
end

local first;
local source = nil;
local Period;
local AngleTreshold;
local StartShift;
local EndShift;
local LSMA_Angle=nil;
local MaxShift;
local mFactor;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    AngleTreshold=instance.parameters.AngleTreshold;
    StartShift=instance.parameters.StartShift;
    EndShift=instance.parameters.EndShift;
	MaxShift=math.max(StartShift, EndShift);
    mFactor=100000/(StartShift-EndShift);
    first = source:first()+MaxShift;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.AngleTreshold .. ", " .. instance.parameters.StartShift .. ", " .. instance.parameters.EndShift .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    LSMA_Angle = instance:addStream("LSMA_Angle", core.Bar, name .. ".LSMA_Angle", "LSMA_Angle", instance.parameters.PUPclr, first);
    LSMA_Angle:setPrecision(math.max(2, instance.source:getPrecision()));
    
end

function LSMA(index, shift)
 local i;
 local sum=0;
 local tmp;
 local len=(Period+1)/3;
 for i=1, Period, 1 do
  tmp=(i-len)*source[index-shift-Period+i];
  sum=sum+tmp;
 end
 return (sum*6/(Period*(Period+1)));
end

function Update(period, mode)
   if period>first then
    local fEnd=LSMA(period, EndShift);
    local fStart=LSMA(period, StartShift);
    local fAngle=mFactor*(fEnd-fStart)/2;
    LSMA_Angle[period]=fAngle;
    if math.abs(LSMA_Angle[period])>=AngleTreshold then
     if LSMA_Angle[period]>0 then
      if LSMA_Angle[period]>=LSMA_Angle[period-1] then
       LSMA_Angle:setColor(period, instance.parameters.PUPclr);
      else
       LSMA_Angle:setColor(period, instance.parameters.PDNclr);
      end
     else
      if LSMA_Angle[period]>=LSMA_Angle[period-1] then
       LSMA_Angle:setColor(period, instance.parameters.NUPclr);
      else
       LSMA_Angle:setColor(period, instance.parameters.NDNclr);
      end 
     end
    else
     LSMA_Angle:setColor(period, instance.parameters.Nclr);
    end
   end 
end

