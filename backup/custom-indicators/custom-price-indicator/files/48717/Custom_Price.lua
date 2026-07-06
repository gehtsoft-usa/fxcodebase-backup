-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27801
-- Id: 8144

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

    indicator.parameters:addGroup("Style");
    indicator.parameters:addString("Type", "Type", "", "Dot");
    indicator.parameters:addStringAlternative("Type", "Dot", "", "Dot");
    indicator.parameters:addStringAlternative("Type", "Line", "", "Line");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
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
local CPrice = nil;
local C_Sum;

function Prepare(nameOnly)
    source = instance.source;
    C_Open=instance.parameters.C_Open;
    C_High=instance.parameters.C_High;
    C_Low=instance.parameters.C_Low;
    C_Close=instance.parameters.C_Close;
    C_Sum = C_Open+C_High+C_Low+C_Close;
    assert(C_Sum~=0, "Sum of the coefficients can not be equal zero!");
    first = source:first()+2;
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
    name = name .. ")/" .. C_Sum;
--    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.C_Open .. ", " .. instance.parameters.C_High .. ", " .. instance.parameters.C_Low .. ", " .. instance.parameters.C_Close .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    if instance.parameters.Type=="Dot" then
     CPrice = instance:addStream("CPrice", core.Dot, name .. ".CPrice", "CPrice", instance.parameters.clr, first);
     CPrice:setWidth(instance.parameters.widthLinReg);
    else
     CPrice = instance:addStream("CPrice", core.Line, name .. ".CPrice", "CPrice", instance.parameters.clr, first);
     CPrice:setWidth(instance.parameters.widthLinReg);
     CPrice:setStyle(instance.parameters.styleLinReg);
    end 
end

function Update(period, mode)
   if (period>first) then
    CPrice[period] = (C_Open*source.open[period]+C_High*source.high[period]+C_Low*source.low[period]+C_Close*source.close[period])/C_Sum;
   end 
end

