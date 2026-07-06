-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69420

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
    indicator:name("RSMK");
    indicator:description("description");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addInteger("ema_period", "EMA period", "", 3);
    indicator.parameters:addString("instrument", "Comparison Index", "", "SPX500");
    indicator.parameters:setFlag("instrument", core.FLAG_INSTRUMENTS);
    indicator.parameters:addInteger("shift", "Shift, bars", "", 90)

    indicator.parameters:addColor("out_color", "Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("out_width", "Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("out_style", "Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("out_style", core.FLAG_LINE_STYLE);
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
local source, data, ema, out, compare_source, shift;
function Prepare(nameOnly)
    source = instance.source;
    shift = instance.parameters.shift;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end

    compare_source = sources:Request(1, source, nil, nil, instance.parameters.instrument);
    data = instance:addInternalStream(0, 0);
    ema = core.indicators:create("EMA", data, instance.parameters.ema_period);
    out = instance:addStream("RSMK", core.Line, "RSMK", "RSMK", instance.parameters.out_color, 0, 0);
    out:setWidth(instance.parameters.out_width);
    out:setStyle(instance.parameters.out_style);
end

function Update(period, mode)
    if not sources:IsAllLoaded() then
        return;
    end
    local compare_period = core.findDate(compare_source, source:date(period), false);
    if compare_period < 0 or period < shift then
        return;
    end
    local compare_period_shift = core.findDate(compare_source, source:date(period - shift), false);
    if compare_period_shift < 0 then
        return;
    end
    data[period] = math.log(source.close[period] / compare_source.close[compare_period]) 
        - math.log(source.close[period - shift] / compare_source.close[compare_period_shift]);
    ema:update(mode);
    out[period] = ema.DATA[period] * 100;
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    if sources:AsyncOperationFinished(cookie, successful, message, message1, message2) then
        instance:updateFrom(0);
    end
end