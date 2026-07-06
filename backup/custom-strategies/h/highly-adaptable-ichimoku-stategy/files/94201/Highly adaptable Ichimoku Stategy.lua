-- Id: 11811
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/posting.php?mode=reply&f=31&t=31550

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
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
    strategy:name("Highly adaptable Ichimoku Stategy");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("");
	
	    strategy.parameters:addGroup("Price");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
	
	  strategy.parameters:addString("TF", "Time frame", "", "m5");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);
	
	strategy.parameters:addGroup("Calculation");
    strategy.parameters:addInteger("T", "Tenkan Period", "Tenkan Period", 9);
    strategy.parameters:addInteger("K", "Kijun Period", "Kijun Period", 26);
    strategy.parameters:addInteger("S", "Senkou Period", "Senkou Period", 52);
 

	strategy.parameters:addGroup("Selector");
	
	strategy.parameters:addString("Action".. 1, "TL / KL Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 1, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 1, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 1, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 1, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 1, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 2, "TL / KL Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 2, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 2, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 2, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 2, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 2, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 3, "CS / Price Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 3, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 3, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 3, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 3, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 3, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 4, "CS / Price Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 4, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 4, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 4, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 4, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 4, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 5, "Top Cloud / Price  Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 5, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 5, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 5, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 5, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 5, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 6, "Top Cloud / Price Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 6, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 6, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 6, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 6, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 6, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 7, "Bottom Cloud / Price  Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 7, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 7, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 7, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 7, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 7, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 8, "Bottom Cloud / Price Cross  Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 8, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 8, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 8, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 8, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 8, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 9, "CS / Top Cloud  Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 9, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 9, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 9, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 9, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 9, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 10, "CS / Top Cloud  Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 10, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 10, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 10, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 10, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 10, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 11, "CS / Bottom Cloud  Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 11, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 11, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 11, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 11, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 11, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 12, "CS / Bottom Cloud  Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 12, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 12, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 12, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 12, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 12, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 13, "SA / SB  Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 13, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 13, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 13, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 13, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 13, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 14, "SA / SB  Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 14, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 14, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 14, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 14, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 14, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 15, "Price / KL  Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 15, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 15, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 15, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 15, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 15, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 16, "Price / KL   Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 16, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 16, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 16, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 16, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 16, "Alert", "", "Alert");

	strategy.parameters:addString("Action".. 17, "CS / TL  Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 17, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 17, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 17, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 17, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 17, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 18, "CS / TL   Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 18, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 18, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 18, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 18, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 18, "Alert", "", "Alert");

	strategy.parameters:addString("Action".. 19, "CS / KL  Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 19, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 19, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 19, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 19, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 19, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 20, "CS / KL   Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 20, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 20, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 20, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 20, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 20, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 21, "TL / Price  Cross Over", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 21, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 21, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 21, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 21, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 21, "Alert", "", "Alert");
	
	strategy.parameters:addString("Action".. 22, "TL / Price   Cross Under", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 22, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. 22, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. 22, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. 22, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. 22, "Alert", "", "Alert");
	
	
    strategy.parameters:addGroup("Strategy Parameters");
    strategy.parameters:addString("Direction", "Type of signal", "", "direct");
    strategy.parameters:addStringAlternative("Direction", "direct", "", "direct");
    strategy.parameters:addStringAlternative("Direction", "reverse", "", "reverse");

    strategy.parameters:addGroup("Time Parameters");
    strategy.parameters:addString("StartTime", "Start Time for Trading", "", "00:00:00");
    strategy.parameters:addString("StopTime", "Stop Time for Trading", "", "24:00:00");

    strategy.parameters:addBoolean("UseMandatoryClosing", "Use Mandatory Closing", "", false);
    strategy.parameters:addString("ExitTime", "Mandatory Closing  Time", "", "23:59:00");
    strategy.parameters:addInteger("ValidInterval", "Valid interval for operation in second", "", 60);

    CreateTradingParameters();
   
end

function CreateTradingParameters()
    strategy.parameters:addGroup("Trading Parameters");

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false);
    -- NG: optimizer/backtester hint
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("ALLOWEDSIDE", "Allowed side", "Allowed side for trading or signaling, can be Sell, Buy or Both", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell");

    strategy.parameters:addBoolean("CloseOnOpposite", "Close On Opposite", "", true);
    strategy.parameters:addBoolean("AllowMultiple", "Allow Multiple", "", true);
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 100);
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
local CloseOnOpposite;

local Action={};
local Direction;
local first={};

local Tenkan;
local Kijun;
local Senkou;
local ICH;
local TL;
local KL;

local UseMandatoryClosing;
local ValidInterval;
local Number = 22;

