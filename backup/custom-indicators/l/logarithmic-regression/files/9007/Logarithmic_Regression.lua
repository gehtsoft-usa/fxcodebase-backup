-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3716
-- Id: 3421

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Logarithmic regression indicator");
    indicator:description("Logarithmic regression indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 50);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 1);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrReg", "Color regression", "Color regression", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrBand", "Color band", "Color band", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width", "width", "width", 1, 1, 5);
    indicator.parameters:addInteger("style", "style", "style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
end

local first;
local source = nil;
local Period;
local Deviation;
local BuffReg=nil;
local BuffBandUp=nil;
local BuffBandDn=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Deviation=instance.parameters.Deviation;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Deviation .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    BuffReg = instance:addStream("BuffReg", core.Line, name .. ".Regression", "Regression", instance.parameters.clrReg, first);
    BuffBandUp = instance:addStream("BuffBandUp", core.Line, name .. ".BandUp", "BandUp", instance.parameters.clrBand, first);
    BuffBandDn = instance:addStream("BuffBandDn", core.Line, name .. ".BandDn", "BandDn", instance.parameters.clrBand, first);
    BuffReg:setWidth(instance.parameters.width);
    BuffReg:setStyle(instance.parameters.style);
    BuffBandUp:setWidth(instance.parameters.width);
    BuffBandUp:setStyle(instance.parameters.style);
    BuffBandDn:setWidth(instance.parameters.width);
    BuffBandDn:setStyle(instance.parameters.style);
end

function Update(period, mode)
   if (period==source:size()-1) then
    local i,ii;
    local sumxvalue={};
    local sumyvalue={};
    local constant={};
    local matrix={};
    local pos=period-Period+1;
    
    for i=0,3,1 do
     sumyvalue[i]=0;
     constant[i]=0;
     matrix[i]={};
     for ii=0,3,1 do
      matrix[i][ii]=0;
     end
    end
    for i=0,7,1 do
     sumxvalue[i]=0;
    end
    sumxvalue[0]=Period;
    local exp;
    for exp=1,2,1 do
     local sumx=0;
     local sumy=0;
     local k;
     for k=1,Period,1 do
      local lnx=math.log(k);
      sumx=sumx+math.pow(lnx,exp);
      if exp==1 then
       sumy=sumy+math.log(source[pos+k-1]);
      else
       sumy=sumy+math.log(source[pos+k-1])*math.pow(lnx,exp-1);
      end
     end
     sumxvalue[exp]=sumx;
     if sumy~=0 then
      sumyvalue[exp-1]=sumy;
     end
    end

    local row;
    local col;
    for row=0,1,1 do
     for col=0,1,1 do
      matrix[row][col]=sumxvalue[row+col];
     end
    end  
    sumyvalue[1]=sumyvalue[1]-(matrix[1][0]/matrix[0][0])*sumyvalue[0];
    matrix[1][1]=matrix[1][1]-(matrix[1][0]/matrix[0][0])*matrix[0][1];
    
    constant[1]=sumyvalue[1]/matrix[1][1];
    local a=(sumyvalue[0]-(constant[1]*matrix[0][1]))/matrix[0][0];
    constant[0]=math.exp(a);
    
    k=1;
    for i=period-Period+1,period,1 do
     BuffReg[i]=constant[0]*math.pow(k,constant[1]);
     k=k+1;
    end
    BuffReg[period-Period]=nil;
    
    sum=0;
    for i=period-Period+1,period,1 do
     sum=sum+math.pow(source[i]-BuffReg[i],2)
    end
    local variance=math.sqrt(sum/Period);
    for i=period-Period+1,period,1 do
     BuffBandUp[i]=BuffReg[i]+Deviation*variance;
     BuffBandDn[i]=BuffReg[i]-Deviation*variance;
    end
    BuffBandUp[period-Period]=nil;
    BuffBandDn[period-Period]=nil;
    
   end 
end

