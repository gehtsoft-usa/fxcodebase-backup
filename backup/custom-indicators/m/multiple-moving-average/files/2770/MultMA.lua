-- Id: 989
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1419

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
    indicator:name("Multiple Moving Average");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 5);
    indicator.parameters:addInteger("Mode", "Mode", "Mode", 3);
    indicator.parameters:addString("MA_Method", "Method of MA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("MA_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "TMA", "", "TMA");
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color of MA", "Color of MA", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

end

local Period;
local Mode;
local MA_Method;

local first;
local source = nil;
local MA;
local source_MA;

local Inds={};
local fac={};

function Prepare(nameOnly)
    Period = instance.parameters.Period;
    Mode = instance.parameters.Mode;
    MA_Method = instance.parameters.MA_Method;
    source = instance.source;
    source_MA=source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ", " .. Mode .. ", " .. MA_Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    fac[0]=1;
    for i=1,Mode,1 do
    assert(core.indicators:findIndicator(MA_Method) ~= nil, MA_Method .. " indicator must be installed");
     Ind=core.indicators:create(MA_Method, source_MA, Period);
     Inds[i]=Ind;
     source_MA=Ind.DATA;
     fac[i]=fac[i-1]*i;
    end
    
    first = Inds[Mode].DATA:first()+2;
    
    MA = instance:addStream("Mult_MA", core.Line, name .. ".Mult_MA", "Mult_MA", instance.parameters.clr, first);
	MA:setWidth(instance.parameters.width);
    MA:setStyle(instance.parameters.style);
end

function Update(period, mode)
 if (period>first) then
  for i=1,Mode,1 do
   Inds[i]:update(mode);
  end
  
  local sum=0.;
  local Z=1;
  for i=1,Mode,1 do
   sum=sum+Z*Inds[i].DATA[period]*fac[Mode]/(fac[i]*fac[Mode-i]);
   Z=Z*(-1);
  end
  MA[period]=sum;

 end 
end