-- Don't need to store hour + minute + second for each time
local OpenTime, CloseTime, ExitTime;
--
function Prepare( nameOnly)
    UseMandatoryClosing = instance.parameters.UseMandatoryClosing;   
    Direction = instance.parameters.Direction;    
	ValidInterval= instance.parameters.ValidInterval;

	Tenkan = instance.parameters.T;
    Kijun = instance.parameters.K;
    Senkou = instance.parameters.S;

    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick");

    local name = profile:id() .. "( " .. instance.bid:name() 
	local i;
	for i = 1, Number, 1 do 
        Action[i]= instance.parameters:getString ("Action" .. i);
	end
	
	name = name  ..  " )";
    instance:name(name);
		
    -- NG: parsing of the time is moved to separate function
    local valid;
    OpenTime, valid = ParseTime(instance.parameters.StartTime);
    assert(valid, "Time " .. instance.parameters.StartTime .. " is invalid");
    CloseTime, valid = ParseTime(instance.parameters.StopTime);
    assert(valid, "Time " .. instance.parameters.StopTime .. " is invalid");
    ExitTime, valid = ParseTime(instance.parameters.ExitTime);
    assert(valid, "Time " .. instance.parameters.ExitTime .. " is invalid");

    PrepareTrading();

    if nameOnly then
        return ;
    end
	
    Source = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar");
	
	ICH  = core.indicators:create("ICH", Source, Tenkan, Kijun, Senkou);
    TL = ICH.SL; -- adjust for the poor naming in the indicator
    KL = ICH.TL; -- adjust for the poor naming in the indicator
    
    first["TL"]=TL:first();
    first["KL"]=KL:first();
    first["SA"]=ICH.SA:first();
    first["CS"]=ICH.CS:first();
    first["SB"]=ICH.SB:first();
    first["PRICE"]=Source:first();

	if UseMandatoryClosing then
        core.host:execute("setTimer", 100, math.max(ValidInterval / 2, 1));
    end
   
end


function PrepareTrading()
    AllowMultiple =  instance.parameters.AllowMultiple;
	CloseOnOpposite = instance.parameters.CloseOnOpposite;
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
    if AllowTrade then
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
end


 -- NG: create a function to parse time
function ParseTime(time)
    local Pos = string.find(time, ":");
    if Pos == nil then
        return nil, false;
    end
    local h = tonumber(string.sub(time, 1, Pos - 1));
    time = string.sub(time, Pos + 1);
    Pos = string.find(time, ":");
    if Pos == nil then
        return nil, false;
    end
    local m = tonumber(string.sub(time, 1, Pos - 1));
    local s = tonumber(string.sub(time, Pos + 1));
    return (h / 24.0 +  m / 1440.0 + s / 86400.0),                          -- time in ole format
           ((h >= 0 and h < 24 and m >= 0 and m < 60 and s >= 0 and s < 60) or (h == 24 and m == 0 and s == 0)); -- validity flag
end


function InRange(now, openTime, closeTime)
    if openTime == closeTime then
        return true;
    end
    if openTime < closeTime then
        return now >= openTime and now <= closeTime;
    end
    if openTime > closeTime then
        return now > openTime or now < closeTime;
    end

    return now == openTime;
end




