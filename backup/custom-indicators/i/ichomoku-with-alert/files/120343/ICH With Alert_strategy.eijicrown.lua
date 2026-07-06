-- Id: 21801
-- More information about this indicator can be found at:
-- http://fxcodebase.com/
-- Id:

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    strategy:name("ICH With Alert strategy example");
    strategy:description("");
           
    strategy.parameters:addString("TF", "Time frame", "", "m5");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);

    strategy.parameters:addString("Indicator", "Indicator", "", "ICH WITH ALERT.EIJICROWN");
    strategy.parameters:setFlag("Indicator",core.FLAG_INDICATOR);	

    strategy.parameters:addGroup("Price");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addGroup("Trading Parameters");
    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "ICH WITH ALERT.EIJICROWN.STRATEGY");

    strategy.parameters:addGroup("Strategy Parameters");    
    strategy.parameters:addInteger("Amount", "Amount", "", 1, 1, 100);       
end

local Account;
local BaseSize;
local CanClose;
local CustomID;
local Offer;
local Amount;
local IndiInstance = nil;
local Kijun_Sen = nil

function Prepare(nameOnly)
  
    local name;
    name = profile:id() .. "( " .. instance.bid:name();
	name = name .. ", " .. instance.parameters.TF .. ", " .. instance.parameters.Type
    name = name  ..  " )";
    instance:name(name);
 
    if nameOnly then
        return ;
    end

    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick");
	assert(core.indicators:findIndicator(instance.parameters.Indicator ) ~= nil, "Please, download and install ".. instance.parameters.Indicator ..".LUA indicator");          
    assert(TF ~= "t1", "The time frame must not be tick");

    PrepareTrading();	    
    Source = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar"); 

    local profile = core.indicators:findIndicator(instance.parameters.Indicator);
    local params = instance.parameters:getCustomParameters("Indicator");
    Kijun_Sen = params.Y;
    IndiInstance = profile:createInstance(Source, params);
end

function PrepareTrading()
    
    CustomID = instance.parameters.CustomID;
    Account = instance.parameters.Account;
    BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", instance.bid:instrument(), Account);
    CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", instance.bid:instrument(), Account)
     
    Offer = core.host:findTable("offers"):find("Instrument", instance.bid:instrument()).OfferID; 
    Amount = instance.parameters:getInteger("Amount"); 
end

local Period;
local outputStreamsCount
function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.
    if not instance.parameters.AllowTrade then
        return;
    end
    IndiInstance:update(core.UpdateAll);
    
    streamsCount = IndiInstance:getTextOutputCount(); 
    for i = 0, streamsCount - 1  do
        local textOutput = IndiInstance:getTextOutput(i);
        if string.find(textOutput:id(), "Up") ~= nil then
           if (textOutput:hasData(textOutput:size() - 1 - Kijun_Sen) == true) then
                CreateMarketOrder('B')
           end
        elseif string.find(textOutput:id(), "Dn") ~= nil  then
           if (textOutput:hasData(textOutput:size() - 1 - Kijun_Sen) == true) then
                CreateMarketOrder('S')
            end
        end       
    end
end

function ExtAsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 200 then
        if  not success then
            terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], " Open order failed " .. message, instance.bid:date(instance.bid:size() - 1));
        end
    end   
end


function CreateMarketOrder(side)
    local valuemap, success, msg;
    valuemap = core.valuemap();

    valuemap.Command = "CreateOrder";
    valuemap.OrderType = "OM";
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    valuemap.BuySell = side;
    valuemap.Quantity = Amount * BaseSize;
    valuemap.CustomID = CustomID;
    
    success, msg = terminal:execute(200, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], " Open order failed " .. msg, instance.bid:date(instance.bid:size() - 1));
        return false;
    end

    return msg;
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");