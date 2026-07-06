

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67311

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine

function Init()
    indicator:name("Belkhayate Gravity");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 100)
    indicator.parameters:addInteger("Order", "Order", "Order", 3)
    indicator.parameters:addColor("color", "Line Color", "", core.colors().Lime);
    indicator.parameters:addColor("UpColor", "Up Color", "", core.colors().Lime);
    indicator.parameters:addColor("DownColor", "Down Color", "", core.colors().Red);
end

local GC1;
local Thick1;
local Thick2;
local Thick3;
local BiasStrength;
local UpColor
local DownColor;
local Period;
local Order;

local first;
local source = nil;
local BCG;
local indicators = {};

function Add(tf)
	local data = {};
	data.loadedId = (#indicators * 2) + 1;
	data.loadingId = (#indicators * 2) + 2;
	data.source = core.host:execute("getSyncHistory", source:instrument(), tf, source:isBid(), 0, data.loadedId, data.loadingId);
	data.indi = core.indicators:create("BCG", data.source, Period, Order, 0.618);
	data.loading = true;
	indicators[#indicators + 1] = data;
end

function Prepare(nameOnly)   
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 
    if (nameOnly) then
        return;
	end
	UpColor = instance.parameters.UpColor;
	DownColor = instance.parameters.DownColor;
	Period = instance.parameters.Period;
	Order = instance.parameters.Order;
	source = instance.source;
	BiasStrength = instance:addInternalStream(0, 0);
	GC1 = instance:addStream("GC1", core.Line, "GC1", "GC1", instance.parameters.color, 0);
	Thick1 = instance:addStream("Thick1", core.Dot, "Thick1", "Thick1", instance.parameters.color, 0);
	Thick1:setWidth(2);
	Thick2 = instance:addStream("Thick2", core.Dot, "Thick2", "Thick2", instance.parameters.color, 0);
	Thick2:setWidth(3);
	Thick3 = instance:addStream("Thick3", core.Dot, "Thick3", "Thick3", instance.parameters.color, 0);
	Thick3:setWidth(4);
	
	
	assert(core.indicators:findIndicator("BCG") ~= nil, "Please, download and install BCG.LUA indicator from http://fxcodebase.com/code/viewtopic.php?f=17&p=123721");

	BCG = core.indicators:create("BCG", source, Period, Order, 0.618);

	if source:barSize() == "m1" then
		Add("m5");
		Add("m15");
		Add("m30");
		Add("H1");
		Add("H4");
		Add("D1");
	elseif source:barSize() == "m5" then
		Add("m15");
		Add("m30");
		Add("H1");
		Add("H2");
		Add("H4");
		Add("D1");
	elseif source:barSize() == "m15" then
		Add("m30");
		Add("H1");
		Add("H2");
		Add("H4");
		Add("H12");
		Add("D1");
	elseif source:barSize() == "m30" then
		Add("H1");
		Add("H2");
		Add("H4");
		Add("H12");
		Add("D1");
		Add("W1");
	elseif source:barSize() == "H1" then
		Add("H2");
		Add("H4");
		Add("H12");
		Add("D1");
		Add("W1");
		Add("M1");
	else
		assert(false, "Unsupported timeframe");
	end
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
	local allLoaded = true;
	for _, data in ipairs(indicators) do
		if data.loadingId == cookie then
			data.loading = true;
		elseif data.loadedId == cookie then
			data.loading = false;
		end
		if data.loading then
			allLoaded = false;
		end
	end
	if allLoaded then
		instance:updateFrom(0);
	end
end

function Update(period, mode)
	if (period < 10 + Period) then
		return;
	end
	BCG:update(core.UpdateLast);
	for _, data in ipairs(indicators) do
		if data.loading then
			return;
		end
		data.indi:update(core.UpdateLast);
	end
	local p1 = BCG.GravityLine[period];
	if not BCG.GravityLine:hasData(period - 1) then
		return;
	end
	local p2 = BCG.GravityLine[period - 1];

	BiasStrength[period] = 0;
	GC1[period] = p1;
	if p1 > p2 then
		BiasStrength[period] = 1;
		BiasStrength:setColor(period, UpColor)
	elseif p1 < p2 then
		BiasStrength[period] = -1;
		BiasStrength:setColor(period, DownColor)
	end

	local above = 0;
	local below = 0;
	for _, data in ipairs(indicators) do
		if p1 > data.indi.DATA[NOW] then
			above = above + 1;
		elseif p1 < data.indi.DATA[NOW] then
			below = below + 1;
		end
	end
	if p1 > p2 and above > 0 then
		if below == 0 then
			Thick3[period] = p1;
			Thick3:setColor(period, UpColor);
			BiasStrength[period] = 4;
		end
		if above > below then
			Thick2[period] = p1;
			Thick2:setColor(period, UpColor);
			BiasStrength[period] = 3;
		else
			Thick1[period] = p1;
			Thick1:setColor(period, UpColor);
			BiasStrength[period] = 2;
		end
	elseif p1 < p2 and below > 0 then
		if above == 0 then
			Thick3[period] = p1;
			Thick3:setColor(period, DownColor);
			BiasStrength[period] = -4;
		end
		if below > above then
			Thick2[period] = p1;
			Thick2:setColor(period, DownColor);
			BiasStrength[period] = -3;
		else
			Thick1[period] = p1;
			Thick1:setColor(period, DownColor);
			BiasStrength[period] = -2;
		end
	end
end
