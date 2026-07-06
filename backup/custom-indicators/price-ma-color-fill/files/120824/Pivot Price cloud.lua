-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=66607

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
    indicator:name("Pivot Price cloud");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addString("tf1", "Timeframe 1", "", "D1");
    indicator.parameters:setFlag("tf1", core.FLAG_PERIODS);

    indicator.parameters:addColor("pivot1_color", "Pivot Color", "", core.colors().Green);
    indicator.parameters:addColor("pivot2_color", "Price Color", "", core.colors().Blue);
    indicator.parameters:addInteger("transparency", "Transparency", "", 50, 0, 100);
end

local source, pivot1, pivot2, p1, p2, line1, line2;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    pivot1 = core.indicators:create("PIVOT", source, instance.parameters.tf1, "Pivot", "HIST");

    p1 = instance:addStream("Pivot", core.Line, name .. ".P1", "P1", instance.parameters.pivot1_color, 0);
    p2 = instance:addStream("Price", core.Line, name .. ".P2", "P2", instance.parameters.pivot2_color, 0);
    line1 = instance:addInternalStream(0, 0);
    line2 = instance:addInternalStream(0, 0);

    instance:createChannelGroup("Pivot Channel", "Pivot Channel", line1, line2, instance.parameters.pivot1_color, 100 - instance.parameters.transparency);
    core.host:execute("setTimer", 1, 1);
end

local loaded = false;

function Update(period, mode)
    pivot1:update(mode);

    p1[period] = pivot1.P[period];
    p2[period] = source.close[period];
    line1[period] = pivot1.P[period];
    line2[period] = source.close[period];
    if line1[period] > line2[period] then
        line1:setColor(period, instance.parameters.pivot1_color);
    else
        line1:setColor(period, instance.parameters.pivot2_color);
    end
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    if pivot1.P:size() ~= 0 then
        if not loaded then
            loaded = true;
            instance:updateFrom(0);
        end
    else
        loaded = false;
    end
end