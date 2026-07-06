-- Id: 2628
-- More information about this indicator can be found at:
-- http://fxcodebase.com

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
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

function Init()
    strategy:name("Divergence on MACD Signals (improved edition)");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Signals BUY when MACD detects trend up and SELL when MACD detects trend down.");

    strategy.parameters:addGroup("MACD Parameters");

    strategy.parameters:addInteger("SN", "Short EMA periods", "", 5, 1, 200);
    strategy.parameters:addInteger("LN", "Long EMA periods", "", 34, 1, 200);
    strategy.parameters:addInteger("IN", "Signal line periods", "", 5, 1, 200);

    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addString("Period", "Period size", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);
	
	strategy.parameters:addString("PriceStream", "Price stream", "", "C");
    strategy.parameters:addStringAlternative("PriceStream", "Open", "", "O");
    strategy.parameters:addStringAlternative("PriceStream", "Close", "", "C");
    strategy.parameters:addStringAlternative("PriceStream", "High", "", "H");
    strategy.parameters:addStringAlternative("PriceStream", "Low", "", "L");
    strategy.parameters:addStringAlternative("PriceStream", "Typical", "", "T");
    strategy.parameters:addStringAlternative("PriceStream", "Median", "", "M");
    strategy.parameters:addStringAlternative("PriceStream", "Weighted", "", "W");
    strategy.parameters:addStringAlternative("PriceStream", "Volume", "", "V");

    strategy.parameters:addGroup("MACD Streams");
    strategy.parameters:addString("MACDStream", "Choice stream of MACD indicator", "", "MACD");
    strategy.parameters:addStringAlternative("MACDStream", "MACD", "", "MACD");
    strategy.parameters:addStringAlternative("MACDStream", "SIGNAL", "", "SIGNAL");
    strategy.parameters:addStringAlternative("MACDStream", "HISTOGRAM", "", "HISTOGRAM");

    strategy.parameters:addGroup("Divergence");
    strategy.parameters:addBoolean("isNeedToConfirm", "Is need to take into account Hide divergence?", "The hide divergence may be signal to confirm trends moving.", false);

	strategy.parameters:addGroup("Trading");
	strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addBoolean("isNeedAutoTrading", "Is need to use autotrading?", "In case NO the only ordinary signals will be produced.", false);
    strategy.parameters:addString("Account", " Account", "Choice of the account", "");
	strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("tradeSize", " Trade Size (lots)", "", 1, 1, 10000);
	
    strategy.parameters:addGroup("Margin care");
    strategy.parameters:addBoolean("isNeedMarginCare", "Is need to perform margin care?", "", false);
    strategy.parameters:addDouble("margin", " Low Margin (%)", "If the margin of the account is below specified percent then the trade positions will not open.", 0);
	
    strategy.parameters:addGroup("Profit/Loss care");
    strategy.parameters:addBoolean("isNeedPLCare", "Is need to perform gross profit/loss care?", "In case YES the trade positions will not open when " .. 
																								 "locking or limiting actions have been happen.", false);
	
    strategy.parameters:addDouble("profit", " Max Profit", "Locking profit for account at desired value.", 0);
    strategy.parameters:addDouble("loss", " Min Loss", "Limiting losses for account at desired value.", 0);

    strategy.parameters:addGroup("Risk management");
    strategy.parameters:addBoolean("isNeedRiskManagement", "Is need to perform risks management?", "", false);
    strategy.parameters:addBoolean("isNeedLimit", " Use limit?", "", false);
    strategy.parameters:addDouble("limit", "   Limit of price movement (pips)", "", 5.1, 5.1, 1000);
    strategy.parameters:addBoolean("isNeedStop", " Use stop?", "", false);
    strategy.parameters:addDouble("stop", "   Stop of price movement (pips)", "", 5.1, 5.1, 1000);
    strategy.parameters:addBoolean("isNeedTrailing", "   Use trailing?", "", false);
    strategy.parameters:addBoolean("isNeedDynamicTrailing", "     Dynamic trailing mode", "", false);
    strategy.parameters:addInteger("trailingStop", "     Fixed trailing stop (pips)", "", 10, 10, 300);

    strategy.parameters:addGroup("Log orders");
    strategy.parameters:addBoolean("isNeedLogOrders", "Is need to perform logging of orders creation?", "", false);

    strategy.parameters:addGroup("Positions monitor");
    strategy.parameters:addBoolean("isNeedMonitorPositions", "Is need to monitoring trade positions?", "", false);
    strategy.parameters:addString("Email", " E-mail address", "Note that to recieve e-mails, SMTP settings must be defined (see Trading Station Strategies Options).", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
    strategy.parameters:addBoolean("isNeedOpenPositions", " Watch for Open positions?", "", false);
    strategy.parameters:addBoolean("isNeedClosePositions", " Watch for Closed positions?", "", false);
    strategy.parameters:addBoolean("isNeedProfitPositions", "   Report profit positions?", "", true);
    strategy.parameters:addBoolean("isNeedLossPositions", "   Report loss positions?", "", true);

    strategy.parameters:addGroup("Strategy version");
    strategy.parameters:addString("Version", "dMACDext version 2.3", "", "");
end

local MACD, MACDDATA;
local gSource = nil;
local lastSerial = -1;
local id = 1;
local idOM = 2;
local idLE = 3;
local idSE = 4;
local first;
local loading = false;
local source;
local idOffer;
local idAccount;
local tradeSize;
local canLimitStop;
local pipSize;
local currentBS = "";
local isTrueHost = true;
local timer = nil;
local idTimer = 100;
local timeFormat = "%02i:%02i";
local plFormat = "%.2f";
local aOpenPs = {};
local history_aOpenPs = {};
local aClosePs = {};
local history_aClosePs = {};
local processingCollect = false;
local processingReport = false;

function Prepare()
    assert(instance.parameters.Period ~= "t1", "The strategy can't be applied on the tick data.");
	
	loading = true;

	source = core.host:execute("getHistory", id, instance.bid:instrument(), instance.parameters.Period, 0, 0, instance.parameters.Type == "Bid");
	
	if instance.parameters.PriceStream == "O" then
		gSource = source.open;
	elseif instance.parameters.PriceStream == "C" then
		gSource = source.close;
	elseif instance.parameters.PriceStream == "H" then
		gSource = source.high;
	elseif instance.parameters.PriceStream == "L" then
		gSource = source.low;
	elseif instance.parameters.PriceStream == "T" then
		gSource = source.typical;
	elseif instance.parameters.PriceStream == "M" then
		gSource = source.median;
	elseif instance.parameters.PriceStream == "W" then
		gSource = source.weighted;
	elseif instance.parameters.PriceStream == "V" then
		gSource = source.volume;
	end

    MACD = core.indicators:create("MACD", gSource, instance.parameters.SN, instance.parameters.LN, instance.parameters.IN);

	local idStream;
	
	if instance.parameters.MACDStream == "MACD" then
		idStream = 0;
	elseif instance.parameters.MACDStream == "SIGNAL" then
		idStream = 1;
	elseif instance.parameters.MACDStream == "HISTOGRAM" then
		idStream = 2;
	end
	
    MACDDATA = MACD:getStream(idStream);  

	first = MACDDATA:first();

	if instance.parameters.isNeedAutoTrading then
		idOffer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;
		idAccount = instance.parameters.Account;
		tradeSize = instance.parameters.tradeSize * core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), idAccount);
		
		canLimitStop = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), idAccount);
		pipSize = instance.bid:pipSize();
	end
	
	isTrueHost = (string.find(string.lower(core.host:version()), "marketscope") ~= nil and true or false);
	
	if instance.parameters.isNeedMonitorPositions then
		timer = core.host:execute("setTimer", idTimer, 1);
	end
