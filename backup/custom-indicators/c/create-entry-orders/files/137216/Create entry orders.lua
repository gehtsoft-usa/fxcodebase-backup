-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64251

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Trading commands");
    indicator:description("Trading commands");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    
    indicator.parameters:addInteger("distance", "Distance, pips", "", 10);
    
    indicator.parameters:addString("Account", "Account to trade on", "", "");
    indicator.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    indicator.parameters:addDouble("Amount", "Trade Amount", "", 1, 1, 1000000);
end

local OPEN_TRADES = 107;
local distance, offer_id, Account, Amount, bid, ask

function Prepare(nameOnly)
    local name = profile:id();
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
    Account = instance.parameters.Account;
    Amount = instance.parameters.Amount;
    distance = instance.parameters.distance;
    
    stub = instance:addStream("stub", core.Line, "stub", "stub", core.rgb(255, 0, 0), 0);
    offer_id = core.host:findTable("offers"):find("Instrument", instance.source:instrument()).OfferID;
    bid = core.host:execute("getBidPrice");
    ask = core.host:execute("getAskPrice");
    
    core.host:execute("addCommand", OPEN_TRADES, "Open trades");
end

function Update(period)
end

function OpenMarket(offer_id, account_id, order_type, bs, amount, rate)
    local valuemap = core.valuemap();
    valuemap.Command = "CreateOrder";
    valuemap.OfferID = offer_id;
    valuemap.AcctID = account_id;
    valuemap.Quantity = core.host:execute("getTradingProperty", "baseUnitSize", bid:instrument(), account_id);
    valuemap.BuySell = bs;
    valuemap.Rate = rate;
    valuemap.OrderType = order_type;

    local success, msg = terminal:execute(200, valuemap);
    assert(success, msg);
end

function AsyncOperationFinished(cookie, success, message)
    if cookie == OPEN_TRADES then
        OpenMarket(offer_id, Account, "SE", "B", Amount, ask[NOW] + distance * ask:pipSize())
        OpenMarket(offer_id, Account, "SE", "S", Amount, bid[NOW] - distance * ask:pipSize())
    end
end

function round(num, digits)
    if digits and digits > 0 then
        local mult = 10 ^ digits
        return math.floor(num * mult + 0.5) / mult;
    end
    return math.floor(num + 0.5);
end
