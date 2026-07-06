-- Id: 20596
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=61770

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
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init() --The strategy profile initialization
    strategy:name("Genesis System Strategy");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("");
    
    strategy.parameters:addGroup("Price");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
    
    strategy.parameters:addString("TF", "Time frame", "", "H1");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);
    
    strategy.parameters:addGroup("CCI Calculation"); 
    strategy.parameters:addInteger("CCI_Period", "CCI Period", " ", 45);
    strategy.parameters:addString("CCI_Type", "CCI Period", " ", "CCI Trigger Level");
    strategy.parameters:addStringAlternative("CCI_Type", "CCI Trigger Level", "", "CCI Trigger Level");
    strategy.parameters:addStringAlternative("CCI_Type", "CCI MA", "", "CCI MA");    
    strategy.parameters:addInteger("CCI_Trigger_Level",  "CCI Trigger Level", "", 0);
    
    strategy.parameters:addInteger("CCI_MA_Period", "MA Period", "Period" , 14);
    strategy.parameters:addString("CCI_Method", "MA Method", "Method" , "MVA");
    strategy.parameters:addStringAlternative("CCI_Method", "MVA", "MVA" , "MVA");
    strategy.parameters:addStringAlternative("CCI_Method", "EMA", "EMA" , "EMA");
    strategy.parameters:addStringAlternative("CCI_Method", "LWMA", "LWMA" , "LWMA");
    strategy.parameters:addStringAlternative("CCI_Method", "TMA", "TMA" , "TMA");
    strategy.parameters:addStringAlternative("CCI_Method", "SMMA", "SMMA" , "SMMA");
    strategy.parameters:addStringAlternative("CCI_Method", "KAMA", "KAMA" , "KAMA");
    strategy.parameters:addStringAlternative("CCI_Method", "VIDYA", "VIDYA" , "VIDYA");
    strategy.parameters:addStringAlternative("CCI_Method", "WMA", "WMA" , "WMA");    
    
    strategy.parameters:addGroup("GannHiLo Calculation");
    strategy.parameters:addInteger("Period", "Period", "Period", 10);
    strategy.parameters:addString("Method", "MA Method", "Method" , "MVA");
    strategy.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    strategy.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    strategy.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    strategy.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    strategy.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    strategy.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    strategy.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    strategy.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
    
    strategy.parameters:addGroup("TVI Calculation"); 
    strategy.parameters:addInteger("r", "First Smoothing", "r", 12);
    strategy.parameters:addInteger("s",  "Second Smoothing", "s", 12);
    
    strategy.parameters:addGroup("T3 Calculation"); 
    strategy.parameters:addInteger("a", "Period", "", 8, 1 , 2000);
    strategy.parameters:addDouble("b", "b", "", 0.618);

    strategy.parameters:addGroup("HTF Price");
    strategy.parameters:addBoolean("confirm_with_htf", "Confirm with HTF", "", true);
    strategy.parameters:addString("BTF_TF", "Higher Time frame", "", "H1");
    strategy.parameters:setFlag("BTF_TF", core.FLAG_PERIODS);
    
    strategy.parameters:addGroup("HTF CCI Calculation"); 
    strategy.parameters:addInteger("BTF_CCI_Period", "CCI Period", " ", 45);
    strategy.parameters:addString("BTF_CCI_Type", "CCI Period", " ", "CCI Trigger Level");
    strategy.parameters:addStringAlternative("BTF_CCI_Type", "CCI Trigger Level", "", "CCI Trigger Level");
    strategy.parameters:addStringAlternative("BTF_CCI_Type", "CCI MA", "", "CCI MA");    
    strategy.parameters:addInteger("BTF_CCI_Trigger_Level",  "CCI Trigger Level", "", 0);
    
    strategy.parameters:addInteger("BTF_CCI_MA_Period", "MA Period", "Period" , 14);
    strategy.parameters:addString("BTF_CCI_Method", "MA Method", "Method" , "MVA");
    strategy.parameters:addStringAlternative("BTF_CCI_Method", "MVA", "MVA" , "MVA");
    strategy.parameters:addStringAlternative("BTF_CCI_Method", "EMA", "EMA" , "EMA");
    strategy.parameters:addStringAlternative("BTF_CCI_Method", "LWMA", "LWMA" , "LWMA");
    strategy.parameters:addStringAlternative("BTF_CCI_Method", "TMA", "TMA" , "TMA");
    strategy.parameters:addStringAlternative("BTF_CCI_Method", "SMMA", "SMMA" , "SMMA");
    strategy.parameters:addStringAlternative("BTF_CCI_Method", "KAMA", "KAMA" , "KAMA");
    strategy.parameters:addStringAlternative("BTF_CCI_Method", "VIDYA", "VIDYA" , "VIDYA");
    strategy.parameters:addStringAlternative("BTF_CCI_Method", "WMA", "WMA" , "WMA");    
    
    strategy.parameters:addGroup("HTF GannHiLo Calculation");
    strategy.parameters:addInteger("BTF_Period", "Period", "Period", 10);
    strategy.parameters:addString("BTF_Method", "MA Method", "Method" , "MVA");
    strategy.parameters:addStringAlternative("BTF_Method", "MVA", "MVA" , "MVA");
    strategy.parameters:addStringAlternative("BTF_Method", "EMA", "EMA" , "EMA");
    strategy.parameters:addStringAlternative("BTF_Method", "LWMA", "LWMA" , "LWMA");
    strategy.parameters:addStringAlternative("BTF_Method", "TMA", "TMA" , "TMA");
    strategy.parameters:addStringAlternative("BTF_Method", "SMMA", "SMMA" , "SMMA");
    strategy.parameters:addStringAlternative("BTF_Method", "KAMA", "KAMA" , "KAMA");
    strategy.parameters:addStringAlternative("BTF_Method", "VIDYA", "VIDYA" , "VIDYA");
    strategy.parameters:addStringAlternative("BTF_Method", "WMA", "WMA" , "WMA");
    
    strategy.parameters:addGroup("HTF TVI Calculation"); 
    strategy.parameters:addInteger("BTF_r", "First Smoothing", "r", 12);
    strategy.parameters:addInteger("BTF_s",  "Second Smoothing", "s", 12);
    
    strategy.parameters:addGroup("HTF T3 Calculation"); 
    strategy.parameters:addInteger("BTF_a", "Period", "", 8, 1 , 2000);
    strategy.parameters:addDouble("BTF_b", "b", "", 0.618);

    CreateTradingParameters();
