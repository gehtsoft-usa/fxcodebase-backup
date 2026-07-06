-- Id: 10291
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=59738

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


function Init() --The strategy profile initialization
    strategy:name("MTF MA Cross Strategy");
    strategy:description("");
    -- NG: optimizer/backtester hint
    strategy:setTag("NonOptimizableParameters", "ShowAlert,PlaySound,SoundFile,RecurrentSound,SendMail,Email");


    strategy.parameters:addGroup("Price");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

	
	Parameters (1, "m15");
	Parameters (2, "H1");
	Parameters (3, "H4" );
 
	

 
     
	 strategy.parameters:addGroup("Exit Parameters");
     strategy.parameters:addBoolean("EXIT", "Use additional Exit Options", "", true);
	 
	 strategy.parameters:addInteger("Mode", "Type of Exit", "", 2);
    strategy.parameters:addIntegerAlternative("Mode", "Cumulative (All Selected)", "", 1);
    strategy.parameters:addIntegerAlternative("Mode", "Single Time Frame (Any Selected)", "", 2)
	 
	 local i;
	 for i = 1, 3,1 do
	 strategy.parameters:addBoolean("ON"..i, i ..". Use This Time Framel in  Exit Calculation", "", true);
	 end
	 
	  strategy.parameters:addInteger("BL", "Long Exit Limit", "", 1);
	   strategy.parameters:addInteger("SL", "Short Exit Limit", "", 1);
	 
    strategy.parameters:addGroup("Strategy Parameters");
    strategy.parameters:addString("Direction", "Type of signal", "", "direct");
    strategy.parameters:addStringAlternative("Direction", "direct", "", "direct");
    strategy.parameters:addStringAlternative("Direction", "reverse", "", "reverse");
  
    CreateTradingParameters();
	
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

function Parameters (id, TF,MVA,PERIOD)
    strategy.parameters:addGroup(id..". Time Frame");
	
	if id > 1 then
	strategy.parameters:addBoolean("USE"..id, "Use This Time Frame", "", true);
	end
	
	
	 strategy.parameters:addString("TF"..id , "Time Frame", "", TF );
    strategy.parameters:setFlag("TF"..id , core.FLAG_PERIODS);
	
	
	strategy.parameters:addString("Price"..id, "Price Source", "", "close");
    strategy.parameters:addStringAlternative("Price"..id, "OPEN", "", "open");
    strategy.parameters:addStringAlternative("Price"..id, "HIGH", "", "high");
    strategy.parameters:addStringAlternative("Price"..id, "LOW", "", "low");
    strategy.parameters:addStringAlternative("Price"..id,"CLOSE", "", "close");
    strategy.parameters:addStringAlternative("Price"..id, "MEDIAN", "", "median");
    strategy.parameters:addStringAlternative("Price"..id, "TYPICAL", "", "typical");
    strategy.parameters:addStringAlternative("Price"..id, "WEIGHTED", "", "weighted");	
	
	
	strategy.parameters:addInteger("Period1"..id, "Fast MA Period","", 5);
	strategy.parameters:addString("Method1"..id, "MA Method", "Method" , "EMA");
    strategy.parameters:addStringAlternative("Method1"..id, "MVA", "MVA" , "MVA");
    strategy.parameters:addStringAlternative("Method1"..id, "EMA", "EMA" , "EMA");
 strategy.parameters:addStringAlternative("Method1"..id, "LWMA", "LWMA" , "LWMA");
    strategy.parameters:addStringAlternative("Method1"..id, "TMA", "TMA" , "TMA");
    strategy.parameters:addStringAlternative("Method1"..id, "SMMA", "SMMA" , "SMMA");
    strategy.parameters:addStringAlternative("Method1"..id, "KAMA", "KAMA" , "KAMA");
    strategy.parameters:addStringAlternative("Method1"..id, "VIDYA", "VIDYA" , "VIDYA");
    strategy.parameters:addStringAlternative("Method1"..id, "WMA", "WMA" , "WMA");
	
	strategy.parameters:addInteger("Period2"..id, "Slow MA Period","", 200);
	
	strategy.parameters:addString("Method2"..id, "MA Method", "Method" , "MVA");
    strategy.parameters:addStringAlternative("Method2"..id, "MVA", "MVA" , "MVA");
    strategy.parameters:addStringAlternative("Method2"..id, "EMA", "EMA" , "EMA");
 strategy.parameters:addStringAlternative("Method2"..id, "LWMA", "LWMA" , "LWMA");
    strategy.parameters:addStringAlternative("Method2"..id, "TMA", "TMA" , "TMA");
    strategy.parameters:addStringAlternative("Method2"..id, "SMMA", "SMMA" , "SMMA");
    strategy.parameters:addStringAlternative("Method2"..id, "KAMA", "KAMA" , "KAMA");
    strategy.parameters:addStringAlternative("Method2"..id, "VIDYA", "VIDYA" , "VIDYA");
    strategy.parameters:addStringAlternative("Method2"..id, "WMA", "WMA" , "WMA");
	
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

    strategy.parameters:addBoolean("AllowMultiple", "Allow Multiple", "", false);
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

