-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69697
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69697

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

function AddPrice(id, name)
    indicator.parameters:addString("Price" .. id, name .. " Price Source", "", "close")
    indicator.parameters:addStringAlternative("Price" .. id, "OPEN", "", "open")
    indicator.parameters:addStringAlternative("Price" .. id, "HIGH", "", "high")
    indicator.parameters:addStringAlternative("Price" .. id, "LOW", "", "low")
    indicator.parameters:addStringAlternative("Price" .. id, "CLOSE", "", "close")
    indicator.parameters:addStringAlternative("Price" .. id, "MEDIAN", "", "median")
    indicator.parameters:addStringAlternative("Price" .. id, "TYPICAL", "", "typical")
    indicator.parameters:addStringAlternative("Price" .. id, "WEIGHTED", "", "weighted")
end

function Init()
    indicator:name("Longer/Shorter Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    AddPrice("1", "Long");
    indicator.parameters:addDouble("Factor1", "Factor1", "", 1);
    indicator.parameters:addInteger("atr_period", "ATR 1 period", "", 14);
    indicator.parameters:addString("tf1", "Timeframe 1", "", "m5");
    indicator.parameters:setFlag("tf1", core.FLAG_PERIODS);
    AddPrice("2", "Short");
    indicator.parameters:addDouble("Factor2", "Factor2", "", 1);
    indicator.parameters:addInteger("atr_period_2", "ATR 2 period", "", 21);
    indicator.parameters:addString("tf2", "Timeframe 2", "", "m5");
    indicator.parameters:setFlag("tf2", core.FLAG_PERIODS);

    indicator.parameters:addColor("entry_buy_color", "Entry Buy Color", "Color", core.colors().Green);
    indicator.parameters:addInteger("entry_buy_width", "Entry Buy Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("entry_buy_style", "Entry Buy Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("entry_buy_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("exit_buy_color", "Exit Buy Color", "Color", core.colors().Green);
    indicator.parameters:addInteger("exit_buy_width", "Exit Buy Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("exit_buy_style", "Exit Buy Style", "Style", core.LINE_DASH);
    indicator.parameters:setFlag("exit_buy_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("entry_sell_color", "Entry Sell Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("entry_sell_width", "Entry Sell Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("entry_sell_style", "Entry Sell Style", "Style", core.LINE_SOLID);
    indicator.parameters:setFlag("entry_sell_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("exit_sell_color", "Exit Sell Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("exit_sell_width", "Exit Sell Width", "Width", 1, 1, 5);
    indicator.parameters:addInteger("exit_sell_style", "Exit Sell Style", "Style", core.LINE_DASH);
    indicator.parameters:setFlag("exit_sell_style", core.FLAG_LINE_STYLE);
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

local long_src, short_src;
local src1, src2;
local source;
local Factor2, Factor1, atr, atr2, TRAILINGUP, TRAILINGDOWN, LONGUP1, LONGDN1, entry_buy, exit_buy, SHORTUP1, SHORTDN1;
function Prepare(nameOnly)
    source = instance.source;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    long_src = source[instance.parameters.Price1];
    short_src = source[instance.parameters.Price2];
    src1 = sources:Request(1, source, instance.parameters.tf1);
    src2 = sources:Request(2, source, instance.parameters.tf2);
    Factor1 = instance.parameters.Factor1;
    Factor2 = instance.parameters.Factor2;
    atr = core.indicators:create("ATR", src1, instance.parameters.atr_period);
    atr2 = core.indicators:create("ATR", src2, instance.parameters.atr_period_2);
    TRAILINGUP = instance:addInternalStream(0, 0);
    TRAILINGDOWN = instance:addInternalStream(0, 0);
    LONGUP1 = instance:addInternalStream(0, 0);
    SHORTUP1 = instance:addInternalStream(0, 0);
    LONGDN1 = instance:addInternalStream(0, 0);
    SHORTDN1 = instance:addInternalStream(0, 0);
    entry_buy = instance:addStream("entry_buy", core.Line, "Entry Buy", "Entry Buy", instance.parameters.entry_buy_color, 0, 0);
    entry_buy:setWidth(instance.parameters.entry_buy_width);
    entry_buy:setStyle(instance.parameters.entry_buy_style);
    exit_buy = instance:addStream("exit_buy", core.Line, "Exit Buy", "Exit Buy", instance.parameters.exit_buy_color, 0, 0);
    exit_buy:setWidth(instance.parameters.exit_buy_width);
    exit_buy:setStyle(instance.parameters.exit_buy_style);
    entry_sell = instance:addStream("entry_sell", core.Line, "Entry sell", "Entry sell", instance.parameters.entry_sell_color, 0, 0);
    entry_sell:setWidth(instance.parameters.entry_sell_width);
    entry_sell:setStyle(instance.parameters.entry_sell_style);
    exit_sell = instance:addStream("exit_sell", core.Line, "Exit sell", "Exit sell", instance.parameters.exit_sell_color, 0, 0);
    exit_sell:setWidth(instance.parameters.exit_sell_width);
    exit_sell:setStyle(instance.parameters.exit_sell_style);
end

function Update(period, mode)
    if not sources:IsAllLoaded() then
        return;
    end
    atr:update(mode);
    local atr_period = core.findDate(src1, source:date(period), false);
    if atr_period < 0 or not atr.DATA:hasData(atr_period - 1) then
        return;
    end
    atr2:update(mode);
    local atr2_period = core.findDate(src2, source:date(period), false);
    if atr2_period < 0 or not atr2.DATA:hasData(atr2_period - 1) then
        return;
    end
	
    if source.close[period] > long_src[period] then
        local Up1 = source.close[period] - Factor1 * atr.DATA[atr_period];
        TRAILINGUP[period] = math.max(Up1, TRAILINGUP[period - 1]);
    else
        TRAILINGUP[period] = long_src[period];
    end

    local Up2 = source.close[period - 1] - (Factor2 * atr2.DATA[atr2_period - 1]);
    local LONGUPX = math.max(TRAILINGUP[period], long_src[period]);
    LONGUP = math.min(LONGUPX, Up2);
    if source.close[period] > LONGUP1[period - 1] then
        LONGUP1[period] = math.max(LONGUP, LONGUP1[period - 1])
    else
        LONGUP1[period] = LONGUP;
    end
    LONGDNX = math.max(TRAILINGUP[period], long_src[period]);
    local Dn2 = source.close[period - 1] + (Factor2 * atr2.DATA[atr2_period - 1]);
    local LONGDN = math.max(LONGDNX, Dn2);
    if source.close[period] < LONGDN1[period - 1] then
        LONGDN1[period] = math.min(LONGDN, LONGDN1[period - 1]);
    else
        LONGDN1[period] = LONGDN;
    end
    if source.close[period] < LONGDN1[period] then
        entry_buy[period] = math.min(LONGDN, LONGDN1[period - 1]);
    else
        entry_buy[period] = LONGDN;
    end
    if source.close[period] > LONGUP1[period] then
        exit_buy[period] = math.max(LONGUP, LONGUP1[period - 1]);
    else
        exit_buy[period] = LONGUP;
    end

    if source.close[period] < short_src[period] then
        local Dn1 = source.close[period] + Factor1 * atr.DATA[atr_period];
        TRAILINGDOWN[period] = math.max(Dn1, TRAILINGDOWN[period - 1]);
    else
        TRAILINGDOWN[period] = short_src[period];
    end
    SHORTUPX = math.min(TRAILINGDOWN[period], short_src[period]);
    SHORTUP = math.min(SHORTUPX, Up2);
    if source.close[period] > SHORTUP1[period - 1] then
        SHORTUP1[period] = math.max(SHORTUP, SHORTUP1[period - 1]);
    else
        SHORTUP1[period] = SHORTUP;
    end
    SHORTDNX = math.min(TRAILINGDOWN[period], short_src[period]);
    SHORTDN = math.max(SHORTDNX, Dn2);
    if source.close[period] < SHORTDN1[period - 1] then
        SHORTDN1[period] = math.min(SHORTDN, SHORTDN1[period - 1]);
    else
        SHORTDN1[period] = SHORTDN;
    end

    if source.close[period] > SHORTUP1[period] then
        entry_sell[period] = math.max(SHORTUP, SHORTUP1[period - 1]);
    else
        entry_sell[period] = SHORTUP;
    end
    if source.close[period] < SHORTDN1[period] then
        exit_sell[period] = math.min(SHORTDN, SHORTDN1[period - 1]);
    else
        exit_sell[period] = SHORTDN;
    end
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    if sources:AsyncOperationFinished(cookie, successful, message, message1, message2) then
        instance:updateFrom(0);
    end
end