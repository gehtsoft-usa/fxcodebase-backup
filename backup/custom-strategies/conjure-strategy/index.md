# Conjure strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=65680  
> Forum: 31 · Topic 65680 · 9 post(s)


---

## Conjure strategy

**Apprentice** · Sun Jan 28, 2018 9:04 am

![EURUSD m1 (01-28-2018 1315).png](images/117318/EURUSD%20m1%20%2801-28-2018%201315%29.png)



Lets say EUR/USD is on 1.23350
if the price goes up for 50 pips open a BUY position.
if the price moves up for 50 more pips open a second BUY position.
etc
for every 50 pips open a new BUY position.

The secret is to be able to have 2 accounts.
1 for buy
1 for sell

Close all positions when used margin reach balance,
or when no more positions are able to open because of used margin.

 [conjure strategy.lua](files/117318/conjure%20strategy.lua)


---

## Re: Conjure strategy

**conjure** · Wed Feb 07, 2018 10:12 am

Apprentice Is it possible to add an option , to close all positions when profit is above a specific percentage of balance? Like this strategy bellow?
[http://fxcodebase.com/code/viewtopic.php?f=31&t=2901&start=80#p114560](https://fxcodebase.com/code/viewtopic.php?f=31&t=2901&start=80#p114560)


---

## Re: Conjure strategy

**Apprentice** · Mon Feb 12, 2018 11:27 am

[conjure strategy.lua](files/117736/conjure%20strategy.lua)

Try this version.


---

## Re: Conjure strategy

**conjure** · Mon Feb 12, 2018 2:07 pm

I really like it.
Thank you for your effort my friend..

Can i ask you one last thing?

Can you add an option to open both positions (Buy and Sell)
when parameters (+10 pip) meet ,
so i don't have to load it twice for every pair?

something like that

Code: [Select all](https://fxcodebase.com/code/)
`strategy.parameters:addBoolean("is_sell", "Is Sell", "", true);
    strategy.parameters:addBoolean("is_buy", "Is Buy", "", true);`


---

## Re: Conjure strategy

**conjure** · Mon Feb 12, 2018 2:08 pm

I really like it.
Thank you for your effort my friend..

Can i ask you one last thing?

Can you add an option to open both positions (Buy and Sell)
when parameters (+10 pip) meet ,
so i don't have to load it twice for every pair?

something like that

Code: [Select all](https://fxcodebase.com/code/)
`strategy.parameters:addBoolean("is_sell", "Is Sell", "", true);
    strategy.parameters:addBoolean("is_buy", "Is Buy", "", true);`


---

## Re: Conjure strategy

**conjure** · Mon Feb 19, 2018 5:02 pm

Apprentice is it possible to modify my second strategy so i can open the trades (Buy and Sell)
in one account that supports hedging , so i can back test the strategy?

what i need is this.

Lets say EUR/USD is on 1.23350

if the price goes up for 50 pips open a BUY position.
if the price moves up for 50 more pips open a second BUY position.etc
for every 50 pips open a new BUY position.

if the price goes down for 50 pips open a SELL position.
if the price moves up for 50 more pips open a second SELL position.etc
for every 50 pips open a new SELL position.

that means that if the price move 50 pip over the original price 1.23350 ,it will open a BUY position.Now if it moves 50 pip down from original price it will open SELL position.
The account must support hedging.

Close all positions when profit is above a specific percentage of balance.


---

## Re: Conjure strategy

**conjure** · Tue Feb 20, 2018 9:28 am

Apprentice i messed with the code and i made it do what i want.
My only problem i dont know how to fix is how can i reset the parameters every time that positions are closed so it can start from current price? Can you help me on that ?

Code: [Select all](https://fxcodebase.com/code/)
`-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=65680

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          [[email protected]](https://fxcodebase.com/cdn-cgi/l/email-protection)   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

local Modules = {};

function Init()
    strategy:name("Conjure Strategy");
    strategy:description("");

    strategy.parameters:addBoolean("is_buy", "Is Buy", "", true);
    strategy.parameters:addDouble("step", "Step", "", 50);
    strategy.parameters:addDouble("step2", "Step2", "", 50);
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);   
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 100);
    strategy.parameters:addDouble("ProfitLevel", "Profit level for close orders in the account currency", "", 0);
    strategy.parameters:addString("ProfitType", "Profit Type of level for close orders", "", "Fixed");
    strategy.parameters:addStringAlternative("ProfitType", "Fixed", "", "Fixed");
    strategy.parameters:addStringAlternative("ProfitType", "Percentage of balance", "", "Balance");
   
    strategy.parameters:addString("LevelType", "Type of profit level", "", "ABOVE");
    strategy.parameters:addStringAlternative("LevelType", "ABOVE", "", "ABOVE");
    strategy.parameters:addStringAlternative("LevelType", "BELOW", "", "BELOW");
end

local is_buy;
local step;
local step2;
local AllowTrade;
local Account;
local Amount;
local Offer;

function Prepare(name_only)
    for _, module in pairs(Modules) do module:Prepare(nameOnly); end
    instance:name(profile:id() .. "(" .. instance.bid:name() ..  ")");
    if name_only then return ; end

    local profitlevel = instance.parameters.ProfitLevel
    assert(instance.parameters.ProfitType ~= "Balance" or (profitlevel >= 0 and profitlevel <= 100 ), "Incorrect value of the Profit Level. 0 <= Profit Level <= 100");

    is_buy = instance.parameters.is_buy;
    step = instance.parameters.step * instance.bid:pipSize();
    step2 = instance.parameters.step2 * instance.ask:pipSize();
    AllowTrade = instance.parameters.AllowTrade;
    Account = instance.parameters.Account;
    Amount = instance.parameters.Amount;
    BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account);
    Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;

    ExtSubscribe(1, nil, "t1", not is_buy, "tick");
end

local initial_price;
local initial_price2;
function ExtUpdate(id, source, period)
    if initial_price == nil then
        initial_price = source:tick(NOW);
    end
    if is_buy then
        if source:tick(NOW) - initial_price >= step then
            initial_price = initial_price + step;
            MarketOrder("B");
        end
    if initial_price2 == nil then
        initial_price2 = source:tick(NOW);
    end
        if initial_price2 - source:tick(NOW) >= step2 then
            initial_price2 = initial_price2 - step2;
            MarketOrder("S");
        end
    end
    local account = core.host:findTable("accounts"):find("AccountID", Account);
    local mmr = core.host:execute("getTradingProperty", "MMR", instance.bid:instrument(), Account);
    local emr = core.host:execute("getTradingProperty", "EMR", instance.bid:instrument(), Account);
    local margin_needed = math.max(emr, mmr) * Amount;
    if account.UsedMargin >= account.Balance or account.UsableMargin < margin_needed then
        local offer_id = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;
        CloseAll(offer_id, Account, "B");
        CloseAll(offer_id, Account, "S");
    end
    ControlProfit(id, source, period);
end

-- -----------------------------------------------------------------------
-- Return count of opened trades for spicific direction
-- (both directions if BuySell parameters is 'nil')
-- -----------------------------------------------------------------------
function haveTrades(BuySell)
    local enum, row;
    local found = false;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while (not found) and (row ~= nil) do
        if row.AccountID == Account and
           row.Instrument == instance.bid:instrument() and
           (row.BS == BuySell or BuySell == nil) then
           found = true;
        end
        row = enum:next();
    end

    return found
end

-- -----------------------------------------------------------------------
--  Exit from the specified direction
-- -----------------------------------------------------------------------
function exit(BuySell, row)
    if not(AllowTrade) then
        return ;
    end

    local valuemap, success, msg;
    if haveTrades(BuySell) then
        valuemap = core.valuemap();

        -- switch the direction since the order must be in oppsite direction
        if BuySell == "B" then
            BuySell = "S";
        else
            BuySell = "B";
        end
        valuemap.OrderType = "CM";
        valuemap.OfferID=row.OfferID;
        valuemap.AcctID = Account;
        valuemap.NetQtyFlag = "N";
        valuemap.TradeID=row.TradeID;
        valuemap.Quantity=row.Lot;
        valuemap.BuySell = BuySell;
        success, msg = terminal:execute(101, valuemap);

        if not(success) then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        end
    end
end

function ControlProfit(id, source, period)
    if haveTrades() then
        local trades = core.host:findTable("trades");
        local enum = trades:enumerator();
        local PL=0;
        while true do
            local row = enum:next();
            if row == nil then break end

            if row.AccountID == Account and row.Instrument==instance.bid:instrument() then
                if row.BS == 'B' then
                    PL=PL+row.GrossPL;
                elseif row.BS == 'S' then
                    PL=PL+row.GrossPL;
                end
            end
        end
        local profitLevel =  instance.parameters.ProfitLevel;
        local currentBalance = core.host:findTable("accounts"):find("AccountID", Account).Balance;
        if (instance.parameters.ProfitType == "Balance") then
            profitLevel = currentBalance * instance.parameters.ProfitLevel / 100;
        end

        if (PL >= profitLevel and instance.parameters.LevelType=="ABOVE") or (PL<=profitLevel and instance.parameters.LevelType=="BELOW") then
            local enum = trades:enumerator();
            while true do
                local row = enum:next();
                if row == nil then break end
                if row.AccountID == Account and row.Instrument==instance.bid:instrument() then
                    if row.BS == 'B' then
                        if AllowTrade then
                            exit('B',row);
                                                 exit('S',row);

                        end
                    elseif row.BS == 'S' then
                        if AllowTrade then
                                              exit('B',row);

                            exit('S',row);
                        end
                    end
                end
            end
        end
    end
end

function CloseAll(offer_id, account_id, bs)
    local valuemap;
    valuemap = core.valuemap();
    valuemap.Command = "CreateOrder";
    valuemap.OrderType = "CM";
    valuemap.OfferID = offer_id;
    valuemap.BuySell = bs;
    valuemap.AcctID = account_id;
    valuemap.NetQtyFlag = "y";
    local success, msg;
    success, msg = terminal:execute(100, valuemap);
    assert(success, msg);
end

function MarketOrder(BuySell)
    local valuemap = core.valuemap();
    valuemap.Command = "CreateOrder";
    valuemap.OrderType = "OM";
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    valuemap.Quantity = Amount * BaseSize;
    valuemap.BuySell = BuySell;

    local success, msg = terminal:execute(200, valuemap);
    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Open order failed" .. msg, instance.bid:date(NOW));
        return false;
    end

    return true;
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");`


---

## Re: Conjure strategy

**Apprentice** · Mon Mar 05, 2018 11:27 am

Your request is added to the development list under Id Number 4064


---

## Re: Conjure strategy

**Apprentice** · Tue Mar 06, 2018 3:43 pm

[conjure strategy.lua](files/118063/conjure%20strategy.lua)

Try this version.
