-- Available @ https://fxcodebase.com/code/viewtopic.php?f=31&t=74737

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+

function Init() --The strategy profile initialization
    strategy:name("ETF rotation strategy");
    strategy:description("");
	
	strategy.parameters:addString("instrument_1", "Instrument 1", "", "SPY.us");
	strategy.parameters:setFlag("instrument_1", core.FLAG_INSTRUMENTS);

	strategy.parameters:addString("instrument_2", "Instrument 2", "", "TLT.us");
	strategy.parameters:setFlag("instrument_2", core.FLAG_INSTRUMENTS);
	
	strategy.parameters:addInteger("Period", "Period", "", 3);	

	
	strategy.parameters:addGroup("Price");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
	
	strategy.parameters:addString("TF", "Time frame", "", "m1");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);
	
    CreateTradingParameters();
end

function CreateTradingParameters()
    strategy.parameters:addGroup("Execution Parameters");

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);   
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
   
	strategy.parameters:addString("EntryExecutionType", "Entry Execution Type", "", "Live");
    strategy.parameters:addStringAlternative("EntryExecutionType", "End of Turn", "", "EndOfTurn");
	strategy.parameters:addStringAlternative("EntryExecutionType", "Live", "", "Live");	
	strategy.parameters:addBoolean("use_exit", "Optional exit", "", false);
 
	 strategy.parameters:addGroup("Trade Parameters");
	
	strategy.parameters:addBoolean("CloseOnOpposite", "Close On Opposite", "", true);
    strategy.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "ETFRS");
	
	strategy.parameters:addBoolean("PositionCap", "Use Position Cap", "", false);
	strategy.parameters:addInteger("MaxNumberOfPositionInAnyDirection", "Max Number Of Open Position In Any Direction", "", 2);
	strategy.parameters:addInteger("MaxNumberOfPosition", "Max Number Of Position In One Direction", "", 1);
    	
    strategy.parameters:addString("ALLOWEDSIDE", "Allowed side", "Allowed side for trading or signaling, can be Sell, Buy or Both", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell");
 

    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1);
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false);
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30);
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false);
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30);
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false);
	strategy.parameters:addBoolean("UseBreakeven", "Use Breakeven ", "", false);
	strategy.parameters:addDouble("Profit", "Breakeven Level", "", 10);
	
    strategy.parameters:addGroup("Alerts");
    strategy.parameters:addBoolean("ShowAlert", "ShowAlert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", true);
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", false);
    strategy.parameters:addString("Email", "Email", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
	
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
end

local OpenTime, CloseTime, ExitTime,ValidInterval,UseMandatoryClosing;
local Source_1, TickSource_1;
local Source_2, TickSource_2;
local MaxNumberOfPositionInAnyDirection, MaxNumberOfPosition;
local SoundFile = nil;
local RecurrentSound = false;
local ALLOWEDSIDE;
local AllowTrade;
local instrument_1 = {};
local instrument_2 = {};
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
local EntryExecutionType;
local CloseOnOpposite
local IsDirectDirection;
local CustomID;
local PositionCap;
local TF;
local OpenTime, CloseTime, ExitTime;
local LastEntry, LastExit;
local ToTime;
local Profit;
local UseBreakeven;
local minChange;
local TICK_SOURCE_1 = 1;
local TICK_SOURCE_2 = 2;
local BAR_SOURCE_1 = 3;
local BAR_SOURCE_2 = 4;
local indicator_1;
local indicator_2;
local UseExit = false;

--Indicator parameters
function Prepare(nameOnly)
    CustomID = instance.parameters.CustomID;
	EntryExecutionType = instance.parameters.EntryExecutionType;
	ExitExecutionType= instance.parameters.EntryExecutionType;
    CloseOnOpposite = instance.parameters.CloseOnOpposite;
	MaxNumberOfPositionInAnyDirection = instance.parameters.MaxNumberOfPositionInAnyDirection;
	MaxNumberOfPosition = instance.parameters.MaxNumberOfPosition;
	IsDirectDirection = instance.parameters.Direction == "direct";
	TF= instance.parameters.TF;
	ToTime= instance.parameters.ToTime;
	Profit = instance.parameters.Profit;
	UseBreakeven = instance.parameters.UseBreakeven;
	UseExit = instance.parameters.use_exit;
	minChange = math.pow(10, -instance.bid:getPrecision());
	
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
	 
	PositionCap = instance.parameters.PositionCap;	
	ValidInterval = instance.parameters.ValidInterval;
	UseMandatoryClosing = instance.parameters.UseMandatoryClosing;
	LastEntry=nil;
	LastExit=nil;
	
    assert(TF ~= "t1", "The time frame must not be tick");

    local name;
    name = profile:id() .. "( " .. instance.bid:name()  .. ", " .. CustomID ..  " )";
    instance:name(name);
   
    PrepareTrading();

    if nameOnly then
        return ;
    end
	
	
	Period = instance.parameters.Period;
	
 	if EntryExecutionType == "Live" or ExitExecutionType == "Live" or UseBreakeven then
		TickSource_1 = ExtSubscribe(TICK_SOURCE_1, instance.parameters.instrument_1, "t1", instance.parameters.Type == "Bid", "close");
		TickSource_2 = ExtSubscribe(TICK_SOURCE_2, instance.parameters.instrument_2, "t1", instance.parameters.Type == "Bid", "close");
 	end
	
    Source_1 = ExtSubscribe(BAR_SOURCE_1, instance.parameters.instrument_1, TF, instance.parameters.Type == "Bid", "bar");
    Source_2 = ExtSubscribe(BAR_SOURCE_2, instance.parameters.instrument_2, TF, instance.parameters.Type == "Bid", "bar");
    --indicator_1 = core.indicators:create("MVA", Source_1, instance.parameters.mva_1_period);
	--indicator_2 = core.indicators:create("MVA", Source_2, instance.parameters.mva_2_period);
	
	ValidInterval = instance.parameters.ValidInterval;
	UseMandatoryClosing = instance.parameters.UseMandatoryClosing;
	
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

function ReleaseInstance()
	core.host:execute ("killTimer", 100);
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

    AllowTrade = instance.parameters.AllowTrade;
    Account = instance.parameters.Account;
    Amount = instance.parameters.Amount;

    instrument_1.BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.parameters.instrument_1, Account);
    instrument_2.BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.parameters.instrument_2, Account);
    instrument_1.Offer = core.host:findTable("offers"):find("Instrument", instance.parameters.instrument_1).OfferID;
    instrument_2.Offer = core.host:findTable("offers"):find("Instrument", instance.parameters.instrument_2).OfferID;
    instrument_1.CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.parameters.instrument_1, Account);
    instrument_2.CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.parameters.instrument_2, Account);	
	instrument_1.instrument=instance.parameters.instrument_1;
	instrument_2.instrument=instance.parameters.instrument_2;	
    SetLimit = instance.parameters.SetLimit;
    Limit = instance.parameters.Limit;
    SetStop = instance.parameters.SetStop;
    Stop = instance.parameters.Stop;
    TrailingStop = instance.parameters.TrailingStop;
