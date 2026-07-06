-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=70438

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
    indicator:name("Trend Sniper");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addBoolean("showExtra", "Show Higher Timeframe", "", true);
    indicator.parameters:addString("higherTime", "Extra Timeframe", "", "m15");
    indicator.parameters:setFlag("higherTime", core.FLAG_BARPERIODS);
    indicator.parameters:addBoolean("std", "Line chart", "", false);
    indicator.parameters:addBoolean("candles", "Candle chart", "", true);
    indicator.parameters:addBoolean("wicks", "Wicks", "", true);
    indicator.parameters:addInteger("len", "Current Length", "", 14);
    indicator.parameters:addInteger("len2", "Extra Timeframe Length", "", 14);

    indicator.parameters:addColor("up_bar_color", "Up bar color", "", core.colors().Green);
    indicator.parameters:addColor("down_bar_color", "Down bar color", "", core.colors().Red);
    indicator.parameters:addColor("RSI_close_color", "RSI Close Color", "Color", core.colors().Yellow);
    indicator.parameters:addInteger("RSI_close_width", "RSI Close Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("RSI_close_style", "RSI Close Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("RSI_close_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("RSI_extra_color", "RSI Extra Color", "Color", core.colors().Blue);
    indicator.parameters:addInteger("RSI_extra_width", "RSI Extra Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("RSI_extra_style", "RSI Extra Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("RSI_extra_style", core.FLAG_LINE_STYLE);
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

local source, htf, rsiExtra, gain_loss_close, gain_loss_close_abs, gain_loss_open_ma, gain_loss_open_abs_ma;
local wicks, gain_loss_open, gain_loss_open_abs, gain_loss_close_ma, gain_loss_close_abs_ma;
local gain_loss_high, gain_loss_high_abs, gain_loss_high_ma, gain_loss_high_abs_ma;
local gain_loss_low, gain_loss_low_abs, gain_loss_low_ma, gain_loss_low_abs_ma;
local RSI_open, RSI_close, RSI_high, RSI_low, up_bar_color, down_bar_color, RSI_extra;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    up_bar_color = instance.parameters.up_bar_color;
    down_bar_color = instance.parameters.down_bar_color;
    wicks = instance.parameters.wicks;
    htf = sources:Request(1, source, instance.parameters.higherTime);
    if instance.parameters.showExtra then
        rsiExtra = core.indicators:create("RSI", htf, instance.parameters.len2);
        RSI_extra = instance:addStream("RSI_extra", core.Line, "RSI Extra", "RSI Extra", instance.parameters.RSI_extra_color, 0, 0);
        RSI_extra:setWidth(instance.parameters.RSI_extra_width);
        RSI_extra:setStyle(instance.parameters.RSI_extra_style);
    end
    gain_loss_close = instance:addInternalStream(0, 0);
    gain_loss_close_abs = instance:addInternalStream(0, 0);
    gain_loss_close_ma = core.indicators:create("EMA", gain_loss_close, instance.parameters.len);
    gain_loss_close_abs_ma = core.indicators:create("EMA", gain_loss_close_abs, instance.parameters.len);
    gain_loss_high = instance:addInternalStream(0, 0);
    gain_loss_high_abs = instance:addInternalStream(0, 0);
    gain_loss_high_ma = core.indicators:create("EMA", gain_loss_high, instance.parameters.len);
    gain_loss_high_abs_ma = core.indicators:create("EMA", gain_loss_high_abs, instance.parameters.len);
    gain_loss_open = instance:addInternalStream(0, 0);
    gain_loss_open_abs = instance:addInternalStream(0, 0);
    gain_loss_open_ma = core.indicators:create("EMA", gain_loss_open, instance.parameters.len);
    gain_loss_open_abs_ma = core.indicators:create("EMA", gain_loss_open_abs, instance.parameters.len);
    gain_loss_low = instance:addInternalStream(0, 0);
    gain_loss_low_abs = instance:addInternalStream(0, 0);
    gain_loss_low_ma = core.indicators:create("EMA", gain_loss_low, instance.parameters.len);
    gain_loss_low_abs_ma = core.indicators:create("EMA", gain_loss_low_abs, instance.parameters.len);

    RSI_open = instance:addInternalStream(0, 0);
    if instance.parameters.std then
        RSI_close = instance:addStream("RSI_Close", core.Line, "RSI Close", "RSI CLose", instance.parameters.RSI_close_color, 0, 0);
        RSI_close:setWidth(instance.parameters.RSI_close_width);
        RSI_close:setStyle(instance.parameters.RSI_close_style);
        RSI_close:addLevel(30, core.LINE_SOLID, 1, core.rgb(42, 42, 42));
        RSI_close:addLevel(70, core.LINE_SOLID, 1, core.rgb(42, 42, 42));
        RSI_close:addLevel(20, core.LINE_SOLID, 1, core.rgb(63, 63, 63));
        RSI_close:addLevel(80, core.LINE_SOLID, 1, core.rgb(63, 63, 63));
    else
        RSI_close = instance:addInternalStream(0, 0);
    end
    RSI_high = instance:addInternalStream(0, 0);
    RSI_low = instance:addInternalStream(0, 0);
    if instance.parameters.candles then
        instance:createCandleGroup("bars", "bars", RSI_open, RSI_high, RSI_open, RSI_close);
    end
end

function Update(period, mode)
    if not sources:IsAllLoaded() then
        return;
    end
    if period == 0 then
        return;
    end
    local norm_close = (source.close[period] + source.close[period - 1]) / 2;
    gain_loss_close[period] = (source.close[period] - source.close[period - 1]) / norm_close;
    gain_loss_close_abs[period] = math.abs(gain_loss_close[period]);
    gain_loss_close_ma:update(mode);
    gain_loss_close_abs_ma:update(mode);
    if rsiExtra ~= nil then
        rsiExtra:update(mode);
        local index = core.findDate(rsiExtra.DATA, source.close:date(period), false);
        if index >= 0 then
            RSI_extra[period] = rsiExtra.DATA[index];
        end
    end
    RSI_close[period] = 50 + 50 * gain_loss_close_ma.DATA[period] / gain_loss_close_abs_ma.DATA[period];

    local norm_open = (source.open[period] + source.open[period - 1]) / 2;
    if wicks then
        norm_open = (source.close[period] + source.close[period - 1]) / 2;
    end
    gain_loss_open[period] = (source.open[period] - source.open[period - 1]) / norm_open;
    gain_loss_open_abs[period] = math.abs(gain_loss_open[period]);
    gain_loss_open_ma:update(mode);
    gain_loss_open_abs_ma:update(mode);
    RSI_open[period] = 50 + 50 * gain_loss_open_ma.DATA[period] / gain_loss_open_abs_ma.DATA[period];

    local norm_high = (source.high[period] + source.high[period - 1]) / 2;
    if wicks then
        norm_high = (source.close[period] + source.close[period - 1]) / 2;
    end
    gain_loss_high[period] = (source.high[period] - source.high[period - 1]) / norm_high;
    gain_loss_high_abs[period] = math.abs(gain_loss_high[period]);
    gain_loss_high_ma:update(mode);
    gain_loss_high_abs_ma:update(mode);
    RSI_high[period] = 50 + 50 * gain_loss_high_ma.DATA[period] / gain_loss_high_abs_ma.DATA[period];
    
    local norm_low = (source.low[period] + source.low[period - 1]) / 2;
    if wicks then
        norm_low = (source.close[period] + source.close[period - 1]) / 2;
    end
    gain_loss_low[period] = (source.low[period] - source.low[period - 1]) / norm_low;
    gain_loss_low_abs[period] = math.abs(gain_loss_low[period]);
    gain_loss_low_ma:update(mode);
    gain_loss_low_abs_ma:update(mode);
    RSI_low[period] = 50 + 50 * gain_loss_low_ma.DATA[period] / gain_loss_low_abs_ma.DATA[period];
    if RSI_close[period] > RSI_close[period - 1] then
        RSI_open:setColor(period, up_bar_color);
    else
        RSI_open:setColor(period, down_bar_color);
    end
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    if sources:AsyncOperationFinished(cookie, successful, message, message1, message2) then
        instance:updateFrom(0);
    end
end
