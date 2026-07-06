-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10402
-- Id: 5401

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
    indicator:name("Percentage Crossover Channel indicator");
    indicator:description("Percentage Crossover Channel indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("percent", "percent", "", 1);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UpperClr", "Upper Color", "Upper Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("MiddleClr", "Middle Color", "Middle Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("LowerClr", "Lower Color", "Lower Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local percent;
local UpperBuff=nil;
local MiddleBuff=nil;
local LowerBuff=nil;
local PlusVar;
local MinusVar;

function Prepare(nameOnly)
    source = instance.source;
    percent=instance.parameters.percent;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.percent .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    UpperBuff = instance:addStream("UpperBuff", core.Line, name .. ".Upper", "Upper", instance.parameters.UpperClr, first);
    MiddleBuff = instance:addStream("MiddleBuff", core.Line, name .. ".Middle", "Middle", instance.parameters.MiddleClr, first);
    LowerBuff = instance:addStream("LowerBuff", core.Line, name .. ".Lower", "Lower", instance.parameters.LowerClr, first);
    UpperBuff:setWidth(instance.parameters.widthLinReg);
    UpperBuff:setStyle(instance.parameters.styleLinReg);
    MiddleBuff:setWidth(instance.parameters.widthLinReg);
    MiddleBuff:setStyle(instance.parameters.styleLinReg);
    LowerBuff:setWidth(instance.parameters.widthLinReg);
    LowerBuff:setStyle(instance.parameters.styleLinReg);
    local var1=percent/100;
    PlusVar=1+var1;
    MinusVar=1-var1;
end

function Update(period, mode)
   if (period>first) then
    if source[period]*MinusVar>MiddleBuff[period-1] then
     MiddleBuff[period]=source[period]*MinusVar;
    elseif source[period]*PlusVar<MiddleBuff[period-1] then
     MiddleBuff[period]=source[period]*PlusVar;
    else
     MiddleBuff[period]=MiddleBuff[period-1];  
    end
    UpperBuff[period]=MiddleBuff[period]*(1+percent/100);
    LowerBuff[period]=MiddleBuff[period]*(1-percent/100);
   elseif period==first then
    MiddleBuff[period]=source[period];  
   end 
end

