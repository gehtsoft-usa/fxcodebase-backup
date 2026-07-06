--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Ichimoku Advanced");
    indicator:description("Enables to quickly discern and filter 'at a glance' the low-probability trading setups from those of higher probability.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Trend");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Tenkan", "Tenkan", "", 9, 1, 300);
    indicator.parameters:addInteger("Kijun", "Kijun", "", 26, 1, 300);
    indicator.parameters:addInteger("Senkou", "Senkou", "", 52, 1, 300);
    indicator.parameters:addInteger("SpanShift", "Span Shift", "", 0, -200, 200);
    indicator.parameters:addInteger("ChinkouShift", "Chinkou Shift", "", 0, -200, 200);
    indicator.parameters:addGroup("Signals");
    indicator.parameters:addBoolean("Signal1", "Show Span Cross Signals", "", true);
    indicator.parameters:addBoolean("Signal2", "Show Close Close Signals", "", true);
    indicator.parameters:addBoolean("SignalMode", "Marketscope signal mode", "Leave true to show signals on chart. The false value is for using the indicator inside signals", true);
    indicator.parameters:addGroup("Line Style");

    indicator.parameters:addBoolean("TenkanShow", "Show Tenkan", "", true);
    indicator.parameters:addColor("TenkanColor", "Tenkan Color", "", core.rgb(255, 0, 0));

    indicator.parameters:addBoolean("KijunShow", "Show Kijun", "", true);
    indicator.parameters:addColor("KijunColor", "Kijun Color", "", core.rgb(32, 178, 170));

    indicator.parameters:addBoolean("ChinkouShow", "Show Chinkou", "", true);
    indicator.parameters:addColor("ChinkouColor", "Chinkou Color", "", core.rgb(255, 165, 0));

    indicator.parameters:addColor("SpanAColor", "Span A Color", "", core.rgb(244, 164, 96));
    indicator.parameters:addColor("SpanBColor", "Span B Color", "", core.rgb(216, 191, 216));
    indicator.parameters:addColor("SpanABFill", "Span Area Fill Color 1", "", core.rgb(0, 0, 205));
    indicator.parameters:addColor("SpanBAFill", "Span Area Fill Color 2", "", core.rgb(128, 0, 0));
    indicator.parameters:addInteger("FillTransparency", "Fill Area Transparency (%)", "", 90, 0, 100);
    indicator.parameters:addGroup("Signal Style");
    indicator.parameters:addColor("SpanCrossColor", "Color of the span cross marker", "", core.rgb(255, 255, 0));
    indicator.parameters:addColor("CloseCrossColor", "Color of the close price cross marker", "", core.rgb(255, 215, 0));
    indicator.parameters:addInteger("FontSize", "Font Size", "", 8, 4, 32);
end

-- parameters
local Tenkan;
local Kijun;
local Senkou;
local SpanShift;
local ChinkouShift;
local Signal1;
local Signal2;
local source;

local TenkanShow;
local KijunShow;
local ChinkouShow;
local SignalMode;


-- line buffers
local TenkanBuffer;
local KijunBuffer;
local ChinkouBuffer;
local SpanABuffer;
local SpanBBuffer;
local SpanSignal;
local CloseSignal;

-- indexes
local TenkanFirst;
local KijunFirst;
local ChinkouFirst;
local SpanAFirst;
local SpanBFirst;

-- fill buffers
local SpanABBuffer1, SpanABBuffer2;
local SpanBABuffer1, SpanBABuffer2;

