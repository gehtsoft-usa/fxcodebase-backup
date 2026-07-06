-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41293
-- Id: 9335

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
    indicator:name("Wama indicator");
    indicator:description("Wama indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 15);
    indicator.parameters:addBoolean("UseDoubleSmooth", "Use double smooth", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local UseDoubleSmooth;
local EMA;
local SecondEMA;
local Buff;
local Period4, Period8, Period12;
local Wama=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    UseDoubleSmooth=instance.parameters.UseDoubleSmooth;
    Period4=math.floor(Period/4);
    Period8=math.floor(Period/8);
    Period12=math.floor(Period/12);
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Buff=instance:addInternalStream(0, 0);
    EMA = core.indicators:create("EMA", source, Period);
    SecondEMA = core.indicators:create("EMA", Buff, Period4);
    Wama = instance:addStream("Wama", core.Line, name .. ".Wama", "Wama", instance.parameters.clr, first);
    Wama:setWidth(instance.parameters.widthLinReg);
    Wama:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if period>first then
    EMA:update(mode);
    local vel=EMA.DATA[period]-EMA.DATA[period-Period4];
    local acc=EMA.DATA[period]-2*EMA.DATA[period-Period4]+EMA.DATA[period-Period8];
    local aaa=EMA.DATA[period]-3*EMA.DATA[period-Period4]+3*EMA.DATA[period-Period8]-EMA.DATA[period-Period12];
    if UseDoubleSmooth then
     Buff[period]=EMA.DATA[period]+vel+acc/2+aaa/6;
     SecondEMA:update(mode);
     Wama[period]=SecondEMA.DATA[period];
    else
     Wama[period]=EMA.DATA[period]+vel+acc/2+aaa/6;
    end
   end 
end

