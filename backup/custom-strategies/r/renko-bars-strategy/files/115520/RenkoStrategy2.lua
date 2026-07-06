-- Id: 19316
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=60750

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init() --The strategy profile initialization
    strategy:name("Renko Bar Strategy");
    strategy:description("Enters a position whenever the renko changes direction by a certain number of bars.");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");
	
	strategy.parameters:addGroup("Renko");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
	strategy.parameters:addString("TF", "Time frame", "The timeframe for the renko. It is best to leave this as fine as possible (m1). Tick is currently not supported.", "m1");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);
    strategy.parameters:addInteger("Step", "Brick Size", "", 100);
    strategy.parameters:addBoolean("PrintDebug", "Print Debug", "", false);
	
    strategy.parameters:addGroup("Strategy Parameters");
    strategy.parameters:addInteger("BarCount", "Number of Bars", "The number of bars in a new direction for it to generate a signal.", 3, 1, 100);
    strategy.parameters:addString("Direction", "Type of signal", "", "direct");
    strategy.parameters:addStringAlternative("Direction", "direct", "", "direct");
    strategy.parameters:addStringAlternative("Direction", "reverse", "", "reverse");

    strategy.parameters:addBoolean("CloseOpposite", "Close at first opposite brick", "", true);

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

    strategy.parameters:addBoolean("CloseOnOpposite", "Close On Opposite", "", true);
    strategy.parameters:addBoolean("AllowMultiple", "Allow Multiple", "", true);
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000);
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


local TriggerSource;

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
local CloseOnOpposite;
local Direction;
local CloseOpposite;

local OpenTime, CloseTime, ExitTime;
local ValidInterval,UseMandatoryClosing;
local ToTime;

local renkoFirst;
local RenkoView;
local candles;
local Step;
local PrintDebug;
local BarCount;

--
function Prepare( nameOnly)
    Step = instance.parameters.Step;
    PrintDebug = instance.parameters.PrintDebug;
    BarCount = instance.parameters.BarCount; 
    Direction = instance.parameters.Direction;   
    CloseOpposite=instance.parameters.CloseOpposite; 
	 

    assert(instance.parameters.TF ~= "t1", "Tick time frame is not supported.");

    local name = profile:id() .. "( " .. instance.bid:name() .. "," .. Step .. "," .. BarCount .. " )";
    instance:name(name);

  

    PrepareTrading();

    if nameOnly then
        return ;
    end
	
    -- trigger source. Since the renko chart does not produce events when it creates a new bar
    -- it is best if we always run in tick mode.
    TriggerSource = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "close");
    PipSize = TriggerSource:pipSize();

    -- before we create the view, we need to know how many bars we will need.
    -- this is tricky because we cannot instantiate the indicator without the renkoView
    -- and we cannot start the view without knowing how many bars the indicator needs.
    renkoFirst = BarCount + 1;
	
	assert(core.indicators:findIndicator("RENKO_CANDLES_NEW") ~= nil, "Please, download and install RENKO_CANDLES_NEW.LUA indicator");  

    -- create the RenkoView
    local renkoProf = core.indicators:findIndicator("RENKO_CANDLES_NEW");
    local params = renkoProf:parameters();
    core.host:trace("Instrument: " .. instance.bid:instrument());
    params:setString("instrument", instance.bid:instrument());
    core.host:trace("TF: " .. instance.parameters.TF);
    params:setString("frame", instance.parameters.TF);
    params:setBoolean("type", instance.parameters.Type == "Bid");
    params:setInteger("Step", Step);
    params:setInteger("barLimit", renkoFirst);
    params:setBoolean("PrintDebug", PrintDebug);

    RenkoView = renkoProf:createInstance(nil, params);

    -- keep a global reference to the renko candles or it crashes.
    candles = RenkoView:getCandleOutput(0);

	ToTime= instance.parameters.ToTime;
    ValidInterval = instance.parameters.ValidInterval;
    UseMandatoryClosing = instance.parameters.UseMandatoryClosing;	
	
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

