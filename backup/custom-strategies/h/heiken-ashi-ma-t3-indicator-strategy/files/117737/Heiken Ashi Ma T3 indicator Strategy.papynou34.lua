-- Id: 20559
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=65489

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

function Init() --The strategy profile initialization
    strategy:name("Heiken Ashi Ma T3 indicator Strategy");
    strategy:description("");
    
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");
    
    strategy.parameters:addGroup("Price");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
    
    strategy.parameters:addString("TF", "Time frame", "", "m1");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);
    

    strategy.parameters:addGroup("Calculation");
    strategy.parameters:addInteger("MA_Period", "Ma period", "", 10);
    strategy.parameters:addString("MA_Method", "MA method", "", "MVA");
    strategy.parameters:addStringAlternative("MA_Method", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("MA_Method", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("MA_Method", "KAMA", "", "KAMA");
    strategy.parameters:addStringAlternative("MA_Method", "Wilder", "", "Wilder");
    strategy.parameters:addStringAlternative("MA_Method", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("MA_Method", "SineWMA", "", "SineWMA");
    strategy.parameters:addStringAlternative("MA_Method", "TriMA", "", "TriMA");
    strategy.parameters:addStringAlternative("MA_Method", "LSMA", "", "LSMA");
    strategy.parameters:addStringAlternative("MA_Method", "SMMA", "", "SMMA");
    strategy.parameters:addStringAlternative("MA_Method", "HMA", "", "HMA");
    strategy.parameters:addStringAlternative("MA_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    strategy.parameters:addStringAlternative("MA_Method", "DEMA", "", "DEMA");
    strategy.parameters:addStringAlternative("MA_Method", "T3", "", "T3");
    strategy.parameters:addStringAlternative("MA_Method", "ITrend", "", "ITrend");
    strategy.parameters:addStringAlternative("MA_Method", "Median", "", "Median");
    strategy.parameters:addStringAlternative("MA_Method", "GeoMean", "", "GeoMean");
    strategy.parameters:addStringAlternative("MA_Method", "REMA", "", "REMA");
    strategy.parameters:addStringAlternative("MA_Method", "ILRS", "", "ILRS");
    strategy.parameters:addStringAlternative("MA_Method", "IE/2", "", "IE/2");
    strategy.parameters:addStringAlternative("MA_Method", "TriMAgen", "", "TriMAgen");
    strategy.parameters:addStringAlternative("MA_Method", "JSmooth", "", "JSmooth");
    strategy.parameters:addInteger("Step", "Step", "", 1);
    strategy.parameters:addBoolean("UseT3", "Use T3", "", true);
    strategy.parameters:addDouble("b", "b", "", 0.88);
   
    CreateTradingParameters();
end

function CreateTradingParameters()
    strategy.parameters:addGroup("Execution Parameters");

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);   
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    
     strategy.parameters:addString("AccountType", "Account Type", "", "Automatic");
    strategy.parameters:addStringAlternative("AccountType", "FIFO", "", "FIFO");
    strategy.parameters:addStringAlternative("AccountType", "non FIFO", "", "NON");
    strategy.parameters:addStringAlternative("AccountType", "Automatic", "", "Automatic");
  
    strategy.parameters:addString("EntryExecutionType", "Entry Execution Type", "", "Live");
    strategy.parameters:addStringAlternative("EntryExecutionType", "End of Turn", "", "EndOfTurn");
    strategy.parameters:addStringAlternative("EntryExecutionType", "Live", "", "Live");    
 
    strategy.parameters:addGroup("Trade Parameters");
    
    strategy.parameters:addBoolean("CloseOnOpposite", "Close On Opposite", "", true);
    strategy.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "HAMAT3IS");
    
    strategy.parameters:addBoolean("PositionCap", "Use Position Cap", "", false);
    
    strategy.parameters:addInteger("MaxNumberOfPositionInAnyDirection", "Max Number Of Open Position In Any Direction", "", 2);
    strategy.parameters:addInteger("MaxNumberOfPosition", "Max Number Of Position In One Direction", "", 1);
        
    strategy.parameters:addString("ALLOWEDSIDE", "Allowed side", "Allowed side for trading or signaling, can be Sell, Buy or Both", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell");
    
    strategy.parameters:addString("Direction", "Type of Signal / Trade", "", "direct");
    strategy.parameters:addStringAlternative("Direction", "Direct", "", "direct");
    strategy.parameters:addStringAlternative("Direction", "Reverse", "", "reverse");

    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000);
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false);
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30);
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false);
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30);
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false);
    strategy.parameters:addDouble("close_partial_amount", "Close % of Position", "Use 0 to disable", 50);
    strategy.parameters:addDouble("close_partial_profit", "Profit Target for Partial Close, pips", "", 10);
    strategy.parameters:addDouble("breakeven_to", "Breakeven To, in pips", "", 0);
    
    strategy.parameters:addGroup("Alerts");
    strategy.parameters:addBoolean("ShowAlert", "ShowAlert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", true);
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", false);
    strategy.parameters:addString("Email", "Email", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
    
     strategy.parameters:addGroup("Time Parameters");
     
    strategy.parameters:addInteger("ToTime", "Convert the date to", "", 6);
    strategy.parameters:addIntegerAlternative("ToTime", "EST", "", 1);
    strategy.parameters:addIntegerAlternative("ToTime", "UTC", "", 2);
    strategy.parameters:addIntegerAlternative("ToTime", "Local", "", 3);
    strategy.parameters:addIntegerAlternative("ToTime", "Server", "", 4);
    strategy.parameters:addIntegerAlternative("ToTime", "Financial", "", 5);
    strategy.parameters:addIntegerAlternative("ToTime", "Display", "", 6);
    
    strategy.parameters:addString("StartTime", "Start Time for Trading", "", "00:00:00");
    strategy.parameters:addString("StopTime", "Stop Time for Trading", "", "24:00:00");
 
    strategy.parameters:addBoolean("UseMandatoryClosing", "Use Mandatory Closing", "", false);
    strategy.parameters:addString("ExitTime", "Mandatory Closing  Time", "", "23:59:00");
    strategy.parameters:addInteger("ValidInterval", "Valid interval for operation in second", "", 60);
end

local Modules = {};
trading = {};
trading.Name = "Trading";
trading.Version = "2.7.0";
trading.Debug = false;
trading.AddAmountParameter = true;
trading.AddStopParameter = true;
trading.AddLimitParameter = true;
trading.CustomID = nil;
trading._ids_start = nil;
trading._signaler = nil;
trading._allow_trade = false;
trading._account = nil;
trading._amount = 1;
trading._all_modules = {};
trading._limit = nil;
trading._stop = nil;
trading._trailing_stop = nil;
trading._request_id = {};
trading._waiting_requests = {};
trading._used_stop_orders = {};
trading._used_limit_orders = {};
function trading:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function trading:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end

function trading:Init(parameters)
end

function trading:Prepare(name_only)
end

function trading:OnNewModule(module)
    if module.Name == "Signaler" then self._signaler = module; end
    self._all_modules[#self._all_modules + 1] = module;
end

function trading:AsyncOperationFinished(cookie, success, message, message1, message2)
    local res = self._waiting_requests[cookie];
    if res ~= nil then
        res.Finished = true;
        res.Success = success;
        res.Error = not success and message or nil;
        if not success then
            self:trace(string.format("Failed request %s", tostring(message)));
        end
        self._waiting_requests[cookie] = nil;
    elseif cookie == self._order_update_id then
        for _, order in ipairs(self._monitored_orders) do
            if order.RequestID == message2 then
                order.FixStatus = message1;
            end
        end
    elseif cookie == self._ids_start + 2 then
        if not success then
            if self._signaler ~= nil then
                self._signaler:Signal("Close order failed: " .. message);
            else
                self:trace("Close order failed: " .. message);
            end
        end
    end
end

function trading:calculateAmount()
    return self._amount;
end

function trading:getOppositeSide(side) if side == "B" then return "S"; end return "B"; end

function trading:getId()
    for id = self._ids_start, self._ids_start + 100 do
        if self._waiting_requests[id] == nil then return id; end
    end
    return self._ids_start;
end

function trading:CreateStopOrder(stop_rate, trade, trailing)
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
        valuemap.TrailUpdatePips = trailing;
    else
        valuemap.OrderType = "SE"
        valuemap.AcctID  = trade.AccountID;
        valuemap.NetQtyFlag = "Y"
    end

    local id = self:getId();
    local success, msg = terminal:execute(id, valuemap);
    if not(success) then
        local message = "Failed create stop " .. msg;
        self:trace(message);
        if self._signaler ~= nil then
            self._signaler:Signal(message);
        end
        local res = {};
        res.Finished = true;
        res.Success = false;
        res.Error = message;
        return res;
    end
    local res = {};
    res.Finished = false;
    res.RequestID = msg;
    self._waiting_requests[id] = res;
    self._request_id[trade.TradeID] = msg;
    return res;
end

function trading:CreateLimitOrder(limit_rate, trade)
    local valuemap = core.valuemap();
    valuemap.Command = "CreateOrder";
    valuemap.OfferID = trade.OfferID;
    valuemap.Rate = limit_rate;
    if trade.BS == "B" then
        valuemap.BuySell = "S";
    else
        valuemap.BuySell = "B";
    end
    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        valuemap.OrderType = "L";
        valuemap.AcctID  = trade.AccountID;
        valuemap.TradeID = trade.TradeID;
        valuemap.Quantity = trade.Lot;
    else
        valuemap.OrderType = "LE"
        valuemap.AcctID  = trade.AccountID;
        valuemap.NetQtyFlag = "Y"
    end
    local success, msg = terminal:execute(200, valuemap);
    if not(success) then
        terminal:alertMessage(trade.Instrument, limit_rate, "Failed create limit " .. msg, core.now());
    else
        self._request_id[trade.TradeID] = msg;
    end
end

function trading:ChangeOrder(rate, order)
    local min_change = core.host:findTable("offers"):find("Instrument", order.Instrument).PointSize;
    if math.abs(rate - order.Rate) > min_change then
        self:trace(string.format("Changing an order to %s", tostring(rate)));
        -- stop exists
        local valuemap = core.valuemap();
        valuemap.Command = "EditOrder";
        valuemap.AcctID  = order.AccountID;
        valuemap.OrderID = order.OrderID;
        valuemap.TrailUpdatePips = order.TrlMinMove ~= 0 and order.TrlMinMove or nil;
        valuemap.Rate = rate;
        local id = self:getId();
        local success, msg = terminal:execute(id, valuemap);
        if not(success) then
            local message = "Failed change order " .. msg;
            self:trace(message);
            if self._signaler ~= nil then
                self._signaler:Signal(message);
            end
            local res = {};
            res.Finished = true;
            res.Success = false;
            res.Error = message;
            return res;
        end
        local res = {};
        res.Finished = false;
        res.RequestID = msg;
        self._waiting_requests[id] = res;
        return res;
    end
    local res = {};
    res.Finished = true;
    res.Success = true;
    return res;
end

function trading:IsLimitOrderType(order_type) return order_type == "L" or order_type == "LE" or order_type == "LT" or order_type == "LTE"; end

function trading:IsStopOrderType(order_type) return order_type == "S" or order_type == "SE" or order_type == "ST" or order_type == "STE"; end

function trading:FindLimitOrder(trade)
    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        local order_id;
        if trade.LimitOrderID ~= nil and trade.LimitOrderID ~= "" then
            order_id = trade.LimitOrderID;
            self:trace("Using limit order id from the trade");
        elseif self._request_id[trade.TradeID] ~= nil then
            self:trace("Searching limit order by request id: " .. tostring(self._request_id[trade.TradeID]));
            local order = core.host:findTable("orders"):find("RequestID", self._request_id[trade.TradeID]);
            if order ~= nil then
                order_id = order.OrderID;
                self._request_id[trade.TradeID] = nil;
            end
        end
        -- Check that order is stil exist
        if order_id ~= nil then return core.host:findTable("orders"):find("OrderID", order_id); end
    else
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if row.ContingencyType == 3 and IsLimitOrderType(row.Type) and self._used_limit_orders[row.OrderID] ~= true then
                self._used_limit_orders[row.OrderID] = true;
                return row;
            end
            row = enum:next();
        end
    end
    return nil;
end

function trading:FindStopOrder(trade)
    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        local order_id;
        if trade.StopOrderID ~= nil and trade.StopOrderID ~= "" then
            order_id = trade.StopOrderID;
            self:trace("Using stop order id from the trade");
        elseif self._request_id[trade.TradeID] ~= nil then
            self:trace("Searching stop order by request id: " .. tostring(self._request_id[trade.TradeID]));
            local order = core.host:findTable("orders"):find("RequestID", self._request_id[trade.TradeID]);
            if order ~= nil then
                order_id = order.OrderID;
                self._request_id[trade.TradeID] = nil;
            end
        end
        -- Check that order is stil exist
        if order_id ~= nil then return core.host:findTable("orders"):find("OrderID", order_id); end
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

function trading:MoveStop(stop_rate, trade)
    local order = self:FindStopOrder(trade);
    if order == nil then
        self:trace("Stop order not found, creating a new one");
        return self:CreateStopOrder(stop_rate, trade);
    else
        return self:ChangeOrder(stop_rate, order);
    end
end

function trading:MoveLimit(limit_rate, trade)
    self:trace("Searching for a limit");
    local order = self:FindLimitOrder(trade);
    if order == nil then
        self:trace("Limit order not found, creating a new one");
        return self:CreateLimitOrder(limit_rate, trade);
    else
        return self:ChangeOrder(limit_rate, order);
    end
end

function trading:RemoveStop(trade)
    self:trace("Searching for a stop");
    local order = self:FindStopOrder(trade);
    if order == nil then self:trace("No stop"); return nil; end
    self:trace("Deleting order");
    return self:DeleteOrder(order);
end

function trading:RemoveLimit(trade)
    self:trace("Searching for a limit");
    local order = self:FindLimitOrder(trade);
    if order == nil then self:trace("No limit"); return nil; end
    self:trace("Deleting order");
    return self:DeleteOrder(order);
end

function trading:MoveOrder(order, new_rate)
    local min_change = core.host:findTable("offers"):find("Instrument", order.Instrument).PointSize;
    if math.abs(new_rate - order.Rate) > min_change then
        self:trace(string.format("Changing an order to %s", tostring(new_rate)));
        -- stop exists
        local valuemap = core.valuemap();
        valuemap.Command = "EditOrder";
        valuemap.AcctID  = order.AccountID;
        valuemap.OrderID = order.OrderID;
        valuemap.Rate = new_rate;
        local success, msg = terminal:execute(200, valuemap);
        if not(success) then terminal:alertMessage(order.Instrument, new_rate, "Failed change stop " .. msg, core.now()); end
    end
end

trading:RegisterModule(Modules);
breakeven = {};
-- public fields
breakeven.Name = "Breakeven";
breakeven.Version = "1.3.1";
breakeven.Debug = false;
breakeven.Default_breakeven_when = 10;
breakeven.Default_use_breakeven = false;
breakeven.Default_breaeven_to = 1;
--private fields
breakeven._breakeven_when = 10;
breakeven._use_breakeven = false;
breakeven._breaeven_to = 1;
breakeven._moved_stops = {};
breakeven._request_id = nil;
breakeven._used_stop_orders = {};
breakeven._ids_start = 4200;
breakeven._source_id = nil;
breakeven._trading = nil;
breakeven._controllers = {};

function breakeven:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function breakeven:OnNewModule(module)
    if module.Name == "Trading" then self._trading = module; end
end
function breakeven:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end

function breakeven:Init(parameters)
    parameters:addBoolean("use_breakeven", "Use Breakeven", "", self.Default_use_breakeven);
    parameters:addDouble("breakeven_when", "Breakeven Activation Value, in pips", "", self.Default_breakeven_when);
    parameters:addDouble("breakeven_to", "Breakeven To, in pips", "", self.Default_breaeven_to);
end

function breakeven:Prepare(nameOnly)
    self._breakeven_when = instance.parameters.breakeven_when;
    self._use_breakeven = instance.parameters.use_breakeven;
    self._breaeven_to = instance.parameters.breakeven_to;
    if self._use_breakeven == nil or self._use_breakeven == true then
        self._source_id = self._ids_start + 1;
        ExtSubscribe(self._source_id, nil, "t1", true, "tick");
    end
    self:trace(string.format("Use breakeven: %s. Profit for trigger breakeven: %s. Breakeven target: %s",
        tostring(self._use_breakeven), tostring(self._breakeven_when), tostring(self._breaeven_to)));
end

function breakeven:ExtUpdate(id, source, period)
    if id ~= self._source_id then
        return;
    end
    for _, controller in ipairs(self._controllers) do
        controller:DoBreakeven();
    end
end

function breakeven:CreateController()
    local controller = {};
    controller._parent = self;
    controller._executed = false;
    function controller:SetWhen(when)
        self._when = when;
        return self;
    end
    function controller:SetTrade(trade)
        self._trade = trade;
        return self;
    end
    function controller:SetDynamicTo(dynamicTo)
        self._dynamicTo = dynamicTo;
        return self;
    end
    function controller:SetTo(to)
        self._to = to;
        return self;
    end
    function controller:SetRequestID(trade_request_id)
        self._request_id = trade_request_id;
        return self;
    end
    function controller:GetTrade()
        if self._trade == nil then
            self._trade = core.host:findTable("trades"):find("OpenOrderReqID", self._request_id);
            if self._trade == nil then
                return nil;
            end
        end
        return self._trade;
    end
    function controller:getTo()
        local trade = self:GetTrade();
        if self._dynamicTo ~= nil then
            return self._dynamicTo(trade);
        end
        local offer = core.host:findTable("offers"):find("Instrument", trade.Instrument);
        if trade.BS == "B" then
            return offer.Bid - (trade.PL - self._to) * offer.PointSize;
        else
            return offer.Ask + (trade.PL - self._to) * offer.PointSize;
        end
    end
    function controller:DoBreakeven()
        if self._executed then
            return false;
        end
        local trade = self:GetTrade();
        if trade == nil then
            return true;
        end
        if not trade:refresh() then
            self._executed = true;
            return false;
        end
        if trade.PL >= self._when then
            local stop = self:getTo();
            trading:MoveStop(stop, trade);
            local account = core.host:findTable("accounts"):find("AccountID", trade.AccountID);
            local base_unit_size = core.host:execute("getTradingProperty", "baseUnitSize", trade.Instrument, trade.AccountID);
            local amount = math.floor(trade.Lot / base_unit_size * instance.parameters.close_partial_amount / 100) * base_unit_size;
            if account.Hedging == "Y" then
                local valuemap = core.valuemap();
                valuemap.BuySell = trade.BS == "B" and "S" or "B";
                valuemap.OrderType = "CM";
                valuemap.OfferID = trade.OfferID;
                valuemap.AcctID = trade.AccountID;
                valuemap.TradeID = trade.TradeID;
                valuemap.Quantity = math.max(amount, 1);
                local success, msg = terminal:execute(200, valuemap);
                assert(success, msg);
            else
                local valuemap = core.valuemap();
                valuemap.OrderType = "OM";
                valuemap.OfferID = trade.OfferID;
                valuemap.AcctID = trade.AccountID;
                valuemap.Quantity = math.max(amount, 1);
                if trade.BS == "B" then
                    valuemap.BuySell = "S";
                else
                    valuemap.BuySell = "B";
                end
                local success, msg = terminal:execute(200, valuemap);
                assert(success, msg);
            end
            self._executed = true;
            return false;
        end
        return true;
    end
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end

function breakeven:CreateBreakeven(trade_request_id, when)
    return self:CreateController()
        :SetWhen(when)
        :SetRequestID(trade_request_id);
end

breakeven:RegisterModule(Modules);

local AccountType;
local Source,TickSource;
local MaxNumberOfPositionInAnyDirection, MaxNumberOfPosition;
local SoundFile = nil;
local RecurrentSound = false;
local ALLOWEDSIDE;
local AllowTrade;
local Offer;
local CanClose;
local Account;
local Amount;
local SetLimit;
local Limit;
local SetStop;
local Stop;
local TrailingStop;
local ShowAlert;
local Email;
local SendEmail;
local BaseSize;
local EntyExecutionType, ExitExecutionType;
local CloseOnOpposite
local first;
local Direction;
local CustomID;
local PositionCap;
local TF;
local OpenTime, CloseTime, ExitTime;
local LastEntry, LastExit;
local ToTime;
local ValidInterval,UseMandatoryClosing;
local close_partial_amount;
local close_partial_profit;
 
--Indicator parameters
local Indicator,  MA_Period, MA_Method, Step, UseT3, b;
 
function Prepare( nameOnly)
    CustomID = instance.parameters.CustomID;
    AccountType = instance.parameters.AccountType;
    EntryExecutionType = instance.parameters.EntryExecutionType;
    ExitExecutionType= instance.parameters.ExitExecutionType;
    CloseOnOpposite = instance.parameters.CloseOnOpposite;
    MaxNumberOfPositionInAnyDirection = instance.parameters.MaxNumberOfPositionInAnyDirection;
    MaxNumberOfPosition = instance.parameters.MaxNumberOfPosition;
    Direction = instance.parameters.Direction == "direct";
    TF= instance.parameters.TF;
    ToTime= instance.parameters.ToTime;
    close_partial_amount = instance.parameters.close_partial_amount;
    close_partial_profit = instance.parameters.close_partial_profit;
    breakeven:Prepare(nameOnly);
    
    if ToTime == 1 then
        ToTime=core.TZ_EST;
    elseif ToTime == 2 then
        ToTime=core.TZ_UTC;
    elseif ToTime == 3 then
        ToTime=core.TZ_LOCAL;
    elseif ToTime == 4 then
        ToTime=core.TZ_SERVER;
    elseif ToTime == 5 then
        ToTime=core.TZ_FINANCIAL;
    elseif ToTime == 6 then
        ToTime=core.TZ_TS;
    end
     
    PositionCap = instance.parameters.PositionCap;    
    ValidInterval = instance.parameters.ValidInterval;
    UseMandatoryClosing = instance.parameters.UseMandatoryClosing;
     
    LastEntry=nil;
    LastExit=nil;
    
    --Indicator parameters
    MA_Period = instance.parameters.MA_Period;
    MA_Method = instance.parameters.MA_Method;
    Step = instance.parameters.Step;
    UseT3 = instance.parameters.UseT3;
    b = instance.parameters.b;

    assert(TF ~= "t1", "The time frame must not be tick");

    name = profile:id() .. ", " .. instance.bid:name() .. ", " .. CustomID;
    instance:name(name);
   
    PrepareTrading();

    if nameOnly then
        return ;
    end
    
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA strategy.");  
    assert(core.indicators:findIndicator("T3_MA") ~= nil, "Please, download and install T3_MA.LUA strategy.");  
    assert(core.indicators:findIndicator("HEIKIN_ASHI_MA_T3") ~= nil, "Please, download and install HEIKIN_ASHI_MA_T3.LUA strategy.");  
    
     if EntryExecutionType== "Live"  
      then
     TickSource = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "close");
     end
    
    Source = ExtSubscribe(2, nil, TF, instance.parameters.Type == "Bid", "bar");
    Indicator = core.indicators:create("HEIKIN_ASHI_MA_T3", Source, MA_Period, MA_Method, Step, UseT3, b, false   ,  core.rgb(0, 255, 0),  core.rgb(255, 0, 0)  );
    first=Indicator.DATA:first(); 
    
    
    ValidInterval = instance.parameters.ValidInterval;
    UseMandatoryClosing = instance.parameters.UseMandatoryClosing;
    
     local valid;
    OpenTime, valid = ParseTime(instance.parameters.StartTime);
    assert(valid, "Time " .. instance.parameters.StartTime .. " is invalid");
    CloseTime, valid = ParseTime(instance.parameters.StopTime);
    assert(valid, "Time " .. instance.parameters.StopTime .. " is invalid");
    ExitTime, valid = ParseTime(instance.parameters.ExitTime);
    assert(valid, "Time " .. instance.parameters.ExitTime .. " is invalid");
    
    if UseMandatoryClosing then
        core.host:execute("setTimer", 100, math.max(ValidInterval / 2, 1));
    end
end

function ReleaseInstance()
    for _, module in pairs(Modules) do if module.ReleaseInstance ~= nil then module:ReleaseInstance(); end end
    core.host:execute ("killTimer", 100);
end

 -- NG: create a function to parse time
function ParseTime(time)
    local Pos = string.find(time, ":");
    if Pos == nil then
        return nil, false;
    end
    local h = tonumber(string.sub(time, 1, Pos - 1));
    time = string.sub(time, Pos + 1);
    Pos = string.find(time, ":");
    if Pos == nil then
        return nil, false;
    end
    local m = tonumber(string.sub(time, 1, Pos - 1));
    local s = tonumber(string.sub(time, Pos + 1));
    return (h / 24.0 +  m / 1440.0 + s / 86400.0),                          -- time in ole format
           ((h >= 0 and h < 24 and m >= 0 and m < 60 and s >= 0 and s < 60) or (h == 24 and m == 0 and s == 0)); -- validity flag
end


function InRange(now, openTime, closeTime)
    if openTime < closeTime then
        return now >= openTime and now <= closeTime;
    end
    if openTime > closeTime then
        return now > openTime or now < closeTime;
    end

    return now == openTime;
end

function PrepareTrading()
    ALLOWEDSIDE = instance.parameters.ALLOWEDSIDE;

    local PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be chosen");

    ShowAlert = instance.parameters.ShowAlert;
    RecurrentSound = instance.parameters.RecurrentSound;

    SendEmail = instance.parameters.SendEmail;

    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");

    AllowTrade = instance.parameters.AllowTrade;
    Account = instance.parameters.Account;
    Amount = instance.parameters.Amount;
    BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account);
    Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;
    
    if AccountType== "FIFO" then
    CanClose=false;
    elseif AccountType== "NON" then
    CanClose=true;
    else
    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account);
    end
    
    SetLimit = instance.parameters.SetLimit;
    Limit = instance.parameters.Limit;
    SetStop = instance.parameters.SetStop;
    Stop = instance.parameters.Stop;
    TrailingStop = instance.parameters.TrailingStop;
