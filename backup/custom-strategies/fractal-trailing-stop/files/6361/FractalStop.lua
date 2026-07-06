-- Id: 2609
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=2791

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
    strategy:name("Set stop by fractals");
    strategy:description("Strategy changes stop followiung to the fractals");

    strategy.parameters:addGroup("Fractal Parameters");
    strategy.parameters:addInteger("Frame", "Number of bars for fractals (Odd)", "", 5, 5, 99);
    
    strategy.parameters:addGroup("Stop Parameters");
    strategy.parameters:addInteger("Indent", "Indent from fractal", "", 0, 0, 1000);
    strategy.parameters:addBoolean("MoveBack", "Move stop back", "", false);

    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
    strategy.parameters:addString("Period", "Timeframe", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Trade");
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("Trade", "Choose Trade", "", "");
    strategy.parameters:setFlag("Trade", core.FLAG_TRADE);

    strategy.parameters:addString("EntryExecutionType", "Execution Type", "", "Live");
    strategy.parameters:addStringAlternative("EntryExecutionType", "End of Turn", "", "EndOfTurn");
    strategy.parameters:addStringAlternative("EntryExecutionType", "Live", "", "Live");    
end

local tradeExist = true;
local first = true;
local stopOrder = nil;      -- the identifier of the stop order
local tsource = nil;
local timer;
local minChange;
local executing = false;
local EntryExecutionType;
local TickSource;

function Prepare(onlyName)
    local name;
    name = profile:id() .. "(" .. instance.bid:instrument()  .. "[" .. instance.parameters.Period  .. "]" ..
                           "," .. instance.parameters.Frame .. "," ..
                           "," .. instance.parameters.Indent .. "," ..
                           instance.parameters.Trade .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end

    EntryExecutionType = instance.parameters.EntryExecutionType;
    minChange = math.pow(10, -instance.bid:getPrecision());

    ExtSetupSignal(name .. ":", true);
    if EntryExecutionType == "Live" then
        TickSource = ExtSubscribe(2, nil, "t1", instance.parameters.Type == "Bid", "close");
    end
    tsource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
end

function TriggerSteam(id)
    if EntryExecutionType == "Live" then
        return id == 2;
    else
        return id == 1;
    end
end

function GetPeriod(period)
    if EntryExecutionType == "Live" then
        return tsource:size() - 1;
    else
        return period;
    end
end

function ExtUpdate(id, source, period)
    if TriggerSteam(id) and tradeExist then
        period = GetPeriod(period);
        if period > tsource:first() + instance.parameters.Frame then
            -- check whether trade exists
            local trade, order;

            if not(core.host:execute("isTableFilled", "trades")) then
                core.host:trace("not filled");
                -- relogin??
                return ;
            end

            if not(core.host:execute("isReadyForTrade")) then
                -- relogin??
                core.host:trace("not ready");
                return ;
            end

            trade = core.host:findTable("trades"):find("TradeID", instance.parameters.Trade);

            if trade == nil then
                tradeExist = false;
                terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Trade " .. instance.parameters.Trade .. " disappear", instance.bid:date(NOW));
                core.host:execute("stop");
                return ;
            end

            local stopValue;
            local stopSide;
            local Shift = math.floor(instance.parameters.Frame / 2);
            if trade.BS == "B" then
                for i=1,Shift,1 do
                    if tsource.low[period-i-Shift]<=tsource.low[period-Shift] or tsource.low[period+i-Shift]<=tsource.low[period-Shift] then
                        return;
                    end
                end
                stopValue=tsource.low[period-Shift]-instance.parameters.Indent*instance.bid:pipSize();
                if instance.parameters.MoveBack==false then
                    if trade.StopOrderID ~= "" and trade.StopOrderID ~= nil then
                        if stopValue<trade.Stop then
                            return ;
                        end
                    end
                end
                stopSide = "S";
                if stopValue >= instance.bid[NOW] then
                    return ;
                end
            else
                for i=1,Shift,1 do
                    if tsource.high[period-i-Shift]>=tsource.high[period-Shift] or tsource.high[period+i-Shift]>=tsource.high[period-Shift] then
                        return;
                    end
                end
                stopValue=tsource.high[period-Shift]+instance.parameters.Indent*instance.bid:pipSize();
                if instance.parameters.MoveBack==false then
                    if trade.StopOrderID ~= "" and trade.StopOrderID ~= nil then
                        if stopValue>trade.Stop then
                            return ;
                        end
                    end 
                end 
                stopSide = "B";
                if stopValue <= instance.ask[NOW] then
                    return ;
                end
            end

            if instance.parameters.AllowTrade then
                if trade.StopOrderID == "" or trade.StopOrderID == nil then
                    local valuemap = core.valuemap();
                    valuemap.Command = "CreateOrder";
                    valuemap.OrderType = "S";
                    valuemap.OfferID = trade.OfferID;
                    valuemap.AcctID = trade.AccountID;
                    valuemap.TradeID = trade.TradeID;
                    valuemap.Quantity = trade.Lot;
                    valuemap.Rate = stopValue;
                    valuemap.BuySell = stopSide;
                    executing = true;
                    local success, msg = terminal:execute(200, valuemap);
                    if not(success) then
                        executing = false;
                        terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed create stop " .. msg, instance.bid:date(NOW));
                    end
                else
                    if math.abs(stopValue - trade.Stop) > minChange then
                        -- stop exists
                        local valuemap = core.valuemap();
                        valuemap.Command = "EditOrder";
                        valuemap.AcctID = trade.AccountID;
                        valuemap.OrderID = trade.StopOrderID;
                        valuemap.Rate = stopValue;
                        executing = true;
                        local success, msg = terminal:execute(200, valuemap);
                        if not(success) then
                            executing = false;
                            terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed change stop " .. msg, instance.bid:date(NOW));
                        end
                    end
                end
            end
        end
    end
end

function ExtAsyncOperationFinished(id, success, message)
    if id == 200 then
        executing = false;
        if not(success) then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed create/change stop " .. message, instance.bid:date(NOW));
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");

