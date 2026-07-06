-- Id: 21554
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=31&t=66196


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

function Init()
    strategy:name("ATR Trailing Stop Strategy");
    strategy:description("");

    strategy.parameters:addGroup("Trade");
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("Trade", "(non-FIFO) Choose Trade", "", "");
    strategy.parameters:setFlag("Trade", core.FLAG_TRADE);

    strategy.parameters:addGroup("Trailing Stop Parameters");    
    strategy.parameters:addString("Indicator", "Indicator", "", "ATR");
    strategy.parameters:setFlag("Indicator",core.FLAG_INDICATOR);	
    strategy.parameters:addDouble("IndicatorMultiplier", "IndicatorMultiplier", "", 1, -10, 10);	
    
    strategy.parameters:addGroup("Price Parameters");    
    strategy.parameters:addString("TF", "TF", "Time frame ('t1', 'm1', 'm5', etc.)", "m5");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);

    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
end

local Account;
local Offer;
local CanClose;

local orderId
local tradeId
local requestId

local minChange;
local DistTradeStop;
local Indicator;
local IndicatorMultiplier;
local preStopValue = 0;
 
function Prepare(nameOnly)

    name = profile:id() .. "(" .. instance.bid:instrument()  .. "[" .. instance.parameters.Trade   .. "], " .. instance.parameters.Indicator .. "," .. 
        instance.parameters.IndicatorMultiplier .. ")";

    tradeId = instance.parameters.Trade;
    local trade = core.host:findTable("trades"):find("TradeID", tradeId);
    assert(trade ~= nil, "Trade can not be found")

    Account = trade.AccountID
    Offer   = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;
    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)    
    DistTradeStop = core.host:execute("getTradingProperty", "conditionalDistanceStopForTrade", instance.bid:instrument());
    IndicatorMultiplier = instance.parameters.IndicatorMultiplier; 
    minChange = math.pow(10, -instance.bid:getPrecision());
    
    instance:name(name);
    if onlyName then
        return ;
    end 
    
    Source = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar");     
        
    local tmpprofile = core.indicators:findIndicator(instance.parameters:getString("Indicator"));
    local tmpparams = instance.parameters:getCustomParameters("Indicator");
    Indicator = tmpprofile:createInstance(Source, tmpparams);
    first = Indicator.DATA:first();    
end

function ExtUpdate(id, source, period)
    if not instnace.parameters.AllowTrade then
        return;
    end
    Indicator:update(core.UpdateLast);
    
    if id ~= 1 then
	   return;
	end
	
	if period < first  then
	   return;
	end	
	
	if not(checkReady("trades")) or not(checkReady("orders")) then
        return ;
    end

    local trade, order; 
    trade = core.host:findTable("trades"):find("TradeID", tradeId);
    
    if isTradeExist(trade) == false then
        return;
    end 
		
    if requestId ~= nil then
        order = core.host:findTable("orders"):find("RequestID", requestId);
        if order ~= nil then
            orderId = order.OrderID
            requestId = nil
        end
    end

    local stopValue = 0;
    if trade.BS == "B"  then
        --stopValue = instance.bid[NOW] - IndicatorMultiplier * Indicator.DATA[period];
        stopValue = IndicatorMultiplier * Indicator.DATA[period];
        stopSide = "S";
    else            
        --stopValue = instance.ask[NOW] +  IndicatorMultiplier * Indicator.DATA[period];
        stopValue = IndicatorMultiplier * Indicator.DATA[period];
        stopSide = "B";
    end
         
    if preStopValue ~= stopValue then
        moveStop(stopValue, stopSide)
        preStopValue = stopValue;
    end
end

function isTradeExist(trade)
    if trade == nil then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Trade " .. instance.parameters.Trade .. " disappear", instance.bid:date(NOW));
        core.host:execute("stop");
        return false;
    end
    
    return true;
end 

function moveStop(rate, side)
    -- Check that order is stil exist
    local order = nil

    if orderId ~= nil then
        order = core.host:findTable("orders"):find("OrderID", orderId);
    end


    if order == nil then
        -- =======================================================================
        --                           CREATE NEW ORDER                           --
        -- =======================================================================

        valuemap = core.valuemap();
        valuemap.Command = "CreateOrder";
        valuemap.OfferID = Offer;
        valuemap.Rate = rate;
        valuemap.BuySell = side;

        local trade = core.host:findTable("trades"):find("TradeID", tradeId);        
        if CanClose then
            valuemap.OrderType = "S";
            valuemap.AcctID  = trade.AccountID;
            valuemap.TradeID = trade.TradeID;
            valuemap.Quantity = trade.Lot;
        else
            valuemap.OrderType = "SE"
            valuemap.AcctID  = trade.AccountID;
            valuemap.NetQtyFlag = "Y"
        end
        

        success, msg = terminal:execute(200, valuemap);
        if not(success) then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed create stop " .. msg, instance.bid:date(NOW));
        else
            requestId = core.parseCsv(msg)[0]
        end
    else
        -- =======================================================================
        --                      CHANGE EXISTING ORDER                           --
        -- =======================================================================
        if math.abs(rate - order.Rate) > minChange then
            -- stop exists
            valuemap = core.valuemap();
            valuemap.Command = "EditOrder";
            valuemap.AcctID  = order.AccountID;
            valuemap.OrderID = order.OrderID;
            valuemap.Rate = rate;
            
            success, msg = terminal:execute(200, valuemap);
            if not(success) then
                terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed change stop " .. msg, instance.bid:date(NOW));
            end
        end
    end
end

function ExtAsyncOperationFinished(id, success, message)
    if id == 200 then
        if not(success) then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed create/change stop " .. message , instance.bid:date(NOW));
        end
    end
end

function checkReady(table)
    return core.host:execute("isTableFilled", table);
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");