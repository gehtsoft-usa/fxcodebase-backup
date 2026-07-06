-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3613
-- Id: 3297

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
    indicator:name("MA Squeeze indicator");
    indicator:description("MA Squeeze indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("MA1_Period", "MA1_Period", "", 5);
    indicator.parameters:addString("MA1_Method", "MA1_Method", "", "MVA");
    indicator.parameters:addStringAlternative("MA1_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA1_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA1_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("MA1_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA1_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("MA1_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("MA1_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("MA1_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MA1_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("MA1_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("MA1_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("MA1_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("MA1_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("MA1_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("MA1_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("MA1_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("MA1_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("MA1_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("MA1_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("MA1_Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addString("MA1_Price", "MA1_Price", "", "close");
    indicator.parameters:addStringAlternative("MA1_Price", "close", "", "close");
    indicator.parameters:addStringAlternative("MA1_Price", "open", "", "open");
    indicator.parameters:addStringAlternative("MA1_Price", "high", "", "high");
    indicator.parameters:addStringAlternative("MA1_Price", "low", "", "low");
    indicator.parameters:addStringAlternative("MA1_Price", "median", "", "median");
    indicator.parameters:addStringAlternative("MA1_Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("MA1_Price", "weighted", "", "weighted");
    indicator.parameters:addInteger("MA2_Period", "MA2_Period", "", 21);
    indicator.parameters:addString("MA2_Method", "MA2_Method", "", "MVA");
    indicator.parameters:addStringAlternative("MA2_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MA2_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MA2_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("MA2_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MA2_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("MA2_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("MA2_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("MA2_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MA2_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("MA2_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("MA2_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("MA2_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("MA2_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("MA2_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("MA2_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("MA2_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("MA2_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("MA2_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("MA2_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("MA2_Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addString("MA2_Price", "MA2_Price", "", "close");
    indicator.parameters:addStringAlternative("MA2_Price", "close", "", "close");
    indicator.parameters:addStringAlternative("MA2_Price", "open", "", "open");
    indicator.parameters:addStringAlternative("MA2_Price", "high", "", "high");
    indicator.parameters:addStringAlternative("MA2_Price", "low", "", "low");
    indicator.parameters:addStringAlternative("MA2_Price", "median", "", "median");
    indicator.parameters:addStringAlternative("MA2_Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("MA2_Price", "weighted", "", "weighted");
    indicator.parameters:addBoolean("ATR_Enable", "ATR_Enable", "", true);
    indicator.parameters:addInteger("ATR_Period", "ATR_Period", "", 50);
    indicator.parameters:addDouble("ATR_Coeff", "ATR_Coeff", "", 0.4);
    indicator.parameters:addInteger("ThresholdPips", "ThresholdPips", "", 15);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrMA1", "Color MA1", "Color MA1", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrMA2", "Color MA2", "Color MA2", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrSqueeze", "Color Squeeze", "Color Squeeze", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width", "width", "width", 1, 1, 5);
    indicator.parameters:addInteger("style", "style", "style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
end

local first;
local source = nil;
local MA1_Period;
local MA1_Method;
local MA1_Price;
local MA2_Period;
local MA2_Method;
local MA2_Price;
local ATR_Enable;
local ATR_Period;
local ATR_Coeff;
local ThresholdPips;
local MA1;
local MA2;
local ATR;
local Price1;
local Price2;
local BuffMA1=nil;
local BuffMA2=nil;
local BuffSq1=nil;
local BuffSq2=nil;

function Prepare(nameOnly)
    source = instance.source;
    MA1_Period=instance.parameters.MA1_Period;
    MA1_Method=instance.parameters.MA1_Method;
    MA1_Price=instance.parameters.MA1_Price;
    MA2_Period=instance.parameters.MA2_Period;
    MA2_Method=instance.parameters.MA2_Method;
    MA2_Price=instance.parameters.MA2_Price;
    ATR_Enable=instance.parameters.ATR_Enable;
    ATR_Period=instance.parameters.ATR_Period;
    ATR_Coeff=instance.parameters.ATR_Coeff;
    ThresholdPips=instance.parameters.ThresholdPips;
    if MA1_Price=="close" then
     Price1=source.close;
    elseif MA1_Price=="open" then
     Price1=source.open;
    elseif MA1_Price=="high" then
     Price1=source.high;
    elseif MA1_Price=="low" then
     Price1=source.low;
    elseif MA1_Price=="median" then
     Price1=source.median;
    elseif MA1_Price=="typical" then
     Price1=source.typical;
    else
     Price1=source.weighted;
    end 
    if MA2_Price=="close" then
     Price2=source.close;
    elseif MA2_Price=="open" then
     Price2=source.open;
    elseif MA2_Price=="high" then
     Price2=source.high;
    elseif MA2_Price=="low" then
     Price2=source.low;
    elseif MA2_Price=="median" then
     Price2=source.median;
    elseif MA2_Price=="typical" then
     Price2=source.typical;
    else
     Price2=source.weighted;
    end 

    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.MA1_Period .. ", " .. instance.parameters.MA1_Method .. ", " .. instance.parameters.MA1_Price .. ", " .. instance.parameters.MA2_Period .. ", " .. instance.parameters.MA2_Method .. ", " .. instance.parameters.MA2_Price .. ", " .. instance.parameters.ATR_Period .. ", " .. instance.parameters.ATR_Coeff .. ", " .. instance.parameters.ThresholdPips .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
     
    MA1 = core.indicators:create("AVERAGES", Price1, MA1_Method, MA1_Period, false);
    MA2 = core.indicators:create("AVERAGES", Price2, MA2_Method, MA2_Period, false);
    if ATR_Enable==true then
     ATR = core.indicators:create("ATR", source, ATR_Period);
     first = math.max(MA1.DATA:first(),MA2.DATA:first(),ATR.DATA:first())+2;
    else 
     first = math.max(MA1.DATA:first(),MA2.DATA:first())+2;
    end 
    BuffMA1 = instance:addStream("BuffMA1", core.Line, name .. ".MA1", "MA1", instance.parameters.clrMA1, first);
    BuffMA2 = instance:addStream("BuffMA2", core.Line, name .. ".MA2", "MA2", instance.parameters.clrMA2, first);
    BuffSq1 = instance:addStream("BuffSq1", core.Line, name .. ".Sq1", "Sq1", instance.parameters.clrSqueeze, first);
    BuffSq2 = instance:addStream("BuffSq2", core.Line, name .. ".Sq2", "Sq2", instance.parameters.clrSqueeze, first);
    BuffMA1:setWidth(instance.parameters.width);
    BuffMA1:setStyle(instance.parameters.style);
    BuffMA2:setWidth(instance.parameters.width);
    BuffMA2:setStyle(instance.parameters.style);
    BuffSq1:setWidth(instance.parameters.width);
    BuffSq1:setStyle(instance.parameters.style);
    BuffSq2:setWidth(instance.parameters.width);
    BuffSq2:setStyle(instance.parameters.style);
end

function Update(period, mode)
   if (period>first) then
    MA1:update(mode);
    MA2:update(mode);
    if ATR_Enable==true then
     ATR:update(mode);
    end
    BuffMA1[period]=MA1.DATA[period];
    BuffMA2[period]=MA2.DATA[period];
    local Delta;
    if ATR_Enable==true then
     Delta=ATR.DATA[period]*ATR_Coeff;
    else
     Delta=ThresholdPips*source:pipSize();
    end
    if math.abs(MA1.DATA[period]-MA2.DATA[period])<Delta then
     BuffSq1[period]=MA2.DATA[period]+Delta;
     BuffSq2[period]=MA2.DATA[period]-Delta;
    else
     BuffSq1[period]=nil;
     BuffSq2[period]=nil; 
    end
   end 
end

