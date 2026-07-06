-- Id: 14959
--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

function Init() --The strategy profile initialization
    strategy:name("GrossPL close strategy");
    strategy:description("GrossPL close strategy");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");

    strategy.parameters:addGroup("Parameters");
    strategy.parameters:addDouble("Profit", "Profit level", "", 50);
    strategy.parameters:addDouble("Loss", "Loss level", "", -60);

    strategy.parameters:addGroup("Signal Parameters");
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
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

-- Trading parameters
local Account = nil;
local BaseSize = nil;
local PipSize;
local ProfitLevel, LossLevel;
local CanClose;

function Prepare(nameOnly)
    ShowAlert = instance.parameters.ShowAlert;
    ProfitLevel = instance.parameters.Profit;
    LossLevel = instance.parameters.Loss;
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

    local name;
    name = profile:id() .. "(" .. instance.bid:name() .. "," .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    Source = ExtSubscribe(2, nil, "t1", true, "bar");
    Account = instance.parameters.Account;
    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account);

    ExtSetupSignal(profile:id() .. ":", ShowAlert);
    ExtSetupSignalMail(name);
end

function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.
    if not instance.parameters.AllowTrade then
        return;
    end
    local trades = core.host:findTable("trades");
    local enum = trades:enumerator();
    local TotalPL=0;
    while true do
     local row = enum:next();
     if row == nil then break end
     TotalPL=TotalPL+row.GrossPL;
    end
    
    local TP, SL = false, false;
    
    if TotalPL>=ProfitLevel then
     TP=true;
    end
    if TotalPL<=LossLevel then
     SL=true;
    end
    
    if TP then
     ExtSignal(source, period, "Profit level achieved", SoundFile, Email, RecurrentSound);
     CloseAll();
     ---core.host:execute("stop");
     return ;
    end
    if SL then
     ExtSignal(source, period, "Loss level achieved", SoundFile, Email, RecurrentSound);
     CloseAll();
    -- core.host:execute("stop");
     return ;
    end
    
end

function CloseAll()
    local trades = core.host:findTable("trades");
    local enum = trades:enumerator();
    while true do
     local row = enum:next();
     if row == nil then break end
      local valuemap;
      valuemap = core.valuemap();

      if CanClose then
        -- non-FIFO account, create a close market order
        valuemap.OrderType = "CM";
        valuemap.TradeID = row.TradeID;
      else
        -- FIFO account, create an opposite market order
        valuemap.OrderType = "OM";
      end

      valuemap.OfferID = row.OfferID;
      valuemap.AcctID = row.AccountID;
      valuemap.Quantity = row.Lot;
      valuemap.CustomID = row.QTXT;
      if row.BS == "B" then valuemap.BuySell = "S"; else valuemap.BuySell = "B"; end
      success, msg = terminal:execute(200, valuemap);
      assert(success, msg);
     
    end
 
end

-- The strategy instance finalization.
function ReleaseInstance()
end

function AsyncOperationFinished(cookie, successful, message)
  if not successful then
    core.host:trace('Error: ' .. message)
  end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
