-- Available @  https://fxcodebase.com/code/viewtopic.php?f=17&t=75393
 
--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                               https://appliedmachinelearning.systems/contact/  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+

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

function Init()
    indicator:name("Trending Candles using EMA and Mean Dot");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addString("timeframe", "Timeframe", "", "M1");
    indicator.parameters:setFlag("timeframe", core.FLAG_PERIODS);
    indicator.parameters:addInteger("ema_period", "EMA Period", "", 15);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("bull_color", "Bullish Color", "", core.colors().Lime);
    indicator.parameters:addColor("vbull_color", "Very Bullish Color", "", core.colors().DarkGreen);
    indicator.parameters:addColor("bear_color", "Bearish Color", "", core.colors().Red);
    indicator.parameters:addColor("vbear_color", "Very Bearish Color", "", core.colors().DarkRed);
    indicator.parameters:addColor("neutral_color", "Neutral Color", "", core.colors().Gray);
end

local source;
local o, h, l, c, v;
local bull_color, vbull_color, bear_color, vbear_color, neutral_color;
local btf, ema, mean;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    bull_color = instance.parameters.bull_color;
    vbull_color = instance.parameters.vbull_color;
    bear_color = instance.parameters.bear_color;
    vbear_color = instance.parameters.vbear_color;
    neutral_color = instance.parameters.neutral_color;
    btf = sources:Request(1, source, instance.parameters.timeframe);
    ema = core.indicators:create("EMA", btf, instance.parameters.ema_period);
    local profile = core.indicators:findIndicator("MEANTF_DOT");
    assert(profile ~= nil, "Please, download and install " .. "MEANTF_DOT" .. ".LUA indicator");
    mean = core.indicators:create("MEANTF_DOT", btf)

    o = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), 0)
    h = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), 0)
    l = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), 0)
    c = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), 0)
    v = instance:addStream("volume", core.Line, name, "volume", core.rgb(0, 0, 0), 0)
    instance:createCandleGroup(source:name(), source:name(), o, h, l, c, v);
end

function Update(period, mode)
    if not sources:IsAllLoaded() then
		return
	end
    o[period] = source.open[period];
    c[period] = source.close[period];
    h[period] = source.high[period];
    l[period] = source.low[period];
    v[period] = source.volume[period];
    ema:update(mode);
    mean:update(mode);
    local btf_period = core.findDate(btf, source:date(period), false);

    if source.close[period] > ema.DATA[btf_period] then
        local mean_bar = source.close[period] > mean.MeanUP[btf_period];
        if mean_bar and source.close[period] > mean.Prev[btf_period] then
            o:setColor(period, vbull_color);
        elseif mean_bar then
            o:setColor(period, bull_color);
        else
            o:setColor(period, neutral_color);
        end
    elseif source.close[period] < ema.DATA[btf_period] then
        local mean_bar = source.close[period] < mean.MeanDN[btf_period];
        if mean_bar and source.close[period] < mean.Prev[btf_period] then
            o:setColor(period, vbear_color);
        elseif mean_bar then
            o:setColor(period, bear_color);
        else
            o:setColor(period, neutral_color);
        end
    else
        o:setColor(period, neutral_color);
    end
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
	if sources:AsyncOperationFinished(cookie, successful, message, message1, message2) and sources:IsAllLoaded() then
		instance:updateFrom(0);
	end
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+