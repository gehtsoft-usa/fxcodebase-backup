-- Id: 10822
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=20399

--+------------------------------------------------------------------+
--|                                            http://fxcodebase.com |
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

-- Created by Alokasi. Contact by private message at http://fxcodebase.com

-- License

-- Permission is hereby granted, free of charge, to any person obtaining a copy of this materials and
-- associated documentation files (the "Materials"), to deal in the Materials without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Materials, and to permit persons to whom the Materials is furnished to do so, subject to the
-- following conditions:

-- The author's copyright notice and this permission notice shall be included in all copies or substantial
-- portions of the Materials.

-- THE MATERIALS ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
-- LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
-- EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
-- IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE MATERIALS OR
-- THE USE OR OTHER DEALINGS IN THE MATERIALS.

-- Using of any materials of this site serves as your acknowledgement and representation that you have read
-- and understand all the disclaimers and this license and that you agree to be bound by them.

function Init() --The strategy profile initialization
	strategy:name("Finger Cuffs")
	strategy:description(
		"Finger Cuffs strategy adapted from James Stanley's article (http://www.dailyfx.com/forex/education/trading_tips/daily_trading_lesson/2012/03/26/Short_Term_Momentum_Scalping_in_Forex.html)"
	)
	strategy:setTag("Version", "2")
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert")
	strategy.parameters:addGroup("Price Parameters")
	-- trend time frames
	strategy.parameters:addString("trendPeriod", "Trend time frame", "Time frame to use for determining trend", "H1")
	strategy.parameters:setFlag("trendPeriod", core.FLAG_PERIODS)
	-- entry time frames
	strategy.parameters:addString(
		"entryPeriod",
		"Trade entry time frame",
		"Time frame to use for determining trade entry",
		"m15"
	)
	strategy.parameters:setFlag("entryPeriod", core.FLAG_PERIODS)
	-- trade management time frames
	strategy.parameters:addString(
		"trdMgmtPeriod",
		"Trade management time frame",
		"Time frame to use for managing the trade",
		"m1"
	)
	strategy.parameters:setFlag("trdMgmtPeriod", core.FLAG_PERIODS)
	strategy.parameters:addString("Price", "Price type", "", "close")
	strategy.parameters:addStringAlternative("Price", "close", "", "close")
	strategy.parameters:addStringAlternative("Price", "open", "", "open")
	strategy.parameters:addStringAlternative("Price", "high", "", "high")
	strategy.parameters:addStringAlternative("Price", "low", "", "low")
	strategy.parameters:addStringAlternative("Price", "median", "", "median")
	strategy.parameters:addStringAlternative("Price", "typical", "", "typical")
	strategy.parameters:addStringAlternative("Price", "weighted", "", "weighted")
	-- use a second trend time frame
	strategy.parameters:addBoolean("confirmTrend", "Confirm trend in a second time frame", "", true)
	strategy.parameters:addString(
		"trendPeriod2",
		"Time frame for the confirmation trend",
		"This should be the large of two trends. Only the first trend (above) has a trend collapse failsafe for closing trades.",
		"H4"
	)
	strategy.parameters:setFlag("trendPeriod2", core.FLAG_PERIODS)
	strategy.parameters:addBoolean(
		"enforceTrendBarDirection",
		"Enter only when the trend bar is moving in the trend direction",
		"",
		true
	)
	strategy.parameters:addBoolean(
		"closeOnTrendCollapse",
		"Close open trades when fast trend EMA crosses slow trend EMA",
		"",
		false
	)

	strategy.parameters:addGroup("EMA Parameters")
	strategy.parameters:addInteger("fastEma", "Fast EMA period", "", 8)
	strategy.parameters:addInteger("slowEma", "Slow EMA period", "", 34)

	strategy.parameters:addGroup("Channel Parameters")
	strategy.parameters:addBoolean("confirmWithChannel", "Use the channel in trend determination", "", false)
	-- strategy.parameters:addBoolean("useChannelStops", "Use the trend time frame channel as the initial stop", "", false);
	strategy.parameters:addInteger("nLB", "Lookback period", "", 24, 2, 100000)
	strategy.parameters:addInteger("nD", "Delay period", "", 3, 2, 100000)
	strategy.parameters:addString(
		"rangeType",
		"Range type",
		"Take the ranges from the candle bodies or from the wicks.",
		"Wicks"
	)
	strategy.parameters:addStringAlternative("rangeType", "Bodies", "Determine the range from the candle bodies", "Bodies")
	strategy.parameters:addStringAlternative(
		"rangeType",
		"Wicks",
		"Determine the range from the full length of the candle, including wicks",
		"Wicks"
	)

	strategy.parameters:addGroup("ATR Parameters")
	-- strategy.parameters:addBoolean("useATRStops","Use the ATR to set stops","",false);
	strategy.parameters:addDouble("atrStopFactor", "Set stop at ATR times this value", "", 2)
	-- strategy.parameters:addBoolean("useATRLimits","Use the ATR to set limits","",false);
	-- strategy.parameters:addDouble("atrLimitFactor","Set limit at ATR times this value","",5);
	strategy.parameters:addInteger("nATR", "ATR lookback period", "Note: ATR uses the Trend time frame", 14)

	strategy.parameters:addGroup("Trading Parameters")
	strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true)
	strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE)
	strategy.parameters:addString("Account", "Account to trade on", "", "")
	strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT)
	strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 2, 1, 100)
	strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", true)
	-- strategy.parameters:addString("limitType", "Type of limit to use", "", "Pips");
	-- strategy.parameters:addStringAlternative("limitType", "Pips", "", "Pips");
	-- strategy.parameters:addStringAlternative("limitType", "ATR", "", "ATR");
	-- strategy.parameters:addStringAlternative("limitType", "Channel", "", "Channel");
	strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 150, 1, 10000)
	strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", true)
	strategy.parameters:addString("stopType", "Type of stop to use", "", "Channel")
	strategy.parameters:addStringAlternative("stopType", "Pips", "", "Pips")
	strategy.parameters:addStringAlternative("stopType", "ATR", "", "ATR")
	strategy.parameters:addStringAlternative("stopType", "Channel", "", "Channel")
	strategy.parameters:addBoolean(
		"SetMaxLoss",
		"Clamp automatic stop loss set values",
		"When set 'true', will use the minimum of either the automatic determined stop loss or the value set below",
		false
	)
	strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 75, 1, 10000)
	strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false)
	strategy.parameters:addString("AllowDirection", "Allow direction for positions", "", "Both")
	strategy.parameters:addStringAlternative("AllowDirection", "Both", "", "Both")
	strategy.parameters:addStringAlternative("AllowDirection", "Long", "", "Long")
	strategy.parameters:addStringAlternative("AllowDirection", "Short", "", "Short")

	strategy.parameters:addGroup("Margin care")
	strategy.parameters:addBoolean("UseMarginCare", "Perform margin care", "", true)
	strategy.parameters:addDouble(
		"marginPercent",
		"Min margin buffer (%)",
		"If the margin of the account is below the required marging plus this percentage, positions will not open.",
		10
	)

	strategy.parameters:addGroup("Automatic Trade Management")
	strategy.parameters:addBoolean("autoTrdMgmt", "Use automatic trade management", "", true)
	strategy.parameters:addDouble("Profit", "Min Profit (in pips)", "", 50.0)
	strategy.parameters:addDouble("Gap", "Lead Gap (in pips)", "", 25.0)
	-- strategy.parameters:addBoolean("takeProfit", "Take profit on stop move", "Whether to take immediate profit on half of the lot when the stop is moved the first time. The profit taken would be Min. Profit + Gap.", false);
	strategy.parameters:addString("stopMoveAction", "Action to take when stop is moved", "", "Nothing")
	strategy.parameters:addStringAlternative("stopMoveAction", "Take Profit", "", "Take Profit")
	strategy.parameters:addStringAlternative("stopMoveAction", "Nothing", "", "Nothing")
	strategy.parameters:addStringAlternative("stopMoveAction", "Add to Position", "", "Add to Position")
	strategy.parameters:addInteger("addPosLots", "Amount to add on stop move (in Lots)", "", 2)

	strategy.parameters:addGroup("Signal Parameters")
	strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true)
	strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false)
	strategy.parameters:addFile("SoundFile", "Sound File", "", "")
	strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND)
	strategy.parameters:addBoolean("Recurrent", "RecurrentSound", "", false)

	strategy.parameters:addGroup("Email Parameters")
	strategy.parameters:addBoolean("SendEmail", "Send email", "", false)
	strategy.parameters:addString("Email", "Email address", "", "")
	strategy.parameters:setFlag("Email", core.FLAG_EMAIL)