function PrepareTrading()
    AllowMultiple =  instance.parameters.AllowMultiple;
	CloseOnOpposite = instance.parameters.CloseOnOpposite;
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
local lastPeriod = -100;
function ExtUpdate(id, source, tickPeriod)  -- The method called every time when a new bid or ask price appears.
    if AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
            return ;
        end
    end

    if id ~= 1 then
        return;
    end
	
	    now = core.host:execute("getServerTime");
	now= core.host:execute ("convertTime", core.TZ_EST, ToTime, now);
   -- get only time
    now = now - math.floor(now);		
	
	
	  if not InRange(now, OpenTime, CloseTime)
	  then            
      return ;
      end
	  

    -- redirect the strategy to use the renko bar stream.
    local Source = candles;

    -- get the latest period.
    local renkoSize = Source.open:size() - 1;
    if (renkoSize <= renkoFirst) then
        -- not enough data.
        return;
    end

    if (RenkoView.close:serial(renkoSize) == lastPeriod) then
        -- the renko has not been updated.
        return;
    end

    -- if the renko has been updated
    -- check how many bars we have missed.
    -- this is required because sometimes the price can move very quickly in multiples of the brick size
    -- therefore, we need to check the trade conditions on every renko brick
    -- otherwise, we might miss a signal (like a cross-over)

    local fromPeriod;
    local toPeriod = renkoSize;
    if (lastPeriod == -100) then
        fromPeriod = renkoSize;
    else
        local i = renkoSize;
        while (RenkoView.close:serial(i) ~= lastPeriod) do
            i = i-1;
        end
        fromPeriod = i + 1;
    end
    lastPeriod = RenkoView.close:serial(renkoSize);

    local timeCheck = false;
    local now = core.host:execute("getServerTime");
    now = now - math.floor(now);
    if now < OpenTime or now > CloseTime then
        -- failed the time check.
        return;
    end

    local period = fromPeriod;
    while (period <= toPeriod) do
        -- for every new renko bar, check the trade signals.
        -- TODO: This should really be enhanced to handle if multiple/opposite signals are going to be generated in the same set of new renko bars.

        local renkoGreen = RenkoView.open[period] <= RenkoView.close[period];
        local firstGreen = renkoGreen;
        local index = period - 1;
        local limit = period - BarCount;
        local count = 0;
        local trade = true;
        while (index >= limit) do
            local currentGreen = RenkoView.open[index] <= RenkoView.close[index];
            if (index == limit) then
                -- this one should be opposite
                trade = trade and (currentGreen ~= renkoGreen);
            else
                -- this has to match the latest direction
                trade = trade and (currentGreen == renkoGreen);
            end

            index = index - 1;
        end

        if (trade) then
            if (renkoGreen) then
                ExtTrace("Buy!");
                BUY();
            else
                ExtTrace("Sell!");
                SELL();
            end
        end

        if CloseOpposite then
            if haveTrades("B") and not(firstGreen) then
                ExtTrace("Close Buy!");
                exit("B");
            elseif haveTrades("S") and firstGreen then
                ExtTrace("Close Sell!");
                exit("S");
            end
        end

        -- move to the next renko period.
        period = period + 1;
    end

end

	  
-- NG: Introduce async function for timer/monitoring for the order results
function ExtAsyncOperationFinished(cookie, success, message)

    if cookie == 100 then
        -- timer
        if UseMandatoryClosing and AllowTrade then
            now = core.host:execute("getServerTime");
            now= core.host:execute ("convertTime", core.TZ_EST, ToTime, now);
            -- get only time
            now = now - math.floor(now);
			
            -- check whether the time is in the exit time period
            if now >= ExitTime and now < ExitTime +(ValidInterval / 86400.0) then
                if not checkReady("trades")  then
                    return ;
                end  
				
				     if haveTrades("B")  then
                     exit("B");
                     Signal ("Close Long");
					 end
					 
					 if haveTrades("S")  then
                     exit("S");
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
        if CloseOnOpposite and haveTrades('S') then
            exit('S');
            Signal ("Close Short");
        end	

        if haveTrades('B') and not AllowMultiple then
            return;
        end

        if ALLOWEDSIDE == "Sell"   then
            return;
        end 

        if (enter('B')) then
            Signal ("Open Long");
        end

    elseif ShowAlert then
        Signal ("Up Trend");
    end