function Prepare()
    source = instance.source;

    Tenkan = instance.parameters.Tenkan;
    Kijun = instance.parameters.Kijun;
    Senkou = instance.parameters.Senkou;
    SpanShift = instance.parameters.SpanShift;
    ChinkouShift = instance.parameters.ChinkouShift;
    TenkanShow = instance.parameters.TenkanShow;
    KijunShow = instance.parameters.KijunShow;
    ChinkouShow = instance.parameters.ChinkouShow;
    Signal1 = instance.parameters.Signal1;
    Signal2 = instance.parameters.Signal2;
    SignalMode = instance.parameters.SignalMode;

    TenkanFirst = source:first() + Tenkan;
    KijunFirst = source:first() + Kijun;
    ChinkouFirst = math.max(0, source:first() - Kijun + ChinkouShift);
    SpanAFirst = math.max(TenkanFirst, KijunFirst);
    SpanBFirst = source:first() + Senkou;

    local name;
    name = profile:id() .. "(" .. source:name() .. "," .. Tenkan .. "," .. Kijun .. "," .. Senkou .. "," .. SpanShift .. "," .. ChinkouShift ..")";
    instance:name(name);

    if TenkanShow then
        TenkanBuffer = instance:addStream("Tenkan", core.Line, name .. ".Tenkan", "Tenkan", instance.parameters.TenkanColor, TenkanFirst)
    else
        TenkanBuffer = instance:addInternalStream(TenkanFirst, 0);
    end
    if KijunShow then
        KijunBuffer = instance:addStream("Kijun", core.Line, name .. ".Kijun", "Kijun", instance.parameters.KijunColor, KijunFirst)
    else
        KijunBuffer = instance:addInternalStream(KijunFirst, 0);
    end
    if ChinkouShow then
        ChinkouBuffer = instance:addStream("Chinkou", core.Line, name .. ".Chinkou", "Chinkou", instance.parameters.ChinkouColor, ChinkouFirst,  - Kijun + ChinkouShift);
    else
        ChinkouBuffer = instance:addInternalStream(ChinkouFirst,  - Kijun + ChinkouShift);
    end

    SpanABuffer = instance:addStream("SpanA", core.Line, name .. ".SpanA", "SpanA", instance.parameters.SpanAColor, SpanAFirst,  Kijun + SpanShift);
    SpanBBuffer = instance:addStream("SpanB", core.Line, name .. ".SpanB", "SpanB", instance.parameters.SpanBColor, SpanBFirst,  Kijun + SpanShift);

    SpanABBuffer1 = instance:addInternalStream(0, Kijun + SpanShift);
    SpanABBuffer2 = instance:addInternalStream(0, Kijun + SpanShift);
    SpanBABuffer1 = instance:addInternalStream(0, Kijun + SpanShift);
    SpanBABuffer2 = instance:addInternalStream(0, Kijun + SpanShift);

    instance:createChannelGroup("AB", "AB", SpanABBuffer1, SpanABBuffer2, instance.parameters.SpanABFill, 100 - instance.parameters.FillTransparency);
    instance:createChannelGroup("BA", "BA", SpanBABuffer1, SpanBABuffer2, instance.parameters.SpanBAFill, 100 - instance.parameters.FillTransparency);

    if Signal1 then
        if SignalMode then
            SpanSignal = instance:createTextOutput ("SpanSignal", "SpanSignal", "Wingdings", instance.parameters.FontSize, core.H_Center, core.V_Center, instance.parameters.SpanCrossColor, Kijun + SpanShift);
        else
            SpanSignal = instance:addStream("SpanSignal", core.Dot, name .. ".SpanSignal", "SpanSignal", core.rgb(0, 0, 0), 0, Kijun + SpanShift);
        end
    end
    if Signal2 then
        if SignalMode then
            CloseSignal = instance:createTextOutput ("CloseSignal", "CloseSignal", "Wingdings", instance.parameters.FontSize, core.H_Center, core.V_Center, instance.parameters.CloseCrossColor, 0);
        else
            CloseSignal = instance:addStream("CloseSignal", core.Dot, name .. ".CloseSignal", "CloseSignal", core.rgb(0, 0, 0), 0, 0);
        end
    end
end

function Update(period, mode)
    if period >= TenkanFirst then
        local high, low, range;

        low, high = core.minmax(source, core.rangeTo(period, Tenkan));
        TenkanBuffer[period] = (low + high) / 2;
    end

    if period >= KijunFirst then
        local high, low, range;

        low, high = core.minmax(source, core.rangeTo(period, Kijun));
        KijunBuffer[period] = (low + high) / 2;
    end

    local CinkouPeriod = period - Kijun + ChinkouShift;

    if CinkouPeriod > 0 and period >= source:first() then
        ChinkouBuffer[period - Kijun + ChinkouShift] = source.close[period];
    end

    if period >= SpanAFirst then
        SpanABuffer[period + Kijun + SpanShift] = (TenkanBuffer[period] + KijunBuffer[period]) / 2;
    end

    if period >= SpanBFirst then
        local high, low, range;

        low, high = core.minmax(source, core.rangeTo(period, Senkou));
        SpanBBuffer[period + Kijun + SpanShift] = (low + high) / 2;
    end

    if period >= SpanAFirst and period >= SpanBFirst then
        local period1 = period + Kijun + SpanShift;
        if SpanABuffer[period1] > SpanBBuffer[period1] then
            SpanABBuffer1[period1] = SpanABuffer[period1];
            SpanABBuffer2[period1] = SpanBBuffer[period1];
        elseif SpanABuffer[period1] < SpanBBuffer[period1] then
            SpanBABuffer1[period1] = SpanABuffer[period1];
            SpanBABuffer2[period1] = SpanBBuffer[period1];
        end

        if Signal1 and period >= SpanAFirst + 1 and period >= SpanBFirst + 1 then
            if SignalMode then
                if core.crosses(SpanABuffer, SpanBBuffer, period1) then
                    SpanSignal:set(period1, (SpanABuffer[period1] + SpanBBuffer[period1]) / 2, "\164");
                else
                    SpanSignal:setNoData(period1);
                end
            else
                if core.crosses(SpanABuffer, SpanBBuffer, period1) then
                    SpanSignal[period1] = 1;
                else
                    SpanSignal[period1] = 0;
                end
            end
        end
        if Signal2 and period >= SpanAFirst + 1 and period >= SpanBFirst + 1 then
            if SignalMode then
                if core.crosses(SpanABuffer, source.close, period) then
                    CloseSignal:set(period, SpanABuffer[period], "\165");
                else
                    CloseSignal:setNoData(period);
                end

                if core.crosses(SpanBBuffer, source.close, period) then
                    CloseSignal:set(period, SpanBBuffer[period], "\165");
                end
            else
                if core.crosses(SpanABuffer, source.close, period) then
                    CloseSignal[period] = 1;
                else
                    CloseSignal[period] = 0;
                end

                if core.crosses(SpanBBuffer, source.close, period) then
                    CloseSignal[period] = CloseSignal[period] + 2;
                end
            end
        end
    end
end