end

function CreateTradingParameters()
    strategy.parameters:addGroup("Trading Parameters");

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", true);   
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    
 
    strategy.parameters:addString("ExecutionType", "End of Turn / Live", "", "End of Turn");
    strategy.parameters:addStringAlternative("ExecutionType", "End of Turn", "", "End of Turn");
    strategy.parameters:addStringAlternative("ExecutionType", "Live", "", "Live");
    
    strategy.parameters:addBoolean("CloseOnOpposite", "Close On Opposite", "", true);
    strategy.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "ETLS");
    
    strategy.parameters:addInteger("MaxNumberOfPositionInAnyDirection", "Max Number Of Open Position In Any Direction", "", 10, 1, 100);
    strategy.parameters:addInteger("MaxNumberOfPosition", "Max Number Of Position In One Direction", "", 5, 1, 100);
        
    strategy.parameters:addString("ALLOWEDSIDE", "Allowed side", "Allowed side for trading or signaling, can be Sell, Buy or Both", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell");
    
    strategy.parameters:addString("Direction", "Type of Signal / Trade", "", "direct");
    strategy.parameters:addStringAlternative("Direction", "Direct", "", "direct");
    strategy.parameters:addStringAlternative("Direction", "Reverse", "", "reverse");

    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000);
    strategy.parameters:addBoolean("SetLimit", "Set Limit Orders", "", false);
    strategy.parameters:addInteger("Limit", "Limit Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false);
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false);
    strategy.parameters:addBoolean("Exit", "Use Optional Exit", "", true);
    
    strategy.parameters:addGroup("Alerts");
    strategy.parameters:addBoolean("ShowAlert", "ShowAlert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    strategy.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", true);
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", false);
    strategy.parameters:addString("Email", "Email", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
    
     strategy.parameters:addGroup("Time Parameters");
    strategy.parameters:addString("StartTime", "Start Time for Trading", "", "00:00:00");
    strategy.parameters:addString("StopTime", "Stop Time for Trading", "", "24:00:00");

    strategy.parameters:addBoolean("UseMandatoryClosing", "Use Mandatory Closing", "", false);
    strategy.parameters:addString("ExitTime", "Mandatory Closing  Time", "", "23:59:00");
    strategy.parameters:addInteger("ValidInterval", "Valid interval for operation in second", "", 60);
    
    
end
local OpenTime, CloseTime, ExitTime,ValidInterval;
local Source,TickSource;
local MaxNumberOfPositionInAnyDirection, MaxNumberOfPosition;
local SoundFile = nil;
local RecurrentSound = false;
local ALLOWEDSIDE;
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
local ExecutionType;
local CloseOnOpposite
local first;
local CCI_Period, CCI_Trigger_Level,CCI_Type, CCI_MA_Period, CCI_Method, CCI; 
local Gann,Period,Method;
local TVI,r,s;
local T3,a,b;
local Direction;
local CustomID;
local Exit;
-- Don't need to store hour + minute + second for each time
local OpenTime, CloseTime, ExitTime;
local BTF_Source;
local BTF_CCI;
local BTF_Gann;
local BTF_TVI;
local BTF_T3;
--
function Prepare( nameOnly)
    CustomID = instance.parameters.CustomID;
    ExecutionType = instance.parameters.ExecutionType;
    CloseOnOpposite = instance.parameters.CloseOnOpposite;
    MaxNumberOfPositionInAnyDirection = instance.parameters.MaxNumberOfPositionInAnyDirection;
    MaxNumberOfPosition = instance.parameters.MaxNumberOfPosition;
    Direction = instance.parameters.Direction == "direct";
    Exit = instance.parameters.Exit;
    
    ValidInterval = instance.parameters.ValidInterval;
    UseMandatoryClosing = instance.parameters.UseMandatoryClosing;
    
    CCI_Period= instance.parameters.CCI_Period;
    CCI_Trigger_Level= instance.parameters.CCI_Trigger_Level; 

    CCI_Type= instance.parameters.CCI_Type;
    CCI_MA_Period= instance.parameters.CCI_MA_Period;
    CCI_Method= instance.parameters.CCI_Method;    
    
    
    Period= instance.parameters.Period;
    Method= instance.parameters.Method;
    r= instance.parameters.r;
    s= instance.parameters.s;
    a= instance.parameters.a;
    b= instance.parameters.b;

    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick");

    local name;
    name = profile:id() .. "( " .. instance.bid:name() .. "," .. CustomID ..  " )";
    instance:name(name);
   
    PrepareTrading();

    if nameOnly then
        return ;
    end
    
    assert(core.indicators:findIndicator("T3_MA") ~= nil, "Please, download and install T3_MA.LUA indicator");
    assert(core.indicators:findIndicator("TVI") ~= nil, "Please, download and install TVI.LUA indicator");
    assert(core.indicators:findIndicator("CCI_HISTOGRAM") ~= nil, "Please, download and install CCI_HISTOGRAM.LUA indicator");
    assert(core.indicators:findIndicator("GANNHILO HISTOGRAM") ~= nil, "Please, download and install GANNHILO HISTOGRAM.LUA indicator");       
    assert(core.indicators:findIndicator("T3_MA_HISTOGRAM") ~= nil, "Please, download and install T3_MA_HISTOGRAM.LUA indicator");
    assert(core.indicators:findIndicator("TVI_HISTOGRAM") ~= nil, "Please, download and install TVI_HISTOGRAM.LUA indicator");           
        
    if ExecutionType== "Live" then
        TickSource = ExtSubscribe(1, nil, "t1", instance.parameters.Type == "Bid", "close");
    end
    
    Source = ExtSubscribe(2, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar");
    CCI =   core.indicators:create("CCI_HISTOGRAM", Source, CCI_Period,CCI_Type, CCI_Trigger_Level,CCI_MA_Period, CCI_Method, core.rgb(0, 255, 0),core.rgb(255, 0, 0));    
    Gann = core.indicators:create("GANNHILO HISTOGRAM", Source.close, Period, Method,core.rgb(0, 255, 0),core.rgb(255, 0, 0));
    TVI = core.indicators:create("TVI_HISTOGRAM", Source, r,s,core.rgb(0, 255, 0),core.rgb(255, 0, 0));
    T3 = core.indicators:create("T3_MA_HISTOGRAM", Source.close, a,b,core.rgb(0, 255, 0),core.rgb(255, 0, 0));
    if instance.parameters.confirm_with_htf then
        BTF_Source = ExtSubscribe(3, nil, instance.parameters.BTF_TF, instance.parameters.Type == "Bid", "bar");
        BTF_CCI = core.indicators:create("CCI_HISTOGRAM", BTF_Source, instance.parameters.BTF_CCI_Period,
            instance.parameters.BTF_CCI_Type, instance.parameters.BTF_CCI_Trigger_Level,
            instance.parameters.BTF_CCI_MA_Period, instance.parameters.BTF_CCI_Method,
            core.rgb(0, 255, 0),core.rgb(255, 0, 0));
        BTF_Gann = core.indicators:create("GANNHILO HISTOGRAM", BTF_Source.close, instance.parameters.BTF_Period,
            instance.parameters.BTF_Method, core.rgb(0, 255, 0), core.rgb(255, 0, 0));
        BTF_TVI = core.indicators:create("TVI_HISTOGRAM", BTF_Source, instance.parameters.BTF_r,
            instance.parameters.BTF_s, core.rgb(0, 255, 0), core.rgb(255, 0, 0));
        BTF_T3 = core.indicators:create("T3_MA_HISTOGRAM", BTF_Source.close, 
            instance.parameters.BTF_a, instance.parameters.BTF_b, core.rgb(0, 255, 0), core.rgb(255, 0, 0));
    end
 
    first=math.max(CCI.DATA:first(),Gann.DATA:first(),TVI.DATA:first(),T3.DATA:first())+1; 
    
     local valid;
    OpenTime, valid = ParseTime(instance.parameters.StartTime);
    assert(valid, "Time " .. instance.parameters.StartTime .. " is invalid");
    CloseTime, valid = ParseTime(instance.parameters.StopTime);
    assert(valid, "Time " .. instance.parameters.StopTime .. " is invalid");
    ExitTime, valid = ParseTime(instance.parameters.ExitTime);
    assert(valid, "Time " .. instance.parameters.ExitTime .. " is invalid");
    
    if UseMandatoryClosing then
        core.host:execute("setTimer", 100, math.max(ValidInterval / 2, 1));
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
 
local Last;
local LAST;
local ONE;

function GetDirection(indi_stream, period)
    if indi_stream:colorI(period) == core.rgb(0, 255, 0) then
        return 1;
    elseif indi_stream:colorI(period) == core.rgb(255, 0, 0) then
        return -1;
    end
    return 0;
end

function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.
    if AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
            return ;
        end
    end
    if (BTF_Source:size() == 0) then
        return;
    end
    
    if  ExecutionType ==  "Live" and  id == 1 then
            
            period= core.findDate (Source.close, TickSource:date(period), false );        
                    
    end

    if  ExecutionType ==  "Live"  then
    
            if ONE == Source:serial(period) then
            return;
            end
    
            if id == 2 then
            return;
            end        
            
            
        
    else    
        if id ~= 2 then       
        return;
        end
    end

    CCI:update(core.UpdateLast);
    Gann:update(core.UpdateLast);
    TVI:update(core.UpdateLast);
    T3:update(core.UpdateLast);
    if (BTF_Source ~= nil) then
        BTF_CCI:update(core.UpdateLast);
        BTF_Gann:update(core.UpdateLast);
        BTF_TVI:update(core.UpdateLast);
        BTF_T3:update(core.UpdateLast);
    end
    
    if period < first then
        return;
    end
    
    local CountNow = GetDirection(CCI.DATA, period)
        + GetDirection(Gann.DATA, period)
        + GetDirection(TVI.DATA, period)
        + GetDirection(T3.DATA, period);
    local CountPrevious = GetDirection(CCI.DATA, period - 1)
        + GetDirection(Gann.DATA, period - 1)
        + GetDirection(TVI.DATA, period - 1)
        + GetDirection(T3.DATA, period - 1);
    local confirm_count;
    if BTF_Source ~= nil then
        local btf_period = BTF_CCI.DATA:size() - 1;
        if BTF_Source:date(NOW) == Source:date(NOW) then
            btf_period = btf_period - 1;
        end
        confirm_count = GetDirection(BTF_CCI.DATA, btf_period)
            + GetDirection(BTF_Gann.DATA, btf_period)
            + GetDirection(BTF_TVI.DATA, btf_period)
            + GetDirection(BTF_T3.DATA, btf_period);
    else
        confirm_count = 4;
    end
    -- only buy if we have a fast cross over slow and the price is above the moving averages.
    if CountNow == 4 and CountPrevious ~= 4 and confirm_count == 4 then
        if Direction then
            BUY();
        else
            SELL();
        end
        ONE= Source:serial(period);
    elseif CountNow == -4 and CountPrevious ~= -4 and confirm_count == -4 then
        if Direction then
            SELL();
        else
            BUY();
        end
        ONE= Source:serial(period);
    end
    
    if Exit then
        if CountNow ~= 4 then
            if Direction then
                if haveTrades("B") then
                    exitSpecific("B");
                    Signal ("Close Long");
                end
            else 
                if haveTrades("S") then
                    exitSpecific("S");
                    Signal ("Close Short");
                end
            end
        end
        if CountNow ~= -4 then
            if   Direction then    
                if haveTrades("S") then
                    exitSpecific("S");
                    Signal ("Close Short");
                end 
            else 
                if haveTrades("B") then
                    exitSpecific("B");
                    Signal ("Close Long");
                end
            end
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
                     exitSpecific("S");
                     Signal ("Close Short");
                end
                if haveTrades("B") then
                     exitSpecific("B");
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

--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--
function BUY()
    if AllowTrade then
        if CloseOnOpposite and haveTrades("S") then
            -- close on opposite signal
            exitSpecific("S");
            Signal ("Close Short");
        end

        if ALLOWEDSIDE == "Sell"  then
            -- we are not allowed buys.
            return;
        end 

        enter("B");
    else
        Signal ("Buy Signal");    
    end
end   
    
function SELL ()        
    if AllowTrade then
        if CloseOnOpposite and haveTrades("B") then
            -- close on opposite signal
            exitSpecific("B");
            Signal ("Close Long");
        end

        if ALLOWEDSIDE == "Buy"  then
            -- we are not allowed sells.
            return;
        end

        enter("S");
    else
        Signal ("Sell Signal");    
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
    while row ~= nil do
        if row.AccountID == Account and row.OfferID == Offer and row.QTXT == CustomID and (row.BS == BuySell or BuySell == nil) then
            count = count + 1;
        end

        row = enum:next();
    end

    return count;
end

function haveTrades(BuySell) 
    local enum, row;
    local found = false;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while (row ~= nil) do
        if row.AccountID == Account and row.OfferID == Offer and row.QTXT == CustomID and (row.BS == BuySell or BuySell == nil) then
            found = true;
            break;
        end

        row = enum:next();
    end

    return found;
end

-- enter into the specified direction
function enter(BuySell)
    -- do not enter if position in the specified direction already exists
    if tradesCount(BuySell) >= MaxNumberOfPosition
    or ((tradesCount(nil)) >= MaxNumberOfPositionInAnyDirection)    
    then
        return true;
    end

    -- send the alert after the checks to see if we can trade.
    if (BuySell == "S") then
        Signal ("Sell Signal");    
    else
        Signal ("Buy Signal");    
    end

    return MarketOrder(BuySell);
end


-- enter into the specified direction
function MarketOrder(BuySell)
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
function exitSpecific(BuySell)
    -- we have to loop through to exit all trades in each direction instead
    -- of using the net qty flag because we may be running multiple strategies on the same account.
    local enum, row;
    local found = false;
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while (not found) and (row ~= nil) do
        -- for every trade for this instance.
        if row.AccountID == Account and row.OfferID == Offer and row.QTXT == CustomID and (row.BS == BuySell or BuySell == nil) then
           exitTrade(row);
        end

        row = enum:next();
    end
end

-- exit from the specified direction
function exitTrade(tradeRow)
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

