-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41308
-- Id: 9348

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
    indicator:name("Linreg indicator");
    indicator:description("Linreg indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 13);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Linreg=nil;
local per1, per2, SumBars, SumSqrBars;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+Period ;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Linreg = instance:addStream("Linreg", core.Line, name .. ".Linreg", "Linreg", instance.parameters.clr, first);
    Linreg:setWidth(instance.parameters.widthLinReg);
    Linreg:setStyle(instance.parameters.styleLinReg);
    per1=Period-1;
    per2=Period*per1;
    SumBars=per2*0.5;
    SumSqrBars=per2*(2*Period-1)/6;
end

function Update(period, mode)
   if period>first then
    local SumY, Sum1 = 0, 0;
    local i;
    for i=0, Period-1, 1 do
     SumY=SumY+source[period-i];
     Sum1=Sum1+source[period-i]*i;
    end
    local Sum2=SumBars*SumY;
    local Num1=Period*Sum1-Sum2;
    local Num2=SumBars*SumBars-Period*SumSqrBars;
    local Slope=0;
    if Num2~=0 then
     Slope=Num1/Num2;
    end
    local Intercept=(SumY-Slope*SumBars)/Period;
    Linreg[period]=Intercept+Slope*per1;
   end 
end