end

-- Signal Parameters
local ShowAlert
local SoundFile
local RecurrentSound
local SendEmail, Email

-- Source variables
local trendSource = nil
local entrySource = nil
local trdMgmtSource = nil
local trendSouce2 = nil
-- local trendSourceLoading = true;
-- local entrySourceLoading = true;
-- local trdMgmtSourceLoading = true;

-- Internal indicators
local fEmaTrend = nil
local sEmaTrend = nil
local fEmaTrend2 = nil
local sEmaTrend2 = nil
local fEmaEntry = nil
local sEmaEntry = nil
local ohlc4T = nil
local ohlc4T2 = nil
local ohlc4E = nil
local hlRange = nil
local hlRange2 = nil
local hlRangeE = nil
local atr = nil

-- Internal flags
local trendDirection = 0
local trendDirection2 = 0
local closeTrades = 0
local profitTaken = false
local waitEntry = false

-- Strategy parameters
local openLevel = 0
local closeLevel = 0
-- local confirmTrend;

-- Trading parameters
local AllowTrade = nil
local Account = nil
local Amount = nil
local BaseSize = nil
local PipSize
local SetLimit = nil
local Limit = nil
local SetStop = nil
local Stop = nil
local TrailingStop = nil
local CanClose = nil
local AllowDirection

-- auto trading stuff
local stopOrder = nil -- the identifier of the stop order
local sar = nil
local timer
local minChange
local executing = false
local Profit
local gap
local profitSum
local stopOrder

local Parameters = {}
local CanClose = true