function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.
    if AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
            return ;
        end
    end

    if id ~= 1   then
        return;
    end

    local now = core.host:execute("getServerTime");
      if not InRange(now, OpenTime, CloseTime)
	  then            
      return ;
      end

        ICH:update(core.UpdateLast);

        if period > (math.max(first["TL"], first["KL"]) + 1) then   
            if core.crossesOver(TL, KL, period)then									
                ACTION(1,"TL / KL" ,"Over");								
            end
            if core.crossesUnder(TL, KL, period) then		
                ACTION(2,"TL / KL" ,"Under");	  
            end				
        end 

        if period > (math.max(first["CS"] + Kijun, first["PRICE"] + Kijun) + 1) then
            if core.crossesOver(ICH.CS, Source.close, period-Kijun, period-Kijun-1 ) then	
                ACTION(3,"CS / Price" ,"Over");	
            end	  
            if core.crossesUnder(ICH.CS, Source.close, period-Kijun, period-Kijun-1 )  then	
                ACTION(4,"CS / Price" ,"Under");	
            end	  
        end		

        if period > (math.max(first["SA"], first["SB"]) + 1) then	
            if math.max(ICH.SA[period], ICH.SB[period])< Source.close[period] and  math.max(ICH.SA[period-1], ICH.SB[period-1]) > Source.close[period-1]   then	
                ACTION(5,"Top Cloud / Price" , "Over");
            end									 
            if math.max(ICH.SA[period], ICH.SB[period]) >  Source.close[period] and  math.max(ICH.SA[period-1], ICH.SB[period-1]) < Source.close[period-1]  then	
                ACTION(6,"Top Cloud / Price" ,"Under");
            end				
            if math.min(ICH.SA[period], ICH.SB[period]) < Source.close[period] and  math.min(ICH.SA[period-1], ICH.SB[period-1]) > Source.close[period-1] then									
                ACTION(7,"Bottom Cloud / Price" ,"Over");	
            end									
            if math.min(ICH.SA[period], ICH.SB[period])> Source.close[period] and  math.min(ICH.SA[period-1], ICH.SB[period-1]) < Source.close[period-1] then		
                ACTION(8,"Bottom Cloud / Price" ,"Under");	
            end  			
        end


        if period > (math.max(first["CS"] + Kijun , first["SA"]) + 1) then
            if ICH.CS[period-Kijun-1] < math.max(ICH.SA[period-1-Kijun], ICH.SB[period-1-Kijun]) and ICH.CS[period-Kijun] > math.max(ICH.SA[period-Kijun], ICH.SB[period-Kijun]) then	
                ACTION(9,"CS / Top Cloud" ,"Over");	
            end	  
            if ICH.CS[period-Kijun-1] > math.max(ICH.SA[period-1-Kijun], ICH.SB[period-1-Kijun]) and ICH.CS[period-Kijun] < math.max(ICH.SA[period-Kijun], ICH.SB[period-Kijun]) then	
                ACTION(10,"CS / Top Cloud" ,"Under");	
            end	  
            if ICH.CS[period-Kijun-1] < math.min(ICH.SA[period-1-Kijun], ICH.SB[period-1-Kijun]) and ICH.CS[period-Kijun] > math.min(ICH.SA[period-Kijun], ICH.SB[period-Kijun])  then	
                ACTION(11,"CS / Bottom Cloud" ,"Over");	
            end	  
            if  ICH.CS[period-Kijun-1] > math.min(ICH.SA[period-1-Kijun], ICH.SB[period-1-Kijun]) and ICH.CS[period-Kijun] < math.min(ICH.SA[period-Kijun], ICH.SB[period-Kijun])   then	
                ACTION(12,"CS / Bottom Cloud" ,"Under");	
            end	  
        end		


        --Price / KL
        if period > (first["KL"] + 1) then
            if  core.crossesOver(Source.close, KL, period ) then
                ACTION(15,"Price / KL" ,"Over");
            end
            if  core.crossesUnder(Source.close, KL, period ) then
                ACTION(16,"Price / KL" ,"Under");
            end
        end


        if period > (first["SA"] + 1) then
            if  core.crossesOver(ICH.SA,ICH.SB, period + Kijun ) then
                ACTION(13,"SA / SB" ,"Over");
            end
            if  core.crossesUnder(ICH.SA,ICH.SB, period + Kijun ) then
                ACTION(14,"SA / SB" ,"Under");
            end
        end

        if (period - Kijun) > (math.max(first["CS"], first["TL"]) + 1) then
            local csPeriod = period - Kijun;
            if core.crossesOver(ICH.CS, TL, csPeriod) then
            -- if ICH.CS[csPeriod - 1] < TL[csPeriod - 1] and ICH.CS[csPeriod] > TL[csPeriod] then	
                ACTION(17,"CS / TL" ,"Over");	
            end
            if core.crossesUnder(ICH.CS, TL, csPeriod) then
            -- if ICH.CS[csPeriod - 1] > TL[csPeriod - 1] and ICH.CS[csPeriod] < TL[csPeriod] then	
                ACTION(18,"CS / TL" ,"Under");	
            end	  
        end

        if (period - Kijun) > (math.max(first["CS"], first["KL"]) + 1) then
            local csPeriod = period - Kijun;
            if core.crossesOver(ICH.CS, KL, csPeriod) then
            -- if ICH.CS[csPeriod - 1] < KL[csPeriod - 1] and ICH.CS[csPeriod] > KL[csPeriod] then	
                ACTION(19,"CS / KL" ,"Over");	
            end	  
            -- if ICH.CS[csPeriod - 1] > KL[csPeriod - 1] and ICH.CS[csPeriod] < KL[csPeriod] then	
            if core.crossesUnder(ICH.CS, KL, csPeriod) then
                ACTION(20,"CS / KL" ,"Under");	
            end	  
        end
		
		
		if period >  first["TL"] then
		  if core.crossesOver(TL, Source.close, period) then
		 ACTION(21,"CS / KL" ,"Over");
		 end
		  if core.crossesUnder(TL, Source.close, period) then
         ACTION(22,"CS / KL" ,"Under");	  
		 end
		end
    
    
end

