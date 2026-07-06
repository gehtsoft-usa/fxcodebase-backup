-- Id: 
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63112

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
	indicator:name("Average Daily Range")
	indicator:description("Average Daily Range")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Indicator)

	indicator.parameters:addGroup("ADR Calculation")
	indicator.parameters:addString("TF", "Bar Size to display High/Low", "", "D1")
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS)
	indicator.parameters:addInteger("N", "ADR Periods", "", 14)
	indicator.parameters:addDouble("Multiplier", "Multiplier", "", 0.5)

	indicator.parameters:addBoolean("Show", "Show Projection", "", true)
	indicator.parameters:addBoolean("show_pips", "Show pips till ADR", "", false);
	indicator.parameters:addBoolean("Label", "Show Label", "", true)
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 255, 0))
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
end

local ArrowSize
local source
local ADR = nil
local Source, loading
local N
local TF
local Show
local color
local Label
local host
local first

local size
local width, style
local ADR
local Range
local Multiplier
local show_pips;
function Prepare(nameOnly)
	color = instance.parameters.color
	Show = instance.parameters.Show
	ArrowSize = instance.parameters.ArrowSize
	Label = instance.parameters.Label
	N = instance.parameters.N
	Multiplier = instance.parameters.Multiplier
	TF = instance.parameters.TF
	width = instance.parameters.width
	style = instance.parameters.style
	show_pips = instance.parameters.show_pips;
	local name = profile:id() .. "," .. instance.source:name()
	instance:name(name)

	if (nameOnly) then
		return
	end

	source = instance.source
	first = source:first() + N
	host = core.host

	Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), N, 100, 101)
	loading = true
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
	if cookie == 100 then
		loading = false
		instance:updateFrom(0)
	elseif cookie == 101 then
		loading = true
	end
end

function Update(period, mode)
	if period < source:size() - 1 or loading or not period == source:size() - 1 then
		return
	end

	start_date, end_date =
		core.getcandle(TF, core.now(), core.host:execute("getTradingDayOffset"), core.host:execute("getTradingWeekOffset"))

	local ADR = Calculate()

	local MAX = source.low[period] + ADR * Multiplier
	local MIN = source.high[period] - ADR * Multiplier

	if Label then
		local text = "ADR : " .. win32.formatNumber(ADR / source:pipSize(), false, 2);
		if show_pips then
			local current_dr = (Source.high[NOW] - Source.low[NOW]) / source:pipSize();
			text = text .. "; Pips : " .. win32.formatNumber(ADR / source:pipSize() - current_dr, false, 2);
		end
		core.host:execute("drawLabel", 1, end_date, MAX, text)
	end

	if Show then
		core.host:execute(
			"drawLine",
			2,
			start_date,
			MAX,
			end_date,
			MAX,
			color,
			style,
			width,
			string.format("%." .. 2 .. "f", MAX)
		)
		core.host:execute(
			"drawLine",
			3,
			start_date,
			MIN,
			end_date,
			MIN,
			color,
			style,
			width,
			string.format("%." .. 2 .. "f", MIN)
		)
	end
end

function Calculate()
	local Sum = 0
	local p = Source:size() - 1

	for i = 1, N, 1 do
		Sum = Sum + (Source.high[p - i] - Source.low[p - i])
	end
	return (Sum / N)
end