end

function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.
    for _, module in pairs(Modules) do if module.BlockTrading ~= nil and module:BlockTrading(id, source, period) then return; end end for _, module in pairs(Modules) do if module.ExtUpdate ~= nil then module:ExtUpdate(id, source, period); end end
    if AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
         return ;
        end
    end
    
    if period < 0
    then
        return;
    end

    if  EntryExecutionType== "Live"  
    then    
            if id ~= 1 then
            return;
            end        
            period= core.findDate (Source, TickSource:date(period), false);
    else    
            if id ~= 2 then       
            return;
            end
    end
  
    now = core.host:execute("getServerTime");
    now= core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
   -- get only time
    now = now - math.floor(now);
        -- update indicators.
    Indicator:update(core.UpdateLast);

    if not Source.close:hasData( period)    
    or period < first 
    then
        return;
    end
    
    if EntryExecutionType== "Live" and id==1 
    or EntryExecutionType~= "Live" and id~=1 then
    EntryFunction(now,period);    
    end

end

function EntryFunction( now,period)
    local Return=false;
	
	
       if not InRange(now, OpenTime, CloseTime)
	  then            
      return ;
      end
      
     if ( LastEntry == Source:serial(period) )   then
     return;
     end    
      
    -- only buy if we have a fast cross over slow and the price is above the moving averages.
    if  Indicator.DATA:colorI(period) ==  core.rgb(0, 255, 0)
    and Indicator.DATA:colorI(period-1) ~=  core.rgb(0, 255, 0)
    then    
          if Direction then
                BUY();
            else
                SELL();
            end
        LastEntry= Source:serial(period);
        Return=true;
    elseif Indicator.DATA:colorI(period) ==  core.rgb(255, 0, 0)
    and Indicator.DATA:colorI(period-1) ~=  core.rgb(255, 0, 0)
    then
            if Direction then
                SELL();
            else
                BUY();
            end
        LastEntry= Source:serial(period);
        Return=true;
    end
    return Return;
