-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41457
-- Id: 9386

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
    indicator:name("Custom price indicator");
    indicator:description("Custom price indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("C_Open", "Coefficient for Open price", "", 1);
    indicator.parameters:addDouble("C_High", "Coefficient for High price", "", 0);
    indicator.parameters:addDouble("C_Low", "Coefficient for Low price", "", 0);
    indicator.parameters:addDouble("C_Close", "Coefficient for Close price", "", 0);
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

    indicator.parameters:addInteger("Period", "Period", "", 20);
    indicator.parameters:addBoolean("ColorMode", "ColorMode", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MainClr", "Main color", "Main color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local C_Open;
local C_High;
local C_Low;
local C_Close;
local Method;
local Period;
local ColorMode;
local CPrice;
local MA;
local CPrice_MA = nil;
local C_Sum;

function Prepare(nameOnly)
    source = instance.source;
    C_Open=instance.parameters.C_Open;
    C_High=instance.parameters.C_High;
    C_Low=instance.parameters.C_Low;
    C_Close=instance.parameters.C_Close;
    Method=instance.parameters.Method;
    Period=instance.parameters.Period;
    ColorMode=instance.parameters.ColorMode;
    C_Sum = C_Open+C_High+C_Low+C_Close;
    assert(C_Sum~=0, "Sum of the coefficients can not be equal zero!");
   
    local name = profile:id() .. "(" .. source:name() .. ", ";
    if C_Open~=0 then
     name = name .. C_Open .. "*Open+";
    end
    if C_High~=0 then
     name = name .. C_High .. "*High+";
    end
    if C_Low~=0 then
     name = name .. C_Low .. "*Low+";
    end
    if C_Close~=0 then
     name = name .. C_Close .. "*Close+";
    end
    name = string.sub(name, 1, string.len(name)-1);
    name = name .. ")/" .. C_Sum .. ", " .. Method .. ", " .. Period;
    instance:name(name);
    if nameOnly then
        return;
    end
    CPrice=instance:addInternalStream(0, 0);
	
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	
    MA = core.indicators:create("AVERAGES", CPrice, Method, Period, false);
	
	 first = MA.DATA:first();
    CPrice_MA = instance:addStream("CPrice_MA", core.Line, name .. ".CPrice_MA", "CPrice_MA", instance.parameters.MainClr, first);
    CPrice_MA:setWidth(instance.parameters.widthLinReg);
    CPrice_MA:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if (period<source:first()) then
   return;
   end
   
    CPrice[period] = (C_Open*source.open[period]+C_High*source.high[period]+C_Low*source.low[period]+C_Close*source.close[period])/C_Sum;
    MA:update(mode);
	
	 if (period< first) then
   return;
   end
   
    CPrice_MA[period]=MA.DATA[period];
    if ColorMode then
     if CPrice_MA[period]>=CPrice_MA[period-1] then
      CPrice_MA:setColor(period, instance.parameters.UPclr);
     else
      CPrice_MA:setColor(period, instance.parameters.DNclr);
     end
   end 
   
end