end

local requestId;
local used_stop_orders = {};

function isStopOrderType(orderType)
    return orderType == "S" or orderType == "SE" or orderType == "ST" or orderType == "STE";
end

function findStopOrder(trade)
    if instrument_1.CanClose then
        local orderId;
        if requestId ~= nil then
            order = core.host:findTable("orders"):find("RequestID", requestId);
            if order ~= nil then
                orderId = order.OrderID
                requestId = nil
            end
        end

        -- Check that order is stil exist
        if orderId ~= nil then
            return core.host:findTable("orders"):find("OrderID", orderId);
        end
    else
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if row.ContingencyType == 3 and isStopOrderType(row.Type) and used_stop_orders[row.OrderID] ~= true then
                used_stop_orders[row.OrderID] = true;
                return row;
            end
            row = enum:next();
        end
    end
    return nil;
end

function moveStop(rate, side, row)
	local trade = core.host:findTable("trades"):find("TradeID", row.TradeID);
	if trade == nil then
		return;
	end

	local order = findStopOrder(row);
	if order == nil then
		-- =======================================================================
		--                           CREATE NEW ORDER                           --
		-- =======================================================================

		valuemap = core.valuemap();
		valuemap.Command = "CreateOrder";
		valuemap.OfferID = Offer;
		valuemap.Rate = rate;
		valuemap.BuySell = side;

		if CanClose then
			local trade = core.host:findTable("trades"):find("TradeID", row.TradeID);

			valuemap.OrderType = "S";
			valuemap.AcctID  = trade.AccountID;
			valuemap.TradeID = trade.TradeID;
			valuemap.Quantity = trade.Lot;
		else
			valuemap.OrderType = "SE"
			valuemap.AcctID  = Account;
			valuemap.NetQtyFlag = "Y"
		end

		success, msg = terminal:execute(200, valuemap);
		if not(success) then
			terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed create stop " .. msg, instance.bid:date(NOW));
		else
			requestId = core.parseCsv(msg)[0]
		end
	else
		-- =======================================================================
		--                      CHANGE EXISTING ORDER                           --
		-- =======================================================================
		if math.abs(rate - order.Rate) > minChange then
			-- stop exists
			valuemap = core.valuemap();
			valuemap.Command = "EditOrder";
			valuemap.AcctID  = order.AccountID;
			valuemap.OrderID = order.OrderID;
			valuemap.Rate = rate;

			success, msg = terminal:execute(200, valuemap);
			if not(success) then
				terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed change stop " .. msg, instance.bid:date(NOW));
			end
		end
	end
