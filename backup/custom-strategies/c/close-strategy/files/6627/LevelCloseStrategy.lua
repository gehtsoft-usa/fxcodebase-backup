--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

function Init()
    strategy:name("Level Close Strategy");
    strategy:description("Level Close Strategy");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");

    strategy.parameters:addGroup("Parameters");
    strategy.parameters:addDouble("ProfitLevel", "Profit level for close orders in the account currency", "", 0);
    strategy.parameters:addString("LevelType", "Type of profit level", "", "ABOVE");
    strategy.parameters:addStringAlternative("LevelType", "ABOVE", "", "ABOVE");
    strategy.parameters:addStringAlternative("LevelType", "BELOW", "", "BELOW");

    strategy.parameters:addGroup("Trading Parameters");
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false);   
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
	strategy.parameters:addBoolean("Terminate", "Terminate after execution ", "", true);
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    
    strategy.parameters:addBoolean("All", "Use on All Symbols", "", true);
 
   
    strategy.parameters:addString("Symbol", "Symbol", "", "EUR/USD");
    strategy.parameters:setFlag("Symbol", core.FLAG_INSTRUMENTS );
 
    strategy.parameters:addGroup("Notification");
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", false);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", true);
    strategy.parameters:addBoolean("RecurSound", "Recurrent Sound", "", true);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", true);
    strategy.parameters:addString("Email", "Email", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

-- Parameters block
local gSource = nil; -- the source stream
local PlaySound;
local RecurrentSound;
local SoundFile;
local Email;
local SendEmail;
local AllowTrade;
local Account;
local BaseSize;
local Offer;
local CanClose;
local All;
local Terminate;
-- strategy instance initialization routine
-- Processes strategy parameters and subscribe to price streams
-- TODO: Calculate all constants, create instances all necessary indicators and load all required libraries
function Prepare(nameOnly)

    local name = profile:id() .. "(" .. instance.bid:instrument() .. ")";
    instance:name(name);
	
	Terminate=instance.parameters.Terminate;

    if nameOnly then
        return ;
    end

	All= instance.parameters.All;
    AllowTicks = instance.parameters.AllowTicks;
    if (not(AllowTicks)) then
        assert(instance.parameters.TF ~= "t1", "The strategy cannot be applied on ticks.");
    end

    ShowAlert = instance.parameters.ShowAlert;
    if ShowAlert then
        PlaySound = instance.parameters.PlaySound;
        if PlaySound then
            RecurrentSound = instance.parameters.RecurSound;
            SoundFile = instance.parameters.SoundFile;
        else
            SoundFile = nil;
        end
        assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");

        SendEmail = instance.parameters.SendEmail;
        if SendEmail then
            Email = instance.parameters.Email;
        else
            Email = nil;
        end
        assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
    end

    AllowTrade = instance.parameters.AllowTrade;
    if AllowTrade then
        Account = instance.parameters.Account;
        BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account);
        Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;
        CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account);
    end
    gSource = ExtSubscribe(1, nil, "t", true, "close");

    ExtSetupSignal(profile:id() .. ":", ShowAlert);
    ExtSetupSignalMail(name);
    setTimer();

end

function ExtUpdate(id, source, period)
    if AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
            return ;
        end
    end
    
    if haveTrades() then
        local trades = core.host:findTable("trades");
        local enum = trades:enumerator();
        local PL=0;
        while true do
            local row = enum:next();
            if row == nil then break end

            if row.AccountID == Account and (All== true or row.Instrument==instance.parameters.Symbol) then
                if row.BS == 'B' then
                 PL=PL+row.GrossPL; 
                elseif row.BS == 'S' then
                 PL=PL+row.GrossPL; 
                end

            end
        end
        if (PL>=instance.parameters.ProfitLevel and instance.parameters.LevelType=="ABOVE") or (PL<=instance.parameters.ProfitLevel and instance.parameters.LevelType=="BELOW") then
        
        local enum = trades:enumerator();
          while true do
            local row = enum:next();
            if row == nil then break end

            if row.AccountID == Account and (All== true or row.Instrument==instance.parameters.Symbol) then
                if row.BS == 'B' then
		        if ShowAlert then
                            ExtSignal(source, period, "Close", SoundFile, Email, RecurrentSound);
	    		end

		        if AllowTrade then
                            exit('B',row);
	    		end
                elseif row.BS == 'S' then
            		if ShowAlert then
                            ExtSignal(source, period, "Close", SoundFile, Email, RecurrentSound);
	    		end

            		if AllowTrade then
                            exit('S',row);
	    		end
                end
				
			 if Terminate then	
             core.host:execute("stop");   
			 end

            end
          end
        end
    end
