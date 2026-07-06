-- Id: 14524
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62457

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Freedom of Movement oscillator");
    indicator:description("Freedom of Movement oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 10);
    indicator.parameters:addString("Method", "Method", "", "MVA");
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
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Method;
local MA, StdDev;
local RV;
local aMove;
local vByM;
local MAF, StdDevF;
local FoM=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Method=instance.parameters.Method;
    
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");  
	assert(core.indicators:findIndicator("STDDEV") ~= nil, "Please, download and install STDDEV.LUA indicator");  
	
    MA=core.indicators:create("AVERAGES", source.volume, Method, Period, false);
    StdDev=core.indicators:create("STDDEV", source.volume, Period);
	first = StdDev.DATA:first();
    RV=instance:addInternalStream(0, 0);
    aMove=instance:addInternalStream(0, 0);
    vByM=instance:addInternalStream(0, 0);
    MAF=core.indicators:create("AVERAGES", vByM, Method, Period, false);
    StdDevF=core.indicators:create("STDDEV", vByM, Period);
    FoM = instance:addStream("FoM", core.Line, name .. ".FoM", "FoM", instance.parameters.clr, MAF.DATA:first());
    FoM:setPrecision(math.max(2, instance.source:getPrecision()));
    FoM:setWidth(instance.parameters.widthLinReg);
    FoM:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if period<first then
   return;
   end
   
   
    MA:update(mode);
    StdDev:update(mode);
    local av=MA.DATA[period];
    local sd=StdDev.DATA[period];
    if sd~=0 then
     RV[period]=(source.volume[period]-av)/sd;
    else
     RV[period]=nil;
    end
    aMove[period]=math.abs(source.close[period]-source.close[period-1])/source.close[period-1];
	
	
	  if period<first+Period then
   return;
   end
	
    local Min, Max=mathex.minmax(aMove, period-Period+1, period);
    local denom=-1;
    if Max-Min~=0 then
     denom=Max-Min;
    end
    local Move=1+9*(aMove[period]-Min)/math.abs(denom);
    local MinV, MaxV=mathex.minmax(RV, period-Period+1, period);
    local denomV=-1;
    if MaxV-MinV~=0 then
     denomV=MaxV-MinV;
    end
    local Vol=1+9*(RV[period]-MinV)/math.abs(denomV);
    vByM[period]=Vol/Move;
    MAF:update(mode);
    StdDevF:update(mode);
	
	if period < MAF.DATA:first() then
	return;
	end
	
    local avF=MAF.DATA[period];
    local sdF=StdDevF.DATA[period];
    if sdF~=0 then
     FoM[period]=(vByM[period]-avF)/sdF;
    else
     FoM[period]=nil;
    end 
  
end

