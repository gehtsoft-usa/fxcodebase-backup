-- Id: 2111
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=2526

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Mean indicator (dot version)");
    indicator:description("Mean indicator (dot version)");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Parameters");
    indicator.parameters:addString("TF", "Time Frame", "", "D1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN", "DN Color", "DN Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clrPrev", "Prev Color", "Prev Color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width", "Line width", "Line width", 3, 1, 5);
end

local first;
local source = nil;
local MeanUP = nil;
local MeanDN = nil;
local Buff = nil;
local Day = nil;
local PrevBuff = nil;
local bmk = 1;
local TF;
local host;
local offset;
local weekoffset;

function Prepare(nameOnly)
    TF = instance.parameters.TF;

    host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");

    source = instance.source;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. "," .. TF .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Buff = instance:addInternalStream(first, 0);
    Day = instance:addInternalStream(first, 0);
    DayBmk = instance:addInternalStream(first, 0);
    MeanUP = instance:addStream("MeanUP", core.Dot, name .. ".UP", "UP", instance.parameters.clrUP, first);
    MeanDN = instance:addStream("MeanDN", core.Dot, name .. ".DN", "DN", instance.parameters.clrDN, first);
    PrevBuff = instance:addStream("Prev", core.Dot, name .. ".P", "P", instance.parameters.clrPrev, first);
    MeanUP:setWidth(instance.parameters.width);
    MeanDN:setWidth(instance.parameters.width);
    PrevBuff:setWidth(instance.parameters.width);
end

function Update(period, mode)
    if period >= first then
        Day[period] = math.floor(core.getcandle(TF, source:date(period), offset, weekoffset) * 86400 + 0.5);

        if period == first then
            -- first available candle
            Day:setBookmark(bmk, period);
            DayBmk[period] = bmk;
            bmk = bmk + 1;
        else
            -- the first candle of the current day
            if Day[period] ~= Day[period - 1] then
                Day:setBookmark(bmk, period);
                DayBmk[period] = bmk;
                bmk = bmk + 1;
            else
                DayBmk[period] = DayBmk[period - 1];
            end
        end

        local start, avg;
        start = Day:getBookmark(DayBmk[period]);
        avg = core.avg(source, core.range(start, period));
        Buff[period] = avg;

        if start ~= source:first() then
            PrevBuff[period] = Buff[start - 1];
        end
    end

    if period > first then
        if Buff[period] > Buff[period - 1] then
            MeanUP[period] = Buff[period];
            MeanDN[period] = nil;
        elseif Buff[period] < Buff[period - 1] then
            MeanUP[period] = nil;
            MeanDN[period] = Buff[period];
        else
            if MeanUP:hasData(period - 1) then
                MeanUP[period] = MeanUP[period - 1];
                MeanDN[period] = nil;
            elseif MeanDN:hasData(period - 1) then
                MeanUP[period] = nil;
                MeanDN[period] = MeanDN[period - 1];
            end
        end
    end
end