end

function ReleaseInstance() 
	if timer ~= nil then
		core.host:execute("killTimer", timer);
	end
end

function Update()
	if loading == true or not instance.parameters.AllowTrade then
		return;
	end
	
	MACD:update(core.UpdateLast);
	
	local size = gSource:size();
	
	if size > 1 then
		local serial = gSource:serial(size - 1);

		if serial ~= lastSerial then
			local period = size - 2;
			local hasData = MACDDATA:hasData(period);
			
			if period >= first and hasData then
	            checkTrendDown(period); -- to SELL
	            checkTrendUp(period); -- to BUY
				
				lastSerial = serial;
			end
		end
	end
end

function checkTrendDown(period) -- Check trend down
    if isPeak(period) then
        local curr = period;
        local prev = prevPeak(period);
		
		local trueDivergence = false;
		local hideDivergence = false;
		
        if prev ~= nil then
			if source.high[curr] > source.high[prev] and MACDDATA[curr] < MACDDATA[prev] then -- True divergence (turn trend down)
				trueDivergence = true;
			end
			
			if source.high[curr] < source.high[prev] and MACDDATA[curr] > MACDDATA[prev] then -- Hide divergence (confirmation down trend)
				hideDivergence = true;
			end
			
			if trueDivergence or (instance.parameters.isNeedToConfirm and hideDivergence) then
				toSELL(period);
			end
        end
    end
