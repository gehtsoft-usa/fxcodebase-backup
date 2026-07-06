-- Id: 1686
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=2209

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
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
    strategy:name("Set stop by MVA");
    strategy:description("Strategy changes stop equal to the chosen MVA value");
    strategy:setTag("Version", "2");

    strategy.parameters:addGroup("MVA Parameters");
    strategy.parameters:addString("MET", "Moving average method", "", "MVA");
    strategy.parameters:addStringAlternative("MET", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("MET", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("MET", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("MET", "TMA", "", "TMA");

    strategy.parameters:addInteger("MVAN", "Moving average periods", "", 200, 1, 299);
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
    strategy.parameters:addString("TF", "Timeframe", "", "m1");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);
    strategy.parameters:addString("Price", "Price", "", "close");
    strategy.parameters:addStringAlternative("Price", "Open", "", "open");
    strategy.parameters:addStringAlternative("Price", "High", "", "high");
    strategy.parameters:addStringAlternative("Price", "Low", "", "low");
    strategy.parameters:addStringAlternative("Price", "Close/Tick", "", "close");
    strategy.parameters:addStringAlternative("Price", "Median", "", "median");
    strategy.parameters:addStringAlternative("Price", "Typical", "", "typical");
    strategy.parameters:addStringAlternative("Price", "Weighted", "", "weighted");

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addGroup("Trade");
    strategy.parameters:addString("Trade", "Choose Trade", "", "");
    strategy.parameters:setFlag("Trade", core.FLAG_TRADE);
    strategy.parameters:addInteger("Timeout", "Update stop timeout (minutes)", "", 1, 1, 60);
end

local tradeExist = true;
local loaded = false;
local first = true;
local stopOrder = nil;      -- the identifier of the stop order
local tsource = nil;
local mva = nil;
local lastTime = nil;
local timeout = nil;
local pipSize = 0;

function Prepare(nameOnly)
    timeout = instance.parameters.Timeout * 60;
    pipSize = math.pow(10, -instance.bid:getPrecision());

    local name;
    name = profile:id() .. "(" .. instance.bid:instrument()  .. "[" .. instance.parameters.TF  .. "]" .. "." .. instance.parameters.Price ..
                           "," .. instance.parameters.MET .. "(" .. instance.parameters.MVAN .. ")" .. "," .. instance.parameters.Timeout  ..
                           "m," .. instance.parameters.Trade .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
end

function Update()
    if first then
        first = false;
        loaded = true;
        subscribe();
        return ;
    end
    if loaded and tradeExist then
        local now = math.floor(core.now() * 86400 + 0.5);
        if lastTime ~= nil and (now - lastTime) >= timeout then
            updateStop();
            lastTime = math.floor(core.now() * 86400 + 0.5);
        end
    end
end

function AsyncOperationFinished(id, success, message)
    if id == 2 then
        -- data is loaded
        loaded = true;
        updateStop();
        lastTime = math.floor(core.now() * 86400 + 0.5);
    elseif id == 200 and not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed create/change stop " .. msg, instance.bid:date(NOW));
    end
end

function subscribe()
    tsource = core.host:execute("getHistory", 2, instance.bid:instrument(), instance.parameters.TF, 0, 0, instance.parameters.Type == "Bid");

    local isource;
    if instance.parameters.Period == "t1" then
        isource = tsource;
    elseif instance.parameters.Price == "open" then
        isource = tsource.open;
    elseif instance.parameters.Price == "high" then
        isource = tsource.high;
    elseif instance.parameters.Price == "low" then
        isource = tsource.low;
    elseif instance.parameters.Price == "close" then
        isource = tsource.close;
    elseif instance.parameters.Price == "median" then
        isource = tsource.median;
    elseif instance.parameters.Price == "typical" then
        isource = tsource.typical;
    elseif instance.parameters.Price == "weighted" then
        isource = tsource.weighted;
    else
        isource = tsource.close;
    end
    assert(core.indicators:findIndicator(instance.parameters.MET) ~= nil, instance.parameters.MET .. " indicator must be installed");
    mva = core.indicators:create(instance.parameters.MET, isource, instance.parameters.MVAN);
end

function updateStop()
    mva:update(core.UpdateLast);
    if mva.DATA:hasData(NOW) then
        -- check whether trade exists
        local trade, order;
        trade = core.host:findTable("trades"):find("TradeID", instance.parameters.Trade);
        if trade == nil then
            tradeExist = false;
            terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Trade " .. instance.parameters.Trade .. " disappear", instance.bid:date(NOW));
            return ;
        end
        local stopValue, valuemap, success, msg;
        stopValue = mva.DATA[NOW];
        -- check stop value
        if (trade.BS == "B" and stopValue < instance.bid[NOW]) or
           (trade.BS == "S" and stopValue > instance.bid[NOW]) then
            if trade.StopOrderID == "" or trade.StopOrderID == nil then
                valuemap = core.valuemap();
                valuemap.Command = "CreateOrder";
                valuemap.OrderType = "S";
                valuemap.OfferID = trade.OfferID;
                valuemap.AcctID = trade.AccountID;
                valuemap.TradeID = trade.TradeID;
                valuemap.Quantity = trade.Lot;
                valuemap.Rate = stopValue;
                if trade.BS == "B" then
                    valuemap.BuySell = "S";
                else
                    valuemap.BuySell = "B";
                end
                success, msg = terminal:execute(200, valuemap);
                if not(success) then
                    terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed create stop " .. msg, instance.bid:date(NOW));
                end
            else
                if math.abs(trade.Stop - stopValue) >= pipSize then
                    -- stop exists
                    valuemap = core.valuemap();
                    valuemap.Command = "EditOrder";
                    valuemap.AcctID = trade.AccountID;
                    valuemap.OrderID = trade.StopOrderID;
                    valuemap.Rate = stopValue;
                    success, msg = terminal:execute(200, valuemap);
                    if not(success) then
                        terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed create stop " .. msg, instance.bid:date(NOW));
                    end
                end
            end
        end
    end
end
