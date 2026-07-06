-- Id: 164
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=349

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
-- Indicator profile initialization routine
function Init()
    indicator:name("John Ehlers Sine Wave Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("alpha", "Alpha", "", 0.07);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("W1_color", "Color of the base sine", "", core.rgb(0, 255, 128));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("W2_color", "Color of the leading sine", "", core.rgb(128, 128, 255));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local alpha;

local first;
local source = nil;

-- Streams block
local W1 = nil;
local W2 = nil;
local price = nil;
local cycle = nil;
local smooth = nil;
local Q1 = nil;
local I1 = nil;
local InstPeriod = nil;
local DeltaPhase = nil;
local Value1 = nil;

-- Routine
function Prepare(nameOnly)
    alpha = instance.parameters.alpha;
    source = instance.source;
    first = source:first() + 20;
    local name = profile:id() .. "(" .. source:name() .. ", " .. alpha .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    W1 = instance:addStream("BS", core.Line, name .. ".BS", "BS", instance.parameters.W1_color, first);
    W1:setPrecision(math.max(2, instance.source:getPrecision()));
	W1:setWidth(instance.parameters.width1);
    W1:setStyle(instance.parameters.style1);
	
    W2 = instance:addStream("LS", core.Line, name .. ".LS", "LS", instance.parameters.W2_color, first);
    W2:setPrecision(math.max(2, instance.source:getPrecision()));
	W2:setWidth(instance.parameters.width2);
    W2:setStyle(instance.parameters.style2);
    price = instance:addInternalStream(0, 0);
    cycle = instance:addInternalStream(0, 0);
    smooth = instance:addInternalStream(0, 0);
    Q1 = instance:addInternalStream(0, 0);
    I1 = instance:addInternalStream(0, 0);
    InstPeriod = instance:addInternalStream(0, 0);
    DeltaPhase = instance:addInternalStream(0, 0);
    Value1 = instance:addInternalStream(0, 0);
end

-- Indicator calculation routine
function Update(period)
    cycle[period] = 0;
    Q1[period] = 0;
    I1[period] = 0;
    InstPeriod[period] = 0;
    DeltaPhase[period] = 0;
    Value1[period] = 0;

    if period >= source:first() then
        price[period] = (source.high[period] + source.low[period]) / 2;
    end

    if period >= source:first() + 3 then
        smooth[period] = (price[period] + 2 * price[period - 1] + 2 * price[period - 2] + price[period - 3]) / 6;

        if period < source:first() + 7 then
            cycle[period] = (price[period] - 2 * price[period] + price[period - 2]) / 4;
        else
            local i;
            local t;
            local MedianDelta;
            local DC;
            local DCPeriod;
            local RealPart;
            local ImagPart;
            local count;

            if (math.abs(source:date(period) - 40185.0833) < 0.0001) then
                i = 0;
            end

            cycle[period] = (1 - 0.5 * alpha) * (1 - 0.5 * alpha) *
                            (smooth[period] - 2 * smooth[period - 1] + smooth[period - 2]) +
                            2 * (1 - alpha) * cycle[period - 1] - (1 - alpha) * (1 - alpha) * cycle[period - 2];
            Q1[period] = (0.0962 * cycle[period] + 0.5769 * cycle[period - 2] - 0.5769 * cycle[period - 4] -
                          0.0962 * cycle[period - 6]) * (0.5 + 0.08 * InstPeriod[period - 1]);
            I1[period] = cycle[period - 3];
            if Q1[period] ~= 0 and Q1[period - 1] ~= 0 then
                t = (I1[period] / Q1[period] - I1[period - 1] / Q1[period - 1]) /
                    (1 + I1[period] * I1[period - 1] / (Q1[period] * Q1[period - 1]));
            else
                t = 0;
            end
            if t < 0.1 then
                t = 0.1;
            elseif t > 1.1 then
                t = 1.1
            end
            DeltaPhase[period] = t;
            MedianDelta = Median(DeltaPhase);
            if MedianDelta == 0 then
                DC = 15;
            else
                DC = 6.28318 / MedianDelta + 0.5;
            end
            InstPeriod[period] = 0.33 * DC + 0.67 * InstPeriod[period - 1];
            Value1[period] = 0.15 * InstPeriod[period] + 0.85 * Value1[period - 1];
            DCPeriod = IntPortion(Value1[period]);
            RealPart = 0;
            ImagPart = 0;
            count = 0;
            if DCPeriod > period + 1 then
                DCPeriod = period + 1;
            end
            for i = period - DCPeriod + 1, period, 1 do
                RealPart = RealPart + math.sin(math.rad(360 * count / DCPeriod)) * (cycle[i]);
                ImagPart = ImagPart + math.cos(math.rad(360 * count / DCPeriod)) * (cycle[i]);
                count = count + 1;
            end
            if math.abs(ImagPart) > 0.00001 then
                DCPhase = math.deg(math.atan(RealPart / ImagPart));
            end
            if math.abs(ImagPart) <= 0.00001 then
                if RealPart > 0 then
                    DCPhase = 90;
                elseif RealPart < 0 then
                    DCPhase = -90;
                else
                    DCPhase = 0;
                end
            end
            DCPhase = DCPhase + 90;
            if ImagPart < 0 then
                DCPhase = DCPhase + 180;
            end
            if DCPhase > 315 then
                DCPhase = DCPhase - 360;
            end
            if period >= first then
                W1[period] = math.sin(math.rad(DCPhase));
                W2[period] = math.sin(math.rad(DCPhase + 45));
            end
        end
    end
end

function Median(stream)
    local size;
    size = stream:size();
    if size == 0 then
        return 0;
    elseif size == 1 then
        return stream[1];
    elseif size == 2 then
        return (stream[0] + stream[1]) / 2;
    else
        local array, i, i1;
        array = {};
        for i = 1, stream:size(), 1 do
            array[i] = stream[i - 1];
        end
        table.sort(array);
        if size % 2 ~= 0 then
            i = math.ceil(size / 2) + 1;
            return array[i];
        else
            i = size / 2;
            return (array[i] + array[i + 1]) / 2;
        end
    end
end

function IntPortion(value)
    if (value < 0) then
        return math.ceil(value);
    else
        return math.floor(value);
    end
end