end

function checkTrendUp(period) -- Check trend up
    if isTrough(period) then
        local curr = period;
        local prev = prevTrough(period);
		
		local trueDivergence = false;
		local hideDivergence = false;
		
        if prev ~= nil then
			if source.low[curr] < source.low[prev] and MACDDATA[curr] > MACDDATA[prev] then -- True divergence (turn trend up)
				trueDivergence = true;
			end
			
			if source.low[curr] > source.low[prev] and MACDDATA[curr] < MACDDATA[prev] then -- Hide divergence (confirmation up trend)
				hideDivergence = true;
			end
			
			if trueDivergence or (instance.parameters.isNeedToConfirm and hideDivergence) then
				toBUY(period);
			end
        end
    end
end

function toSELL(period)
	terminal:alertMessage(gSource:instrument(), gSource[period], "Divergence on MACD Signals" .. ":" .. "to SELL", gSource:date(period));
	trade("S");
end

function toBUY(period)
	terminal:alertMessage(gSource:instrument(), gSource[period], "Divergence on MACD Signals" .. ":" .. "to BUY", gSource:date(period));
	trade("B");
end

function isPeak(period)
    local i;

    if MACDDATA[period] > 0 and MACDDATA[period] > MACDDATA[period - 1] and MACDDATA[period] > MACDDATA[period + 1] then
        for i = period - 1, first, -1 do
            if MACDDATA[i] < 0 then
                return true;
            elseif MACDDATA[period] < MACDDATA[i] then
                return false;
            end
        end
    end

    return false;
end

function isTrough(period)
    local i;

    if MACDDATA[period] < 0 and MACDDATA[period] < MACDDATA[period - 1] and MACDDATA[period] < MACDDATA[period + 1] then
        for i = period - 1, first, -1 do
            if MACDDATA[i] > 0 then
                return true;
            elseif MACDDATA[period] > MACDDATA[i] then
                return false;
            end
        end
    end

    return false;
end

function prevPeak(period)
    local i;

    for i = period - 5, first, -1 do
        if MACDDATA[i] >= MACDDATA[i - 1] and MACDDATA[i] > MACDDATA[i - 2] and
           MACDDATA[i] >= MACDDATA[i + 1] and MACDDATA[i] > MACDDATA[i + 2] then
           return i;
        end
    end

    return nil;
end

function prevTrough(period)
    local i;

    for i = period - 5, first, -1 do
        if MACDDATA[i] <= MACDDATA[i - 1] and MACDDATA[i] < MACDDATA[i - 2] and
           MACDDATA[i] <= MACDDATA[i + 1] and MACDDATA[i] < MACDDATA[i + 2] then
           return i;
        end
    end

    return nil;
end