end

local moveStops = {};

function DoBreakevenLogic(id, source, period, instrument)
	-- check whether trade exists
	local enum, row;
	local found = false;
	enum = core.host:findTable("trades"):enumerator();
	row = enum:next();
	while (row ~= nil) do
		if row.AccountID == Account and row.OfferID == instrument.Offer then
			if row.PL >= Profit then
				if row.BS == "B"  then
					stopValue = instance.ask[NOW] - row.PL * source:pipSize();
					stopSide = "S";
				else
					stopValue = instance.bid[NOW] + row.PL * source:pipSize();
					stopSide = "B";
				end
				if moveStops[row.TradeID] ~= true then
					moveStop(stopValue, stopSide, row);
					moveStops[row.TradeID] = true;
				end
			end
		end
		row = enum:next();
	end
end

function IsTickSource(id)
	return id == TICK_SOURCE_1 or id == TICK_SOURCE_2;
end

function IsBarSource(id)
	return id == BAR_SOURCE_1 or id == BAR_SOURCE_2;
end

function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.
	if period < Period then
        return;
    end
 
	if IsTickSource(id) and UseBreakeven then
	    DoBreakevenLogic(id, source, period, instrument_1);
	    DoBreakevenLogic(id, source, period, instrument_2);
	end
	
	

	
	if EntryExecutionType == "Live" 
	or ExitExecutionType == "Live" then
	
		if id ~= TICK_SOURCE_1 then
	    return;
	    end
	 
		period1= core.findDate (Source_1.close, TickSource_1:date(period), false );
		period2= core.findDate (Source_2.close, TickSource_1:date(period), false );		
	else
	
		if id ~= BAR_SOURCE_1 then
	    return;
	    end
		
		period1= period;
		period2= core.findDate (Source_2.close, Source_1:date(period), false );	
	end
	
    now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime", core.TZ_EST, ToTime, now);
	-- get only time
    now = now - math.floor(now);

    if AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
			return ;
        end
    end
	
	if period1 <=  Period 
	or period2 <=  Period 
	then
        return; 
    end
 
	
 
		EntryFunction(period1,period2,now);
	 
	 
end

 

function EntryFunction(period1, period2,now)
    if not(now >= OpenTime
	and now <= CloseTime)
	then  
		return false;
    end
	  
    if (LastEntry == Source_1:serial(period1)) then
		return;
	end
	
	local P1= (Source_1.close[period1]-Source_1.close[period1-Period])/(Source_1.close[period1-Period]/100);
	local P2= (Source_2.close[period2]-Source_2.close[period2-Period])/(Source_2.close[period2-Period]/100);
	local P1O= (Source_1.close[period1-1]-Source_1.close[period1-Period-1])/(Source_1.close[period1-Period-1]/100);
	local P2O= (Source_2.close[period2-1]-Source_2.close[period2-Period-1])/(Source_2.close[period2-Period-1]/100);
	
	
    if P1> P2 and P1O <= P2O  then
        
            BUY(instrument_1,instrument_2); 
       
		LastEntry = Source_1:serial(period1);
		return;
    elseif P1< P2 and P1O>= P2O then
		 
            BUY(instrument_2,instrument_1); 
		 
		LastEntry = Source_1:serial(period1);
		return;
    end
	return false;  
end

-- NG: Introduce async function for timer/monitoring for the order results
function ExtAsyncOperationFinished(cookie, success, message)
    if cookie == 100 then
        -- timer
        if UseMandatoryClosing and AllowTrade then
            now = core.host:execute("getServerTime");
            now = core.host:execute("convertTime", core.TZ_EST, ToTime, now);
            -- get only time
            now = now - math.floor(now);
			
            -- check whether the time is in the exit time period
            if now >= ExitTime and now < ExitTime + (ValidInterval / 86400.0) then
                if not checkReady("trades")  then
                    return ;
                end  

				if haveTrades("B", instance.parameters.instrument_1)  then
					exitSpecific("B", instance.parameters.instrument_1);
					Signal ("Close Long");
				end
				if haveTrades("B", instance.parameters.instrument_2)  then
					exitSpecific("B", instance.parameters.instrument_2);
					Signal ("Close Long");
				end

				if haveTrades("S", instance.parameters.instrument_1)  then
					exitSpecific("S", instance.parameters.instrument_1);
					Signal ("Close Short");
				end
				if haveTrades("S", instance.parameters.instrument_2)  then
					exitSpecific("S", instance.parameters.instrument_2);
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
function BUY(instrument,exit_instrument)
    if AllowTrade then
        --if CanClose and CloseOnOpposite and  haveTrades("S") then
		if (CloseOnOpposite or Hedge) and haveTrades("B", exit_instrument  ) then
            -- close on opposite signal
            exitSpecific("B", exit_instrument);
            Signal ("Close Short " .. exit_instrument.instrument);
        end

        if ALLOWEDSIDE == "Sell"  then
            -- we are not allowed buys.
            return;
        end 

        enter("B", 0, instrument );
    else
        Signal ("Buy Signal " .. instrument.instrument  );	
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
        terminal:alertEmail(Email,  profile:id().. " : "  .. Label , FormatEmail(Source_1, NOW, Label));
		 
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