local Mode;
local Source;
local EXIT;
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
 

local Source={};

local Direction;
local Price={};
local Method2={};
local Method1={};
local Period2={};
local Period1={};

local Fast={};
local Slow={};

	
local OpenTime, CloseTime, ExitTime;
local ValidInterval,UseMandatoryClosing;
local ToTime;

local TF={};
local Open={};
local Close={};
local USE={};
local ON={};


function Prepare(nameOnly)
	
	 local name = profile:id() .. "(" ..  instance.bid:name()  .. ")";
    instance:name(name); 


     if   (nameOnly) then
        return;
    end
    
	--Price = instance.parameters.Price;
    EXIT= instance.parameters.EXIT;
    -- NG: replace string comparison everytime in future.
    Direction = instance.parameters.Direction == "direct";
    
	Mode = instance.parameters.Mode;
	 

    -- NG: check TF1/TF2 instead of TF
	local i;
	for i = 1 , 3, 1 do
	

    TF[i]=  instance.parameters:getString("TF" .. i)
	ON[i]=  instance.parameters:getBoolean("ON" .. i);
	if i > 1 then
    USE[i]=  instance.parameters:getBoolean("USE" .. i);	
	end
	
	Price[i]=  instance.parameters:getString("Price" .. i);
	Method1[i]=  instance.parameters:getString("Method1" .. i);
	Method2[i]=  instance.parameters:getString("Method2" .. i);
	
	Period1[i]=  instance.parameters:getInteger("Period1" .. i);
	Period2[i]=  instance.parameters:getInteger("Period2" .. i);
	
    assert(TF[i] ~= "t1", i..". The time frame must not be tick");
	 
    end
 

    PrepareTrading();

    
	for i = 1 , 3, 1 do
	
	
    Source[i] = ExtSubscribe(i, nil, TF[i], instance.parameters.Type == "Bid", "bar");
    assert(core.indicators:findIndicator( Method1[i]) ~= nil,  Method1[i] .. " indicator must be installed");
    Fast[i] = core.indicators:create( Method1[i], Source[i][Price[i]] , Period1[i]);	
    assert(core.indicators:findIndicator( Method2[i]) ~= nil,  Method2[i] .. " indicator must be installed");
    Slow[i] = core.indicators:create( Method2[i], Source[i][Price[i]] , Period2[i]);
    end
	
	
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

