-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65883
-- Id: 20829

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("SAR indicator")
    indicator:description("SAR indicator")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Indicator)

    indicator.parameters:addGroup("Calculation")

    indicator.parameters:addString("TF", "Indicator Time Frame", "", "D1")
    indicator.parameters:setFlag("TF", core.FLAG_BARPERIODS_EDIT)

    indicator.parameters:addDouble("Step", "Step", "", 0.02, 0.001, 1);
    indicator.parameters:addDouble("Max",  "Max",  "", 0.2,  0.001, 10);

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("up_clr",   "Up Color",   "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("down_clr", "Down Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addInteger("width",  "Dot size",   "", 1, 1, 5)
end

local first
local source = nil
local Step
local Max

local Indicator

local SAR_UP = nil
local SAR_DN = nil
local TF

local dayoffset
local weekoffset
local SourceData
local loading = false

function Prepare(nameOnly)
    source = instance.source
    Max  = instance.parameters.Max
    Step = instance.parameters.Step
    TF = instance.parameters.TF

    dayoffset  = core.host:execute("getTradingDayOffset")
    weekoffset = core.host:execute("getTradingWeekOffset")

    local name = profile:id() .. "(" .. source:name() .. ", " .. Max .. ", " .. Step .. ", " .. instance.parameters.TF .. ")"
    instance:name(name)
    if (nameOnly) then
        return
    end

    local s1, e1, s2, e2
    s1, e1 = core.getcandle(source:barSize(), 0, 0, 0)
    s2, e2 = core.getcandle(TF, 0, 0, 0)
    assert((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!")

    SourceData = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0, 100, 101)
    loading    = true

    Indicator = core.indicators:create("SAR", SourceData, Step, max)
    first     = Indicator.DATA:first()

    SAR_UP = instance:addStream("SARU", core.Dot, name .. ".SARU", "SARU", instance.parameters.up_clr, first)
    SAR_UP:setWidth(instance.parameters.width)
    SAR_DN = instance:addStream("SARD", core.Dot, name .. ".SARD", "SARD", instance.parameters.down_clr, first)
    SAR_DN:setWidth(instance.parameters.width)
end

function Initialization(period)
    local Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset)
    if loading or SourceData:size() == 0 then
        return false
    end
    if period < source:first() then
        return false
    end

    local p = core.findDate(SourceData, Candle, false)
    -- candle is not found
    if p < 0 then
        return false
    else
        return p
    end
end

function Update(period, mode)
    if (period < first) then
        return
    end

    Indicator:update(mode)
    local p = Initialization(period)
    if not p then
        return
    end

    if Indicator.UP:hasData(p) then
        SAR_UP[period] = Indicator.UP[p]
    end
    if Indicator.DN:hasData(p) then
        SAR_DN[period] = Indicator.DN[p]
    end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false
        instance:updateFrom(0)
    elseif cookie == 101 then
        loading = true
    end
end
