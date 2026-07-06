-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=31&t=72587

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+



function Init() --The strategy profile initialization
    strategy:name("Multiple instruments Price MA Cross Strategy");
    strategy:description("");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");
	
	strategy.parameters:addGroup("Price");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
	
	
	strategy.parameters:addString("Instrument1" , "1. Instrument (Trade on) ", "", "CAD/CHF");
    strategy.parameters:setFlag("Instrument1"  , core.FLAG_INSTRUMENTS);

 	strategy.parameters:addString("Instrument2" , "2. Instrument", "", "USD/CAD");
    strategy.parameters:setFlag("Instrument2"  , core.FLAG_INSTRUMENTS);
	
	strategy.parameters:addString("Instrument3" , "3. Instrument", "", "CAD/CHF");
    strategy.parameters:setFlag("Instrument3"  , core.FLAG_INSTRUMENTS);	
	
	strategy.parameters:addString("TF", "Time frame", "", "H1");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);

	 
 	strategy.parameters:addGroup("Calculation");   
	
	strategy.parameters:addInteger("Period", "MA Period", "", 14, 1, 2000);
	strategy.parameters:addString("Method", "MA Method", "Method" , "MVA");
    strategy.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    strategy.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    strategy.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    strategy.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    strategy.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    strategy.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    strategy.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    strategy.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
    strategy.parameters:addBoolean("CrossOnly", "1. Instrument Cross Only", "", true);  
	
	
	
    CreateTradingParameters();
end

function CreateTradingParameters()
    strategy.parameters:addGroup("Trading Parameters");

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false);   
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
	

 
    strategy.parameters:addInteger("Amount", "Trade Amount (in Lots)", "", 1, 1, 20000);	
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false);	
	strategy.parameters:addDouble("Limit", "Limit (in Pips)", "", 30, 1, 20000);	
    strategy.parameters:addBoolean("SetStop", "Set Stop", "", false); 	
	strategy.parameters:addDouble("Stop", "Stop (in Pips)", "", 30, 1, 20000);	
    strategy.parameters:addBoolean("TrailingStop", "Use Trailing Stop", "", false); 		
 
	strategy.parameters:addBoolean("CloseOnOpposite", "Close On Opposite", "", true);
    strategy.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "MIPMCS");
	
	
	strategy.parameters:addBoolean("PositionCap", "Use Position Cap", "", true);	
	
	strategy.parameters:addInteger("MaxNumberOfPositionInAnyDirection", "Max Number Of Open Position In Any Direction", "", 2, 1, 100);
	strategy.parameters:addInteger("MaxNumberOfPosition", "Max Number Of Position In One Direction", "", 1, 1, 100);
    	
    strategy.parameters:addString("ALLOWEDSIDE", "Allowed side", "Allowed side for trading or signaling, can be Sell, Buy or Both", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell");
	

    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT); 
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

local Source,TickSource;
local MaxNumberOfPositionInAnyDirection, MaxNumberOfPosition;
local SoundFile = nil;
local RecurrentSound = false;
local ALLOWEDSIDE;
local AllowTrade;
 
local ShowAlert;
local Email;
local SendEmail;
local BaseSize;
local CloseOnOpposite
local first;
local CustomID;

 
--
function Prepare( nameOnly)
    CustomID = instance.parameters.CustomID;
	MaxNumberOfPositionInAnyDirection = instance.parameters.MaxNumberOfPositionInAnyDirection;
	MaxNumberOfPosition = instance.parameters.MaxNumberOfPosition;
	
	TheAmount = instance.parameters.Amount;
	TheSetLimit= instance.parameters.SetLimit;	
	TheLimit = instance.parameters.Limit; 
	TheSetStop = instance.parameters.SetStop;
	TheStop = instance.parameters.Stop; 
	TheTrailingStop = instance.parameters.TrailingStop;	
	PositionCap = instance.parameters.PositionCap;
	CloseOnOpposite = instance.parameters.CloseOnOpposite;
 
	Instrument1 = instance.parameters.Instrument1;
	Instrument2 = instance.parameters.Instrument2;
	Instrument3 = instance.parameters.Instrument3;
	
	Period=instance.parameters.Period;
	Method=instance.parameters.Method;
	
	CrossOnly = instance.parameters.CrossOnly;

    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick");

    local name;
    name = profile:id() ..  "," .. CustomID ..  "";
    instance:name(name);
   
    PrepareTrading();

    if nameOnly then
        return ;
    end
	
	
	Source1 = ExtSubscribe(1, Instrument1, instance.parameters.TF, instance.parameters.Type == "Bid", "bar");
	Source2 = ExtSubscribe(2, Instrument2, instance.parameters.TF, instance.parameters.Type == "Bid", "bar");
	Source3 = ExtSubscribe(3, Instrument3, instance.parameters.TF, instance.parameters.Type == "Bid", "bar");	
	
    Indicator1 = core.indicators:create(Method, Source1.close, Period );	
    Indicator2 = core.indicators:create(Method, Source2.close, Period );	
    Indicator3 = core.indicators:create(Method, Source3.close, Period );		
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
	
