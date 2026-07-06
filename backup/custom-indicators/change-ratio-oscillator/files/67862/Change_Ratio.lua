-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41580
-- Id: 9401

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
    indicator:name("Change ratio oscillator");
    indicator:description("Change ratio oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 3);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Lclr", "Level color", "Level color", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("Lwidth", "Level width", "Level width", 1, 1, 5);
    indicator.parameters:addInteger("Lstyle", "Level style", "Level style", core.LINE_DASH);
    indicator.parameters:setFlag("Lstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Range;
local ChangeRatio=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Range = instance:addInternalStream(0, 0);
    ChangeRatio = instance:addStream("ChangeRatio", core.Line, name .. ".ChangeRatio", "ChangeRatio", instance.parameters.clr, first);
    ChangeRatio:setPrecision(math.max(2, instance.source:getPrecision()));
    ChangeRatio:setWidth(instance.parameters.widthLinReg);
    ChangeRatio:setStyle(instance.parameters.styleLinReg);
    ChangeRatio:addLevel(-1, instance.parameters.Lstyle, instance.parameters.Lwidth, instance.parameters.Lclr);
    ChangeRatio:addLevel(-0.5, instance.parameters.Lstyle, instance.parameters.Lwidth, instance.parameters.Lclr);
    ChangeRatio:addLevel(0, instance.parameters.Lstyle, instance.parameters.Lwidth, instance.parameters.Lclr);
    ChangeRatio:addLevel(0.5, instance.parameters.Lstyle, instance.parameters.Lwidth, instance.parameters.Lclr);
    ChangeRatio:addLevel(1, instance.parameters.Lstyle, instance.parameters.Lwidth, instance.parameters.Lclr);
end

function Update(period, mode)
   if period>first then
    Range[period]=source.high[period]-source.low[period];
    if period>first+Period then
     local sum = mathex.sum(Range, period-Period+1, period);
     if sum==0 then
      ChangeRatio[period]=0;
     else
      ChangeRatio[period]=(source.close[period]-source.close[period-Period])/sum;
     end
    end
   end 
end

