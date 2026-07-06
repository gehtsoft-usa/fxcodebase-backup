-- Id: 7463
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=20166&p=35452#p35452

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Snake force indicator");
    indicator:description("Snake force indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 24);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("FUclr", "Force UP Color", "Force UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("FDclr", "Force DN Color", "Force DN Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("RUclr", "Resistance UP Color", "Resistance UP Color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("RDclr", "Resistance DN Color", "Resistance DN Color", core.rgb(0, 255, 255));
end

local first;
local source = nil;
local Period;
local ForceUp=nil;
local ForceDn=nil;
local ResistanceUp=nil;
local ResistanceDn=nil;
local Mart;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first();
    Mart = instance:addInternalStream(0, 0);
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    ForceUp = instance:addStream("ForceUp", core.Bar, name .. ".ForceUp", "ForceUp", instance.parameters.FUclr, first+2*Period);
    ForceUp:setPrecision(math.max(2, instance.source:getPrecision()));
    ForceDn = instance:addStream("ForceDn", core.Bar, name .. ".ForceDn", "ForceDn", instance.parameters.FDclr, first+2*Period);
    ForceDn:setPrecision(math.max(2, instance.source:getPrecision()));
    ResistanceUp = instance:addStream("ResistanceUp", core.Bar, name .. ".ResistanceUp", "ResistanceUp", instance.parameters.RUclr, first+2*Period);
    ResistanceUp:setPrecision(math.max(2, instance.source:getPrecision()));
    ResistanceDn = instance:addStream("ResistanceDn", core.Bar, name .. ".ResistanceDn", "ResistanceDn", instance.parameters.RDclr, first+2*Period);
    ResistanceDn:setPrecision(math.max(2, instance.source:getPrecision()));
end

function SnakePrice(Shift)
 return source[Shift];
end

function SnakeCalc(Shift)
 local i,j,w;
 local SnakeSum=0;
 local SnakeWeight;
 if (Shift>source:size()-6) then
  SnakeWeight=0;
  i=0;
  w=Shift-5;
  while w<=Shift do
   i=i+1;
   SnakeSum=SnakeSum+i*SnakePrice(w);
   SnakeWeight=SnakeWeight+i;
   w=w+1;
  end
  while w<=source:size()-1 do
   i=i-1;
   SnakeSum=SnakeSum+i*SnakePrice(w);
   SnakeWeight=SnakeWeight+i;
   w=w+1;
  end
 else
  j=Shift+5;
  i=Shift-5;
  w=1;
  while w<=5 do
   SnakeSum=SnakeSum+w*(SnakePrice(i)+SnakePrice(j));
   j=j-1;
   i=i+1;
   w=w+1;
  end
  SnakeSum=SnakeSum+6*SnakePrice(Shift);
  SnakeWeight=36;
 end
 return SnakeSum/SnakeWeight;
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
 if period<first+Period then 
 return;
 end
   Mart[period]=SnakeCalc(period);

   if period<first+2*Period then 
 return;
 end
   
   Drawing(period);
 

 end
  