end

function ExtAsyncOperationFinished(id, success, message)
end

--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--
local TRADE_CHECK = 10001
local requestId = nil
local limitInfo, stopInfo

-- -----------------------------------------------------------------------
-- Function checks that specified table is ready (filled) for processing
-- or that we running under debugger/simulation conditions.
-- -----------------------------------------------------------------------
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
           (instance.parameters.Symbol=="- All -" or row.Instrument == instance.parameters.Symbol) and
           (row.BS == BuySell or BuySell == nil) then
           found = true;
        end
        row = enum:next();
    end

    return found
end

-- -----------------------------------------------------------------------
-- Sets timer for FIFO accounts which is check s
-- -----------------------------------------------------------------------
function setTimer() 
  -- Set check timer for FIFO accounts only
  if AllowTrade and not CanClose then 
    core.host:execute ("setTimer", TRADE_CHECK, 1)
  end
end   

-- -----------------------------------------------------------------------
-- Checks necessity to create stop/limit orders
-- -----------------------------------------------------------------------

-- -----------------------------------------------------------------------
-- Enter into the specified direction
--  BuySell : direction to enter, shoulde be 'B' for long position or 'S' for short
-- -----------------------------------------------------------------------
function enter(BuySell)
    if not(AllowTrade) then
        return true;
    end
    
    local valuemap, success, msg;

    -- do not enter if position in the specified direction already exists
    if haveTrades(BuySell) then
        return true;
    end

    valuemap = core.valuemap();

    valuemap.OrderType = "OM";
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    valuemap.Quantity = Amount * BaseSize;
    valuemap.BuySell = BuySell;
    valuemap.PegTypeStop = "M";

    if SetLimit and CanClose then
        -- set limit order
        if BuySell == "B" then
            valuemap.RateLimit = instance.ask[NOW] + Limit;
        else
            valuemap.RateLimit = instance.bid[NOW] - Limit;
        end
    end

    if SetStop and CanClose then
        -- set limit order
        if BuySell == "B" then
            valuemap.RateStop = instance.ask[NOW] - Stop;
        else
            valuemap.RateStop = instance.bid[NOW] + Stop;
        end
        if TrailingStop then
            valuemap.TrailStepStop = 1;
        end
    end

    success, msg = terminal:execute(100, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed:" .. msg, instance.bid:date(instance.bid:size() - 1));
        return false;
    end
    
    if SetLimit and not(CanClose) then
        requestId = msg
        if BuySell == "B" then
            limitInfo = {SB = "S", rate = instance.ask[NOW] + Limit};
        else
            limitInfo = {SB = "B", rate = instance.bid[NOW] - Limit};
        end
    end

    if SetStop and not(CanClose) then
        requestId = msg
        if BuySell == "B" then
            stopInfo = {SB = "S", rate = instance.ask[NOW] - Stop, trail = TrailingStop};
        else
            stopInfo = {SB = "B", rate = instance.bid[NOW] + Stop, trail = TrailingStop};
        end
    end
    
    return true;
end

-- -----------------------------------------------------------------------
-- Fifo Stop/Limit helper. This function creates 
--  BuySell : direction to enter, shoulde be 'B' for long position or 'S' for short
-- -----------------------------------------------------------------------
function fifoSL(orderType, side, rate, trailing)
    local valuemap = core.valuemap();
    valuemap.Command = "CreateOrder";
    
    local enum, row;
    local buy, sell;
    enum = core.host:findTable("orders"):enumerator();
    row = enum:next();
    while (row ~= nil) do
        if row.OfferID == Offer and row.AccountID == Account and
           row.BS == side       and row.NetQuantity and
           row.Type == orderType then
              valuemap.Command = "EditOrder";
              valuemap.OrderID = row.OrderID
              break; 
        end
        row = enum:next();
    end

    valuemap.OrderType = orderType;
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    valuemap.NetQtyFlag = "y";
    valuemap.Rate = rate;
    valuemap.BuySell = side;
    if trailing then
        valuemap.TrailUpdatePips = 1;
    end

    local success, msg;
    success, msg = terminal:execute(102, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Failed create limit or stop " .. msg, instance.bid:date(NOW));
    end
end

-- -----------------------------------------------------------------------
--  Exit from the specified direction
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

--===========================================================================--
--                      END OF TRADING UTILITY FUNCTIONS                     --
--===========================================================================--

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
