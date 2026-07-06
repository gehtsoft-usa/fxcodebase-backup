-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2430
-- Id: 3468

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("Averages indicator");
    indicator:description("Averages indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");
 
    indicator.parameters:addInteger("Period", "Period", "", 20);
    indicator.parameters:addBoolean("ColorMode", "ColorMode", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MainClr", "Main color", "Main color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Method;
local Period;
local MA;
local Array1;
local Array2;
local Array3;
local Array4;
local Array5;
local Array6;
local Arrays={};
local MainBuff=nil;
local UPBuff=nil;
local DNBuff=nil;
local ColorMode;

function Prepare(nameOnly)
    source = instance.source;
    Method=instance.parameters.Method;
    Period=instance.parameters.Period;
    ColorMode=instance.parameters.ColorMode;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Method .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    MA = instance:addInternalStream(first+Period, 0);
    Array1 = instance:addInternalStream(first, 0);
    Array2 = instance:addInternalStream(first, 0);
    Array3 = instance:addInternalStream(first, 0);
    Array4 = instance:addInternalStream(first, 0);
    Array5 = instance:addInternalStream(first, 0);
    Array6 = instance:addInternalStream(first, 0);
    Arrays[1]=Array1;
    Arrays[2]=Array2;
    Arrays[3]=Array3;
    Arrays[4]=Array4;
    Arrays[5]=Array5;
    Arrays[6]=Array6;
    MainBuff = instance:addStream("MainBuff", core.Line, name .. ".MA", "MA", instance.parameters.MainClr, first);
    UPBuff = instance:addStream("UPBuff", core.Line, name .. ".UP", "UP", instance.parameters.UPclr, first);
    DNBuff = instance:addStream("DNBuff", core.Line, name .. ".DN", "DN", instance.parameters.DNclr, first);
    MainBuff:setWidth(instance.parameters.widthLinReg);
    MainBuff:setStyle(instance.parameters.styleLinReg);
    UPBuff:setWidth(instance.parameters.widthLinReg);
    UPBuff:setStyle(instance.parameters.styleLinReg);
    DNBuff:setWidth(instance.parameters.widthLinReg);
    DNBuff:setStyle(instance.parameters.styleLinReg);
end

function MVA(Price,shift,MAarray,Period_)
 if shift>first+Period_ then
  return core.avg(Price,core.rangeTo(shift,Period_));
 elseif shift>=first then
  return core.avg(Price,core.range(first,shift));
 else return 0; 
 end 
end

function EMA(Price,shift,MAarray,Period_)
 if shift==first then
  return Price[shift];
 else
  return MAarray[shift-1]+2/(1+Period_)*(Price[shift]-MAarray[shift-1]);
 end
end

function Wilder(Price,shift,MAarray,Period_)
 if shift>=first and shift<=first+Period_ then
  return MVA(Price,shift,MAarray,Period_);
 elseif shift>first+Period_ then
  return MAarray[shift-1]+(Price[shift]-MAarray[shift-1])/Period_;
 end
end

function LWMA(Price,shift,MAarray,Period_)
 if shift>first+Period_ then
  local Weight=0;
  local Sum=0;
  local i;
  for i=0,Period_-1,1 do
   Weight=Weight+(Period_-i);
   Sum=Sum+Price[shift-i]*(Period_-i);
  end
  if Weight>0 then
   return Sum/Weight;
  else
   return 0; 
  end
 else
  return 0; 
 end 
end

function SineWMA(Price,shift,MAarray,Period_)
 if shift>=first then
  local Sum=0;
  local Weight=0;
  local i;
  r=core.range(math.max(shift-Period_+1,first),shift);
  for i=r.from,shift,1 do
   Weight=Weight+math.sin(math.pi*(shift-i+1)/(Period_+1));
   Sum=Sum+Price[i]*math.sin(math.pi*(shift-i+1)/(Period_+1));
  end
  if Weight>0 then
   return Sum/Weight;
  else
   return 0;
  end
 end 
end

function TriMA(Price,shift,MAarray,Period_)
 if shift>=first+Period_ then
  local len=math.ceil((Period_+1)/2);
  local Sum=0;
  local i;
  for i=0,len-1,1 do
   Sum=Sum+MVA(Price,shift-i,MAarray,len);
  end
  return Sum/len;
 end 
end

function LSMA(Price,shift,MAarray,Period_)
 if shift>=first+Period_ then
  local Sum=0;
  local i;
  for i=1,Period_,1 do
   Sum=Sum+(i-(Period_+1)/3)*Price[shift-Period_+i];
  end
  return Sum*6/(Period_*(Period_+1));
 end 
end

function SMMA(Price,shift,MAarray,Period_)
 if shift==first+Period_ then
  return MVA(Price,shift,MAarray,Period_);
 elseif shift>first+Period_ then
  local Sum=0;
  local i;
  for i=0,Period_-1,1 do
   Sum=Sum+Price[shift-i-1];
  end
  return (Sum-MAarray[shift-1]+Price[shift])/Period_;
 end
end

function HMA(Price,shift,MAarray,Period_)
 local len=math.floor(math.sqrt(Period_));
 if shift==first+Period_+len then
  return Price[shift];
 elseif shift>first+Period_+len then
  local i;
  for i=0,len-1,1 do
   Array1[first+Period_+len-1-i]=2*LWMA(Price,shift-i,MAarray,math.floor(Period_/2))-LWMA(Price,shift-i,MAarray,Period_);
  end
  return LWMA(Array1,first+Period_+len-1,MAarray,len-1);
 end
end

function ZeroLagEMA(Price,shift,MAarray,Period_)
 local Alpha=2/(Period_+1);
 local lag=math.ceil((Period_-1)/2);
 if shift<=first+lag then
  return Price[shift];
 else
  return Alpha*(2*Price[shift]-Price[shift-lag])+(1-Alpha)*MAarray[shift-1];
 end
 
end

function DEMA(Price,shift,MAarray,Period_,v,num)
 if shift<=first+2 then
  Arrays[num][shift]=Price;
  Arrays[num+1][shift]=Price;
  return Price;
 else
  Arrays[num][shift]=Arrays[num][shift-1]+2/(1+Period_)*(Price-Arrays[num][shift-1]);
  Arrays[num+1][shift]=Arrays[num+1][shift-1]+2/(1+Period_)*(Arrays[num][shift]-Arrays[num+1][shift-1]);
  return (1+v)*Arrays[num][shift]-v*Arrays[num+1][shift];
 end
end

function T3(Price,shift,MAarray,Period_,v)
 if shift<=first+2 then
  Arrays[1][shift]=Price[shift];
  Arrays[2][shift]=Price[shift];
  Arrays[3][shift]=Price[shift];
  Arrays[4][shift]=Price[shift];
  Arrays[5][shift]=Price[shift];
  Arrays[6][shift]=Price[shift];
  return Price[shift];
 else
  local dema1=DEMA(Price[shift],shift,MAarray,Period_,v,1);
  local dema2=DEMA(dema1,shift,MAarray,Period_,v,3);
  return DEMA(dema2,shift,MAarray,Period_,v,5);
 end
end

function ITrend(Price,shift,MAarray,Period_)
 local Alpha=2/(Period_+1);
 if shift>first+7 then
  return (Alpha-0.25*Alpha*Alpha)*Price[shift]+0.5*Alpha*Alpha*Price[shift-1]-(Alpha-0.75*Alpha*Alpha)*Price[shift-2]+2*(1-Alpha)*MAarray[shift-1]-(1-Alpha)*(1-Alpha)*MAarray[shift-2];
 else
  return (Price[shift]+2*Price[shift-1]+Price[shift-2])/4;
 end
end

function Median(Price,shift,MAarray,Period_)
 if shift>=first+Period_ then
  local PrArray={};
  local i;
  for i=1,Period_,1 do
   PrArray[i]=Price[shift-i+1];
  end
  table.sort(PrArray);
  local num=math.ceil((Period_-1)/2);
  if num*2==Period_-1 then
   return PrArray[num];
  else
   return (PrArray[num]+PrArray[num+1])/2;
  end
 end 
end

function GeoMean(Price,shift,MAarray,Period_)
 if shift>=first+Period_ then
  local gmean=math.pow(Price[shift],1/Period_);
  local i;
  for i=1,Period_-1,1 do
   gmean=gmean*math.pow(Price[shift-i],1/Period_);
  end
  return gmean;
 end 
end

function REMA(Price,shift,MAarray,Period_)
 local Alpha=2/(Period_+1);
 local Lambda=0.5;
 if shift<=first+3 then
  return Price[shift];
 else
  return (MAarray[shift-1]*(1+2*Lambda)+Alpha*(Price[shift]-MAarray[shift-1])-Lambda*MAarray[shift-2])/(1+Lambda);
 end
end

function ILRS(Price,shift,MAarray,Period_)
 local sum=Period_*(Period_-1)*0.5;
 local sum2=(Period_-1)*Period_*(2*Period_-1)/6;
 local sum1=0;
 local sumy=0;
 local i;
 for i=0,Period_-1,1 do
  sum1=sum1+i*Price[shift-i];
  sumy=sumy+Price[shift-i];
 end
 local num1=Period_*sum1-sum*sumy;
 local num2=sum*sum-Period_*sum2;
 local slope;
 if num2~=0 then
  slope=num1/num2;
 else
  slope=0;
 end
 return slope+MVA(Price,shift,MAarray,Period_);
end

function IE(Price,shift,MAarray,Period_)
 if shift>=first+Period_ then
  return 0.5*(ILRS(Price,shift,MAarray,Period_)+LSMA(Price,shift,MAarray,Period_));
 end 
end

function TriMAgen(Price,shift,MAarray,Period_)
 if shift>=first+Period_ then
  local len1=math.floor((Period_+1)/2);
  local len2=math.ceil((Period_+1)/2);
  local sum=0;
  local i;
  for i=0,len2-1,1 do
   sum=sum+MVA(Price,shift-i,MAarray,len1);
  end
  return sum/len2;
 end 
end

function JSmooth(Price,shift,MAarray,Period_)
 local Alpha=0.45*(Period_-1)/(0.45*(Period_-1)+2);
 if shift<=first+2 then
  Arrays[1][shift]=Price[shift];
  Arrays[2][shift]=0;
  Arrays[3][shift]=Price[shift];
  Arrays[4][shift]=0;
  Arrays[5][shift]=Price[shift];
  return Price[shift];
 else
  Arrays[1][shift]=(1-Alpha)*Price[shift]+Alpha*Arrays[1][shift-1];
  Arrays[2][shift]=(Price[shift]-Arrays[1][shift])*(1-Alpha)+Alpha*Arrays[2][shift-1];
  Arrays[3][shift]=Arrays[1][shift]+Arrays[2][shift];
  Arrays[4][shift]=(Arrays[3][shift]-Arrays[5][shift-1])*math.pow((1-Alpha),2)+math.pow(Alpha,2)*Arrays[4][shift-1];
  Arrays[5][shift]=Arrays[5][shift-1]+Arrays[4][shift];
  return Arrays[5][shift];
 end
end



function Update(period, mode)
 local i;
   if (period>=first) then
    if Method=="MVA" then
     MA[period]=MVA(source,period,MA,Period);
    elseif Method=="EMA" then
     MA[period]=EMA(source,period,MA,Period);
    elseif Method=="Wilder" then 
     MA[period]=Wilder(source,period,MA,Period);
    elseif Method=="LWMA" then 
     MA[period]=LWMA(source,period,MA,Period);
    elseif Method=="SineWMA" then 
     MA[period]=SineWMA(source,period,MA,Period);
    elseif Method=="TriMA" then 
     MA[period]=TriMA(source,period,MA,Period);
    elseif Method=="LSMA" then 
     MA[period]=LSMA(source,period,MA,Period);
    elseif Method=="SMMA" then 
     MA[period]=SMMA(source,period,MA,Period);
    elseif Method=="HMA" then
     MA[period]=HMA(source,period,MA,Period);
    elseif Method=="ZeroLagEMA" then
     MA[period]=ZeroLagEMA(source,period,MA,Period);
    elseif Method=="DEMA" then
     MA[period]=DEMA(source[period],period,MA,Period,1,1);
    elseif Method=="T3" then 
     MA[period]=T3(source,period,MA,Period,0.7);
    elseif Method=="ITrend" then 
     MA[period]=ITrend(source,period,MA,Period);
    elseif Method=="Median" then 
     MA[period]=Median(source,period,MA,Period);
    elseif Method=="GeoMean" then 
     MA[period]=GeoMean(source,period,MA,Period);
    elseif Method=="REMA" then 
     MA[period]=REMA(source,period,MA,Period);
    elseif Method=="ILRS" then 
     MA[period]=ILRS(source,period,MA,Period);
    elseif Method=="IE/2" then 
     MA[period]=IE(source,period,MA,Period);
    elseif Method=="TriMAgen" then 
     MA[period]=TriMAgen(source,period,MA,Period);
    elseif Method=="JSmooth" then 
     MA[period]=JSmooth(source,period,MA,Period);
    end
    
    if MA[period]~=0 then
     if ColorMode==false then
      MainBuff[period]=MA[period];
     else
      if MA[period]>MA[period-1] then
       UPBuff[period]=MA[period];
       if MA[period-1]<MA[period-2] then
        UPBuff[period-1]=MA[period-1];
       end
      else
       DNBuff[period]=MA[period];
       if MA[period-1]>MA[period-2] then
        DNBuff[period-1]=MA[period-1];
       end
      end
     end 
    end 
   end 
    
end

