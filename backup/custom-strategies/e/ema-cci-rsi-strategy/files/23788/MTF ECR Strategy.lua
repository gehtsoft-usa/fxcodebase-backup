-- Id: 5931
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=11917

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

local FRAMES={"H1", "H1", "H1" }
local TfNumber =3;

function Init() --The strategy profile initialization
    strategy:name("MTF ECR Strategy");
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

 
 
    local i;
	
	for i = 1, TfNumber , 1 do
    TIMEFRAME(i, FRAMES[i] );
	end
	

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

function TIMEFRAME(id, FRAME)
    
	if id == 1 then
    strategy.parameters:addGroup("EMA/ Price Cross");	
	elseif  id == 2 then
    strategy.parameters:addGroup("RSI Filter");		
	strategy.parameters:addBoolean(tostring( id*100 + 10) , "Use This Filter", "", true);
	elseif id == 3 then
    strategy.parameters:addGroup("CCI Filter");	
	strategy.parameters:addBoolean(tostring( id*100 + 10) , "Use This Filter", "", true);
	end 
	
	
   
    strategy.parameters:addString(tostring( id*100 + 1), "Time frame", "", FRAME);
    strategy.parameters:setFlag( tostring(id*100  +1), core.FLAG_PERIODS);
	
	
	 if id == 1 then

    strategy.parameters:addInteger(tostring( id*100 + 2), "EMA Period", "", 34);
	end
	 
	 if id == 2 then

    strategy.parameters:addInteger(tostring( id*100 + 3), "RSI Period", "", 14);
	strategy.parameters:addDouble(tostring( id*100 +  4), "RSI Buy Level", "", 50);
	strategy.parameters:addDouble(tostring( id*100 + 5), "RSI Sell Level", "", 50);
	end
	 if id == 3 then
	
	 strategy.parameters:addInteger(tostring( id*100 + 6), "CCI Period", "", 14);	 
	 strategy.parameters:addDouble(tostring( id*100 + 7), "RSI Buy Level", "", -100);
	 strategy.parameters:addDouble(tostring( id*100 + 8), "RSI Sell Level", "", 100);
	 end

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
local Price;
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

local Indicator={};
local K={};
local D={};
local Source={};
local ON={};
local Direction;
 
local Parameters={};


local OpenTime, CloseTime, ExitTime;
local ValidInterval,UseMandatoryClosing;
local ToTime;

--
function Prepare(nameOnly)
	
	 local name = profile:id() .. "(" ..  instance.bid:name()  .. ")";
    instance:name(name); 


     if   (nameOnly) then
        return;
    end

    -- NG: replace string comparison everytime in future.
    Direction = instance.parameters.Direction == "direct";
    
    Price= instance.parameters.Price;
    Indicator[1] = nil;
    


	local i;
	 
		
	for i = 1, TfNumber , 1 do
	if i > 1 then
	ON[i]= instance.parameters:getBoolean(tostring(i*100 + 10));
	end
	Parameters[tostring(i*100 + 1)]= instance.parameters:getString(tostring(i*100 + 1));
	
	if i == 1 then
	Parameters[tostring(i*100 + 2)]=  instance.parameters:getInteger(tostring(i*100 + 2));
	end
	if i == 2 then
	Parameters[tostring(i*100 + 3)]=  instance.parameters:getInteger(tostring(i*100 + 3));
	Parameters[tostring(i*100 + 4)]=  instance.parameters:getDouble(tostring(i*100 + 4));
	Parameters[tostring(i*100 + 5)]=  instance.parameters:getDouble(tostring(i*100 + 5));
    end
	if i == 3 then
	Parameters[tostring(i*100 + 6)]=  instance.parameters:getInteger(tostring(i*100 + 6));
	Parameters[tostring(i*100 + 7)]=  instance.parameters:getDouble(tostring(i*100 + 7));
	Parameters[tostring(i*100 + 8)]=  instance.parameters:getDouble(tostring(i*100 + 8));
	end
    assert(Parameters[tostring(i*100 + 1)] ~= "t1", "The time frame must not be tick");
	
   
	
	
	Source[i] = ExtSubscribe(i, nil, Parameters[tostring(i*100 + 1)], instance.parameters.Type == "Bid", "bar");
	
				if i ==  1 then
				Indicator[i] = core.indicators:create("EMA", Source[i][Price],Parameters[tostring(i*100 + 2)]);
				end
				if i ==  2 then
				Indicator[i] = core.indicators:create("RSI", Source[i][Price] , Parameters[tostring(i*100 + 3)] );
				end
				
				if i ==  3 then
				Indicator[i] = core.indicators:create("CCI", Source[i] , Parameters[tostring(i*100 + 6)] );
				end
	 end

   
 
 

    PrepareTrading();
  

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
	for i = 1, TfNumber , 1 do	
    Indicator[i]:update(core.UpdateLast);
	end

    local FLAG = true;
	
	for i = 1, TfNumber , 1 do	
		if Indicator[i].DATA:size() <= Indicator[i].DATA:first() + 2  then
		   FLAG= false;
		end
	end

	if not FLAG then
	return;
	end
	
  
		
		   if core.crossesOver(Source[1].close, Indicator[1].DATA , Source[1].close:size()-2, Indicator[1].DATA:size()-2 ) 		
		   and  (Indicator[2].DATA[Indicator[2].DATA:size()-2 ] < Parameters[tostring(2*100 + 4)]or not  ON[2]) 
		    and  (Indicator[3].DATA[Indicator[3].DATA:size()-2 ] < Parameters[tostring(3*100 + 7)]or not  ON[2]) 
		   then
       
		
            if Direction then
                BUY();
            else
                SELL();
            end		
			
		   elseif core.crossesUnder(Source[1].close, Indicator[1].DATA , Source[1].close:size()-2, Indicator[1].DATA:size()-2 ) 	
		    and  (Indicator[2].DATA[Indicator[2].DATA:size()-2 ] > Parameters[tostring(2*100 + 5)]or not  ON[2]) 
		   and  (Indicator[3].DATA[Indicator[3].DATA:size()-2 ] > Parameters[tostring(3*100 + 8)]or not  ON[3]) 
		 then
            if Direction then
                SELL();
            else
                BUY();
            end
        end		
		
		if core.crossesUnder(Source[1].close, Indicator[1].DATA , Source[1].close:size()-2, Indicator[1].DATA:size()-2 ) 	then
		
		           		
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
		             
		 elseif core.crossesOver(Source[1].close, Indicator[1].DATA , Source[1].close:size()-2, Indicator[1].DATA:size()-2 )  then 
		 
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



