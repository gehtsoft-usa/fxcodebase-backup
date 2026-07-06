-- Id: 3790
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4104

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
    indicator:name("Oscillator of CCI fan");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period_1", "First period", "", 5);
    indicator.parameters:addString("Method", "Method", "", "Add");
    indicator.parameters:addStringAlternative("Method", "Add", "", "Add");
    indicator.parameters:addStringAlternative("Method", "Mult", "", "Mult");

    indicator.parameters:addInteger("K", "K", "", 2);
    indicator.parameters:addInteger("N", "Count of MA", "", 5);
    indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("Line_color", "Color of line", "Color of line", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UP_color", "Color of UP", "Color of UP", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DN_color", "Color of DN", "Color of DN", core.rgb(0, 0, 255));
end

local Period1;
local K;
local N;
local Method;

local first;
local source = nil;
local BuffLine=nil;
local BuffUP=nil;
local BuffDN=nil;

local Inds={};

function Prepare(nameOnly)
    Period1 = instance.parameters.Period_1;
    K = instance.parameters.K;
    N = instance.parameters.N;
    Method = instance.parameters.Method;
    source = instance.source;
    local Period=Period1;
    local name = profile:id() .. "(" .. source:name() .. ", " .. Period1 .. ", " .. K .. ", " .. N .. ", " .. Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    for i=1,N,1 do
     Ind=core.indicators:create("CCI", source, Period);
     Inds[i]=Ind;
     if Method=="Mult" then
      Period=Period*K;
     else
      Period=Period+K;
     end 
    end
    
    first = Inds[N].DATA:first()+2;
    
    BuffLine=instance:addStream("BuffLine", core.Line, name .. ".Line", "Line", instance.parameters.Line_color, first);
    BuffLine:setPrecision(math.max(2, instance.source:getPrecision()));
    BuffUP=instance:addStream("BuffUP", core.Bar, name .. ".UP", "UP", instance.parameters.UP_color, first);
    BuffUP:setPrecision(math.max(2, instance.source:getPrecision()));
    BuffDN=instance:addStream("BuffDN", core.Bar, name .. ".DN", "DN", instance.parameters.DN_color, first);
    BuffDN:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
 if (period>first) then
  Inds[1]:update(mode);
  local Res=0;
  for i=2,N,1 do
   Inds[i]:update(mode);
   if Inds[i].DATA[period]<Inds[i-1].DATA[period] then
    Res=Res+1;
   else
    Res=Res-1;
   end
  end
  Res=Res/(N-1);
  BuffLine[period]=Res;
  if Res>0 then
   BuffUP[period]=Res;
   BuffDN[period]=nil;
  else
   BuffDN[period]=Res;
   BuffUP[period]=nil;
  end
  
 end 
end

