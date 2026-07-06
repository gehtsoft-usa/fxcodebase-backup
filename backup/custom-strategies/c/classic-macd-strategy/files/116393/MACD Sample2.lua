-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=2473&start=20

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
    strategy:name("MACD Sample");
    strategy:description("Classic MACD sample");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");

	strategy.parameters:addString("ExecutionType", "End of Turn / Live", "", "End of Turn");
    strategy.parameters:addStringAlternative("ExecutionType", "End of Turn", "", "End of Turn");
	strategy.parameters:addStringAlternative("ExecutionType", "Live", "", "Live");

    strategy.parameters:addGroup("MACD indicator parameters");
    strategy.parameters:addInteger("SN", "Short EMA", "The period of the short EMA.", 12, 2, 1000);
    strategy.parameters:addInteger("LN", "Long EMA", "The period of the long EMA.", 26, 2, 1000);
    strategy.parameters:addInteger("IN", "Signal line", "The number of periods for the signal line.", 9, 2, 1000);

    strategy.parameters:addGroup("Strategy Parameters");
    strategy.parameters:addInteger("MACDOpenLevel", "MACD Open Level", "Minimal MACD level for open position.", 3, 0, 1000)
    strategy.parameters:addInteger("MACDCloseLevel", "MACD Close Level", "MACD level for closing position", 2, 0, 1000)
    strategy.parameters:addBoolean("ConfirmTrend", "Cofirm Trend with MA", "Do we need to confirm MACD signal with Moving Average trend", false);
    strategy.parameters:addInteger("MN", "MA Trend", "MA Trend Period", 26, 2, 1000);

    strategy.parameters:addGroup("Price Parameters");
    strategy.parameters:addString("TF", "Time Frame", "", "m15");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Trading Parameters");
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false);   
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addBoolean("AllowMultiple", "Allow Multiple", "Should we allow multiple positions in the same direction.", true);
	strategy.parameters:addString("TradeSide", "Trade side", "", "Both");
    strategy.parameters:addStringAlternative("TradeSide", "Both", "", "Both");
    strategy.parameters:addStringAlternative("TradeSide", "Only Sell", "", "Sell");
    strategy.parameters:addStringAlternative("TradeSide", "Only Buy", "", "Buy");

	
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 100);
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false);
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false);
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false);

    strategy.parameters:addGroup("Signal Parameters");
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    strategy.parameters:addBoolean("Recurrent", "RecurrentSound", "", false);

    strategy.parameters:addGroup("Email Parameters");
    strategy.parameters:addBoolean("SendEmail", "Send email", "", false);
    strategy.parameters:addString("Email", "Email address", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

-- Signal Parameters
local ShowAlert;
local SoundFile;
local RecurrentSound;
local SendEmail, Email;
local AllowMultiple;

-- Internal indicators
local MACD = nil;
local EMA = nil;

-- Strategy parameters
local openLevel = 0
local closeLevel = 0
local confirmTrend;

-- Trading parameters
local AllowTrade = nil;
local Account = nil;
local Amount = nil;
local BaseSize = nil;
local PipSize;
local SetLimit = nil;
local Limit = nil;
local SetStop = nil;
local Stop = nil;
local TrailingStop = nil;
local CanClose = nil;
local LastTradeTime;
local TradeSide = nil;
local ExecutionType = nil;
local TickSource = nil;
local ONE = nil;

--
--
--
function Prepare(nameOnly) 
    ShowAlert = instance.parameters.ShowAlert;
    AllowMultiple=instance.parameters.AllowMultiple;
    ExecutionType = instance.parameters.ExecutionType;
    local PlaySound = instance.parameters.PlaySound
    if  PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
    assert(not(PlaySound) or SoundFile ~= "", "Sound file must be chosen");
    RecurrentSound = instance.parameters.Recurrent;

    local SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or Email ~= "", "Email address must be specified");
    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick");

    local name;
    name = profile:id() .. "(" .. instance.bid:name() .. "." .. instance.parameters.TF .. "," ..
           "MACD(" .. instance.parameters.SN .. "," .. instance.parameters.LN .. "," .. instance.parameters.IN .. "))";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end


    openLevel  = instance.parameters.MACDOpenLevel * instance.bid:pipSize()
    closeLevel = instance.parameters.MACDCloseLevel * instance.bid:pipSize()
    confirmTrend = instance.parameters.ConfirmTrend;

    TradeSide = instance.parameters.TradeSide;
    AllowTrade = instance.parameters.AllowTrade;
    if AllowTrade then
        Account = instance.parameters.Account;
        Amount = instance.parameters.Amount;
        BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account);
        Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;
        CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account);
        PipSize = instance.bid:pipSize();
        SetLimit = instance.parameters.SetLimit;
        Limit = instance.parameters.Limit;
        SetStop = instance.parameters.SetStop;
        Stop = instance.parameters.Stop;
        TrailingStop = instance.parameters.TrailingStop;
    end

	if ExecutionType== "Live" then
        TickSource = ExtSubscribe(1, nil, "t1", true, "close");
	end


    CloseSource = ExtSubscribe(2, nil, instance.parameters.TF, true, "close");
    MACD = core.indicators:create("MACD", CloseSource, instance.parameters.SN, instance.parameters.LN, instance.parameters.IN);
    EMA = core.indicators:create("EMA", CloseSource, instance.parameters.MN);

    ExtSetupSignal(profile:id() .. ":", ShowAlert);
    ExtSetupSignalMail(name);
