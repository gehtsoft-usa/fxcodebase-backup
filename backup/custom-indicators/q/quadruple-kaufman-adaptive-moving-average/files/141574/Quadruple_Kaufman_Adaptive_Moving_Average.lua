-- More information about this indicator can be found at:
--https://fxcodebase.com/code/viewtopic.php?f=17&t=71104

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   Dogecoin : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("Quadruple Kaufman Adaptive Moving Average");
    indicator:description("Quadruple Kaufman Adaptive Moving Average");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addInteger("length1", "length1", "", 14);
    indicator.parameters:addInteger("fastMA1", "fastMA1", "", 2);
    indicator.parameters:addInteger("slowMA1", "slowMA1", "", 20);
    indicator.parameters:addString("src1", "Source 1", "", "close");
    indicator.parameters:addStringAlternative("src1", "Open", "", "open");
    indicator.parameters:addStringAlternative("src1", "High", "", "high");
    indicator.parameters:addStringAlternative("src1", "Low", "", "low");
    indicator.parameters:addStringAlternative("src1", "Close", "", "close");
    indicator.parameters:addStringAlternative("src1", "Median", "", "median");
    indicator.parameters:addStringAlternative("src1", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("src1", "Weighted", "", "weighted");
    indicator.parameters:addString("tf1", "Resolution 1", "", "H1");
    indicator.parameters:setFlag("tf1", core.FLAG_BARPERIODS);
    indicator.parameters:addInteger("length2", "length2", "", 14);
    indicator.parameters:addInteger("fastMA2", "fastMA2", "", 3);
    indicator.parameters:addInteger("slowMA2", "slowMA2", "", 30);
    indicator.parameters:addString("tf2", "Resolution 2", "", "H1");
    indicator.parameters:setFlag("tf2", core.FLAG_BARPERIODS);
    indicator.parameters:addString("src2", "Source 2", "", "close");
    indicator.parameters:addStringAlternative("src2", "Open", "", "open");
    indicator.parameters:addStringAlternative("src2", "High", "", "high");
    indicator.parameters:addStringAlternative("src2", "Low", "", "low");
    indicator.parameters:addStringAlternative("src2", "Close", "", "close");
    indicator.parameters:addStringAlternative("src2", "Median", "", "median");
    indicator.parameters:addStringAlternative("src2", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("src2", "Weighted", "", "weighted");
    indicator.parameters:addInteger("length3", "length3", "", 14);
    indicator.parameters:addInteger("fastMA3", "fastMA3", "", 4);
    indicator.parameters:addInteger("slowMA3", "slowMA3", "", 40);
    indicator.parameters:addString("src3", "Source 3", "", "close");
    indicator.parameters:addStringAlternative("src3", "Open", "", "open");
    indicator.parameters:addStringAlternative("src3", "High", "", "high");
    indicator.parameters:addStringAlternative("src3", "Low", "", "low");
    indicator.parameters:addStringAlternative("src3", "Close", "", "close");
    indicator.parameters:addStringAlternative("src3", "Median", "", "median");
    indicator.parameters:addStringAlternative("src3", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("src3", "Weighted", "", "weighted");
    indicator.parameters:addString("tf3", "Resolution 3", "", "H1");
    indicator.parameters:setFlag("tf3", core.FLAG_BARPERIODS);
    indicator.parameters:addInteger("length4", "length4", "", 14);
    indicator.parameters:addInteger("fastMA4", "fastMA4", "", 5);
    indicator.parameters:addInteger("slowMA4", "slowMA4", "", 50);
    indicator.parameters:addString("src4", "Source 4", "", "close");
    indicator.parameters:addStringAlternative("src4", "Open", "", "open");
    indicator.parameters:addStringAlternative("src4", "High", "", "high");
    indicator.parameters:addStringAlternative("src4", "Low", "", "low");
    indicator.parameters:addStringAlternative("src4", "Close", "", "close");
    indicator.parameters:addStringAlternative("src4", "Median", "", "median");
    indicator.parameters:addStringAlternative("src4", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("src4", "Weighted", "", "weighted");
    indicator.parameters:addString("tf4", "Resolution 4", "", "H1");
    indicator.parameters:setFlag("tf4", core.FLAG_BARPERIODS);
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
local params = {};
local plot1, plot2, plot3, plot4;
local src1, src2, src3, src4, kama1, kama2, kama3, kama4, indi1, indi2, indi3, indi4;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    params["length1"] = instance.parameters.length1;
    params["fastMA1"] = instance.parameters.fastMA1;
    params["slowMA1"] = instance.parameters.slowMA1;
    params["src1"] = instance.parameters.src1;
    params["tf1"] = instance.parameters.tf1;
    params["length2"] = instance.parameters.length2;
    params["fastMA2"] = instance.parameters.fastMA2;
    params["slowMA2"] = instance.parameters.slowMA2;
    params["tf2"] = instance.parameters.tf2;
    params["src2"] = instance.parameters.src2;
    params["length3"] = instance.parameters.length3;
    params["fastMA3"] = instance.parameters.fastMA3;
    params["slowMA3"] = instance.parameters.slowMA3;
    params["src3"] = instance.parameters.src3;
    params["tf3"] = instance.parameters.tf3;
    params["length4"] = instance.parameters.length4;
    params["fastMA4"] = instance.parameters.fastMA4;
    params["slowMA4"] = instance.parameters.slowMA4;
    params["src4"] = instance.parameters.src4;
    params["tf4"] = instance.parameters.tf4;
    plot1 = instance:addStream("plot1", core.Line, "KAMA1", "KAMA1", core.colors().Yellow, 0, 0);
    plot1:setWidth(1);
    plot1:setStyle(core.LINE_SOLID);
    plot2 = instance:addStream("plot2", core.Line, "KAMA2", "KAMA2", core.colors().Blue, 0, 0);
    plot2:setWidth(1);
    plot2:setStyle(core.LINE_SOLID);
    plot3 = instance:addStream("plot3", core.Line, "KAMA3", "KAMA3", core.colors().Fuchsia, 0, 0);
    plot3:setWidth(1);
    plot3:setStyle(core.LINE_SOLID);
    plot4 = instance:addStream("plot4", core.Line, "KAMA4", "KAMA4", core.colors().Red, 0, 0);
    plot4:setWidth(1);
    plot4:setStyle(core.LINE_SOLID);
    
    local profile = core.indicators:findIndicator("KAMAEX");
    assert(profile ~= nil, "Please, download and install " .. "KAMAEX" .. ".LUA indicator");
    local src1 = sources:Request(1, source, params["tf1"]);
    indi1 = core.indicators:create("KAMAEX", src1, params["length1"], params["fastMA1"], params["slowMA1"], params["src1"])
    local src2 = sources:Request(1, source, params["tf2"]);
    indi2 = core.indicators:create("KAMAEX", src2, params["length2"], params["fastMA2"], params["slowMA2"], params["src2"])
    local src3 = sources:Request(1, source, params["tf3"]);
    indi3 = core.indicators:create("KAMAEX", src3, params["length3"], params["fastMA3"], params["slowMA3"], params["src3"])
    local src4 = sources:Request(1, source, params["tf4"]);
    indi4 = core.indicators:create("KAMAEX", src4, params["length4"], params["fastMA4"], params["slowMA4"], params["src4"])
end

function GetValue(indi, date)
    local index = core.findDate(indi.DATA, date, false);
    if (index < 0) then
        return nil;
    end
    return indi.DATA[index];
end

function Update(period, mode)
    if not sources:IsAllLoaded() then
        return;
    end
    indi1:update(mode);
    indi2:update(mode);
    indi3:update(mode);
    indi4:update(mode);
    plot1[period] = GetValue(indi1, source:date(period));
    plot2[period] = GetValue(indi2, source:date(period));
    plot3[period] = GetValue(indi3, source:date(period));
    plot4[period] = GetValue(indi4, source:date(period));
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    if sources:AsyncOperationFinished(cookie, successful, message, message1, message2) then
        instance:updateFrom(0);
    end
end