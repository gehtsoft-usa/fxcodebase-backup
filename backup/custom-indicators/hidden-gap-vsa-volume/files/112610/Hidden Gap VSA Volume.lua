-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64691
-- Id: 18208

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
	indicator:name("Hidden Gap VSA Volume")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)

	indicator.parameters:addGroup("MACD Calculation")
	indicator.parameters:addInteger("Period", "High Period", "", 40, 1, 1000)
	indicator.parameters:addInteger("Fast", "Low Fast Period", "", 2, 1, 1000)
	indicator.parameters:addInteger("Slow", "Low Slow Period", "", 20, 1, 1000)
	indicator.parameters:addInteger("Ma", "MA Period", "", 20, 1, 1000)

	local color = core.colors()

	indicator.parameters:addGroup("Volume Style")
	indicator.parameters:addColor("color1", "Volume Above Last Period periods color", "", color.Black)
	indicator.parameters:addColor("color2", "Volume Below Last Slow period color", "", color.Gray)
	indicator.parameters:addColor("color3", "Volume Below Last Fast period color", "", color.Purple)
	indicator.parameters:addColor("color4", "Up Volume color", "", color.Blue)
	indicator.parameters:addColor("color5", "Down Volume color", "", color.Red)
	indicator.parameters:addColor("color6", "Neutral color", "", color.White)

	indicator.parameters:addGroup("MA Line Style")
	indicator.parameters:addColor("color7", "MA Line  color", "", color.Gold)

	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5)
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID)
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE)
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first
local source = nil

local open = nil
local close = nil
local high = nil
local low = nil
local xHH_vol, xLL_volSmall, xLL_volBig
local Period, Fast, Slow, Ma, MA, Volume
local xSMA_vol

function Prepare(nameOnly)
	Ma = instance.parameters.Ma
	Period = instance.parameters.Period
	Fast = instance.parameters.Fast
	Slow = instance.parameters.Slow

	source = instance.source

	local name = profile:id() .. " : " .. source:name()
	instance:name(name)
	if nameOnly then
		return;
	end

	xLL_volBig = instance:addInternalStream(0, 0)
	xLL_volSmall = instance:addInternalStream(0, 0)
	xHH_vol = instance:addInternalStream(0, 0)

	xSMA_vol = core.indicators:create("MVA", source.volume, Ma)

	first = math.max(Period, Fast, Slow, xSMA_vol.DATA:first())

	Volume = instance:addStream("Vulume", core.Bar, name, "", core.rgb(0, 0, 0), first)
    Volume:setPrecision(math.max(2, instance.source:getPrecision()));

	MA = instance:addStream("MA", core.Line, name, "MA", instance.parameters.color7, first)
	MA:setWidth(instance.parameters.width)
	MA:setStyle(instance.parameters.style)
	
	MA:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
function Update(period, mode)
	Volume[period] = source.volume[period]

	if period < first then
		Volume:setColor(period, instance.parameters.color6)
		return
	end

	xSMA_vol:update(mode)

	xHH_vol[period] = mathex.max(source.volume, period - Period + 1, period)
	xLL_volSmall[period] = mathex.min(source.volume, period - Fast + 1, period)
	xLL_volBig[period] = mathex.min(source.volume, period - Slow + 1, period)

	if source.volume[period] > xHH_vol[period - 1] then
		Volume:setColor(period, instance.parameters.color1)
	elseif source.volume[period] < xLL_volBig[period - 1] then
		Volume:setColor(period, instance.parameters.color2)
	elseif source.volume[period] < xLL_volSmall[period - 1] then
		Volume:setColor(period, instance.parameters.color3)
	elseif source.volume[period] > source.volume[period - 1] then
		Volume:setColor(period, instance.parameters.color4)
	elseif source.volume[period] < source.volume[period - 1] then
		Volume:setColor(period, instance.parameters.color5)
	else
		Volume:setColor(period, instance.parameters.color6)
	end

	MA[period] = xSMA_vol.DATA[period]
end
