-- Id: 3551
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=3857

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

-- Strategy profile initialization routine
function Init()
    strategy:name("MassStopLimit");
    strategy:description("MassStopLimit");

    strategy.parameters:addGroup("Common Parameters");
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addBoolean("AllAcct", "Set Stop/Limit on all accounts", "If Yes, the stop/limit will be set on all accounts, otherwise, one of the accounts should be selected.", true);
    strategy.parameters:addString("Account", "Account to watch", "The strategy will work for the specified account.", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addBoolean("AllOffer", "Set Stop/Limit on all offers", "If Yes, the stop/limit will be set on all offer, otherwise, only specified offer will be used.", true);
    strategy.parameters:addInteger("UpdateInterval", "Run interval, sec", "How often the stop/limit will be checked, time in seconds.", 1);
    strategy.parameters:addBoolean("Overwrite", "Overwrite existing or changed stop/limit", "Overwrite existing or changed stop/limit", true);

    strategy.parameters:addInteger("StartHour", "Start hour", "Start hour", 10);
    strategy.parameters:addInteger("StopHour", "Stop hour", "Stop hour", 12);
    
    strategy.parameters:addGroup("Stop/Limit Parameters");
    strategy.parameters:addInteger("Stop", "Stop", "Stop value in pips", 0, 0, 1000);
    strategy.parameters:addInteger("Limit", "Limit", "Limit value in pips", 0, 0, 1000);
end

-- Parameters block
local AllAcct;
local Account;
local AllOffer;
local UpdateInterval;


local Stop;
local Limit;
local Offer;

local StartH, StopH;

local TIMER_ID = 100

-- Routine
function Prepare(nameOnly)
    Stop = instance.parameters.Stop
    Limit = instance.parameters.Limit
    StartH = instance.parameters.StartHour
    StopH = instance.parameters.StopHour

    local name = profile:id() .. "(" .. instance.bid:instrument() .. ", " .. Stop .. ", " .. Limit .. ")";
    instance:name(name);

    if nameOnly then
        return ;
    end

    AllAcct = instance.parameters.AllAcct;
    Account = instance.parameters.Account;
    AllOffer = instance.parameters.AllOffer
    UpdateInterval = instance.parameters.UpdateInterval;
    Overwrite = instance.parameters.Overwrite;
    Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;

    timerId = core.host:execute ("setTimer", TIMER_ID, UpdateInterval);
end

--------------------------------------------
-- Recalculate margin level and recheck all levels on timer
--------------------------------------------
function CheckTime()
    local T=core.dateToTable(core.now());

    if (StopH>StartH and T.hour>=StartH and T.hour<StopH) or (StopH>StartH and (T.hour>=StartH or T.hour<StopH)) then
        return true;
    else
        return false;
    end
end

function AsyncOperationFinished(cookie, successful, message)

    if cookie == TIMER_ID then
        if CheckTime() then

        if not(core.host:execute("isTableFilled", "accounts")) then
            return false;
        end

        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        while row ~= nil do
            if (AllAcct or row.AccountID == Account) and
               (AllOffer or row.OfferID == Offer) then
               
                --if Stop already set skip it
                if Stop ~= 0 and (row.Stop == 0 or Overwrite) then
                    setStop(row, Stop)
                end

                if Limit ~= 0 and (row.Limit == 0 or Overwrite) then
                    setLimit(row, Limit)
                end
            end
            row = enum:next();  
        end;
       end
    end
end


function setStop(trade, Stop)
    if not instance.parameters.AllowTrade then
        return;
    end
    local pipSize = core.host:findTable("offers"):find("OfferID", trade.OfferID).PointSize; 
    
    --if Stop already set skip it
    if trade.Stop ~= 0 then
        local pips = math.abs(trade.Open - trade.Stop) / pipSize;
        -- Stop
        if math.abs(Stop - pips) < pipSize then
            return
        end
    end
    
    local new = (trade.Stop == 0)
    local valuemap = core.valuemap();
    
     
    if new then
        valuemap.Command = "CreateOrder"
    else
        valuemap.Command = "EditOrder"
        valuemap.OrderID = trade.StopOrderID
    end
    valuemap.OrderType = "S"
    valuemap.AcctID = trade.AccountID
    valuemap.OfferID = trade.OfferID
    valuemap.TradeID = trade.TradeID
    valuemap.BuySell = (trade.BS == "B") and "S" or "B"
    if new then valuemap.Quantity = trade.Lot end
    if (trade.BS == "B") then
        valuemap.Rate = trade.Open - Stop * pipSize
    else
        valuemap.Rate = trade.Open + Stop * pipSize
    end

    success, msg = terminal:execute(101, valuemap);

    if not(success) then
        core.host:trace("Set stop failed:" .. msg);
    end
end

function setLimit(trade, Limit)
    if not instance.parameters.AllowTrade then
        return;
    end
    local pipSize = core.host:findTable("offers"):find("OfferID", trade.OfferID).PointSize; 
    
    --if limit already set skip it
    if trade.Limit ~= 0 then
        local pips = math.abs(trade.Open - trade.Limit) / pipSize;
        if math.abs(Limit - pips) < pipSize then
            return
        end
    end
    
    local new = (trade.Limit == 0)
    local valuemap = core.valuemap();
    
     
    if new then
        valuemap.Command = "CreateOrder"
    else
        valuemap.Command = "EditOrder"
        valuemap.OrderID = trade.LimitOrderID
    end
    valuemap.OrderType = "L"
    valuemap.AcctID = trade.AccountID
    valuemap.OfferID = trade.OfferID
    valuemap.TradeID = trade.TradeID
    valuemap.BuySell = (trade.BS == "B") and "S" or "B"
    if new then valuemap.Quantity = trade.Lot end
    if (trade.BS == "B") then
        valuemap.Rate = trade.Open + Limit * pipSize
    else
        valuemap.Rate = trade.Open - Limit * pipSize
    end
    success, msg = terminal:execute(101, valuemap);

    if not(success) then
        core.host:trace("Set limit failed:" .. msg);
    end
end

-- strategy calculation routine
function Update(id, source, period)
end

