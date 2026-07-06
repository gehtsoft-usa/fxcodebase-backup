-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=2368

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC |
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
	strategy:name("Strategy Builder")
	strategy:description("Strategy Builder")
	strategy:setTag("NonOptimizableParameters", "ShowAlert,PlaySound,SoundFile,RecurrentSound,SendMail,Email, SendEmail")

	strategy.parameters:addGroup(" Strategy Builder Parametars")
	strategy.parameters:addInteger("LEVEL", "Strategy Builder Threshold", "", 1, 0, 24)
	local i
	for i = 1, 3, 1 do
		strategy.parameters:addGroup(i .. " Indicator Parametars")
		if i == 1 then
			strategy.parameters:addBoolean("ON" .. i, "Indicator", "", true)
		else
			strategy.parameters:addBoolean("ON" .. i, "Indicator", "", false)
		end
		strategy.parameters:addString("IN" .. i, "Indicator", "", "")
		strategy.parameters:setFlag("IN" .. i, core.FLAG_INDICATOR)
		strategy.parameters:addBoolean("Inverse" .. i, "Inverse Indicator", "", false)
	end

	strategy.parameters:addGroup("Price Parameters")
	strategy.parameters:addString("TF", "Time Frame", "", "m15")
	strategy.parameters:setFlag("TF", core.FLAG_PERIODS)

	strategy.parameters:addString("custom_id", "Custom ID", "", "SB");

	Trading_Parameters()
end

local SoundFile = nil
local RecurrentSound = false
local ALLOWEDSIDE
local AllowMultiple
local AllowTrade
local Offer
local CanClose
local Account
local Amount
local SetLimit
local Limit
local SetStop
local Stop
local TrailingStop
local ShowAlert
local Email
local SendEmail
local BaseSize

local LEVEL
local ON = {}
local TEST
local FLAG
local Inverse = {}

local STREAMS = {}
local INV

local tsource = nil
local indicator = {}

local OpenTime, CloseTime, ExitTime
local ValidInterval, UseMandatoryClosing
local ToTime, custom_id

local AccountType
local SUPPORTED = {
	"TSI",
	"RSI",
	"EMA",
	"MVA",
	"KAMA",
	"PPMA",
	"TMA",
	"ADX",
	"DMI",
	"AROON",
	"ARSI",
	"HA",
	"ICH",
	"MD",
	"SAR",
	"CCI",
	"MACD",
	"RLW",
	"SFK",
	"ROC",
	"SSD",
	"STOCHASTIC",
	"KRI",
	"TMACD",
	"ZZZCOMPOSITE",
	"PERCENTAGE PRICE FOLLOWER",
	"FIBOAVERAGES",
	"RB_CLEAR",
	"ITREND",
	"AC",
	"AO",
	"PIVOT",
	"STOCHRSI",
	"HASM",
	"DSS",
	"SMMA",
	"REGRESSION",
	"TRENDSTOP",
	"ST",
	"HMA",
	"QQE",
	"LRS",
	"LAGUERRE_RSI",
	"LAGUERRE_FILTER"
}

