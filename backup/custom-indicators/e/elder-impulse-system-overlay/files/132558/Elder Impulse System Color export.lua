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
	indicator:name("Elder Impulse System Color Export")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("MACD Calculation")
	indicator.parameters:addInteger("SN", "Short EMA", "", 12, 2, 1000)
	indicator.parameters:addInteger("LN", "Long EMA", "", 26, 2, 1000)
	indicator.parameters:addInteger("IN", "Signal Line", "", 9, 2, 1000)

	indicator.parameters:addGroup("EMA Calculation")
	indicator.parameters:addInteger("MA_Period", "EMA Period", "", 13, 2, 1000)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0))
	indicator.parameters:addColor("Down", "Down color", "", core.rgb(255, 0, 0))
	indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 255))

	indicator.parameters:addInteger("shift", "Shift", "", 0);
	indicator.parameters:addString("dde_service", "Service Name", "The service name must be unique amoung all running instances of the strategy", "indicatorColor");
	indicator.parameters:addString("dde_topic", "DDE Topic", "", "indi");
end

local Up, Down, Neutral
local first
local source = nil
local shift;

local open = nil
local close = nil
local high = nil
local low = nil

local SN, LN, IN = nil
local MA_Period
local MACD
local MA
local dde_server, dde_topic, dde_alerts;

function Prepare(nameOnly)
	Up = instance.parameters.Up
	Down = instance.parameters.Down
	Neutral = instance.parameters.Neutral

	IN = instance.parameters.IN
	SN = instance.parameters.SN
	LN = instance.parameters.LN
	MA_Period = instance.parametersMA_Period

	if (LN <= SN) then
		error("The short EMA period must be smaller than long EMA period")
	end

	source = instance.source

	local name = profile:id() .. "(" .. source:name() .. ", " .. source:barSize() .. ")"
	instance:name(name)
	if nameOnly then
		return
	end
	require("ddeserver_lua");
	dde_server = ddeserver_lua.new(instance.parameters.dde_service);
	dde_topic = dde_server:addTopic(instance.parameters.dde_topic);
	dde_alerts = dde_server:addValue(dde_topic, "color");
	shift = instance.parameters.shift;
	MACD = core.indicators:create("MACD", source.close, SN, LN, IN)
	MA = core.indicators:create("EMA", source.close, MA_Period)

	first = math.max(MA.DATA:first(), MACD.DATA:first())

	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first)
	high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first)
	low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first)
	close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first)
	instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close)
end

function ReleaseInstance()
	dde_server:close();
end

function Update(period, mode)
	open[period] = source.open[period]
	close[period] = source.close[period]
	high[period] = source.high[period]
	low[period] = source.low[period]

	if period < first then
		open:setColor(period, Neutral)
		return
	end

	MACD:update(mode)
	MA:update(mode)

	if MACD.HISTOGRAM[period] > MACD.HISTOGRAM[period - 1] and MA.DATA[period] > MA.DATA[period - 1] then
		open:setColor(period, Up)
	elseif MACD.HISTOGRAM[period] < MACD.HISTOGRAM[period - 1] and MA.DATA[period] < MA.DATA[period - 1] then
		open:setColor(period, Down)
	else
		open:setColor(period, Neutral)
	end
	if period > shift then
		dde_server:set(dde_topic, dde_alerts, open:colorI(period - shift));
	end
end
