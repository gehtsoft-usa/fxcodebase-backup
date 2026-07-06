-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32547
-- Id: 8626

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("Universal oscillator")
    indicator:description("Universal oscillator")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addString("Type", "Type of oscillator", "", "BEARS")
    indicator.parameters:addStringAlternative("Type", "Bears", "", "BEARS")
    indicator.parameters:addStringAlternative("Type", "Bulls", "", "BULLS")
    indicator.parameters:addStringAlternative("Type", "CCI", "", "CCI")
    indicator.parameters:addStringAlternative("Type", "MACD", "", "MACD")
    indicator.parameters:addStringAlternative("Type", "DeMarker", "", "DEMARKER")
    indicator.parameters:addStringAlternative("Type", "Momentum", "", "MOMENTUM")
    indicator.parameters:addStringAlternative("Type", "RSI", "", "RSI")
    indicator.parameters:addStringAlternative("Type", "Stochastic", "", "STOCHASTIC")
    indicator.parameters:addStringAlternative("Type", "RLW", "", "RLW")
    indicator.parameters:addString("Price", "Price (only for MACD, Momentum, RSI)", "", "close")
    indicator.parameters:addStringAlternative("Price", "close", "", "close")
    indicator.parameters:addStringAlternative("Price", "open", "", "open")
    indicator.parameters:addStringAlternative("Price", "high", "", "high")
    indicator.parameters:addStringAlternative("Price", "low", "", "low")
    indicator.parameters:addStringAlternative("Price", "median", "", "median")
    indicator.parameters:addStringAlternative("Price", "typical", "", "typical")
    indicator.parameters:addStringAlternative("Price", "weighted", "", "weighted")

    indicator.parameters:addInteger("Period", "Period (Short EMA for MACD, %K periods for Stochastic)", "", 10)
    indicator.parameters:addInteger("Period2", "Long EMA for MACD, %D slowing for Stochastic", "", 12)
    indicator.parameters:addInteger("Period3", "Signal line for MACD, %D periods for Stochastic", "", 15)
    indicator.parameters:addString("DemSmooth", "DeMarker smoothing method", "", "MVA")
    indicator.parameters:addStringAlternative("DemSmooth", "MVA", "", "MVA")
    indicator.parameters:addStringAlternative("DemSmooth", "EMA", "", "EMA")
    indicator.parameters:addStringAlternative("DemSmooth", "LWMA", "", "LWMA")
    indicator.parameters:addStringAlternative("DemSmooth", "TMA", "", "TMA")
    indicator.parameters:addStringAlternative("DemSmooth", "SMMA*", "", "SMMA*")
    indicator.parameters:addStringAlternative("DemSmooth", "Vidya (1995)*", "", "Vidya (1995)*")
    indicator.parameters:addStringAlternative("DemSmooth", "Vidya (1992)*", "", "Vidya (1992)*")
    indicator.parameters:addStringAlternative("DemSmooth", "Wilders*", "", "Wilders*")
    indicator.parameters:addString("StochSmoothK", "Stochastic smoothing type for %K", "", "MVA")
    indicator.parameters:addStringAlternative("StochSmoothK", "MVA", "", "MVA")
    indicator.parameters:addStringAlternative("StochSmoothK", "EMA", "", "EMA")
    indicator.parameters:addStringAlternative("StochSmoothK", "Fast smoothed", "", "Fast smoothed")
    indicator.parameters:addString("StochSmoothD", "Stochastic smoothing type for %D", "", "MVA")
    indicator.parameters:addStringAlternative("StochSmoothD", "MVA", "", "MVA")
    indicator.parameters:addStringAlternative("StochSmoothD", "EMA", "", "EMA")

    indicator.parameters:addGroup("Style")
    indicator.parameters:addString("VType", "Type of chart", "", "Filling")
    indicator.parameters:addStringAlternative("VType", "Line", "", "Line")
    indicator.parameters:addStringAlternative("VType", "Filling", "", "Filling")
    indicator.parameters:addStringAlternative("VType", "Dot", "", "Dot")
    indicator.parameters:addString("LType", "Levels type", "", "Bollinger bands")
    indicator.parameters:addStringAlternative("LType", "Constant", "", "Constant")
    indicator.parameters:addStringAlternative("LType", "Moving average", "", "Moving average")
    indicator.parameters:addStringAlternative("LType", "Bollinger bands", "", "Bollinger bands")
    indicator.parameters:addInteger("LPeriod", "Levels period", "", 30)
    indicator.parameters:addDouble("LDeviation", "Levels deviation", "", 2)
    indicator.parameters:addBoolean("ColorMode", "ColorMode", "", true)
    indicator.parameters:addColor("MainClr", "Main color", "Main color", core.rgb(0, 255, 0))
    indicator.parameters:addColor(
        "UPclr",
        "UP color (if ColorMode=true)",
        "UP color (if ColorMode=true)",
        core.rgb(0, 0, 255)
    )
    indicator.parameters:addColor(
        "DNclr",
        "DN color (if ColorMode=true)",
        "DN color (if ColorMode=true)",
        core.rgb(255, 0, 0)
    )
    indicator.parameters:addColor("MiddleClr", "Middle line color", "Middle line color", core.rgb(128, 128, 128))
    indicator.parameters:addColor("UpLevelClr", "Up level color", "Up level color", core.rgb(128, 128, 128))
    indicator.parameters:addColor("DnLevelClr", "Dn level color", "Dn level color", core.rgb(128, 128, 128))
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5)
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID)
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE)
    indicator.parameters:addInteger("A", "Transparency (%)", "", 50, 0, 100)
