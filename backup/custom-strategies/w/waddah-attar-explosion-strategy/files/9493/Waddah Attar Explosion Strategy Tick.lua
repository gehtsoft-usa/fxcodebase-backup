-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=360

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Strategy profile initialization routine
-- Defines Strategy profile properties and Strategy parameters
function Init()
    strategy:name("Waddah Attar Explosion strategy");
    strategy:description("Waddah Attar Explosion strategy");
	
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert,Account,CanTrade,Email,SendEmail");

    strategy.parameters:addGroup("Price Parameters");
    strategy.parameters:addString("TF", "TF", "Time frame ('t1', 'm1', 'm5', etc.)", "T");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);
	
	--strategy.parameters:addBoolean("AllowTicks", "Allow Ticks", "", false);
	
	strategy.parameters:addString("Type", "Bid/Ask", "Bid", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
    
    strategy.parameters:addGroup("Parameters");
	strategy.parameters:addInteger("Sen", "Sensitivity", "", 150);
    strategy.parameters:addInteger("DeadZonePip", "Dead Zone in pips", "", 30);
    strategy.parameters:addInteger("ExplosionPower", "Explosion Power", "", 15);
    strategy.parameters:addInteger("TrendPower", "Trend Power", "", 15);

    strategy.parameters:addGroup("Trading Parameters");
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false);
	strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);  
	
	 strategy.parameters:addBoolean("AllowMultiple", "Allow Multiple Positions in the same direction", "", true);
	 
	 strategy.parameters:addString("SIDE", "Allow Short/Long/Both Positions", "", "BOTH");
    strategy.parameters:addStringAlternative("SIDE", "Both", "", "BOTH");
    strategy.parameters:addStringAlternative("SIDE", "Short", "", "SHORT");
	strategy.parameters:addStringAlternative("SIDE", "Long", "", "LONG");
	 
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 100);
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false);
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false);
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false);

    strategy.parameters:addGroup("Notification");
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", true);
    strategy.parameters:addBoolean("RecurSound", "Recurrent Sound", "", true);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", true);
    strategy.parameters:addString("Email", "Email", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

-- Parameters block
local SIDE;
local gSource = nil; -- the source stream
local PlaySound;
local RecurrentSound;
local SoundFile;
local Email;
local SendEmail;
local AllowTrade;
local Account;
local Amount;
local BaseSize;
local SetLimit;
local Limit;
local SetStop;
local Stop;
local TrailingStop;
local Offer;
local CanClose;
local AllowMultiple;
--TODO: Add variable(s) for your strategy if needed
local WAD, WAD1, WAD2, WAD3;
local ExplosionPower;
local TrendPower;
local first;
local DeadZone;


-- strategy instance initialization routine
-- Processes strategy parameters and subscribe to price streams
-- TODO: Calculate all constants, create instances all necessary indicators and load all required libraries
function Prepare(nameOnly)

    local Sen;
    local DeadZonePip;
    local ShowAlert;

    Sen = instance.parameters.Sen;
    DeadZonePip = instance.parameters.DeadZonePip;
    ExplosionPower = instance.parameters.ExplosionPower;
    TrendPower = instance.parameters.TrendPower;

    SIDE= instance.parameters.SIDE;   
    AllowMultiple= instance.parameters.AllowMultiple;
    local name = profile:id() .. "(" .. instance.bid:instrument() .. ")";
    instance:name(name);

    if nameOnly then
        return ;
    end

	--local AllowTicks;
    --AllowTicks = instance.parameters.AllowTicks;
    --if (not(AllowTicks)) then
        assert(instance.parameters.TF == "t1", "Use this strategy only on ticks.");
    --end

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
        Amount = instance.parameters.Amount;
        BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account);
        Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;
        CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account);
        SetLimit = instance.parameters.SetLimit;
        Limit = instance.parameters.Limit * instance.bid:pipSize();
        SetStop = instance.parameters.SetStop;
        Stop = instance.parameters.Stop * instance.bid:pipSize();
        TrailingStop = instance.parameters.TrailingStop;
    end
	
	 --TODO: Find indicator's profile, intialize parameters, and create indicator's instance (if needed)
	
    --ExtSubscribe(1, nil, instance.parameters.TF, true, "close");
	
  --  assert(instance.parameters.Period ~= "t1", "Can't be applied on ticks!");
    gSource = ExtSubscribe(2, nil, instance.parameters.TF, true, "close");
	
	 assert(core.indicators:findIndicator("WADDAH_ATTAR_EXPLOSION_TICK") ~= nil, "WADDAH_ATTAR_EXPLOSION_TICK indicator must be installed");
	
    local ps = gSource:pipSize();
    if ps > 1 then
        ps = math.pow(10, -ps);
    end
    DeadZone = DeadZonePip * ps;
    WAD = core.indicators:create("WADDAH_ATTAR_EXPLOSION_TICK", gSource, Sen, DeadZonePip);
    WAD1 = WAD:getStream(0);
    WAD2 = WAD:getStream(1);
    WAD3 = WAD:getStream(2);
    first = WAD1:first() + 2;

    ExtSetupSignal(profile:id() .. ":", ShowAlert);
    ExtSetupSignalMail(name);
    setTimer();   
end

