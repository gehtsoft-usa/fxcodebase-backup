-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1124

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

function Init()
    indicator:name("AMKA indicator")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)
    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addInteger("periodAMA", "periodAMA", "No description", 9)
    indicator.parameters:addDouble("nfast", "nfast", "No description", 2)
    indicator.parameters:addDouble("nslow", "nslow", "No description", 30)
    indicator.parameters:addDouble("Pow", "Pow", "No description", 2)
    indicator.parameters:addDouble("dK", "dK", "No description", 1)
    indicator.parameters:addString("use_stdev", "use_stdev", "", "true")
    indicator.parameters:addStringAlternative("use_stdev", "true", "", "true")
    indicator.parameters:addStringAlternative("use_stdev", "false", "", "false")
    indicator.parameters:addString("app_price", "app_price", "", "close")
    indicator.parameters:addStringAlternative("app_price", "close", "", "close")
    indicator.parameters:addStringAlternative("app_price", "open", "", "open")
    indicator.parameters:addStringAlternative("app_price", "high", "", "high")
    indicator.parameters:addStringAlternative("app_price", "low", "", "low")
    indicator.parameters:addStringAlternative("app_price", "median", "", "median")
    indicator.parameters:addStringAlternative("app_price", "typical", "", "typical")
    indicator.parameters:addStringAlternative("app_price", "weighted", "", "weighted")

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Line_color", "Color of line", "Color of line", core.rgb(0, 255, 0))
    indicator.parameters:addColor("UP_color", "Color of UP", "Color of UP", core.rgb(255, 0, 0))
    indicator.parameters:addColor("DN_color", "Color of DN", "Color of DN", core.rgb(0, 0, 255))
    indicator.parameters:addInteger("widthLinReg", "Dot size", "Dot size", 3, 1, 5)
end

local periodAMA
local nfast
local nslow
local Pow
local dK
local use_stdev
local app_price
--local Price;

local first
local source = nil
local buffLine = nil
local buffUp = nil
local buffDn = nil

local slowSC
local fastSC

local ddAMA = 0.

function Prepare(nameOnly)
    periodAMA = instance.parameters.periodAMA
    nfast = instance.parameters.nfast
    nslow = instance.parameters.nslow
    Pow = instance.parameters.Pow
    dK = instance.parameters.dK
    use_stdev = instance.parameters.use_stdev
    app_price = instance.parameters.app_price
    source = instance.source
    --Price = instance:addInternalStream(0, 0);
    first = source:first() + periodAMA
    local name =
        profile:id() ..
        "(" ..
            source:name() ..
                ", " .. periodAMA .. ", " .. nfast .. ", " .. nslow .. ", " .. Pow .. ", " .. app_price .. ")"
    instance:name(name)
    if nameOnly then
        return
    end
    buffLine =
        instance:addStream(
        "Line",
        core.Line,
        name .. ".Line",
        "Line",
        instance.parameters.Line_color,
        first + periodAMA
    )
    buffUp = instance:addStream("Up", core.Dot, name .. ".Up", "Up", instance.parameters.UP_color, first + periodAMA)
    buffDn = instance:addStream("Dn", core.Dot, name .. ".Dn", "Dn", instance.parameters.DN_color, first + periodAMA)
    buffUp:setWidth(instance.parameters.widthLinReg)
    buffDn:setWidth(instance.parameters.widthLinReg)
    slowSC = (2. / (nslow + 1.))
    fastSC = (2. / (nfast + 1.))
    ddAMA = core.makeArray(periodAMA)
end

function Update(period, mode)
    if period < first then
        return
    end
    local AMA0 = source[app_price][period - 1]
    if buffLine[period - 1] > 0 then
        AMA0 = buffLine[period - 1]
    end

    local Filter

    local signal = math.abs(source[app_price][period] - source[app_price][period - periodAMA])
    local noise = 0.000000001
    for i = 0, periodAMA - 1, 1 do
        noise = noise + math.abs(source[app_price][period - i] - source[app_price][period - i - 1])
    end
    local ER = signal / noise
    local SSC = ER * (fastSC - slowSC) + slowSC
    local AMA = AMA0 + math.pow(SSC, Pow) * (source[app_price][period] - AMA0)
    buffLine[period] = AMA

    local ddK = (AMA - AMA0) / source:pipSize()
    if use_stdev == "true" then
        InsertDif(ddK)
        if period - source:first() > 2 * periodAMA then
            local SMAdif = 0.
            for i = 0, periodAMA - 1, 1 do
                SMAdif = SMAdif + ddAMA[i]
            end
            SMAdif = SMAdif / periodAMA
            local StDev = 0.
            for i = 0, periodAMA - 1, 1 do
                StDev = StDev + math.pow(ddAMA[i] - SMAdif, 2)
            end
            StDev = math.sqrt(StDev) / periodAMA
            Filter = dK * StDev
        else
            Filter = 100000
        end
    else
        Filter = dK
    end

    local var1 = 0.
    local var2 = 0.
    if ddK > Filter then
        var1 = AMA
        buffUp[period] = AMA
    end
    if ddK < -Filter then
        var2 = AMA
        buffDn[period] = AMA
    end
    AMA0 = AMA
end

function InsertDif(a)
    for i = 0, periodAMA - 1, 1 do
        if ddAMA[i] == 0. then
            ddAMA[i] = a
        end
        for i = 0, periodAMA - 2, 1 do
            ddAMA[i] = ddAMA[i + 1]
        end
        ddAMA[periodAMA - 1] = a
    end
end
