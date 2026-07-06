-- Id: 17053
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=64096

--+------------------------------------------------------------------+
--|                                            http://fxcodebase.com |
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
    indicator:name("Super Divergence Indicator V2.0")
    indicator:description("Multiple Choice Divergence")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("Choose Indicator for Divergence")
    indicator.parameters:addString("Indicator", "Choose one", "", "MACD")
    indicator.parameters:addStringAlternative("Indicator", "MACD", "", "MACD")
    indicator.parameters:addStringAlternative("Indicator", "CCI", "", "CCI")
    indicator.parameters:addStringAlternative("Indicator", "ROC", "", "ROC")
    indicator.parameters:addStringAlternative("Indicator", "TSI", "", "TSI")
    indicator.parameters:addStringAlternative("Indicator", "RSI", "", "RSI")
    indicator.parameters:addStringAlternative("Indicator", "MFI", "", "MFI")
    indicator.parameters:addStringAlternative("Indicator", "STOCH", "", "STOCHASTIC")

    indicator.parameters:addGroup("MACD Calculation")
    indicator.parameters:addInteger("MACD_N", "Period of short EMA for MACD", "", 12)
    indicator.parameters:addInteger("MACD_N2", "Period of long EMA for MACD", "", 26)
    indicator.parameters:addInteger("MACD_N3", "Signal period of MACD", "", 9)
    indicator.parameters:addDouble("MACD_OB", "MACD Overbought Level", "", 0.0002, -0.1, 0.1)
    indicator.parameters:addDouble("MACD_OS", "MACD Oversold Level", "", -0.0002, -0.1, 0.1)

    indicator.parameters:addGroup("CCI Calculation")
    indicator.parameters:addInteger("CCI_N", "Number of periods", "The number of periods.", 14, 2, 1000)
    indicator.parameters:addDouble("CCI_OB", "CCI Overbought (usually 100)", "", 100, 0, 500)
    indicator.parameters:addDouble("CCI_OS", "CCI Oversold (usually -100)", "", -100, -500, 0)

    indicator.parameters:addGroup("ROC Calculation")
    indicator.parameters:addInteger("ROC_N", "Periods for ROC Indicator ", "", 7)
    indicator.parameters:addDouble("ROC_OB", "ROC Overbought Level", "", 0.10, -5.00, 5.00)
    indicator.parameters:addDouble("ROC_OS", "ROC Oversold Level", "", -0.10, -5.00, 5.00)

    indicator.parameters:addGroup("TSI Calculation")
    indicator.parameters:addInteger("TSI_N", "Periods for TSI Indicator 1", "", 7)
    indicator.parameters:addInteger("TSI_N2", "Periods for TSI Indicator 2", "", 14)
    indicator.parameters:addDouble("TSI_OB", "TSI Overbought Level", "", 30, -100, 100)
    indicator.parameters:addDouble("TSI_OS", "TSI Oversold Level", "", -30, -100, 100)

    indicator.parameters:addGroup("RSI Calculation")
    indicator.parameters:addInteger("RSI_N", "Periods for RSI Indicator ", "", 7)
    indicator.parameters:addDouble("RSI_OB", "RSI Overbought Level", "", 70)
    indicator.parameters:addDouble("RSI_OS", "RSI Oversold Level", "", 30)

    indicator.parameters:addGroup("MFI Calculation")
    indicator.parameters:addInteger("MFI_N", "MFI Periods", "", 7)
    indicator.parameters:addDouble("MFI_OB", "MFI Overbought Level", "", 70)
    indicator.parameters:addDouble("MFI_OS", "MFI Oversold Level", "", 30)

    indicator.parameters:addGroup("Stochastic Calculation")
    indicator.parameters:addInteger("STOCH_N", "periods for %K", "", 5, 2, 1000)
    indicator.parameters:addInteger("STOCH_N2", "D smoothing periods", "", 3, 2, 1000)
    indicator.parameters:addInteger("STOCH_N3", "periods for %D", "", 3, 2, 1000)
    indicator.parameters:addDouble("STOCH_OB", "Stochastic Overbought Level", "", 70.0, 20, 100)
    indicator.parameters:addDouble("STOCH_OS", "Stochastic Oversold Level", "", 30.0, 1, 80)

    indicator.parameters:addGroup("Common")
    indicator.parameters:addBoolean(
        "I",
        "Indicator mode",
        "Keep true value to display labels and lines. Set this parameter to false when the indicator is used in another indicator.",
        true
    )
    indicator.parameters:addBoolean("showHidden", "Show Hidden (continuation) divergence?", "", true)
    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("D_color", "Color of Divergence line", "", core.rgb(0, 155, 255))
    indicator.parameters:addColor("UP_color", "Color of Uptrend", "", core.rgb(255, 0, 0))
    indicator.parameters:addColor("DN_color", "Color of Downtrend", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("level_overboughtsold_color", "Line Color", "", core.rgb(128, 128, 128))
    indicator.parameters:addInteger("level_overboughtsold_width", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N
local N2
local N3

local overbought
local oversold

local showHidden
local I
local DD
local UP_color
local DN_color

local first
local source = nil

-- Streams block
local D = nil
local UP = nil
local DN = nil
local IND = nil
local DIV = nil
local lineid = nil
local Indicator

-- Routine

local trough = {}
local peak = {}

function Prepare(nameOnly)
    Indicator = instance.parameters.Indicator

    if Indicator == "MACD" then
        N = instance.parameters.MACD_N
        N2 = instance.parameters.MACD_N2
        N3 = instance.parameters.MACD_N3
        overbought = instance.parameters.MACD_OB
        oversold = instance.parameters.MACD_OS
    end

    if Indicator == "CCI" then
        N = instance.parameters.CCI_N
        N2 = 0
        N3 = 0
        overbought = instance.parameters.CCI_OB
        oversold = instance.parameters.CCI_OS
    end

    if Indicator == "ROC" then
        N = instance.parameters.ROC_N
        N2 = 0
        N3 = 0
        overbought = instance.parameters.ROC_OB
        oversold = instance.parameters.ROC_OS
    end

    if Indicator == "TSI" then
        N = instance.parameters.TSI_N
        N2 = instance.parameters.TSI_N2
        N3 = 0
        overbought = instance.parameters.TSI_OB
        oversold = instance.parameters.TSI_OS
    end

    if Indicator == "RSI" then
        N = instance.parameters.RSI_N
        N2 = 0
        N3 = 0
        overbought = instance.parameters.RSI_OB
        oversold = instance.parameters.RSI_OS
    end

    if Indicator == "MFI" then
        N = instance.parameters.MFI_N
        N2 = 0
        N3 = 0
        overbought = instance.parameters.MFI_OB
        oversold = instance.parameters.MFI_OS
        assert(core.indicators:findIndicator("MFI") ~= nil, "Please, download and install MFI.LUA indicator")
    end

    if Indicator == "STOCHASTIC" then
        N = instance.parameters.STOCH_N
        N2 = instance.parameters.STOCH_N2
        N3 = instance.parameters.STOCH_N3
        overbought = instance.parameters.STOCH_OB
        oversold = instance.parameters.STOCH_OS
    end

    I = instance.parameters.I
    DD = instance.parameters.DD
    UP_color = instance.parameters.UP_color
    DN_color = instance.parameters.DN_color
    source = instance.source
    showHidden = instance.parameters.showHidden

    local name = profile:id() .. "(" .. source:name() .. ", " .. Indicator .. ", " .. N .. ")"
    instance:name(name)
    if nameOnly then
        return
    end
    assert(core.indicators:findIndicator(instance.parameters.Indicator) ~= nil, instance.parameters.Indicator .. " indicator must be installed");
    DIV = core.indicators:create(instance.parameters.Indicator, source, N, N2, N3)
    first = DIV.DATA:first()

    D =
        instance:addStream(
        instance.parameters.Indicator,
        core.Line,
        name .. "." .. instance.parameters.Indicator,
        instance.parameters.Indicator,
        instance.parameters.D_color,
        first,
        -1
    )
    D:setPrecision(math.max(2, instance.source:getPrecision()));
    D:addLevel(
        oversold,
        instance.parameters.level_overboughtsold_style,
        instance.parameters.level_overboughtsold_width,
        instance.parameters.level_overboughtsold_color
    )
    D:addLevel(
        overbought,
        instance.parameters.level_overboughtsold_style,
        instance.parameters.level_overboughtsold_width,
        instance.parameters.level_overboughtsold_color
    )
    if I then
        UP =
            instance:createTextOutput(
            "Up",
            "Up",
            "Wingdings",
            10,
            core.H_Center,
            core.V_Top,
            instance.parameters.UP_color,
            -1
        )
        DN =
            instance:createTextOutput(
            "Dn",
            "Dn",
            "Wingdings",
            10,
            core.H_Center,
            core.V_Bottom,
            instance.parameters.DN_color,
            -1
        )
    else
        UP = instance:addStream("UP", core.Bar, name .. ".UP", "UP", instance.parameters.D_color, first, -1)
    UP:setPrecision(math.max(2, instance.source:getPrecision()));
        DN = instance:addStream("DN", core.Bar, name .. ".DN", "DN", instance.parameters.D_color, first, -1)
    DN:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

local pperiod = nil
local pperiod1 = nil
local line_id = 0

-- Indicator calculation routine
function Update(period, mode)
    DIV:update(mode)

    -- if recaclulation started - remove all
    if pperiod ~= nil and pperiod > period then
        core.host:execute("removeAll")
    end
    pperiod = period
    -- process only candles which are already closed closed.
    if pperiod1 ~= nil and pperiod1 == source:serial(period) then
        return
    end

    pperiod1 = source:serial(period)
    period = period - 1

    if period >= first then
        D[period] = DIV.DATA[period]
        if period >= first + 5 then
            processBullish(period)
            processBearish(period)
        end
    end
end

function processBullish(period)
    if isTrough(period) then
        local curr, prev
        curr = period

        for prev = period - 3, first + 4, -1 do
            if trough[prev] ~= nil then
                if
                    source.low[curr] < source.low[curr - 1] and source.low[curr] < source.low[curr + 1] and
                        source.low[curr] <= source.low[prev] and
                        DIV.DATA[curr] >= DIV.DATA[prev]
                 then
                    if I then
                        DN:set(curr, DIV.DATA[curr], "\225", "Reversal Bullish")
                    else
                        DN:set(curr, DIV.DATA[curr], "\225", "Reversal Bullish")
                        UP:setNoData(curr)
                    end
                elseif
                    source.low[curr] < source.low[curr - 1] and source.low[curr] < source.low[curr + 1] and
                        source.low[curr] >= source.low[prev] and
                        DIV.DATA[curr] <= DIV.DATA[prev]
                 then
                    if showHidden then
                        if I then
                            DN:set(curr, DIV.DATA[curr], "\225", "Continuation Bullish")
                        else
                            DN:set(curr, DIV.DATA[curr], "\225", "Continuation Bullish")
                            UP:setNoData(curr)
                        end
                    end
                end
            end
        end
    end
end

function isTrough(period)
    if
        DIV.DATA[period] <= oversold and DIV.DATA[period] < DIV.DATA[period - 1] and
            DIV.DATA[period] < DIV.DATA[period + 1]
     then
        trough[period] = period
        return true
    else
        return false
    end
    return false
end

function processBearish(period)
    if isPeak(period) then
        local curr, prev
        curr = period

        for prev = period - 3, first + 4, -1 do
            if peak[prev] ~= nil then
                if
                    source.high[curr] > source.high[curr - 1] and source.high[curr] > source.high[curr + 1] and
                        source.high[curr] >= source.high[prev] and
                        DIV.DATA[curr] <= DIV.DATA[prev]
                 then
                    if I then
                        UP:set(curr, DIV.DATA[curr], "\226", "Reversal Bearish")
                    else
                        UP:set(curr, DIV.DATA[curr], "\226", "Reversal Bearish")
                        DN:setNoData(curr)
                    end
                elseif
                    source.high[curr] > source.high[curr - 1] and source.high[curr] > source.high[curr + 1] and
                        source.high[curr] <= source.high[prev] and
                        DIV.DATA[curr] >= DIV.DATA[prev]
                 then
                    if showHidden then
                        if I then
                            UP:set(curr, DIV.DATA[curr], "\226", "Continuation Bearish")
                        else
                            UP:set(curr, DIV.DATA[curr], "\226", "Continuation Bearish")
                            DN:setNoData(curr)
                        end
                    end
                end
            end
        end
    end
end

function isPeak(period)
    if
        DIV.DATA[period] >= overbought and DIV.DATA[period] > DIV.DATA[period - 1] and
            DIV.DATA[period] > DIV.DATA[period + 1]
     then
        peak[period] = period
        return true
    else
        return false
    end
    return false
end