local orderId
local tradeId
local requestId
--
--
--
function Prepare(nameOnly)
	ShowAlert = instance.parameters.ShowAlert
	AllowDirection = instance.parameters.AllowDirection
	local PlaySound = instance.parameters.PlaySound
	if PlaySound then
		SoundFile = instance.parameters.SoundFile
	else
		SoundFile = nil
	end
	assert(not (PlaySound) or SoundFile ~= "", "Sound file must be chosen")
	RecurrentSound = instance.parameters.Recurrent

	local SendEmail = instance.parameters.SendEmail
	if SendEmail then
		Email = instance.parameters.Email
	else
		Email = nil
	end
	assert(not (SendEmail) or Email ~= "", "Email address must be specified")
	-- assert(instance.parameters.TF ~= "t1", "The time frame must not be tick");

	local name
	name =
		profile:id() ..
		"(" .. instance.bid:name() .. "." .. instance.parameters.trendPeriod .. ", lots=" .. instance.parameters.Amount .. ")"
	instance:name(name)
	if nameOnly then
		return
	end

	AllowTrade = instance.parameters.AllowTrade
	if AllowTrade then
		Account = instance.parameters.Account
		Amount = instance.parameters.Amount
		BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account)
		Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID
		CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)
		PipSize = instance.bid:pipSize()
		SetLimit = instance.parameters.SetLimit
		Limit = instance.parameters.Limit
		SetStop = instance.parameters.SetStop
		Stop = instance.parameters.Stop
		TrailingStop = instance.parameters.TrailingStop
	end

	gap = instance.parameters.Gap
	Profit = instance.parameters.Profit
	profitSum = Profit
	minChange = math.pow(10, -instance.bid:getPrecision())

	-- Setup the source for determining the trend
	trendSource = ExtSubscribe(2101, nil, instance.parameters.trendPeriod, true, "bar")
	Price = instance.parameters.Price
	if Price == "close" then
		trendSource_ = trendSource.close
	elseif Price == "open" then
		trendSource_ = trendSource.open
	elseif Price == "high" then
		trendSource_ = trendSource.high
	elseif Price == "low" then
		trendSource_ = trendSource.low
	elseif Price == "typical" then
		trendSource_ = trendSource.typical
	elseif Price == "median" then
		trendSource_ = trendSource.median
	else
		trendSource_ = trendSource.weighted
	end

	-- Setup the source for determining the second trend
	if instance.parameters.confirmTrend then
		trendSource2 = ExtSubscribe(2104, nil, instance.parameters.trendPeriod2, true, "bar")
		Price = instance.parameters.Price
		if Price == "close" then
			trendSource2_ = trendSource2.close
		elseif Price == "open" then
			trendSource2_ = trendSource2.open
		elseif Price == "high" then
			trendSource2_ = trendSource2.high
		elseif Price == "low" then
			trendSource2_ = trendSource2.low
		elseif Price == "typical" then
			trendSource2_ = trendSource2.typical
		elseif Price == "median" then
			trendSource2_ = trendSource2.median
		else
			trendSource2_ = trendSource2.weighted
		end
	end

	-- Setup the source for determining entry signals
	entrySource = ExtSubscribe(2102, nil, instance.parameters.entryPeriod, true, "bar")
	Price = instance.parameters.Price
	if Price == "close" then
		entrySource_ = entrySource.close
	elseif Price == "open" then
		entrySource_ = entrySource.open
	elseif Price == "high" then
		entrySource_ = entrySource.high
	elseif Price == "low" then
		entrySource_ = entrySource.low
	elseif Price == "typical" then
		entrySource_ = entrySource.typical
	elseif Price == "median" then
		entrySource_ = entrySource.median
	else
		entrySource_ = entrySource.weighted
	end

	-- Setup the source for trade management
	if instance.parameters.autoTrdMgmt then
		trdMgmtSource = ExtSubscribe(2103, nil, instance.parameters.trdMgmtPeriod, true, "bar")
		Price = instance.parameters.Price
		if Price == "close" then
			trdMgmtSource_ = trdMgmtSource.close
		elseif Price == "open" then
			trdMgmtSource_ = trdMgmtSource.open
		elseif Price == "high" then
			trdMgmtSource_ = trdMgmtSource.high
		elseif Price == "low" then
			trdMgmtSource_ = trdMgmtSource.low
		elseif Price == "typical" then
			trdMgmtSource_ = trdMgmtSource.typical
		elseif Price == "median" then
			trdMgmtSource_ = trdMgmtSource.median
		else
			trdMgmtSource_ = trdMgmtSource.weighted
		end
	end

	assert(core.indicators:findIndicator("HL_RANGE") ~= nil, "Please, download and install HL_RANGE.LUA indicator")
	assert(core.indicators:findIndicator("OHLC4") ~= nil, "Please, download and install OHLC4.LUA indicator")

	-- create the internal indicator streams (order of creation is important for updates)
	-- Trend streams
	fEmaTrend = core.indicators:create("EMA", trendSource_, instance.parameters.fastEma)
	sEmaTrend = core.indicators:create("EMA", trendSource_, instance.parameters.slowEma)
	hlRange =
		core.indicators:create(
		"HL_RANGE",
		trendSource,
		instance.parameters.nLB,
		instance.parameters.nD,
		instance.parameters.rangeType
	)
	ohlc4T = core.indicators:create("OHLC4", trendSource)
	if instance.parameters.stopType == "ATR" then
		atr = core.indicators:create("ATR", trendSource, instance.parameters.nATR)
	end

	-- Second Trend streams
	if instance.parameters.confirmTrend then
		fEmaTrend2 = core.indicators:create("EMA", trendSource2_, instance.parameters.fastEma)
		sEmaTrend2 = core.indicators:create("EMA", trendSource2_, instance.parameters.slowEma)
		hlRange2 =
			core.indicators:create(
			"HL_RANGE",
			trendSource2,
			instance.parameters.nLB,
			instance.parameters.nD,
			instance.parameters.rangeType
		)
		ohlc4T2 = core.indicators:create("OHLC4", trendSource2)
	end

	-- Entry streams
	fEmaEntry = core.indicators:create("EMA", entrySource_, instance.parameters.fastEma)
	sEmaEntry = core.indicators:create("EMA", entrySource_, instance.parameters.slowEma)
	ohlc4E = core.indicators:create("OHLC4", entrySource)
	hlRangeE =
		core.indicators:create(
		"HL_RANGE",
		entrySource,
		instance.parameters.nLB,
		instance.parameters.nD,
		instance.parameters.rangeType
	)

	-- Trade Management streams

	ExtSetupSignal(profile:id() .. ":", ShowAlert)
	ExtSetupSignalMail(name)
