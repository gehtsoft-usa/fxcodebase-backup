-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=21013
-- Id: 7003

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
    indicator:name("RSX_S indicator");
    indicator:description("RSX_S indicator");
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
    indicator.parameters:addInteger("SPeriod", "S Period", "", 15);
    indicator.parameters:addString("SMethod", "S Method", "", "MVA");
    indicator.parameters:addStringAlternative("SMethod", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("SMethod", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("SMethod", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("SMethod", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("SMethod", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("SMethod", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("SMethod", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("SMethod", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("SMethod", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("SMethod", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("SMethod", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("SMethod", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("SMethod", "T3", "", "T3");
    indicator.parameters:addStringAlternative("SMethod", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("SMethod", "Median", "", "Median");
    indicator.parameters:addStringAlternative("SMethod", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("SMethod", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("SMethod", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("SMethod", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("SMethod", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("SMethod", "JSmooth", "", "JSmooth");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("RSX_UP_P_clr", "RSX UP Positive Color", "RSX UP Positive Color", core.rgb(0, 128, 128));
    indicator.parameters:addColor("RSX_UP_N_clr", "RSX UP Negative Color", "RSX UP Negative Color", core.rgb(255, 128, 255));
    indicator.parameters:addColor("RSX_DN_P_clr", "RSX DN Positive Color", "RSX DN Positive Color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("RSX_DN_N_clr", "RSX DN Negative Color", "RSX DN Negative Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Signal_UP_clr", "Signal UP Color", "Signal UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Signal_DN_clr", "Signal DN Color", "Signal DN Color", core.rgb(255, 128, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local DPeriod;
local DMethod;
local SPeriod;
local SMethod;
local DPrice, AbsDPrice;
local DMA, AbsDMA, SignalMA;
local RSX=nil;
local Signal=nil;

function Prepare(nameOnly)
    source = instance.source;
    DPeriod=instance.parameters.DPeriod;
    DMethod=instance.parameters.DMethod;
    SPeriod=instance.parameters.SPeriod;
    SMethod=instance.parameters.SMethod;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.DPeriod .. ", " .. instance.parameters.DMethod .. ", " .. instance.parameters.SPeriod .. ", " .. instance.parameters.SMethod .. ")";
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
    RSX = instance:addStream("RSX", core.Bar, name .. ".RSX", "RSX", instance.parameters.RSX_UP_P_clr, first);
    RSX:setPrecision(math.max(2, instance.source:getPrecision()));
    SignalMA = core.indicators:create("AVERAGES", RSX, SMethod, SPeriod, false);
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Signal_UP_clr, first);
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal:setWidth(instance.parameters.widthLinReg);
    Signal:setStyle(instance.parameters.styleLinReg);
    RSX:addLevel(50);
    RSX:addLevel(-50);
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
     RSX[period]=RSX_*100;
    end
    SignalMA:update(mode);
    Signal[period]=SignalMA.DATA[period];
    
    if RSX[period]>=0 then
     if RSX[period]>=RSX[period-1] then
      RSX:setColor(period, instance.parameters.RSX_UP_P_clr);
     else
      RSX:setColor(period, instance.parameters.RSX_DN_P_clr);
     end
    else
     if RSX[period]>=RSX[period-1] then
      RSX:setColor(period, instance.parameters.RSX_UP_N_clr);
     else
      RSX:setColor(period, instance.parameters.RSX_DN_N_clr);
     end
    end
    
    if Signal[period]>=Signal[period-1] then
     Signal:setColor(period, instance.parameters.Signal_UP_clr)
    else
     Signal:setColor(period, instance.parameters.Signal_DN_clr)
    end
 
end

