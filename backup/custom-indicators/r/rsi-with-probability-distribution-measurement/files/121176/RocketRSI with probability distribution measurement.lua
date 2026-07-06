-- Id: 22306
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66656

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- RocketRSI Indicator     (C) 2005-2018   John F. Ehlers
-- October 2018 • Technical Analysis of Stocks & commodities 

function Init()
    indicator:name("RocketRSI with probability distribution measurement");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator); 
    
    indicator.parameters:addInteger("SmoothLength", "Smooth Length", "", 8);
    indicator.parameters:addInteger("RSILength", "RSI Length", "", 10);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("RocketRSI_color", "Color of RocketRSI", "Color of RocketRSI", core.rgb(0, 255, 0));
    indicator.parameters:addColor("distr_color_1", "Color of Distribution Bars -3 .. -2", "Color of Distribution Bars", core.rgb(255, 0, 0));
    indicator.parameters:addColor("distr_color_2", "Color of Distribution Bars -2 .. -1", "Color of Distribution Bars", core.rgb(192, 0, 0));
    indicator.parameters:addColor("distr_color_3", "Color of Distribution Bars -1 .. 0", "Color of Distribution Bars", core.rgb(128, 0, 0));
    indicator.parameters:addColor("distr_color_4", "Color of Distribution Bars 0 .. 1", "Color of Distribution Bars", core.rgb(0, 128, 0));
    indicator.parameters:addColor("distr_color_5", "Color of Distribution Bars 1 .. 2", "Color of Distribution Bars", core.rgb(0, 192, 0));
    indicator.parameters:addColor("distr_color_6", "Color of Distribution Bars 2 .. 3", "Color of Distribution Bars", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Transparency", "Transparency", "", 90, 0, 100);
end

local c1;
local c2;
local c3;
local Filt;
local first;
local RSILength;
local Mom;
local source;
function Prepare(nameOnly)
    RSILength = instance.parameters.RSILength;
    source = instance.source;
    local name = string.format("%s(%s, %d, %d)", profile:id(), source:name(), RSILength, instance.parameters.SmoothLength);
    instance:name(name);
    if nameOnly then
        return;
    end
    first = source:first() + RSILength - 1;
    RocketRSI = instance:addStream("RocketRSI", core.Line, "RocketRSI", "RocketRSI", instance.parameters.RocketRSI_color, first + RSILength);

    RocketRSI:setPrecision(math.max(2, instance.source:getPrecision()));

    local a1 = math.exp(-1.414 * 3.14159 / instance.parameters.SmoothLength);
    local b1 = 2 * a1 * math.cos(1.414 * 180 / instance.parameters.SmoothLength);
    c2 = b1;
    c3 = -a1 * a1;
    c1 = 1 - c2 - c3;

    Filt = instance:addInternalStream(0, 0);
    Mom = instance:addInternalStream(0, 0);
    instance:ownerDrawn(true);
end

local Bin = {};
local LastBin;
local init = false;
function Draw(stage, context)
    if stage ~= 0 or Bin.Max == nil then
        return;
    end
    if not init then
        context:createPen(1, context.SOLID, 3, instance.parameters.distr_color_1);
        context:createSolidBrush(11, instance.parameters.distr_color_1);
        context:createPen(2, context.SOLID, 3, instance.parameters.distr_color_2);
        context:createSolidBrush(12, instance.parameters.distr_color_2);
        context:createPen(3, context.SOLID, 3, instance.parameters.distr_color_3);
        context:createSolidBrush(13, instance.parameters.distr_color_3);
        context:createPen(4, context.SOLID, 3, instance.parameters.distr_color_4);
        context:createSolidBrush(14, instance.parameters.distr_color_4);
        context:createPen(5, context.SOLID, 3, instance.parameters.distr_color_5);
        context:createSolidBrush(15, instance.parameters.distr_color_5);
        context:createPen(6, context.SOLID, 3, instance.parameters.distr_color_6);
        context:createSolidBrush(16, instance.parameters.distr_color_6);
        init = true;
    end
    local maxHeight = context:bottom() - context:top();
    local maxWidth = context:right() - context:left();
    local height = maxHeight / Bin.Max;
    local width = maxWidth / 60;
    local shift = 0;
    if width > 3 then
        shift = 1;
    end
    for i = 1, 60 do
        local val = Bin[i];
        if val ~= nil then
            context:drawRectangle(math.floor((i - 1) / 10) + 1, math.floor((i - 1) / 10) + 11, 
                context:left() + (i - 1) * width + shift, context:bottom(),
                context:left() + i * width - shift, context:bottom() - val * height,
                context:convertTransparency(instance.parameters.Transparency));
        end
    end
end

local lastSerial;

function Update(period, mode)
    if period < first then
        return;
    end
    Mom[period] = source[period] + source[period - RSILength + 1];

    if period >= first + 1 then
        local part2 = 0;
        local part3 = 0;
        if period > first + 1 then
            part2 = c2 * Filt[period - 1];
            if period > first + 2 then
                part3 = c3 * Filt[period - 2];
            end
        end
        Filt[period] = c1 * (Mom[period] + Mom[period - 1]) / 2 + part2 + part3;
    end
    
    if period >= first + RSILength then
        CU = 0;
        CD = 0;
        for count = 0, RSILength - 1 do
            local val = Filt[period - count] - Filt[period - count - 1];
            if val > 0 then
                CU = CU + val;
            elseif val < 0 then 
                CD = CD + math.abs(val); 
            end
        end
        if CU + CD ~= 0 then 
            local rsi = math.min(0.999, math.max((CU - CD) / (CU + CD), -0.999));
            RocketRSI[period] = 0.5 * math.log((1 + rsi) / (1 - rsi)); 
        end
        if lastSerial ~= source:serial(period) then
            LastBin = Bin;
            Bin = {};
            lastSerial = source:serial(period);
        end
        for i = 1, 60 do 
            local J = (i - 31.0) / 10.0;
            local K = (i - 30.0) / 10.0;
            if RocketRSI[period] > J and RocketRSI[period] <= K then
                if LastBin == nil or LastBin[i] == nil then
                    Bin[i] = 1;
                else
                    Bin[i] = LastBin[i] + 1;
                end
                if Bin.Max == nil or Bin.Max < Bin[i] then
                    Bin.Max = Bin[i];
                end
            else
                Bin[i] = LastBin[i];
            end
        end
    end
end
