-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27375

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

function Add(id, Price1, P1, M1, Price2, P2, M2)
    indicator.parameters:addGroup(id .. ". MA Cross Calulation")
    indicator.parameters:addString("tf1_" .. id, "Timeframe", "", "m5");
    indicator.parameters:setFlag("tf1_" .. id, core.FLAG_PERIODS);
    indicator.parameters:addString("Price1" .. id, "1. MA Price Source", "", Price1)
    indicator.parameters:addStringAlternative("Price1" .. id, "OPEN", "", "open")
    indicator.parameters:addStringAlternative("Price1" .. id, "HIGH", "", "high")
    indicator.parameters:addStringAlternative("Price1" .. id, "LOW", "", "low")
    indicator.parameters:addStringAlternative("Price1" .. id, "CLOSE", "", "close")
    indicator.parameters:addStringAlternative("Price1" .. id, "MEDIAN", "", "median")
    indicator.parameters:addStringAlternative("Price1" .. id, "TYPICAL", "", "typical")
    indicator.parameters:addStringAlternative("Price1" .. id, "WEIGHTED", "", "weighted")
    indicator.parameters:addInteger("shift1_" .. id, "Shift", '', 0);

    indicator.parameters:addInteger("P1" .. id, "1. MA Period", "Period", P1)

    indicator.parameters:addString("M1" .. id, "Method", "", M1)
    indicator.parameters:addStringAlternative("M1" .. id, "MVA", "", "MVA")
    indicator.parameters:addStringAlternative("M1" .. id, "EMA", "", "EMA")
    indicator.parameters:addStringAlternative("M1" .. id, "Wilder", "", "Wilder")
    indicator.parameters:addStringAlternative("M1" .. id, "LWMA", "", "LWMA")
    indicator.parameters:addStringAlternative("M1" .. id, "SineWMA", "", "SineWMA")
    indicator.parameters:addStringAlternative("M1" .. id, "TriMA", "", "TriMA")
    indicator.parameters:addStringAlternative("M1" .. id, "LSMA", "", "LSMA")
    indicator.parameters:addStringAlternative("M1" .. id, "SMMA", "", "SMMA")
    indicator.parameters:addStringAlternative("M1" .. id, "HMA", "", "HMA")
    indicator.parameters:addStringAlternative("M1" .. id, "ZeroLagEMA", "", "ZeroLagEMA")
    indicator.parameters:addStringAlternative("M1" .. id, "DEMA", "", "DEMA")
    indicator.parameters:addStringAlternative("M1" .. id, "T3", "", "T3")
    indicator.parameters:addStringAlternative("M1" .. id, "ITrend", "", "ITrend")
    indicator.parameters:addStringAlternative("M1" .. id, "Median", "", "Median")
    indicator.parameters:addStringAlternative("M1" .. id, "GeoMean", "", "GeoMean")
    indicator.parameters:addStringAlternative("M1" .. id, "REMA", "", "REMA")
    indicator.parameters:addStringAlternative("M1" .. id, "ILRS", "", "ILRS")
    indicator.parameters:addStringAlternative("M1" .. id, "IE/2", "", "IE/2")
    indicator.parameters:addStringAlternative("M1" .. id, "TriMAgen", "", "TriMAgen")
    indicator.parameters:addStringAlternative("M1" .. id, "JSmooth", "", "JSmooth")
    indicator.parameters:addStringAlternative("M1" .. id, "KAMA", "", "KAMA")

    indicator.parameters:addString("Price2" .. id, "2. MA Price Source", "", Price2)
    indicator.parameters:addString("tf2_" .. id, "Timeframe", "", "m5");
    indicator.parameters:setFlag("tf2_" .. id, core.FLAG_PERIODS);
    indicator.parameters:addStringAlternative("Price2" .. id, "OPEN", "", "open")
    indicator.parameters:addStringAlternative("Price2" .. id, "HIGH", "", "high")
    indicator.parameters:addStringAlternative("Price2" .. id, "LOW", "", "low")
    indicator.parameters:addStringAlternative("Price2" .. id, "CLOSE", "", "close")
    indicator.parameters:addStringAlternative("Price2" .. id, "MEDIAN", "", "median")
    indicator.parameters:addStringAlternative("Price2" .. id, "TYPICAL", "", "typical")
    indicator.parameters:addStringAlternative("Price2" .. id, "WEIGHTED", "", "weighted")
    indicator.parameters:addInteger("shift2_" .. id, "Shift", '', 0);

    indicator.parameters:addInteger("P2" .. id, "2. MA Period", "Period", P2)

    indicator.parameters:addString("M2" .. id, "Method", "", M2)
    indicator.parameters:addStringAlternative("M2" .. id, "MVA", "", "MVA")
    indicator.parameters:addStringAlternative("M2" .. id, "EMA", "", "EMA")
    indicator.parameters:addStringAlternative("M2" .. id, "Wilder", "", "Wilder")
    indicator.parameters:addStringAlternative("M2" .. id, "LWMA", "", "LWMA")
    indicator.parameters:addStringAlternative("M2" .. id, "SineWMA", "", "SineWMA")
    indicator.parameters:addStringAlternative("M2" .. id, "TriMA", "", "TriMA")
    indicator.parameters:addStringAlternative("M2" .. id, "LSMA", "", "LSMA")
    indicator.parameters:addStringAlternative("M2" .. id, "SMMA", "", "SMMA")
    indicator.parameters:addStringAlternative("M2" .. id, "HMA", "", "HMA")
    indicator.parameters:addStringAlternative("M2" .. id, "ZeroLagEMA", "", "ZeroLagEMA")
    indicator.parameters:addStringAlternative("M2" .. id, "DEMA", "", "DEMA")
    indicator.parameters:addStringAlternative("M2" .. id, "T3", "", "T3")
    indicator.parameters:addStringAlternative("M2" .. id, "ITrend", "", "ITrend")
    indicator.parameters:addStringAlternative("M2" .. id, "Median", "", "Median")
    indicator.parameters:addStringAlternative("M2" .. id, "GeoMean", "", "GeoMean")
    indicator.parameters:addStringAlternative("M2" .. id, "REMA", "", "REMA")
    indicator.parameters:addStringAlternative("M2" .. id, "ILRS", "", "ILRS")
    indicator.parameters:addStringAlternative("M2" .. id, "IE/2", "", "IE/2")
    indicator.parameters:addStringAlternative("M2" .. id, "TriMAgen", "", "TriMAgen")
    indicator.parameters:addStringAlternative("M2" .. id, "JSmooth", "", "JSmooth")
    indicator.parameters:addStringAlternative("M2" .. id, "KAMA", "", "KAMA")
