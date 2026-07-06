--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

function Init()
    strategy:name(resources:get("R_Name"));
    strategy:description(resources:get("R_Description"));
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");

    strategy.parameters:addGroup(resources:get("R_ParamGroup"));

    strategy.parameters:addInteger("SN", resources:get("R_SN"), "", 5, 1, 200);
    strategy.parameters:addInteger("LN", resources:get("R_LN"), "", 34, 1, 200);
    strategy.parameters:addInteger("IN", resources:get("R_IN"), "", 5, 1, 200);

    strategy.parameters:addString("Type", resources:get("R_PriceType"), "", "Bid");
    strategy.parameters:addStringAlternative("Type", resources:get("R_Bid"), "", "Bid");
    strategy.parameters:addStringAlternative("Type", resources:get("R_Ask"), "", "Ask");

    strategy.parameters:addString("Period", resources:get("R_PeriodType"), "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);
	
    strategy.parameters:addGroup(resources:get("R_MACDStreamsGroup"));
    strategy.parameters:addString("MACDStream", resources:get("R_MACDStream"), "", "MACD");
    strategy.parameters:addStringAlternative("MACDStream", resources:get("R_MACD"), "", "MACD");
    strategy.parameters:addStringAlternative("MACDStream", resources:get("R_SIGNAL"), "", "SIGNAL");
    strategy.parameters:addStringAlternative("MACDStream", resources:get("R_HISTOGRAM"), "", "HISTOGRAM");

    strategy.parameters:addGroup(resources:get("R_TradeGroup"));
    	strategy.parameters:addBoolean("isNeedAutoTrading", "Allow strategy to trade", "", false);   
    strategy.parameters:setFlag("isNeedAutoTrading", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addInteger("tradeSize", resources:get("R_tradeSize"), "", 1, 1, 100);

    strategy.parameters:addGroup(resources:get("R_DivergenceGroup"));
    strategy.parameters:addBoolean("isNeedToConfirm", resources:get("R_isNeedToConfirm"), "", false);

    strategy.parameters:addGroup(resources:get("R_RiskManagementGroup"));
    strategy.parameters:addBoolean("isNeedRiskManagement", resources:get("R_isNeedRiskManagement"), "", false);
    strategy.parameters:addDouble("delta", resources:get("R_delta"), "", 0, 0.001, 1000);
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
    assert(instance.parameters.Period ~= "t1", resources:get("ERR_TICK"));
	
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
		idAccount = core.host:findTable("accounts"):enumerator():next().AccountID;
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
	terminal:alertMessage(gSource:instrument(), gSource[period], resources:get("R_Name") .. ":" .. resources:get("R_toSELL"), gSource:date(period));
	trade("S", period);
end

function toBUY(period)
	terminal:alertMessage(gSource:instrument(), gSource[period], resources:get("R_Name") .. ":" .. resources:get("R_toBUY"), gSource:date(period));
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

    local valuemap = core.valuemap();
	
    valuemap.Command = "CreateOrder";
    valuemap.OrderType = "OM"; -- true market order opens a position at any currently available market rate.
    valuemap.OfferID = idOffer;
    valuemap.AcctID = idAccount;
    valuemap.BuySell = type;
    valuemap.Quantity = tradeSize;
	
    local rc, reqID;
    rc, reqID = terminal:execute(id, valuemap);
	
    if rc == true and instance.parameters.isNeedRiskManagement then
        local trade = core.host:findTable("trades"):find("OpenOrderReqID", reqID);
		
        if trade ~= nil then
			valuemap = core.valuemap();
			
			valuemap.Command = "CreateOrder";
	        valuemap.OrderType = "L"; -- limit order is used for locking in profit of the existing position when the market condition is met.
	        valuemap.OfferID = idOffer;
	        valuemap.AcctID = idAccount;
	        valuemap.TradeID = trade.TradeID;
	        if trade.BS == "B" then -- order direction must be opposite to the direction of the order which was used to create the position 
				valuemap.BuySell = "S";
			else
				valuemap.BuySell = "B";
			end
	        valuemap.Quantity = trade.Lot;
			if valuemap.BuySell == "B" then -- rate must be below the market for buy orders and above the market for sell orders.
				valuemap.Rate = instance.ask[period] - instance.parameters.delta; -- be below the market for buy orders 
			else
				valuemap.Rate = instance.bid[period] + instance.parameters.delta; -- be above the market for sell orders
			end
	        terminal:execute(id, valuemap);
			
	        valuemap.OrderType = "S"; -- stop order is used for limiting losses of the existing position when the market condition is met.
			if valuemap.BuySell == "B" then -- rate must be above the market for buy orders and below the market for sell orders.
				valuemap.Rate = instance.ask[period] + instance.parameters.delta; -- be above the market for buy orders
			else
				valuemap.Rate = instance.bid[period] - instance.parameters.delta; -- be below the market for sell orders 
			end
	        terminal:execute(id, valuemap);
        end
    end
end

function AsyncOperationFinished(cookie, success, message)
	loading = false;
end
