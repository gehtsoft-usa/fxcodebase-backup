-- Id: 4269
-- More information about this indicator can be found at:
-- https://localhost:44310/Admin/Users

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
    indicator:name("Difference3 trigger indicator");
    indicator:description("Difference3 trigger indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PeriodMA", "Period of MA", "", 10);
    indicator.parameters:addInteger("MAShift", "MA shift", "", 10,0,1000);
    indicator.parameters:addInteger("PriceShift", "Price shift", "", 31,0,1000);
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
    indicator.parameters:addBoolean("UseMethod1", "Use method 1", "", true);
    indicator.parameters:addBoolean("UseMethod2", "Use method 2", "", true);
    indicator.parameters:addBoolean("UseMethod3", "Use method 3", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP", "Color UP", "Color UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN", "Color DN", "Color DN", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local PeriodMA;
local MAShift;
local PriceShift;
local Method;
local MA;
local Diff3=nil;

function Prepare(nameOnly)
    source = instance.source;
    PeriodMA=instance.parameters.PeriodMA;
    MAShift=instance.parameters.MAShift;
    PriceShift=instance.parameters.PriceShift;
    Method=instance.parameters.Method;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.PeriodMA .. ", " .. instance.parameters.MAShift .. ", " .. instance.parameters.PriceShift .. ", " .. instance.parameters.Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
    MA = core.indicators:create("AVERAGES", source, Method, PeriodMA, false);	
	first = MA.DATA:first();
	
    Diff3 = instance:addStream("Diff3", core.Bar, name .. ".Diff3", "Diff3", instance.parameters.clrUP,  math.max(source:first(),first+MAShift ));
	Diff3:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   local Trigger=0; 
   if (period<first+PriceShift)
   or (period<first+MAShift) then
   return;
   end
   
    MA:update(mode);
    local Res1=source[period]-MA.DATA[period];
    local Res2=MA.DATA[period]-MA.DATA[period-MAShift];
    if instance.parameters.UseMethod1 then
     if Res1>0 then
      Trigger=Trigger+1;
     elseif Res1<0 then
      Trigger=Trigger-1;
     end
    end 
    if instance.parameters.UseMethod2 then
     if Res2>0 then
      Trigger=Trigger+1;
     elseif Res2<0 then
      Trigger=Trigger-1;
     end
    end 
  
  
    local Res3=source[period]-source[period-PriceShift];
    if instance.parameters.UseMethod3 then
     if Res3>0 then
      Trigger=Trigger+1;
     elseif Res3<0 then
      Trigger=Trigger-1;
     end
    end 
 
   Diff3[period]=Trigger;
   if Trigger>0 then
    Diff3:setColor(period,instance.parameters.clrUP);
   else
    Diff3:setColor(period,instance.parameters.clrDN);
   end
end

