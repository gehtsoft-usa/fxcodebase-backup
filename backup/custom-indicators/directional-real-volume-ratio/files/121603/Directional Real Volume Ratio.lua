-- Id: 22461
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66830

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("Directional Real Volume Ratio");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volume Indicators");

    indicator.parameters:addColor("clrV", "Indicator Color", "", core.rgb(65, 105, 225));
end

local source;
local indi;
local buy_stream;
local sell_stream;

function Prepare(nameOnly)
    assert(instance.source:supportsVolume(), "The source must have volume");

    source = instance.source;

    local name = profile:id() .. "(" .. instance.source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    indicator = core.indicators:create("DIRECTIONAL_REAL_VOLUME", source);
    buy_stream = indicator:getStream(0);
    sell_stream = indicator:getStream(1);
    V = instance:addStream("Rate", core.Line, name, "Rate", instance.parameters.clrV, 0);
	V:setPrecision(math.max(2, instance.source:getPrecision()));
    core.host:execute("setTimer", 100, 1);
end

function Update(period, mode)
    indicator:update(core.UpdateLast);
    if buy_stream:hasData(period) and sell_stream:hasData(period) then
        if (sell_stream:tick(period) < 0) then
            V[period] = buy_stream:tick(period) / (-sell_stream:tick(period));
        end
    end
end

local first = true;
function IndiHasData()
    for i = 0, buy_stream:size() - 1 do
        if buy_stream:hasData(i) then
            return true;
        end
    end
    return false;
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == 100 then
        core.host:trace(tostring(buy_stream:size()) .. " " .. tostring(buy_stream:hasData(NOW)));
        if buy_stream:size() <= 1 or not IndiHasData() then
            first = true;
        elseif first then
            first = false;
            instance:updateFrom(0);
        end
    end
end