end
 


local LastTrade;

function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.
    if AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
            return ;
        end
    end
	
	
    Indicator1:update(core.UpdateLast);
    Indicator2:update(core.UpdateLast);
    Indicator3:update(core.UpdateLast); 
	
	
    if id ~=1 then
	return;
	end
	 
	if  LastTrade == Source1:serial(period) 
	then
	return;
	end	   

 	period1= period;
 	period2= core.findDate (Source2, Source1:date(period), false);
 	period3= core.findDate (Source3, Source1:date(period), false);


 	            if Source1.close[period1]> Indicator1.DATA[period1]
				and ((Source1.close[period1-1]<= Indicator1.DATA[period1-1] and  CrossOnly) or not CrossOnly)
 	            and Source2.close[period2]> Indicator2.DATA[period2]				
 	            and Source3.close[period3]> Indicator3.DATA[period3]					
				then
                BUY(Instrument1 , TheAmount    ,TheSetLimit    , TheLimit     , TheSetStop     ,TheStop   , TheTrailingStop );  
				LastTrade = Source1:serial(period1)
 				elseif Source1.close[period1]< Indicator1.DATA[period1]
                and ((Source1.close[period1-1]>= Indicator1.DATA[period1-1] and  CrossOnly) or not CrossOnly)				
 	            and Source2.close[period2]< Indicator2.DATA[period2]				
 	            and Source3.close[period3]< Indicator3.DATA[period3]
				then		
                SELL(Instrument1, TheAmount    ,TheSetLimit   , TheLimit     , TheSetStop     ,TheStop   , TheTrailingStop );
                LastTrade = Source1:serial(period1)
				end     
		 
 
    

end

-- NG: Introduce async function for timer/monitoring for the order results
function ExtAsyncOperationFinished(cookie, success, message)

     if cookie == 200 and not success then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. message, instance.bid:date(instance.bid:size() - 1));
    elseif cookie == 201 and not success then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Close order failed" .. message, instance.bid:date(instance.bid:size() - 1));
    end
end

--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--
function BUY( Instrument, Amount, SetLimit,  Limit  ,  SetStop  , Stop ,  TrailingStop)
    if AllowTrade then
        if CloseOnOpposite and haveTrades("S", Instrument) then
            -- close on opposite signal
            exitSpecific("S",  Instrument);
            Signal ("Close Short","Close Short :" ..  Instrument );
        end

        if ALLOWEDSIDE == "Sell"  then
            -- we are not allowed buys.
            return;
        end 

        enter("B", Instrument, Amount,  SetLimit, Limit  ,  SetStop  , Stop ,  TrailingStop);
    else
        Signal ("Buy Signal", "Buy Signal :" .. Instrument );	
    end
end   
    
function SELL( Instrument, Amount, SetLimit,  Limit  ,  SetStop  , Stop ,  TrailingStop)
    if AllowTrade then
        if CloseOnOpposite and haveTrades("B", Instrument) then
            -- close on opposite signal
            exitSpecific("B", Instrument);
            Signal ("Close Long", "Close Long :" ..  Instrument );
        end

        if ALLOWEDSIDE == "Buy"  then
            -- we are not allowed sells.
            return;
        end

        enter("S", Instrument, Amount,  SetLimit, Limit  ,  SetStop  , Stop ,  TrailingStop);
    else
        Signal ("Sell Signal", "Sell Signal :" .. Instrument );	
    end
end

function Signal (Subject, Text )
    if ShowAlert then
        terminal:alertMessage(Subject, Source1.close[ Source1.close:size()-1],  Text, instance.bid:date(NOW));
    end

    if SoundFile ~= nil then
        terminal:alertSound(SoundFile, RecurrentSound);
    end

    if Email ~= nil then
        terminal:alertEmail(Email, Subject, Text);
    end
end								

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

