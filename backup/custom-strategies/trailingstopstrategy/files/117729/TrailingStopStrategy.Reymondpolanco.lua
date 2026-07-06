-- Id: 21414
-- Id: 21605
-- Id: 20704
-- Id: 20552

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
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function AddLevel(index)
    strategy.parameters:addInteger("PipsTPLevel" .. index, "Trade Profit level " .. index .. " (pips)", "", index * 10, 0.1, 1000); 
    strategy.parameters:addDouble("TPLevel" .. index, "Trade Profit level " .. index .. " (rate)", "", 0);  
    strategy.parameters:setFlag("TPLevel" .. index, core.FLAG_PRICE);
    strategy.parameters:addBoolean("IsInPipsTPLevel" .. index, "Use Profit level " .. index .. " in pips", "", false);
    strategy.parameters:addInteger("PipsTPTarget" .. index, "Trade Profit Target " .. index .. " (pips)", "", index * 10 - 10, 0.1, 1000); 
end

function Init()
    strategy:name("Manual Trailing Stop (absolute rate)");
    strategy:description("");

    strategy.parameters:addGroup("Trade");
    strategy.parameters:addString("Trade", "(non-FIFO) Choose Trade", "", "");
    strategy.parameters:setFlag("Trade", core.FLAG_TRADE);
    
    strategy.parameters:addGroup("Order");
    strategy.parameters:addString("Order", "(non-FIFO) Choose Order", "", "");
    strategy.parameters:setFlag("Order", core.FLAG_ORDER);
    
    strategy.parameters:addGroup("Selector");
    strategy.parameters:addString("Selector", "Selector", "", "Trade");
    strategy.parameters:addStringAlternative("Selector", "Order", "", "Order");
    strategy.parameters:addStringAlternative("Selector", "Trade", "", "Trade");

    strategy.parameters:addGroup("Trailing Stop Parameters");
    AddLevel(1);
    AddLevel(2);
    AddLevel(3);
    AddLevel(4);
    AddLevel(5);
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
    function controller:AddTrailing(when, stop)
        core.host:trace("New stop " .. stop .. " when " .. when);
        if when == 0 then
            return self;
        end
        local level = { };
        level.When = when;
        level.Stop = stop;
        self._profitLevels[#self._profitLevels + 1] = level;
        return self;
    end
    function controller:SetTradeID(trade_id)
        self._trade_id = trade_id;
        return self;
    end
    function controller:IsSetTradeID()
        return self._trade_id ~= nil;
    end
    function controller:GetMinLevel()
        local index;
        local minLevel;
        for i, level in ipairs(self._profitLevels) do
            if minLevel == nil or minLevel.When > level.When then
                index = i;
                minLevel = level;
            end
        end
        return minLevel, index;
    end
    function controller:GetMaxLevel()
        local index;
        local maxLevel;
        for i, level in ipairs(self._profitLevels) do
            if maxLevel == nil or maxLevel.When < level.When then
                index = i;
                maxLevel = level;
            end
        end
        return maxLevel, index;
    end
    function controller:RemoveLevel(index)
        table.remove(self._profitLevels, index);
    end
    function controller:DoCheck()
        local trade = core.host:findTable("trades"):find("TradeID", self._trade_id);
        if trade == nil then
            return false;
        end
        if self._executing then
            return true;
        end
        DistTradeStop = core.host:execute("getTradingProperty", "conditionalDistanceStopForTrade", trade.Instrument);
        local offer = core.host:findTable("offers"):find("Instrument", trade.Instrument);
        local min_change = offer.PointSize;
        if trade.BS == "B" then
            local level, index = self:GetMinLevel();
            if level == nil then
                return true;
            end
            if offer.Ask >= level.When then
                if #self._profitLevels > 0 then
                    table.remove(self._profitLevels, index)
                else
                    self:closeTrade(trade);
                    return true;
                end
            else
                return true;
            end
          
            if level.Stop >= offer.Bid then
                return true;
            end
            core.host:trace("Moving stop to ".. level.Stop);
            self:MoveStop(level.Stop, trade);
        else
            local level, index = self:GetMaxLevel();
            if level == nil then
                return true;
            end
            if offer.Bid <= level.When then
                if #self._profitLevels > 0 then
                    table.remove(self._profitLevels, index)
                else
                    self:closeTrade(trade);
                    return true;
                end
            else
                return true;
            end

            if level.Stop <= offer.Ask then
                return true;
            end
            core.host:trace("Moving stop to ".. level.Stop);
            self:MoveStop(level.Stop, trade);
        end
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
    local id = ""
    if instance.parameters.Selector == "Trade" then
        id = instance.parameters.Trade;
    else
        id = instance.parameters.Order;
    end
    
    local TPLevel1 = not instance.parameters:getBoolean("IsInPipsTPLevel1") and instance.parameters.TPLevel1 or instance.parameters.PipsTPLevel1;
    local TPLevel2 = not instance.parameters:getBoolean("IsInPipsTPLevel2") and instance.parameters.TPLevel2 or instance.parameters.PipsTPLevel2;
    local TPLevel3 = not instance.parameters:getBoolean("IsInPipsTPLevel3") and instance.parameters.TPLevel3 or instance.parameters.PipsTPLevel3;
    local TPLevel4 = not instance.parameters:getBoolean("IsInPipsTPLevel4") and instance.parameters.TPLevel4 or instance.parameters.PipsTPLevel4;
    local TPLevel5 = not instance.parameters:getBoolean("IsInPipsTPLevel5") and instance.parameters.TPLevel5 or instance.parameters.PipsTPLevel5;
        
    name = profile:id() .. "(" .. instance.bid:instrument()  .. "[" .. id  .. "], " .. TPLevel1 .. "," .. TPLevel2 .. "," .. 
        TPLevel3 .. "," .. TPLevel4 .. "," .. TPLevel5 .. ")";

    instance:name(name);
    if onlyName then
        return ;
    end 
   
    controller = CreateTrailingController();
    
    local tradeId = instance.parameters.Trade;
    local trade = nil;
    if instance.parameters.Selector == "Trade" then
        trade = core.host:findTable("trades"):find("TradeID", tradeId);
        assert(trade ~= nil, "Trade can not be found")
        
        controller:SetTradeID(tradeId);  
        initTPLevels(trade);    
    else
       core.host:execute("subscribeTradeEvents", 1001, "trades");
    end
    
    ExtSetupSignal(name .. ":", true);
    Source = ExtSubscribe(1, nil, "t1", true, "close");
end

function initTPLevels(trade)
    for i = 1, 5 do
        local isInPips = instance.parameters:getBoolean("IsInPipsTPLevel" .. i);
                
        local rate = 0;
        if not isInPips then
            rate = instance.parameters:getDouble("TPLevel" .. i);
        else
            rate = trade.Open + instance.parameters:getInteger("PipsTPLevel" .. i) * instance.bid:pipSize();
        end
        if trade.BS == "B" then
            local stop = trade.Open + instance.parameters:getInteger("PipsTPTarget" .. i) * instance.bid:pipSize();
            controller:AddTrailing(rate, stop);
        else
            local stop = trade.Open - instance.parameters:getInteger("PipsTPTarget" .. i) * instance.bid:pipSize();
            controller:AddTrailing(rate, stop);
        end
    end
end
    
function ExtUpdate(id, source, period)
    if id ~= 1 then
       return;
    end
    
    if not(checkReady("trades")) or not(checkReady("orders")) then
        return ;
    end

    if controller:IsSetTradeID() then
        if not controller:DoCheck() then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Trade " .. instance.parameters.Trade .. " disappear", instance.bid:date(NOW));
            core.host:execute("stop");
            return;
        end
    end
end

function ExtAsyncOperationFinished(id, success, message, message1)
    controller:AsyncOperationFinished(id);
    if id == 200 then
        if not(success) then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed create/change stop " .. message , instance.bid:date(NOW));
        end
    elseif id == 1001 then
        if not controller:IsSetTradeID() and message1 == instance.parameters.Order then        
            local tradeID = message;
            controller:SetTradeID(tradeID);
            trade = core.host:findTable("trades"):find("TradeID", tradeID);  
            initTPLevels(trade);   
        end
    end
end

function checkReady(table)
    return core.host:execute("isTableFilled", table);
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");