function trade(type)
	if not instance.parameters.isNeedAutoTrading then
		return;
	end

	local account = core.host:findTable("accounts"):find("AccountID", instance.parameters.Account);
	
	if instance.parameters.isNeedMarginCare then
		local margin = (account.UsableMargin / account.Equity) * 100;
		if margin <= instance.parameters.margin then
			return;
		end
	end
	
    if instance.parameters.isNeedPLCare then
		local GrossPL = account.GrossPL;
		if GrossPL > instance.parameters.profit or GrossPL < instance.parameters.loss then
			return;
		end
	end

    local valuemap = core.valuemap();
	
    valuemap.Command = "CreateOrder";
    valuemap.OrderType = "OM"; -- True market order opens a position at any currently available market rate.
    valuemap.OfferID = idOffer;
    valuemap.AcctID = idAccount;
    valuemap.BuySell = type;
    valuemap.Quantity = tradeSize;
	
	if instance.parameters.isNeedRiskManagement and canLimitStop then
		if instance.parameters.isNeedLimit then
	        valuemap.PegTypeLimit = "M";
	        valuemap.PegPriceOffsetPipsLimit = (valuemap.BuySell == "B" and instance.parameters.limit or -instance.parameters.limit);
		end
		
		if instance.parameters.isNeedStop then
	        valuemap.PegTypeStop = "M";
	        valuemap.PegPriceOffsetPipsStop = (valuemap.BuySell == "B" and -instance.parameters.stop or instance.parameters.stop);
		end
		
		if instance.parameters.isNeedTrailing then
			if instance.parameters.isNeedDynamicTrailing then
				valuemap.TrailStepStop = 1;
			else
				valuemap.TrailStepStop = instance.parameters.trailingStop;
			end
		end
	end

	if instance.parameters.isNeedRiskManagement and not canLimitStop then
		currentBS = valuemap.BuySell;
	end
	
    local success, msg;
    success, msg = terminal:execute(idOM, valuemap);

	if instance.parameters.isNeedLogOrders then
	    if success then
	        terminal:alertMessage("", 0, "TrueMarketOrder request is sent. OpenOrderReqID=" .. msg, core.now());
		else
	        terminal:alertMessage("", 0, "Send TrueMarketOrder to server failed! '" .. msg .. "'", core.now());
	    end
    end
end

function NettingSL(type)
	if instance.parameters.isNeedLimit then
		makeSL("LE", (type == "B" and "S" or "B"), instance.parameters.limit, 0);
	end
	
	if instance.parameters.isNeedStop then
		local trailingStop;
		
		if instance.parameters.isNeedTrailing then
			if instance.parameters.isNeedDynamicTrailing then
				trailingStop = 1;
			else
				trailingStop = instance.parameters.trailingStop;
			end
		else
			trailingStop = 0;
		end

		makeSL("SE", (type == "B" and "S" or "B"), instance.parameters.stop, trailingStop);
	end
end

function makeSL(orderType, side, unit, trailing)
	local rate;

	if side == "B" then
		rate = instance.ask[NOW] + (orderType == "LE" and -unit * pipSize or unit * pipSize);
	else
		rate = instance.bid[NOW] + (orderType == "LE" and unit * pipSize or -unit * pipSize);
	end

    local enum, row;
	
    enum = core.host:findTable("orders"):enumerator();
    row = enum:next();
	
    local valuemap = core.valuemap();
	
    while row ~= nil do
        if row.NetQuantity and
           row.Type == orderType and
           row.BS == side and
           row.OfferID == idOffer and
           row.AccountID == idAccount then
		   
		    if row.FixStatus == "W" then -- try to change existing netting
				if row.Rate == rate then -- do not change order for the same rate
					if instance.parameters.isNeedLogOrders then
						local order = (orderType == "LE" and "EntryLimitOrder" or "EntryStopOrder");
						
						terminal:alertMessage("", 0, "Change of " .. order .. " was skipped (order with the same Rate already exists)", core.now());
					end
						
					return;
				end
				
			    valuemap.Command = "EditOrder";
			    valuemap.OrderID = row.OrderID;
			    valuemap.AcctID = idAccount;
				
				if instance.parameters.isNeedLogOrders then
					local order = (orderType == "LE" and "EntryLimitOrder" or "EntryStopOrder");
					
					terminal:alertMessage("", 0, order .. " will be changed (from old Rate=" .. row.Rate .. " to new Rate=" .. rate .. ")", core.now());
				end
				
				if not isTrueHost then
					if side == "B" then
						rate = (orderType == "LE" and -unit or unit);
					else
						rate = (orderType == "LE" and unit or -unit);
					end
				end
				
			    valuemap.Rate = rate;
				if trailing ~= 0 then
					valuemap.TrailUpdatePips = trailing;
				end
				
			    local success, msg;
			    success, msg = terminal:execute((orderType == "LE" and idLE or idSE), valuemap);
				
				if instance.parameters.isNeedLogOrders then
					local order = (orderType == "LE" and "EntryLimitOrder" or "EntryStopOrder");
					
				    if success then
				        terminal:alertMessage("", 0, order .. " request is sent. OpenOrderReqID=" .. msg, core.now());
					else
				        terminal:alertMessage("", 0, "Send " .. order .. " to server failed! '" .. msg .. "'", core.now());
				    end
			    end
				
	            return;
				
			else
				if instance.parameters.isNeedLogOrders then
					local order = (orderType == "LE" and "EntryLimitOrder" or "EntryStopOrder");
					
					terminal:alertMessage("", 0, "Send " .. order .. " to server was skipped (the same order already exists and in work)", core.now());
				end
				
	            return;
			end
        end
		
        row = enum:next();
    end

    valuemap.Command = "CreateOrder";
    valuemap.OrderType = orderType;
    valuemap.OfferID = idOffer;
    valuemap.AcctID = idAccount;
    valuemap.NetQtyFlag = "y";
    valuemap.BuySell = side;
	
    valuemap.Rate = rate;
    if trailing ~= 0 then
        valuemap.TrailUpdatePips = trailing;
    end

    local success, msg;
    success, msg = terminal:execute((orderType == "LE" and idLE or idSE), valuemap);

	if instance.parameters.isNeedLogOrders then
		local order = (orderType == "LE" and "EntryLimitOrder" or "EntryStopOrder");
		
	    if success then
	        terminal:alertMessage("", 0, order .. " request is sent. OpenOrderReqID=" .. msg, core.now());
		else
	        terminal:alertMessage("", 0, "Send " .. order .. " to server failed! '" .. msg .. "'", core.now());
	    end
    end
