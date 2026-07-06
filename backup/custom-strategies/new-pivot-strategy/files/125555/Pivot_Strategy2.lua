-- Id: 24582
-- More information about this indicator can be found at:
-- http://fxcodebase.com/

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    strategy:name("Pivot strategy 2"); 
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Pivot strategy 2");
    
    strategy.parameters:addString("TF", "Time frame", "Open position based on tick, candle close", "m1");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);
    strategy.parameters:addBoolean("Once_day", "Once per day", "", true);
    strategy.parameters:addBoolean("Once_side", "Once per side", "", true);
    strategy.parameters:addBoolean("Open_short", "Open short", "", true);
    strategy.parameters:addBoolean("Open_long", "Open long", "", true);
    strategy.parameters:addString("SignalType", "Type of signal", "", "Direct");
    strategy.parameters:addStringAlternative("SignalType", "Direct", "", "Direct");
    strategy.parameters:addStringAlternative("SignalType", "Reverse", "", "Reverse");

    strategy.parameters:addGroup("Trading");
    strategy.parameters:addString("Account", "Account", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addBoolean("CanTrade", "Allow Trading", "", false);
    strategy.parameters:setFlag("CanTrade", core.FLAG_ALLOW_TRADE);
    
    strategy.parameters:addGroup("Alerts");
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    strategy.parameters:addBoolean("SendEmail", "Send email", "", false);
    strategy.parameters:addString("Email", "Email address", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);

end

local BAR_TF_ID = 1;
local TICK_TF_ID = 2;

local source;
local TickSource;
local pivot;
local Account;
local OfferId;
local MinQuantity;
local LastBuySerial;
local LastSellSerial;
local OpenShort;
local OpenLong;
local OnceDay;
local OnceSide;
local Functions = { };
local ReverseDecitions;
local Email;
local SoundFile;
local CanTrade;
function Prepare()
    instance:name(profile:id());
    Account = instance.parameters.Account;
    OpenShort = instance.parameters.Open_short;
    OpenLong = instance.parameters.Open_long;
    OnceDay = instance.parameters.Once_day;
    OnceSide = instance.parameters.Once_side;
    ReverseDecitions = instance.parameters.SignalType == "Reverse";
    
    if ReverseDecitions then
        Functions.isNeedToBuy = needSell;
        Functions.isNeedToSell = needBuy;
    else
        Functions.isNeedToBuy = needBuy;
        Functions.isNeedToSell = needSell;
    end
    
    local SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "Email address must be specified");
    local ShowAlert = instance.parameters.ShowAlert;
    local PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");
    CanTrade = instance.parameters.CanTrade;
    ExtSetupSignal(profile:id(), ShowAlert);
    ExtSetupSignalMail(profile:id());
    
    OfferId = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;
    MinQuantity = core.host:execute("getTradingProperty", "minQuantity", instance.bid:instrument(), Account);

    local time_frame = instance.parameters.TF;
    if time_frame == "t1" then
        TickSource = ExtSubscribe(TICK_TF_ID, nil, time_frame, true, "tick");
        time_frame = "m1";
    end
    source = ExtSubscribe(BAR_TF_ID, nil, time_frame, true, "bar");
    pivot = core.indicators:create("PIVOT", source, "D1", "Pivot", "HIST");
end

function needBuy()
    if core.crossesUnder(source.close, pivot.S1, NOW)
       or core.crossesUnder(source.close, pivot.S2, NOW) 
       or core.crossesUnder(source.close, pivot.S3, NOW) 
       or core.crossesUnder(source.close, pivot.S4, NOW)
       or core.crossesUnder(source.close, pivot.P, NOW) then
        return true;
    end
    return false;
end

function needSell()
    if core.crossesOver(source.close, pivot.R1, NOW)
       or core.crossesOver(source.close, pivot.R2, NOW) 
       or core.crossesOver(source.close, pivot.R3, NOW) 
       or core.crossesOver(source.close, pivot.R4, NOW)
       or core.crossesOver(source.close, pivot.P, NOW) then
        return true;
    end
    return false;
end

function ExtUpdate(id, source, period)
    if TickSource ~= nil and id ~= TICK_TF_ID then
        return;
    end
    
    pivot:update(core.UpdateLast);
    if pivot.P:size() - pivot.P:first() < 2 then
        return;
    end
    local currentSerial, e = core.getcandle("D1", source:date(NOW), 0, 0);
    if OnceDay and (currentSerial == LastBuySerial or currentSerial == LastSellSerial) then
        return;
    end
    if OpenLong and Functions.isNeedToBuy() then
        if OnceSide and currentSerial == LastBuySerial then
            return;
        end
        if CanTrade then
            exit("S");
            enter("B");
        end
        ExtSignal(instance.ask, instance.ask:size() - 1, "BUY", SoundFile, Email);
        LastBuySerial = currentSerial;
    elseif OpenShort and Functions.isNeedToSell() then
        if OnceSide and currentSerial == LastSellSerial then
            return;
        end
        if CanTrade then
            exit("B");
            enter("S");
        end
        ExtSignal(instance.ask, instance.ask:size() - 1, "Sell", SoundFile, Email);
        LastSellSerial = currentSerial;
    end
end

function enter(BuySell)
    local valuemap, success, msg;
    valuemap = core.valuemap();

    valuemap.OrderType = "OM";
    valuemap.OfferID = OfferId;
    valuemap.AcctID = Account;
    valuemap.Quantity = MinQuantity;
    valuemap.BuySell = BuySell;
    valuemap.PegTypeStop = "M";

    success, msg = terminal:execute(1000, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), source.close[NOW], "Open order failed" .. msg, source:date(NOW));
    end
end

function exit(BuySell)
    local enum, row, valuemap, success, msg;

    local count = 0;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while count == 0 and row ~= nil do
        if row.AccountID == Account and
           row.OfferID == OfferId and
           row.BS == BuySell then
           count = count + 1;
        end
        row = enum:next();
    end

    if count > 0 then
        valuemap = core.valuemap();

        if BuySell == "B" then
            BuySell = "S";
        else
            BuySell = "B";
        end
        valuemap.OrderType = "CM";
        valuemap.OfferID = OfferId;
        valuemap.AcctID = Account;
        valuemap.NetQtyFlag = "Y";
        valuemap.BuySell = BuySell;
        success, msg = terminal:execute(101, valuemap);

        if not(success) then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Close order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");