end

function Init()
    indicator:name("Three MA Cross Heatmap")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    Add(1, "close", 5, "EMA", "close", 6, "EMA")
    Add(2, "close", 13, "EMA", "close", 21, "EMA")
    Add(3, "close", 50, "EMA", "close", 200, "EMA")

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("Color", "Label Color", "", core.rgb(0, 0, 0))
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 255, 0))
    indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(255, 0, 0))
    indicator.parameters:addColor("Neutral", "Neutral Trend Color", "", core.rgb(128, 128, 128))

    indicator.parameters:addDouble("VSpace", "Vertical Spacing (%)", "", 5, 0, 50)
    indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)", "", 5, 0, 50)
    indicator.parameters:addDouble("Size", "Font Size (%)", "", 90, 50, 200)
end

-- Sources v1.3
local sources = {}
sources.last_id = 1
sources.ids = {}
sources.items = {}
function sources:Request(id, source, tf, isBid, instrument)
	local ids = {}
	ids.loading_id = self.last_id
	ids.loaded_id = self.last_id + 1
	ids.loaded = false
	self.last_id = self.last_id + 2
	self.ids[id] = ids

    if tf == nil then
        tf = source:barSize()
    end
	if isBid == nil then
		isBid = source:isBid()
    end
    if instrument == nil then
        instrument = source:instrument();
    end

	self.items[id] = core.host:execute("getSyncHistory", instrument, tf, isBid, 100, ids.loaded_id, ids.loading_id)
	return self.items[id];
end
function sources:AsyncOperationFinished(cookie, successful, message, message1, message2)
	for index, ids in pairs(self.ids) do
		if ids.loaded_id == cookie then
			ids.loaded = true
			self.allLoaded = nil
			return true
		elseif ids.loading_id == cookie then
			ids.loaded = false
			self.allLoaded = false
			return false
		end
	end
	return false
end
function sources:IsAllLoaded()
	if self.allLoaded == nil then
		for index, ids in pairs(self.ids) do
			if not ids.loaded then
				self.allLoaded = false
				return false
			end
		end
		self.allLoaded = true
	end
	return self.allLoaded
end

local source

local VSpace, HSpace
local Color
local Size

local Up, Down, Neutral

