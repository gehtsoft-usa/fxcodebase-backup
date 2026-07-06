--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

function Init()
    strategy:name("Divergence on MACD Signals (improved edition)");
    strategy:description("Signals BUY when MACD detects trend up and SELL when MACD detects trend down.");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");

    strategy.parameters:addGroup("Parameters");

    strategy.parameters:addInteger("SN", "Short EMA periods", "", 5, 1, 200);
    strategy.parameters:addInteger("LN", "Long EMA periods", "", 34, 1, 200);
    strategy.parameters:addInteger("IN", "Signal line periods", "", 5, 1, 200);

    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addString("Period", "Period size", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);
	
    strategy.parameters:addGroup("MACD streams");
    strategy.parameters:addString("MACDStream", "Choice stream of MACD indicator", "", "MACD");
    strategy.parameters:addStringAlternative("MACDStream", "MACD", "", "MACD");
    strategy.parameters:addStringAlternative("MACDStream", "SIGNAL", "", "SIGNAL");
    strategy.parameters:addStringAlternative("MACDStream", "HISTOGRAM", "", "HISTOGRAM");

    strategy.parameters:addGroup("Divergence");
    strategy.parameters:addBoolean("isNeedToConfirm", "Is need to confirm trends moving?", "", false);

    strategy.parameters:addGroup("Trade");
   	strategy.parameters:addBoolean("isNeedAutoTrading", "Allow strategy to trade", "", false);   
    strategy.parameters:setFlag("isNeedAutoTrading", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("Account", "Account", "Choice of the account", "");
	strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("tradeSize", "Trade Size (in lots)", "", 1, 1, 10000);
	
    strategy.parameters:addGroup("Margin care");
    strategy.parameters:addBoolean("isNeedMarginCare", "Is need to perform margin care?", "", false);
    strategy.parameters:addDouble("margin", "Low Margin (%)", "If the margin of the account is below specified percent then the trade positions will not open.", 0);
	
    strategy.parameters:addGroup("Profit/Loss care");
    strategy.parameters:addBoolean("isNeedPLCare", "Is need to perform gross profit/loss care?", "In case YES the trade positions will not open when " .. 
																								 "locking or limiting actions have been happen.", false);
	
    strategy.parameters:addDouble("profit", "Max Profit", "Locking profit for account at desired value.", 0);
    strategy.parameters:addDouble("loss", "Min Loss", "Limiting losses for account at desired value.", 0);

    strategy.parameters:addGroup("Risk management");
    strategy.parameters:addBoolean("isNeedRiskManagement", "Is need to perform risks management?", "", false);
    strategy.parameters:addDouble("limit", "Limit of price movement (delta)", "If the value is 0, that means no-limit order.", 0, 0, 10000);
    strategy.parameters:addDouble("stop", "Stop of price movement (delta)", "If the value is 0, that means no-stop order.", 0, 0, 10000);
    strategy.parameters:addInteger("trailingStop", "Trailing stop (pips)", "If the value is 1, that means that the dynamic trailing mode is used, " .. 
																		   "i.e. the order rate is changed with every change of the market price. " ..
																		   "If the value is 0, that means no-trailing order.", 1, 0, 10000);
end

local MACD, MACDDATA;
local gSource = nil;
local lastSerial = -1;
local id = 1;
local idOM = 2;
local idCM = 3;
local first;
local loading = false;
local source;
local idInstument;
local idAccount;
local tradeSize;

function Prepare()
    assert(instance.parameters.Period ~= "t1", "The signal can't be applied on the tick data.");
	
	loading = true;

	source = core.host:execute("getHistory", id, instance.bid:instrument(), instance.parameters.Period, 0, 0, instance.parameters.Type == "Bid");
	gSource = source.close;
	
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
	end
end

function Update()
	if loading == true then
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
	trade("S", period);
end

function toBUY(period)
	terminal:alertMessage(gSource:instrument(), gSource[period], "Divergence on MACD Signals" .. ":" .. "to BUY", gSource:date(period));
	trade("B", period);
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

function trade(type, period)
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

	if instance.parameters.isNeedRiskManagement then
		if instance.parameters.limit ~= 0 then
			valuemap.RateLimit = (valuemap.BuySell == "B" and -- The limit order must be above the trade price for the position created using a buy order (long position) and
															  -- below the trade price for the position created using a sell order (short position).
								instance.ask[period] + instance.parameters.limit or -- be above the trade price for the Buy order (long position) 
								instance.bid[period] - instance.parameters.limit);  -- be below the trade price for the Sell order (short position)
		end
		
		if instance.parameters.stop ~= 0 then
			valuemap.RateStop = (valuemap.BuySell == "B" and -- The stop order must be below the trade price for the position created using a buy order (long position) and 
															 --  above the trade price for the position created using a sell order (short position).
								instance.ask[period] - instance.parameters.stop or -- be below the trade price for the Buy order (long position) 
								instance.bid[period] + instance.parameters.stop);  -- be above the trade price for the Sell order (short position)
		end
		valuemap.TrailStepStop = instance.parameters.trailingStop;
	end
	
    local success, msg;
    success, msg = terminal:execute(idOM, valuemap);

    if not success then
        terminal:alertMessage("", 0, "Create order failed! '" .. msg .. "'", core.now());
    end
end

function AsyncOperationFinished(cookie, successful, info)
	if cookie == id then
		loading = false;
	end
end
