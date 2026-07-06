-- Id:
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66856

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
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
    indicator:name("Williams’s highs and lows")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addInteger("Size1", "Arrow Size", "", 15)
    indicator.parameters:addInteger("Size2", "Font Size", "", 15)
    indicator.parameters:addColor("clrUP", "Up Color", "", core.COLOR_UPCANDLE)
    indicator.parameters:addColor("clrDN", "Down Color", "", core.COLOR_DOWNCANDLE)
    indicator.parameters:addBoolean("ShowPrice", "Show Price", "", false)
    indicator.parameters:addColor("clrPrice", "Label Color", "", core.rgb(128, 128, 128))
end

local source
local up, down
local Size1, Size2
local alto, basso;
function Prepare(nameOnly)
    source = instance.source

    Size1 = instance.parameters.Size1
    Size2 = instance.parameters.Size2

    local name = profile:id() .. "(" .. source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    up = instance:createTextOutput("Up", "Up", "Wingdings", Size1, core.H_Center, core.V_Top, instance.parameters.clrUP, 0)
    down = instance:createTextOutput("Dn", "Dn", "Wingdings", Size1, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0)
    up1 = instance:createTextOutput("", "UpL", "Arial", Size2, core.H_Right, core.V_Top, instance.parameters.clrPrice, 0)
    down1 = instance:createTextOutput("", "DnL", "Arial", Size2, core.H_Right, core.V_Bottom, instance.parameters.clrPrice, 0)
    alto = instance:addInternalStream(0, 0);
    basso = instance:addInternalStream(0, 0);
end
local MARK_UP = 1;
local SHORT_MARK_UP = 2;
local MEDIUM_MARK_UP = 3;
local REF_HIGH = 4;
local MARK_DOWN = 5;
local SHORT_MARK_DOWN = 6;
local MEDIUM_MARK_DOWN = 7;
local REF_LOW = 8;
local LONG_MARK_DOWN = 9;
local LONG_MARK_UP = 10;
local IM_LOW_OLD = 11;
local IM_LOW_NEW = 12;
local IM_HIGH_OLD = 13;
local IM_HIGH_NEW = 14;
local UP_BOOK = 15;
local DOWN_BOOK = 16;
local TREND = 17;
function Update(period, mode)
    if period == 0 then
        alto[period] = source.high[period];
        basso[period] = source.low[period];
        basso:setBookmark(MARK_UP, period);
        return;
    else
        alto[period] = alto[period - 1];
        basso[period] = basso[period - 1];
    end

    if not (source.high[period] < source.high[period - 1] and source.low[period] > source.low[period - 1]) then
        if (source.high[period] > alto[period - 1]) then
            alto[period] = source.high[period];
            basso[period] = source.low[period];
            basso:setBookmark(MARK_UP, period);
        end
        if (source.low[period] < basso[period - 1]) then
            alto[period] = source.high[period]
            basso[period] = source.low[period]
            basso:setBookmark(MARK_DOWN, period);
        end
    end

    if alto[period] < alto[period - 1] and basso:getBookmark(TREND) ~= 0 then
        basso:setBookmark(TREND, 0)
        basso:setBookmark(LONG_MARK_UP, basso:getBookmark(MEDIUM_MARK_UP))
        basso:setBookmark(MEDIUM_MARK_UP, basso:getBookmark(SHORT_MARK_UP))
        basso:setBookmark(SHORT_MARK_UP, basso:getBookmark(MARK_UP))
        if basso:getBookmark(LONG_MARK_UP) < 0 then
            return;
        end
        local mediummarkhigh = source.high[basso:getBookmark(MEDIUM_MARK_UP)]
        if source.high[basso:getBookmark(LONG_MARK_UP)] < mediummarkhigh 
            and mediummarkhigh > source.high[basso:getBookmark(SHORT_MARK_UP)]
        then
            basso:setBookmark(IM_HIGH_OLD, basso:getBookmark(IM_HIGH_NEW));
            basso:setBookmark(IM_HIGH_NEW, basso:getBookmark(MEDIUM_MARK_UP));
        end
        if basso:getBookmark(IM_HIGH_OLD) < 0 then
            return;
        end
        if source.high[basso:getBookmark(IM_HIGH_OLD)] > source.high[basso:getBookmark(IM_HIGH_NEW)] then
            basso:setBookmark(REF_HIGH, basso:getBookmark(MEDIUM_MARK_UP));
        end
    end
    if basso[period] > basso[period - 1] and basso:getBookmark(TREND) ~= 1 then
        basso:setBookmark(TREND, 1)
        basso:setBookmark(LONG_MARK_DOWN, basso:getBookmark(MEDIUM_MARK_DOWN))
        basso:setBookmark(MEDIUM_MARK_DOWN, basso:getBookmark(SHORT_MARK_DOWN))
        basso:setBookmark(SHORT_MARK_DOWN, basso:getBookmark(MARK_DOWN))
        if basso:getBookmark(LONG_MARK_DOWN) < 0 then
            return;
        end
        local mediummarklow = source.low[basso:getBookmark(MEDIUM_MARK_DOWN)]
        if source.low[basso:getBookmark(LONG_MARK_DOWN)] > mediummarklow
            and mediummarklow < source.low[basso:getBookmark(SHORT_MARK_DOWN)] 
        then
            basso:setBookmark(IM_LOW_OLD, basso:getBookmark(IM_LOW_NEW));
            basso:setBookmark(IM_LOW_NEW, basso:getBookmark(MEDIUM_MARK_DOWN));
        end
        if basso:getBookmark(IM_LOW_OLD) < 0 then
            return;
        end
        if source.low[basso:getBookmark(IM_LOW_OLD)] < source.low[basso:getBookmark(IM_LOW_NEW)] then
            basso:setBookmark(REF_LOW, basso:getBookmark(MEDIUM_MARK_DOWN));
        end
    end
    local reflow_index = basso:getBookmark(REF_LOW);
    local im_low_old_index = basso:getBookmark(IM_LOW_OLD);
    up:setNoData(period);
    up1:setNoData(period);
    down:setNoData(period);
    down1:setNoData(period);
    if im_low_old_index >= 0 and reflow_index >= 0 then
        if source.low[im_low_old_index] < source.low[basso:getBookmark(IM_LOW_NEW)]
            and mathex.min(source.low, reflow_index, period) >= source.low[basso:getBookmark(MEDIUM_MARK_DOWN)]
        then
            up:set(period, source.high[period], "\218", source.high[period]);
            up:setNoData(period - 1);
            if instance.parameters.ShowPrice then
                up1:set(period, source.high[period], "  " .. source.high[period]);
                up1:setNoData(period - 1);
            end
        end
    end
    local refhigh_index = basso:getBookmark(REF_HIGH);
    local im_high_old_index = basso:getBookmark(IM_HIGH_OLD);
    if im_high_old_index >= 0 and refhigh_index >= 0 then
        if source.high[im_high_old_index] > source.high[basso:getBookmark(IM_HIGH_NEW)] 
            and mathex.max(source.high, refhigh_index, period) <= source.high[basso:getBookmark(MEDIUM_MARK_UP)]
        then
            down:set(period, source.low[period], "\217", source.low[period]);
            down:setNoData(period - 1);
            if instance.parameters.ShowPrice then
                down1:set(period, source.low[period], "  " .. source.low[period]);
                down1:setNoData(period - 1);
            end
        end
    end
end