end

function ExtAsyncOperationFinished(cookie, success, message)
    for _, module in pairs(Modules) do if module.AsyncOperationFinished ~= nil then module:AsyncOperationFinished(cookie, success, message, message1, message2); end end
    if cookie == 100 then
        -- timer
        if UseMandatoryClosing and AllowTrade then
            now = core.host:execute("getServerTime");
            now= core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
            -- get only time
            now = now - math.floor(now);
            
            -- check whether the time is in the exit time period
            if now >= ExitTime and now < ExitTime +(ValidInterval / 86400.0) then
                if not checkReady("trades")  then
                    return ;
                end  
        
                if haveTrades("B")  then
                    exitSpecific("B");
                    Signal ("Close Long");
                end
                
                if haveTrades("S")  then
                    exitSpecific("S");
                    Signal ("Close Short");
                end
            end
        end
    elseif cookie == 200 and not success then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. message, instance.bid:date(instance.bid:size() - 1));
    elseif cookie == 201 and not success then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Close order failed" .. message, instance.bid:date(instance.bid:size() - 1));
     end
end

--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--
function BUY()
    if AllowTrade then
        --if CanClose and CloseOnOpposite and  haveTrades("S") then
        if (CloseOnOpposite or Hedge) and  haveTrades("S")then
            -- close on opposite signal
            exitSpecific("S");
            Signal ("Close Short");
        end

        if ALLOWEDSIDE == "Sell"  then
            -- we are not allowed buys.
            return;
        end 

        enter("B",0);
    else
        Signal ("Buy Signal");    
    end