function Prepare(nameOnly)
	LEVEL = instance.parameters.LEVEL
	INV = instance.parameters.INVERSE

	AccountType = instance.parameters.AccountType
	custom_id = instance.parameters.custom_id;

	local i
	for i = 1, 3, 1 do
		ON[i] = instance.parameters:getBoolean("ON" .. i)
		Inverse[i] = instance.parameters:getBoolean("Inverse" .. i)
		if ON[i] then
			local j

			for j = 1, #SUPPORTED, 1 do
				if instance.parameters:getString("IN" .. i) == SUPPORTED[j] then
					break
				elseif j == #SUPPORTED then
					assert(
						false,
						instance.parameters:getString("IN" .. i) .. " Indicator Is not supported, Contact Apprentice on FxCodeBase.com"
					)
				end
			end

			if instance.parameters:getString("IN" .. i) == "FIBOAVERAGES" then
				assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download  AVERAGES Indicator")
			end

			assert(core.indicators:findIndicator(instance.parameters:getString("IN" .. i)) ~= nil, "Please, download Indicator")
		end
	end

	assert(instance.parameters.TF ~= "t1", "The time frame must not be tick")

	local name
	name = profile:id() .. "(" .. instance.bid:name() .. "." .. instance.parameters.TF .. ")"
	instance:name(name)

	Initialization()

	tsource = ExtSubscribe(1, nil, instance.parameters.TF, true, "bar")

	local iprofile = {}
	local iparams = {}

	for i = 1, 3, 1 do
		if ON[i] then
			iprofile[i] = core.indicators:findIndicator(instance.parameters:getString("IN" .. i))
			iparams[i] = instance.parameters:getCustomParameters("IN" .. i)
			if iprofile[i]:requiredSource() == core.Tick then
				indicator[i] = iprofile[i]:createInstance(tsource.close, iparams[i])
			else
				indicator[i] = iprofile[i]:createInstance(tsource, iparams[i])
			end
		end
	end

	if nameOnly then
		return
	end

	ToTime = instance.parameters.ToTime
	ValidInterval = instance.parameters.ValidInterval
	UseMandatoryClosing = instance.parameters.UseMandatoryClosing

	if ToTime == 1 then
		ToTime = core.TZ_EST
	elseif ToTime == 2 then
		ToTime = core.TZ_UTC
	elseif ToTime == 3 then
		ToTime = core.TZ_LOCAL
	elseif ToTime == 4 then
		ToTime = core.TZ_SERVER
	elseif ToTime == 5 then
		ToTime = core.TZ_FINANCIAL
	elseif ToTime == 6 then
		ToTime = core.TZ_TS
	end

	local valid
	OpenTime, valid = ParseTime(instance.parameters.StartTime)
	assert(valid, "Time " .. instance.parameters.StartTime .. " is invalid")
	CloseTime, valid = ParseTime(instance.parameters.StopTime)
	assert(valid, "Time " .. instance.parameters.StopTime .. " is invalid")
	ExitTime, valid = ParseTime(instance.parameters.ExitTime)
	assert(valid, "Time " .. instance.parameters.ExitTime .. " is invalid")

	if UseMandatoryClosing then
		core.host:execute("setTimer", 100, math.max(ValidInterval / 2, 1))
	end
end

-- NG: create a function to parse time
function InRange(now, openTime, closeTime)
	if openTime < closeTime then
		return now >= openTime and now <= closeTime
	end
	if openTime > closeTime then
		return now > openTime or now < closeTime
	end

	return now == openTime
end

function ParseTime(time)
	local Pos = string.find(time, ":")
	if Pos == nil then
		return nil, false
	end
	local h = tonumber(string.sub(time, 1, Pos - 1))
	time = string.sub(time, Pos + 1)
	Pos = string.find(time, ":")
	if Pos == nil then
		return nil, false
	end
	local m = tonumber(string.sub(time, 1, Pos - 1))
	local s = tonumber(string.sub(time, Pos + 1))
	return (h / 24.0 + m / 1440.0 + s / 86400.0), ((h >= 0 and h < 24 and m >= 0 and m < 60 and s >= 0 and s < 60) or -- time in ole format
		(h == 24 and m == 0 and s == 0)) -- validity flag
end

