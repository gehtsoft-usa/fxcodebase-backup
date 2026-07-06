-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65468

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
    indicator:name("Price prediction by Nearest Neighbor indicator");
    indicator:description("Price prediction by Nearest Neighbor indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Npast", "Past bars", "", 300);
    indicator.parameters:addInteger("Nfuture", "Future bars", "", 50);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Pclr", "Past color", "Past color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Pwidth", "Past line width", "Past line width", 1, 1, 5);
    indicator.parameters:addInteger("Pstyle", "Past line style", "Past line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Pstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Fclr", "Future color", "Future color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("Fwidth", "Future line width", "Future line width", 3, 1, 5);
    indicator.parameters:addInteger("Fstyle", "Future line style", "Future line style", core.LINE_DASH);
    indicator.parameters:setFlag("Fstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Npast;
local Nfuture;
local mx, sxx, denx, sxy;
local PBuff=nil;
local FBuff=nil;

function Prepare(nameOnly) 
    source = instance.source;
    Npast=instance.parameters.Npast;
    Nfuture=instance.parameters.Nfuture;
    first = source:first()+2;
	
	    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Npast .. ", " .. instance.parameters.Nfuture .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    mx = instance:addInternalStream(first, 0);
    sxx = instance:addInternalStream(first, 0);
    denx = instance:addInternalStream(first, 0);
    sxy = instance:addInternalStream(first, 0);

	
    PBuff = instance:addStream("PBuff", core.Line, name .. ".PBuff", "PBuff", instance.parameters.Pclr, first);
    PBuff:setWidth(instance.parameters.Pwidth);
    PBuff:setStyle(instance.parameters.Pstyle);
    FBuff = instance:addStream("FBuff", core.Line, name .. ".FBuff", "FBuff", instance.parameters.Fclr, first, Nfuture);
    FBuff:setWidth(instance.parameters.Fwidth);
    FBuff:setStyle(instance.parameters.Fstyle);
end

function Update(period, mode)
   if period==source:size()-1 then
    local my=0;
    local syy=0;
    local i;
    local y;
    for i=0, Npast-1, 1 do
     y=source[period-i];
     my=my+y;
     syy=syy+y*y;
    end
    local deny=syy*Npast-my*my;
    
    local kstart;
    if deny>0 then
      deny=math.sqrt(deny);
      kstart=first;
     local k;
     
     local x, xnew, xold;
     for k=kstart, period-Npast-Nfuture, 1 do
      if k==first then
       mx[first]=0;
       sxx[first]=0;
       for i=first, first+Npast-1, 1 do
        x=source[i];
        mx[first]=mx[first]+x;
        sxx[first]=sxx[first]+x*x;
       end
      else
       xnew=source[k+Npast-1];
       xold=source[k-1];
       mx[k]=mx[k-1]+xnew-xold;
       sxx[k]=sxx[k-1]+xnew*xnew-xold*xold;
      end
      denx[k]=sxx[k]*Npast-mx[k]*mx[k];
     end
     
     local b;
     local corrMax=0;
     local knn;
     local num, corr;
     for k=first, period-Npast-Nfuture, 1 do
      sxy[k]=0;
      for i=0, Npast-1, 1 do
       sxy[k]=sxy[k]+source[k+i]*source[period-Npast+i];
      end
      if denx[k]>0 then
       num=sxy[k]*Npast-mx[k]*my;
       corr=num/math.sqrt(denx[k])/deny;
       if corr>corrMax then
        corrMax=corr;
        knn=k;
        b=num/denx[k];
       end
      end
     end

     if knn==nil then
      return;
     end
     
     local delta=source[period-1]-b*source[knn+Npast-1];
     for i=0, Npast+Nfuture-1, 1 do
      if i<=Npast-1 then
       PBuff[period-Npast+i]=b*source[knn+i]+delta;
      end
      if i>=Npast-1 then
       FBuff[period+i-Npast]=b*source[knn+i]+delta;
      end
     end
     
    end
   end 
end

