-- Id: 18892

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=65022

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

function Init() --The strategy profile initialization
    strategy:name("Zone Strategy");
    strategy:description("");
    -- NG: optimizer/backtester hint
    strategy:setTag("NonOptimizableParameters", "ShowAlert,PlaySound,SoundFile,RecurrentSound,SendMail,Email");

    strategy.parameters:addGroup("Price");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
    CreateTradingParameters();
end

function CreateTradingParameters()
    strategy.parameters:addGroup("Trading Parameters");

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false);   
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
	 
    strategy.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "ZT");
	
    strategy.parameters:addString("Direction", "Direction", "", "Buy");
    strategy.parameters:addStringAlternative("Direction", "Buy", "", "Buy");
    strategy.parameters:addStringAlternative("Direction", "Sell", "", "Sell");
    strategy.parameters:addDouble("zone_price", "Zone Price", "", 0);
    strategy.parameters:setFlag("zone_price", core.FLAG_PRICE);
    strategy.parameters:addDouble("entry_price", "Entry Price", "", 0);
    strategy.parameters:setFlag("entry_price", core.FLAG_PRICE);
    strategy.parameters:addDouble("invalidation_price", "Invalidation Price", "", 0);
    strategy.parameters:setFlag("invalidation_price", core.FLAG_PRICE);

    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000);
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false);
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false);
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false);
	
    strategy.parameters:addGroup("Alerts");
    strategy.parameters:addBoolean("ShowAlert", "ShowAlert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", true);
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", false);
    strategy.parameters:addString("Email", "Email", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local Source;
local SoundFile = nil;
local RecurrentSound = false;
local ALLOWEDSIDE;
local AllowMultiple;
local AllowTrade;
local Offer;
local CanClose;
local Account;
local Amount;
local SetLimit;
local Limit;
local SetStop;
local Stop;
local TrailingStop;
local ShowAlert;
local Email;
local SendEmail;
local BaseSize;
local Source;
local CustomID;
local zone_price;
local entry_price;
local invalidation_price;
local Direction;

function Prepare(nameOnly)
    CustomID = instance.parameters.CustomID; 
    zone_price = instance.parameters.zone_price;
    entry_price = instance.parameters.entry_price;
    Direction = instance.parameters.Direction;
    invalidation_price = instance.parameters.invalidation_price;

    local name = string.format("%s (%s, %s, %s, %s)", profile:id(), Direction, tostring(zone_price), tostring(entry_price), tostring(invalidation_price));
    instance:name(name);
 
    PrepareTrading();

    if nameOnly then
        return ;
    end

    Source = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "tick");
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
    Amount = instance.parameters.Amount;
    BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account);
    Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID;
    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account);
    SetLimit = instance.parameters.SetLimit;
    Limit = instance.parameters.Limit;
    SetStop = instance.parameters.SetStop;
    Stop = instance.parameters.Stop;
    TrailingStop = instance.parameters.TrailingStop;
end

local order_created = false;
local order_response_recieved = false;
local order_request_id;
function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.
    if order_created then
        if core.crosses(source, invalidation_price, period) then
            Signal("Deleting order");
            DeleteOrder();
            core.host:execute("stop");
        end
        if order_response_recieved and GetOrder() == nil then
            core.host:execute("stop");
        end
    else
        if core.crosses(source, zone_price, period) then
            CreateOrder();
        end
    end
end

function GetOrder()
    local enum = core.host:findTable("orders"):enumerator();
    local row = enum:next();
    while (row ~= nil) do
        if row.RequestID == order_request_id and (row.Type == "SE" or row.Type == "LE") then
            return row;
        end
        row = enum:next();
    end
    return nil;
end

function DeleteOrder()
    local order = GetOrder();
    if order == nil then
        return;
    end
    local valuemap = core.valuemap();
    valuemap.Command = "DeleteOrder";
    valuemap.OrderID = order.OrderID;
    success, message = terminal:execute(200, valuemap);
    if not(success) then
        Signal(instance.bid:instrument(), instance.bid[NOW], "Failed delete order " .. message, instance.bid:date(NOW));	                     		   
    end
end

function CreateOrder()
    Signal("The price has entered the zone");
    if not AllowTrade then
        return;
    end
    order_created = true;
    local valuemap = core.valuemap();
    valuemap.Command = "CreateOrder";
    if SetLimit then
        valuemap.PegTypeLimit = "M";
        if Direction == "Buy" then
            valuemap.PegPriceOffsetPipsLimit = Limit;
        else
            valuemap.PegPriceOffsetPipsLimit = -Limit;
        end
    end

    if SetStop then
        valuemap.PegTypeStop = "M";
        if Direction == "Buy" then
            valuemap.PegPriceOffsetPipsStop = -Stop;
        else
            valuemap.PegPriceOffsetPipsStop = Stop;
        end
        if TrailingStop then
            valuemap.TrailStepStop = 1;
        end
    end
    valuemap.Rate = entry_price;
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    valuemap.Quantity = Amount * BaseSize;
    if Direction == "Buy" then
        valuemap.BuySell = "B";
        if Source:tick(NOW) > entry_price then
            valuemap.OrderType = "LE";
        else
            valuemap.OrderType = "SE";
        end
    else
        valuemap.BuySell = "S";
        if Source:tick(NOW) > entry_price then
            valuemap.OrderType = "SE";
        else
            valuemap.OrderType = "LE";
        end
    end
    local success, msg = terminal:execute(100, valuemap);
    if not success then
        Signal("Order creation fail: " .. tostring(msg));
        core.host:execute("stop");
    else
        order_request_id = msg;
    end
end

-- NG: Introduce async function for timer/monitoring for the order results
function ExtAsyncOperationFinished(cookie, success, message)
    if cookie == 100 then
        if not success then
            Signal("Order creation fail: " .. tostring(message));
            core.host:execute("stop");
        end
        order_response_recieved = true;
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

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");


