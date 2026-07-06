-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66263
-- Id: 

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
    indicator:name("ZIG ZAG WITH DINAPOLI TARGETS");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator); 

    indicator.parameters:addInteger("Depth", "Minimum points in a ray", "", 50);
    indicator.parameters:addBoolean("VLine", "Show the vertical lines", "", true);
    indicator.parameters:addColor("color", "Line color", "", core.colors().Teal);
    indicator.parameters:addColor("cStar", "Start Line color", "", core.colors().Honeydew);
    indicator.parameters:addColor("cStop", "Stop Line color", "", core.colors().Red);
    indicator.parameters:addColor("cTar1", "Target1 Line color", "", core.colors().Green);
    indicator.parameters:addColor("cTar2", "Target2 Line color", "", core.colors().DarkOrange);
    indicator.parameters:addColor("cTar3", "Target3 Line color", "", core.colors().DarkOrchid);
    indicator.parameters:addColor("cTar4", "Target4 Line color", "", core.colors().DarkSlateBlue);
    indicator.parameters:addColor("cTarT1", "Time Target1 color", "", core.colors().DarkSlateGray);
    indicator.parameters:addColor("cTarT2", "Time Target2 color", "", core.colors().DarkSlateGray);
    indicator.parameters:addColor("cTarT3", "Time Target3 color", "", core.colors().DarkSlateGray);
    indicator.parameters:addColor("cTarT4", "Time Target4 color", "", core.colors().DarkSlateGray);
    indicator.parameters:addColor("cTarT5", "Time Target4 color", "", core.colors().DarkSlateGray);
end

local Depth;
local VLine;
local depth;
local A;
local B;
local C
local Price = {};
local last;
local direction;
local Refresh;
local AT;
local BT;
local CT;
local Time = {};
local direction;
local out;
function Prepare()
    source = instance.source;
    
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);

    out = instance:addStream("H", core.Line, "H", "H", instance.parameters.color, 0);
    Depth = instance.parameters.Depth;
    VLine = instance.parameters.VLine;
    depth = Depth * source:pipSize();
    direction = 1;
    last = 0;
    instance:ownerDrawn(true);
end


function Draw(stage, context)
    if stage == 2 then
        if not init then
            context:createPen(0, context.SOLID, 1, instance.parameters.cStar);
            context:createPen(1, context.SOLID, 1, instance.parameters.cStop);
            context:createPen(2, context.SOLID, 1, instance.parameters.cTar1);
            context:createPen(3, context.SOLID, 1, instance.parameters.cTar2);
            context:createPen(4, context.SOLID, 1, instance.parameters.cTar3);
            context:createPen(5, context.SOLID, 1, instance.parameters.cTar4);
            context:createPen(6, context.SOLID, 1, instance.parameters.cTarT1);
            context:createPen(7, context.SOLID, 1, instance.parameters.cTarT2);
            context:createPen(8, context.SOLID, 1, instance.parameters.cTarT3);
            context:createPen(9, context.SOLID, 1, instance.parameters.cTarT4);
            context:createPen(10, context.SOLID, 1, instance.parameters.cTarT5);
            init = true;
        end
        for i = 0, 5 do
            local visible, y = context:pointOfPrice(Price[i]);
            context:drawLine(i, context:left(), y, context:right(), y);
        end
        if VLine == true then
            for i = 0, 4 do
                local x = context:positionOfDate(Time[i]);
                context:drawLine(i + 6, x, context:top(), x, context:bottom());
            end
        end
    end
end

function DoRefresh(new_a, new_b, new_c, new_at, new_bt, new_ct)
    A = new_a;
    B = new_b;
    C = new_c;
    AT = new_at;
    BT = new_bt;
    CT = new_ct;
    if B == nil or A == nil then
        return;
    end

    local a = B - A;
    Price[0] = a * 0.318 + C; -- Start;
    Price[1] = C; -- Stop
    Price[2] = a * 0.618 + C; -- Target1
    Price[3] = a + C; -- Target2;
    Price[4] = a * 1.618 + C; -- Target3;
    Price[5] = a * 2.618 + C; -- Target4;
    if VLine == true then
        a = BT - AT;
        Time[0] = Round(a * 0.318) + CT; -- Time Target1
        Time[1] = Round(a * 0.618) + CT; -- Time Target2
        Time[2] = Round(a) + CT; -- Time Target3
        Time[3] = Round(a * 1.618) + CT; -- Time Target4
        Time[4] = Round(a * 2.618) + CT; -- Time Target5
    end
    --if Sound==true)PlaySound(SoundFile);
end

function RegisterHigh(i)
    out:setBookmark(1, i);
    local last_low = out:getBookmark(2);
    if last_low == -1 then
        return;
    end
    core.drawLine(out, core.range(last_low, i), source.low[last_low], last_low, source.high[i], i);
    direction = 1;
end

function RegisterLow(i)
    out:setBookmark(2, i);
    local last_high = out:getBookmark(1);
    if last_high == -1 then
        return;
    end
    core.drawLine(out, core.range(last_high, i), source.high[last_high], last_high, source.low[i], i);
    direction = -1;
end

function Ascending(i)
    return source.open[i] < source.close[i];
end

function Descending(i)
    return source.open[i] > source.close[i];
end

function Update(i, mode)
    if i == 0 then
        direction = 1;
    end
    local set = false;
    local last_h = out:getBookmark(1);
    local last_l = out:getBookmark(2);
    if direction > 0 then
        local distance_low = math.abs(source.low[i] - source.high[last_l]);
        if source.high[i] > source.high[last_h] then
            if distance_low >= depth then
                if Ascending(i) then
                    DoRefresh(C, source.high[last_l], source.low[i], CT, source:date(last_l), source:date(i));
                else
                    DoRefresh(B, C, source.high[i], BT, CT, source:date(i));
                end
            else
                RegisterHigh(i);
            end
            set = true;
        end
        if distance_low >= depth and (not set or Descending(i)) then
            if math.abs(source.high[i] - source.low[i]) >= depth and Ascending(i) then
                DoRefresh(C, source.high[last_l], source.low[i], CT, source:date(last_l), source:date(i));
                RegisterHigh(i);
            else
                if direction > 0 then
                    DoRefresh(B, C, source.high[last_l], BT, CT, source:date(last_l));
                end
                RegisterLow(i);
            end
        end
    else
        local distance_high = math.abs(source.high[i] - source.low[last_h]);
        if source.low[i] < source.low[last_l] then
            if distance_high >= depth then
                if Descending(i) then
                    DoRefresh(C, source.low[last_h], source.high[i], CT, source:date(last_h), source:date(i));
                else
                    DoRefresh(B, C, source.low[i], BT, CT, source:date(i));
                end
            else
                RegisterLow(i);
            end
            set = true;
        end
        if distance_high >= depth and (not set or Ascending(i)) then
            if math.abs(source.high[i] - source.low[i]) >= depth and Descending(i) then
                DoRefresh(C, source.low[last_h], source.high[i], CT, source:date(last_h), source:date(i));
                RegisterLow(i);
            else
                if direction < 0 then
                    DoRefresh(B, C, source.low[last_h], BT, CT, source:date(last_h));
                end
                RegisterHigh(i);
            end
        end
    end
end

function Round(num, idp)
    if idp and idp > 0 then
        local mult = 10 ^ idp
        return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end