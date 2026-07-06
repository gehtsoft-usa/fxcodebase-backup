-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7888

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
    indicator:name("AFIRMA indicator");
    indicator:description("AFIRMA indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 4);
    indicator.parameters:addInteger("Taps", "Taps", "", 21);
    indicator.parameters:addString("Window", "Window", "", "Rectangular");
    indicator.parameters:addStringAlternative("Window", "Rectangular", "", "Rectangular");
    indicator.parameters:addStringAlternative("Window", "Hanning", "", "Hanning");
    indicator.parameters:addStringAlternative("Window", "Hamming", "", "Hamming");
    indicator.parameters:addStringAlternative("Window", "Blackman", "", "Blackman");
    indicator.parameters:addStringAlternative("Window", "Blackman-Harris", "", "Blackman-Harris");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Color 1", "Color 1", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr2", "Color 2", "Color 2", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Taps;
local Window;
local AFIRMA=nil;
local w={};
local wsum;
local n,sx2,sx3,sx4,sx5,sx6,den;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Taps=instance.parameters.Taps;
    Window=instance.parameters.Window;
	
	 local i;
    wsum=0;
    for i=0,Taps-1,1 do
     if Window=="Rectangular" then
      w[i]=1;
     elseif Window=="Hanning" then
      w[i]=0.5-0.5*math.cos(2*math.pi*i/Taps);
     elseif Window=="Hamming" then
      w[i]=0.54-0.46*math.cos(2*math.pi*i/Taps);
     elseif Window=="Blackman" then
      w[i]=0.42-0.5*math.cos(2*math.pi*i/Taps)+0.08*math.cos(4*math.pi*i/Taps);
     else
      w[i]=0.35875-0.48829*math.cos(2*math.pi*i/Taps)+0.14128*math.cos(4*math.pi*i/Taps)-0.01168*math.cos(6*math.pi*i/Taps);
     end
     if i~=Taps/2 then
      w[i]=w[i]*math.sin(math.pi*(i-Taps/2.0)/Period)/math.pi/(i-Taps/2.0);
     end 
     wsum=wsum+w[i];
    end
    n=math.floor((Taps-1)/2);
    sx2=(2*n+1)/3;
    sx3=n*(n+1)/2;
    sx4=sx2*(3*n*n+3*n-1)/5;
    sx5=sx3*(2*n*n+2*n-1)/3;
    sx6=sx2*(3*n*n*n*(n+2)-3*n+1)/7;
    den=sx6*sx4/sx5-sx5;
	
	
    first = source:first()+n;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Taps .. ", " .. instance.parameters.Window .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    AFIRMA = instance:addStream("AFIRMA", core.Line, name .. ".AFIRMA", "AFIRMA", instance.parameters.clr1, first);
    AFIRMA:setWidth(instance.parameters.widthLinReg);
    AFIRMA:setStyle(instance.parameters.styleLinReg);
   
end

function Update(period, mode)
   if (period<first) then
   return;
   end
    local i;
    local Sum=0;
    for i=0,Taps-1,1 do
     Sum=Sum+source[period-i]*w[i]/wsum;
    end
    AFIRMA[period-n]=Sum;
    AFIRMA:setColor(period-n,instance.parameters.clr1);
    if period==source:size()-1 then
     local a0=AFIRMA[source:size()-1-n];
     local a1=AFIRMA[source:size()-1-n]-AFIRMA[source:size()-2-n];
     local sx2y=0;
     local sx3y=0;
     for i=0,n,1 do
      sx2y=sx2y+i*i*source[period-n+i];
      sx3y=sx3y+i*i*i*source[period-n+i];
     end
     sx2y=2*sx2y/(n*(n+1));
     sx3y=2*sx3y/(n*(n+1));
     local p=sx2y-a0*sx2-a1*sx3;
     local q=sx3y-a0*sx3-a1*sx4;
     local a2=(p*sx6/sx5-q)/den;
     local a3=(q*sx4/sx5-p)/den;
     local k;
     for k=0,n,1 do
      i=period-n+k;
      AFIRMA[i]=a0+k*a1+k*k*a2+k*k*k*a3;
      AFIRMA:setColor(i,instance.parameters.clr2);
     end 
    end 
    
 
end