end

function ExtUpdate(id, source, period) -- The method called every time when a new bid or ask price appears.
	-- Conditions to check and execute if the trend period data (id 2101) is being returned
	if id == 2101 then
		fEmaTrend:update(core.UpdateLast)
		sEmaTrend:update(core.UpdateLast)
		hlRange:update(core.UpdateLast)
		ohlc4T:update(core.UpdateLast)
		if instance.parameters.stopType == "ATR" then
			atr:update(core.UpdateLast)
		end

		-- Check that we have enough data
		if instance.parameters.stopType == "ATR" then
			if
				(atr.DATA:first() > (period - 1)) or (sEmaTrend.DATA:first() > (period - 1)) or
					(hlRange.DATA:first() > (period - 1))
			 then
				return
			end
		else
			if (sEmaTrend.DATA:first() > (period - 1)) or (hlRange.DATA:first() > (period - 1)) then
				return
			end
		end

		local trades = core.host:findTable("trades")
		local haveTrades = (trades:find("OfferID", Offer) ~= nil)

		if fEmaTrend.DATA[period] > sEmaTrend.DATA[period] then
			if instance.parameters.confirmWithChannel then
				if ohlc4T.DATA[period] > hlRange.high[period] then
					trendDirection = 1
				end
				if ohlc4T.DATA[period] < hlRange.high[period] then
					trendDirection = 0
				end
			else
				if ohlc4T.DATA[period] > fEmaTrend.DATA[period] then
					trendDirection = 1
				end
				if ohlc4T.DATA[period] < fEmaTrend.DATA[period] then
					trendDirection = 0
				end
			end
		end

		if fEmaTrend.DATA[period] < sEmaTrend.DATA[period] then
			if instance.parameters.confirmWithChannel then
				if ohlc4T.DATA[period] < hlRange.low[period] then
					trendDirection = -1
				end
				if ohlc4T.DATA[period] > hlRange.low[period] then
					trendDirection = 0
				end
			else
				if ohlc4T.DATA[period] < fEmaTrend.DATA[period] then
					trendDirection = -1
				end
				if ohlc4T.DATA[period] > fEmaTrend.DATA[period] then
					trendDirection = 0
				end
			end
		end

		if instance.parameters.enforceTrendBarDirection then
			if trendDirection == 1 then
				if trendSource.close[period] > trendSource.open[period] then
					waitEntry = false
				else
					waitEntry = true
				end
			else
				if trendDirection == -1 then
					if trendSource.open[period] > trendSource.close[period] then
						waitEntry = false
					else
						waitEntry = true
					end
				else
					waitEntry = false
				end
			end
		end

		if instance.parameters.stopType == "Channel" then
			stopB = (instance.ask[NOW] - hlRange.low[period]) / instance.ask:pipSize()
			stopS = (hlRange.high[period] - instance.bid[NOW]) / instance.bid:pipSize()
		else
			if instance.parameters.stopType == "ATR" then
				stopB = (instance.parameters.atrStopFactor * atr.DATA[period]) / instance.ask:pipSize()
			end
		end

		if (haveTrades) and instance.parameters.closeOnTrendCollapse then
			if core.crossesUnder(fEmaTrend.DATA, sEmaTrend.DATA, period) then
				-- if core.crossesUnder(ohlc4T.DATA, hlRange.high, period) then
				-- closeTrades = 1;
				closeAll("Trend collapsed")
			end
			if core.crossesOver(fEmaTrend.DATA, sEmaTrend.DATA, period) then
				-- if core.crossesOver(ohlc4T.DATA, hlRange.low, period) then
				-- closeTrades = -1;
				closeAll("Trend collapsed")
			end
		end
	end

	-- Conditions to check and execute if the entry period data (id 2102) is being returned
	if id == 2102 then
		fEmaEntry:update(core.UpdateLast)
		sEmaEntry:update(core.UpdateLast)
		ohlc4E:update(core.UpdateLast)
		hlRangeE:update(core.UpdateLast)

		-- Check that we have enough data
		if (sEmaEntry.DATA:first() > (period - 1)) then -- or (atr.DATA:first() > (period - 1)) then
			return
		end

		local MustOpenB = false
		local MustOpenS = false
		local pipSize = instance.bid:pipSize()

		------------- check for existing trades on this instrument
		local trades = core.host:findTable("trades")
		local haveTrades = (trades:find("OfferID", Offer) ~= nil)

		-- abort sequence if the wait for trend bar direction flag is set and no trades exist
		if waitEntry and not (haveTrades) then
			return
		end

		------------ Or aborts the remaining sequence if there is no trend
		if instance.parameters.confirmTrend then
			if trendDirection == 0 or trendDirection2 == 0 or trendDirection == -trendDirection2 then
				return
			end
		else
			if trendDirection == 0 then
				return
			end
		end
		-- end

		-------------- Put entry decision blocks here
		if
			trendDirection == 1 and
				(core.crossesOver(ohlc4E.DATA, fEmaEntry.DATA, period) or ohlc4E.DATA[period] > hlRangeE.high[period])
		 then
			MustOpenB = true
		end

		if
			trendDirection == -1 and
				(core.crossesUnder(ohlc4E.DATA, fEmaEntry.DATA, period) or ohlc4E.DATA[period] < hlRangeE.low[period])
		 then
			MustOpenS = true
		end
		-------------- end decision block

		-------------- Opening of trades happens here
		if (haveTrades) then
			local enum = trades:enumerator()
			while true do
				local row = enum:next()
				if row == nil then
					break
				end

				if row.AccountID == Account and row.OfferID == Offer then
					-- Close position if we have corresponding closing conditions.
					if row.BS == "B" then
						if MustOpenS then
							if ShowAlert then
								if instance.parameters.AllowDirection == "Long" then
									ExtSignal(source, period, "Close BUY", SoundFile, Email, RecurrentSound)
								else
									ExtSignal(source, period, "Close BUY and SELL", SoundFile, Email, RecurrentSound)
								end
							end

							if AllowTrade then
								Close(row)
								if instance.parameters.AllowDirection ~= "Long" then
									Open("S")
								end
							end
						end
					elseif row.BS == "S" then
						if MustOpenB then
							if ShowAlert then
								if instance.parameters.AllowDirection == "Short" then
									ExtSignal(source, period, "Close SELL", SoundFile, Email, RecurrentSound)
								else
									ExtSignal(source, period, "Close SELL and BUY", SoundFile, Email, RecurrentSound)
								end
							end
							if AllowTrade then
								Close(row)
								if instance.parameters.AllowDirection ~= "Short" then
									Open("B")
								end
							end
						end
					end
				end
			end
		else
			-- if there are no open trades, check the margin
			if instance.parameters.UseMarginCare then
				local account = core.host:findTable("accounts"):find("AccountID", Account)
				local MMR = core.host:execute("getTradingProperty", "MMR", instance.bid:instrument(), Account)
				local margin = account.UsableMargin
				if (MMR * Amount + (instance.parameters.marginPercent / 100) * MMR * Amount) > margin then
					-- Signal("Margin too tight to open position");
					return
				end
			end

			if instance.parameters.stopType == "Channel" then
				if MustOpenB == true then
					if
						(instance.parameters.SetMaxLoss == true and stopB < instance.parameters.Stop) or
							instance.parameters.SetMaxLoss == false
					 then
						-- Signal("Channel stop");
						Stop = stopB
					else
						-- Signal("Pip stop");
						Stop = instance.parameters.Stop
					end
				else
					if
						(instance.parameters.SetMaxLoss == true and stopS < instance.parameters.Stop) or
							instance.parameters.SetMaxLoss == false
					 then
						-- Signal("Channel stop");
						Stop = stopS
					else
						-- Signal("Pip stop");
						Stop = instance.parameters.Stop
					end
				end
			else
				if instance.parameters.stopType == "ATR" then
					if
						(instance.parameters.SetMaxLoss == true and stopB < instance.parameters.Stop) or
							instance.parameters.SetMaxLoss == false
					 then
						-- Signal("ATR stop");
						Stop = stopB
					else
						-- Signal("Pip stop");
						Stop = instance.parameters.Stop
					end
				else
					Stop = instance.parameters.Stop
				end
			end

			if MustOpenB == true and instance.parameters.AllowDirection ~= "Short" then
				if ShowAlert then
					ExtSignal(source, period, "BUY", SoundFile, Email, RecurrentSound)
				end

				if AllowTrade then
					Open("B")
				end
			end

			if MustOpenS == true and instance.parameters.AllowDirection ~= "Long" then
				if ShowAlert then
					ExtSignal(source, period, "SELL", SoundFile, Email, RecurrentSound)
				end

				if AllowTrade then
					Open("S")
				end
			end
		end
	end

	-- Conditions to check and execute if the trade management period data is being returned
	if id == 2103 then
		if period < trdMgmtSource:first() then
			return
		end

		if not (checkReady("trades")) or not (checkReady("orders")) then
			return
		end

		-- find the average position price
		local side, avgPrice, lots = findAvgPositionPrice()

		if avgPrice ~= nil then
			-- look for an existing Net Stop or Stop order
			local enum, row, trade
			enum = core.host:findTable("orders"):enumerator()
			row = enum:next()
			while (row ~= nil) do
				if row.OfferID == Offer and row.AccountID == Account and row.BS ~= side and row.Type == "SE" and row.NetQuantity then -- only identify the net stop order
					orderId = row.OrderID

					-- the following "if" block may seem counterintuitive,
					--    but remember that a sell net stop order corresponds to a buy trade
					if row.BS == "S" then
						if row.Rate > (avgPrice + (profitSum * source:pipSize())) then
							profitSum = (row.Rate - avgPrice) / source:pipSize()
						end
					else
						if row.Rate < (avgPrice - (profitSum * source:pipSize())) then
							profitSum = (avgPrice - row.Rate) / source:pipSize()
						end
					end
				end
				row = enum:next()
			end
		end

		local stopValue, valuemap, success, msg
		local stopSide

		-- debug
		-- terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "profitSum " .. profitSum, instance.bid:date(NOW));
		-- end debug
		if avgPrice ~= nil then
			if lots < Amount then
				-- sets the profitTaken flag in the case that the strategy is stopped after profit is taken
				--   and then restarted later
				profitTaken = true
			end
			if side == "B" then
				if instance.bid[NOW] > (avgPrice + ((profitSum + gap) * source:pipSize())) then
					stopValue = avgPrice + profitSum * source:pipSize()
					if instance.parameters.stopMoveAction == "Take Profit" and not (profitTaken) and Amount > 1 then
						Open("S")
						Signal("Profit Taken")
						profitTaken = true
					else
						if instance.parameters.stopMoveAction == "Add to Position" then
							Amount = instance.parameters.addPosLots
							Open("B")
							Signal("Adding to Position")
							Amount = instance.parameters.Amount
						end
					end
					profitSum = profitSum + Profit
				else
					return
				end

				stopSide = "S"
				if stopValue >= instance.bid[NOW] then
					return
				end
			else
				if instance.ask[NOW] < (avgPrice - ((profitSum + gap) * source:pipSize())) then
					stopValue = avgPrice - profitSum * source:pipSize()
					if instance.parameters.stopMoveAction == "Take Profit" and not (profitTaken) and Amount > 1 then
						Open("B")
						Signal("Profit Taken")
						profitTaken = true
					else
						if instance.parameters.stopMoveAction == "Add to Position" then
							Amount = instance.parameters.addPosLots
							Open("S")
							Signal("Adding to Position")
							Amount = instance.parameters.Amount
						end
					end
					profitSum = profitSum + Profit
				else
					return
				end
				stopSide = "B"
				if stopValue <= instance.ask[NOW] then
					return
				end
			end
			moveStop(stopValue, stopSide)
		else
			-- if there are no trades, then reset relevent variables
			profitSum = Profit
			profitTaken = false
		end
	end

	-- Conditions to check and execute if the second trend period data (id 2104) is being returned
	if id == 2104 then
		if instance.parameters.confirmTrend then
			fEmaTrend2:update(core.UpdateLast)
			sEmaTrend2:update(core.UpdateLast)
			hlRange2:update(core.UpdateLast)
			ohlc4T2:update(core.UpdateLast)
		end

		-- Check that we have enough data
		if (sEmaTrend2.DATA:first() > (period - 1)) or (hlRange2.DATA:first() > (period - 1)) then
			return
		end

		local trades = core.host:findTable("trades")
		local haveTrades = (trades:find("OfferID", Offer) ~= nil)

		if fEmaTrend2.DATA[period] > sEmaTrend2.DATA[period] then
			if ohlc4T2.DATA[period] > hlRange2.high[period] then
				trendDirection2 = 1
			end
			if ohlc4T2.DATA[period] < hlRange2.high[period] then
				trendDirection2 = 0
			end
		end

		if fEmaTrend2.DATA[period] < sEmaTrend2.DATA[period] then
			if ohlc4T2.DATA[period] < hlRange2.low[period] then
				trendDirection2 = -1
			end
			if ohlc4T2.DATA[period] > hlRange2.low[period] then
				trendDirection2 = 0
			end
		end

		if (haveTrades) then
			if core.crossesUnder(fEmaTrend2.DATA, sEmaTrend2.DATA, period) then
				-- closeTrades = 1;
				closeAll("Trend collapsed")
			end
			if core.crossesOver(fEmaTrend2.DATA, sEmaTrend2.DATA, period) then
				-- closeTrades = -1;
				closeAll("Trend collapsed")
			end
		end
	end
