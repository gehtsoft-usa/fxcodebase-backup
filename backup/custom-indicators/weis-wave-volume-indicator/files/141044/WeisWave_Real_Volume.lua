-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59573

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC |
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
    indicator:name("WeisWave oscillator with Real volume")
    indicator:description("WeisWave oscillator with Real volume")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume")
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume")
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions")
    indicator.parameters:addInteger("dif", "dif", "", 1)
    indicator.parameters:addBoolean("Absolute", "Absolute", "", false)

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0))
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0))
end

local first
local source = nil
local dif
local Absolute
local difPip
local mov, trend, wave, vol
local UP = nil
local DN = nil
local Ind

local FirstStart
local LastTime
local upLabel;
local downLabel;
local count;

function Prepare()
    source = instance.source
    dif = instance.parameters.dif
    Absolute = instance.parameters.Absolute
    if instance.parameters.Ind == "Volume" then
        Ind = core.indicators:create("REAL VOLUME", source)
    else
        Ind = core.indicators:create("TRANSACTIONS", source)
    end
    FirstStart = true
    LastTime = 0
    first = source:first() + 2
    mov = instance:addInternalStream(first, 0)
    trend = instance:addInternalStream(first, 0)
    wave = instance:addInternalStream(first, 0)
    vol = instance:addInternalStream(first, 0)
    count = instance:addInternalStream(first, 0)
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.dif .. ")"
    instance:name(name)
    UP = instance:addStream("UP", core.Bar, name .. ".UP", "UP", instance.parameters.UPclr, first)
    UP:setPrecision(math.max(2, instance.source:getPrecision()))
    DN = instance:addStream("DN", core.Bar, name .. ".DN", "DN", instance.parameters.DNclr, first)
    DN:setPrecision(math.max(2, instance.source:getPrecision()))
    upLabel = instance:createTextOutput("upLabel", "Length", "Arial", 12, core.H_Center, core.V_Top, instance.parameters.UPclr)
    downLabel = instance:createTextOutput("dnLabel", "Length", "Arial", 12, core.H_Center, core.V_Bottom, instance.parameters.DNclr)
    difPip = dif * source:pipSize()
end

function AsyncOperationFinished(cookie, success, message)
end

function Update(period, mode)
    if period > first then
        Ind:update(mode)
        if not (Ind.DATA:hasData(period)) then
            if period == first + 1 then
                FirstStart = true
            end
            return
        elseif FirstStart then
            FirstStart = false
            instance:updateFrom(first)
        elseif LastTime ~= source:date(period) and period == source:size() - 1 then
            LastTime = source:date(period)
            instance:updateFrom(period - 10)
        end
        if source.close[period] > source.close[period - 1] then
            mov[period] = 1
        elseif source.close[period] < source.close[period - 1] then
            mov[period] = -1
        else
            mov[period] = 0
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
            vol[period] = vol[period - 1] + Ind.DATA[period]
        else
            vol[period] = Ind.DATA[period]
        end
        if wave[period] == 1 then
            UP[period] = vol[period]
            DN[period] = 0
        elseif wave[period] == -1 then
            if Absolute then
                DN[period] = vol[period]
            else
                DN[period] = -vol[period]
            end
            UP[period] = 0
        end
        if period == 0 or (wave[period] == -1) ~= (count[period - 1] < 0) then
            count[period] = wave[period];
        else
            count[period] = count[period - 1] + wave[period];
        end
        if UP[period] ~= 0 then
            upLabel:set(period, UP[period], tostring(count[period]));
            if period > 0 then
                upLabel:setNoData(period - 1);
            end
        elseif DN[period] ~= 0 then
            downLabel:set(period, DN[period], tostring(math.abs(count[period])))
            if period > 0 then
                downLabel:setNoData(period - 1);
            end
        end
    end
end