end

function AsyncOperationFinished(cookie, successful, info)
	if cookie == id then
		loading = false;
		
	elseif cookie == idOM then
		if successful then
			if instance.parameters.isNeedLogOrders then
				terminal:alertMessage("", 0, "TrueMarketOrder is successfully opened. OpenOrderID=" .. info, core.now());
			end
			
			if instance.parameters.isNeedRiskManagement and not canLimitStop then
				if not isPresentInverseTrades(currentBS) then
					NettingSL(currentBS);
				else
					--[[ 
						In case (for FIFO accounts) current (newcomer) TrueMarketOrder with inverse direction 
						will close previous (opended) position for the same currence pair and 
						that newcomer trade also disappears, so do not need netting for nothing.
					--]]
					if instance.parameters.isNeedLogOrders then
						terminal:alertMessage("", 0, "Newcomer TrueMarketOrder has closed trade position and disappeared, so nothing to netting.", core.now());
					end
				end
			end
		else
			if instance.parameters.isNeedLogOrders then
				terminal:alertMessage("", 0, "Processing TrueMarketOrder on server failed! '" .. info .. "'", core.now());
			end
		end
		
	elseif cookie == idLE or cookie == idSE then
		if instance.parameters.isNeedLogOrders then
			local order = (cookie == idLE and "EntryLimitOrder" or "EntryStopOrder");
			
			if successful then
				terminal:alertMessage("", 0, order .. " is successfully " .. (info == "" and "changed" or "opened. OpenOrderID=" .. info), core.now());
			else
				terminal:alertMessage("", 0, "Processing " .. order .. " on server failed! '" .. info .. "'", core.now());
			end
		end
		
	elseif cookie == idTimer then
		collectPositions();
		reportPositions();
		
	end
end

function isPresentInverseTrades(currentBS)
	local inverseBS = (currentBS == "B" and "S" or "B");
	local isPresentInverseTrades = false;
	
    local enum, row;
	
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
	
    while row ~= nil do
        if row.BS == inverseBS and
           row.OfferID == idOffer and
           row.AccountID == idAccount then
		   
		   isPresentInverseTrades = true;
		   break;
        end
		
        row = enum:next();
    end
	
	return isPresentInverseTrades;
end

