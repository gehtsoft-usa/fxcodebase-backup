-- Id: 5659
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=4196

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

function Init() --The strategy profile initialization
    strategy:name("Advanced fractal strategy");
    strategy:description("Advanced fractal strategy");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");

    strategy.parameters:addGroup("Indicator parameters");
    strategy.parameters:addInteger("Frame", "Number of fractals (Odd)", "Number of fractals (Odd)", 5, 5,99);
    strategy.parameters:addInteger("Distance", "Min. distance for central bar", "Min. distance for central bar", 5);
    
    strategy.parameters:addGroup("Strategy Parameters");
    strategy.parameters:addString("TypeSignal", "Type of signal", "", "direct");
    strategy.parameters:addStringAlternative("TypeSignal", "direct", "", "direct");
    strategy.parameters:addStringAlternative("TypeSignal", "reverse", "", "reverse");
    strategy.parameters:addBoolean("AllowMultPos", "Allow multiple positions", "", false);

    strategy.parameters:addGroup("Price Parameters");
    strategy.parameters:addString("TF", "Time Frame", "", "m15");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);

	strategy.parameters:addGroup("MA Filter Calculation");
	strategy.parameters:addBoolean("MaFilter", "Use MA Filter", "", false);
	strategy.parameters:addInteger("FP1", "Average Period", "", 20);
	strategy.parameters:addString("Method1", "Method", "Method" , "MVA");
    strategy.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    strategy.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
	strategy.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    strategy.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    strategy.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    strategy.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    strategy.parameters:addStringAlternative("Method1", "HMA", "HMA" , "HMA");
    strategy.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");

    strategy.parameters:addGroup("Trading Parameters");
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false);
    -- NG: optimizer/backtester hint
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("ALLOWEDSIDE", "Allowed side", "Allowed side for trading or signaling, can be Sell, Buy or Both", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell");
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000);
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

-- Strategy parameters
local openLevel = 0
local closeLevel = 0
local confirmTrend;

-- Trading parameters
local AllowTrade = nil;
local ALLOWEDSIDE;
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
local Frame;
local Source;
local Distance;
local MA;
local MaFilter;
local first;
local TypeSignal;

--
--
--
function Prepare(nameOnly)
    ShowAlert = instance.parameters.ShowAlert;
    Frame = instance.parameters.Frame;
    Distance = instance.parameters.Distance;
    MaFilter = instance.parameters.MaFilter;
    TypeSignal = instance.parameters.TypeSignal;

    local PlaySound = instance.parameters.PlaySound
    if  PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
    assert(not(PlaySound) or SoundFile ~= "", "Sound file must be chosen");
    RecurrentSound = instance.parameters.Recurrent;
    ALLOWEDSIDE = instance.parameters.ALLOWEDSIDE;

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
           "Adv. fractal(" .. instance.parameters.Frame .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

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

    Source = ExtSubscribe(2, nil, instance.parameters.TF, true, "bar");

    assert(core.indicators:findIndicator(instance.parameters.Method1) ~= nil, instance.parameters.Method1 .. " indicator must be installed");
	MA = core.indicators:create(instance.parameters.Method1, Source.close, instance.parameters.FP1);
    first = MA.DATA:first();

    ExtSetupSignal(profile:id() .. ":", ShowAlert);
    ExtSetupSignalMail(name);
end

function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.

    -- Check that we have enough data
    if (Source:first() > period-math.floor((Frame-1)/2)) then
        return
    end

    if (MaFilter and period <= first) then
        return;
    end

    MA:update(core.UpdateLast);

    local pipSize = instance.bid:pipSize()

    local trades = core.host:findTable("trades");
    local haveTrades = (trades:find('AccountID', Account) ~= nil)
    
    local MustB=true;
    local MustS=true;
    local i;
    local Shift=math.floor((Frame-1)/2);
    for i=1,Shift,1 do
     if Source.low[period-i-Shift]<=Source.low[period-Shift]+Distance*pipSize or Source.low[period+i-Shift]<=Source.low[period-Shift]+Distance*pipSize then
       MustB=false;
     end
     if Source.high[period-i-Shift]>=Source.high[period-Shift]-Distance*pipSize or Source.high[period+i-Shift]>=Source.high[period-Shift]-Distance*pipSize then
       MustS=false;
     end
    end

    if MustB and MustS then
        MustB=false;
        MustS=false;
    end

    if (MaFilter) then
        -- check the MA Filter
        local currentMA = MA.DATA[period];
        local currentPrice = Source.close[period];

        if (MustB and currentMA <= currentPrice) then
            -- if we are buying, the current price must be higher than the current MA
            MustB = false;
        elseif (MustS and currentMA >= currentPrice) then
            MustS = false;
        end
    end

    if TypeSignal == "reverse" then
        -- reverse trading signals.
        if MustB then
            MustB = false;
            MustS = true;
        elseif MustS then
            MustB = true;
            MustS = false;
        end
    end 

    if (haveTrades and not instance.parameters.AllowMultPos) then
        local enum = trades:enumerator();
        while true do
            local row = enum:next();            
            if row == nil then break end

            if row.AccountID == Account and row.OfferID == Offer then
                -- Close position if we have corresponding closing conditions.
                if row.BS == 'B' then
                    if MustS then
                        if ShowAlert then
                            ExtSignal(source, period, "Close BUY and SELL", SoundFile, Email, RecurrentSound);
                        end

                        if AllowTrade then
                            Close(row);
                            SELL();
                        end
                    end
                elseif row.BS == 'S' then
                    if MustB then
                        if ShowAlert then
                            ExtSignal(source, period, "Close SELL and BUY", SoundFile, Email, RecurrentSound);
                        end

                        if AllowTrade then
                            Close(row);
                            BUY();
                        end
                    end
                end
            end
        end

    else

        if MustB then
            if ShowAlert then
                ExtSignal(source, period, "BUY", SoundFile, Email, RecurrentSound)
            end

            if AllowTrade then
                BUY();
            end
        end

        if MustS then
            if ShowAlert then
                ExtSignal(source, period, "SELL", SoundFile, Email, RecurrentSound)
            end

            if AllowTrade then
                SELL();
            end
        end
    end
end

function BUY()
    if (ALLOWEDSIDE == "Sell") then
        return;
    end

    Open("B")
end

function SELL()
    if (ALLOWEDSIDE == "Buy") then
        return;
    end

    Open("S");
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
    if trade.BS == "B" then 
        valuemap.BuySell = "S"; 
    else 
        valuemap.BuySell = "B"; 
    end
    success, msg = terminal:execute(200, valuemap);
    assert(success, msg);
end

function AsyncOperationFinished(cookie, successful, message)
  if not successful then
    core.host:trace('Error: ' .. message)
  end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");