end   

function SELL ()        
    if AllowTrade then
        --if CanClose and CloseOnOpposite and  haveTrades("B") then
        if (CloseOnOpposite or Hedge) and  haveTrades("B") then
            -- close on opposite signal
            exitSpecific("B");
            Signal ("Close Long");
        end

        if ALLOWEDSIDE == "Buy"  then
            -- we are not allowed sells.
            return;
        end

        enter("S",0);
    else
        Signal ("Sell Signal");    
    end
end

function Signal (Label)
    if ShowAlert then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW],  Label, instance.bid:date(NOW));
    end

    if SoundFile ~= nil then
        terminal:alertSound(SoundFile, RecurrentSound);
    end

    if Email ~= nil then
        terminal:alertEmail(Email, profile:id().. " : " .. Label , FormatEmail(Source, NOW, Label));
         
    end
end                                

function checkReady(table)
    local rc;
    if Account == "TESTACC_ID" then
        -- run under debugger/simulator
        rc = true;
    else
        rc = core.host:execute("isTableFilled", table);
    end

    return rc;
end

function tradesCount(BuySell) 
    local enum, row;
    local count = 0;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while row ~= nil do
        if row.AccountID == Account 
        and row.OfferID == Offer 
        and row.QTXT == CustomID   
        and (row.BS == BuySell or BuySell == nil) then
            count = count + 1;
        end

        row = enum:next();
    end

    return count;
