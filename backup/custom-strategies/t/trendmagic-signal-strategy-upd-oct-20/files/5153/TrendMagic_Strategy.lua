-- Id: 2005
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=2387

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


function Init()
    strategy:name("Trend Magic Strategy");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("The strategy trades using Trend Magic indicators");

    strategy.parameters:addGroup("Trend Magic Parameters");
    strategy.parameters:addInteger("CCI", "CCI", "", 50);
    strategy.parameters:addInteger("ATR", "ATR", "", 5);

    strategy.parameters:addGroup("Price Parameters");
    strategy.parameters:addString("TF", "Time Frame", "", "m15");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Trading Parameters");
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false);
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000);
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false);
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false);
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false);

    strategy.parameters:addGroup("Auto Lot");
    strategy.parameters:addBoolean("AutoLot", "Increase trade size after loss position", "", false);
    strategy.parameters:addInteger("IncStep", "Step to increase in lots", "", 1, 1, 100);
    strategy.parameters:addInteger("IncMax", "Maximum trade size in lots", "", 5, 1, 100);

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

local ShowAlert;
local SoundFile;
local Email;
local AllowTrade;
local Offer;
local CanClose;
local Account;
local Amount;
local BaseSize;
local SetLimit;
local Limit;
local SetStop;
local Stop;
local TrailingStop;
local RecurrentSound;
local AutoLot;
local IncStep;
local IncMax;
local tsource = nil;
local TM = nil;
local lastOpenRequest = nil;        -- the latest open request
local AutoLotCurr = 0;
local lastExitPL = 0;               -- profit loss on last exit call

function Prepare(onlyName)


  local name = profile:id() .. "(" ..  instance.bid:name()  .. ")";
    instance:name(name); 


     if   (nameOnly) then
        return;
    end

	
	
	

    RecurrentSound= instance.parameters.Recurrent;
    local SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "Email address must be specified");


    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick");
    assert(not(instance.parameters.PlaySound) or (instance.parameters.PlaySound and instance.parameters.SoundFile ~= ""), "Sound file must be chosen");
    assert(core.indicators:findIndicator("TRENDMAGIC1") ~= nil, "Please download and install Trend Magic 1 indicator!");



    ShowAlert = instance.parameters.ShowAlert;
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
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

        AutoLot = instance.parameters.AutoLot;
        IncStep = instance.parameters.IncStep;
        IncMax = instance.parameters.IncMax - Amount;
    end

   

    tsource = ExtSubscribe(2, nil, instance.parameters.TF, true, "bar");
    TM = core.indicators:create("TRENDMAGIC1", tsource, instance.parameters.CCI, instance.parameters.ATR, true);
end

function ExtUpdate(id, source, period)
    if id == 2 then
        TM:update(core.UpdateLast);
        -- check whether the signal appears
        if TM.SIG[period] == 1 and TM.SIG[period - 1] == -1 then
            -- switch to long
            if ShowAlert then
                terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Enter Long", instance.bid:date(NOW));
            end

            if SoundFile ~= nil then
                terminal:alertSound(SoundFile, RecurrentSound);
            end

            if Email ~= nil then
                terminal:alertEmail (Email, "Enter Long", "Trend Lord Strategy have give Enter Long signal")
            end

            exit("S");
            enter("B");
        elseif TM.SIG[period] == -1 and TM.SIG[period - 1] == 1 then
            -- switch to short
            if ShowAlert then
                terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Enter Short", instance.bid:date(NOW));
            end
            if SoundFile ~= nil then
                terminal:alertSound(SoundFile, RecurrentSound);
            end

            if Email ~= nil then
                terminal:alertEmail (Email, "Enter Short", "Trend Lord Strategy have give Enter Short signal")
            end

            exit("B");
            enter("S");
        end
    end
end

-- enter into the specified direction
function enter(BuySell)
    if not(AllowTrade) then
        return ;
    end

    local profitable = true;
    local enum, row, valuemap, success, msg;

    local count = 0;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while count == 0 and row ~= nil do
        if row.AccountID == Account and
           row.OfferID == Offer and
           row.BS == BuySell then
           count = count + 1;
        end
        row = enum:next();
    end

    -- do not enter if position in the
    -- specified direction already exists
    if count > 0 then
        return ;
    end


    -- check whether the previous trade was profitable (in case it closed
    -- earilier by stop or limit order
    -- the just closed trades are checked by exit procedure (see lastExitPL)
    if lastOpenRequest ~= nil then
        enum = core.host:findTable("closed trades"):enumerator();
        row = enum:next();
        profit = 0;
        while row ~= nil do
            if row.OpenOrderReqID == lastOpenRequest then
                profit = profit + row.PL;
            end
            row = enum:next();
        end
        profit = profit + lastExitPL;
        if profit < 0 then
            profitable = false;
        end
    end

    if AutoLot then
        if profitable then
            AutoLotCurr = 0;
        else
            AutoLotCurr = AutoLotCurr + IncStep;
            if AutoLotCurr > IncMax then
                AutoLotCurr = IncMax;
            end
        end
    else
        AutoLotCurr = 0;
    end
    lastExitPL = 0;

    valuemap = core.valuemap();

    valuemap.OrderType = "OM";
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    valuemap.Quantity = (Amount + AutoLotCurr) * BaseSize;
    valuemap.BuySell = BuySell;
    valuemap.PegTypeStop = "M";

    if SetLimit then
        -- set limit order
        if BuySell == "B" then
            valuemap.RateLimit = instance.ask[NOW] + Limit;
        else
            valuemap.RateLimit = instance.bid[NOW] - Limit;
        end
    end

    if SetStop then
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
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        lastOpenRequest = nil;
    else
        lastOpenRequest = msg;  -- keep latest open request id
    end
end

-- exit from the specified direction
function exit(BuySell)
    if not(AllowTrade) then
        return ;
    end

    local enum, row, valuemap, success, msg;

    lastExitPL = 0;
    -- check whether we have at least one trade on the specified account
    -- in the specified direction for the specified instrument
    local count = 0;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while count == 0 and row ~= nil do
        if row.AccountID == Account and
           row.OfferID == Offer and
           row.BS == BuySell then
           count = count + 1;
           lastExitPL = lastExitPL + row.PL;
        end
        row = enum:next();
    end

    if count > 0 then
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
        valuemap.TradeID = "all";
        valuemap.NetQtyFlag = "Y";
        valuemap.BuySell = BuySell;
        success, msg = terminal:execute(101, valuemap);

        if not(success) then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        end
    end
end


dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");



