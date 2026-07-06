-- Id: 3432
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3728

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
    indicator:name("Diff MA Histogram indicator");
    indicator:description("Diff MA Histogram indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 10);
    indicator.parameters:addString("Price", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price", "close", "", "close");
    indicator.parameters:addStringAlternative("Price", "open", "", "open");
    indicator.parameters:addStringAlternative("Price", "high", "", "high");
    indicator.parameters:addStringAlternative("Price", "low", "", "low");
    indicator.parameters:addStringAlternative("Price", "median", "", "median");
    indicator.parameters:addStringAlternative("Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price", "weighted", "", "weighted");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP", "Color UP", "Color UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN", "Color DN", "Color DN", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local SourcePrice;
local Period;
local Price;
local Diff;
local BuffUP=nil;
local BuffDN=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Price=instance.parameters.Price;
    if Price=="close" then
     SourcePrice=source.close;
    elseif Price=="open" then
     SourcePrice=source.open;
    elseif Price=="high" then
     SourcePrice=source.high;
    elseif Price=="low" then
     SourcePrice=source.low;
    elseif Price=="median" then
     SourcePrice=source.median;
    elseif Price=="typical" then
     SourcePrice=source.typical;
    else
     SourcePrice=source.weighted;
    end 
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. " " .. instance.parameters.Price .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Diff = instance:addInternalStream(first, 0);
    BuffUP = instance:addStream("BuffUP", core.Bar, name .. ".UP", "UP", instance.parameters.clrUP, first);
    BuffUP:setPrecision(math.max(2, instance.source:getPrecision()));
    BuffDN = instance:addStream("BuffDN", core.Bar, name .. ".DN", "DN", instance.parameters.clrDN, first);
    BuffDN:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    local CountUP=0;
    local SumUP=0;
    local CountDN=0;
    local SumDN=0;
    local i=period;
    while i>=first and (CountUP<Period or CountDN<Period) do
     if source.close[i]>source.open[i] and CountUP<Period then
      CountUP=CountUP+1;
      SumUP=SumUP+SourcePrice[i];
     end
     if source.close[i]<source.open[i] and CountDN<Period then
      CountDN=CountDN+1;
      SumDN=SumDN+SourcePrice[i];
     end
     i=i-1;
    end
    if CountUP>0 and CountDN>0 then
     local MA_UP=SumUP/CountUP;
     local MA_DN=SumDN/CountDN;
     Diff[period]=MA_UP-MA_DN;
     if Diff[period]>Diff[period-1] then
      BuffUP[period]=Diff[period];
      BuffDN[period]=nil;
     elseif Diff[period]<Diff[period-1] then
      BuffDN[period]=Diff[period];
      BuffUP[period]=nil;
     end
    else
     BuffUP[period]=nil; 
     BuffDN[period]=nil;
    end 
   
end

