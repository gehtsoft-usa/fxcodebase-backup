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
    indicator.parameters:addInteger("sr_width", "Support/Reistance Width", "Support/Resistance Width", 1, 1, 5);
    indicator.parameters:addInteger("sr_style", "Support/Reistance Style", "Support/Resistance Style", core.LINE_SOLID);
    indicator.parameters:setFlag("sr_style", core.FLAG_LINE_STYLE);
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
local TenkanSenPeriod;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    TenkanSenPeriod = instance.parameters.TenkanSenPeriod;

    local source1 = sources:Request(1, source, instance.parameters.tf1);
    local source2 = sources:Request(2, source, instance.parameters.tf2);
    local source3 = sources:Request(3, source, instance.parameters.tf3);
    ich1 = core.indicators:create("ICH", source1, instance.parameters.TenkanSenPeriod, instance.parameters.KijunSenPeriod, instance.parameters.SenkouSpanPeriod);
    ich2 = core.indicators:create("ICH", source2, instance.parameters.TenkanSenPeriod, instance.parameters.KijunSenPeriod, instance.parameters.SenkouSpanPeriod);
    ich3 = core.indicators:create("ICH", source3, instance.parameters.TenkanSenPeriod, instance.parameters.KijunSenPeriod, instance.parameters.SenkouSpanPeriod);
    sr1 = instance:addStream("SR1", core.Line, "Support/Resistance 1", "Support/Resistance 1", instance.parameters.sr_color, 0, 0);
    sr1:setWidth(instance.parameters.sr_width);
    sr1:setStyle(instance.parameters.sr_style);
    sr2 = instance:addStream("SR2", core.Line, "Support/Resistance 2", "Support/Resistance 2", instance.parameters.sr_color, 0, 0);
    sr2:setWidth(instance.parameters.sr_width);
    sr2:setStyle(instance.parameters.sr_style);
    sr3 = instance:addStream("SR3", core.Line, "Support/Resistance 3", "Support/Resistance 3", instance.parameters.sr_color, 0, 0);
    sr3:setWidth(instance.parameters.sr_width);
    sr3:setStyle(instance.parameters.sr_style);
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
    if ich1.KL[index1] == ich1.SB[index1 + TenkanSenPeriod] 
        and ich1.KL[index1] == ich1.KL[index1 - 1]
    then
        sr1[period] = ich1.SB[index1];
    end
    if ich2.KL[index2] == ich2.SB[index2 + TenkanSenPeriod]
        and ich2.KL[index2] == ich2.KL[index2 - 1]
    then
        sr2[period] = ich2.SB[index2];
    end
    if ich3.KL[index3] == ich3.SB[index3 + TenkanSenPeriod]
        and ich3.KL[index3] == ich3.KL[index3 - 1]
    then
        sr3[period] = ich3.SB[index3];
    end
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    sources:AsyncOperationFinished(cookie, successful, message, message1, message2);
end