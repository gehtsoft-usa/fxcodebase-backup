-- More information about this indicator can be found at:
-- http://fxcodebase.com/

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
    indicator:name("MA Channel");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addString("ma1_timeframe", "MA 1 Timeframe", "", "m5");
    indicator.parameters:setFlag("ma1_timeframe", core.FLAG_PERIODS);
    indicator.parameters:addInteger("ma1_period", "MA 1 period", "", 7);
    AddAverages("ma1_method", "MA 1 method", "MVA");
    
    indicator.parameters:addString("ma2_timeframe", "MA 2 Timeframe", "", "m15");
    indicator.parameters:setFlag("ma2_timeframe", core.FLAG_PERIODS);
    indicator.parameters:addInteger("ma2_period", "MA 2 period", "", 14);
    AddAverages("ma2_method", "MA 2 method", "MVA");

    indicator.parameters:addColor("ma1_color", "MA 1 Color", "Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("ma1_width", "MA 1 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("ma1_style", "MA 1 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("ma1_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("ma2_color", "MA 2 Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("ma2_width", "MA 2 Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("ma2_style", "MA 2 Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("ma2_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("channel_color", "Channel color", "", core.rgb(128, 128, 0));
    indicator.parameters:addInteger("transparency", "Transparency", "", 50, 0, 100);
end

function AddAverages(id, name, default)
    indicator.parameters:addString(id, name, "", default);
    indicator.parameters:addStringAlternative(id, "MVA", "", "MVA");
    indicator.parameters:addStringAlternative(id, "EMA", "", "EMA");
    indicator.parameters:addStringAlternative(id, "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative(id, "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative(id, "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative(id, "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative(id, "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative(id, "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative(id, "HMA", "", "HMA");
    indicator.parameters:addStringAlternative(id, "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative(id, "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative(id, "T3", "", "T3");
    indicator.parameters:addStringAlternative(id, "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative(id, "Median", "", "Median");
    indicator.parameters:addStringAlternative(id, "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative(id, "REMA", "", "REMA");
    indicator.parameters:addStringAlternative(id, "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative(id, "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative(id, "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative(id, "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative(id, "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative(id, "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative(id, "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative(id, "HPF", "", "HPF");
    indicator.parameters:addStringAlternative(id, "VAMA", "", "VAMA");
end

function CreateAverages(method, source, period)
    if method == "MVA" or method == "EMA" or method == "ARSI" 
        or method == "KAMA" or method == "LWMA" or method == "SMMA"
        or method == "VIDYA"
    then
        --assert(core.indicators:findIndicator(method) ~= nil, method .. " indicator must be installed");
        return core.indicators:create(method, source, period);
    end
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES indicator");
    return core.indicators:create("AVERAGES", source, method, period);
end

-- Sources v1.2
local sources = {}
sources.last_id = 1
sources.ids = {}
sources.items = {}
function sources:Request(id, source, tf, isBid)
	local ids = {}
	ids.loading_id = self.last_id
	ids.loaded_id = self.last_id + 1
	ids.loaded = false
	self.last_id = self.last_id + 2
	self.ids[id] = ids

	if isBid == nil then
		isBid = source:isBid()
	end

	self.items[id] = core.host:execute("getSyncHistory", source:instrument(), tf, isBid, 100, ids.loaded_id, ids.loading_id)
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

local ma1, ma2;
local source;
local channel_color;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end

    channel_color = instance.parameters.channel_color;

    ma1source = sources:Request(1, source, instance.parameters.ma1_timeframe);
    ma1 = CreateAverages(instance.parameters.ma1_method, ma1source, instance.parameters.ma1_period);
    ma2source = sources:Request(2, source, instance.parameters.ma2_timeframe);
    ma2 = CreateAverages(instance.parameters.ma2_method, ma2source, instance.parameters.ma2_period);

    ma1_stream = instance:addStream("MA 1", core.Line, "MA1", "MA1", instance.parameters.ma1_color, 0, 0);
    ma1_stream:setWidth(instance.parameters.ma1_width);
    ma1_stream:setStyle(instance.parameters.ma1_style);

    ma2_stream = instance:addStream("MA 2", core.Line, "MA2", "MA2", instance.parameters.ma2_color, 0, 0);
    ma2_stream:setWidth(instance.parameters.ma2_width);
    ma2_stream:setStyle(instance.parameters.ma2_style);

    instance:createChannelGroup("channel", "channel", ma1_stream, ma2_stream, instance.parameters.channel_color, instance.parameters.transparency);
end

function Update(period, mode)
    if not sources:IsAllLoaded() then
        return;
    end
    ma1:update(mode);
    ma2:update(mode);
    local index1 = core.findDate(ma1.DATA, source:date(period), false);
    if index1 >= 0 then
        ma1_stream[period] = ma1.DATA[index1];
    end

    local index2 = core.findDate(ma2.DATA, source:date(period), false);
    if index2 >= 0 then
        ma2_stream[period] = ma2.DATA[index2];
    end
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
	if sources:AsyncOperationFinished(cookie, successful, message, message1, message2) and sources:IsAllLoaded() then
		instance:updateFrom(0);
	end
end