function tradesCount(BuySell, instrument) 
    local enum, row;
    local count = 0;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while row ~= nil do
        if row.AccountID == Account 
		and row.OfferID == instrument.Offer 
		and row.QTXT == CustomID   
		and (row.BS == BuySell or BuySell == nil) then
            count = count + 1;
        end

        row = enum:next();
    end

    return count;
end

function haveTrades(BuySell, instrument) 
    local enum, row;
    local found = false;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while (row ~= nil) do
        if row.AccountID == Account
		and row.OfferID == instrument.Offer
		and  row.QTXT == CustomID 
		and (row.BS == BuySell or BuySell == nil) then
            found = true;
            break;
        end
 
        row = enum:next();
    end

    return found;
end

-- enter into the specified direction
function enter(BuySell, hCount, instrument)
    -- do not enter if position in the specified direction already exists
    if (tradesCount(BuySell, instrument) >= MaxNumberOfPosition
	or (tradesCount(nil, instrument) >= MaxNumberOfPositionInAnyDirection))	
	and PositionCap	
	then
        return true;
    end

    -- send the alert after the checks to see if we can trade.
    if (BuySell == "S") then
        Signal ("Sell Signal ".. instrument.instrument);	
    else
        Signal ("Buy Signal ".. instrument.instrument);	
    end

    return MarketOrder(BuySell, hCount, instrument);
end

-- enter into the specified direction
function MarketOrder(BuySell, hCount, instrument)
    local valuemap, success, msg;
    valuemap = core.valuemap();

    valuemap.Command = "CreateOrder";
    valuemap.OrderType = "OM";
    valuemap.OfferID = instrument.Offer;
    valuemap.AcctID = Account;
	if hCount > 0 then
		valuemap.Quantity = hCount * instrument.BaseSize;
	else
		valuemap.Quantity = Amount * instrument.BaseSize;
	end
    valuemap.BuySell = BuySell;
    valuemap.CustomID = CustomID;

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

    if (not instrument.CanClose) then
        valuemap.EntryLimitStop = 'Y'
    end

    success, msg = terminal:execute(200, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        return false;
    end

    return true;
end

function exitSpecific(BuySell, instrument)
	--side
	-- closes all positions of the specified direction (B for buy, S for sell)
    local enum, row, valuemap;
    enum = core.host:findTable("trades"):enumerator();
    while true do
        row = enum:next();
        if row == nil then
            break;
        end
        if row.AccountID == Account and
			row.OfferID == instrument.Offer and
			row.BS == BuySell and
			row.QTXT == CustomID then
            -- if trade has to be closed

            if instrument_1.CanClose then
                -- non-FIFO account, create a close market order
                valuemap = core.valuemap();
                valuemap.OrderType = "CM";
                valuemap.OfferID = row.OfferID;
                valuemap.AcctID = Account;
                valuemap.Quantity = row.Lot;
                valuemap.TradeID = row.TradeID;
                valuemap.CustomID = CustomID;
                if row.BS == "B" then
                    valuemap.BuySell = "S";
                else
                    valuemap.BuySell = "B";
                end
                success, msg = terminal:execute(201, valuemap);
                 if not(success) then
					terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Close order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
					return false;
				end
            else
                -- FIFO account, create an opposite market order
                valuemap = core.valuemap();
                valuemap.OrderType = "OM";
                valuemap.OfferID = row.OfferID;
                valuemap.AcctID = Account;
                valuemap.Quantity = row.Lot;
                valuemap.CustomID = CustomID;
                if row.BS == "B" then
                    valuemap.BuySell = "S";
                else
                    valuemap.BuySell = "B";
                end
                success, msg = terminal:execute(201, valuemap);
                 if not(success) then
					terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Close order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
					return false;
				end
            end
        end
    end
end 

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+