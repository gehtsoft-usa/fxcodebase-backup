-- Id: 7282
-- More information about this indicator can be found at:
-- http://fxcodebase.com/

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
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
    indicator:name("Snake force TMA indicator");
    indicator:description("Snake force TMA indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 24);
    indicator.parameters:addInteger("TMA_Period", "Period of TMA", "", 11);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("FUclr", "Force UP Color", "Force UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("FDclr", "Force DN Color", "Force DN Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("RUclr", "Resistance UP Color", "Resistance UP Color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("RDclr", "Resistance DN Color", "Resistance DN Color", core.rgb(0, 255, 255));
end

local first;
local source = nil;
local Period;
local TMA_Period;
local ForceUp=nil;
local ForceDn=nil;
local ResistanceUp=nil;
local ResistanceDn=nil;
local Mart;

function Prepare()
    source = instance.source;
    Period=instance.parameters.Period;
    TMA_Period=instance.parameters.TMA_Period;
    first = source:first()+2;
    Mart = instance:addInternalStream(first, 0);
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.TMA_Period .. ")";
    instance:name(name);
    ForceUp = instance:addStream("ForceUp", core.Bar, name .. ".ForceUp", "ForceUp", instance.parameters.FUclr, first);
    ForceUp:setPrecision(math.max(2, instance.source:getPrecision()));
    ForceDn = instance:addStream("ForceDn", core.Bar, name .. ".ForceDn", "ForceDn", instance.parameters.FDclr, first);
    ForceDn:setPrecision(math.max(2, instance.source:getPrecision()));
    ResistanceUp = instance:addStream("ResistanceUp", core.Bar, name .. ".ResistanceUp", "ResistanceUp", instance.parameters.RUclr, first);
    ResistanceUp:setPrecision(math.max(2, instance.source:getPrecision()));
    ResistanceDn = instance:addStream("ResistanceDn", core.Bar, name .. ".ResistanceDn", "ResistanceDn", instance.parameters.RDclr, first);
    ResistanceDn:setPrecision(math.max(2, instance.source:getPrecision()));
end

function iTma(per, i)
 local half=(per+1)/2;
 local sum=0;
 local sumw=0;
 local k;
 local weight;
 for k=0,per-1,1 do
  weight=k+1;
  if weight>half then
   weight=per-k;
  end
  sumw=sumw+weight;
  sum=sum+weight*source.close[i-k];
 end
 if sumw~=0 then
  return sum/sumw;
 else
  return nil; 
 end
end

function Drawing(Shift)
 local val,Dval,val1,val2,val11,val22,val3;
 val=5*(Mart[Shift]-core.min(Mart,core.rangeTo(Shift,Period)))/9;
 Dval=5*(Mart[Shift]-Mart[Shift-1]+core.min(Mart,core.rangeTo(Shift-1,Period))-core.min(Mart,core.rangeTo(Shift,Period)))/9;
 if Dval>0 then
  ForceUp[Shift]=val;
  ResistanceUp[Shift]=0;
 else
  ForceUp[Shift]=0;
  ResistanceUp[Shift]=val;
 end

 val=5*(Mart[Shift]-core.max(Mart,core.rangeTo(Shift,Period)))/9;
 Dval=5*(Mart[Shift]-Mart[Shift-1]+core.max(Mart,core.rangeTo(Shift-1,Period))-core.max(Mart,core.rangeTo(Shift,Period)))/9;
 if Dval<0 then
  ForceDn[Shift]=val;
  ResistanceDn[Shift]=0;
 else
  ForceDn[Shift]=0;
  ResistanceDn[Shift]=val;
 end
 return;
end

function Update(period, mode)
 local i; 
 local period_;
 if period>first+Period then
  local StartCandle=period;
  local EndCandle=period;
  if period==source:size()-1 then
   StartCandle=source:size()-6;
  end
  for i=StartCandle,EndCandle,1 do
   Mart[i]=iTma(TMA_Period,i);
   Drawing(i);
  end
 end 
end 


