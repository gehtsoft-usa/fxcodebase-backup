
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=65091

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
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    strategy:name("Manual Trailing Stop");
    strategy:description("");

    strategy.parameters:addGroup("Trade");
    strategy.parameters:addString("Trade", "(non-FIFO) Choose Trade", "", "");
    strategy.parameters:setFlag("Trade", core.FLAG_TRADE);

    strategy.parameters:addGroup("Trailing Stop Parameters");
    strategy.parameters:addInteger("TPLevel1", "Trade Profit level1 (pips)", "", 20, 0.1, 1000);  
    strategy.parameters:addInteger("TPLevel2", "Trade Profit level2 (pips)", "", 20, 0.1, 1000);
    strategy.parameters:addInteger("TPLevel3", "Trade Profit level3 (pips)", "", 20, 0.1, 1000);
    strategy.parameters:addInteger("TPLevel4", "Trade Profit level4 (pips)", "", 20, 0.1, 1000);
    strategy.parameters:addInteger("TPLevel5", "Trade Profit level5 (pips)", "", 30, 0.1, 1000);  
end

local controller;

function CreateTrailingController()
    local controller = {};
    controller._profitLevels = {};
    controller._limit = nil;
    controller._stop = 0;
    controller._trade_id = nil;
    controller._executing = false;
    controller._cookie = 0;
    function controller:AddTrailing(level)
        if self._limit == nil then
            self._limit = level;
        end
        self._profitLevels[#self._profitLevels + 1] = level;
        return self;
    end
    function controller:SetTradeID(trade_id)
        self._trade_id = trade_id;
        return self;
    end
    function controller:DoCheck()
        local trade = core.host:findTable("trades"):find("TradeID", self._trade_id);
        if trade == nil or self._executing then
            return false;
        end
        DistTradeStop = core.host:execute("getTradingProperty", "conditionalDistanceStopForTrade", trade.Instrument);
        local offer = core.host:findTable("offers"):find("Instrument", trade.Instrument);
        local min_change = offer.PointSize;
        local stopValue = nil;
        if trade.BS == "B" then
            stopValue = trade.Open + self._stop;
            if stopValue > offer.Bid - DistTradeStop * min_change then
                stopValue = offer.Bid - (DistTradeStop - 1) * min_change;
            end

            if offer.Ask >= trade.Open + self._limit then
                if #self._profitLevels > 0 then
                    self._stop = self._stop + self._limit;
                    self._limit = self._limit + self._profitLevels[1];
                    table.remove(self._profitLevels, 1)
                else
                    self:closeTrade(trade);
                    return true;
                end
            else
                return true;
            end
          
            if stopValue >= offer.Bid then
                return true;
            end
        else
            stopValue = trade.Open - self._stop;
            if stopValue < offer.Ask + DistTradeStop * min_change then
                stopValue = offer.Ask + (DistTradeStop + 1) * min_change;
            end

            if offer.Bid <= trade.Open - self._limit then
                if #self._profitLevels > 0 then
                    self._stop = self._stop + self._limit;
                    self._limit = self._limit + self._profitLevels[1];
                    table.remove(self._profitLevels, 1)
                else
                    self:closeTrade(trade);
                    return true;
                end
            else
                return true;
            end

            if stopValue <= offer.Ask then
                return true;
            end
        end
        self:MoveStop(stopValue, trade);
        return true;
    end
    function controller:closeTrade(row)
        local valuemap, success, msg;
    
        valuemap = core.valuemap();
        valuemap.OrderType = "CM";
        valuemap.OfferID = row.OfferID;
        valuemap.AcctID = row.AccountID;
        valuemap.NetQtyFlag = "N";
        valuemap.TradeID = row.TradeID;
        valuemap.Quantity = row.Lot;
        valuemap.BuySell = row.BS == "B" and "S" or "B";
        success, msg = terminal:execute(101, valuemap);
        self._cookie = 101;
        self._executing = success;
    
        if not(success) then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        end
    end
    controller._request_id = nil;
    function controller:CreateStopOrder(stop_rate, trade)
        local valuemap = core.valuemap();
        valuemap.Command = "CreateOrder";
        valuemap.OfferID = trade.OfferID;
        valuemap.Rate = stop_rate;
        if trade.BS == "B" then
            valuemap.BuySell = "S";
        else
            valuemap.BuySell = "B";
        end
    
        local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
        if can_close then
            valuemap.OrderType = "S";
            valuemap.AcctID  = trade.AccountID;
            valuemap.TradeID = trade.TradeID;
            valuemap.Quantity = trade.Lot;
        else
            valuemap.OrderType = "SE"
            valuemap.AcctID  = trade.AccountID;
            valuemap.NetQtyFlag = "Y"
        end
    
        local success, msg = terminal:execute(200, valuemap);
        self._cookie = 200;
        self._executing = success;
        if not(success) then
            terminal:alertMessage(trade.Instrument, stop_rate, "Failed create stop " .. msg, core.now());
        else
            self._request_id = msg;
        end
    end
    
    function controller:ChangeStopOrder(stop_rate, order)
        local min_change = core.host:findTable("offers"):find("Instrument", order.Instrument).PointSize;
        if math.abs(stop_rate - order.Rate) > min_change then
            -- stop exists
            local valuemap = core.valuemap();
            valuemap.Command = "EditOrder";
            valuemap.AcctID  = order.AccountID;
            valuemap.OrderID = order.OrderID;
            valuemap.Rate = stop_rate;
    
            local success, msg = terminal:execute(201, valuemap);
            self._cookie = 201;
            self._executing = success;
            if not(success) then
                terminal:alertMessage(order.Instrument, stop_rate, "Failed change stop " .. msg, core.now());
            end
        end
    end
    
    function controller:IsStopOrderType(order_type)
        return order_type == "S" or order_type == "SE" or order_type == "ST" or order_type == "STE";
    end
    
    controller._used_stop_orders = {};
    function controller:FindStopOrder(trade)
        local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
        if can_close then
            local order_id;
            if trade.StopOrderID ~= nil and trade.StopOrderID ~= "" then
                order_id = trade.StopOrderID;
            elseif _request_id ~= nil then
                local order = core.host:findTable("orders"):find("RequestID", _request_id);
                if order ~= nil then
                    order_id = order.OrderID;
                    _request_id = nil;
                end
            end
    
            -- Check that order is stil exist
            if order_id ~= nil then
                return core.host:findTable("orders"):find("OrderID", order_id);
            end
        else
            local enum = core.host:findTable("orders"):enumerator();
            local row = enum:next();
            while (row ~= nil) do
                if row.ContingencyType == 3 and self:IsStopOrderType(row.Type) and self._used_stop_orders[row.OrderID] ~= true then
                    self._used_stop_orders[row.OrderID] = true;
                    return row;
                end
                row = enum:next();
            end
        end
        return nil;
    end
    
    function controller:MoveStop(stop_rate, trade)
        local order = self:FindStopOrder(trade);
        if order == nil then
            -- =======================================================================
            --                           CREATE NEW ORDER                           --
            -- =======================================================================
            self:CreateStopOrder(stop_rate, trade);
        else
            -- =======================================================================
            --                      CHANGE EXISTING ORDER                           --
            -- =======================================================================
            self:ChangeStopOrder(stop_rate, order);
        end
    end

    function controller:AsyncOperationFinished(cookie)
        if self._cookie == cookie then
            self._executing = false;
        end
    end
    return controller;
end

function Prepare(nameOnly)

    name = profile:id() .. "(" .. instance.bid:instrument()  .. "[" .. instance.parameters.Trade   .. "], " .. instance.parameters.TPLevel1 .. "," .. 
        instance.parameters.TPLevel2 .. "," .. instance.parameters.TPLevel3 .. "," .. instance.parameters.TPLevel4 .. ","  .. instance.parameters.TPLevel5 .. ")";

    local tradeId = instance.parameters.Trade   
    local trade = core.host:findTable("trades"):find("TradeID", tradeId);
    assert(trade ~= nil, "Trade can not be found")

    instance:name(name);
    if onlyName then
        return ;
    end 

    controller = CreateTrailingController();
    controller:SetTradeID(tradeId);
    for i = 1, 5 do
        controller:AddTrailing(instance.parameters:getInteger("TPLevel" .. i) * instance.bid:pipSize());
    end

    ExtSetupSignal(name .. ":", true);
    Source = ExtSubscribe(1, nil, "t1", true, "close");
end

function ExtUpdate(id, source, period)
    if id ~= 1 then
       return;
    end
    
    if not(checkReady("trades")) or not(checkReady("orders")) then
        return ;
    end

    if not controller:DoCheck() then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Trade " .. instance.parameters.Trade .. " disappear", instance.bid:date(NOW));
        core.host:execute("stop");
        return;
    end
end

function ExtAsyncOperationFinished(id, success, message)
    controller:AsyncOperationFinished(id);
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