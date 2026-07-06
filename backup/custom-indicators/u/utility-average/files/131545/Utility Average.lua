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
    indicator:name("Utility Average");
    indicator:description("S&C 1997-03");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addString("instrument", "Against Symbol", "", "EUR/USD");
    indicator.parameters:setFlag("instrument", core.FLAG_INSTRUMENTS);

    indicator.parameters:addInteger("up_lag", "Up Lag", "", 65);
    indicator.parameters:addInteger("dn_lag", "Down Lag", "", 100);

    indicator.parameters:addColor("UtDrB_color", "UtDrB Color", "Color", core.colors().Green);
    indicator.parameters:addInteger("UtDrB_width", "UtDrB Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("UtDrB_style", "UtDrB Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("UtDrB_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("UtRsB_color", "UtRsB Color", "Color", core.colors().Lime);
    indicator.parameters:addInteger("UtRsB_width", "UtRsB Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("UtRsB_style", "UtRsB Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("UtRsB_style", core.FLAG_LINE_STYLE);

    indicator.parameters:addColor("UtDrS_color", "UtDrS Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("UtDrS_width", "UtDrS Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("UtDrS_style", "UtDrS Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("UtDrS_style", core.FLAG_LINE_STYLE);
    
    indicator.parameters:addColor("UtRsS_color", "UtRsS Color", "Color", core.colors().Pink);
    indicator.parameters:addInteger("UtRsS_width", "UtRsS Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("UtRsS_style", "UtRsS Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("UtRsS_style", core.FLAG_LINE_STYLE);
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

local source, source2, up_lag, dn_lag;
local XCon = 0.5;
local Util, UtSPR, UtSpRAvg, UtAvg, UtDrB, UtRsB, UtDrS, UtRsS;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    up_lag = instance.parameters.up_lag;
    dn_lag = instance.parameters.dn_lag;

    source2 = sources:Request(1, source, nil, nil, instance.parameters.instrument);

    Util = instance:addInternalStream(0, 0);
    UtSPR = instance:addInternalStream(0, 0);
    UtSpRAvg = instance:addInternalStream(0, 0);
    UtAvg = instance:addInternalStream(0, 0);

    UtDrB = instance:addStream("UtDrB", core.Line, "UtDrB", "UtDrB", instance.parameters.UtDrB_color, 0, 0);
    UtDrB:setWidth(instance.parameters.UtDrB_width);
    UtDrB:setStyle(instance.parameters.UtDrB_style);

    UtRsB = instance:addStream("UtRsB", core.Line, "UtRsB", "UtRsB", instance.parameters.UtRsB_color, 0, 0);
    UtRsB:setWidth(instance.parameters.UtRsB_width);
    UtRsB:setStyle(instance.parameters.UtRsB_style);

    UtDrS = instance:addStream("UtDrS", core.Line, "UtDrS", "UtDrS", instance.parameters.UtDrS_color, 0, 0);
    UtDrS:setWidth(instance.parameters.UtDrS_width);
    UtDrS:setStyle(instance.parameters.UtDrS_style);
    
    UtRsS = instance:addStream("UtRsS", core.Line, "UtRsS", "UtRsS", instance.parameters.UtRsS_color, 0, 0);
    UtRsS:setWidth(instance.parameters.UtRsS_width);
    UtRsS:setStyle(instance.parameters.UtRsS_style);
end

function Update(period, mode)
    if not sources:IsAllLoaded() then
        return;
    end
    local period_2 = core.findDate(source2, source:date(period), false);
    if period_2 < 0 then
        return;
    end
    Util[period] = math.log(source2[period_2]) * 100;
    UtSPR[period] = math.log(source2[period_2] / source[period]) * 100;
    if period == 0 then
        UtSpRAvg[period] = UtSPR[period];
        UtAvg[period] = Util[period];
    else
        UtSpRAvg[period] = UtSpRAvg[period - 1] + (XCon * (UtSPR[period] - UtSpRAvg[period - 1]));
        UtAvg[period] = UtAvg[period - 1] + (XCon * (Util[period] - UtAvg[period - 1])); 
    end
    if period >= up_lag then
        UtDrB[period] = UtAvg[period] - UtAvg[period - up_lag]; 
        UtRsB[period] = (UtSpRAvg[period] - UtSpRAvg[period - up_lag]); 
    end
    if period >= dn_lag then
        UtDrS[period] = UtAvg[period] - UtAvg[period - dn_lag]; 
        UtRsS[period] = (UtSpRAvg[period] - UtSpRAvg[period - dn_lag]);
    end
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    if sources:AsyncOperationFinished(cookie, successful, message, message1, message2) then
        instance:updateFrom(0);
    end
end
