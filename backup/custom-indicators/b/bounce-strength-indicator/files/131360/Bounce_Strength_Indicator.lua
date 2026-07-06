-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69425

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                           mario.jemic@gmail.com  |
--|                          https://AppliedMachineLearning.systems  |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                                  Patreon: https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Bounce Strength Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addInteger("InpRangePeriod", "Range Period", "", 20);
    indicator.parameters:addInteger("InpSlowing", "Slowing", "", 3);
    indicator.parameters:addInteger("InpAvgPeriod", "Avg Period", "", 3);
    indicator.parameters:addString("InpUsingVolumeWeight", "Using Volume", "", "tick");
    indicator.parameters:addStringAlternative("InpUsingVolumeWeight", "Using TickVolume", "", "tick");
    indicator.parameters:addStringAlternative("InpUsingVolumeWeight", "Using without Volume", "", "novol");

    indicator.parameters:addInteger("ExtPosBuffer_color", "ExtPosBuffer Color", "", core.colors().Teal);
    indicator.parameters:addInteger("ExtNegBuffer_color", "ExtNegBuffer Color", "", core.colors().Red);
    indicator.parameters:addColor("BSIBuffer_color1", "Bounce Strength Index Color 1", "Color", core.colors().Magenta);
    indicator.parameters:addColor("BSIBuffer_color2", "Bounce Strength Index Color 2", "Color", core.colors().Gray);
    indicator.parameters:addColor("BSIBuffer_color3", "Bounce Strength Index Color 3", "Color", core.colors().DodgerBlue);
    indicator.parameters:addInteger("BSIBuffer_width", "Bounce Strength Index Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("BSIBuffer_style", "Bounce Strength Index Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("BSIBuffer_style", core.FLAG_LINE_STYLE);
end

local source, InpRangePeriod, InpSlowing, InpAvgPeriod, InpUsingVolumeWeight;
local ExtPosBuffer, BSIBuffer_color1, BSIBuffer_color2, BSIBuffer_color3;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    InpRangePeriod = instance.parameters.InpRangePeriod;
    InpSlowing = instance.parameters.InpSlowing;
    InpAvgPeriod = instance.parameters.InpAvgPeriod;
    InpUsingVolumeWeight = instance.parameters.InpUsingVolumeWeight;
    BSIBuffer_color1 = instance.parameters.BSIBuffer_color1;
    BSIBuffer_color2 = instance.parameters.BSIBuffer_color2;
    BSIBuffer_color3 = instance.parameters.BSIBuffer_color3;

    ExtPosBuffer = instance:addStream("ExtPosBuffer", core.Bar, "Floor Bounce Strength", "Floor Bounce Strength", instance.parameters.ExtPosBuffer_color, 0, 0);
    ExtNegBuffer = instance:addStream("ExtNegBuffer", core.Bar, "Ceiling Bounce Strength", "Ceiling Bounce Strength", instance.parameters.ExtNegBuffer_color, 0, 0);
    BSIBuffer = instance:addStream("BSIBuffer", core.Line, "Bounce Strength Index", "Bounce Strength Index", instance.parameters.BSIBuffer_color1, 0, 0);
    BSIBuffer:setWidth(instance.parameters.BSIBuffer_width);
    BSIBuffer:setStyle(instance.parameters.BSIBuffer_style);
    BSIBuffer:addLevel(10, core.DASHDOT, 1, core.colors().Blue);
    BSIBuffer:addLevel(0, core.DASHDOT, 1, core.colors().Blue);
    BSIBuffer:addLevel(-10, core.DASHDOT, 1, core.colors().Blue);
end

local ExtLowest = {};
local ExtHighest = {};
local Count = {};
local ExtVolume = {};

function Update(period, mode)
    if period < InpRangePeriod then
        return;
    end
    local volmax = nil;
    local dmin, dmax = mathex.minmax(source, period - InpRangePeriod, period);
    if Count[0] == nil then
        Count[0] = 0;
    end
    ExtLowest[Count[0]] = dmin;
    ExtHighest[Count[0]] = dmax;
    if InpUsingVolumeWeight == "novol" then
        ExtVolume[Count[0]] = 1.0;
    elseif InpUsingVolumeWeight == "tick" then
        ExtVolume[Count[0]] = mathex.max(source.volume, period - InpRangePeriod, period);
    end
    local sumpos=0;
    local sumneg=0;
    local sumhigh=0;
    for kkk = 0, InpSlowing - 1 do
        local barkkk = period - kkk;
        local vol=1.0;
        if InpUsingVolumeWeight == "tick" then
            if ExtVolume[Count[kkk]] ~= nil and ExtVolume[Count[kkk]] > 0 then
                vol = source.volume[barkkk] / ExtVolume[Count[kkk]];
            end
        end
        local extHigh = ExtHighest[Count[kkk]] or 0;
        local extLow = ExtLowest[Count[kkk]] or 0;
        local ratio=0;
        local range = math.max(source:pipSize(), extHigh-extLow);
        local sp=(source.high[barkkk]-source.low[barkkk]);
        if source.close[barkkk - 1] - sp * 0.2 <= source.close[barkkk] then
            if (source.low[barkkk] == extLow) then
                ratio=1;
            else
                ratio=(extHigh-source.low[barkkk])/range;
            end
            sumpos = sumpos + (source.close[barkkk]-source.low[barkkk])*ratio *vol;
        end
        if source.close[barkkk-1]+sp*0.2>=source.close[barkkk] then
            if (source.high[barkkk]==extHigh) then
                ratio=1;
            else
                ratio=(source.high[barkkk]-extLow)/range;
            end
            sumneg = sumneg + (source.high[barkkk]-source.close[barkkk])*ratio*vol*-1;
        end
        sumhigh = sumhigh + range;
    end
    if sumhigh == 0 then
        ExtPosBuffer[period]=nil;
        ExtNegBuffer[period]=nil;
    else
        ExtPosBuffer[period]=sumpos/sumhigh*100;
        ExtNegBuffer[period]=sumneg/sumhigh*100;
    end
    if (period < source:size()-1) then
        Recount_ArrayZeroPos(Count,size);
    end
    local sum=0;
    for kkk=0, InpAvgPeriod - 1 do
        sum = sum + ExtPosBuffer[period-kkk]+ExtNegBuffer[period-kkk];
    end
    BSIBuffer[period]=sum/InpAvgPeriod;
    local clr=1;
    if(BSIBuffer[period-1] > BSIBuffer[period]) then
        BSIBuffer:setColor(period, BSIBuffer_color1);
    elseif (BSIBuffer[period-1] < BSIBuffer[period]) then
        BSIBuffer:setColor(period, BSIBuffer_color3);
    else
        BSIBuffer:setColor(period, BSIBuffer_color2);
    end
end
local count=1;
function Recount_ArrayZeroPos()
    local Max2 = math.max(InpRangePeriod, InpSlowing);
    local Max1 = Max2 - 1;
    count = count - 1;
    if (count<0) then
        count = Max1;
    end
    for iii = 0, Max2 - 1 do
       numb = iii + count;
        if (numb > Max1) then
            numb = numb - Max2;
        end
        Count[iii] = numb;
    end
end