--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+


function Init()
    strategy:name("Divergence on MACD Signals (extended edition)");
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
    strategy.parameters:addInteger("tradeSize", "Trade Size (in lots)", "", 1, 1, 1000);
    strategy.parameters:addDouble("margin", "Low Margin (%)", "If the margin of the account is below specified percent then the trade position will not open.", 0);
	
    strategy.parameters:addGroup("Profit/Loss care");
    strategy.parameters:addBoolean("isNeedPLCare", "Is need to perform gross profit/loss care?", "", false);
    strategy.parameters:addDouble("profit", "Max Profit", "Locking profit for account at desired value.", 0);
    strategy.parameters:addDouble("loss", "Min Loss", "Limiting losses for account at desired value.", 0);

    strategy.parameters:addGroup("Risk management");
    strategy.parameters:addBoolean("isNeedRiskManagement", "Is need to perform risks management?", "", false);
    strategy.parameters:addDouble("delta", "Delta of price movement", "", 0, 0, 1000);
    strategy.parameters:addInteger("trailingStop", "Trailing stop (in pips)", "", 0, 0, 1000);
end

local MACD, MACDDATA;
local gSource = nil;
local lastSerial = -1;
local id = 1;
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
	
	local margin = (account.UsableMargin / account.Equity) * 100;
	if margin <= instance.parameters.margin then
		return;
	end
	
    local valuemap = core.valuemap();
	
    valuemap.Command = "CreateOrder";
    valuemap.OrderType = "OM"; -- True market order opens a position at any currently available market rate.
    valuemap.OfferID = idOffer;
    valuemap.AcctID = idAccount;
    valuemap.BuySell = type;
    valuemap.Quantity = tradeSize;
	
    local rc, reqID;
    rc, reqID = terminal:execute(id, valuemap);
	
    if rc == true then
		local trade = core.host:findTable("trades"):find("OpenOrderReqID", reqID);
		if trade == nil then
			return;
		end
		
		valuemap = core.valuemap();
			
		valuemap.Command = "CreateOrder";
		valuemap.OfferID = idOffer;
		valuemap.AcctID = idAccount;
		valuemap.TradeID = trade.TradeID;
		valuemap.BuySell = (trade.BS == "B" and "S" or "B"); -- order direction must be opposite to the direction of the order which was used to create the position 
		valuemap.Quantity = trade.Lot;
		
	    if instance.parameters.isNeedPLCare then
			local GrossPL = account.GrossPL;
			if GrossPL > instance.parameters.profit or GrossPL < instance.parameters.loss then
			        valuemap.OrderType = "CM"; -- True market close order closes a position at any currently available market rate.
					terminal:execute(id, valuemap);
			end
		end
		
	    if instance.parameters.isNeedRiskManagement then
			valuemap.OrderType = "L"; -- Limit order is used for locking in profit of the existing position when the market condition is met.
			valuemap.Rate = (valuemap.BuySell == "B" and -- rate must be below the market for buy orders and above the market for sell orders.
							instance.ask[period] - instance.parameters.delta or -- be below the market for buy orders 
							instance.bid[period] + instance.parameters.delta);  -- be above the market for sell orders
			terminal:execute(id, valuemap);
			
			valuemap.OrderType = "S"; -- Stop order is used for limiting losses of the existing position when the market condition is met.
			valuemap.Rate = (valuemap.BuySell == "B" and -- rate must be above the market for buy orders and below the market for sell orders.
							instance.ask[period] + instance.parameters.delta or -- be above the market for buy orders
							instance.bid[period] - instance.parameters.delta);  -- be below the market for sell orders 
			valuemap.TrailUpdatePips = instance.parameters.trailingStop;
			terminal:execute(id, valuemap);
	    end
    end
end

function AsyncOperationFinished(cookie, success, message)
	loading = false;
end