-- NG: Introduce async function for timer/monitoring for the order results
function ExtAsyncOperationFinished(cookie, success, message)
    if cookie == 100 then
        -- timer
        if UseMandatoryClosing and AllowTrade then
            now = core.host:execute("getServerTime");
            -- get only time
            now = now - math.floor(now);
            -- check whether the time is in the exit time period
            if now >= ExitTime and now < ExitTime + ValidInterval then
                if not(checkReady("trades")) or not(checkReady("orders")) then
                    return ;
                end
                if haveTrades("S") then
                    exit("S");
                    Signal ("Close Short");
                end
                if haveTrades("B") then
                   exit("B");
                   Signal ("Close Long");
               end
            end
        end
    elseif cookie == 200 and not success then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. message, instance.bid:date(instance.bid:size() - 1));
    elseif cookie == 201 and not success then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Close order failed" .. message, instance.bid:date(instance.bid:size() - 1));
    end
end



function ACTION (Flag, Line, Label)
    if Action[Flag] ==  "NO" then
        return;	
							
    elseif Action[Flag] ==  "BUY" then		
        BUY();

    elseif Action[Flag] ==  "SELL" then				
        SELL();

    elseif Action[Flag] ==  "CLOSE" then
        if AllowTrade then
                
            if haveTrades('B') then
                exit('B');
                Signal ("Close Long");
            end							

            if haveTrades('S') then
                exit('S');
                Signal ("Close Short");
            end	
        else
            Signal ("Close All");									
        end	

    elseif Action[Flag] ==  "Alert" then 										
        Signal (Line .. " Line Cross" .. Label );				 		
    end
end


--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--

function BUY()
    if AllowTrade then
        if CloseOnOpposite and haveTrades('S') then
            exit('S');
            Signal ("Close Short");
        end	

        if haveTrades('B') and not AllowMultiple then
            return;
        end

        if ALLOWEDSIDE == "Sell"   then
            return;
        end 

        enter('B');
        Signal ("Open Long");

    elseif ShowAlert then
        Signal ("Up Trend");
    end

end   

function SELL ()		
    if AllowTrade then
        if CloseOnOpposite and haveTrades('B') then
            exit('B');
            Signal ("Close Long");
        end

        if haveTrades('S') and not AllowMultiple then
            return;
        end

        if ALLOWEDSIDE == "Buy"  then
            return;
        end

        enter('S');
        Signal ("Open Short");	
																			
    elseif ShowAlert then
        Signal ("Down Trend");	
    end				 

end

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

function tradesCount(BuySell) 
    local enum, row;
    local count = 0;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while count == 0 and row ~= nil do
        if row.AccountID == Account and
           row.OfferID == Offer and
           (row.BS == BuySell or BuySell == nil) then
           count = count + 1;
        end
        row = enum:next();
    end

    return count
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

-- enter into the specified direction
function enter(BuySell)
    if not(AllowTrade) then
        return true;
    end

    -- do not enter if position in the
    -- specified direction already exists
    if tradesCount(BuySell) > 0 and not  AllowMultiple  then
        return true;
    end

    local valuemap, success, msg;
    valuemap = core.valuemap();

    valuemap.OrderType = "OM";
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    valuemap.Quantity = Amount * BaseSize;
    valuemap.BuySell = BuySell;

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


    success, msg = terminal:execute(100, valuemap);

    if not(success) then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        return false;
    end

    return true;
end

-- exit from the specified direction
function exit(BuySell, use_net)
    if not (AllowTrade) then
        return true
    end

    if use_net == true then
        local valuemap, success, msg
        if tradesCount(BuySell) > 0 then
            valuemap = core.valuemap()

            -- switch the direction since the order must be in oppsite direction
            if BuySell == "B" then
                BuySell = "S"
            else
                BuySell = "B"
            end
            valuemap.OrderType = "CM"
            valuemap.OfferID = Offer
            valuemap.AcctID = Account
            valuemap.NetQtyFlag = "Y"
            valuemap.BuySell = BuySell
            success, msg = terminal:execute(101, valuemap)

            if not(success) then
               terminal:alertMessage(
                   instance.bid:instrument(),
                   instance.bid[instance.bid:size() - 1],
                   "Open order failed"..msg,
                   instance.bid:date(instance.bid:size() - 1)
               )
                return false
            end
            return true
        end
    else
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        while row ~= nil do
            if row.BS == BuySell and row.OfferID == Offer then
                local valuemap = core.valuemap();
                valuemap.BuySell = row.BS == "B" and "S" or "B";
                valuemap.OrderType = "CM";
                valuemap.OfferID = row.OfferID;
                valuemap.AcctID = row.AccountID;
                valuemap.TradeID = row.TradeID;
                valuemap.Quantity = row.Lot;
                local success, msg = terminal:execute(101, valuemap);
            end
        row = enum: next();
        end
    end
    return false
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
		
		
		
