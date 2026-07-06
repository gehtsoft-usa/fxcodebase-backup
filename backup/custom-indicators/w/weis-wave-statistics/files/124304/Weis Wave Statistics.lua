-- Id: 24115
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67422

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
    indicator:name("WeisWave oscillator")
    indicator:description("WeisWave oscillator")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("dif", "dif", "", 1)
    indicator.parameters:addBoolean("Absolute", "Absolute", "", false)

    indicator.parameters:addString("legs_volume", "Leg Volume Calculation Method", "", "total");
    indicator.parameters:addStringAlternative("legs_volume", "Total", "", "total")
    indicator.parameters:addStringAlternative("legs_volume", "Average", "", "avg")

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0))
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0))

    indicator.parameters:addGroup("Divisor Calculation")
    indicator.parameters:addInteger("Divisor", "Divisor", "", 1)
    indicator.parameters:addIntegerAlternative("Divisor", "1", "", 1)
    indicator.parameters:addIntegerAlternative("Divisor", "100", "", 100)
    indicator.parameters:addIntegerAlternative("Divisor", "1000", "", 1000)
    indicator.parameters:addIntegerAlternative("Divisor", "10000", "", 10000)
    indicator.parameters:addIntegerAlternative("Divisor", "100000", "", 100000)
    indicator.parameters:addIntegerAlternative("Divisor", "1000000", "", 1000000)

    indicator.parameters:addGroup("Legs")
    indicator.parameters:addBoolean("show_legs", "Show legs", "", false);
    indicator.parameters:addColor("LegsUPclr", "Legs UP Color", "UP Color", core.rgb(0, 255, 0))
    indicator.parameters:addColor("LegsDNclr", "Legs DN Color", "DN Color", core.rgb(255, 0, 0))
    indicator.parameters:addBoolean("show_total_volume", "Show total volume", "", false);
    indicator.parameters:addBoolean("show_avg_volume", "Show average volume", "", false);
    indicator.parameters:addColor("total_volume_color", "Total Volume Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("avg_volume_color", "Average Volume Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addBoolean("show_time", "Show time", "", false);
    indicator.parameters:addColor("time_color", "Time Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addString("legs_size", "Legs size", "", "no")
    indicator.parameters:addStringAlternative("legs_size", "Do not show", "", "no")
    indicator.parameters:addStringAlternative("legs_size", "Pips", "", "pips")
    indicator.parameters:addStringAlternative("legs_size", "Bars", "", "bars")
    indicator.parameters:addColor("leg_size_color", "Leg size color", "", core.rgb(255, 0, 0))

    indicator.parameters:addInteger("font_size", "Font size", "", 8)
end

local first
local source = nil
local dif
local Absolute
local difPip
local mov, trend, wave, vol
local UP = nil
local DN = nil
local legs;
local Divisor
local legs_volume;
local LegsUPclr, LegsDNclr;
local show_total_volume, show_avg_volume;
local total_volume_color, avg_volume_color;
local font_size;
local show_time;
local time_color;
local legs_size;
local leg_size_color;
local sections;
function Prepare(nameOnly)
    source = instance.source
    dif = instance.parameters.dif
    Absolute = instance.parameters.Absolute
    Divisor = instance.parameters.Divisor
    LegsUPclr = instance.parameters.LegsUPclr;
    LegsDNclr = instance.parameters.LegsDNclr;
    legs_volume = instance.parameters.legs_volume;
    show_total_volume = instance.parameters.show_total_volume;
    show_avg_volume = instance.parameters.show_avg_volume;
    total_volume_color = instance.parameters.total_volume_color;
    avg_volume_color = instance.parameters.avg_volume_color;
    show_time = instance.parameters.show_time;
    time_color = instance.parameters.time_color;
    font_size = instance.parameters.font_size;
    legs_size = instance.parameters.legs_size;
    leg_size_color = instance.parameters.leg_size_color;

    first = source:first() + 2
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.dif .. ")"
    instance:name(name)
    if nameOnly then
        return
    end
    mov = instance:addInternalStream(first, 0)
    trend = instance:addInternalStream(first, 0)
    wave = instance:addInternalStream(first, 0)
    vol = instance:addInternalStream(first, 0)
    UP = instance:addStream("UP", core.Bar, name .. ".UP", "UP", instance.parameters.UPclr, first)
    UP:setPrecision(math.max(2, instance.source:getPrecision()));
    DN = instance:addStream("DN", core.Bar, name .. ".DN", "DN", instance.parameters.DNclr, first)
    DN:setPrecision(math.max(2, instance.source:getPrecision()));
    if instance.parameters.show_legs then
        legs = instance:addStream("Legs", core.Line, "Legs", "Legs", LegsUPclr, 0, 0);
    legs:setPrecision(math.max(2, instance.source:getPrecision()));
        core.host:execute("attachOuputToChart", "Legs");
        sections = CreateSections(legs);
    end
    difPip = dif * source:pipSize()

    instance:drawOnMainChart(true);
end

local FONT = 1;
local init = false;
function Draw(stage, context)
    if stage ~= 102 then
        return;
    end
    if not init then
        context:createFont(FONT, "Arial", 0, context:pointsToPixels(font_size), 0);
        init = true;
    end

    local peaks = sections:EnumPeaks();
    if not peaks:Next() then
        return;
    end
    local prev_period, prev_value = peaks:GetData();
    while peaks:Next() do
        local period, value = peaks:GetData();
        if wave[prev_period] == 1 then
            local x = context:positionOfBar(prev_period);
            local _, y = context:pointOfPrice(prev_value);
            if legs_size == "pips" and period ~= -1 then
                Text = win32.formatNumber(math.abs(source.low[prev_period] - source.high[period]) / source:pipSize(), false, 1);
                width, height = context:measureText(FONT, Text, 0)
                context:drawText(FONT, Text, leg_size_color, -1, x - width / 2, y - height, x + width / 2, y, 0)
                y = y - height * 1.3;
            elseif legs_size == "bars" and period ~= -1 then
                Text = prev_period - period;
                width, height = context:measureText(FONT, Text, 0)
                context:drawText(FONT, Text, leg_size_color, -1, x - width / 2, y - height, x + width / 2, y, 0)
                y = y - height * 1.3;
            end
            if show_time and period ~= -1 then
                Text = math.ceil((source:date(prev_period) - source:date(period)) * 1440);
                width, height = context:measureText(FONT, Text, 0)
                context:drawText(FONT, Text, time_color, -1, x - width / 2, y - height, x + width / 2, y, 0)
                y = y - height * 1.3;
            end
            if show_avg_volume and period ~= -1 then
                Text = math.ceil(vol[period] / (prev_period - period));
                width, height = context:measureText(FONT, Text, 0)
                context:drawText(FONT, Text, avg_volume_color, -1, x - width / 2, y - height, x + width / 2, y, 0)
                y = y - height * 1.3;
            end
            if show_total_volume then
                Text = tostring(vol[period]);
                width, height = context:measureText(FONT, Text, 0)
                context:drawText(FONT, Text, total_volume_color, -1, x - width / 2, y - height, x + width / 2, y, 0)
            end
        else
            local x = context:positionOfBar(prev_period);
            local _, y = context:pointOfPrice(prev_value);
            if show_total_volume then
                Text = tostring(vol[period]);
                width, height = context:measureText(FONT, Text, 0)
                context:drawText(FONT, Text, total_volume_color, -1, x - width / 2, y, x + width / 2, y + height, 0)
                y = y + height * 1.3;
            end
            if show_avg_volume and period ~= -1 then
                Text = math.ceil(vol[period] / (prev_period - period));
                width, height = context:measureText(FONT, Text, 0)
                context:drawText(FONT, Text, avg_volume_color, -1, x - width / 2, y, x + width / 2, y + height, 0)
                y = y + height * 1.3;
            end
            if show_time and period ~= -1 then
                Text = math.ceil((source:date(prev_period) - source:date(period)) * 1440);
                width, height = context:measureText(FONT, Text, 0)
                context:drawText(FONT, Text, time_color, -1, x - width / 2, y, x + width / 2, y + height, 0)
                y = y + height * 1.3;
            end
            if legs_size == "pips" and period ~= -1 then
                Text = win32.formatNumber(math.abs(source.high[prev_period] - source.low[period]) / source:pipSize(), false, 1);
                width, height = context:measureText(FONT, Text, 0)
                context:drawText(FONT, Text, leg_size_color, -1, x - width / 2, y, x + width / 2, y + height, 0)
                y = y + height * 1.3;
            elseif legs_size == "bars" and period ~= -1 then
                Text = prev_period - period;
                width, height = context:measureText(FONT, Text, 0)
                context:drawText(FONT, Text, leg_size_color, -1, x - width / 2, y, x + width / 2, y + height, 0)
                y = y + height * 1.3;
            end
            
        end
        prev_period = period;
        prev_value = value;
    end
    if prev_period ~= -1 then
        local x = context:positionOfBar(prev_period);
        local _, y = context:pointOfPrice(prev_value);
        if show_total_volume then
            Text = tostring(vol[period]);
            width, height = context:measureText(FONT, Text, 0)
            if wave[prev_period] == 1 then
                context:drawText(FONT, Text, total_volume_color, -1, x - width / 2, y - height, x + width / 2, y, 0)
                y = y - height * 1.3;
            else
                context:drawText(FONT, Text, total_volume_color, -1, x - width / 2, y, x + width / 2, y + height, 0)
                y = y + height * 1.3;
            end
        end
    end
end

function Update(period, mode)
    if period <= first then
        return;
    end
    if source.close[period] > source.close[period - 1] then
        mov[period] = 1
    elseif source.close[period] < source.close[period - 1] then
        mov[period] = -1
    end
    if mov[period] ~= 0 and mov[period] ~= mov[period - 1] then
        trend[period] = mov[period]
    else
        trend[period] = trend[period - 1]
    end
    if trend[period] ~= wave[period - 1] and math.abs(source.close[period] - source.close[period - 1]) >= difPip then
        wave[period] = trend[period]
    else
        wave[period] = wave[period - 1]
    end
    if wave[period] == wave[period - 1] then
        vol[period] = vol[period - 1] + source.volume[period] / Divisor
    else
        vol[period] = source.volume[period] / Divisor
    end
    DrawBars(period);
    if legs ~= nil then
        DrawLegs(period);
    end
end

function DrawBars(period)
    if legs_volume == "total" then
        if wave[period] == 1 then
            UP[period] = vol[period]
        elseif wave[period] == -1 then
            if Absolute then
                DN[period] = vol[period]
            else
                DN[period] = -vol[period]
            end
        end
    else
        local periods = period - legs:getBookmark(1);
        if wave[period] == 1 then
            UP[period] = vol[period] / periods
        elseif wave[period] == -1 then
            if Absolute then
                DN[period] = vol[period] / periods
            else
                DN[period] = -vol[period] / periods
            end
        end
    end
end

function CreateSections(stream)
    local sections = {};
    sections.Stream = stream;
    sections.Total = 0;
    function sections:AddPoint(period)
        local index = 1;
        local section = self.Stream:getBookmark(index);
        if section == period then
            return;
        end
        while section ~= -1 do
            local next = self.Stream:getBookmark(index + 1);
            self.Stream:setBookmark(index + 1, section);
            section = next;
            index = index + 1;
        end
        self.Stream:setBookmark(1, period);
        self.Total = index - 1;
    end
    function sections:EnumPeaks()
        local enum = {};
        enum.zz = self;
        enum.Index = 0;
        function enum:Next()
            self.Index = self.Index + 1;
            return self.Index <= self.zz.Total;
        end
        function enum:GetData()
            local period = self.zz.Stream:getBookmark(self.Index);
            if period == -1 then
                return nil;
            end
            return period, self.zz.Stream[period];
        end
        return enum;
    end
    return sections;
end

function DrawLegs(period)
    if wave[period - 1] ~= wave[period - 2] then
        sections:AddPoint(period - 1);
    end
    local prev;
    local current;
    if wave[period] == wave[period - 1] then
        DrawLeg(legs:getBookmark(1), period);
    else
        DrawLeg(legs:getBookmark(2), legs:getBookmark(1));
        DrawLeg(legs:getBookmark(1), period);
    end
end

function GetLegRate(period)
    if wave[period] == 1 then
        return source.high[period];
    end

    return source.low[period];
end

function DrawLeg(from, to)
    core.drawLine(legs, core.range(from, to), GetLegRate(from), from, GetLegRate(to), to);
    local clr = wave[from] == 1 and LegsUPclr or LegsDNclr;
    for i = from + 1, to do
        legs:setColor(i, clr);
    end
end
