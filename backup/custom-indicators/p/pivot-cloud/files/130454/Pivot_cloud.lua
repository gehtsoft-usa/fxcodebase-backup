-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69274


--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Pivot cloud");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addString("tf1", "Timeframe 1", "", "H1");
    indicator.parameters:setFlag("tf1", core.FLAG_PERIODS);
    indicator.parameters:addString("tf2", "Timeframe 2", "", "D1");
    indicator.parameters:setFlag("tf2", core.FLAG_PERIODS);

    indicator.parameters:addColor("pivot1_color", "Pivot 1 Color", "", core.colors().Green);
    indicator.parameters:addColor("pivot2_color", "Pivot 2 Color", "", core.colors().Blue);
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
    pivot2 = core.indicators:create("PIVOT", source, instance.parameters.tf2, "Pivot", "HIST");

    p1 = instance:addStream("Pivot 1", core.Line, name .. ".P1", "P1", instance.parameters.pivot1_color, 0);
    p2 = instance:addStream("Pivot 2", core.Line, name .. ".P2", "P2", instance.parameters.pivot2_color, 0);
    line1 = instance:addInternalStream(0, 0);
    line2 = instance:addInternalStream(0, 0);

    instance:createChannelGroup("Pivot Channel", "Pivot Channel", line1, line2, instance.parameters.pivot1_color, 100 - instance.parameters.transparency);
    core.host:execute("setTimer", 1, 1);
end

local loaded = false;

function Update(period, mode)
    pivot1:update(mode);
    pivot2:update(mode);

    p1[period] = pivot1.P[period];
    p2[period] = pivot2.P[period];
    line1[period] = pivot1.P[period];
    line2[period] = pivot2.P[period];
    if line1[period] > line2[period] then
        line1:setColor(period, instance.parameters.pivot1_color);
    else
        line1:setColor(period, instance.parameters.pivot2_color);
    end
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    if pivot1.P:size() ~= 0 and pivot2.P:size() ~= 0 then
        if not loaded then
            loaded = true;
            instance:updateFrom(0);
        end
    else
        loaded = false;
    end
end