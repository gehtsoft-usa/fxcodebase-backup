-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=11900
-- Id: 5577

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
    indicator:name("ATR channels indicator");
    indicator:description("ATR channels indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ATR_Period", "Period of ATR", "", 26);
    indicator.parameters:addInteger("MA_Period", "Period of MA", "", 16);
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
    indicator.parameters:addString("MA_Price", "Price of MA", "", "close");
    indicator.parameters:addStringAlternative("MA_Price", "close", "", "close");
    indicator.parameters:addStringAlternative("MA_Price", "open", "", "open");
    indicator.parameters:addStringAlternative("MA_Price", "high", "", "high");
    indicator.parameters:addStringAlternative("MA_Price", "low", "", "low");
    indicator.parameters:addStringAlternative("MA_Price", "median", "", "median");
    indicator.parameters:addStringAlternative("MA_Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("MA_Price", "weighted", "", "weighted");
    indicator.parameters:addDouble("Mult_Factor1", "Mult_Factor1", "", 1.6);
    indicator.parameters:addDouble("Mult_Factor2", "Mult_Factor2", "", 3.2);
    indicator.parameters:addDouble("Mult_Factor3", "Mult_Factor3", "", 4.8);

    indicator.parameters:addGroup("Cental Line Style");
    indicator.parameters:addColor("MainClr", "Central Line Color", "Line Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Central Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Central Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("1. Line Style");
    indicator.parameters:addColor("Band1U", "1. Upper Band Color", "Band Color", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Band1L", "1. Lower Band Color", "Band Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "1. Band Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style1", "1. Band Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("2. Line Style");
    indicator.parameters:addColor("Band2U", "2. Upper Band Color", "Band Color", core.rgb(192, 0, 0));	
    indicator.parameters:addColor("Band2L", "2. Lower Band Color", "Band Color", core.rgb(192, 0, 0));
	indicator.parameters:addInteger("width2", "2. Band Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style2", "2. Band Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("3. Line Style");
	indicator.parameters:addColor("Band3U", "3. Upper Band Color", "Band Color", core.rgb(128, 0, 0));
    indicator.parameters:addColor("Band3L", "3. Lower Band Color", "Band Color", core.rgb(128, 0, 0));
	indicator.parameters:addInteger("width3", "3. Band Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style3", "3. Band Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
end

local first;
local source = nil;
local ATR_Period;
local MA_Period;
local MA_Method;
local MA_Price;
local Mult_Factor1;
local Mult_Factor2;
local Mult_Factor3;
local MA;
local ATR;
local Main=nil;
local UpperBand1=nil;
local UpperBand2=nil;
local UpperBand3=nil;
local LowerBand1=nil;
local LowerBand2=nil;
local LowerBand3=nil;

function Prepare(nameOnly)
    source = instance.source;
    ATR_Period=instance.parameters.ATR_Period;
    MA_Period=instance.parameters.MA_Period;
    MA_Method=instance.parameters.MA_Method;
    MA_Price=instance.parameters.MA_Price;
    Mult_Factor1=instance.parameters.Mult_Factor1;
    Mult_Factor2=instance.parameters.Mult_Factor2;
    Mult_Factor3=instance.parameters.Mult_Factor3;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.ATR_Period .. ", " .. instance.parameters.MA_Period .. ", " .. instance.parameters.MA_Method .. ", " .. instance.parameters.MA_Price .. ", " .. instance.parameters.Mult_Factor1 .. ", " .. instance.parameters.Mult_Factor2 .. ", " .. instance.parameters.Mult_Factor3 .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	
    ATR = core.indicators:create("ATR", source, ATR_Period);

     MA = core.indicators:create("AVERAGES", source[MA_Price], MA_Method, MA_Period, false);
	 
	 first = math.max(MA.DATA:first(),ATR.DATA:first());
  
    Main = instance:addStream("Main", core.Line, name .. ".Main", "Main", instance.parameters.MainClr, first);
    UpperBand1 = instance:addStream("UpperBand1", core.Line, name .. ".UpperBand1", "UpperBand1", instance.parameters.Band1U, first);
    UpperBand2 = instance:addStream("UpperBand2", core.Line, name .. ".UpperBand2", "UpperBand2", instance.parameters.Band2U, first);
    UpperBand3 = instance:addStream("UpperBand3", core.Line, name .. ".UpperBand3", "UpperBand3", instance.parameters.Band3U, first);
    LowerBand1 = instance:addStream("LowerBand1", core.Line, name .. ".LowerBand1", "LowerBand1", instance.parameters.Band1L, first);
    LowerBand2 = instance:addStream("LowerBand2", core.Line, name .. ".LowerBand2", "LowerBand2", instance.parameters.Band2L, first);
    LowerBand3 = instance:addStream("LowerBand3", core.Line, name .. ".LowerBand3", "LowerBand3", instance.parameters.Band3L, first);
    Main:setWidth(instance.parameters.width);
    Main:setStyle(instance.parameters.style);
    UpperBand1:setWidth(instance.parameters.width1);
    UpperBand1:setStyle(instance.parameters.style1);
    UpperBand2:setWidth(instance.parameters.width2);
    UpperBand2:setStyle(instance.parameters.style2);
    UpperBand3:setWidth(instance.parameters.width3);
    UpperBand3:setStyle(instance.parameters.style3);
    LowerBand1:setWidth(instance.parameters.width1);
    LowerBand1:setStyle(instance.parameters.style1);
    LowerBand2:setWidth(instance.parameters.width2);
    LowerBand2:setStyle(instance.parameters.style2);
    LowerBand3:setWidth(instance.parameters.width3);
    LowerBand3:setStyle(instance.parameters.style3);
end

function Update(period, mode)
   
    MA:update(mode);
    ATR:update(mode);
	if (period<first) then
	return;
	end
	
    Main[period]=MA.DATA[period];
    UpperBand1[period]=MA.DATA[period]+ATR.DATA[period]*Mult_Factor1;
    UpperBand2[period]=MA.DATA[period]+ATR.DATA[period]*Mult_Factor2;
    UpperBand3[period]=MA.DATA[period]+ATR.DATA[period]*Mult_Factor3;
    LowerBand1[period]=MA.DATA[period]-ATR.DATA[period]*Mult_Factor1;
    LowerBand2[period]=MA.DATA[period]-ATR.DATA[period]*Mult_Factor2;
    LowerBand3[period]=MA.DATA[period]-ATR.DATA[period]*Mult_Factor3;
   
end

