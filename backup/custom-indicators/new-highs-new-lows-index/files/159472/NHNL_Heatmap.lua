-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=22579&start=10
-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 
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

local timeframes = {
    {name = "m1", value = "m1", enabled = false},
    {name = "m5", value = "m5", enabled = false},
    {name = "m15", value = "m15", enabled = true},
    {name = "m30", value = "m30", enabled = false},
    {name = "H1", value = "H1", enabled = true},
    {name = "H2", value = "H2", enabled = false},
    {name = "H3", value = "H3", enabled = false},
    {name = "H4", value = "H4", enabled = true},
    {name = "H6", value = "H6", enabled = false},
    {name = "H8", value = "H8", enabled = false},
    {name = "D1", value = "D1", enabled = false},
    {name = "W1", value = "W1", enabled = false},
    {name = "M1", value = "M1", enabled = false}
};
function Init()
    indicator:name("Heatmap indicator")
    indicator:description("")
    indicator:requiredSource(core.Bar)
    indicator:type(core.Oscillator)

    indicator.parameters:addGroup("Indicator Parameters");
    indicator.parameters:addInteger("Period", "Period", "Period", 20);

    indicator.parameters:addGroup("Timeframe Selection");
    for _, tf in ipairs(timeframes) do
        indicator.parameters:addBoolean("use_" .. tf.name, "Use " .. tf.name, "", tf.enabled);
    end

    indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("up_color", "Up Color", "", core.COLOR_UPCANDLE)
    indicator.parameters:addColor("down_color", "Down Color", "", core.COLOR_DOWNCANDLE)
    indicator.parameters:addColor("neutral_color", "Neutral Color", "", core.rgb(128, 128, 128))
    indicator.parameters:addColor("labels_color", "Label Color", "", core.COLOR_LABEL)
end

local source;
local conditions = {};

function CreateIndicator(src)
    local profile = core.indicators:findIndicator("NHNL");
    assert(profile ~= nil, "Please, download and install " .. "NHNL" .. ".LUA indicator");
    local indicatorParams = profile:parameters();
    indicatorParams:setInteger("Period", instance.parameters.Period);
    return core.indicators:create("NHNL", src, indicatorParams);
end

function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end

    for i, tf in ipairs(timeframes) do
        if instance.parameters:getBoolean("use_" .. tf.name) then
            local condition = {};
            condition.src = sources:Request(i, source, tf.value);
            condition.indi = CreateIndicator(condition.src);
            condition.Name = tf.name;
            function condition:Update(period, mode)
                self.indi:update(mode);
            end
            function condition:GetSignal(period)
                local index = core.findDate(self.indi.DATA, source:date(period), false);
                if (index <= 0) then
                    return 0;
                end
                return self.indi.DATA[index] >= 0 and 1 or -1;
            end
            conditions[#conditions + 1] = condition;
        end
    end
    instance:ownerDrawn(true);
end

function ReleaseInstance()
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    if sources:AsyncOperationFinished(cookie, successful, message, message1, message2) then
        instance:updateFrom(0);
    end
end

function Update(period, mode)
    for index, condition in ipairs(conditions) do
        condition:Update(period, mode)
    end
end

local init = false;

local UP_PEN_ID = 1;
local UP_BRUSH_ID = 2;
local DOWN_PEN_ID = 3;
local DOWN_BRUSH_ID = 4;
local NEUTRAL_PEN_ID = 5;
local NEUTRAL_BRUSH_ID = 6;
local FONT_ID = 7;
local labels_color;

function Draw(stage, context)
    if stage ~= 0 or #conditions == 0 then
        return
    end

    context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom())
    if not init then
        local up_color = instance.parameters.up_color;
        local down_color = instance.parameters.down_color;
        local neutral_color = instance.parameters.neutral_color;
        context:createPen(UP_PEN_ID, context.SOLID, 1, up_color);
        context:createSolidBrush(UP_BRUSH_ID, up_color);
        context:createPen(DOWN_PEN_ID, context.SOLID, 1, down_color);
        context:createSolidBrush(DOWN_BRUSH_ID, down_color);
        context:createPen(NEUTRAL_PEN_ID, context.SOLID, 1, neutral_color);
        context:createSolidBrush(NEUTRAL_BRUSH_ID, neutral_color);
        context:createFont(FONT_ID, "Arial", 0, context:pointsToPixels(10), 0);
        labels_color = instance.parameters.labels_color;
        init = true
    end

    local first = math.max(source:first(), context:firstBar());
    local last = math.min(context:lastBar(), source:size() - 1);
    local total_height = context:bottom() - context:top();
    local cell_height = total_height / #conditions;

    for period = first, last do
        local x, x_start, x_end = context:positionOfBar(period);
        for index, condition in ipairs(conditions) do
            local signal = condition:GetSignal(period);
            local y_from = context:top() + cell_height * (index - 1);
            local y_to = y_from + cell_height - 1;
            if signal == 1 then
                context:drawRectangle(UP_PEN_ID, UP_BRUSH_ID, x_start, y_from, x_end, y_to);
            elseif signal == -1 then
                context:drawRectangle(DOWN_PEN_ID, DOWN_BRUSH_ID, x_start, y_from, x_end, y_to);
            else
                context:drawRectangle(NEUTRAL_PEN_ID, NEUTRAL_BRUSH_ID, x_start, y_from, x_end, y_to);
            end
        end
    end
    for index, condition in ipairs(conditions) do
        if condition.Name ~= nil then
            local x_to = context:right();
            local w, h = context:measureText(FONT_ID, condition.Name, 0);
            local x_from = x_to - w;
            local y_from = context:top() + cell_height * (index - 1) + (cell_height - 1 - h) / 2;
            local y_to = y_from + cell_height - 1 - (cell_height - 1 - h) / 2;

            context:drawText(FONT_ID, condition.Name, labels_color, -1, x_from, y_from, x_to, y_to, 0);
        end
    end
end
-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=22579&start=10
-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 