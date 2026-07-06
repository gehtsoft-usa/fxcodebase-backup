-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=68891

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
    indicator:name("Indic_BuySell");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("FontSize", "Font Size", "", 6, 4, 12);
    indicator.parameters:addColor("up_color", "Up Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("down_color", "Down Color", "", core.rgb(255, 0, 0));
end

local LOADING_ID = 2;
local LOADED_ID = 1;
local loading = true;
local source_bid;
local source_ask;
local source;
local buffer;
local buffer2;
local buffer3;
local atr, g_ibuf_84, g_ibuf_80;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), instance.source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    if instance.source:isBid() then
        source_bid = instance.source;
        source_ask = core.host:execute("getSyncHistory", instance.source:instrument(), instance.source:barSize(), false, 0, LOADED_ID, LOADING_ID);
    else
        source_ask = instance.source;
        source_bid = core.host:execute("getSyncHistory", instance.source:instrument(), instance.source:barSize(), true, 0, LOADED_ID, LOADING_ID);
    end

    buffer = instance:addInternalStream(0, 0);
    buffer2 = instance:addInternalStream(0, 0);
    buffer3 = instance:addInternalStream(0, 0);
    atr = core.indicators:create("ATR", source, 10);
    g_ibuf_80 = instance:createTextOutput("Upa", "Upa", "Wingdings", instance.parameters.FontSize, core.H_Center, core.V_Bottom, instance.parameters.up_color, 0);
    g_ibuf_84 = instance:createTextOutput("Dna", "Dna", "Wingdings", instance.parameters.FontSize, core.H_Center, core.V_Top, instance.parameters.down_color, 0);
end

function Update(period, mode)
    if loading or period < 1 then
        return;
    end
    atr:update(mode);
    local date = source:date(period);
    local ask_period = core.findDate(source_ask, date, false);
    local bid_period = core.findDate(source_bid, date, false);
    local spreadRate = source_ask.close[ask_period] - source_bid.close[bid_period];

    buffer[period] = math.max(
        math.abs(source.low[period] - source.close[period - 1]), 
        math.abs(spreadRate + source.high[period] - source.close[period - 1]), 
        spreadRate + source.high[period] - source.low[period]);

    if period < 8 then
        return;
    end
    local ld_68 = 0;
    for i = 0, 7 do
        ld_68 = ld_68 + buffer[period - i] * (i + 1);
    end
    ld_68 = 2.0 * ld_68 / (7 * (7 + 1.0));

    local ld_44 = 0.7 * ld_68;
    buffer2[period] = buffer2[period - 1];
    buffer3[period] = buffer3[period - 1];
    if buffer2[period] ~= -1 then 
        if source.low[period] < buffer3[period] - ld_44 then
            buffer2[period] = -1;
            buffer3[period] = spreadRate + source.high[period];
            g_ibuf_80:set(period, source.low[period] - atr.DATA[period] * 2 / 3.0, "\226");
        end
    else
        if spreadRate + source.high[period] > buffer3[period] + ld_44 then
            buffer2[period] = 1;
            buffer3[period] = source.low[period];
            g_ibuf_84:set(period, spreadRate + source.high[period] + atr.DATA[period] * 2 / 3.0, "\225");
        end
    end
    if buffer2[period] ~= -1 and source.low[period] > buffer3[period] then
        buffer3[period] = source.low[period];
    end
    if buffer2[period] ~= 1 and spreadRate + source.high[period] < buffer3[period] then
        buffer3[period] = spreadRate + source.high[period];
    end
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    if (cookie == LOADED_ID) then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == LOADING_ID then
        loading = true;
    end
end