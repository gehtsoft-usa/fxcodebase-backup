--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
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
    strategy.parameters:addBoolean("TradeAll", "Watch all trades", "If Yes, the strategy will be watched on all trades, otherwise, one of the trade should be selected.", true);
    strategy.parameters:addString("Trade", "Choose Trade", "", "");
    strategy.parameters:setFlag("Trade", core.FLAG_TRADE);
end

local tradeExist = true;
local first = true;
local stopOrder = nil;      -- the identifier of the stop order
local tsource = nil;
local timer;
local minChange;
local executing = false;
local tradeAll;
local trades = {};

function Prepare(onlyName)
    local name;
    tradeAll = instance.parameters.TradeAll;
    
    local tradeCaption = instance.parameters.Trade;
    if tradeAll == true then
        tradeCaption = "All Trades";
    end
    
    
    name = profile:id() .. "(" .. instance.bid:instrument()  .. "[" .. instance.parameters.Period  .. "]" ..
                           "," .. instance.parameters.Frame .. "," ..
                           "," .. instance.parameters.Indent .. "," ..
                           tradeCaption .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end

    minChange = math.pow(10, -instance.bid:getPrecision());

    trades = {};
    trades.count = 0;
    ExtSetupSignal(name .. ":", true);
    tsource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
end

function ExtUpdate(id, source, period)
    if id == 1 and tradeExist then
     local Shift=math.floor(instance.parameters.Frame/2);
        if period > tsource:first()+instance.parameters.Frame then

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
            
            trades = {};
            trades.count = 0;

            if tradeAll == true then
                local tradesEnum = core.host:findTable("trades"):enumerator();
                local idx = 1;
                local tradeRow = tradesEnum:next();
                while tradeRow ~= nil do
                    trades[idx] = tradeRow;
                    idx = idx + 1;
                    tradeRow = tradesEnum:next();
                end
                trades.count = idx - 1;
            else
                local tradeRow = core.host:findTable("trades"):find("TradeID", instance.parameters.Trade);
                if tradeRow ~= nil then
                    trades[1] = tradeRow;
                    trades.count = 1;
                end
            end

            if trades.count == 0 then
                tradeExist = false;
                
                local tradeCaption = "Trade " .. instance.parameters.Trade;
                if tradeAll == true then
                    tradeCaption = "Trades";
                end
    
                terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], tradeCaption .. " disappear",
                instance.bid:date(NOW));
                core.host:execute("stop");
                return ;
            end

            for idx = 1, #trades do
                          
                local trade = trades[idx];
                local stopValue, valuemap, success, msg;
                local stopSide;
                local Fl=true;
                if trade.BS == "B" then
                    for i=1,Shift,1 do
                        if tsource.low[period-i-Shift]<=tsource.low[period-Shift] or tsource.low[period+i-Shift]<=tsource.low[period-Shift] then
                            Fl=false;
                        end
                    end
                    if Fl==true then
                        stopValue=tsource.low[period-Shift]-instance.parameters.Indent*instance.bid:pipSize();
                        if instance.parameters.MoveBack==false then
                            if trade.StopOrderID ~= "" and trade.StopOrderID ~= nil then
                                if stopValue<trade.Stop then
                                    return ;
                                end
                            end 
                        end 
                    else
                        return ;
                    end
                    stopSide = "S";
                    if stopValue >= instance.bid[NOW] then
                        --core.host:trace(string.format("not passed %f >= %f", stopValue, instance.bid[NOW]));
                        return ;
                    end
                else
                    for i=1,Shift,1 do
                        if tsource.high[period-i-Shift]>=tsource.high[period-Shift] or tsource.high[period+i-Shift]>=tsource.high[period-Shift] then
                            Fl=false;
                            end
                    end
                    if Fl==true then
                        stopValue=tsource.high[period-Shift]+instance.parameters.Indent*instance.bid:pipSize();
                        if instance.parameters.MoveBack==false then
                            if trade.StopOrderID ~= "" and trade.StopOrderID ~= nil then
                                if stopValue>trade.Stop then
                                    return ;
                                end
                            end 
                        end 
                    else
                        return ;
                    end
                    stopSide = "B";
                    if stopValue <= instance.ask[NOW] then
                        --core.host:trace(string.format("not passed %f <= %f", stopValue, instance.ask[NOW]));
                        return ;
                    end
                end


                if trade.StopOrderID == "" or trade.StopOrderID == nil then
                    valuemap = core.valuemap();
                    valuemap.Command = "CreateOrder";
                    valuemap.OrderType = "S";
                    valuemap.OfferID = trade.OfferID;
                    valuemap.AcctID = trade.AccountID;
                    valuemap.TradeID = trade.TradeID;
                    valuemap.Quantity = trade.Lot;
                    valuemap.Rate = stopValue;
                    valuemap.BuySell = stopSide;
                    executing = true;
                    success, msg = terminal:execute(200, valuemap);
                    if not(success) then
                        executing = false;
                        terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed create stop " .. msg, instance.bid:date(NOW));
                    end
                else
                    if math.abs(stopValue - trade.Stop) > minChange then
                        -- stop exists
                        valuemap = core.valuemap();
                        valuemap.Command = "EditOrder";
                        valuemap.AcctID = trade.AccountID;
                        valuemap.OrderID = trade.StopOrderID;
                        valuemap.Rate = stopValue;
                        executing = true;
                        success, msg = terminal:execute(200, valuemap);
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

