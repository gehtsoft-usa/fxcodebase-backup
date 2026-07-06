-- Id: 2611
-- More information about this indicator can be found at:
-- http://fxcodebase.com

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    strategy:name("Set stop by order's life time");
    strategy:description("Strategy changes stop followiung to the order's life time");

    strategy.parameters:addGroup("Stop Parameters");
    strategy.parameters:addInteger("TimeInterval", "Time interval for trailing, in minutes", "", 60, 1, 100000);
    strategy.parameters:addInteger("StepTrailing", "Step for trailing", "", 10, 1, 1000);

    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addGroup("Trade");
    strategy.parameters:addString("Trade", "Choose Trade", "", "");
    strategy.parameters:setFlag("Trade", core.FLAG_TRADE);
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
end

local tradeExist = true;
local first = true;
local stopOrder = nil;      -- the identifier of the stop order
local tsource = nil;
local timer;
local minChange;
local executing = false;
local LastTime;

function Prepare(onlyName)
    local name;
    name = profile:id() .. "(" .. instance.bid:instrument()  .. 
                           "," .. instance.parameters.TimeInterval .. "," ..
                           "," .. instance.parameters.StepTrailing .. "," ..
                           instance.parameters.Trade .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end

    minChange = math.pow(10, -instance.bid:getPrecision());

    ExtSetupSignal(name .. ":", true);
    tsource = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "close");
    LastTime=core.now();
end

function ExtUpdate(id, source, period)
    if id == 1 and tradeExist then
        if period > tsource:first() then
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

            local stopValue, valuemap, success, msg;
            local stopSide;
            local FlTrail=false;
            
            if math.floor((core.now()-LastTime)*1440)>=instance.parameters.TimeInterval then
             FlTrail=true;
             LastTime=core.now();
            end
            
            if FlTrail==false then
             return ;
            end
            
            if trade.StopOrderID == "" or trade.StopOrderID == nil then
             return ;
            end
            
            if trade.BS == "B" then
                stopValue=trade.Stop+instance.parameters.StepTrailing*instance.bid:pipSize();
               stopSide = "S";
               if stopValue >= instance.bid[NOW] then
                   --core.host:trace(string.format("not passed %f >= %f", stopValue, instance.bid[NOW]));
                   return ;
               end
            else
                stopValue=trade.Stop-instance.parameters.StepTrailing*instance.bid:pipSize();
               stopSide = "B";
               if stopValue <= instance.ask[NOW] then
                   --core.host:trace(string.format("not passed %f <= %f", stopValue, instance.ask[NOW]));
                   return ;
               end
            end


                if math.abs(stopValue - trade.Stop) > minChange and instance.parameters.AllowTrade then
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

function ExtAsyncOperationFinished(id, success, message)
    if id == 200 then
        executing = false;
        if not(success) then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed create/change stop " .. message, instance.bid:date(NOW));
        end
    end
end





dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");

