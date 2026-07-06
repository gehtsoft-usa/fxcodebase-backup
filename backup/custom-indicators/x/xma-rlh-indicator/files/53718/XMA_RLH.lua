-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=31487
-- Id: 8421

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
    indicator:name("XMA_RLH indicator");
    indicator:description("XMA_RLH indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method1", "Method1", "", "EMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method1", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method1", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method1", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method1", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method1", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method1", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method1", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method1", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method1", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method1", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method1", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method1", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method1", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method1", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method1", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method1", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("Period1", "Period1", "", 12);
    indicator.parameters:addString("Method2", "Method2", "", "EMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method2", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method2", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method2", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method2", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method2", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method2", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method2", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method2", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method2", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method2", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method2", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method2", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method2", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method2", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method2", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method2", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("Period2", "Period2", "", 5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MA1clr", "MA1 Color", "MA1 Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("MA2clr", "MA2 Color", "MA2 Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Resclr", "Res Color", "Res Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Method1;
local Period1;
local Method2;
local Period2;
local MA1;
local MA2
local Buff1=nil;
local Buff2=nil;
local ResBuff=nil;

function Prepare(nameOnly)
    source = instance.source;
    Method1=instance.parameters.Method1;
    Period1=instance.parameters.Period1;
    Method2=instance.parameters.Method2;
    Period2=instance.parameters.Period2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Method1 .. ", " .. instance.parameters.Period1 .. ", " .. instance.parameters.Method2 .. ", " .. instance.parameters.Period2 .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");  
    
    MA1 = core.indicators:create("AVERAGES", source, Method1, Period1, false);
    MA2 = core.indicators:create("AVERAGES", MA1.DATA, Method2, Period2, false);
	
	first = math.max( MA1.DATA:first(),MA2.DATA:first());
	
    Buff1 = instance:addStream("Buff1", core.Line, name .. ".MA1", "MA1", instance.parameters.MA1clr, first);
    Buff2 = instance:addStream("Buff2", core.Line, name .. ".MA2", "MA2", instance.parameters.MA2clr, first);
    ResBuff = instance:addStream("ResBuff", core.Line, name .. ".Res", "Res", instance.parameters.Resclr, first);
    Buff1:setWidth(instance.parameters.widthLinReg);
    Buff1:setStyle(instance.parameters.styleLinReg);
    Buff2:setWidth(instance.parameters.widthLinReg);
    Buff2:setStyle(instance.parameters.styleLinReg);
    ResBuff:setWidth(instance.parameters.widthLinReg);
    ResBuff:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if (period>first) then
    MA1:update(mode);
    MA2:update(mode);
    Buff1[period]=MA1.DATA[period];
    Buff2[period]=MA2.DATA[period];
    ResBuff[period]=2*MA1.DATA[period]-MA2.DATA[period];
   end 
end

