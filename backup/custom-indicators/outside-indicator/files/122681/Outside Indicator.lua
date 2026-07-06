-- Id: 23275
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67135

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
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

-- Indicator profile initialization routine

function Init()
	indicator:name("Outside Indicator")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("Calculation")

	indicator.parameters:addBoolean("SignalMode", "SignalMode", "", false)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addBoolean("show_strong", "Show Strong", "", true)
	indicator.parameters:addColor("Strong", "Strong Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addBoolean("show_weak", "Show Weak", "", true)
	indicator.parameters:addColor("Weak", "Weak Color", "", core.rgb(0, 0, 255))
	indicator.parameters:addBoolean("show_pinbar", "Show Pinbar", "", true)
	indicator.parameters:addColor("Pinbar", "Pinbar Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addInteger("Size", "Size", "", 10)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local SignalMode
local first
local source = nil
local Size
local Signal
local up, down
local font
local Strong, Weak, Pinbar
local show_strong, show_weak, show_pinbar;
-- Routine
function Prepare(nameOnly)
	local Parameters = ""

	local name = profile:id() .. "(" .. instance.source:name() .. "," .. Parameters .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end
	show_strong = instance.parameters.show_strong;
	show_weak = instance.parameters.show_weak;
	show_pinbar = instance.parameters.show_pinbar;
	Strong = instance.parameters.Strong
	Weak = instance.parameters.Weak
	Pinbar = instance.parameters.Pinbar

	SignalMode = instance.parameters.SignalMode
	Size = instance.parameters.Size

	font = core.host:execute("createFont", "Wingdings", Size, false, false)

	source = instance.source
	first = source:first()

	if SignalMode then
		Signal = instance:addStream("Signal", core.Bar, "Signal", "Signal", Strong, first)
	else
		Signal = instance:addInternalStream(0, 0)
	end
end

-- Indicator calculation routine
function Update(period, mode)
	if period < first then
		return
	end

	Signal[period] = 0

	if source.close[period] > source.open[period] and source.close[period - 1] < source.open[period - 1] then
		if source.high[period] > source.high[period - 1] and source.low[period] < source.low[period - 1] then
			if show_strong then
				Signal[period] = 2
			end
		elseif source.close[period] > source.open[period - 1] then
			if show_weak then
				Signal[period] = 1
			end
		end
	elseif source.close[period] < source.open[period] and source.close[period - 1] > source.open[period - 1] then
		if source.high[period] > source.high[period - 1] and source.low[period] < source.low[period - 1] then
			if show_strong then
				Signal[period] = -2
			end
		elseif source.close[period] < source.open[period - 1] then
			if show_weak then
				Signal[period] = -1
			end
		end
	elseif show_pinbar then
		local Top = source.high[period] - math.max(source.open[period], source.close[period])
		local Bottom = math.min(source.open[period], source.close[period]) - source.low[period]
		local Body = math.abs(source.open[period] - source.close[period])

		if Top > Body * 3 or Bottom > Body * 3 then
			if source.close[period] > source.open[period] then
				Signal[period] = 3
			elseif source.close[period] < source.open[period] then
				Signal[period] = -3
			end
		end
	end

	if SignalMode then
		return
	end

	core.host:execute("removeLabel", source:serial(period))

	local Price = nil
	local Symbol = nil
	local Color = nil
	local VA

	if Signal[period] == 1 then
		Color = Weak
		Symbol = "\108"
		VA = core.V_Bottom
		Price = source.low[period]
	elseif Signal[period] == 2 then
		Color = Strong
		Symbol = "\108"
		VA = core.V_Bottom
		Price = source.low[period]
	elseif Signal[period] == -1 then
		Color = Weak
		Symbol = "\108"
		VA = core.V_Top
		Price = source.high[period]
	elseif Signal[period] == -2 then
		Color = Strong
		Symbol = "\108"
		VA = core.V_Top
		Price = source.high[period]
	elseif Signal[period] == 3 then
		Color = Pinbar
		Symbol = "\110"
		VA = core.V_Bottom
		Price = source.low[period]
	elseif Signal[period] == -3 then
		Color = Pinbar
		Symbol = "\110"
		VA = core.V_Top
		Price = source.high[period]
	end

	if Price ~= nil then
		core.host:execute(
			"drawLabel1",
			source:serial(period),
			source:date(period),
			core.CR_CHART,
			Price,
			core.CR_CHART,
			core.H_Center,
			VA,
			font,
			Color,
			Symbol
		)
	end
end

function ReleaseInstance()
	core.host:execute("deleteFont", font)
end
