-- Id: 4268
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
    indicator:name("Difference3 indicator");
    indicator:description("Difference3 indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PeriodMA", "Period of MA", "", 10);
    indicator.parameters:addInteger("MAShift", "MA shift", "", 10,0,1000);
    indicator.parameters:addInteger("PriceShift", "Price shift", "", 31,1000);
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

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Color 1", "Color 1", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr2", "Color 2", "Color 2", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clr3", "Color 3", "Color 3", core.rgb(0, 0, 255));
end

local first;
local source = nil;
local PeriodMA;
local MAShift;
local PriceShift;
local Method;
local MA;
local Buff1=nil;
local Buff2=nil;
local Buff3=nil;

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
	
    Buff1 = instance:addStream("Buff1", core.Line, name .. ".Line1", "Line1", instance.parameters.clr1, math.max(source:first(),first+MAShift ) );
    Buff2 = instance:addStream("Buff2", core.Line, name .. ".Line2", "Line2", instance.parameters.clr2, math.max(source:first(),first+MAShift ));
    Buff3 = instance:addStream("Buff3", core.Line, name .. ".Line3", "Line3", instance.parameters.clr3, math.max(source:first(),first+MAShift ));
    Buff1:addLevel(0);
	Buff1:setPrecision(math.max(2, instance.source:getPrecision()));
	Buff2:setPrecision(math.max(2, instance.source:getPrecision()));
	Buff3:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)

   if (period<first+MAShift)
   or (period<first+PriceShift)
   then
   return;
   end
   
    MA:update(mode);
    Buff1[period]=source[period]-MA.DATA[period];
    Buff2[period]=MA.DATA[period]-MA.DATA[period-MAShift];
  
  
    Buff3[period]=source[period]-source[period-PriceShift];
 
end