-- strategy calculation routine
-- TODO: Add your code for decision making
-- TODO: Update the instance of your indicator(s) if needed
function ExtUpdate(id, source, period)
   
   if id == 2 then
        -- the WAD source is updated
        WAD:update(core.UpdateLast);
        if period > first then
            local trend1, trend2, explosion1, explosion2;
            local pwre, pwrt;

            if WAD1[period] ~= 0 then
                trend1 = WAD1[period];
            elseif WAD2[period] ~= 0 then
                trend1 = -WAD2[period];
            else
                trend1 = 0;
            end

            if WAD1[period - 2] ~= 0 then
                trend2 = WAD1[period - 2];
            elseif WAD2[period - 2] ~= 0 then
                trend2 = -WAD2[period - 2];
            else
                trend2 = 0;
            end

            explosion1 = WAD3[period];
            explosion2 = WAD3[period - 1];

            if trend1 > 0 and trend1 > explosion1 and trend1 > DeadZone and
               explosion1 > DeadZone and explosion1 > explosion2 and trend1 > trend2 and PrevSignal ~= 1 then
                pwrt = 100 * (trend1 - trend2) / trend1;
                pwre = 100 * (explosion1 - explosion2) / explosion1;
                if pwre >= ExplosionPower and pwrt >= TrendPower then
                    --ExtSignal(gSource, period, "BUY", SoundFile);
					SIGNAL (true,source, period);
                    PrevSignal = 1;
                end
            end

            if trend1 < 0 and math.abs(trend1) > explosion1 and math.abs(trend1) > DeadZone and
               explosion1 > DeadZone and explosion1 > explosion2 and math.abs(trend1) > math.abs(trend2) and PrevSignal ~= 2 then
                pwrt = 100 * (math.abs(trend1) - math.abs(trend2)) / math.abs(trend1);
                pwre = 100 * (explosion1 - explosion2) / explosion1;
                if pwre >= ExplosionPower and pwrt >= TrendPower then
				    SIGNAL (false,source, period);
                    --ExtSignal(gSource, period, "SELL", SoundFile);
                    PrevSignal = 2;
                end
            end
        end
    end
		

		    
	
end

function SIGNAL (FLAG,source, period)

		if FLAG then
					if haveTrades('B')  and not  AllowMultiple then
					return;
					end
					
					if SIDE == "SHORT" then
					return;
					end
					
					              ExtSignal(source, period,  "Enter Long" , SoundFile, Email, RecurrentSound);   
								 --if ShowAlert then
								--	terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Enter Long", instance.bid:date(NOW));
								--end
								--if SoundFile ~= nil then
								--	terminal:alertSound(SoundFile, RecurrentSound);
								--end
								
								--if Email ~= nil then
								-- terminal:alertEmail(Email, "Enter Long", profile:id() .. "(" .. instance.bid:instrument() .. ")" ..", " ..instance.bid:instrument()..", " .. instance.bid[NOW]..", " .. "Enter Long"..", " .. instance.bid:date(NOW));
								--end

								if AllowTrade then
									if haveTrades('S') then
									exit('S');
									end
									enter('B');
							   end     

		else
		                if haveTrades('S')  and not  AllowMultiple then
						return;
						end
						
						if SIDE == "LONG" then
						return;
						end
			
			         --     if ShowAlert then
						--	terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Enter Short", instance.bid:date(NOW));
					--	end
					--	if SoundFile ~= nil then
					--		terminal:alertSound(SoundFile, RecurrentSound);
					--	end
						
					--	if Email ~= nil then
					--	 terminal:alertEmail(Email, "Enter Short", profile:id() .. "(" .. instance.bid:instrument() .. ")" ..", " ..instance.bid:instrument()..", " .. instance.bid[NOW]..", " .. "Enter Short"..", " .. instance.bid:date(NOW));
					--	end
					
					ExtSignal(source, period,  "Enter Short" , SoundFile, Email, RecurrentSound);   

						if AllowTrade then
						    if haveTrades('B') then
                            exit('B');
							end
                            enter('S');
	    		       end      
		end
end

function ExtAsyncOperationFinished(id, success, message)
    checkTimer(id, success, message);
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
           row.OfferID == Offer and
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
function checkTimer(id, success, message) 
    if ((not CanClose) and id == TRADE_CHECK and requestId ~= nil) then
        local trades = core.host:findTable("trades");
        row = trades:find('OpenOrderReqID', requestId);
        if (row ~= nil) then
            local stopped = false
            if SetLimit then
               if (limitInfo.SB == "S" and instance.bid[NOW] >= limitInfo.rate) or
                  (limitInfo.SB == "B" and instance.ask[NOW] <= limitInfo.rate) then
                  exit(row.BS);
                  stopped = true;
                end
            end
            if SetStop and (not stopped) then
                if  (stopInfo.SB == "S" and instance.bid[NOW] <= stopInfo.rate) or
                    (stopInfo.SB == "B" and instance.ask[NOW] >= stopInfo.rate) then
                  exit(row.BS);
                  stopped = true;
                end
            end
            if (not stopped) then
              if SetLimit then 
                fifoSL("LE", limitInfo.SB, limitInfo.rate, false)
              end
              if SetStop then 
                fifoSL("SE", stopInfo.SB, stopInfo.rate, stopInfo.trail)            
              end
            end
            requestId = nil
        end
    end
end 

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
	if not AllowMultiple  then		
		if haveTrades(BuySell) then
			return true;
		end
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
function exit(BuySell)
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
        valuemap.OfferID = Offer;
        valuemap.AcctID = Account;
        valuemap.NetQtyFlag = "Y";
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