function ExtUpdate(id, source, period)
	if AllowTrade then
		if not (checkReady("trades")) or not (checkReady("orders")) then
			return
		end
	end

	if period < 1 then
		return
	end

	local i

	now = core.host:execute("getServerTime")
	now = core.host:execute("convertTime", core.TZ_EST, ToTime, now)
	-- get only time
	now = now - math.floor(now)
	if not InRange(now, OpenTime, CloseTime) then
		return
	end

	if id == 1 then
		RESET()

		for i = 1, 3, 1 do
			if ON[i] then
				indicator[i]:update(core.UpdateLast)
			end

			if ON[i] then
				if
					instance.parameters:getString("IN" .. i) ~= "SAR" and instance.parameters:getString("IN" .. i) ~= "RB_CLEAR" and
						instance.parameters:getString("IN" .. i) ~= "SUPERTREND"
				 then
					if not indicator[i].DATA:hasData(period) then
						return
					end
				end

				EVALUATION(i, period)
			end
		end

		if TEST >= LEVEL and FLAG ~= "L" then
			FLAG = "L"

			if INV then
				--TRADE(false, true);
				--SIGNAL(true, true,true,  false);
				SELL()
			else
				--TRADE(true, true);
				--SIGNAL(true, true,true,  true);
				BUY()
			end
		elseif TEST <= (0 - LEVEL) and FLAG ~= "S" then
			FLAG = "S"
			if INV then
				--TRADE(true, true);
				--SIGNAL(true, true,true,  true);
				BUY()
			else
				--TRADE(false, true);
				--SIGNAL(true, true,true,  false);
				SELL()
			end
		end

		if TEST < LEVEL and FLAG == "L" then
			FLAG = nil
		elseif TEST > (0 - LEVEL) and FLAG == "S" then
			FLAG = nil
		end
	end
end

