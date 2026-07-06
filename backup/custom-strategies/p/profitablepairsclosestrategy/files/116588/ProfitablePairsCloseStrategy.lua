-- Id: 20008

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=65471

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
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

function Init()
    strategy:name("Profitable Pairs Close Strategy");
    strategy:description("Profitable Pairs Close Strategy");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");

    strategy.parameters:addGroup("Parameters");
    strategy.parameters:addDouble("ProfitLevel", "Profit pairs level for close", "", 0);

    strategy.parameters:addGroup("Trading Parameters");
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false);   
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
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

function Prepare(nameOnly)

    local name = profile:id() .. "(" .. instance.bid:instrument() .. ")";
    instance:name(name);
	
    if nameOnly then
        return ;
    end

	All = instance.parameters.All;

	local profitlevel = instance.parameters.ProfitLevel
    --assert(profitlevel >= 0 and profitlevel <= 100, "Incorrect value of the Profit Level. 0 <= Profit Level <= 100");
	
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
    gSource = ExtSubscribe(1, nil, "t1", true, "close");

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
        local tradePairs = {};
        local instruments = {};
        while true do
            local row = enum:next();
            if row == nil then break end

            if row.AccountID == Account and (All== true or row.Instrument==instance.parameters.Symbol) then
            
                if tradePairs[row.Instrument] == nil then
                
                    tradePairs[row.Instrument] = {};
                    tradePairs[row.Instrument]['B'] = {};
                    tradePairs[row.Instrument]['S'] = {};
                end
                
                instruments[row.Instrument] = true;
                table.insert(tradePairs[row.Instrument][row.BS], row)
            end
        end
        
        local profitLevel =  instance.parameters.ProfitLevel;         		
        for key,value in pairs(instruments) do 
            local buyTrades = tradePairs[key]['B'];
            local sellTrades = tradePairs[key]['S'];
            
            repeat
                local isProfitPairFound = false;           
                for indexBuy = 1, #buyTrades do         
                    for indexSell = 1, #sellTrades do
                        buyTrade = buyTrades[indexBuy];
                        sellTrade = sellTrades[indexSell];
                        if buyTrade.GrossPL + sellTrade.GrossPL >= profitLevel then
                      
                            isProfitPairFound = true;
                            --CLOSE Traders ---
                            if ShowAlert then
                                ExtSignal(source, period, "Close", SoundFile, Email, RecurrentSound);
                             end

                            if AllowTrade then
                                exit('B',buyTrade);
                                exit('S',sellTrade);
                            end                                                      
                            --------------
                            table.remove(buyTrades, indexBuy)
                            table.remove(sellTrades, indexSell)  
                            break
                        end
                    end
                    
                    if isProfitPairFound == true then
                        break;
                    end
                end
             until(isProfitPairFound == false)
        end
    end
end

function ExtAsyncOperationFinished(id, success, message)
end

local TRADE_CHECK = 10001
local requestId = nil

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

function setTimer() 
  -- Set check timer for FIFO accounts only
  if AllowTrade and not CanClose then 
    core.host:execute ("setTimer", TRADE_CHECK, 1)
  end
end   

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

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
