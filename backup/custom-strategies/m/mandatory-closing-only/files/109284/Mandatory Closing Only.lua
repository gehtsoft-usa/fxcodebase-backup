-- Id: 17116
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=64152

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
    strategy:name("MandatoryClosing");
    strategy:description("");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");
	
 
 
    strategy.parameters:addInteger("ToTime", "Convert the date to", "", 6);
    strategy.parameters:addIntegerAlternative("ToTime", "EST", "", 1);
    strategy.parameters:addIntegerAlternative("ToTime", "UTC", "", 2);
    strategy.parameters:addIntegerAlternative("ToTime", "Local", "", 3);
    strategy.parameters:addIntegerAlternative("ToTime", "Server", "", 4);
    strategy.parameters:addIntegerAlternative("ToTime", "Financial", "", 5);
	strategy.parameters:addIntegerAlternative("ToTime", "Display", "", 6);
	
 
 
	
	

	


	
    CreateTradingParameters();
end

function CreateTradingParameters()
    strategy.parameters:addGroup("Trading Parameters"); 
	
	strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false);   
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
	
	
	strategy.parameters:addString("AccountType", "Account Type", "", "Automatic");
    strategy.parameters:addStringAlternative("AccountType", "FIFO", "", "FIFO");
	strategy.parameters:addStringAlternative("AccountType", "non FIFO", "", "NON");
    strategy.parameters:addStringAlternative("AccountType", "Automatic", "", "Automatic");
	
 
	 strategy.parameters:addBoolean("UseIdentifier", "Use Custom Identifier", "", false);
     strategy.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "CATR");
	
	 
 
    strategy.parameters:addString("ALLOWEDSIDE", "Allowed side", "Allowed side for trading or signaling, can be Sell, Buy or Both", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell");
	
 

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
	
	 strategy.parameters:addGroup("Time Parameters");
    strategy.parameters:addBoolean("UseMandatoryClosing", "Use Mandatory Closing", "", true);
		strategy.parameters:addBoolean("Exit", "Close Strategy after first Trade Execution", "", false);
    strategy.parameters:addString("ExitTime", "Mandatory Closing  Time", "", "23:59:00");
    strategy.parameters:addInteger("ValidInterval", "Valid interval for operation (in second)", "", 60);
end


local  ExitTime,ValidInterval;
local Source;
local SoundFile = nil;
local RecurrentSound = false;
local ALLOWEDSIDE;
local AllowTrade;
local Offer;
local CanClose;
local Account;
local ShowAlert;
local Email;
local SendEmail;
local BaseSize;
local first;
local Exit;
local Direction;
local CustomID;
local UseIdentifier;
local ToTime;
-- Don't need to store hour + minute + second for each time
local  ExitTime;
local AccountType;


function Prepare( nameOnly)
   CustomID = instance.parameters.CustomID;
	
    local name = profile:id() .. "( " .. instance.bid:name() .. "," .. CustomID ..  " )";
    instance:name(name); 

    if nameOnly then
        return ;
    end
	
	
	Direction = instance.parameters.Direction == "direct";	
	AccountType= instance.parameters.AccountType;	
	ValidInterval = instance.parameters.ValidInterval;
	UseMandatoryClosing = instance.parameters.UseMandatoryClosing;
	UseIdentifier = instance.parameters.UseIdentifier;	 
	Exit= instance.parameters.Exit;
	ToTime= instance.parameters.ToTime;
	
	--[[
	strategy.parameters:addIntegerAlternative("ToTime", "EST", "", 1);
    strategy.parameters:addIntegerAlternative("ToTime", "UTC", "", 2);
    strategy.parameters:addIntegerAlternative("ToTime", "Local", "", 3);
    strategy.parameters:addIntegerAlternative("ToTime", "Server", "", 4);
    strategy.parameters:addIntegerAlternative("ToTime", "Financial", "", 5);
	strategy.parameters:addIntegerAlternative("ToTime", "Display", "", 6);
	
	]]
	
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

   
   
    PrepareTrading();

  
	
	 local valid;  
    ExitTime, valid = ParseTime(instance.parameters.ExitTime);
    assert(valid, "Time " .. instance.parameters.ExitTime .. " is invalid");
	
	if UseMandatoryClosing then
        core.host:execute("setTimer", 100, math.max(ValidInterval / 2, 1));
    end 
  
end

 -- when indicator is being released
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

function InRange(now, openTime, closeTime)
    if openTime < closeTime then
        return now >= openTime and now <= closeTime;
    end
    if openTime > closeTime then
        return now > openTime or now < closeTime;
    end

    return now == openTime;
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
    Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;
    
	if AccountType== "FIFO" then
	CanClose=false;
    elseif AccountType== "NON" then
	CanClose=true;
	else
	CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account);
	end
	
