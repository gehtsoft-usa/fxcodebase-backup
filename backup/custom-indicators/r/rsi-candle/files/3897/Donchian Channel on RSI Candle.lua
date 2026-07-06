-- Id: 24064
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1927

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("Donchian Channel on RSI Candle")
    indicator:description("RSI Candle")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)
    indicator.parameters:addGroup("RSI Calculation")
    indicator.parameters:addInteger("Frame", "RSI period", "RSI Period", 14)

    indicator.parameters:addGroup("Donchian Calculation")
    indicator.parameters:addInteger("N", "Number of periods", "", 20, 1, 10000)
    indicator.parameters:addString("AC", "Analyze the current period", "", "yes")
    indicator.parameters:addStringAlternative("AC", "no", "", "no")
    indicator.parameters:addStringAlternative("AC", "yes", "", "yes")

    indicator.parameters:addString("SM", "Show middle line", "", "no")
    indicator.parameters:addStringAlternative("SM", "no", "", "no")
    indicator.parameters:addStringAlternative("SM", "yes", "", "yes")

    indicator.parameters:addString("Type", "RSI Type", "", "Bar")
    indicator.parameters:addStringAlternative("Type", "Bar", "", "Bar")
    indicator.parameters:addStringAlternative("Type", "Line", "", "Line")
    indicator.parameters:addStringAlternative("Type", "Nothing", "", "Nothing")

    indicator.parameters:addGroup("Style")
    indicator.parameters:addDouble("OB", "OB Level", "OB Level", 70)
    indicator.parameters:addDouble("OS", "OS Level", "OS Level", 30)
    --indicator.parameters:addBoolean("ShowCandles", "Show Candles", "", true);
    indicator.parameters:addBoolean("Show", "Show OB/OS Zone", "", true)
    indicator.parameters:addInteger("transp", "Zone Transparency %", "", 80, 0, 100)

    indicator.parameters:addColor("Top", "OB Zone Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Bottom", "OS Zone Color", "", core.rgb(255, 0, 0))

    indicator.parameters:addGroup("RSI Line Style")
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(128, 128, 128))
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
    indicator.parameters:addGroup("Donchian Lines Style")
    indicator.parameters:addColor("clrDU", "Color of the Up line", "", core.rgb(0, 255, 0))
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE)
    indicator.parameters:addColor("clrDN", "Color of the Down line", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE)
    indicator.parameters:addColor("clrDM", "Color of the middle line", "", core.rgb(0, 0, 255))
    indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5)
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID)
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame
local Show
local first
local source = nil

-- Streams block
local Open = nil
local Close = nil
local High = nil
local Low = nil
local Type

