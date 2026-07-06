--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("Price Overlay");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addString("instrument", "Instrument", "", "EUR/USD");
    indicator.parameters:setFlag("instrument", core.FLAG_INSTRUMENTS);
    indicator.parameters:addColor("color", "Color", "", core.colors().Red);
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

local source;
local instrument;
local overlay;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    instrument = instance.parameters.instrument;
    overlay = sources:Request(1, source, nil, nil, instrument);

    instance:ownerDrawn(true);
end

function Update(period, mode)
end

local init = false;
local pen = 1;
function Draw(stage, context)
    if stage ~= 2 or not sources:IsAllLoaded() then
        return;
    end
    if not init then
        init = true;
        context:createPen(pen, context.SOLID, 1, instance.parameters.color);
    end

    local stream = overlay.close;

    local from_bar = math.max(source:first(), context:firstBar() - 1)
    local to_bar = math.min(context:lastBar(), source:size() - 1)
    local indi_min, indi_max;
    for i = from_bar, to_bar, 1 do
        local index = core.findDate(stream, source:date(i), false);
        if index >= 0 and stream:hasData(index) then
            if indi_min == nil then
                indi_min = stream[index];
                indi_max = stream[index];
            else
                if indi_min > stream[index] then
                    indi_min = stream[index];
                end
                if indi_max < stream[index] then
                    indi_max = stream[index];
                end
            end
        end
    end
    if indi_min == nil then
        return;
    end

    local previous_value, previous_x, previous_y;
    local top = context:top();
    local bottom = context:bottom();
    local range = bottom - top;
    local indi_range = indi_max - indi_min;
    if indi_range == nil then
        return;
    end
	for i = from_bar, to_bar, 1 do
        local index = core.findDate(stream, source:date(i), false);
        if index >= 0 and stream:hasData(index) then
            local x_center, x_left, x_right = context:positionOfBar(i);
            local y = top + range * (indi_max - stream[index]) / indi_range;
            if previous_value ~= nil then
                context:drawLine(pen, previous_x, previous_y, x_center, y);
            end
            previous_x = x_center;
            previous_y = y;
            previous_value = stream[index];
        end
	end
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    sources:AsyncOperationFinished(cookie, successful, message, message1, message2);
end