end   

function SELL ()		
    if AllowTrade then
        if CloseOnOpposite and haveTrades('B') then
            exit('B');
            Signal ("Close Long");
        end

        if haveTrades('S') and not AllowMultiple then
            return;
        end

        if ALLOWEDSIDE == "Buy"  then
            return;
        end

        if (enter('S')) then
            Signal ("Open Short");	
        end
																			
    elseif ShowAlert then
        Signal ("Down Trend");	
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
     terminal:alertEmail(Email, Label, profile:id() .. "(" .. instance.bid:instrument() .. ")" .. instance.bid[NOW]..", " .. Label..", " .. instance.bid:date(NOW));
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
    while count == 0 and row ~= nil do
        if row.AccountID == Account and
           row.OfferID == Offer and
           (row.BS == BuySell or BuySell == nil) then
           count = count + 1;
        end
        row = enum:next();
    end

    return count
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

    return found
end

-- enter into the specified direction
function enter(BuySell)
    if not(AllowTrade) then
        return false;
    end

    -- do not enter if position in the
    -- specified direction already exists
    if tradesCount(BuySell) > 0 and not AllowMultiple  then
        return false;
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
        valuemap.EntryLimitStop = 'Y'
    end


    success, msg = terminal:execute(100, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        return false;
    end

    return true;
end

-- exit from the specified direction
function exit(BuySell, use_net)
    if not (AllowTrade) then
        return true
    end

    if use_net == true then
        local valuemap, success, msg
        if tradesCount(BuySell) > 0 then
            valuemap = core.valuemap()

            -- switch the direction since the order must be in oppsite direction
            if BuySell == "B" then
                BuySell = "S"
            else
                BuySell = "B"
            end
            valuemap.OrderType = "CM"
            valuemap.OfferID = Offer
            valuemap.AcctID = Account
            valuemap.NetQtyFlag = "Y"
            valuemap.BuySell = BuySell
            success, msg = terminal:execute(101, valuemap)

            if not(success) then
               terminal:alertMessage(
                   instance.bid:instrument(),
                   instance.bid[instance.bid:size() - 1],
                   "Open order failed"..msg,
                   instance.bid:date(instance.bid:size() - 1)
               )
                return false
            end
            return true
        end
    else
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        while row ~= nil do
            if row.BS == BuySell and row.OfferID == Offer then
                local valuemap = core.valuemap();
                valuemap.BuySell = row.BS == "B" and "S" or "B";
                valuemap.OrderType = "CM";
                valuemap.OfferID = row.OfferID;
                valuemap.AcctID = row.AccountID;
                valuemap.TradeID = row.TradeID;
                valuemap.Quantity = row.Lot;
                local success, msg = terminal:execute(101, valuemap);
            end
        row = enum: next();
        end
    end
    return false
end

-- ---------------------------------------------------------
-- Trace helper function
-- ---------------------------------------------------------
function ExtTrace(message)
    core.host:trace(ExtTimeNow() .. " Renko (" .. ExtRenkoTimeNow() .. ") " .. message);
end

function ExtRenkoTimeNow()
    return ExtFormatDate(candles.close:date(candles.close:size() - 1));
end

function ExtTimeNow()
    return ExtFormatDate(math.max(instance.bid:date(instance.bid:size() - 1), instance.ask:date(instance.ask:size() - 1)));
end

function ExtFormatDate(inputDate)
    local theDate = core.dateToTable(core.host:execute("convertTime", 1, 4, inputDate));
    return string.format("%d/%02d/%02d %02d:%02d:%02d", theDate.year, theDate.month, theDate.day, theDate.hour, theDate.min, theDate.sec);
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
