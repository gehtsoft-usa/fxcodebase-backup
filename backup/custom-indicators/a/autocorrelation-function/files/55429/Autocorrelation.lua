-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32538
-- Id: 8610

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
    indicator:name("Autocorrelation indicator");
    indicator:description("Autocorrelation indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Length", "Length", "", 100);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Length;
local A=nil;

function Prepare(nameOnly)
    source = instance.source;
    Length=instance.parameters.Length;
    first = source:first()+Length;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Length .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    A = instance:addStream("A", core.Line, name .. ".A", "A", instance.parameters.clr, first);
    A:setPrecision(math.max(2, instance.source:getPrecision()));
    A:setWidth(instance.parameters.widthLinReg);
    A:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if period<first or  period<source:size()-1 then
   return;
   end
   
    local i1, i2;
    local sum;
    local sumx, sumy = 0, 0;
    local SKO = 0;
    local v1, v2 = 0, 0;
    local last=source:size()-1;
    for i1=0,Length,1 do
     SKO=SKO+source[last-i1]*source[last-i1];
     sumx=sumx+source:date(last-i1)-source:date(last-Length);
     sumy=sumy+source[last-i1];
    end
    SKO=SKO/Length;
    sumx=sumx/(Length+1);
    sumy=sumy/(Length+1);
    for i1=0,Length-1,1 do
     v1=v1+(source:date(last-i1)-source:date(last-Length)-sumx)*(source[last-i1]-sumy);
     v2=v2+(source:date(last-i1)-source:date(last-Length)-sumx)*(source:date(last-i1)-source:date(last-Length)-sumx);
    end
    v1=v1/v2;
    v2=sumy-v1*sumx;
    
    for i1=0,Length,1 do
     sum=0;
     for i2=0,Length,1 do
      if i1+i2<=Length then
       sum=sum+(source[last-i2]-v1*(source:date(last-i2)-source:date(last-Length))-v2)*(source[last-i2-i1]-v1*(source:date(last-i2-i1)-source:date(last-Length))-v2);
      end
     end
     A[last-i1]=sum/SKO;
    end
    
    for i1=Length,0,-1 do
     A[last-i1]=A[last-i1]/A[last];
    end
    
 
end

