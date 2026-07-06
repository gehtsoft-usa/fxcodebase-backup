-- Id: 6222
local BAR = true;

function Init() --The strategy profile initialization
    strategy:name("Trix Strategy");
    strategy:description("");
    -- NG: optimizer/backtester hint
    strategy:setTag("NonOptimizableParameters", "ShowAlert,PlaySound,SoundFile,RecurrentSound,SendMail,Email");


    strategy.parameters:addGroup("Price");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
	
	
    strategy.parameters:addString("Price", "Price Source", "", "close");
    strategy.parameters:addStringAlternative("Price", "OPEN", "", "open");
    strategy.parameters:addStringAlternative("Price", "HIGH", "", "high");
    strategy.parameters:addStringAlternative("Price", "LOW", "", "low");
    strategy.parameters:addStringAlternative("Price","CLOSE", "", "close");
    strategy.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    strategy.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    strategy.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
 


    strategy.parameters:addString("TF", "Time Frame", "", "m5");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);
	
	strategy.parameters:addGroup("Signal Trix Calculation");
    strategy.parameters:addInteger("P_NS", "TRIX Periods", "", 14);
    strategy.parameters:addString("MA_1S", "First Smoothing Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "EMA");
    strategy.parameters:addStringAlternative("MA_1S", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("MA_1S", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("MA_1S", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("MA_1S", "TMA", "", "TMA");
    strategy.parameters:addStringAlternative("MA_1S", "SMMA*", "", "SMMA");
    strategy.parameters:addStringAlternative("MA_1S", "Vidya (1995)*", "", "VIDYA");
    strategy.parameters:addStringAlternative("MA_1S", "Vidya (1992)*", "", "VIDYA92");
    strategy.parameters:addStringAlternative("MA_1S", "Wilders*", "", "WMA");
    strategy.parameters:addString("MA_2S", "Second Smoothing Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "EMA");
    strategy.parameters:addStringAlternative("MA_2S", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("MA_2S", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("MA_2S", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("MA_2S", "TMA", "", "TMA");
    strategy.parameters:addStringAlternative("MA_2S", "SMMA*", "", "SMMA");
    strategy.parameters:addStringAlternative("MA_2S", "Vidya (1995)*", "", "VIDYA");
    strategy.parameters:addStringAlternative("MA_2S", "Vidya (1992)*", "", "VIDYA92");
    strategy.parameters:addStringAlternative("MA_2S", "Wilders*", "", "WMA");
    strategy.parameters:addString("MA_3S", "Third Smoothing Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "EMA");
    strategy.parameters:addStringAlternative("MA_3S", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("MA_3S", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("MA_3S", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("MA_3S", "TMA", "", "TMA");
    strategy.parameters:addStringAlternative("MA_3S", "SMMA*", "", "SMMA");
    strategy.parameters:addStringAlternative("MA_3S", "Vidya (1995)*", "", "VIDYA");
    strategy.parameters:addStringAlternative("MA_3S", "Vidya (1992)*", "", "VIDYA92");
    strategy.parameters:addStringAlternative("MA_3S", "Wilders*", "", "WMA");
    strategy.parameters:addInteger("S_NS", "Signal Periods", "", 9);
    strategy.parameters:addString("MA_SS", "Signal Smoothing Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "MVA");
    strategy.parameters:addStringAlternative("MA_SS", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("MA_SS", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("MA_SS", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("MA_SS", "TMA", "", "TMA");
    strategy.parameters:addStringAlternative("MA_SS", "SMMA*", "", "SMMA");
    strategy.parameters:addStringAlternative("MA_SS", "Vidya (1995)*", "", "VIDYA");
    strategy.parameters:addStringAlternative("MA_SS", "Vidya (1992)*", "", "VIDYA92");
    strategy.parameters:addStringAlternative("MA_SS", "Wilders*", "", "WMA");
	
	
	  strategy.parameters:addGroup("Exit Option");
	   strategy.parameters:addBoolean("Exit", "Use Exit", "", false);
	   strategy.parameters:addString("ExitType", "Type of Exit signal", "", "Any");
    strategy.parameters:addStringAlternative("ExitType", "Any", "", "Any");
    strategy.parameters:addStringAlternative("ExitType", "Signal Line Cross", "", "First");
	strategy.parameters:addStringAlternative("ExitType", "Zero Line Cross", "", "Second");	
	
    strategy.parameters:addGroup("Strategy Parameters");
    strategy.parameters:addString("Direction", "Type of signal", "", "direct");
    strategy.parameters:addStringAlternative("Direction", "direct", "", "direct");
    strategy.parameters:addStringAlternative("Direction", "reverse", "", "reverse");

    strategy.parameters:addGroup("Time Parameters");
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
local Exit,ExitType;
local P_NS,MA_1S,MA_2S,MA_3S,MA_SS,S_NS;

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

   ExitType = instance.parameters.ExitType;
   Exit = instance.parameters.Exit;

    Price = instance.parameters.Price;	
   
    UseMandatoryClosing = instance.parameters.UseMandatoryClosing;
	P_NS= instance.parameters.P_NS;
	MA_1S = instance.parameters.MA_1S;
	MA_2S = instance.parameters.MA_2S;
	MA_3S = instance.parameters.MA_3S;
	MA_SS = instance.parameters.MA_SS;
	S_NS = instance.parameters.S_NS;


    -- NG: replace string comparison everytime in future.
    Direction = instance.parameters.Direction == "direct";
    ValidInterval = instance.parameters.ValidInterval;

    Indicator[1] = nil;


    -- NG: check TF1/TF2 instead of TF
    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick");
 

    local name;
    name = profile:id() .. "( " .. instance.bid:name();
    local i;
	
	

	 	assert(core.indicators:findIndicator("TRIX") ~= nil, "Please, download and install TRIX.LUA indicator");          
    
    name = name  ..  " )";
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
	
	
	
	
    Indicator[1] = core.indicators:create("TRIX", Source[Price] ,P_NS,MA_1S,MA_2S,MA_3S,S_NS,  MA_SS  );
	Short[11] = Indicator[1]:getStream(0);
	Short[12] = Indicator[1]:getStream(1);	

	
	first=math.max(Short[12]:first() );
	


	
    if UseMandatoryClosing then
        core.host:execute("setTimer", 100, math.max(ValidInterval / 2, 1));
    end
end

function PrepareTrading()
    AllowMultiple =  instance.parameters.AllowMultiple;
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
    local pos = string.find(time, ":");
    if pos == nil then
        return nil, false;
    end
    local h = tonumber(string.sub(time, 1, pos - 1));
    time = string.sub(time, pos + 1);
    pos = string.find(time, ":");
    if pos == nil then
        return nil, false;
    end
    local m = tonumber(string.sub(time, 1, pos - 1));
    local s = tonumber(string.sub(time, pos + 1));
    return (h / 24.0 + m / 1440.0 + s / 86400.0),                          --time in ole format
            ((h >= 0 and h< 24 and m >= 0 and m< 60 and s >= 0 and s< 60) or(h == 24 and m == 0 and s == 0)); --validity flag
end

function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.
    if AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
            return ;
        end
    end

 
    if id ~= 1 then
        return;
    end


     
   
    Indicator[1]:update(core.UpdateLast);
	
   

    if period < first +1  then
        return ;
    end

    local now = core.host:execute("getServerTime");
    now = now - math.floor(now);

    if now >= OpenTime and now <= CloseTime then
	
	
	
        if   core.crossesOver(Short[11], Short[12] ,period)
		and  Short[12][period] > 0
		then
       
		
            if Direction then
                BUY();
            else
                SELL();
            end
			
		 elseif  core.crossesOver(Short[11], Short[12] ,period)
		 and  Short[12][period]  <  0
		 then
            if Direction then
                SELL();
            else
                BUY();
            end
        end
		
		
		if Exit then
		
				     	if	(core.crossesUnder(Short[11], Short[12] ,period)   and ( ExitType == "First"  or   ExitType == "Any") )  	
						or  (   Short[11][period]    <  0  and  ( ExitType == "Second"  or   ExitType == "Any")  ) 	
										
						then
								if   Direction then
										   if haveTrades("B") then
											   exit("B");
											   Signal ("Close Long");
										   end
							   else 
										 if haveTrades("S") then
											   exit("S");
											   Signal ("Close Short");
										   end
								   
								end
					  end
					  
					  
					  
					   if	( core.crossesOver(Short[11], Short[12] ,period) 	and  (ExitType == "First"  or   ExitType == "Any")   ) 					
						or   (  Short[11][period]   > 0  and  (ExitType == "Second"   or   ExitType == "Any") ) 
                
						then
								   if   Direction then    
										if haveTrades("S") then
										   exit("S");
										   Signal ("Close Short");
									   end 
								  
								  
							   else 
							   
									  if haveTrades("B") then
										   exit("B");
										   Signal ("Close Long");
									   end
								
							 
							 end
				
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
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--


function BUY()
    if AllowTrade then
        if haveTrades("B") and not AllowMultiple then
            if  haveTrades("S")   then
                exit("S");
                Signal ("Close Short");
            end
            return;
        end

        if ALLOWEDSIDE == "Sell" then
            if haveTrades("S")   then
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

        if ALLOWEDSIDE == "Buy"  then
            if  haveTrades("B") then
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
    if tradesCount(BuySell) > 0 and not  AllowMultiple  then
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

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");