local data = {};
function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.source:name() .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    source = instance.source
    VSpace = (instance.parameters.VSpace / 100)
    HSpace = (instance.parameters.HSpace / 100)
    Method = instance.parameters.Method

    Up = instance.parameters.Up
    Down = instance.parameters.Down
    Neutral = instance.parameters.Neutral

    host = core.host
    Size = instance.parameters.Size
    Color = instance.parameters.Color
    instance:setLabelColor(Color)
    instance:ownerDrawn(true)

    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator")

    for i = 1, 3, 1 do
        local item = {};
        item.Shift1 = instance.parameters:getInteger("shift1_" .. i);
        item.Source1 = sources:Request(1, source, instance.parameters:getString("tf1_" .. i));
        item.Indicator1 = core.indicators:create("AVERAGES", item.Source1[instance.parameters:getString("Price1" .. i)], instance.parameters:getString("M1" .. i),
            instance.parameters:getInteger("P1" .. i), true)
        item.Shift2 = instance.parameters:getInteger("shift2_" .. i);
        item.Source2 = sources:Request(1, source, instance.parameters:getString("tf2_" .. i));
        item.Indicator2 = core.indicators:create("AVERAGES", item.Source2[instance.parameters:getString("Price2" .. i)], instance.parameters:getString("M2" .. i), 
            instance.parameters:getInteger("P2" .. i), true)
        data[#data + 1] = item;
    end
end

function Update(period, mode)
    if not sources:IsAllLoaded() then
        return;
    end
    for i, item in ipairs(data) do
        item.Indicator1:update(node);
        item.Indicator2:update(node);
    end
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    if sources:AsyncOperationFinished(cookie, successful, message, message1, message2) then
        instance:updateFrom(0);
    end
end

local init = false
local OTHER_PEN = 1;
local OTHER_BRUSH = 2;
local UP_PEN = 11;
local UP_BRUSH = 12;
local DOWN_PEN = 21;
local DOWN_BRUSH = 22;
local NEUTRAL_PEN = 31;
local NEUTRAL_BRUSH = 32;

function GetPenBrush(i, j)
    local index1 = core.findDate(data[j].Source1, source:date(i), false) - data[j].Shift1;
    local index2 = core.findDate(data[j].Source2, source:date(i), false) - data[j].Shift2;
    if data[j].Indicator1.DATA:hasData(index1) and data[j].Indicator2.DATA:hasData(index2) then
        if data[j].Indicator1.DATA[index1] > data[j].Indicator2.DATA[index2] then
            return UP_PEN, UP_BRUSH;
        elseif data[j].Indicator1.DATA[index1] < data[j].Indicator2.DATA[index2] then
            return DOWN_PEN, DOWN_BRUSH
        else
            return NEUTRAL_PEN, NEUTRAL_BRUSH
        end
    end
    return OTHER_PEN, OTHER_BRUSH
end

function Draw(stage, context)
    if stage ~= 0 then
        return
    end
    if not sources:IsAllLoaded() then
        return;
    end

    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
    context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom())
    if not init then
        context:createPen(OTHER_PEN, context.SOLID, 3, Color)
        context:createSolidBrush(OTHER_BRUSH, Color)

        context:createPen(UP_PEN, context.SOLID, 3, Up)
        context:createSolidBrush(UP_BRUSH, Up)

        context:createPen(DOWN_PEN, context.SOLID, 3, Down)
        context:createSolidBrush(DOWN_BRUSH, Down)

        context:createPen(NEUTRAL_PEN, context.SOLID, 3, Neutral)
        context:createSolidBrush(NEUTRAL_BRUSH, Neutral)

        init = true
    end

    local first = math.max(source:first(), context:firstBar())
    local last = math.min(context:lastBar(), source:size() - 1)

    X0, X1, X2 = context:positionOfBar(source:size() - 1)
    HCellSize = (X2 - X1) * HSpace
    VCellSize = ((context:bottom() - context:top()) / (4))

    for i = first, last, 1 do
        x0, x1, x2 = context:positionOfBar(i)

        for j = 1, 3, 1 do
            local pen, brush = GetPenBrush(i, j)
            context:drawRectangle(pen, brush, x1 + HCellSize, context:top() + VCellSize / 2 + VCellSize * (j - 1) + VCellSize * VSpace,
                x2 - HCellSize, context:top() + VCellSize / 2 + VCellSize * (j) - VCellSize * VSpace)

            if i == first then
                local width, height
                context:createFont(3, "Arial", ((X2 - X1) / 100) * Size, (VCellSize / 100) * Size, context.NORMAL)
                Value = tostring(j .. ".")
                width, height = context:measureText(3, Value, style)
                context:drawText(3, Value, Color, -1, X2 + (X2 - X1), context:top() + VCellSize / 2 + VCellSize * (j - 1) + VCellSize * VSpace,
                    X2 + (X2 - X1) + width, context:top() + VCellSize / 2 + VCellSize * (j) - VCellSize * VSpace, style)
            end
        end
    end
end
