-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=21013
-- Id: 7002

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
    indicator:name("RSX indicator");
    indicator:description("RSX indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("DPeriod", "D Period", "", 15);
    indicator.parameters:addString("DMethod", "D Method", "", "MVA");
    indicator.parameters:addStringAlternative("DMethod", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("DMethod", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("DMethod", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("DMethod", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("DMethod", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("DMethod", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("DMethod", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("DMethod", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("DMethod", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("DMethod", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("DMethod", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("DMethod", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("DMethod", "T3", "", "T3");
    indicator.parameters:addStringAlternative("DMethod", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("DMethod", "Median", "", "Median");
    indicator.parameters:addStringAlternative("DMethod", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("DMethod", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("DMethod", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("DMethod", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("DMethod", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("DMethod", "JSmooth", "", "JSmooth");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 128, 128));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local DPeriod;
local DMethod;
local DPrice, AbsDPrice;
local DMA, AbsDMA;
local RSX=nil;

function Prepare(nameOnly)
    source = instance.source;
    DPeriod=instance.parameters.DPeriod;
    DMethod=instance.parameters.DMethod;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.DPeriod .. ", " .. instance.parameters.DMethod .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
   
    DPrice = instance:addInternalStream(0, 0);
    AbsDPrice = instance:addInternalStream(0, 0);
	
	
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");   

    DMA = core.indicators:create("AVERAGES", DPrice, DMethod, DPeriod, false);
    AbsDMA = core.indicators:create("AVERAGES", AbsDPrice, DMethod, DPeriod, false);
	first = AbsDMA.DATA:first();
	
    RSX = instance:addStream("RSX", core.Line, name .. ".RSX", "RSX", instance.parameters.clr, first);
    RSX:setPrecision(math.max(2, instance.source:getPrecision()));
    RSX:setWidth(instance.parameters.widthLinReg);
    RSX:setStyle(instance.parameters.styleLinReg);
    RSX:addLevel(30);
    RSX:addLevel(70);
end

function Update(period, mode)

    DPrice[period]=source[period]-source[period-1];
    AbsDPrice[period]=math.abs(DPrice[period]);
	
   if (period<first) then
   return;
   end
   
    DMA:update(mode);
    AbsDMA:update(mode);
    if (AbsDMA.DATA[period]==0) then
     RSX[period]=nil;
    else
     local RSX_=DMA.DATA[period]/AbsDMA.DATA[period];
     RSX_=math.max(math.min(RSX_,1),-1);
     RSX[period]=RSX_*50+50;
    end
    
end