function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.
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
	  
	  

	local i;
	for i = 1 , 3, 1 do 
    Fast[i]:update(core.UpdateLast);
	Slow[i]:update(core.UpdateLast);
    end

    -- NG: condition to check the presense of the data is changed to proper
    --     crossover functions
    if Fast[1].DATA:size() <= Fast[1].DATA:first() + 2 
	or Fast[2].DATA:size() <= Fast[2].DATA:first() + 2 
	or Fast[3].DATA:size() <= Fast[3].DATA:first() + 2 
    or Slow[1].DATA:size() <= Slow[1].DATA:first() + 2 
	or Slow[2].DATA:size() <= Slow[2].DATA:first() + 2 
	or Slow[3].DATA:size() <= Slow[3].DATA:first() + 2 
	then
        return ;
    end

 
        -- NG: 1) different time frame may have different dimensions
        --     2) bar strategies must check cross at the closed bar
        --        not the recently closed bar
		
		-- if core.crossesOver(Short[1], Short[2], Short[1]:size() - 2, Short[2]:size() - 2) then
        
		
		if     (Slow[1].DATA[ Slow[1].DATA:size() - 1] < Fast[1].DATA[ Fast[1].DATA:size() - 1]) and (Slow[1].DATA[ Slow[1].DATA:size() - 2] > Fast[1].DATA[ Fast[1].DATA:size() - 2])
		and   (( Slow[2].DATA[ Slow[2].DATA:size() - 1] <  Fast[2].DATA[ Fast[2].DATA:size() - 1]) or not USE[2])
		and   ((  Slow[3].DATA[ Slow[3].DATA:size() - 1]<  Fast[3].DATA[ Fast[3].DATA:size() - 1]) or not USE[3])

	
		then
            if Direction then
                BUY();
            else
                SELL();
            end

        elseif     Slow[1].DATA[ Slow[1].DATA:size() - 1] > Fast[1].DATA[ Fast[1].DATA:size() - 1]and (Slow[1].DATA[ Slow[1].DATA:size() - 2] < Fast[1].DATA[ Fast[1].DATA:size() - 2])
		and   (( Slow[2].DATA[ Slow[2].DATA:size() - 1] >  Fast[2].DATA[ Fast[2].DATA:size() - 1]) or not USE[2])
		and   ((  Slow[3].DATA[ Slow[3].DATA:size() - 1] >  Fast[3].DATA[ Fast[3].DATA:size() - 1]) or not USE[3])		
		then
            if Direction then
                SELL();
            else
                BUY();
            end
        end
		
		
		if EXIT then
		local S=0;
		local B=0;
		    if Mode == 1  then
			
			    if     (( Slow[1].DATA[ Slow[1].DATA:size() - 1] > Fast[1].DATA[ Fast[1].DATA:size() - 1]) and   ON[1]) then
				B=B+1;
				end
				if   (( Slow[2].DATA[ Slow[2].DATA:size() - 1] > Fast[2].DATA[ Fast[2].DATA:size() - 1]) and   ON[2]) then
				B=B+1;
				end
				if   (( Slow[3].DATA[ Slow[3].DATA:size() - 1] > Fast[3].DATA[ Fast[3].DATA:size() - 1] )and  ON[3]) then
				B=B+1;
				end
			
				
		        if     (( Slow[1].DATA[ Slow[1].DATA:size() - 1] < Fast[1].DATA[ Fast[1].DATA:size() - 1]) and   ON[1]) then
				S=S+1;
				end
				if   (( Slow[2].DATA[ Slow[2].DATA:size() - 1] < Fast[2].DATA[ Fast[2].DATA:size() - 1] )and   ON[2]) then
				S=S+1;
				end
				if   (( Slow[3].DATA[ Slow[3].v:size() - 1] < Fast[3].DATA[ Fast[3].DATA:size() - 1]) and  ON[3]) then
				S=S+1;
				end
			
				
				if B >= BL then
				
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
				
				
				if S >= SL then
				
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
				
			
			else
			
		
		        if     ((Slow[1].DATA[ Slow[1].DATA:size() - 1] > Fast[1].DATA[ Fast[1].DATA:size() - 1] ) and   ON[1])
				or   ((  Slow[2].DATA[ Slow[2].DATA:size() - 1] > Fast[2].DATA[ Fast[2].DATA:size() - 1] ) and   ON[2])
				or   ((  Slow[3].DATA[ Slow[3].DATA:size() - 1] > Fast[3].DATA[ Fast[3].DATA:size() - 1] ) and  ON[3])	
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
				
		        if     ((Slow[1].DATA[ Slow[1].DATA:size() - 1] < Fast[1].DATA[ Fast[1].DATA:size() - 1] ) and   ON[1])
				or   (( Slow[2].DATA[ Slow[2].DATA:size() - 1] < Fast[2].DATA[ Fast[2].DATA:size() - 1] ) and   ON[2])
				or   ((  Slow[3].DATA[ Slow[3].DATA:size() - 1] < Fast[3].DATA[ Fast[3].DATA:size() - 1] ) and  ON[3])
		
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



