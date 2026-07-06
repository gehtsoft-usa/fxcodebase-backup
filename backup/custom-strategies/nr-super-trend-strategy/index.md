# NR Super Trend Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=59291  
> Forum: 31 · Topic 59291 · 15 post(s)


---

## NR Super Trend Strategy

**Apprentice** · Sat Aug 24, 2013 4:44 am

![NR_Super_Trend Strategy.png](images/88879/NR_Super_Trend%20Strategy.png)



Open Long
Super Trend / Price CrossUnder

Open Short
Super Trend / Price CrossOver

 [NR_Super_Trend Strategy.lua](files/88879/NR_Super_Trend%20Strategy.lua)

For this strategy you need to install Non Repainting Supertrend Indicator.
[viewtopic.php?f=17&t=41453](https://fxcodebase.com/code/viewtopic.php?f=17&t=41453)


---

## Re: NR Super Trend Strategy

**mulligan** · Mon Aug 26, 2013 12:15 pm

Thanks so much for the strategy. It looks like the "show alert" is reversed. That is, it reads up trend when it is actually down and down trend when up.


---

## Re: NR Super Trend Strategy

**Apprentice** · Mon Aug 26, 2013 12:26 pm

Indeed, fixed.


---

## Re: NR Super Trend Strategy

**Raygeek** · Mon May 11, 2015 7:19 am

Hi Apprentice,

The indicator works perfectly on graphics but the strategy does not trigger trade or alert on the indicator change.

May I ask you to have a look or tell me what I might be missing ?

The setup is straightforward, so I am not showing it here.

Thanks a lot.

Raygeek


---

## Re: NR Super Trend Strategy

**Raygeek** · Mon May 11, 2015 9:21 am

Hi again Apprentice,

Don't bother, the strategy is working, it seems that the LuaLib-20130603.exe package that I installed earlier is the culprit.

I reinstalled a clean TS2 and it si working now.

Do you have a LuaLib file to recommend ?

Thanks

Raygeek


---

## Re: NR Super Trend Strategy

**Raygeek** · Mon Jun 29, 2015 4:47 pm

Hi Apprentice,

Would it be possible to combine the NR Supertrend with a test on a MA like this :

BUY : Price is over EMA (x) AND NR Supertrend ( y,z) turns up
CLOSE position on stop/limit reached OR NR Supertrend turns down

SELL : Price is under EMA(x) AND NR Supertrend (y,z) turns down
CLOSE position on stop/limit reached OR NR Supertrend turns up

Thanks a lot and sorry for loosing time and energy on other requests.

Best Regards


---

## Re: NR Super Trend Strategy

**Apprentice** · Tue Jun 30, 2015 3:45 am

Requested can be found here.
[viewtopic.php?f=31&t=62377](https://fxcodebase.com/code/viewtopic.php?f=31&t=62377)


---

## Re: NR Super Trend Strategy

**Raygeek** · Thu Jul 02, 2015 5:11 am

Thank you, Apprentice, should have looked further myself....
Gonna test it.
Best Regards

Raygeek


---

## Re: NR Super Trend Strategy

**Raygeek** · Thu Jul 02, 2015 11:01 am

Hi Apprentice,

I have tested the strategy and need the following changes :

The position OPENING should happen AT THE END of the bar/candle during which Supertrend changes direction WHILE respecting the MA condition.

Unless the price has reached Stop or Target, the CLOSING should happen at the next (also end of bar/candle) supertrend change ALONE, WITHOUT respecting the MA condition.

I need to test against a 300 MA, which seems out of range in the current setup : can you allow for a larger range ?

Hope that I am understandable, if not, let me know, I will try to explain better.
Thanks

Best RegardS

Raygeek


---

## Re: NR Super Trend Strategy

**MC. Trend Trader** · Sun Jul 05, 2015 1:13 am

Hello,

I want to install an order management for 3 positions.

Where exactly and how shall I put this code in this strategy

for Buy trades

Code: [Select all](https://fxcodebase.com/code/)
`if haveTrades("B") or haveTrades("S") then
           return;   
       else
          enter("B", Stop1, Limit1);
          enter("B", Stop2, Limit2);
          enter("B", Stop3, Limit3);
              if ShowAlert then`

and Short trades

Code: [Select all](https://fxcodebase.com/code/)
`if haveTrades("B") or haveTrades("S") then
           return;   
       else
          enter("S", Stop1, Limit1);
          enter("S", Stop2, Limit2);
          enter("S", Stop3, Limit3);`

Nr_Supertrend Strategy

Code: [Select all](https://fxcodebase.com/code/)
`local BAR = true;

function Init() --The strategy profile initialization
    strategy:name("NR Super Trend Strategy");
    strategy:description("");
    -- NG: optimizer/backtester hint
    strategy:setTag("NonOptimizableParameters", "ShowAlert,PlaySound,SoundFile,RecurrentSound,SendMail,Email");

    strategy.parameters:addGroup("Price");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
   
   

    strategy.parameters:addString("TF", "Time frame", "", "m5");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);
   
   
    strategy.parameters:addGroup("Calculation");
    strategy.parameters:addInteger("Period", "Period", "", 10);
    strategy.parameters:addDouble("Multiplier", "Multiplier", "", 4);      
   
    strategy.parameters:addGroup("Strategy Parameters");
    strategy.parameters:addString("Direction", "Type of signal", "", "direct");
    strategy.parameters:addStringAlternative("Direction", "direct", "", "direct");
    strategy.parameters:addStringAlternative("Direction", "reverse", "", "reverse");

    strategy.parameters:addGroup("Time Parameters");
    strategy.parameters:addString("StartTime", "Start Time for Trading", "", "00:00:00");
    strategy.parameters:addString("StopTime", "Stop Time for Trading", "", "24:00:00");

    strategy.parameters:addBoolean("UseMandatoryClosing", "Use Mandatory Closing", "", false);
    strategy.parameters:addString("ExitTime", "Mandatory Closing  Time", "", "23:59:00");
    strategy.parameters:addInteger("ValidInterval", "Valid interval for operation in second", "", 60);

    CreateTradingParameters();
end

function CreateTradingParameters()
    strategy.parameters:addGroup("Trading Parameters");

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false);
    -- NG: optimizer/backtester hint
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("ALLOWEDSIDE", "Allowed side", "Allowed side for trading or signaling, can be Sell, Buy or Both", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell");

    strategy.parameters:addBoolean("AllowMultiple", "Allow Multiple", "", true);
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 100);
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false);
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false);
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false);

    strategy.parameters:addGroup("Alerts");
    strategy.parameters:addBoolean("ShowAlert", "ShowAlert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", true);
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", false);
    strategy.parameters:addString("Email", "Email", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local Source;

local SoundFile = nil;
local RecurrentSound = false;
local ALLOWEDSIDE;
local AllowMultiple;
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

local Period,Multiplier;

local Indicator={};
local Short={};
local Source;

local Direction;
local UseMandatoryClosing;
local ValidInterval;

local first;
local Price;

-- Don't need to store hour + minute + second for each time
local OpenTime, CloseTime, ExitTime;

--
function Prepare(nameOnly)

   
   
    UseMandatoryClosing = instance.parameters.UseMandatoryClosing;
   Period= instance.parameters.Period;
   Multiplier= instance.parameters.Multiplier;
   

    -- NG: replace string comparison everytime in future.
    Direction = instance.parameters.Direction == "direct";
    ValidInterval = instance.parameters.ValidInterval;

    Indicator[1] = nil;

    -- NG: check TF1/TF2 instead of TF
    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick");
 

    local name;
    name = profile:id() .. "( " .. instance.bid:name();
    local i;
   
   
 
      name = name .. ", " ..  Period.. ", " .. Multiplier;
   

       assert(core.indicators:findIndicator("NR_SUPER_TREND") ~= nil, "Please, download and install NR_SUPER_TREND.LUA indicator");         
   
    name = name  ..  " )";
    instance:name(name);

    -- NG: parsing of the time is moved to separate function
    local valid;
    OpenTime, valid = ParseTime(instance.parameters.StartTime);
    assert(valid, "Time " .. instance.parameters.StartTime .. " is invalid");
    CloseTime, valid = ParseTime(instance.parameters.StopTime);
    assert(valid, "Time " .. instance.parameters.StopTime .. " is invalid");
    ExitTime, valid = ParseTime(instance.parameters.ExitTime);
    assert(valid, "Time " .. instance.parameters.ExitTime .. " is invalid");

    PrepareTrading();

    if nameOnly then
        return ;
    end

    Source = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar");
   
   
   
   
    Indicator[1] = core.indicators:create("NR_SUPER_TREND", Source, Period, Multiplier , core.rgb(0, 255, 0) , core.rgb(255, 0, 0)   );
   Short[1] = Indicator[1]:getStream(0);
   
   first=Short[1]:first();
   

   
    if UseMandatoryClosing then
        core.host:execute("setTimer", 100, math.max(ValidInterval / 2, 1));
    end
end

function PrepareTrading()
    AllowMultiple =  instance.parameters.AllowMultiple;
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
    if AllowTrade then
        Account = instance.parameters.Account;
        Amount = instance.parameters.Amount;
        BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account);
        Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;
        CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account);
        SetLimit = instance.parameters.SetLimit;
        Limit = instance.parameters.Limit;
        SetStop = instance.parameters.SetStop;
        Stop = instance.parameters.Stop;
        TrailingStop = instance.parameters.TrailingStop;
    end
end

-- NG: create a function to parse time
function ParseTime(time)
    local Pos = string.find(time, ":");
    local h = tonumber(string.sub(time, 1, Pos - 1));
    time = string.sub(time, Pos + 1);
    Pos = string.find(time, ":");
    local m = tonumber(string.sub(time, 1, Pos - 1));
    local s = tonumber(string.sub(time, Pos + 1));
    return (h / 24.0 +  m / 1440.0 + s / 86400.0),                          -- time in ole format
           ((h >= 0 and h < 24 and m >= 0 and m < 60 and s >= 0 and s < 60) or (h == 24 and m == 0 and s == 0)); -- validity flag
end

function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.
    if AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
            return ;
        end
    end

 
    if id ~= 1 then
        return;
    end

     
   
    Indicator[1]:update(core.UpdateLast);
   

    if period < first +1  then
        return ;
    end

    local now = core.host:execute("getServerTime");
    now = now - math.floor(now);

    if now >= OpenTime and now <= CloseTime then
   
   
   
        if   Indicator[1].DATA:colorI(period) ==  core.rgb(255, 0, 0)
      and   Indicator[1].DATA:colorI(period-1) ~=  core.rgb(255, 0, 0)
      then
       
      
            if Direction then
                BUY();
            else
                SELL();
            end
         
      elseif  Indicator[1].DATA:colorI(period) ==  core.rgb(0, 255, 0)
      and   Indicator[1].DATA:colorI(period-1) ~=  core.rgb(0, 255, 0)
       then
            if Direction then
                SELL();
            else
                BUY();
            end
        end
      
      
   
             
    end
end

-- NG: Introduce async function for timer/monitoring for the order results
function ExtAsyncOperationFinished(cookie, success, message)
    if cookie == 100 then
        -- timer
        if UseMandatoryClosing and AllowTrade then
            now = core.host:execute("getServerTime");
            -- get only time
            now = now - math.floor(now);
            -- check whether the time is in the exit time period
            if now >= ExitTime and now < ExitTime + ValidInterval then
                if not(checkReady("trades")) or not(checkReady("orders")) then
                    return ;
                end
                if haveTrades("S") then
                    exit("S");
                    Signal ("Close Short");
                end
                if haveTrades("B") then
                   exit("B");
                   Signal ("Close Long");
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
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--

function BUY()
    if AllowTrade then
        if haveTrades("B") and not AllowMultiple then
            if  haveTrades("S")   then
                exit("S");
                Signal ("Close Short");
            end
            return;
        end

        if ALLOWEDSIDE == "Sell" then
            if haveTrades("S")   then
                exit("S");
                Signal ("Close Short");
            end
            return;
        end

        if haveTrades("S") then
            exit("S");
            Signal ("Close Short");
        end

        enter("B");
        Signal ("Open Long");
    elseif ShowAlert then
        Signal ("Up Trend");
    end
end

function SELL()
    if AllowTrade then
        if haveTrades("S") and not AllowMultiple then
            if haveTrades("B") then
                exit("B");
                Signal ("Close Long");
            end
            return;
        end

        if ALLOWEDSIDE == "Buy"  then
            if  haveTrades("B") then
                exit("B");
                Signal ("Close Long");
            end
            return;
        end

        if haveTrades("B") then
            exit("B");
            Signal ("Close Long");
        end

        enter("S");
        Signal ("Open Short");
    else
        Signal ("Down Trend");
    end
end

function Signal(Label)
    if ShowAlert then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW],  Label, instance.bid:date(NOW));
    end

    if SoundFile ~= nil then
        terminal:alertSound(SoundFile, RecurrentSound);
    end

    if Email ~= nil then
        terminal:alertEmail(Email, Label, profile:id() .. "(" .. instance.bid:instrument() .. ")" .. instance.bid[NOW]..", " .. Label..", " .. instance.bid:date(NOW));
    end
end

function checkReady(table)
    return core.host:execute("isTableFilled", table);
end

function tradesCount(BuySell)
    local enum, row;
    local count = 0;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    -- NG: to get the true count we must NOT stop when count is not a zero or
    -- the function will return 1 or 0 only and will work as "haveTrades"
    -- while count == 0 and row ~= nil do
    while row ~= nil do
        if row.AccountID == Account and
           row.OfferID == Offer and
           (row.BS == BuySell or BuySell == nil) then
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
    while (not found) and (row ~= nil) do
        if row.AccountID == Account and
           row.OfferID == Offer and
           (row.BS == BuySell or BuySell == nil) then
           found = true;
        end
        row = enum:next();
    end
    return found;
end

-- enter into the specified direction
function enter(BuySell)
    if not(AllowTrade) then
        return true;
    end

    -- do not enter if position in the
    -- specified direction already exists
    if tradesCount(BuySell) > 0 and not  AllowMultiple  then
        return true;
    end

    local valuemap, success, msg;
    valuemap = core.valuemap();

    valuemap.OrderType = "OM";
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    valuemap.Quantity = Amount * BaseSize;
    valuemap.BuySell = BuySell;

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
        valuemap.EntryLimitStop = "Y";
    end

    success, msg = terminal:execute(200, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        return false;
    end

    return true;
end

-- exit from the specified direction
function exit(BuySell)
    if not(AllowTrade) then
        return true;
    end

    local valuemap, success, msg;

    if tradesCount(BuySell) > 0 then
        valuemap = core.valuemap();

        -- switch the direction since the order must be in oppsite direction
        if BuySell == "B" then
            BuySell = "S";
        else
            BuySell = "B";
        end
        valuemap.OrderType = "CM";
        valuemap.OfferID = Offer;
        valuemap.AcctID = Account;
        valuemap.NetQtyFlag = "Y";
        valuemap.BuySell = BuySell;
        success, msg = terminal:execute(201, valuemap);

        if not(success) then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
            return false;
        end
        return true;
    end
    return false;
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");`

Thanks in advance

MC.Trend Trader


---

## Re: NR Super Trend Strategy

**Apprentice** · Mon Jul 06, 2015 4:34 am

Unfortunately you can not copy / past code.
 NR Super Trend Strategy uses a simple enter funkciju.
 enter("B")
You use
enter("B", Stop1, Limit1);
enter("B", Stop2, Limit2);
enter("B", Stop3, Limit3);

You can use enter function from my MCP Strategy Template.
enter(BuySell,Instrument,Amount, Limit , SetStop ,Stop , TrailingStop)
[viewtopic.php?f=28&t=2712](https://fxcodebase.com/code/viewtopic.php?f=28&t=2712)
Some modifications will be required.


---

## Re: NR Super Trend Strategy

**MC. Trend Trader** · Mon Jul 06, 2015 4:48 pm

Hello Apprentice

I want this Position/Ordermanager in NR_Supertrend Strategy.

Here is a example Ordermanagement strategy that works, but I can not get to rewrite it for this strategy, it just will not work properly,

Can you Help?

Code: [Select all](https://fxcodebase.com/code/)
`function Init() --The strategy profile initialization
    strategy:name("Order Management");
    strategy:description("");
    strategy:setTag("NonOptimizableParameters", "ShowAlert,PlaySound,SoundFile,RecurrentSound,SendMail,Email");

    strategy.parameters:addGroup("Price");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
   
   if not BAR then
    strategy.parameters:addString("Price", "Price Source", "", "close");
    strategy.parameters:addStringAlternative("Price", "OPEN", "", "open");
    strategy.parameters:addStringAlternative("Price", "HIGH", "", "high");
    strategy.parameters:addStringAlternative("Price", "LOW", "", "low");
    strategy.parameters:addStringAlternative("Price","CLOSE", "", "close");
    strategy.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    strategy.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    strategy.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");   
   end
 
    strategy.parameters:addString("TF", "Time frame", "", "m5");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);
   
    strategy.parameters:addGroup("Strategy Parameters");

    strategy.parameters:addInteger("amount", "Amount in lots", "", 1, 1, 100);

    strategy.parameters:addInteger("Limit1", "1st limit order (in pips)", "", 10, 1, 10000);
    strategy.parameters:addInteger("Limit2", "2nd limit order (in pips)", "", 20, 1, 10000);
    strategy.parameters:addInteger("Limit3", "3d limit order (in pips)", "", 30, 1, 10000);

    strategy.parameters:addInteger("Stop1", "1st stop order (in pips)", "", 10, 1, 10000);
    strategy.parameters:addInteger("Stop2", "2nd stop order (in pips)", "", 20, 1, 10000);
    strategy.parameters:addInteger("Stop3", "3d stop order (in pips)", "", 30, 1, 10000);

--    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false);

    CreateTradingParameters();

end

function CreateTradingParameters()
    strategy.parameters:addGroup("Trading Parameters");

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("ALLOWEDSIDE", "Allowed side", "Allowed side for trading or signaling, can be Sell, Buy or Both", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell");

--    strategy.parameters:addBoolean("AllowMultiple", "Allow Multiple", "", true);
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);

    strategy.parameters:addGroup("Alerts");
    strategy.parameters:addBoolean("ShowAlert", "ShowAlert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", true);
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", false);
    strategy.parameters:addString("Email", "Email", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local Source;

local SoundFile = nil;
local RecurrentSound = false;
local ALLOWEDSIDE;
local AllowMultiple;
local AllowTrade;
local Offer;
local CanClose;
local Account;
local Amount;
local Limit;
local Stop;
local TrailingStop;
local ShowAlert;
local Email;
local SendEmail;
local BaseSize;

local Indicator={};
local Short={};
local Source;

local first;
local Price;

local FastMA;
local SlowMA;

local Limit1, Limit2, Limit3;
local Stop1, Stop2, Stop3;

--
function Prepare(nameOnly)

   if not BAR then
    Price = instance.parameters.Price;
   end
   
    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick");
 

    local name;
    name = profile:id() .. "( " .. instance.bid:name() .. ")";
    local i;

    instance:name(name);

    PrepareTrading();

    if nameOnly then
        return ;
    end

    Source = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "close");
   
    FastMA = core.indicators:create("MVA", Source, 5);
    SlowMA = core.indicators:create("MVA", Source, 20);

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

    ExtSetupSignal(profile:id() .. ":", ShowAlert);
    ExtSetupSignalMail(name);

    AllowTrade = instance.parameters.AllowTrade;
    if AllowTrade then
        Account = instance.parameters.Account;
        Amount = instance.parameters.amount;
        BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account);
        Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;
        CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account);
        Limit1 = instance.parameters.Limit1;
        Limit2 = instance.parameters.Limit2;
        Limit3 = instance.parameters.Limit3;
        Stop1 = instance.parameters.Stop1;
        Stop2 = instance.parameters.Stop2;
        Stop3 = instance.parameters.Stop3;
--        TrailingStop = instance.parameters.TrailingStop;
    end
end

function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.

    -- update moving average
    FastMA:update(core.UpdateLast);
    SlowMA:update(core.UpdateLast);

    if AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
            return ;
        end
    end

    if period < 1 or not(SlowMA.DATA:hasData(period - 1)) then
        return ;
    end

   -- specify your conditions for entering the market (long):
   if core.crossesOver(FastMA.DATA, SlowMA.DATA, period) then
       if haveTrades("B") or haveTrades("S") then
           return;   
       else
          enter("B", Stop1, Limit1);
          enter("B", Stop2, Limit2);
          enter("B", Stop3, Limit3);
              if ShowAlert then
                  ExtSignal(source, period, "BUY", SoundFile, Email, RecurrentSound);
              end

       end

   -- specify your conditions for entering the market (short):
   elseif core.crossesOver(SlowMA.DATA, FastMA.DATA, period) then
       if haveTrades("B") or haveTrades("S") then
           return;   
       else
          enter("S", Stop1, Limit1);
          enter("S", Stop2, Limit2);
          enter("S", Stop3, Limit3);
              if ShowAlert then
                  ExtSignal(source, period, "SELL", SoundFile, Email, RecurrentSound);
              end
       end
   end

end

function ExtAsyncOperationFinished(cookie, success, message)
    if cookie == 100 then
        -- timer
    elseif cookie == 200 and not success then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. message, instance.bid:date(instance.bid:size() - 1));
    elseif cookie == 201 and not success then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Close order failed" .. message, instance.bid:date(instance.bid:size() - 1));
    end
end

--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--

function checkReady(table)
    return core.host:execute("isTableFilled", table);
end

function haveTrades(BuySell)
    local enum, row;
    local found = false;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while (not found) and (row ~= nil) do
        if row.AccountID == Account and
           row.OfferID == Offer and
           (row.BS == BuySell or BuySell == nil) then
           found = true;
        end
        row = enum:next();
    end
    return found;
end

-- enter into the specified direction
function enter(BuySell, Stop, Limit)
    if not(AllowTrade) then
        return true;
    end

    local valuemap, success, msg;
    valuemap = core.valuemap();

    valuemap.OrderType = "OM";
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    valuemap.Quantity = Amount * BaseSize;
    valuemap.BuySell = BuySell;

   local StopTrade = Stop;
   local LimitTrade = Limit;

    -- add stop/limit

    valuemap.PegTypeStop = "O";
        if BuySell == "B" then
            valuemap.PegPriceOffsetPipsStop = -StopTrade;
        else
            valuemap.PegPriceOffsetPipsStop = StopTrade;
        end

 --   if TrailingStop then
 --       valuemap.TrailStepStop = 1;
 --    end

    valuemap.PegTypeLimit = "O";
        if BuySell == "B" then
            valuemap.PegPriceOffsetPipsLimit = LimitTrade;
        else
            valuemap.PegPriceOffsetPipsLimit = -LimitTrade;
        end

    if (not CanClose) then
        valuemap.EntryLimitStop = "Y";
    end

    success, msg = terminal:execute(200, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        return false;
    end

    return true;
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");`

Regards

MC. Trend Trader


---

## Re: NR Super Trend Strategy

**Apprentice** · Mon Jul 13, 2015 4:49 am

Your request is added to the development list.


---

## Re: NR Super Trend Strategy

**Stance** · Tue Jul 14, 2015 1:48 am

Would it be possible to add Relative Currency Strength ( [viewtopic.php?f=17&t=59518&hilit=currency+strength](https://fxcodebase.com/code/viewtopic.php?f=17&t=59518&hilit=currency+strength) ) to this strategy so that it would only take a trade if it matches the currency strength?

ie go long on AUDUSD only if AUD is stronger than USD.


---

## Re: NR Super Trend Strategy

**Apprentice** · Fri Jan 26, 2018 1:52 pm

The strategy was revised and updated.
