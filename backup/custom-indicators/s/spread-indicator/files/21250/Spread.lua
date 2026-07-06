-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10150
-- Id: 5324

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
    indicator:name("Spread indicator");
    indicator:description("Spread indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 20);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("SignalClr", "Signal Color", "Signal Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local ask;
local bid;
local Spread=nil;
local Signal=nil;
local MA;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Spread = instance:addStream("Spread", core.Line, name .. ".Spread", "Spread", instance.parameters.Clr, first);
    Spread:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.SignalClr, first);
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    MA = core.indicators:create("MVA", Spread, Period);
    Spread:setWidth(instance.parameters.widthLinReg);
    Spread:setStyle(instance.parameters.styleLinReg);
    Signal:setWidth(instance.parameters.widthLinReg);
    Signal:setStyle(instance.parameters.styleLinReg);
    if source:isBid() then
     bid = source;
     ask = core.host:execute("getAskPrice");
    else
     ask = source;
     bid = core.host:execute("getBidPrice");
    end
    Spread:addLevel(0);
end

function Update(period, mode)
   if (period>first) then
    Spread[period]=(ask.open[period]-bid.open[period])/source:pipSize();
    MA:update(mode);
    Signal[period]=MA.DATA[period];
   end 
end

