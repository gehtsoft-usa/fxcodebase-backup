-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=27497&p=131735#p131735

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
    indicator:name("Katsanos Divergence");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("length", "Length", "", 14);

    indicator.parameters:addColor("div_color", "Divergence Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("div_width", "Divergence Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("div_style", "Divergence Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("div_style", core.FLAG_LINE_STYLE);
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

local src_2, source, div, length, temp, temp_ema;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    src_2 = sources:Request(1, source, nil, nil, nil);
    length = instance.parameters.length;
    div = instance:addStream("Divergence", core.Line, "Divergence", "Divergence", instance.parameters.div_color, 0, 0);
    div:setWidth(instance.parameters.div_width);
    div:setStyle(instance.parameters.div_style);
    temp = instance:addInternalStream(0, 0);
    temp_ema = core.indicators:create("EMA", temp, 3);
end

function Update(period, mode)
    if not sources:IsAllLoaded() or period < length or not src_2:hasData(period - length + 1) or not source:hasData(period - length + 1) then
        return;
    end
	
	if src_2:size()-1 < length then
	return;
	end
	
    val1 = mathex.lregSlope(src_2, period - length + 1, period);
    val2 = mathex.lregSlope(source, period - length + 1, period);
    temp[period] = val2 - val1;
    temp_ema:update(mode);
	if period < temp_ema.DATA:first() then
	return;
	end
	
    div[period] = temp_ema.DATA[period] * 100;
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    if sources:AsyncOperationFinished(cookie, successful, message, message1, message2) then
        instance:updateFrom(0);
    end
end