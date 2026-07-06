-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=74403

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+

-- Indicator profile initialization routine

function Init()
	indicator:name("Variance")
	indicator:description("")
	indicator:requiredSource(core.Tick)
	indicator:type(core.Oscillator)

	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("Period", "Period", "", 14, 1, 2000)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE)
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period
local first
local source = nil

local Oscillator

-- Routine
function Prepare(nameOnly)
	Period = instance.parameters.Period

	local Parameters = Period

	local name = profile:id() .. "(" .. instance.source:name() .. ", " .. Parameters .. ")"
	instance:name(name)

	if (nameOnly) then
		return
	end

	source = instance.source
	first = source:first() + Period

	-- Average= instance:addInternalStream(0, 0);

	Oscillator =
		instance:addStream("Oscillator", core.Line, " Oscillator", " Oscillator", instance.parameters.color, first)
	Oscillator:setWidth(instance.parameters.width)
	Oscillator:setStyle(instance.parameters.style)
	Oscillator:setPrecision(math.max(2, source:getPrecision()))
end

-- Indicator calculation routine
function Update(period, mode)
	if period < source:first() + Period then
		return
	end
	local m = 0
	local s = 0
	local oldm = 0
	for k = 0, Period - 1, 1 do
		oldm = m
		m = m + (source[period - k] - m) / (1.0 + k)
		s = s + (source[period - k] - m) * (source[k] - oldm)
	end

	Oscillator[period] = (s / (Period - 1))
end
--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+