function tradesCount(BuySell,Instrument) 
    local enum, row;
    local count = 0;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while row ~= nil do
        if row.AccountID == Account 
		and row.Instrument == Instrument
		and row.QTXT == CustomID 
		and (row.BS == BuySell
		or BuySell == nil) then
            count = count + 1;
        end

        row = enum:next();
    end

    return count;
end

function haveTrades(BuySell,Instrument) 
    local enum, row;
    local found = false;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while (row ~= nil) do
        if row.AccountID == Account 
		and row.Instrument == Instrument
		and row.QTXT == CustomID
		and (row.BS == BuySell or BuySell == nil)
		then
            found = true;
            break;
        end

        row = enum:next();
    end

    return found;
end

-- enter into the specified direction
function enter(BuySell,Instrument,Amount, SetLimit, Limit  , SetStop  ,Stop , TrailingStop)
    -- do not enter if position in the specified direction already exists
    if (tradesCount(BuySell,Instrument) >= MaxNumberOfPosition
	or   tradesCount(nil,Instrument)  >= MaxNumberOfPositionInAnyDirection)
    and PositionCap	
	then
        return true;
    end

    -- send the alert after the checks to see if we can trade.
    if (BuySell == "S") then
        Signal ("Sell Signal","Sell Signal" );	
    else
        Signal ("Buy Signal","Buy Signal"  );	
    end
	
	
    return MarketOrder(BuySell,Instrument,Amount, Limit  , SetStop  ,Stop , TrailingStop );
end


-- enter into the specified direction
function MarketOrder(BuySell,Instrument,Amount, Limit  , SetStop  ,Stop , TrailingStop)

    local Offer = core.host:findTable("offers"):find("Instrument", Instrument).OfferID;
	
	if Offer== nil then
	return;
	end
	
    local BaseSize = core.host:execute("getTradingProperty", "baseUnitSize", Instrument, Account);
	local CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", Instrument, Account);
    local valuemap, success, msg;
    valuemap = core.valuemap();
    valuemap.Command = "CreateOrder";
    valuemap.OrderType = "OM";
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    valuemap.Quantity = Amount * BaseSize;
    valuemap.BuySell = BuySell;
    valuemap.CustomID = CustomID;

    -- add stop/limit
    valuemap.PegTypeStop = "O";
    if SetStop then 
        if BuySell == "B" then
            valuemap.PegPriceOffsetPipsStop = -Stop;
        else
            valuemap.PegPriceOffsetPipsStop = Stop;
        end
    end
    if TrailingStop then
        valuemap.TrailStepStop = 1;
    end

    valuemap.PegTypeLimit = "O";
    if SetLimit then
        if BuySell == "B" then
            valuemap.PegPriceOffsetPipsLimit = Limit;
        else
            valuemap.PegPriceOffsetPipsLimit = -Limit;
        end
    end

    if (not CanClose) then
        valuemap.EntryLimitStop = 'Y'
    end

    success, msg = terminal:execute(200, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        return false;
    end

    return true;
end

-- exit from the specified trade using the direction as a key
function exitSpecific(BuySell,  Instrument)
    -- we have to loop through to exit all trades in each direction instead
    -- of using the net qty flag because we may be running multiple strategies on the same account.
    local enum, row;
    local found = false;
	local Offer = core.host:findTable("offers"):find("Instrument", Instrument).OfferID;
	local CanClose = core.host:execute("getTradingProperty", "canCreateMarketClose", Instrument, Account);
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while (not found) and (row ~= nil) do
        -- for every trade for this instance.
        if row.AccountID == Account
		and row.Instrument == Instrument
		and row.QTXT == CustomID 
		and (row.BS == BuySell 
		or BuySell == nil) then
           exitTrade(row,Offer,CanClose);
        end

        row = enum:next();
    end
end

-- exit from the specified direction
function exitTrade(tradeRow, Offer,CanClose)
    if not(AllowTrade) then
        return true;
    end

    local valuemap, success, msg;
    valuemap = core.valuemap();

    -- switch the direction since the order must be in oppsite direction
    if tradeRow.BS == "B" then
        BuySell = "S";
    else
        BuySell = "B";
    end
    valuemap.OrderType = "CM";
	
	
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    if (CanClose) then
        -- Non-FIFO can close each trade independantly.
        valuemap.TradeID = tradeRow.TradeID;
        valuemap.Quantity = tradeRow.Lot;
    else
        -- FIFO.
        valuemap.NetQtyFlag = "Y"; -- this forces all trades to close in the opposite direction.
    end
    valuemap.BuySell = BuySell;
    valuemap.CustomID = CustomID;
    success, msg = terminal:execute(201, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Close order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        return false;
    end

    return true;
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");

