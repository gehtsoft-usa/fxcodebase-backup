-- Id: 5342
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=10251


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
    indicator:name("J_TPO_Velocity indicator");
    indicator:description("J_TPO_Velocity indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 14, 3, 10000);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("NEclr", "NE Color", "NE Color", core.rgb(128, 128, 128));
    indicator.parameters:addColor("UPUPclr", "UP UP Color", "UP UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UPDNclr", "UP DN Color", "UP DN Color", core.rgb(0, 128, 0));
    indicator.parameters:addColor("DNUPclr", "DN UP Color", "DN UP Color", core.rgb(128, 0, 0));
    indicator.parameters:addColor("DNDNclr", "DN DN Color", "DN DN Color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Period;
local J_TPO_Velocity=nil;
local normalization;
local Lenp1half;


 function Prepare(nameOnly)  
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    J_TPO_Velocity = instance:addStream("J_TPO_Velocity", core.Bar, name .. ".J_TPO_Velocity", "J_TPO_Velocity", instance.parameters.NEclr, first);
    J_TPO_Velocity:setPrecision(math.max(2, instance.source:getPrecision()));
    normalization=12/(Period*(Period-1)*(Period+1));
    Lenp1half=(Period+1)*0.5;
end

function J_TPO_Value(period)
 local arr1={};
 local arr2={};
 local arr3={};
 local m;
 for m=1,Period,1 do
  arr1[m]=source.close[period-Period+m];
  arr2[m]=m;
  arr3[m]=m;
 end
 for m=1,Period-1,1 do
  local maxval=arr1[m];
  local maxloc=m;
  local j;
  for j=m+1,Period,1 do
   if arr1[j]<maxval then
    maxval=arr1[j];
    maxloc=j;
   end
  end 
  local tmp=arr1[m];
  arr1[m]=arr1[maxloc];
  arr1[maxloc]=tmp;
  tmp=arr2[m];
  arr2[m]=arr2[maxloc];
  arr2[maxloc]=tmp;
 end
 m=1;
 while m<Period do
  j=m+1;
  local flag=true;
  local accum=arr3[m];
  while flag do
   if arr1[m]~=arr1[j] then
    if j-m>1 then
     accum=accum/(j-m);
     local n;
     for n=m,j-1,1 do
      arr3[n]=accum;
     end
    end
    flag=false;
   else
    accum=accum+arr3[j];
    j=j+1;
   end
  end
  m=j;
 end
 accum=0;
 for m=1,Period,1 do
  accum=accum+(arr3[m]-Lenp1half)*(arr2[m]-Lenp1half);
 end
 return normalization*accum;
end

function Range(period)
 local H=mathex.max(source.high,core.rangeTo(period,Period));
 local L=mathex.min(source.low,core.rangeTo(period,Period));
 return (H-L)/source:pipSize();
end

function Update(period, mode)
   if (period<first ) then
   return;
   end
    J_TPO_Velocity[period]=J_TPO_Value(period)*Range(period);
    if J_TPO_Velocity[period]>0 then
     if J_TPO_Velocity[period]>J_TPO_Velocity[period-1] then
      J_TPO_Velocity:setColor(period,instance.parameters.UPUPclr);
     elseif J_TPO_Velocity[period]<J_TPO_Velocity[period-1] then
      J_TPO_Velocity:setColor(period,instance.parameters.UPDNclr);
     end
    elseif J_TPO_Velocity[period]<0 then
     if J_TPO_Velocity[period]>J_TPO_Velocity[period-1] then
      J_TPO_Velocity:setColor(period,instance.parameters.DNUPclr);
     elseif J_TPO_Velocity[period]<J_TPO_Velocity[period-1] then
      J_TPO_Velocity:setColor(period,instance.parameters.DNDNclr);
     end
    end
   
end

