-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69797


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

    indicator.parameters:addBoolean("all_trades", "All Trades", "", true);
    indicator.parameters:addString("Trade", "Choose Trade", "", "");
    indicator.parameters:setFlag("Trade", core.FLAG_TRADE);

    indicator.parameters:addColor("out_color", "Out Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("out_width", "Out Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("out_style", "Out Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("out_style", core.FLAG_LINE_STYLE);
end

local source, value, out, all_trades;
function Prepare(nameOnly)
    source = instance.source;
    all_trades = instance.parameters.all_trades;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    out = instance:addStream("out", core.Line, "PL", "PL", instance.parameters.out_color, 0, 0);
    out:setWidth(instance.parameters.out_width);
    out:setStyle(instance.parameters.out_style);
end

function Update(period, mode)
    if period ~= source:size() - 1 then
        out[period] = 0;
        return;
    end
    
    if all_trades then
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        local pl = 0;
        while row ~= nil do
            if row.Instrument == source:instrument() then
                pl = pl + row.PL;
            end
            row = enum:next();
        end
        out[period] = pl * source:pipSize();
    else
        trade = core.host:findTable("trades"):find("TradeID", instance.parameters.Trade);
        if trade == nil then
            out[period] = 0;
            return;
        end
        out[period] = trade.PL * source:pipSize();
    end
end