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
    indicator:name("Ichimoku Support/Resistance");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addInteger("TenkanSenPeriod", "Tenkan-sen period", "Tenkan-sen period", 9, 1, 1000)
    indicator.parameters:addInteger("KijunSenPeriod", "Kijun-sen period", "Kijun-sen period", 26, 1, 1000)
    indicator.parameters:addInteger("SenkouSpanPeriod", "Senkou Span B period", "Senkou Span B period", 52, 1, 1000) 

    indicator.parameters:addString("tf1", "Timeframe 1", "", "M1");
    indicator.parameters:setFlag("tf1", core.FLAG_PERIODS);
    indicator.parameters:addString("tf2", "Timeframe 2", "", "W1");
    indicator.parameters:setFlag("tf2", core.FLAG_PERIODS);
    indicator.parameters:addString("tf3", "Timeframe 3", "", "D1");
    indicator.parameters:setFlag("tf3", core.FLAG_PERIODS);

    indicator.parameters:addColor("sr_color", "Support/Reistance Color", "Support/Resistance Color", core.colors().Red);
    indicator.parameters:addFile("file", "Log file", "", core.app_path() .. "\\Log\\Ichimoku_resistance.csv");
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

local source, ich1, ich2, ich3, sr1, sr2, sr3;
local TenkanSenPeriod, file, source1, source2, source3;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    TenkanSenPeriod = instance.parameters.TenkanSenPeriod;
    file = instance.parameters.file;

    source1 = sources:Request(1, source, instance.parameters.tf1);
    source2 = sources:Request(2, source, instance.parameters.tf2);
    source3 = sources:Request(3, source, instance.parameters.tf3);
    ich1 = core.indicators:create("ICH", source1, instance.parameters.TenkanSenPeriod, instance.parameters.KijunSenPeriod, instance.parameters.SenkouSpanPeriod);
    ich2 = core.indicators:create("ICH", source2, instance.parameters.TenkanSenPeriod, instance.parameters.KijunSenPeriod, instance.parameters.SenkouSpanPeriod);
    ich3 = core.indicators:create("ICH", source3, instance.parameters.TenkanSenPeriod, instance.parameters.KijunSenPeriod, instance.parameters.SenkouSpanPeriod);

    instance:ownerDrawn(true);
end

local init = false;
local sr_color;
local LINE = 1;
function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        init = true;
        sr_color = instance.parameters.sr_color;
        context:createPen(LINE, context.SOLID, 1, sr_color);
    end

    if sr1 ~= nil then
        local _, y = context:pointOfPrice(sr1);
        context:drawLine(LINE, context:left(), y, context:right(), y);
    end
    if sr2 ~= nil then
        local _, y = context:pointOfPrice(sr2);
        context:drawLine(LINE, context:left(), y, context:right(), y);
    end
    if sr3 ~= nil then
        local _, y = context:pointOfPrice(sr3);
        context:drawLine(LINE, context:left(), y, context:right(), y);
    end
end

function WriteToFile(period, date, value)
    local file = io.open(file, "a");
    file:write(period .. ";" .. core.formatDate(date) .. ";" .. value .. "\n");
    file:close();
end

function Update(period, mode)
    ich1:update(mode);
    ich2:update(mode);
    ich3:update(mode);

    local index1 = core.findDate(ich1.DATA, source:date(period), false);
    local index2 = core.findDate(ich2.DATA, source:date(period), false);
    local index3 = core.findDate(ich3.DATA, source:date(period), false);
    if index1 <= 0 or index2 <= 0 or index3 <= 0 
        or not ich1.TL:hasData(index1 - 1) 
        or not ich2.TL:hasData(index2 - 1) 
        or not ich3.TL:hasData(index3 - 1) 
    then
        return;
    end
    if ich1.TL[index1] == ich1.SB[index1 + TenkanSenPeriod] then
        sr1 = ich1.SB[index1];
        WriteToFile(source1:barSize(), source1:date(index1), sr1);
    end
    if ich2.TL[index2] == ich2.SB[index2 + TenkanSenPeriod] then
        sr2 = ich2.SB[index2];
        WriteToFile(source2:barSize(), source2:date(index2), sr2);
    end
    if ich3.TL[index3] == ich3.SB[index3 + TenkanSenPeriod] then
        sr3 = ich3.SB[index3];
        WriteToFile(source3:barSize(), source3:date(index3), sr3);
    end
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    sources:AsyncOperationFinished(cookie, successful, message, message1, message2);
end