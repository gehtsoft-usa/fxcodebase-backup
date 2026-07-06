-- Id: 3682
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=3968

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
    strategy:name("StopLimitAlert");
    strategy:description("StopLimitAlert");
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert,Account,CanTrade,Email,SendEmail");
    strategy:setTag("Version", "1.1");

    strategy.parameters:addGroup("Common Parameters");
    strategy.parameters:addBoolean("AllAcct", "Check Stop/Limits on all accounts", "If Yes, the Stop/Limits will be checked on all accounts, otherwise, one of the accounts should be selected.", true);
    strategy.parameters:addString("Account", "Account to watch", "The strategy will work for the specified account.", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addBoolean("AllOffer", "Check stop/limit on all offers", "If Yes, the stop/limit will be checked for all offers, otherwise, only specified offer will be used.", true);
    strategy.parameters:addInteger("UpdateInterval", "Check interval, sec", "How often the margin will be checked, time in seconds.", 10);
    
    strategy.parameters:addGroup("Notification");
    strategy.parameters:addString("Email", "Email", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

-- Parameters block
local AllAcct;
local Account;
local AllOffer
local Offer;
local UpdateInterval;

local Email;

local TIMER_ID = 100

local stops, limits = {}, {}

-- Routine
function Prepare(nameOnly)
    local name = profile:id();
    instance:name(name);

    if nameOnly then
        return ;
    end

    Email = instance.parameters.Email;
    assert(Email ~= "", "E-mail address must be specified");

    AllAcct = instance.parameters.AllAcct;
    Account = instance.parameters.Account;
    AllOffer = instance.parameters.AllOffer;
    UpdateInterval = instance.parameters.UpdateInterval;

    if not AllOffer then
        Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;
    end
    
    local enum = core.host:findTable("trades"):enumerator();
    local row = enum:next();
    while row ~= nil do
        if (AllAcct or row.AccountID == Account) and
           (AllOffer or row.OfferID == Offer) then
           
            if row.Stop ~= 0 then
                stops[row.StopOrderID] = true
            end

            if row.Limit ~= 0 then
                limits[row.LimitOrderID] = true
            end
        end
        row = enum:next();  
    end;

    local enum = core.host:findTable("orders"):enumerator();
    local row = enum:next();
    while row ~= nil do
        if (AllAcct or row.AccountID == Account) and
           (AllOffer or row.OfferID == Offer) and
           (row.NetQuantity) then
            if row.Type == 'SE' then
                stops[row.OrderID] = true
            end
            if row.Type == 'LE' then
                limits[row.OrderID] = true
            end
        end
        row = enum:next();  
    end;
    
    
    timerId = core.host:execute ("setTimer", TIMER_ID, UpdateInterval);
end

--------------------------------------------
-- Recalculate margin level and recheck all levels on timer
--------------------------------------------
function AsyncOperationFinished(cookie, successful, message)
    if cookie == TIMER_ID then
        local enum = core.host:findTable("closed trades"):enumerator();
        local row = enum:next();
        while row ~= nil do
            if (AllAcct or row.AccountID == Account) and
               (AllOffer or row.OfferID == Offer) then 
                local orderID = row.CloseOrderID

                if stops[orderID] ~= nil then
                    alertEmail(orderID, "Stop")
                    stops[orderID] = nil
                end

                if limits[orderID] ~= nil then
                    alertEmail(orderID, "Limit")
                    limits[orderID] = nil
                end
            end
            row = enum:next();
        end
        
        -- Mark all stop/limits as non checked
        for id, s in pairs(stops) do stops[id] = false end
        for id, l in pairs(limits) do limits[id] = false end
        
        -- Look through "trades" and mark already stoped stop/limits
        -- and insert new stop/limits.
        enum = core.host:findTable("trades"):enumerator();
        row = enum:next();
        while row ~= nil do
            if (AllAcct or row.AccountID == Account) and
               (AllOffer or row.OfferID == Offer) then
               
                if row.Stop ~= 0  then stops[row.StopOrderID] = true end
                if row.Limit ~= 0 then limits[row.LimitOrderID] = true end
            end
            row = enum:next();  
        end;
        -- Look through "orders" and mark already stoped stop/limits
        -- and insert new stop/limits.
        enum = core.host:findTable("orders"):enumerator();
        row = enum:next();
        while row ~= nil do
            if (AllAcct or row.AccountID == Account) and
               (AllOffer or row.OfferID == Offer) and
               (row.NetQuantity) then
               
                if row.Type == 'SE' then stops[row.OrderID] = true end
                if row.Type == 'LE' then limits[row.OrderID] = true end
            end
            row = enum:next();  
        end;
        
        local stopstr = ""
        local limitstr = ""
        for id, s in pairs(stops) do 
            if not s then stops[id] = nil end
            stopstr = stopstr .. id .. ","
        end
        for id, l in pairs(limits) do 
            if not l then 
                limits[id] = nil
            end
            limitstr = limitstr .. id .. ","
        end
        
        core.host:trace("Stops:" .. stopstr)
        core.host:trace("Limits:" .. limitstr)
    end
end

-- strategy calculation routine
function Update(id, source, period)
end

-- ---------------------------------------------------------
-- Formats the email subject and text
-- @param source   The signal source
-- @param period    The number of the period
-- @param message   The rest of the message to be added to the signal
-- ---------------------------------------------------------
function alertEmail(CloseOrderID, _type)
    --format email subject
	local subject = "StopLimitAlert: Trade(s) closed by " .. _type;
	
    --format email text
	local delim = "\013\010";
    local tdelim = "-------------------------\013\010";
    
    local text = ''
    
    local enum = core.host:findTable("closed trades"):enumerator();
    local trade = enum:next();
    while trade ~= nil do
        if trade.CloseOrderID == CloseOrderID then
            local acctDescr = "Account#: " .. trade.AccountID
            local tradeDescr = "Trade#: " .. trade.TradeID
            local instrDescr = "Instrument: " .. trade.Instrument
            local plDescr = "P/L: " .. trade.GrossPL
            local bsDescr = "BS: " .. (trade.BS == "B" and "Buy" or "Sell")
            local amountDescr = "Amount: " .. trade.AmountK
            local ttime = core.dateToTable(trade.CloseTime);
            local dateDescr = "Time: " .. string.format("%02i/%02i %02i:%02i", ttime.month, ttime.day, ttime.hour, ttime.min);	
            text = text .. 
                         acctDescr    .. delim ..
                         tradeDescr   .. delim .. 
                         instrDescr   .. delim .. 
                         plDescr      .. delim .. 
                         bsDescr      .. delim ..
                         amountDescr  .. delim ..
                         dateDescr    .. delim ..
                         tdelim;
        end
        trade = enum:next();  
    end;
    --core.host:trace(subject .. ":" .. text)                   
	terminal:alertEmail(Email, subject, text);
end
    
