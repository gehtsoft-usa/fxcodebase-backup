-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=71411&p=157426#p157426

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
    indicator:name("Grouped ROC");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addString("instruments", "(Instruments list) / count", "Only +/- are supported", "EUR/USD+USD/JPY-CAD/JPY");
    indicator.parameters:addInteger("Period", "Period", "Period", 24)
    indicator.parameters:addColor("stream_color", "Stream Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("stream_width", "Stream Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("stream_style", "Stream Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("stream_style", core.FLAG_LINE_STYLE);
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

local last_id = 1;
function GetIndicator(instrument)
    local indi = {};
    indi.source = sources:Request(tostring(last_id), instance.source, nil, nil, instrument);
    last_id = last_id + 1;
    function indi:Get(period)
        if self.source:size() < instance.parameters.Period or not self.source:hasData(period - instance.parameters.Period) then
            return nil;
        end
        return (self.source[period] - self.source[period - instance.parameters.Period]) / self.source:pipSize();
    end
    return indi;
end

local source;
local op = nil;
local count = 0;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    local instruments = instance.parameters.instruments;
    local len = string.len(instruments);
    local token = "";
    for i = 1, len, 1 do
        local ch = string.sub(instruments, i, i);
        if ch == "+" then
            local new_op = {};
            new_op.left = GetIndicator(token);
            count = count + 1;
            token = "";
            function new_op:Get(period)
                local l = self.left:Get(period);
                if l == nil then
                    return nil;
                end
                local r = self.right:Get(period);
                if r == nil then
                    return nil;
                end
                return l + r;
            end
            if op == nil then
                op = new_op;
            else
                op.right = new_op;
            end
        elseif ch == "-" then
            local new_op = {};
            new_op.left = GetIndicator(token);
            count = count + 1;
            token = "";
            function new_op:Get(period)
                local l = self.left:Get(period);
                if l == nil then
                    return nil;
                end
                local r = self.right:Get(period);
                if r == nil then
                    return nil;
                end
                return l - r;
            end
            if op == nil then
                op = new_op;
            else
                op.right = new_op;
            end
        else
            token = token .. ch;
        end
    end
    if op == nil then
        op = GetIndicator(token);
    else
        op.right = GetIndicator(token);
    end
    count = count + 1;
    stream = instance:addStream("Stream", core.Line, "ROC", "ROC", instance.parameters.stream_color, 0, 0);
    stream:setWidth(instance.parameters.stream_width);
    stream:setStyle(instance.parameters.stream_style);
end

function Update(period, mode)
    if not sources:IsAllLoaded() then
        return;
    end
    stream[period] = op:Get(period) / count;
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