end

function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.
    
    local date = source:date(period);

	if  ExecutionType ==  "Live" and  id == 1 then	
        period= core.findDate (CloseSource, TickSource:date(period), false );						
	end

	if  ExecutionType ==  "Live"  then
        
        if ONE == CloseSource:serial(period) then
			return;
        end
	
        if id == 2 then
            return;
        end									
	else	
	    	    
        if id ~= 2 then       
            return;
        end
	end

    MACD:update(core.UpdateLast)
    EMA:update(core.UpdateLast)

    -- Check that we have enough data
    if (MACD.SIGNAL:first() > (period - 1) or EMA.EMA:first() > (period - 1)) then
        return
    end
    
    local macd, signal = MACD.MACD, MACD.SIGNAL
    local ma = EMA.EMA
    local pipSize = instance.bid:pipSize()
    local trades = core.host:findTable("trades");
    local haveTrades = (trades:find('AccountID', Account) ~= nil)

    if (not haveTrades) then
        -- Open BUY (Long) position if MACD line crosses over SIGNAL line
        -- in negative area below openLevel. Also check MA trend if
        -- confirmTrend flag is 'true'
        if TradeSide == "Both" or TradeSide == "Buy" then
            if (macd[period] < 0 and core.crossesOver(macd, signal, period) and math.abs(macd[period]) > openLevel and
                (not confirmTrend or ma[period] > ma[period - 1])) then

                if ShowAlert then
                    ExtSignal(source, period, "BUY", SoundFile, Email, RecurrentSound)
                end

                if AllowTrade then
                    Open("B")
                end
                
                ONE= CloseSource:serial(period);
            end
        end

        -- Open SELL (Short) position if MACD line crosses under SIGNAL line
        -- in positive area above openLevel. Also check MA trend if
        -- confirmTrend flag is 'true'
        if TradeSide == "Both" or TradeSide == "Sell" then
            if (macd[period] > 0 and core.crossesUnder(macd, signal, period) and macd[period] > openLevel and
               (not confirmTrend or ma[period] < ma[period - 1])) then
                if ShowAlert then
                    ExtSignal(source, period, "SELL", SoundFile, Email, RecurrentSound)
                end

                if AllowTrade then
                    Open("S")
                end
                
                ONE= CloseSource:serial(period);
            end
        end
    else
        local enum = trades:enumerator();
        while true do
            local row = enum:next();
            if row == nil then break end

            if row.AccountID == Account and row.OfferID == Offer then
                    -- Close position if we have corresponding closing conditions.
                if row.BS == 'B' then
                    if (macd[period] > 0 and core.crossesUnder(macd, signal, period) and macd[period] > closeLevel) then
                        if ShowAlert then
                            ExtSignal(source, period, "SELL", SoundFile, Email, RecurrentSound);
                        end

                        if AllowTrade then
                            Close(row);
                        end
                        ONE= CloseSource:serial(period);
                    end

                    if TradeSide == "Both" or TradeSide == "Buy" then
                        if AllowMultiple and LastTradeTime~=date then
                            if (macd[period] < 0 and core.crossesOver(macd, signal, period) and math.abs(macd[period]) > openLevel and
                                (not confirmTrend or ma[period] > ma[period - 1])) then

                                LastTradeTime=date;

                                if ShowAlert then
                                    ExtSignal(source, period, "BUY", SoundFile, Email, RecurrentSound)
                                end

                                if AllowTrade then
                                    Open("B")
                                end
                                
                                ONE= CloseSource:serial(period);
                            end
                        end
                    end
                elseif row.BS == 'S' then
                    if (macd[period] < 0 and core.crossesOver(macd, signal, period) and math.abs(macd[period]) > closeLevel) then
            		  if ShowAlert then
                            ExtSignal(source, period, "BUY", SoundFile, Email, RecurrentSound);
	    		      end

            		  if AllowTrade then
                            Close(row);
	    		      end
	    		      
                      ONE= CloseSource:serial(period);
                    end

                    if TradeSide == "Both" or TradeSide == "Sell" then
                        if AllowMultiple and LastTradeTime~= date then
                            if (macd[period] > 0 and core.crossesUnder(macd, signal, period) and macd[period] > openLevel and
                                (not confirmTrend or ma[period] < ma[period - 1])) then

                                LastTradeTime=date;

                                if ShowAlert then
                                    ExtSignal(source, period, "SELL", SoundFile, Email, RecurrentSound)
                                end

                                if AllowTrade then
                                    Open("S")
                                end
                                
                                ONE= CloseSource:serial(period);
                            end
                        end
                    end
                end

            end
        end
    end