end

-- The strategy instance finalization.
function ReleaseInstance()
end

-- The method enters to the market
function Open(side)
	local valuemap
	local iAmount

	-- abort opening trades if trading is not allowed
	if not (instance.parameters.AllowTrade) then
		return
	end

	local trdSide, avgPrice, lots = findAvgPositionPrice()

	-- check to see if profit taking is enabled, has been taken, or trades exist
	if instance.parameters.stopMoveAction == "Take Profit" and not (profitTaken) and Amount > 1 and trdSide ~= nil then
		if lots >= Amount then
			iAmount = math.ceil(lots / 2)
		else
			-- if trades exist and profit has not been taken but the number of lots is less than the
			--    the strategy is asking for, then profit was taken before the strategy started
			profitTaken = true
			return
		end
	else
		iAmount = Amount
	end

	if instance.parameters.UseMarginCare then
		if trdSide == nil then -- if nil it means we are opening positions and need to check margin
			local account = core.host:findTable("accounts"):find("AccountID", Account)
			local MMR = core.host:execute("getTradingProperty", "MMR", instance.bid:instrument(), Account)
			local margin = account.UsableMargin
			if (MMR * iAmount + (instance.parameters.marginPercent / 100) * MMR * iAmount) > margin then
				-- Signal("Margin too tight to open position");
				return
			end
		end
	end

	valuemap = core.valuemap()
	valuemap.Command = "CreateOrder"
	valuemap.OrderType = "OM"
	valuemap.OfferID = Offer
	valuemap.AcctID = Account
	valuemap.Quantity = iAmount * BaseSize
	-- valuemap.CustomID = CID;
	valuemap.BuySell = side
	valuemap.QTXT = "1"
	-- if SetStop and CanClose then
	if SetStop then
		valuemap.PegTypeStop = "O"
		if side == "B" then
			valuemap.PegPriceOffsetPipsStop = -Stop
		else
			valuemap.PegPriceOffsetPipsStop = Stop
		end
		if TrailingStop then
			valuemap.TrailStepStop = 1
		end
	end
	-- if SetLimit and CanClose then
	if SetLimit then
		valuemap.PegTypeLimit = "O"
		if side == "B" then
			valuemap.PegPriceOffsetPipsLimit = Limit
		else
			valuemap.PegPriceOffsetPipsLimit = -Limit
		end
	end

	if not (CanClose) and (SetStop or SetLimit) then
		-- if regular s/l orders aren't allowed - create ELS order
		valuemap.EntryLimitStop = "Y"
	end

	success, msg = terminal:execute(200, valuemap)
	assert(success, msg)

	-- FIFO Account, in that case we have to open Net Limit and Stop Orders
	-- if not(CanClose) then
	-- if SetStop then
	-- valuemap = core.valuemap();
	-- valuemap.Command = "CreateOrder";
	-- valuemap.OrderType = "SE"
	-- valuemap.OfferID = Offer;
	-- valuemap.AcctID = Account;
	-- valuemap.NetQtyFlag = 'y';
	-- if side == "B" then
	-- valuemap.BuySell = "S";
	-- rate = instance.ask[NOW] - Stop * PipSize;
	-- valuemap.Rate = rate;
	-- elseif side == "S" then
	-- valuemap.BuySell = "B";
	-- rate = instance.bid[NOW] + Stop * PipSize;
	-- valuemap.Rate = rate;
	-- end
	-- if TrailingStop then
	-- valuemap.TrailUpdatePips = 1
	-- end
	-- success, msg = terminal:execute(200, valuemap);
	-- --core.host:trace('Set stop @ ' .. rate);
	-- assert(success, msg);
	-- end
	-- if SetLimit then
	-- valuemap = core.valuemap();
	-- valuemap.Command = "CreateOrder";
	-- valuemap.OrderType = "LE"
	-- valuemap.OfferID = Offer;
	-- valuemap.AcctID = Account;
	-- valuemap.NetQtyFlag = 'y';
	-- if side == "B" then
	-- valuemap.BuySell = "S";
	-- rate = instance.ask[NOW] + Limit * PipSize;
	-- valuemap.Rate = rate;
	-- elseif side == "S" then
	-- valuemap.BuySell = "B";
	-- rate = instance.bid[NOW] - Limit * PipSize;
	-- valuemap.Rate = rate;
	-- end
	-- success, msg = terminal:execute(200, valuemap);
	-- --core.host:trace('Set limit @ ' .. rate);
	-- assert(success, msg);
	-- end
	-- end