function collectPositions()
	if processingCollect then 
		return;
	end;	
	
	processingCollect = true;
	
	local enum, row, ctime, ttime, stime;
	local msg = "";
	local offer, precision;
	
	-- Process open positions.
	if instance.parameters.isNeedOpenPositions then
		enum = core.host:findTable("trades"):enumerator();
		
		while true do
			row = enum:next();
			
			if row == nil then
				break;
			end
			
			if row.AccountID == idAccount and row.OfferID == idOffer then
				ctime = core.host:execute("convertTime", 1, 3, row.Time);
				ttime = core.dateToTable(ctime);
				stime = string.format(timeFormat, ttime.hour, ttime.min);
				
				offer = core.host:findTable("offers"):find("OfferID", row.OfferID);
				precision = offer.Digits;
				
				msg =   row.AmountK .. "; " .. 
						round(row.Open, "%." .. precision .. "f") .. "; " .. 
						(row.IsBuy == true and "Buy" or "Sell") .. "; " .. 
						stime .. 
						"\013\010";
				
				putMessage(aOpenPs, msg);
			end
		end
	end
	
	-- Process close positions.
	if instance.parameters.isNeedClosePositions then
		enum = core.host:findTable("closed trades"):enumerator();
		
		while true do
			row = enum:next();
			
			if row == nil then
				break;
			end
			
			if row.AccountID == idAccount and row.OfferID == idOffer then
				ctime = core.host:execute("convertTime", 1, 3, row.CloseTime);
				ttime = core.dateToTable(ctime);
				stime = string.format(timeFormat, ttime.hour, ttime.min);
				
				offer = core.host:findTable("offers"):find("OfferID", row.OfferID);
				precision = offer.Digits;
				
				msg = 	row.AmountK .. "; " .. 
						round(row.Close, "%." .. precision .. "f") .. "; " .. 
						(row.BS == "B" and "Buy" or "Sell") .. "; " .. 
						round(row.PL, plFormat) .. "; " .. 
						stime .. 
						"\013\010";
				
				if row.PL > 0 then 
					if instance.parameters.isNeedProfitPositions then
						putMessage(aClosePs, msg);
					end
				else
					if instance.parameters.isNeedLossPositions then
						putMessage(aClosePs, msg);
					end
				end
			end
		end
	end
	
	processingCollect = false;
end

function round(value, format)
	return string.format(format, value);
end

function putMessage(inputArray, inputMessage)
	local index = 1; 
	local isNeedToInsert = true;
	
	-- Do not insert the same message twice.
	-- Check it in input array and if presents then set flag.
	while index <= #inputArray do
		if inputArray[index] == inputMessage then
			isNeedToInsert = false;
			break;
		end
		
		index = index + 1;
	end
	
	-- If need to insert message then add it to input array.
	if isNeedToInsert then
		inputArray[#inputArray + 1] = inputMessage;
	end
end

function reportPositions()
	if processingReport then 
		return;
	end;	
	
	processingReport = true;
	
	local enum, row, ctime, ttime, stime;
	local msg = "";
	local msgOpenPositions = "";
	local msgClosePositions = "";
	
	-- Report open positions.
	msgOpenPositions = getMessages(aOpenPs, history_aOpenPs);
	
	-- Report close positions.
	msgClosePositions = getMessages(aClosePs, history_aClosePs);
	
	local scope = "";
	if not (instance.parameters.isNeedProfitPositions and instance.parameters.isNeedLossPositions) then
		if instance.parameters.isNeedProfitPositions then
			scope = " (profit only)";
		end
		if instance.parameters.isNeedLossPositions then
			scope = " (loss only)";
		end
	end
	
	msg = (msgOpenPositions ~= "" and "Open Positions:\013\010(AmountK; PriceOpen; B/S; Time)\013\010" .. msgOpenPositions .. "\013\010 \013\010" or "") .. 
		  (msgClosePositions ~= "" and "Closed Positions" .. scope .. ":\013\010(AmountK; PriceClose; B/S; P/L; Time)\013\010" .. msgClosePositions .. "\013\010" or "");
	
	if msg ~= "" then
		if instance.parameters.Email ~= "" then
			terminal:alertEmail(instance.parameters.Email, "dMACDext: Account ".. idAccount .. ", Instrument " .. instance.bid:instrument(), msg);
		end
	end
	
	processingReport = false;
end

function getMessages(inputArray, historyArray)
	local index, history_index;
	local outputMessage = "";
	
	-- Do not output the same message twice.
	-- Check it in history array and if presents then remove it from current input array.
	history_index = 1;
	while history_index <= #historyArray do
		index = 1;
		while index <= #inputArray do
			if inputArray[index] == historyArray[history_index] then
				table.remove(inputArray, index);
				break;
			end
			
			index = index + 1;
		end
		
		history_index = history_index + 1;
	end
	
	-- Make output message from current input array.
	-- Put added message to history array and revome it from input array after processing.
	while #inputArray > 0 do
		outputMessage = outputMessage .. inputArray[1];
		
		table.insert(historyArray, inputArray[1]);
		table.remove(inputArray, 1);
	end
	
	return outputMessage;
end
