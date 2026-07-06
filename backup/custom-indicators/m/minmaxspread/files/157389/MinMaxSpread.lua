-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75384

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
    indicator:name("Min/Max Spread");
    indicator:description("Min/Max Spread");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addColor("min_color", "Min spread color", "", core.colors().Green);
    indicator.parameters:addColor("max_color", "Max spread color", "", core.colors().Red);
end

local source;
local other_source;
local min_color;
local max_color;
local tradingWeekOffset, tradingDayOffset;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    min_color = instance.parameters.min_color;
    max_color = instance.parameters.max_color;
    other_source = sources:Request(1, source, source:barSize(), not source:isBid(), source:instrument());
    tradingWeekOffset = core.host:execute("getTradingWeekOffset");
    tradingDayOffset = core.host:execute("getTradingDayOffset");
    instance:ownerDrawn(true);
end

function Update(period, mode)
end

local min_pen;
local max_pen;
local font;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not sources:IsAllLoaded() then
        return;
    end
    if min_pen == nil then
        min_pen = 1;
        max_pen = 2;
        font = 3;
        context:createPen(min_pen, context.SOLID, 1, instance.parameters.min_color);
        context:createPen(max_pen, context.SOLID, 1, instance.parameters.max_color);
        context:createFont(font, "Arial", 0, context:pointsToPixels(12), context.LEFT);
    end
    local s, e = core.getcandle("D1", source:date(NOW), tradingDayOffset, tradingWeekOffset);
    local start = math.max(0, core.findDate(source, s, false));
    local min_spread, max_spread;
    local min_spread_index, max_spread_index;
    for i = start, source:size() - 1 do
        local spread = math.abs(source.close[i] - other_source.close[i]) / source:pipSize();
        if min_spread == nil or min_spread > spread then
            min_spread = spread;
            min_spread_index = i;
        end
        if max_spread == nil or max_spread < spread then
            max_spread = spread;
            max_spread_index = i;
        end
    end
    local _, x2 = context:positionOfBar(source:size() - 1);
    local _, x = context:positionOfBar(min_spread_index);
    local _, y = context:pointOfPrice(source.close[min_spread_index]);
    context:drawLine(min_pen, x, y, x2, y);
    local text = win32.formatNumber(min_spread, false, 2) .. " min";
    local w, h = context:measureText(font, text, context.LEFT);
    context:drawText(font, text, core.COLOR_LABEL, -1, x2 - w, y - h, x2, y, context.LEFT);

    local _, x = context:positionOfBar(max_spread_index);
    local _, y = context:pointOfPrice(source.close[max_spread_index]);
    context:drawLine(max_pen, x, y, x2, y);
    local text = win32.formatNumber(max_spread, false, 2) .. " max";
    local w, h = context:measureText(font, text, context.LEFT);
    context:drawText(font, text, core.COLOR_LABEL, -1, x2 - w, y - h, x2, y, context.LEFT);
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