end

local first
local source = nil
local Type
local Price
local Period
local Period2
local Period3
local DemSmooth
local StochSmoothK
local StochSmoothD
local VType
local LType
local LPeriod
local LDeviation
local ColorMode
local Ind
local UO = nil
local Middle = nil
local UpLevel = nil
local DnLevel = nil
local MA

function Prepare(nameOnly)
    source = instance.source
    Type = instance.parameters.Type
    Price = instance.parameters.Price
    Period = instance.parameters.Period
    Period2 = instance.parameters.Period2
    Period3 = instance.parameters.Period3
    DemSmooth = instance.parameters.DemSmooth
    StochSmoothK = instance.parameters.StochSmoothK
    StochSmoothD = instance.parameters.StochSmoothD
    VType = instance.parameters.VType
    LType = instance.parameters.LType
    LPeriod = instance.parameters.LPeriod
    LDeviation = instance.parameters.LDeviation
    ColorMode = instance.parameters.ColorMode

    assert(core.indicators:findIndicator("DEM") ~= nil, "Please, download and install DEM.LUA indicator")
    assert(core.indicators:findIndicator("BEARS") ~= nil, "Please, download and install BEARS.LUA indicator")
    assert(core.indicators:findIndicator("BULLS") ~= nil, "Please, download and install BULLS.LUA indicator")

    local IndName
    if Type == "BEARS" or Type == "BULLS" or Type == "CCI" or Type == "RLW" then
        if not nameOnly then
    assert(core.indicators:findIndicator(Type) ~= nil, Type .. " indicator must be installed");
            Ind = core.indicators:create(Type, source, Period)
        end
        IndName = Type .. " (" .. Period .. ")"
    elseif Type == "DEMARKER" then
        if not nameOnly then
            Ind = core.indicators:create("DEM", source, Period, DemSmooth)
        end
        IndName = "DeMarker (" .. Period .. ", " .. DemSmooth .. ")"
    elseif Type == "STOCHASTIC" then
        if not nameOnly then
            Ind = core.indicators:create("STOCHASTIC", source, Period, Period2, Period3, StochSmoothK, StochSmoothD)
        end
        IndName =
            "Stochastic (" ..
            Period .. ", " .. Period2 .. ", " .. Period3 .. ", " .. StochSmoothK .. ", " .. "StochSmoothD" .. ")"
    else
        local TickSource
        if Price == "close" then
            TickSource = source.close
        elseif Price == "open" then
            TickSource = source.open
        elseif Price == "high" then
            TickSource = source.high
        elseif Price == "low" then
            TickSource = source.low
        elseif Price == "median" then
            TickSource = source.median
        elseif Price == "typical" then
            TickSource = source.typical
        else
            TickSource = source.weighted
        end
        if Type == "MACD" then
            if not nameOnly then
                Ind = core.indicators:create("MACD", TickSource, Period, Period2, Period3)
            end
            IndName = "MACD (" .. Period .. ", " .. Period2 .. ", " .. Period3 .. ", " .. Price .. ")"
        else
            if not nameOnly then
                Ind = core.indicators:create(Type, TickSource, Period)
            end
            IndName = Type .. " (" .. Period .. ", " .. Price .. ")"
        end
    end

    local name = profile:id() .. "(" .. source:name() .. ", " .. IndName .. ")"
    instance:name(name)
    if nameOnly then
        return
    end
    if LType ~= "Constant" then
        MA = core.indicators:create("MVA", Ind.DATA, LPeriod)
        first = MA.DATA:first()
    else
        first = Ind.DATA:first()
    end
    Middle = instance:addStream("Middle", core.Line, name .. ".Middle", "Middle", instance.parameters.MiddleClr, first)
    Middle:setPrecision(math.max(2, instance.source:getPrecision()));
    UpLevel =
        instance:addStream("UpLevel", core.Line, name .. ".UpLevel", "UpLevel", instance.parameters.UpLevelClr, first)
    UpLevel:setPrecision(math.max(2, instance.source:getPrecision()));
    DnLevel =
        instance:addStream("DnLevel", core.Line, name .. ".DnLevel", "DnLevel", instance.parameters.DnLevelClr, first)
    DnLevel:setPrecision(math.max(2, instance.source:getPrecision()));
    if VType == "Line" then
        UO = instance:addStream("UO", core.Line, name .. ".UO", "UO", instance.parameters.MainClr, first)
    UO:setPrecision(math.max(2, instance.source:getPrecision()));
    UO:setPrecision(math.max(2, instance.source:getPrecision()));
    UO:setPrecision(math.max(2, instance.source:getPrecision()));
    elseif VType == "Filling" then
        UO = instance:addStream("UO", core.Line, name .. ".UO", "UO", instance.parameters.MainClr, first)
        instance:createChannelGroup("Gr", "Gr", UO, Middle, instance.parameters.MainClr, 100 - instance.parameters.A)
    else
        UO = instance:addStream("UO", core.Dot, name .. ".UO", "UO", instance.parameters.MainClr, first)
    end
    UO:setWidth(instance.parameters.widthLinReg)
    UO:setStyle(instance.parameters.styleLinReg)
end

function Update(period, mode)
    if period < first then
        return
    end

    Ind:update(mode)

    if LType ~= "Constant" then
        MA:update(mode)
    end

    if LType == "Constant" then
        Middle[period] = 0
        UpLevel[period] = LDeviation
        DnLevel[period] = -LDeviation
    elseif LType == "Moving average" then
        Middle[period] = MA.DATA[period]
        UpLevel[period] = Middle[period] + LDeviation
        DnLevel[period] = Middle[period] - LDeviation
    else
        Middle[period] = MA.DATA[period]
        local Dev = mathex.meandev(Middle, math.max(first, period - LPeriod + 1), period)
        UpLevel[period] = Middle[period] + Dev * LDeviation
        DnLevel[period] = Middle[period] - Dev * LDeviation
    end
    UO[period] = Middle[period] + Ind.DATA[period]
    if ColorMode then
        if UO[period] > 0 then
            UO:setColor(period, instance.parameters.UPclr)
        elseif UO[period] < 0 then
            UO:setColor(period, instance.parameters.DNclr)
        else
            UO:setColor(period, instance.parameters.MainClr)
        end
    end
end
