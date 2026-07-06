-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=75407

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
 
function Init()
    indicator:name("WEDGE LINE BASED ON HIGHER TIME FRAME INSIDEBAR");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addInteger("length", "Inside Bar Calculation Period", "", 3);
    indicator.parameters:addString("timeframe", "Inside Bar Calculation Timeframe", "", "H1");
    indicator.parameters:setFlag("timeframe", core.FLAG_PERIODS);

    indicator.parameters:addColor("up_color", "Up Line Color", "", core.colors().Green);
    indicator.parameters:addInteger("up_width", "Up Line Width", "", 1);
    indicator.parameters:addInteger("up_style", "Up Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("up_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("dn_color", "Down Line Color", "", core.colors().Red);
    indicator.parameters:addInteger("dn_width", "Down Line Width", "", 1);
    indicator.parameters:addInteger("dn_style", "Down Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("dn_style", core.FLAG_LINE_STYLE);
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
local htf;
local length;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    length = instance.parameters.length;
    htf = sources:Request(1, source, instance.parameters.timeframe);
    instance:ownerDrawn(true)
end

function Update(period, mode)
end

local init = false;
local up_pen = 1;
local dn_pen = 2;

function FindInsideBar()
    local count = 0;
    for i = htf:size() - 2, length, -1 do
        if htf.high[i] > htf.high[i + 1] and htf.low[i] < htf.low[i + 1] then
            count = count + 1;
        else
            count = 0;
        end
        if count == length - 1 then
            return i, i + length - 1;
        end
    end
    return nil, nil;
end

function Draw(stage, context)
    if not sources:IsAllLoaded() then
        return;
    end
    if stage ~= 2 then
        return;
    end
    if not init then
        init = true;
        context:createPen(up_pen, context:convertPenStyle(instance.parameters.up_style), instance.parameters.up_width, instance.parameters.up_color);
        context:createPen(dn_pen, context:convertPenStyle(instance.parameters.dn_style), instance.parameters.dn_width, instance.parameters.dn_color);
    end
    local from, to = FindInsideBar();
    if from == nil then
        return;
    end
    local x1 = context:positionOfDate(htf:date(from));
    local x2 = context:positionOfDate(htf:date(to));
    local _, y1 = context:pointOfPrice(htf.high[from]);
    local _, y2 = context:pointOfPrice(htf.high[to]);
    context:drawLine(up_pen, x1, y1, x2, y2)
    local _, y1 = context:pointOfPrice(htf.low[from]);
    local _, y2 = context:pointOfPrice(htf.low[to]);
    context:drawLine(dn_pen, x1, y1, x2, y2)
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    if sources:AsyncOperationFinished(cookie, successful, message, message1, message2) then
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