end

function haveTrades(BuySell) 
    local enum, row;
    local found = false;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while (row ~= nil) do
        if row.AccountID == Account
        and row.OfferID == Offer
        and  row.QTXT == CustomID 
        and (row.BS == BuySell or BuySell == nil) then
            found = true;
            break;
        end
 
        row = enum:next();
    end

    return found;
end

-- enter into the specified direction
function enter(BuySell, hCount)
    -- do not enter if position in the specified direction already exists
    if (tradesCount(BuySell) >= MaxNumberOfPosition
    or (tradesCount(nil) >= MaxNumberOfPositionInAnyDirection))    
    and PositionCap    
    then
        return true;
    end

    -- send the alert after the checks to see if we can trade.
    if (BuySell == "S") then
        Signal ("Sell Signal");    
    else
        Signal ("Buy Signal");    
    end

    return MarketOrder(BuySell,hCount);
end

-- enter into the specified direction
function MarketOrder(BuySell,hCount)
    local valuemap, success, msg;
    valuemap = core.valuemap();

    valuemap.Command = "CreateOrder";
    valuemap.OrderType = "OM";
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    if hCount > 0 then
    valuemap.Quantity = hCount * BaseSize;
    else
    valuemap.Quantity = Amount * BaseSize;
    end
    valuemap.BuySell = BuySell;
     valuemap.CustomID = CustomID;

    -- add stop/limit
    valuemap.PegTypeStop = "O";
    if SetStop then 
        if BuySell == "B" then
            valuemap.PegPriceOffsetPipsStop = -Stop;
        else
            valuemap.PegPriceOffsetPipsStop = Stop;
        end
    end
    if TrailingStop then
        valuemap.TrailStepStop = 1;
    end

    valuemap.PegTypeLimit = "O";
    if SetLimit then
        if BuySell == "B" then
            valuemap.PegPriceOffsetPipsLimit = Limit;
        else
            valuemap.PegPriceOffsetPipsLimit = -Limit;
        end
    end

    if (not CanClose) then
        valuemap.EntryLimitStop = 'Y'
    end

    success, msg = terminal:execute(200, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        return false;
    end

    if close_partial_amount ~= 0 then
        breakeven:CreateController():SetWhen(close_partial_profit):SetTo(instance.parameters.breakeven_to):SetRequestID(msg);
    end

    return true;
end

function exitSpecific(BuySell)
    if not AllowTrade then
    return;
    end
 
--side
-- closes all positions of the specified direction (B for buy, S for sell)
 
    local enum, row, valuemap;

    enum = core.host:findTable("trades"):enumerator();
    while true do
        row = enum:next();
        if row == nil then
            break;
        end
        if row.AccountID == Account and
           row.OfferID == Offer and
           row.BS == BuySell and
           row.QTXT == CustomID then
            -- if trade has to be closed

                        if CanClose then
                                        -- non-FIFO account, create a close market order
                                        valuemap = core.valuemap();
                                        valuemap.OrderType = "CM";
                                        valuemap.OfferID = Offer;
                                        valuemap.AcctID = Account;
                                        valuemap.Quantity = row.Lot;
                                        valuemap.TradeID = row.TradeID;
                                        valuemap.CustomID = CustomID;
                                        if row.BS == "B" then
                                            valuemap.BuySell = "S";
                                        else
                                            valuemap.BuySell = "B";
                                        end
                                        success, msg = terminal:execute(201, valuemap);
                                         if not(success) then
                                            terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Close order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
                                            return false;
                                        end
                          else
                                            -- FIFO account, create an opposite market order
                                            valuemap = core.valuemap();
                                            valuemap.OrderType = "OM";
                                            valuemap.OfferID = Offer;
                                            valuemap.AcctID = Account;
                                            --valuemap.Quantity = Amount*BaseSize;
                                            valuemap.Quantity = row.Lot;
                                            valuemap.CustomID = CustomID;
                                            if row.BS == "B" then
                                                valuemap.BuySell = "S";
                                            else
                                                valuemap.BuySell = "B";
                                            end
                                            success, msg = terminal:execute(201, valuemap);
                                             if not(success) then
                                                terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Close order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
                                                return false;
                                            end
                        end
        end
    end
end 

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
