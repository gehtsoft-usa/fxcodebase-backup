function Init()
    strategy:name("ZigZag strategy");
    strategy:description("ZigZag strategy");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");

    strategy.parameters:addGroup("First ZigZag");
    strategy.parameters:addBoolean("Use1", "Use", "", true);
    strategy.parameters:addInteger("Depth1", "Depth", "The minimum number of periods used to draw one ZigZag line.", 5, 1, 1000);
    strategy.parameters:addInteger("Deviation1", "Deviation", "The maximum distance in pips by which the current high/low must be lower/higher than the previous one to return Backstep periods back to check if the current high/low is a new max/min.", 1, 1, 1000);
    strategy.parameters:addInteger("Backstep1", "Backstep", "The number of periods used to define a new min/max if the current high/low is lower/higher than the previous one by Deviation or less.", 3, 1, 1000);
    strategy.parameters:addGroup("Second ZigZag");
    strategy.parameters:addBoolean("Use2", "Use", "", true);
    strategy.parameters:addInteger("Depth2", "Depth", "The minimum number of periods used to draw one ZigZag line.", 13, 1, 1000);
    strategy.parameters:addInteger("Deviation2", "Deviation", "The maximum distance in pips by which the current high/low must be lower/higher than the previous one to return Backstep periods back to check if the current high/low is a new max/min.", 8, 1, 1000);
    strategy.parameters:addInteger("Backstep2", "Backstep", "The number of periods used to define a new min/max if the current high/low is lower/higher than the previous one by Deviation or less.", 5, 1, 1000);
    strategy.parameters:addGroup("Third ZigZag");
    strategy.parameters:addBoolean("Use3", "use", "", true);
    strategy.parameters:addInteger("Depth3", "Depth", "The minimum number of periods used to draw one ZigZag line.", 34, 1, 1000);
    strategy.parameters:addInteger("Deviation3", "Deviation", "The maximum distance in pips by which the current high/low must be lower/higher than the previous one to return Backstep periods back to check if the current high/low is a new max/min.", 21, 1, 1000);
    strategy.parameters:addInteger("Backstep3", "Backstep", "The number of periods used to define a new min/max if the current high/low is lower/higher than the previous one by Deviation or less.", 12, 1, 1000   );
    
    strategy.parameters:addGroup("Price Parameters");
    strategy.parameters:addString("TF", "TF", "Time frame ('t1', 'm1', 'm5', etc.)", "m1");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addGroup("Trading Parameters");
      strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false);   
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 100);
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false);
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false);
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false);
    strategy.parameters:addString("AllowDirection", "Allow direction for positions", "", "Both");
    strategy.parameters:addStringAlternative("AllowDirection", "Both", "", "Both");
    strategy.parameters:addStringAlternative("AllowDirection", "Long", "", "Long");
    strategy.parameters:addStringAlternative("AllowDirection", "Short", "", "Short");

    strategy.parameters:addGroup("Notification");
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", false);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addBoolean("RecurSound", "Recurrent Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", false);
    strategy.parameters:addString("Email", "Email", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local source;
local ZZ1 = nil;
local ZZ2 = nil;
local ZZ3 = nil;
local Extent;

local Use1
local Use2
local Use3

function Prepare()
    source = instance.source;

    instance:name(profile:id() .. "(" .. instance.bid:instrument() .. ")");

    ShowAlert = instance.parameters.ShowAlert;
    AllowDirection = instance.parameters.AllowDirection;

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
	
	assert(core.indicators:findIndicator("ZZ_SEMAFOR") ~= nil, "Please, download and install ZZ_SEMAFOR.LUA indicator");    
    
    gSource = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar"); 

    Use1 = instance.parameters.Use1
    if Use1 then
        ZZ1 = core.indicators:create("ZZ_SEMAFOR", gSource, instance.parameters.Depth1, instance.parameters.Deviation1, instance.parameters.Backstep1);
    end
    
    Use2 = instance.parameters.Use2
    if Use2 then
        ZZ2 = core.indicators:create("ZZ_SEMAFOR", gSource, instance.parameters.Depth2, instance.parameters.Deviation2, instance.parameters.Backstep2);
    end
    
    Use3 = instance.parameters.Use3
    if Use3 then
        ZZ3 = core.indicators:create("ZZ_SEMAFOR", gSource, instance.parameters.Depth3, instance.parameters.Deviation3, instance.parameters.Backstep3);
    end

    assert(not(ZZ1 == nil and ZZ2 == nil and ZZ3 == nil), "At least one zigzag must be turned on");
    
    ExtSetupSignal(profile:id() .. ":", ShowAlert);
    ExtSetupSignalMail(name);
end

local prevSignal = nil

function ExtUpdate(id, source, period)
    if AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
            return ;
        end
    end
    
    if ZZ1 ~= nil then ZZ1:update(core.UpdateNew); end
    if ZZ2 ~= nil then ZZ2:update(core.UpdateNew); end
    if ZZ3 ~= nil then ZZ3:update(core.UpdateNew); end

    local up1, up2, up3 = nil, nil, nil
    local to;

    to = math.max(period - 100, 0);

    for i = period, to, -1 do
        if (ZZ1 ~= nil) then
            if (ZZ1.ZigZag[i] > 0 and  up1 == nil) then
                up1 = true
            elseif (ZZ1.ZigZag[i] < 0 and up1 == nil) then
                up1 = false
            end
        end
        if (ZZ2 ~= nil) then
            if (ZZ2.ZigZag[i] > 0 and  up2 == nil) then
                up2 = true 
            elseif (ZZ2.ZigZag[i] < 0 and up2 == nil) then
                up2 = false
            end
        end
        if (ZZ3 ~= nil) then
            if (ZZ3.ZigZag[i] > 0 and  up3 == nil) then
                up3 = true 
            elseif (ZZ3.ZigZag[i] < 0 and up3 == nil) then
                up3 = false
            end
        end
        
        if up1 ~= nil and up2 ~= nil and u3 ~= nil then
            break;
        end
    end
    
    local signal = ''
    if Use1 then signal = signal .. tostring(up1) end
    if Use2 then signal = signal .. tostring(up2) end
    if Use3 then signal = signal .. tostring(up3) end
    
    if signal ~= prevSignal then
        if (not Use1 or (Use1 and up1)) and 
           (not Use2 or (Use2 and up2)) and
           (not Use3 or (Use3 and up3)) then
            if AllowDirection~="Short" then
            exit('B')
            enter('S');

            
            if ShowAlert then
                ExtSignal(source, period, "SELL", SoundFile, Email, RecurrentSound);
            end
            end
        elseif (not Use1 or (Use1 and not up1)) and 
               (not Use2 or (Use2 and not up2)) and
               (not Use3 or (Use3 and not up3)) then
            if AllowDirection~="Long" then
            exit('S')
            enter('B');
            
            if  ShowAlert then
                ExtSignal(source, period, "BUY", SoundFile, Email, RecurrentSound);
            end
        end
        end        
    end

    prevSignal = signal
    
end

function checkReady(table)
    local rc;
    if Account == "TESTACC_ID" then
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
           row.OfferID == Offer and
           (row.BS == BuySell or BuySell == nil) then
           found = true;
        end
        row = enum:next();
    end

    return found
end

function enter(BuySell)
    if not(AllowTrade) then
        return true;
    end
    
    local valuemap, success, msg;

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

    if SetLimit then
        if BuySell == "B" then
            valuemap.RateLimit = instance.ask[NOW] + Limit;
        else
            valuemap.RateLimit = instance.bid[NOW] - Limit;
        end
    end

    if SetStop  then
        if BuySell == "B" then
            valuemap.RateStop = instance.ask[NOW] - Stop;
        else
            valuemap.RateStop = instance.bid[NOW] + Stop;
        end
        if TrailingStop then
            valuemap.TrailStepStop = 1;
        end
    end

    if (not CanClose) and (SetStop or SetLimit) then
        valuemap.EntryLimitStop = 'Y'
    end
    
    success, msg = terminal:execute(100, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed:" .. msg, instance.bid:date(instance.bid:size() - 1));
        return false;
    end
    
    return true;
end

function exit(BuySell)
    if not(AllowTrade) then
        return ;
    end

    local valuemap, success, msg;
    if haveTrades(BuySell) then
        valuemap = core.valuemap();

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

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
