-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59640
-- Id: 10203

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
    indicator:name("Simple Support/Resistance indicator");
    indicator:description("Simple Support/Resistance indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 15);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("Bars", "Count of bars", "", 30);
    indicator.parameters:addColor("Sclr", "Support color", "Support color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Swidth", "Support line width", "Support line width", 1, 1, 5);
    indicator.parameters:addInteger("Sstyle", "Support line style", "Support line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Sstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Rclr", "Resistance color", "Resistance color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Rwidth", "Resistance line width", "Resistance line width", 1, 1, 5);
    indicator.parameters:addInteger("Rstyle", "Resistance line style", "Resistance line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Rstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Bars;
local Support=nil;
local Resistance=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Bars=instance.parameters.Bars;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Support = instance:addStream("Support", core.Line, name .. ".Support", "Support", instance.parameters.Sclr, first);
    Support:setWidth(instance.parameters.Swidth);
    Support:setStyle(instance.parameters.Sstyle);
    Resistance = instance:addStream("Resistance", core.Line, name .. ".Resistance", "Resistance", instance.parameters.Rclr, first);
    Resistance:setWidth(instance.parameters.Rwidth);
    Resistance:setStyle(instance.parameters.Rstyle);
end

function Update(period, mode)
   if period>first+Period and period==source:size()-1 then
    local Min, Max = mathex.minmax(source, period-Period, period-1);
    local S=2*Min-Max;
    local R=2*Max-Min;
    core.drawLine(Support, core.rangeTo(period, Bars), S, period-Bars+1, S, period);
    core.drawLine(Resistance, core.rangeTo(period, Bars), R, period-Bars+1, R, period);
    Support[period-Bars]=nil;
    Resistance[period-Bars]=nil;
   end 
end

