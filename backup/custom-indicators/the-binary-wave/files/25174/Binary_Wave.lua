-- Id: 5727
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=12833

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
    indicator:name("Binary Wave indicator");
    indicator:description("Binary Wave indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("WeightMA", "Weight of MA", "", 1);
    indicator.parameters:addDouble("WeightMACD", "Weight of MACD", "", 1);
    indicator.parameters:addDouble("WeightH_MACD", "Weight of Histogram MACD", "", 1);
    indicator.parameters:addDouble("WeightCCI", "Weight of CCI", "", 1);
    indicator.parameters:addDouble("WeightMOM", "Weight of MOM", "", 1);
    indicator.parameters:addDouble("WeightRSI", "Weight of RSI", "", 1);
    indicator.parameters:addDouble("WeightDMI", "Weight of DMI", "", 1);

    indicator.parameters:addString("Price", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price", "close", "", "close");
    indicator.parameters:addStringAlternative("Price", "open", "", "open");
    indicator.parameters:addStringAlternative("Price", "high", "", "high");
    indicator.parameters:addStringAlternative("Price", "low", "", "low");
    indicator.parameters:addStringAlternative("Price", "median", "", "median");
    indicator.parameters:addStringAlternative("Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price", "weighted", "", "weighted");
    indicator.parameters:addInteger("MA_Period", "Period of MA", "", 13);
    indicator.parameters:addString("MA_Method", "Method of MA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("MA_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("MA_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("MA_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("MA_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("MA_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MA_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("MA_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("MA_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("MA_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("MA_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("MA_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("MA_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("MA_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("MA_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("MA_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("MA_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("MA_Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("MACD_Fast", "Fast period of MACD", "", 12);
    indicator.parameters:addInteger("MACD_Slow", "Slow period of MACD", "", 26);
    indicator.parameters:addInteger("MACD_Signal", "Signal period of MACD", "", 9);
    indicator.parameters:addInteger("CCI_Period", "Period of CCI", "", 14);
    indicator.parameters:addInteger("MOM_Period", "Period of Momentum", "", 14);
    indicator.parameters:addInteger("RSI_Period", "Period of RSI", "", 14);
    indicator.parameters:addInteger("DMI_Period", "Period of DMI", "", 14);
    indicator.parameters:addInteger("Smooth_Period", "Smooth Period", "", 20);
    indicator.parameters:addString("Smooth_Method", "Smooth Method", "", "MVA");
    indicator.parameters:addStringAlternative("Smooth_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Smooth_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Smooth_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Smooth_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Smooth_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Smooth_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Smooth_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Smooth_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Smooth_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Smooth_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Smooth_Method", "JSmooth", "", "JSmooth");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local WeightMA;
local WeightMACD;
local WeightH_MACD;
local WeightCCI;
local WeightMOM;
local WeightRSI;
local WeightDMI;
local Price;
local MA_Period;
local MA_Method;
local MACD_Fast;
local MACD_Slow;
local MACD_Signal;
local CCI_Period;
local MOM_Period;
local RSI_Period;
local DMI_Period;
local Smooth_Method;
local Smooth_Period;
local MA;
local MACD;
local CCI;
local MOM;
local RSI;
local DMI;
local TMP;
local Smooth_MA;
local Binary_Wave=nil;

 function Prepare(nameOnly)   
    source = instance.source;
	
	
	local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    WeightMA=instance.parameters.WeightMA;
    WeightMACD=instance.parameters.WeightMACD;
    WeightH_MACD=instance.parameters.WeightH_MACD;
    WeightCCI=instance.parameters.WeightCCI;
    WeightMOM=instance.parameters.WeightMOM;
    WeightRSI=instance.parameters.WeightRSI;
    WeightDMI=instance.parameters.WeightDMI;
    Price=instance.parameters.Price;
    MA_Period=instance.parameters.MA_Period;
    MA_Method=instance.parameters.MA_Method;
    MACD_Fast=instance.parameters.MACD_Fast;
    MACD_Slow=instance.parameters.MACD_Slow;
    MACD_Signal=instance.parameters.MACD_Signal;
    CCI_Period=instance.parameters.CCI_Period;
    MOM_Period=instance.parameters.MOM_Period;
    RSI_Period=instance.parameters.RSI_Period;
    DMI_Period=instance.parameters.DMI_Period;
    Smooth_Period=instance.parameters.Smooth_Period;
    Smooth_Method=instance.parameters.Smooth_Method;
   
    TMP=instance:addInternalStream(source:first(), 0);
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");   
    Smooth_MA=core.indicators:create("AVERAGES", TMP, Smooth_Method, Smooth_Period, false);
	
    local sourceT;
    if Price=="close" then
     sourceT=source.close;
    elseif Price=="open" then
     sourceT=source.open;
    elseif Price=="high" then
     sourceT=source.high;
    elseif Price=="low" then
     sourceT=source.low;
    elseif Price=="median" then
     sourceT=source.median;
    elseif Price=="typical" then
     sourceT=source.typical;
    else
     sourceT=source.weighted;
    end 
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	assert(core.indicators:findIndicator("MOMENTUM") ~= nil, "Please, download and install MOMENTUM.LUA indicator");    
	
    MA = core.indicators:create("AVERAGES", sourceT, MA_Method, MA_Period, false);
    MACD = core.indicators:create("MACD", sourceT, MACD_Fast, MACD_Slow, MACD_Signal);
    CCI = core.indicators:create("CCI", source, CCI_Period);
    MOM = core.indicators:create("MOMENTUM", sourceT, MOM_Period);
    RSI = core.indicators:create("RSI", sourceT, RSI_Period);
    DMI = core.indicators:create("DMI", source, DMI_Period);
	
	
	first = math.max( MA.DATA:first(), MACD.DATA:first(), CCI.DATA:first(), MOM.DATA:first(), RSI.DATA:first(), DMI.DATA:first());
    
    Binary_Wave = instance:addStream("Binary_Wave", core.Line, name .. ".Binary_Wave", "Binary_Wave", instance.parameters.clr, Smooth_MA.DATA:first());
    Binary_Wave:setWidth(instance.parameters.widthLinReg);
    Binary_Wave:setStyle(instance.parameters.styleLinReg);
	
	Binary_Wave:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    MA:update(mode);
    MACD:update(mode);
    CCI:update(mode);
    MOM:update(mode);
    RSI:update(mode);
    DMI:update(mode);
	
    local Sum=0;
    if source.close[period]>MA.DATA[period] then 
     Sum=Sum+WeightMA;
    elseif source.close[period]<MA.DATA[period] then
     Sum=Sum-WeightMA;
    end 
    if MACD.MACD[period]>MACD.MACD[period-1] then
     Sum=Sum+WeightMACD;
    elseif MACD.MACD[period]<MACD.MACD[period-1] then
     Sum=Sum-WeightMACD;
    end
    if MACD.HISTOGRAM[period]>0 then
     Sum=Sum+WeightH_MACD;
    elseif MACD.HISTOGRAM[period]<0 then
     Sum=Sum-WeightH_MACD;
    end
    if CCI.DATA[period]>0 then
     Sum=Sum+WeightCCI;
    elseif CCI.DATA[period]<0 then
     Sum=Sum-WeightCCI;
    end
    if MOM.DATA[period]>100 then
     Sum=Sum+WeightMOM;
    elseif MOM.DATA[period]<100 then
     Sum=Sum-WeightMOM;
    end
    if RSI.DATA[period]>50 then
     Sum=Sum+WeightRSI;
    elseif RSI.DATA[period]<50 then
     Sum=Sum-WeightRSI;
    end
    if DMI.DIP[period]>DMI.DIM[period] then
     Sum=Sum+WeightDMI;
    elseif DMI.DIP[period]<DMI.DIM[period] then
     Sum=Sum-WeightDMI;
    end
    TMP[period]=Sum;
    Smooth_MA:update(mode);
	
	if  period < Smooth_MA.DATA:first() then
	return;
	end
	
    Binary_Wave[period]=Smooth_MA.DATA[period];
 
end