function EVALUATION(i, p)
	if instance.parameters:getString("IN" .. i) == "TSI" then
		if indicator[i].DATA[p] > 0 then
			PLUS(i)
		elseif indicator[i].DATA[p] < 0 then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "RSI" then
		if indicator[i].DATA[p] > 50 then
			PLUS(i)
		elseif indicator[i].DATA[p] < 50 then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "EMA" then
		if tsource.close[p] > indicator[i].DATA[p] then
			PLUS(i)
		elseif tsource.close[p] < indicator[i].DATA[p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "MVA" then
		if tsource.close[p] > indicator[i].DATA[p] then
			PLUS(i)
		elseif tsource.close[p] < indicator[i].DATA[p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "KAMA" then
		if tsource.close[p] > indicator[i].DATA[p] then
			PLUS(i)
		elseif tsource.close[p] < indicator[i].DATA[p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "MVA" then
		if tsource.close[p] > indicator[i].DATA[p] then
			PLUS(i)
		elseif tsource.close[p] < indicator[i].DATA[p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "PPMA" then
		if tsource.close[p] > indicator[i].DATA[p] then
			PLUS(i)
		elseif tsource.close[p] < indicator[i].DATA[p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "TMA" then
		if tsource.close[p] > indicator[i].DATA[p] then
			PLUS(i)
		elseif tsource.close[p] < indicator[i].DATA[p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "ADX" then
		if indicator[i].DATA[p] > 25 then
			PLUS(i)
		else
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "DMI" then
		STREAMS[0] = indicator[i]:getStream(0)
		STREAMS[1] = indicator[i]:getStream(1)

		if STREAMS[0][p] > STREAMS[1][p] then
			PLUS(i)
		elseif STREAMS[0][p] < STREAMS[1][p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "AROON" then
		STREAMS[0] = indicator[i]:getStream(0)
		STREAMS[1] = indicator[i]:getStream(1)

		if STREAMS[0][p] > STREAMS[1][p] then
			PLUS(i)
		elseif STREAMS[0][p] < STREAMS[1][p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "ARSI" then
		STREAMS[0] = nil
		STREAMS[0] = indicator[i]:getStream(0)

		if tsource.close[p] > STREAMS[0][p] then
			PLUS(i)
		elseif tsource.close[p] < STREAMS[0][p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "HA" then
		STREAMS[0] = indicator[i]:getStream(0)
		STREAMS[3] = indicator[i]:getStream(3)

		if STREAMS[0][p] < STREAMS[3][p] then
			PLUS(i)
		elseif STREAMS[0][p] > STREAMS[3][p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "ICH" then
		STREAMS[0] = indicator[i]:getStream(0)
		STREAMS[1] = indicator[i]:getStream(1)

		if STREAMS[0][p] > STREAMS[1][p] then
			PLUS(i)
		elseif STREAMS[0][p] < STREAMS[1][p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "MD" then
		STREAMS[0] = nil
		STREAMS[0] = indicator[i]:getStream(0)

		if tsource.close[p] > STREAMS[0][p] then
			PLUS(i)
		elseif tsource.close[p] < STREAMS[0][p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "SAR" then
		STREAMS[0] = indicator[i]:getStream(0)
		STREAMS[1] = indicator[i]:getStream(1)

		if STREAMS[0]:hasData(p) then
			MINUS(i)
		elseif STREAMS[1]:hasData(p) then
			PLUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "CCI" then
		STREAMS[0] = indicator[i]:getStream(0)

		if STREAMS[0][p] > 0 then
			PLUS(i)
		elseif STREAMS[0][p] < 0 then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "MACD" then
		STREAMS[0] = indicator[i]:getStream(0)
		STREAMS[1] = indicator[i]:getStream(1)

		if STREAMS[0][p] > STREAMS[1][p] then
			PLUS(i)
		elseif STREAMS[0][p] < STREAMS[1][p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "RLW" then
		STREAMS[0] = indicator[i]:getStream(0)

		if STREAMS[0][p] > 50 then
			PLUS(i)
		elseif STREAMS[0][p] < 50 then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "ROC" then
		STREAMS[0] = indicator[i]:getStream(0)

		if STREAMS[0][p] > 0 then
			PLUS(i)
		elseif STREAMS[0][p] < 0 then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "SFK" then
		STREAMS[0] = indicator[i]:getStream(0)
		STREAMS[1] = indicator[i]:getStream(1)

		if STREAMS[0][p] > STREAMS[1][p] then
			PLUS(i)
		elseif STREAMS[0][p] < STREAMS[1][p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "SSD" then
		STREAMS[0] = indicator[i]:getStream(0)
		STREAMS[1] = indicator[i]:getStream(1)

		if STREAMS[0][p] > STREAMS[1][p] then
			PLUS(i)
		elseif STREAMS[0][p] < STREAMS[1][p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "STOCHASTIC" then
		STREAMS[0] = indicator[i]:getStream(0)
		STREAMS[1] = indicator[i]:getStream(1)

		if STREAMS[0][p] > STREAMS[1][p] then
			PLUS(i)
		elseif STREAMS[0][p] < STREAMS[1][p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "KRI" then
		STREAMS[0] = indicator[i]:getStream(0)

		if STREAMS[0][p] > 0 then
			PLUS(i)
		elseif STREAMS[0][p] < 0 then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "TMACD" then
		STREAMS[0] = indicator[i]:getStream(0)

		if STREAMS[0][p] > 0 then
			PLUS(i)
		elseif STREAMS[0][p] < 0 then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "ZZZCOMPOSITE" then
		STREAMS[0] = indicator[i]:getStream(0)

		if STREAMS[0][p] > 0 then
			PLUS(i)
		elseif STREAMS[0][p] < 0 then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "PERCENTAGE PRICE FOLLOWER" then
		STREAMS[0] = indicator[i]:getStream(0)

		if tsource.close[p] > STREAMS[0][p] then
			PLUS(i)
		elseif tsource.close[p] < STREAMS[0][p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "FIBOAVERAGES" then
		STREAMS[0] = indicator[i]:getStream(0)

		if tsource.close[p] > STREAMS[0][p] then
			PLUS(i)
		elseif tsource.close[p] < STREAMS[0][p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "RB_CLEAR" then
		STREAMS[0] = indicator[i]:getStream(0)
		STREAMS[1] = indicator[i]:getStream(1)

		if STREAMS[0]:hasData(p) then
			PLUS(i)
		elseif STREAMS[1]:hasData(p) then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "ITREND" then
		STREAMS[0] = indicator[i]:getStream(0)
		STREAMS[1] = indicator[i]:getStream(1)
		if STREAMS[0][p] > STREAMS[1][p] then
			PLUS(i)
		elseif STREAMS[0][p] < STREAMS[1][p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "AC" then
		STREAMS[0] = indicator[i]:getStream(0)

		if STREAMS[0][p] > 0 then
			PLUS(i)
		elseif STREAMS[0][p] < 0 then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "AO" then
		STREAMS[0] = indicator[i]:getStream(0)

		if STREAMS[0][p] > 0 then
			PLUS(i)
		elseif STREAMS[0][p] < 0 then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "ST" then
		STREAMS[0] = indicator[i]:getStream(0)
		--  STREAMS[1]=indicator[i]:getStream(0);

		if tsource.close[p] > STREAMS[0][p] then
			PLUS(i)
		elseif tsource.close[p] < STREAMS[0][p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "PIVOT" then
		STREAMS[0] = indicator[i]:getStream(0)

		if tsource.close[p] > STREAMS[0][p] then
			PLUS(i)
		elseif tsource.close[p] < STREAMS[0][p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "STOCHRSI" then
		STREAMS[0] = indicator[i]:getStream(0)
		STREAMS[1] = indicator[i]:getStream(1)

		if STREAMS[0][p] > STREAMS[1][p] then
			PLUS(i)
		elseif STREAMS[0][p] < STREAMS[1][p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "HASM" then
		STREAMS[0] = indicator[i]:getStream(0)
		STREAMS[1] = indicator[i]:getStream(3)

		if STREAMS[0][p] < STREAMS[1][p] then
			PLUS(i)
		elseif STREAMS[0][p] > STREAMS[1][p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "DSS" then
		STREAMS[0] = indicator[i]:getStream(0)
		STREAMS[1] = indicator[i]:getStream(1)

		if STREAMS[0][p] > STREAMS[1][p] then
			PLUS(i)
		elseif STREAMS[0][p] < STREAMS[1][p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "SMMA" then
		STREAMS[0] = indicator[i]:getStream(0)

		if tsource.close[p] > STREAMS[0][p] then
			PLUS(i)
		elseif tsource.close[p] < STREAMS[0][p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "REGRESSION" then
		STREAMS[0] = indicator[i]:getStream(0)

		if tsource.close[p] > STREAMS[0][p] then
			PLUS(i)
		elseif tsource.close[p] < STREAMS[0][p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "TRENDSTOP" then
		STREAMS[0] = indicator[i]:getStream(0)

		if tsource.close[p] > STREAMS[0][p] then
			PLUS(i)
		elseif tsource.close[p] < STREAMS[0][p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "HMA" then
		STREAMS[0] = indicator[i]:getStream(0)

		if tsource.close[p] > STREAMS[0][p] then
			PLUS(i)
		elseif tsource.close[p] < STREAMS[0][p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "QQE" then
		STREAMS[0] = indicator[i]:getStream(0)
		STREAMS[1] = indicator[i]:getStream(1)

		if STREAMS[0][p] > STREAMS[1][p] then
			PLUS(i)
		elseif STREAMS[0][p] < STREAMS[1][p] then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "LRS" then
		STREAMS[0] = indicator[i]:getStream(0)

		if STREAMS[0][p] > 0 then
			PLUS(i)
		elseif STREAMS[0][p] < 0 then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "LAGUERRE_RSI" then
		STREAMS[0] = indicator[i]:getStream(0)

		if STREAMS[0][p] > 0.5 then
			PLUS(i)
		elseif STREAMS[0][p] < 0.5 then
			MINUS(i)
		end
	elseif instance.parameters:getString("IN" .. i) == "LAGUERRE_FILTER" then
		STREAMS[0] = indicator[i]:getStream(0)

		if tsource.close[p] > STREAMS[0][p] then
			PLUS(i)
		elseif tsource.close[p] < STREAMS[0][p] then
			MINUS(i)
		end
	else
		assert(
			false,
			instance.parameters:getString("IN" .. i) .. " Indicator Is not supported, Contact Apprentice on FxCodeBase.com"
		)
	end
end

function PLUS(j)
	if Inverse[j] then
		TEST = TEST - 1
	else
		TEST = TEST + 1
	end
end

function MINUS(j)
	if Inverse[j] then
		TEST = TEST + 1
	else
		TEST = TEST - 1
	end
end
function RESET(j)
	TEST = 0
end

function SIGNAL(ALERT, SOUND, MAIL, mode)
	if mode then
		if ShowAlert and ALERT then
			terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Enter Long", instance.bid:date(NOW))
		end

		if SoundFile ~= nil and SOUND then
			terminal:alertSound(SoundFile, RecurrentSound)
		end

		if Email ~= nil and MAIL then
			terminal:alertEmail(Email, "Enter Long", "Enter Long signal")
		end
	end

	if not mode then
		if ShowAlert and ALERT then
			terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Enter Short", instance.bid:date(NOW))
		end
		if SoundFile ~= nil and SOUND then
			terminal:alertSound(SoundFile, RecurrentSound)
		end

		if Email ~= nil and MAIL then
			terminal:alertEmail(Email, "Enter Short", "Enter Short signal")
		end
	end
end

function TRADE(mode, close)
	if mode and close then
		exit("S")
		enter("B")
	end

	if not mode and close then
		exit("B")
		enter("S")
	end

	if mode and not close then
		enter("B")
	end

	if not mode and not close then
		enter("S")
	end
end

--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--

function BUY()
	if AllowTrade then
		if haveTrades("B") and not AllowMultiple then
			exit("S")
			Signal("Close Short")

			return
		end

		if ALLOWEDSIDE == "Sell" then
			if haveTrades("S") then
				exit("S")
				Signal("Close Short")
			end

			return
		end

		if haveTrades("S") then
			exit("S")
			Signal("Close Short")
		end
		enter("B")
		Signal("Open Long")
	elseif ShowAlert then
		Signal("Up Trend")
	end
end

function SELL()
	if AllowTrade then
		if haveTrades("S") and not AllowMultiple then
			exit("B")
			Signal("Close Long")

			return
		end

		if ALLOWEDSIDE == "Buy" then
			if haveTrades("B") then
				exit("B")
				Signal("Close Long")
			end

			return
		end

		if haveTrades("B") then
			exit("B")
			Signal("Close Long")
		end
		enter("S")
		Signal("Open Short")
	else
		Signal("Down Trend")
	end
end

function Trading_Parameters()
	strategy.parameters:addGroup("Trading Parameters")

	strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false)
	strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)

	strategy.parameters:addString("AccountType", "Account Type", "", "Automatic")
	strategy.parameters:addStringAlternative("AccountType", "FIFO", "", "FIFO")
	strategy.parameters:addStringAlternative("AccountType", "non FIFO", "", "NON")
	strategy.parameters:addStringAlternative("AccountType", "Automatic", "", "Automatic")

	strategy.parameters:addString(
		"ALLOWEDSIDE",
		"Allowed side",
		"Allowed side for trading or signaling, can be Sell, Buy or Both",
		"Both"
	)
	strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both")
	strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy")
	strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell")

	strategy.parameters:addBoolean("AllowMultiple", "Allow Multiple", "", true)
	strategy.parameters:addString("Account", "Account to trade on", "", "")
	strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
	strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000)
	strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false)
	strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000)
	strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false)
	strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000)
	strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false)

	strategy.parameters:addGroup("Alerts")
	strategy.parameters:addBoolean("ShowAlert", "ShowAlert", "", true)
	strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false)
	strategy.parameters:addFile("SoundFile", "Sound File", "", "")
	strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND)
	strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", true)
	strategy.parameters:addBoolean("SendEmail", "Send Email", "", false)
	strategy.parameters:addString("Email", "Email", "", "")
	strategy.parameters:setFlag("Email", core.FLAG_EMAIL)

	strategy.parameters:addGroup("Time Parameters")
	strategy.parameters:addInteger("ToTime", "Convert the date to", "", 6)
	strategy.parameters:addIntegerAlternative("ToTime", "EST", "", 1)
	strategy.parameters:addIntegerAlternative("ToTime", "UTC", "", 2)
	strategy.parameters:addIntegerAlternative("ToTime", "Local", "", 3)
	strategy.parameters:addIntegerAlternative("ToTime", "Server", "", 4)
	strategy.parameters:addIntegerAlternative("ToTime", "Financial", "", 5)
	strategy.parameters:addIntegerAlternative("ToTime", "Display", "", 6)

	strategy.parameters:addString("StartTime", "Start Time for Trading", "", "00:00:00")
	strategy.parameters:addString("StopTime", "Stop Time for Trading", "", "24:00:00")

	strategy.parameters:addBoolean("UseMandatoryClosing", "Use Mandatory Closing", "", false)
	strategy.parameters:addString("ExitTime", "Mandatory Closing  Time", "", "23:59:00")
	strategy.parameters:addInteger("ValidInterval", "Valid interval for operation in second", "", 60)
end

function Initialization()
	AllowMultiple = instance.parameters.AllowMultiple
	ALLOWEDSIDE = instance.parameters.ALLOWEDSIDE

	local PlaySound = instance.parameters.PlaySound
	if PlaySound then
		SoundFile = instance.parameters.SoundFile
	else
		SoundFile = nil
	end
	assert(not (PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be chosen")
	ShowAlert = instance.parameters.ShowAlert
	RecurrentSound = instance.parameters.RecurrentSound

	SendEmail = instance.parameters.SendEmail

	if SendEmail then
		Email = instance.parameters.Email
	else
		Email = nil
	end
	assert(not (SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified")

	AllowTrade = instance.parameters.AllowTrade
	if AllowTrade then
		Account = instance.parameters.Account
		Amount = instance.parameters.Amount
		BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account)
		Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID
		--CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account);

		if AccountType == "FIFO" then
			CanClose = false
		elseif AccountType == "NON" then
			CanClose = true
		else
			CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)
		end

		SetLimit = instance.parameters.SetLimit
		Limit = instance.parameters.Limit
		SetStop = instance.parameters.SetStop
		Stop = instance.parameters.Stop
		TrailingStop = instance.parameters.TrailingStop
	end
end

function Signal(Label)
	if ShowAlert then
		terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], Label, instance.bid:date(NOW))
	end
	if SoundFile ~= nil then
		terminal:alertSound(SoundFile, RecurrentSound)
	end

	if Email ~= nil then
		terminal:alertEmail(
			Email,
			Label,
			profile:id() ..
				"(" .. instance.bid:instrument() .. ")" .. instance.bid[NOW] .. ", " .. Label .. ", " .. instance.bid:date(NOW)
		)
	end
end

function checkReady(table)
	local rc
	if Account == "TESTACC_ID" then
		-- run under debugger/simulator
		rc = true
	else
		rc = core.host:execute("isTableFilled", table)
	end
	return rc
end

function tradesCount(BuySell)
	local enum, row
	local count = 0
	enum = core.host:findTable("trades"):enumerator()
	row = enum:next()
	while count == 0 and row ~= nil do
		if row.AccountID == Account and row.OfferID == Offer and (row.BS == BuySell or BuySell == nil) and row.QTXT == custom_id then
			count = count + 1
		end
		row = enum:next()
	end

	return count
end

function haveTrades(BuySell)
	local enum, row
	local found = false
	enum = core.host:findTable("trades"):enumerator()
	row = enum:next()
	while (not found) and (row ~= nil) do
		if row.AccountID == Account and row.OfferID == Offer and (row.BS == BuySell or BuySell == nil) and row.QTXT == custom_id then
			found = true
		end
		row = enum:next()
	end

	return found
end

-- enter into the specified direction
function enter(BuySell)
	if not (AllowTrade) then
		return true
	end

	-- do not enter if position in the
	-- specified direction already exists
	if tradesCount(BuySell) > 0 and not AllowMultiple then
		return true
	end

	local valuemap, success, msg
	valuemap = core.valuemap()

	valuemap.OrderType = "OM"
	valuemap.OfferID = Offer
	valuemap.AcctID = Account
	valuemap.Quantity = Amount * BaseSize
	valuemap.BuySell = BuySell

	-- add stop/limit

	valuemap.PegTypeStop = "O"
	if SetStop then
		if BuySell == "B" then
			valuemap.PegPriceOffsetPipsStop = -Stop
		else
			valuemap.PegPriceOffsetPipsStop = Stop
		end
	end
	if TrailingStop then
		valuemap.TrailStepStop = 1
	end

	valuemap.PegTypeLimit = "O"
	if SetLimit then
		if BuySell == "B" then
			valuemap.PegPriceOffsetPipsLimit = Limit
		else
			valuemap.PegPriceOffsetPipsLimit = -Limit
		end
	end
	valuemap.CustomID = custom_id;

	if (not CanClose) then
		valuemap.EntryLimitStop = "Y"
	end

	success, msg = terminal:execute(100, valuemap)

	if not (success) then
		terminal:alertMessage(
			instance.bid:instrument(),
			instance.bid[instance.bid:size() - 1],
			"Open order failed" .. msg,
			instance.bid:date(instance.bid:size() - 1)
		)
		return false
	end

	return true
end

-- exit from the specified direction
function exit(BuySell, use_net)
	if not (AllowTrade) then
		return true
	end

	if use_net == true then
		local valuemap, success, msg
		if tradesCount(BuySell) > 0 then
			valuemap = core.valuemap()

			-- switch the direction since the order must be in oppsite direction
			if BuySell == "B" then
				BuySell = "S"
			else
				BuySell = "B"
			end
			valuemap.OrderType = "CM"
			valuemap.OfferID = Offer
			valuemap.AcctID = Account
			valuemap.NetQtyFlag = "Y"
			valuemap.BuySell = BuySell
			success, msg = terminal:execute(101, valuemap)

			if not (success) then
				terminal:alertMessage(
					instance.bid:instrument(),
					instance.bid[instance.bid:size() - 1],
					"Open order failed" .. msg,
					instance.bid:date(instance.bid:size() - 1)
				)
				return false
			end
			return true
		end
	else
		local enum = core.host:findTable("trades"):enumerator()
		local row = enum:next()
		while row ~= nil do
			if row.BS == BuySell and row.OfferID == Offer and row.QTXT == custom_id then
				local valuemap = core.valuemap()
				valuemap.BuySell = row.BS == "B" and "S" or "B"
				valuemap.OrderType = "CM"
				valuemap.OfferID = row.OfferID
				valuemap.AcctID = row.AccountID
				valuemap.TradeID = row.TradeID
				valuemap.Quantity = row.Lot
				local success, msg = terminal:execute(101, valuemap)
			end
			row = enum:next()
		end
	end
	return false
end

-- NG: Introduce async function for timer/monitoring for the order results
function ExtAsyncOperationFinished(cookie, success, message)
	if cookie == 100 then
		-- timer
		if UseMandatoryClosing and AllowTrade then
			now = core.host:execute("getServerTime")
			now = core.host:execute("convertTime", core.TZ_EST, ToTime, now)
			-- get only time
			now = now - math.floor(now)

			-- check whether the time is in the exit time period
			if now >= ExitTime and now < ExitTime + (ValidInterval / 86400.0) then
				if not checkReady("trades") then
					return
				end

				if haveTrades("B") then
					exit("B")
					Signal("Close Long")
				end

				if haveTrades("S") then
					exit("S")
					Signal("Close Short")
				end
			end
		end
	elseif cookie == 200 and not success then
		terminal:alertMessage(
			instance.bid:instrument(),
			instance.bid[instance.bid:size() - 1],
			"Open order failed" .. message,
			instance.bid:date(instance.bid:size() - 1)
		)
	elseif cookie == 201 and not success then
		terminal:alertMessage(
			instance.bid:instrument(),
			instance.bid[instance.bid:size() - 1],
			"Close order failed" .. message,
			instance.bid:date(instance.bid:size() - 1)
		)
	end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
