-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=71428

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

MO1 = "Relative Strength Index";
MO2 = "True Strength Index";
MO3 = "Rate Of Change";
MO4 = "Absolute Strength Index";
MO5 = "Regression Slope";
MO6 = "Z-Score";
MO7 = "Mataf";
DS1 = "Lines";
DS2 = "Columns";
DS3 = "Area";

function Init()
    indicator:name("FX Currency Strength Indicator");
    indicator:description("FX Currency Strength Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("General Settings")
    indicator.parameters:addString("mode", "Calculation", "", MO1);
    indicator.parameters:addStringAlternative("mode", MO1, "", MO1);
    indicator.parameters:addStringAlternative("mode", MO2, "", MO2);
    indicator.parameters:addStringAlternative("mode", MO3, "", MO3);
    indicator.parameters:addStringAlternative("mode", MO4, "", MO4);
    indicator.parameters:addStringAlternative("mode", MO5, "", MO5);
    indicator.parameters:addStringAlternative("mode", MO6, "", MO6);
    indicator.parameters:addStringAlternative("mode", MO7, "", MO7);
    indicator.parameters:addString("display", "Display", "", DS1);
    indicator.parameters:addStringAlternative("display", DS1, "", DS1);
    indicator.parameters:addStringAlternative("display", DS2, "", DS2);
    indicator.parameters:addStringAlternative("display", DS3, "", DS3);
    indicator.parameters:addString("src", "Source", "", "close");
    indicator.parameters:addStringAlternative("src", "Open", "", "open");
    indicator.parameters:addStringAlternative("src", "High", "", "high");
    indicator.parameters:addStringAlternative("src", "Low", "", "low");
    indicator.parameters:addStringAlternative("src", "Close", "", "close");
    indicator.parameters:addStringAlternative("src", "Median", "", "median");
    indicator.parameters:addStringAlternative("src", "Typical", "", "typical");
    indicator.parameters:addStringAlternative("src", "Weighted", "", "weighted");
    indicator.parameters:addBoolean("ShowLabels", "Show Labels", "", true);
    indicator.parameters:addBoolean("ShowEUR", "Show EUR", "", true);
    indicator.parameters:addBoolean("ShowGBP", "Show GBP", "", true);
    indicator.parameters:addBoolean("ShowAUD", "Show AUD", "", true);
    indicator.parameters:addBoolean("ShowNZD", "Show NZD", "", true);
    indicator.parameters:addBoolean("ShowUSD", "Show USD", "", true);
    indicator.parameters:addBoolean("ShowCAD", "Show CAD", "", true);
    indicator.parameters:addBoolean("ShowCHF", "Show CHF", "", true);
    indicator.parameters:addBoolean("ShowJPY", "Show JPY", "", true);
    indicator.parameters:addGroup("Regression Slope")
    indicator.parameters:addInteger("linregLen", "Linear Regression Period", "", 5);
    indicator.parameters:addInteger("slopeLen", "Slope", "", 1);
    indicator.parameters:addGroup("True Strength Index");
    indicator.parameters:addInteger("fastlen", "TSI Fast Length", "", 5);
    indicator.parameters:addInteger("slowlen", "TSI Slow Length", "", 10);
    indicator.parameters:addGroup("Relative Strength Index");
    indicator.parameters:addInteger("rsiLen", "RSI Length", "", 5);
    indicator.parameters:addGroup("Rate Of Change Index");
    indicator.parameters:addInteger("rocLen", "Rate of Change Period", "", 1);
    indicator.parameters:addGroup("Absolute Strength Index");
    indicator.parameters:addInteger("ASIlen", "Absolute Strength Length", "", 10);
    indicator.parameters:addGroup("Z-Score");
    indicator.parameters:addInteger("zsLen", "Z-Score Length", "", 10);
end

-- Sources v1.3
local sources = {}
sources.last_id = 1
sources.loaded_count = 0;
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
            if not ids.loaded then
                self.loaded_count = self.loaded_count + 1;
            end
			ids.loaded = true
			self.allLoaded = nil
			return true
		elseif ids.loading_id == cookie then
            if ids.loaded then
                self.loaded_count = self.loaded_count - 1;
            end
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

local eur = {};
local gbp = {};
local aud = {};
local nzd = {};
local usd = {};
local cad = {};
local chf = {};
local jpy = {};
local source;
local params = {};

local last_id = 1;
function AddController(controllers, curr1, curr2, div, invert, mode)
    local symbol = curr1 .. "/" .. curr2;
    if core.host:findTable("offers"):find("Instrument", symbol) == nil then
        return;
    end
    local controller = {};
    controller.source = sources:Request(last_id, source, source:barSize(), nil, symbol);
    last_id = last_id + 1;
    controller.div = div;
    controller.stream = instance:addInternalStream(0, 0);
    controller.invert = invert;
    controller.mode = mode;
    if mode == MO1 then
        controller.indi = core.indicators:create("RSI", controller.stream, params["rsiLen"]);
    elseif mode == MO2 then
        controller.indi = core.indicators:create("TSI", controller.stream, params["fastlen"], params["slowlen"]);
    elseif mode == MO3 then
        controller.indi = core.indicators:create("ROC", controller.stream, params["rocLen"]);
    end
    function controller:Calc(period, m)
        local index = core.findDate(self.source, source:date(period), false);
        if index < 0 then
            return 0;
        end
        self.stream[period] = self.source[index] / self.div;
        if self.inv then
            self.stream[period] = 1 / self.stream[period];
        end
        if self.mode == MO1 or self.mode == MO2 or self.mode == MO3 then
            self.indi:update(m);
            return self.indi.DATA[period];
        elseif self.mode == MO4 then
            local src = self.stream[period];
            local src_1 = self.stream[period + 1];
            self.A[period] = src > src_1 and self.A[period - 1] + (src / src_1) - 1 or self.A[period - 1];
            self.M[period] = src == src_1 and self.M[period - 1] + 1.0 / params["ASIlen"] or self.M[period - 1];
            self.D[period] = src < src_1 and self.D[period - 1] + (src_1 / src) - 1 or self.D[period - 1];
            return self.D[period] + self.M[period] / 2 == 0 and 100 or 100 - 100 / (1 + (self.A[period] + self.M[period] / 2) / (self.D[period] + self.M[period] / 2));
        elseif self.mode == MO5 then
            linreg = mathex.lreg(self.stream, core.rangeTo(period, params["linregLen"]))
            return (linreg -  mathex.lreg(self.stream, core.rangeTo(period - params["slopeLen"], params["linregLen"]))) / params["slopeLen"]
        elseif self.mode == MO6 then
            return (self.stream[period] - mathex.avg(self.stream, core.rangeTo(period, params["zsLen"])))
                / mathex.stdev(self.stream, core.rangeTo(period, params["zsLen"]));
        end
        if period == 0 then
            self._close[period] = self.stream[period]
        else
            self._close[period] = self._close[period - 1]
        end

        return 100 - (self._close[period] - self.close[period]) / self._close[period] * 100
    end
    controllers[#controllers + 1] = controller;
end

local plot1, plot2, plot3, plot4, plot5, plot6, plot7, plot8;
local streams = {};
local indicators = {};
local vars = {};
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return;
    end
    params["dummy_1"] = instance.parameters.dummy_1;
    params["mode"] = instance.parameters.mode;
    params["display"] = instance.parameters.display;
    params["src"] = instance.parameters.src;
    params["ShowLabels"] = instance.parameters.ShowLabels;
    params["ShowEUR"] = instance.parameters.ShowEUR;
    params["ShowGBP"] = instance.parameters.ShowGBP;
    params["ShowAUD"] = instance.parameters.ShowAUD;
    params["ShowNZD"] = instance.parameters.ShowNZD;
    params["ShowUSD"] = instance.parameters.ShowUSD;
    params["ShowCAD"] = instance.parameters.ShowCAD;
    params["ShowCHF"] = instance.parameters.ShowCHF;
    params["ShowJPY"] = instance.parameters.ShowJPY;
    params["dummy_2"] = instance.parameters.dummy_2;
    params["linregLen"] = instance.parameters.linregLen;
    params["slopeLen"] = instance.parameters.slopeLen;
    params["dummy_3"] = instance.parameters.dummy_3;
    params["fastlen"] = instance.parameters.fastlen;
    params["slowlen"] = instance.parameters.slowlen;
    params["dummy_4"] = instance.parameters.dummy_4;
    params["rsiLen"] = instance.parameters.rsiLen;
    params["dummy_5"] = instance.parameters.dummy_5;
    params["rocLen"] = instance.parameters.rocLen;
    params["dummy_6"] = instance.parameters.dummy_6;
    params["ASIlen"] = instance.parameters.ASIlen;
    params["dummy_7"] = instance.parameters.dummy_7;
    params["zsLen"] = instance.parameters.zsLen;
    plot1 = instance:addStream("plot1", core.Line, "EUR", "EUR", core.colors().Lime, 0, 0);
    plot1:setWidth(1);
    plot1:setStyle(core.LINE_SOLID);
    plot2 = instance:addStream("plot2", core.Line, "GBP", "GBP", core.colors().Olive, 0, 0);
    plot2:setWidth(1);
    plot2:setStyle(core.LINE_SOLID);
    plot3 = instance:addStream("plot3", core.Line, "AUD", "AUD", core.colors().Red, 0, 0);
    plot3:setWidth(1);
    plot3:setStyle(core.LINE_SOLID);
    plot4 = instance:addStream("plot4", core.Line, "NZD", "NZD", core.colors().Orange, 0, 0);
    plot4:setWidth(1);
    plot4:setStyle(core.LINE_SOLID);
    plot5 = instance:addStream("plot5", core.Line, "USD", "USD", core.colors().Blue, 0, 0);
    plot5:setWidth(1);
    plot5:setStyle(core.LINE_SOLID);
    plot6 = instance:addStream("plot6", core.Line, "CAD", "CAD", core.colors().Teal, 0, 0);
    plot6:setWidth(1);
    plot6:setStyle(core.LINE_SOLID);
    plot7 = instance:addStream("plot7", core.Line, "CHF", "CHF", core.colors().Fuchsia, 0, 0);
    plot7:setWidth(1);
    plot7:setStyle(core.LINE_SOLID);
    plot8 = instance:addStream("plot8", core.Line, "JPY", "JPY", core.colors().Maroon, 0, 0);
    plot8:setWidth(1);
    plot8:setStyle(core.LINE_SOLID);

    AddController(eur, "EUR", "GBP", 1, false, params["mode"]);
    AddController(eur, "EUR", "AUD", 1, false, params["mode"]);
    AddController(eur, "EUR", "NZD", 1, false, params["mode"]);
    AddController(eur, "EUR", "USD", 1, false, params["mode"]);
    AddController(eur, "EUR", "CAD", 1, false, params["mode"]);
    AddController(eur, "EUR", "CHF", 1, false, params["mode"]);
    AddController(eur, "EUR", "JPY", 100, false, params["mode"]);

    AddController(gbp, "GBP", "EUR", 1, true, params["mode"]);
    AddController(gbp, "GBP", "AUD", 1, false, params["mode"]);
    AddController(gbp, "GBP", "NZD", 1, false, params["mode"]);
    AddController(gbp, "GBP", "USD", 1, false, params["mode"]);
    AddController(gbp, "GBP", "CAD", 1, false, params["mode"]);
    AddController(gbp, "GBP", "CHF", 1, false, params["mode"]);
    AddController(gbp, "GBP", "JPY", 100, false, params["mode"]);

    AddController(aud, "AUD", "EUR", 1, true, params["mode"]);
    AddController(aud, "AUD", "GBP", 1, true, params["mode"]);
    AddController(aud, "AUD", "NZD", 1, false, params["mode"]);
    AddController(aud, "AUD", "USD", 1, false, params["mode"]);
    AddController(aud, "AUD", "CAD", 1, false, params["mode"]);
    AddController(aud, "AUD", "CHF", 1, false, params["mode"]);
    AddController(aud, "AUD", "JPY", 100, false, params["mode"]);

    AddController(nzd, "NZD", "EUR", 1, true, params["mode"]);
    AddController(nzd, "NZD", "GBP", 1, true, params["mode"]);
    AddController(nzd, "NZD", "AUD", 1, true, params["mode"]);
    AddController(nzd, "NZD", "USD", 1, false, params["mode"]);
    AddController(nzd, "NZD", "CAD", 1, false, params["mode"]);
    AddController(nzd, "NZD", "CHF", 1, false, params["mode"]);
    AddController(nzd, "NZD", "JPY", 100, false, params["mode"]);

    AddController(usd, "USD", "EUR", 1, true, params["mode"]);
    AddController(usd, "USD", "GBP", 1, true, params["mode"]);
    AddController(usd, "USD", "AUD", 1, true, params["mode"]);
    AddController(usd, "USD", "NZD", 1, true, params["mode"]);
    AddController(usd, "USD", "CAD", 1, false, params["mode"]);
    AddController(usd, "USD", "CHF", 1, false, params["mode"]);
    AddController(usd, "USD", "JPY", 100, false, params["mode"]);

    AddController(cad, "CAD", "EUR", 1, true, params["mode"]);
    AddController(cad, "CAD", "GBP", 1, true, params["mode"]);
    AddController(cad, "CAD", "AUD", 1, true, params["mode"]);
    AddController(cad, "CAD", "NZD", 1, true, params["mode"]);
    AddController(cad, "CAD", "USD", 1, true, params["mode"]);
    AddController(cad, "CAD", "CHF", 1, false, params["mode"]);
    AddController(cad, "CAD", "JPY", 100, false, params["mode"]);

    AddController(chf, "CHF", "EUR", 1, true, params["mode"]);
    AddController(chf, "CHF", "GBP", 1, true, params["mode"]);
    AddController(chf, "CHF", "AUD", 1, true, params["mode"]);
    AddController(chf, "CHF", "NZD", 1, true, params["mode"]);
    AddController(chf, "CHF", "USD", 1, true, params["mode"]);
    AddController(chf, "CHF", "CAD", 1, true, params["mode"]);
    AddController(chf, "CHF", "JPY", 100, false, params["mode"]);

    AddController(jpy, "JPY", "EUR", 1 / 100, true, params["mode"]);
    AddController(jpy, "JPY", "GBP", 1 / 100, true, params["mode"]);
    AddController(jpy, "JPY", "AUD", 1 / 100, true, params["mode"]);
    AddController(jpy, "JPY", "NZD", 1 / 100, true, params["mode"]);
    AddController(jpy, "JPY", "USD", 1 / 100, true, params["mode"]);
    AddController(jpy, "JPY", "CAD", 1 / 100, true, params["mode"]);
    AddController(jpy, "JPY", "CHF", 1 / 100, true, params["mode"]);
    core.host:execute("setStatus", "Loading...");
end

function sum(items, period, mode)
    total = 0;
    count = 0;
    for i, item in ipairs(items) do
        total = item:Calc(period, mode)
        count = count + 1;
    end
    if count == 0 then
        return 0;
    end
    return total / count;
end

function Update(period, mode)
    if not sources:IsAllLoaded() then
        return;
    end
    plot1[period] = (params["ShowEUR"] and sum(eur, period, mode) or nil);
    plot2[period] = (params["ShowGBP"] and sum(gbp, period, mode) or nil);
    plot3[period] = (params["ShowAUD"] and sum(aud, period, mode) or nil);
    plot4[period] = (params["ShowNZD"] and sum(nzd, period, mode) or nil);
    plot5[period] = (params["ShowUSD"] and sum(usd, period, mode) or nil);
    plot6[period] = (params["ShowCAD"] and sum(cad, period, mode) or nil);
    plot7[period] = (params["ShowCHF"] and sum(chf, period, mode) or nil);
    plot8[period] = (params["ShowJPY"] and sum(jpy, period, mode) or nil);
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    if sources:AsyncOperationFinished(cookie, successful, message, message1, message2) then
        instance:updateFrom(0);
    else
        core.host:execute("setStatus", "Loaded: " .. sources.loaded_count);
    end
end
