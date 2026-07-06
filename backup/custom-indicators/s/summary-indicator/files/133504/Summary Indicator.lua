

--http://fxcodebase.com/code/viewtopic.php?f=17&t=69797
-- More information about this indicator can be found at:

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                           mario.jemic@gmail.com  |
--|                          https://AppliedMachineLearning.systems  |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                                  Patreon: https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Summary Indicator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addString("value", "Value to show", "", "NetPL");
    indicator.parameters:addStringAlternative("value", "Net PL", "", "NetPL");
    indicator.parameters:addStringAlternative("value", "Gross PL", "", "GrossPL");
    indicator.parameters:addStringAlternative("value", "Buy Net PL", "", "BuyNetPL");
    indicator.parameters:addStringAlternative("value", "Sell Net PL", "", "SellNetPL");
    indicator.parameters:addStringAlternative("value", "Buy Avg Open", "", "BuyAvgOpen");
    indicator.parameters:addStringAlternative("value", "Sell Avg Open", "", "SellAvgOpen");
    indicator.parameters:addStringAlternative("value", "Buy Amount K", "", "BuyAmountK");
    indicator.parameters:addStringAlternative("value", "Sell Amount K", "", "SellAmountK");
    indicator.parameters:addStringAlternative("value", "Amount K", "", "AmountK");

    indicator.parameters:addColor("out_color", "Out Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("out_width", "Out Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("out_style", "Out Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("out_style", core.FLAG_LINE_STYLE);
end

local source, value, out;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    value = instance.parameters.value;
    if value == "NetPL" then
        out = instance:addStream("out", core.Line, "Net PL", "Net PL", instance.parameters.out_color, 0, 0);
    elseif value == "GrossPL" then
        out = instance:addStream("out", core.Line, "Gross PL", "Gross PL", instance.parameters.out_color, 0, 0);
    elseif value == "BuyNetPL" then
        out = instance:addStream("out", core.Line, "Buy Net PL", "Buy Net PL", instance.parameters.out_color, 0, 0);
    elseif value == "SellNetPL" then
        out = instance:addStream("out", core.Line, "Sell Net PL", "Sell Net PL", instance.parameters.out_color, 0, 0);
    elseif value == "BuyAvgOpen" then
        out = instance:addStream("out", core.Line, "Buy Avg Open", "Buy Avg Open", instance.parameters.out_color, 0, 0);
    elseif value == "SellAvgOpen" then
        out = instance:addStream("out", core.Line, "Sell Avg Open", "Sell Avg Open", instance.parameters.out_color, 0, 0);
    elseif value == "BuyAmountK" then
        out = instance:addStream("out", core.Line, "Buy Amount K", "Buy Amount K", instance.parameters.out_color, 0, 0);
    elseif value == "SellAmountK" then
        out = instance:addStream("out", core.Line, "Sell Amount K", "Sell Amount K", instance.parameters.out_color, 0, 0);
    elseif value == "AmountK" then
        out = instance:addStream("out", core.Line, "Amount K", "Amount K", instance.parameters.out_color, 0, 0);
    end
    out:setWidth(instance.parameters.out_width);
    out:setStyle(instance.parameters.out_style);
end

function Update(period, mode)
    if period ~= source:size() - 1 then
        return;
    end
    local summary = core.host:findTable("summary"):find("Instrument", source:instrument());
    if summary == nil then
        return;
    end
    if value == "NetPL" then
        out[period] = summary.NetPL;
    elseif value == "GrossPL" then
        out[period] = summary.GrossPL;
    elseif value == "BuyNetPL" then
        out[period] = summary.BuyNetPL;
    elseif value == "SellNetPL" then
        out[period] = summary.SellNetPL;
    elseif value == "BuyAvgOpen" then
        out[period] = summary.BuyAvgOpen;
    elseif value == "SellAvgOpen" then
        out[period] = summary.SellAvgOpen;
    elseif value == "BuyAmountK" then
        out[period] = summary.BuyAmountK;
    elseif value == "SellAmountK" then
        out[period] = summary.SellAmountK;
    elseif value == "AmountK" then
        out[period] = summary.AmountK;
    end
end