local RSIOpen = nil
local RSIClose = nil
local RSIHigh = nil
local RSILow = nil
local OB, OS
local UpLow, UpHigh, DownLow, DownHigh
local Top, Bottom
local Line
local n
--local ShowCandles;
-- Routine
function Prepare(nameOnly)
    Frame = instance.parameters.Frame
    Show = instance.parameters.Show
    Top = instance.parameters.Top
    Bottom = instance.parameters.Bottom
    Type = instance.parameters.Type

    source = instance.source

    n = instance.parameters.N

    ---ShowCandles= instance.parameters.ShowCandles;

    OB = instance.parameters.OB
    OS = instance.parameters.OS

    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ")"
    instance:name(name)
    if nameOnly then
        return
    end

    RSIClose = core.indicators:create("RSI", source.close, Frame)

    if Type == "Bar" then
        RSIOpen = core.indicators:create("RSI", source.open, Frame)
        RSIHigh = core.indicators:create("RSI", source.high, Frame)
        RSILow = core.indicators:create("RSI", source.low, Frame)
    end

    if Type == "Bar" then
        Open = instance:addStream("Open", core.Line, name .. "", "", core.COLOR_LABEL, RSIClose.DATA:first())
        Open:setPrecision(math.max(2, instance.source:getPrecision()))
        Close = instance:addStream("Close", core.Line, name .. "", "", core.COLOR_LABEL, RSIClose.DATA:first())
        Close:setPrecision(math.max(2, instance.source:getPrecision()))
        High = instance:addStream("High", core.Line, name .. "", "", core.COLOR_LABEL, RSIClose.DATA:first())
        High:setPrecision(math.max(2, instance.source:getPrecision()))
        Low = instance:addStream("Low", core.Line, name .. "", "", core.COLOR_LABEL, RSIClose.DATA:first())
        Low:setPrecision(math.max(2, instance.source:getPrecision()))
        instance:createCandleGroup("RSI", "RSI Candle", Open, High, Low, Close)
    elseif Type == "Line" then
        Line =
            instance:addStream("RSI", core.Line, name .. "RSI", "RSI", instance.parameters.color, RSIClose.DATA:first())
        Line:setPrecision(math.max(2, instance.source:getPrecision()))
        Line:setWidth(instance.parameters.width)
        Line:setStyle(instance.parameters.style)
    else
        Line = instance:addInternalStream(0, 0)
    end

    UpLow = instance:addStream("UpLow", core.Line, name .. "", "", core.COLOR_LABEL, RSIClose.DATA:first())
    UpLow:setPrecision(math.max(2, instance.source:getPrecision()))
    DownLow = instance:addStream("DownLow", core.Line, name .. "", "", core.COLOR_LABEL, RSIClose.DATA:first())
    DownLow:setPrecision(math.max(2, instance.source:getPrecision()))
    UpHigh = instance:addStream("UpHigh", core.Line, name .. "", "", core.COLOR_LABEL, RSIClose.DATA:first())
    UpHigh:setPrecision(math.max(2, instance.source:getPrecision()))
    DownHigh = instance:addStream("DownHigh", core.Line, name .. "", "", core.COLOR_LABEL, RSIClose.DATA:first())
    DownHigh:setPrecision(math.max(2, instance.source:getPrecision()))

    if Show then
        instance:createChannelGroup("UP", "UP", UpLow, UpHigh, Top, 100 - instance.parameters.transp)
        instance:createChannelGroup("DOWN", "DOWN", DownLow, DownHigh, Bottom, 100 - instance.parameters.transp)
    end

    ac = (instance.parameters.AC == "yes")
    sm = (instance.parameters.SM == "yes")

    Period = instance.parameters.Period

    first = n + RSIClose.DATA:first() - 1
    if (not ac) then
        first = first + 1
    end

    du = instance:addStream("DU", core.Line, name .. ".DU", "DU", instance.parameters.clrDU, first)
    du:setWidth(instance.parameters.width1)
    du:setStyle(instance.parameters.style1)
    dn = instance:addStream("DN", core.Line, name .. ".DN", "DN", instance.parameters.clrDN, first)
    dn:setWidth(instance.parameters.width2)
    dn:setStyle(instance.parameters.style2)
    if (sm) then
        dm = instance:addStream("DM", core.Line, name .. ".DM", "DM", instance.parameters.clrDM, first)
        dm:setWidth(instance.parameters.width3)
        dm:setStyle(instance.parameters.style3)
    end

    du:setPrecision(math.max(2, instance.source:getPrecision()))
    dn:setPrecision(math.max(2, instance.source:getPrecision()))
    if (sm) then
        dm:setPrecision(math.max(2, instance.source:getPrecision()))
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    RSIClose:update(mode)

    if Type == "Bar" then
        RSIHigh:update(mode)
        RSILow:update(mode)
        RSIOpen:update(mode)
    end

    if period <= RSIClose.DATA:first() or not source:hasData(period) then
        return
    end

    UpLow[period] = OB
    DownLow[period] = 0
    UpHigh[period] = 100
    DownHigh[period] = OS

    if Type == "Bar" then
        Open[period] = RSIOpen.DATA[period]
        Close[period] = RSIClose.DATA[period]
        High[period] = math.max(Open[period], Close[period], RSIHigh.DATA[period])
        Low[period] = math.min(Open[period], Close[period], RSILow.DATA[period])
    else
        Line[period] = RSIClose.DATA[period]
    end

    if period < first then
        return
    end

    if Type == "Bar" then
        if (ac) then
            dn[period] = mathex.min(Low, period - n + 1, period)
            du[period] = mathex.max(High, period - n + 1, period)
        else
            dn[period] = mathex.min(Low, period - n + 1 - 1, period - 1)
            du[period] = mathex.max(High, period - n + 1 - 1, period - 1)
        end
    else
        if (ac) then
            dn[period] = mathex.min(Line, period - n + 1, period)
            du[period] = mathex.max(Line, period - n + 1, period)
        else
            dn[period] = mathex.min(Line, period - n + 1 - 1, period - 1)
            du[period] = mathex.max(Line, period - n + 1 - 1, period - 1)
        end
    end

    if (sm) then
        dm[period] = (du[period] + dn[period]) / 2
    end
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+