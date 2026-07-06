-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=70011

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
    indicator:name("OHLC Ranges");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addBoolean("show1", "Show First Time Range", "", true);
    indicator.parameters:addColor("ocCol1", "Open/Close Color", "", core.colors().Red);
    indicator.parameters:addString("res1", "First Time Range", "", "m5");
    indicator.parameters:setFlag("res1", core.FLAG_PERIODS);
    
    indicator.parameters:addBoolean("show2", "Show Second Time Range", "", false);
    indicator.parameters:addColor("ocCol2", "Open/Close Color", "", core.colors().Blue);
    indicator.parameters:addString("res2", "Second Time Range", "", "m5");
    indicator.parameters:setFlag("res2", core.FLAG_PERIODS);
    indicator.parameters:addInteger("transparency", "Transparency", "", 20, 0, 100);
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
local show1, show2;
local source, src1, src2, o1, h1, l1, c1, o2, h2, l2, c2, ocCol1, ocCol2, transparency;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
	
	show1, show2=instance.parameters.show1,instance.parameters.show2;
	
    ocCol1 = instance.parameters.ocCol1;
    ocCol2 = instance.parameters.ocCol2;
    transparency = instance.parameters.transparency;
    src1 = sources:Request(1, source, instance.parameters.res1);
    src2 = sources:Request(2, source, instance.parameters.res2);
    o1 = instance:addInternalStream(0, 0);
    h1 = instance:addInternalStream(0, 0);
    l1 = instance:addInternalStream(0, 0);
    c1 = instance:addInternalStream(0, 0);
	if show1 then
    instance:createChannelGroup("HL1", "HL1", h1, l1, ocCol1, transparency, true)
    instance:createChannelGroup("OC1", "OC1", o1, c1, ocCol1, transparency, true)
	end
    o2 = instance:addInternalStream(0, 0);
    h2 = instance:addInternalStream(0, 0);
    l2 = instance:addInternalStream(0, 0);
    c2 = instance:addInternalStream(0, 0);
	if show2 then
    instance:createChannelGroup("HL2", "HL2", h2, l2, ocCol2, transparency, true)
    instance:createChannelGroup("OC2", "OC2", o2, c2, ocCol2, transparency, true)
	end
end

function Update(period, mode)
    if not sources:IsAllLoaded() then
        return;
    end
    local index1 = core.findDate(src1, source:date(period), false);
    if index1 >= 0 then
        o1[period] = src1.open[index1];
        h1[period] = src1.high[index1];
        l1[period] = src1.low[index1];
        c1[period] = src1.close[index1];
    end
    local index2 = core.findDate(src2, source:date(period), false);
    if index2 >= 0 then
        o2[period] = src2.open[index2];
        h2[period] = src2.high[index2];
        l2[period] = src2.low[index2];
        c2[period] = src2.close[index2];
    end
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    if sources:AsyncOperationFinished(cookie, successful, message, message1, message2) then
        instance:updateFrom(0);
    end
end