end
 

  

function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.
 
end

-- NG: Introduce async function for timer/monitoring for the order results
function ExtAsyncOperationFinished(cookie, success, message)
 

    if cookie ~= 100
	or not UseMandatoryClosing
	or not AllowTrade
	then
	return;
	end
	
	  if not(checkReady("trades")) or not(checkReady("orders")) then
                    return ;
      end
				
	
        -- timer
 
            now = core.host:execute("getServerTime");			
			now= core.host:execute ("convertTime", core.TZ_EST, ToTime, now);
			 
			
            -- get only time
            now = now - math.floor(now);
            -- check whether the time is in the exit time period
			
			
            if not ((now >= ExitTime) and (now < (ExitTime + (ValidInterval/86400.0)))) then
			return;
			end
			
              
                if haveTrades("S") and ALLOWEDSIDE ~= "Buy" then
                     exitSpecific("S");
                     Signal ("Close Short");
                end
                if haveTrades("B") and ALLOWEDSIDE ~= "Sell" then
                     exitSpecific("B");
                     Signal ("Close Long");
               end
			   
				if Exit then
				core.host:execute ("stop");
				end
	 
 
end

--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--

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


function haveTrades(BuySell) 
    local enum, row;
    local found = false;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while (row ~= nil) do
        if row.AccountID == Account and row.OfferID == Offer and (row.QTXT == CustomID  or not UseIdentifier ) and (row.BS == BuySell or BuySell == nil) then
            found = true;
            break;
        end

        row = enum:next();
    end

    return found;
end


-- exit from the specified trade using the direction as a key
function exitSpecific(BuySell)
    -- we have to loop through to exit all trades in each direction instead
    -- of using the net qty flag because we may be running multiple strategies on the same account.
    local enum, row;
    local found = false;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while (not found) and (row ~= nil) do
        -- for every trade for this instance.
        if row.AccountID == Account and row.OfferID == Offer and (row.QTXT == CustomID  or not UseIdentifier )and (row.BS == BuySell or BuySell == nil) then
           exitTrade(row);
        end

        row = enum:next();
    end
end

-- exit from the specified direction
function exitTrade(tradeRow)
    if not(AllowTrade) then
        return true;
    end

    local valuemap, success, msg;
    valuemap = core.valuemap();

    -- switch the direction since the order must be in oppsite direction
    if tradeRow.BS == "B" then
        BuySell = "S";
    else
        BuySell = "B";
    end
    valuemap.OrderType = "CM";
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    if (CanClose) then
        -- Non-FIFO can close each trade independantly.
        valuemap.TradeID = tradeRow.TradeID;
        valuemap.Quantity = tradeRow.Lot;
    else
        -- FIFO.
        valuemap.NetQtyFlag = "Y"; -- this forces all trades to close in the opposite direction.
    end
    valuemap.BuySell = BuySell;
	
	if  UseIdentifier  then
    valuemap.CustomID = CustomID;
	end
	
    success, msg = terminal:execute(201, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Close order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        return false;
    end

    return true;
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");

