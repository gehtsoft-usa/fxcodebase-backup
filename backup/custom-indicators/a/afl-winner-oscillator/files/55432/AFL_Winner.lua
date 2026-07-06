-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32539
-- Id: 8613

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
    indicator:name("AFL_Winner oscillator");
    indicator:description("AFL_Winner oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Periods", "Periods", "", 10);
    indicator.parameters:addInteger("Average", "Average", "", 5);
    indicator.parameters:addString("Method", "Method", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
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
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Periods;
local Average;
local Method;
local HBuff=nil;
local LBuff=nil;
local Cost;
local pa;
local rsv;
local MA1, MA2;

function Prepare(nameOnly)
    source = instance.source;
    Periods=instance.parameters.Periods;
    Average=instance.parameters.Average;
    Method=instance.parameters.Method;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Periods .. ", " .. instance.parameters.Average .. ", " .. instance.parameters.Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Cost = instance:addInternalStream(first, 0);
    pa = instance:addInternalStream(first, 0);
    rsv = instance:addInternalStream(first, 0);
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");   
    MA1 = core.indicators:create("AVERAGES", rsv, Method, Average, false);
    MA2 = core.indicators:create("AVERAGES", MA1.DATA, Method, Average, false);
    HBuff = instance:addStream("HBuff", core.Line, name .. ".HBuff", "HBuff", instance.parameters.UPclr, MA2.DATA:first());
    HBuff:setPrecision(math.max(2, instance.source:getPrecision()));
    LBuff = instance:addStream("LBuff", core.Line, name .. ".LBuff", "LBuff", instance.parameters.UPclr,  MA2.DATA:first());
    LBuff:setPrecision(math.max(2, instance.source:getPrecision()));
    HBuff:setWidth(instance.parameters.widthLinReg);
    HBuff:setStyle(instance.parameters.styleLinReg);
    LBuff:setWidth(instance.parameters.widthLinReg);
    LBuff:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if period>first then
    Cost[period]=source.volume[period]*(2*source.close[period]+source.high[period]+source.low[period])/4;
    if period>first+math.max(Average, Periods) then
     local SumCost=mathex.sum(Cost, core.rangeTo(period, Average));
     local SumVolume=mathex.sum(source.volume, core.rangeTo(period, Average));
     if SumVolume~=0 then
      pa[period]=SumCost/SumVolume;
     else
      pa[period]=0;
     end 
     local min, max = mathex.minmax(pa, core.rangeTo(period, Periods));
     if min~=max then
      rsv[period]=100*(pa[period]-min)/(max-min);
     else
      rsv[period]=0;
     end
     MA1:update(mode);
     MA2:update(mode);
	 
	  if period > MA2.DATA:first() then
     
			 HBuff[period]=MA1.DATA[period];
			 LBuff[period]=MA2.DATA[period];
			 if HBuff[period]>=LBuff[period] then
			  HBuff:setColor(period, instance.parameters.UPclr);
			  LBuff:setColor(period, instance.parameters.UPclr);
			 else
			  HBuff:setColor(period, instance.parameters.DNclr);
			  LBuff:setColor(period, instance.parameters.DNclr);
			 end 
	  end		 
    end 
   end 
end