end

-- Closes specific position
function Close(trade)
	local valuemap
	valuemap = core.valuemap()

	if CanClose then
		-- non-FIFO account, create a close market order
		valuemap.OrderType = "CM"
		valuemap.TradeID = trade.TradeID
	else
		-- FIFO account, create an opposite market order
		valuemap.OrderType = "OM"
	end

	valuemap.OfferID = trade.OfferID
	valuemap.AcctID = trade.AccountID
	valuemap.Quantity = trade.Lot
	valuemap.CustomID = trade.QTXT
	if trade.BS == "B" then
		valuemap.BuySell = "S"
	else
		valuemap.BuySell = "B"
	end
	success, msg = terminal:execute(200, valuemap)
	assert(success, msg)
end

-------- code from BreakEven Strategy
function moveStop(rate, side)
	-- Check that order is stil exist
	local order = nil

	if orderId ~= nil then
		order = core.host:findTable("orders"):find("OrderID", orderId)
	end

	-- local trdSide, avgPrice, lots = findAvgPositionPrice();

	if order == nil then
		-- =======================================================================
		--                           CREATE NEW ORDER                           --
		-- =======================================================================

		valuemap = core.valuemap()
		valuemap.Command = "CreateOrder"
		valuemap.OfferID = Offer
		valuemap.Rate = rate
		valuemap.BuySell = side

		-- if CanClose then
		-- local trade = core.host:findTable("trades"):find("TradeID", tradeId);
		-- valuemap.OrderType = "S";
		-- valuemap.AcctID  = Account;
		-- valuemap.TradeID = trade.TradeID;
		-- valuemap.Quantity = trade.Lot;
		-- else
		valuemap.OrderType = "SE"
		valuemap.AcctID = Account
		valuemap.NetQtyFlag = "Y"
		-- end

		success, msg = terminal:execute(200, valuemap)
		if not (success) then
			terminal:alertMessage(
				instance.bid:instrument(),
				instance.bid[NOW],
				"Failed create stop " .. msg,
				instance.bid:date(NOW)
			)
		else
			requestId = core.parseCsv(msg)[0]
		end
	else
		-- =======================================================================
		--                      CHANGE EXISTING ORDER                           --
		-- =======================================================================
		if math.abs(rate - order.Rate) > minChange then
			-- stop exists
			valuemap = core.valuemap()
			valuemap.Command = "EditOrder"
			valuemap.AcctID = order.AccountID
			valuemap.OrderID = order.OrderID
			valuemap.Rate = rate

			success, msg = terminal:execute(200, valuemap)
			if not (success) then
				terminal:alertMessage(
					instance.bid:instrument(),
					instance.bid[NOW],
					"Failed change stop " .. msg,
					instance.bid:date(NOW)
				)
			end
		end
	end