end

-- The strategy instance finalization.
function ReleaseInstance()
end

-- The method enters to the market
function Open(side)
    local valuemap;

    valuemap = core.valuemap();
    valuemap.OrderType = "OM";
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    valuemap.Quantity = Amount * BaseSize;
    valuemap.CustomID = CID;
    valuemap.BuySell = side;
    if SetStop and CanClose then
        valuemap.PegTypeStop = "O";
        if side == "B" then
            valuemap.PegPriceOffsetPipsStop = -Stop;
        else
            valuemap.PegPriceOffsetPipsStop = Stop;
        end
        if TrailingStop then
            valuemap.TrailStepStop = 1;
        end;
    end
    if SetLimit and CanClose then
        valuemap.PegTypeLimit = "O";
        if side == "B" then
            valuemap.PegPriceOffsetPipsLimit = Limit;
        else
            valuemap.PegPriceOffsetPipsLimit = -Limit;
        end
    end
    success, msg = terminal:execute(200, valuemap);
    assert(success, msg);

    -- FIFO Account, in that case we have to open Net Limit and Stop Orders
    if not(CanClose) then
        if SetStop then
            valuemap = core.valuemap();
            valuemap.OrderType = "SE"
            valuemap.OfferID = Offer;
            valuemap.AcctID = Account;
            valuemap.NetQtyFlag = 'y';
            if side == "B" then
                valuemap.BuySell = "S";
                rate = instance.ask[NOW] - Stop * PipSize;
                valuemap.Rate = rate;
            elseif side == "S" then
                valuemap.BuySell = "B";
                rate = instance.bid[NOW] + Stop * PipSize;
                valuemap.Rate = rate;
            end
            if TrailingStop then
                valuemap.TrailUpdatePips = 1
            end
            success, msg = terminal:execute(200, valuemap);
            --core.host:trace('Set stop @ ' .. rate);
            assert(success, msg);
        end
        if SetLimit then
            valuemap = core.valuemap();
            valuemap.OrderType = "LE"
            valuemap.OfferID = Offer;
            valuemap.AcctID = Account;
            valuemap.NetQtyFlag = 'y';
            if side == "B" then
                valuemap.BuySell = "S";
                rate = instance.ask[NOW] + Limit * PipSize;
                valuemap.Rate = rate;
            elseif side == "S" then
                valuemap.BuySell = "B";
                rate = instance.bid[NOW] - Limit * PipSize;
                valuemap.Rate = rate;
            end
            success, msg = terminal:execute(200, valuemap);
            --core.host:trace('Set limit @ ' .. rate);
            assert(success, msg);
        end
    end
end

-- Closes specific position
function Close(trade)
    local valuemap;
    valuemap = core.valuemap();

    if CanClose then
        -- non-FIFO account, create a close market order
        valuemap.OrderType = "CM";
        valuemap.TradeID = trade.TradeID;
    else
        -- FIFO account, create an opposite market order
        valuemap.OrderType = "OM";
    end

    valuemap.OfferID = trade.OfferID;
    valuemap.AcctID = trade.AccountID;
    valuemap.Quantity = trade.Lot;
    valuemap.CustomID = trade.QTXT;
    if trade.BS == "B" then valuemap.BuySell = "S"; else valuemap.BuySell = "B"; end
    success, msg = terminal:execute(200, valuemap);
    assert(success, msg);
end

function AsyncOperationFinished(cookie, successful, message)
  if not successful then
    core.host:trace('Error: ' .. message)
  end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