end

function checkReady(table)
	return core.host:execute("isTableFilled", table)
end

function findAvgPositionPrice()
	if not (checkReady("trades")) then
		return
	end

	-- find average weighted price of all long and short positions on
	-- chosen instrument/amount
	local enum, row
	local longCount, shortCount
	local sumLongAmount, sumLongPrices
	local sumShortAmount, sumShortPrices

	longCount = 0
	sumLongAmount = 0
	sumLongPrices = 0

	shortCount = 0
	sumShortAmount = 0
	sumShortPrices = 0

	enum = core.host:findTable("trades"):enumerator()
	row = enum:next()
	while row ~= nil do
		if row.AccountID == Account and row.OfferID == Offer then
			if row.BS == "B" then
				sumLongAmount = sumLongAmount + row.Lot
				sumLongPrices = sumLongPrices + row.Lot * row.Open
				longCount = longCount + 1
			else
				sumShortAmount = sumShortAmount + row.Lot
				sumShortPrices = sumShortPrices + row.Lot * row.Open
				shortCount = shortCount + 1
			end
		end
		row = enum:next()
	end

	if longCount > 0 then
		return "B", sumLongPrices / sumLongAmount, sumLongAmount / BaseSize --requires BaseSize to be defined in Prepare();
	end

	if shortCount > 0 then
		return "S", sumShortPrices / sumShortAmount, sumShortAmount / BaseSize --requires BaseSize to be defined in Prepare();
	end
end

--Function for closing all open orders of the instrument for which the strategy is running
function closeAll(message)
	Signal(message)
	-- check whether trades exists on chosen instrument/account on buy or sell side
	-- if non-FIFO account - close them immediatelly.
	if not (checkReady("trades")) then
		Signal("Trades table not ready")
		return
	end

	local hasLong, hasShort
	local enum
	local row

	hasLong = false
	hasShort = false

	enum = core.host:findTable("trades"):enumerator()
	row = enum:next()

	--local canclose = false; ----************* forcing net closes

	while row ~= nil do
		if row.OfferID == Offer and row.AccountID == Account then
			if CanClose then
				-- close trades immediatelly if we can close
				local valuemap = core.valuemap()
				valuemap.Command = "CreateOrder"
				valuemap.OrderType = "CM"
				valuemap.OfferID = Offer
				valuemap.AcctID = Account
				valuemap.Quantity = row.Lot
				valuemap.TradeID = row.TradeID
				if row.BS == "B" then
					valuemap.BuySell = "S"
				else
					valuemap.BuySell = "B"
				end
				local success, msg = terminal:execute(103, valuemap)
				if not (success) then
					--terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "create order failed:" .. msg, instance.bid:date(NOW));
					Signal("Closing order creation failed " .. msg)
				else
					--terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "order created:" .. msg, instance.bid:date(NOW));
					Signal("Closing order created " .. msg)
				end
			else
				if row.BS == "B" then
					hasLong = true
				else
					hasShort = true
				end
			end
		end
		row = enum:next()
	end

	-- if trades exists but we cannot use per-trade CM order - close them
	-- using netting orders
	if hasLong then
		local valuemap = core.valuemap()
		valuemap.Command = "CreateOrder"
		valuemap.OrderType = "CM"
		valuemap.OfferID = Offer
		valuemap.AcctID = Account
		valuemap.NetQtyFlag = "Y"
		valuemap.BuySell = "S"

		local success, msg = terminal:execute(103, valuemap)
		if instance.parameters.LogOrders then
			if not (success) then
				--terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "net order create order failed:" .. msg, instance.bid:date(NOW));
				Signal("Failed to create net closing order " .. msg)
			else
				--terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "net order created:" .. msg, instance.bid:date(NOW));
				Signal("Net closing order created " .. msg)
			end
		end
	end

	if hasShort then
		local valuemap = core.valuemap()
		valuemap.Command = "CreateOrder"
		valuemap.OrderType = "CM"
		valuemap.OfferID = Offer
		valuemap.AcctID = Account
		valuemap.NetQtyFlag = "Y"
		valuemap.BuySell = "B"

		local success, msg = terminal:execute(100, valuemap)
		if instance.parameters.LogOrders then
			if not (success) then
				--terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "net order create order failed:" .. msg, instance.bid:date(NOW));
				Signal("Failed to create net closing order " .. msg)
			else
				--terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "net order created:" .. msg, instance.bid:date(NOW));
				Signal("Net closing order created " .. msg)
			end
		end
	end
end

-- This function generates a signal for the user.
function Signal(Label)
	if Label == nil then
		Label = ""
	end
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

function ExtAsyncOperationFinished(cookie, successful, message)
	if id == 200 or id == 100 then
		executing = false
		Stop = instance.parameters.Stop
		if not (success) then
			terminal:alertMessage(
				instance.bid:instrument(),
				instance.bid[NOW],
				"Failed create/change stop " .. message,
				instance.bid:date(NOW)
			)
		end
	end
	if not successful then
		core.host:trace("Error: " .. message)
	end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
