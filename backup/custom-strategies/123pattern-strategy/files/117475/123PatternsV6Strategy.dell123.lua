-- Id: 20488
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=60232

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

local Modules = {};

function Init() --The strategy profile initialization
    strategy:name("123 Patterns Strategy");
    strategy:description("A strategy based off the 123 Patterns Indicator");
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    
    strategy.parameters:addGroup("Price");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
    
    strategy.parameters:addString("TF", "Time frame", "", "m1");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Strategy Parameters");
    strategy.parameters:addBoolean("WaitForBar", "Wait for bar to close", "True to wait for a bar to close to determine a signal, false to go off current prices.", true);
    strategy.parameters:addInteger("ZigZagDepth", "ZigZagDepth", "", 1);
    strategy.parameters:addDouble("RetraceDepthMin", "RetraceDepthMin", "", 0.4);
    strategy.parameters:addDouble("RetraceDepthMax", "RetraceDepthMax", "", 1);
    strategy.parameters:addBoolean("ShowAllBreaks", "ShowAllBreaks", "", true);
    strategy.parameters:addDouble("Target1Multiply", "Target1Multiply", "", 1.5);
    strategy.parameters:addDouble("Target2Multiply", "Target2Multiply", "", 3);
    strategy.parameters:addString("Direction", "Type of signal", "", "direct");
    strategy.parameters:addStringAlternative("Direction", "direct", "", "direct");
    strategy.parameters:addStringAlternative("Direction", "reverse", "", "reverse");
    strategy.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "123");
    strategy.parameters:addBoolean("inTurns", "In turns", "Trade each direction in turns. Buy, then Sell, then Buy etc etc.", false);

    CreateTradingParameters();
    
    strategy.parameters:addGroup("Time Parameters");
     
    strategy.parameters:addInteger("ToTime", "Convert the date to", "", 6);
    strategy.parameters:addIntegerAlternative("ToTime", "EST", "", 1);
    strategy.parameters:addIntegerAlternative("ToTime", "UTC", "", 2);
    strategy.parameters:addIntegerAlternative("ToTime", "Local", "", 3);
    strategy.parameters:addIntegerAlternative("ToTime", "Server", "", 4);
    strategy.parameters:addIntegerAlternative("ToTime", "Financial", "", 5);
    strategy.parameters:addIntegerAlternative("ToTime", "Display", "", 6);
    
    strategy.parameters:addString("StartTime", "Start Time for Trading", "", "00:00:00");
    strategy.parameters:addString("StopTime", "Stop Time for Trading", "", "24:00:00");

    strategy.parameters:addBoolean("UseMandatoryClosing", "Use Mandatory Closing", "", false);
    strategy.parameters:addString("ExitTime", "Mandatory Closing  Time", "", "23:59:00");
    strategy.parameters:addInteger("ValidInterval", "Valid interval for operation in second", "", 60);
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

    strategy.parameters:addBoolean("AllowMultiple", "Allow Multiple", "Should we allow multiple positions in the same direction.", true);
    strategy.parameters:addInteger("MultipleLimit", "Open Position Limit", "The number of open positions in the same direction allowed for each instance of this strategy. Zero for unlimited.", 0, 0, 1000);
    strategy.parameters:addBoolean("CloseOnOpposite", "Close On Opposite", "Closes existing positions in one direction when an opposite direction entry signal is generated.", true);
    strategy.parameters:addString("Account", "Account to trade on", "", "");
    strategy.parameters:setFlag("Account", core.FLAG_ACCOUNT);
    strategy.parameters:addInteger("Amount", "Trade Amount in Lots", "", 1, 1, 1000000);
    strategy.parameters:addBoolean("SetStop", "Set Stop Orders", "", false);
    strategy.parameters:addInteger("Stop", "Stop Order in pips", "", 30, 1, 10000);
    strategy.parameters:addBoolean("TrailingStop", "Trailing stop order", "", false);
    strategy.parameters:addDouble("breakeven_to", "Breakeven to", "", 0);

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
local MultipleLimit;
local AllowTrade;
local Offer;
local CanClose;
local Account;
local Amount;
local SetStop;
local Stop;
local TrailingStop;
local ShowAlert;
local Email;
local SendEmail;
local BaseSize;

local Direction;
local first;

local ZigZag;
local ZigZagDepth;
local RetraceDepthMin;
local RetraceDepthMax;
local ShowAllBreaks;
local UpperLine={};
local LowerLine={};
local WaitForBar=false;
local Target1Multiply;
local Target2Multiply;

local CustomID;
local first;
local CloseOnOpposite;
local pipSize;

local inTurns;

local OpenTime, CloseTime, ExitTime;
local ValidInterval,UseMandatoryClosing;
local ToTime;
--
function Prepare( nameOnly)
    Direction = instance.parameters.Direction;    
     
    ZigZagDepth=instance.parameters.ZigZagDepth;
    RetraceDepthMin=instance.parameters.RetraceDepthMin;
    RetraceDepthMax=instance.parameters.RetraceDepthMax;
    ShowAllBreaks=instance.parameters.ShowAllBreaks;
    WaitForBar=instance.parameters.WaitForBar;
    inTurns = instance.parameters.inTurns;
    Target1Multiply = instance.parameters.Target1Multiply;
    Target2Multiply = instance.parameters.Target2Multiply;

    CustomID = instance.parameters.CustomID;
    CloseOnOpposite = instance.parameters.CloseOnOpposite;

    assert(instance.parameters.TF ~= "t1", "The time frame must not be tick");

    local name;
    name = profile:id() .. "( " .. instance.bid:name() .. "," .. ZigZagDepth .. "," .. RetraceDepthMin .. "," .. RetraceDepthMax .. "," .. tostring(ShowAllBreaks) .. "," .. CustomID ..  " )";
    instance:name(name);
    PrepareTrading();
    for _, module in pairs(Modules) do module:Prepare(nameOnly); end
    if nameOnly then
        return ;
    end
    
    if (not WaitForBar) then
        -- we need a tick source.
        TickSource = ExtSubscribe(2, nil, "t1", instance.parameters.Type == "Bid", "close");
    end
    Source = ExtSubscribe(1, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar");
    pipSize = Source:pipSize();
    ZigZag = core.indicators:create("ZIGZAG", Source, ZigZagDepth, 5, 3);
    first = Source:first() + ZigZagDepth;
    ToTime= instance.parameters.ToTime;
    ValidInterval = instance.parameters.ValidInterval;
    UseMandatoryClosing = instance.parameters.UseMandatoryClosing;    
    
    if ToTime == 1 then
        ToTime=core.TZ_EST;
    elseif ToTime == 2 then
        ToTime=core.TZ_UTC;
    elseif ToTime == 3 then
        ToTime=core.TZ_LOCAL;
    elseif ToTime == 4 then
        ToTime=core.TZ_SERVER;
    elseif ToTime == 5 then
        ToTime=core.TZ_FINANCIAL;
    elseif ToTime == 6 then
        ToTime=core.TZ_TS;
    end
    
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
    breakeven:Prepare(false);
end

function PrepareTrading()
    AllowMultiple =  instance.parameters.AllowMultiple;
    MultipleLimit = instance.parameters.MultipleLimit;
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
    SetStop = instance.parameters.SetStop;
    Stop = instance.parameters.Stop;
    TrailingStop = instance.parameters.TrailingStop;
end

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

function SearchPeaks(period)
 local i=period;
 local LastHigh=nil;
 local PrevHigh=nil;
 local LastLow=nil;
 local PrevLow=nil;
 while i>first and (PrevHigh==nil or PrevLow==nil) do
  local ZZ=ZigZag.DATA[i];
  if math.abs(ZZ-Source.high[i])<Source:pipSize()/2 then
   if LastHigh==nil then
    LastHigh=i;
   elseif PrevHigh==nil then
    PrevHigh=i;
   end
  elseif math.abs(ZZ-Source.low[i])<Source:pipSize()/2 then 
   if LastLow==nil then
    LastLow=i;
   elseif PrevLow==nil then
    PrevLow=i;
   end 
  end
  i=i-1;
 end
 return PrevLow, PrevHigh, LastLow, LastHigh;
end

function InRange(now, openTime, closeTime)
    if openTime < closeTime then
        return now >= openTime and now <= closeTime;
    end
    if openTime > closeTime then
        return now > openTime or now < closeTime;
    end

    return now == openTime;
end

local Last;
local LAST;
local ONE;
local lastDirection = 0;
function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.
    for _, module in pairs(Modules) do if module.ExtUpdate ~= nil then module:ExtUpdate(id, source, period); end end 
    if id > 2 then
        return;
    end
    if AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
            return ;
        end
    end
    now = core.host:execute("getServerTime");
    now= core.host:execute ("convertTime", core.TZ_EST, ToTime, now);
   -- get only time
    now = now - math.floor(now);
    if not InRange(now, OpenTime, CloseTime)
    then
        return ;
    end
    
    if WaitForBar then
        -- normal wait for bar to close execution
        if id ~= 1 then
            -- if this is the bar source, abort.
            return;
        end
    else
        -- immediate execution
        if period == Last and LAST == TickSource[TickSource:size()-1] then
            -- if we have already done this data, skip it.
            return;
        else
            -- new data.
            Last = period;
            LAST = TickSource[TickSource:size()-1];
            -- find the period of the bar at the same date as the last tick.
            period = core.findDate (Source.close, TickSource:date(TickSource:size()-1), false );
        end    

        if id == 1 then
            -- if this is the bar source, abort.
            return;
        end
    end

    ZigZag:update(core.UpdateLast);

    if period < first  then
        -- not enough data, abort.
        return;
    end
    
    if ONE == Source:serial(period) then
        -- if we have already actioned the last signal.
        return;
    end

    local one, onetime, two, twotime, three, threetime;
    local retracedepth=0;
    local range;
    UpperLine[period]=UpperLine[period-1];
    LowerLine[period]=LowerLine[period-1];

    local PrevLow,PrevHigh,LastLow,LastHigh=SearchPeaks(period);
    if PrevLow==nil or PrevHigh==nil then
        return;
    end

    local i;
    for i=LastHigh,period,1 do
        UpperLine[i]=Source.high[LastHigh];
    end
    for i=LastLow,period,1 do
        LowerLine[i]=Source.low[LastLow];
    end

    local doBuy = false;
    one=Source.low[PrevLow];
    onetime=PrevLow;
    two=Source.high[LastHigh];
    twotime=LastHigh;
    if twotime==period then
        two=Source.high[PrevHigh];
        twotime=PrevHigh;
    end
    three=Source.low[LastLow];
    threetime=LastLow;
    if one-two~=0 then
        retracedepth=(three-two)/(one-two);
    else
        retracedepth=0; 
    end
    local Target1Line;
    local Target2Line;
    if Source.low[period]<UpperLine[period] and Source.close[period]>UpperLine[period] then
        if (retracedepth>RetraceDepthMin and retracedepth<RetraceDepthMax) then
            doBuy = true;
            range=math.abs(two-three);
            Target1Line=two+range*Target1Multiply;
            Target2Line=two+range*Target2Multiply;
        end
        if ShowAllBreaks then
            range=UpperLine[period]-LowerLine[period];
            Target1Line=UpperLine[period]+range*Target1Multiply;
            Target2Line=UpperLine[period]+range*Target2Multiply;
            doBuy = true;
        end
    end
    if (doBuy and (not inTurns or lastDirection ~= 1)) then
        ONE = Source:serial(period);
        lastDirection = 1;
        local command1 = BUY();
        local command2 = BUY();
        if command1 ~= nil then
            local first_trade = command1:SetLimit(Target1Line):Execute();
            local second_trade = command2:SetLimit(Target2Line):Execute();
            local controller = breakeven:CreateController()
                :SetRequestID(second_trade.RequestID)
                :SetWhen(Target1Line)
                :SetTo(instance.parameters.breakeven_to);
            controller.TriggerTrade = first_trade;
        end
    end

    local doSell = false;
    one=Source.high[PrevHigh];
    onetime=PrevHigh;
    two=Source.low[LastLow];
    twotime=LastLow;
    if twotime==period then
        two=Source.low[PrevLow];
        twotime=PrevLow;
    end
    three=Source.high[LastHigh];
    threetime=LastHigh;
    if one-two~=0 then
        retracedepth=(three-two)/(one-two);
    else
        retracedepth=0;
    end
    if Source.high[period]>LowerLine[period] and Source.close[period]<LowerLine[period] then
        if (retracedepth>RetraceDepthMin and retracedepth<RetraceDepthMax) then
            doSell = true;
            range=math.abs(two-three);
            Target1Line=two-range*Target1Multiply;
            Target2Line=two-range*Target2Multiply;
        end
        if ShowAllBreaks then
            doSell = true;
            range=UpperLine[period]-LowerLine[period];
            Target1Line=LowerLine[period]-range*Target1Multiply;
            Target2Line=LowerLine[period]-range*Target2Multiply;
        end
    end
    if (doSell and (not inTurns or lastDirection ~= -1)) then
        ONE = Source:serial(period);
        lastDirection = -1;
        local command1 = SELL();
        local command2 = SELL();
        if command1 ~= nil then
            local first_trade = command1:SetLimit(Target1Line):Execute();
            local second_trade = command2:SetLimit(Target2Line):Execute();
            local controller = breakeven:CreateController()
                :SetRequestID(second_trade.RequestID)
                :SetWhen(Target1Line)
                :SetTo(instance.parameters.breakeven_to);
            controller.TriggerTrade = first_trade;
        end
    end
end

function ReleaseInstance() 
    for _, module in pairs(Modules) do if module.ReleaseInstance ~= nil then module:ReleaseInstance(); end end 
    if log_file ~= nil then
        log_file:close();
    end
end

-- NG: Introduce async function for timer/monitoring for the order results
function ExtAsyncOperationFinished(cookie, success, message)
    for _, module in pairs(Modules) do if module.AsyncOperationFinished ~= nil then module:AsyncOperationFinished(cookie, success, message, message1, message2); end end
    if cookie == 100 then
        -- timer
        if UseMandatoryClosing and AllowTrade then
            now = core.host:execute("getServerTime");
            now= core.host:execute ("convertTime", core.TZ_EST, ToTime, now);
            -- get only time
            now = now - math.floor(now);
            
            -- check whether the time is in the exit time period
            if now >= ExitTime and now < ExitTime +(ValidInterval / 86400.0) then
                if not checkReady("trades")  then
                    return ;
                end  
        
                if haveTrades("B")  then
                    exitSpecific("B");
                    Signal ("Close Long");
                end
                
                if haveTrades("S")  then
                    exitSpecific("S");
                    Signal ("Close Short");
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
            exitSpecific("S");
            Signal ("Close Short");
        end

        if ALLOWEDSIDE == "Sell"  then
            -- we are not allowed buys.
            return;
        end 

        return enter("B");
    else
        Signal ("Buy Signal");    
    end
end   
    
function SELL ()        
    if AllowTrade then
        if CloseOnOpposite and haveTrades("B") then
            exitSpecific("B");
            Signal ("Close Long");
        end

        if ALLOWEDSIDE == "Buy"  then
            -- we are not allowed sells.
            return;
        end

        return enter("S");
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
    if not(AllowTrade) then
        return nil;
    end

    -- do not enter if position in the
    -- specified direction already exists
    local count = tradesCount(BuySell);
    if (AllowMultiple) then
        -- if we allow multiple trades
        if (MultipleLimit > 0 and (count >= MultipleLimit)) then
            -- we have exceeded our multiple limit count.
            return nil;
        end
    else
        if count > 0 then
            -- if we have more than one trade and we aren't allowed multiple, abort.
            return nil;
        end
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
    local command = trading:MarketOrder(instance.bid:instrument())
        :SetAccountID(Account)
        :SetAmount(Amount)
        :SetSide(BuySell)
        :SetCustomID(CustomID);

    if SetStop then 
        command = command:SetPipStop("O", Stop, TrailingStop and 1 or nil);
    end
    return command;
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
    valuemap.TradeID = tradeRow.TradeID;
    valuemap.Quantity = tradeRow.Lot;
    -- valuemap.NetQtyFlag = "Y"; -- this forces all trades to close in the opposite direction.
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

breakeven = {};
-- public fields
breakeven.Name = "Breakeven";
breakeven.Version = "2.0";
breakeven.Debug = false;
--private fields
breakeven._moved_stops = {};
breakeven._request_id = nil;
breakeven._used_stop_orders = {};
breakeven._ids_start = nil;
breakeven._trading = nil;
breakeven._controllers = {};

function breakeven:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function breakeven:OnNewModule(module)
    if module.Name == "Trading" then self._trading = module; end
    if module.Name == "Tables monitor" then
        module:ListenCloseTrade(BreakevenOnClosedTrade);
    end
    if module.Name == "Signaler" then
        self._signaler = module;
    end
end
function BreakevenOnClosedTrade(closed_trade)
    for _, controller in ipairs(breakeven._controllers) do
        if controller.TradeID == closed_trade.TradeID then
            controller._trade = core.host:findTable("trades"):find("TradeID", closed_trade.TradeIDRemain);
            controller.TradeID = closed_trade.TradeIDRemain;
        elseif controller.TradeID == closed_trade.TradeIDRemain then
            controller._executed = true;
            controller._close_percent = nil;
        end
    end
end
function breakeven:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end

function breakeven:Init(parameters)
end

function breakeven:Prepare(nameOnly)
end

function breakeven:ExtUpdate(id, source, period)
    for _, controller in ipairs(self._controllers) do
        controller:DoBreakeven();
    end
end

function breakeven:round(num, idp)
    if idp and idp > 0 then
        local mult = 10 ^ idp
        return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end

function breakeven:CreateBaseController()
    local controller = {};
    controller._parent = self;
    controller._executed = false;
    function controller:SetTrade(trade)
        self._trade = trade;
        self.TradeID = trade.TradeID;
        return self;
    end
    function controller:GetOffer()
        if self._offer == nil then
            local order = self:GetOrder();
            if order == nil then
                order = self:GetTrade();
            end
            self._offer = core.host:findTable("offers"):find("Instrument", order.Instrument);
        end
        return self._offer;
    end
    function controller:SetRequestID(trade_request_id)
        self._request_id = trade_request_id;
        return self;
    end
    function controller:GetOrder()
        if self._order == nil then
            self._order = core.host:findTable("orders"):find("RequestID", self._request_id);
        end
        return self._order;
    end
    function controller:GetTrade()
        if self._trade == nil and self._request_id ~= nil then
            self._trade = core.host:findTable("trades"):find("OpenOrderReqID", self._request_id);
            if self._trade == nil then
                return nil;
            end
            self.TradeID = self._trade.TradeID;
            self._initial_limit = self._trade.Limit;
            self._initial_stop = self._trade.Stop;
        end
        return self._trade;
    end
    return controller;
end

function breakeven:CreateMartingale(openFunction)
    local controller = self:CreateBaseController();
    controller.OpenFunction = openFunction;
    function controller:SetStep(step)
        self._step = step;
        return self;
    end
    function controller:SetLotSizingValue(martingale_lot_sizing_val)
        self._martingale_lot_sizing_val = martingale_lot_sizing_val;
        return self;
    end
    function controller:SetStop(Stop)
        self._martingale_stop = Stop;
        return self;
    end
    function controller:SetLimit(Limit)
        self._martingale_limit = Limit;
        return self;
    end
    function controller:DoBreakeven()
        if self._executed then
            return false;
        end
        local trade = self:GetTrade();
        if trade == nil then
            return true;
        end
        if not trade:refresh() then
            self._executed = true;
            return false;
        end
        if self._current_lot == nil then
            self._current_lot = trade.AmountK;
        end
        local pipSize = self:GetOffer().PointSize;
        if trade.BS == "B" then
            local movement = (trade.Close - trade.Open) / pipSize;
            local enoughtMovement = false;
            if self._step >= 0 then
                enoughtMovement = movement <= -self._step;
            else
                enoughtMovement = movement >= -self._step;
            end
            if enoughtMovement then
                self._current_lot = self._current_lot * self._martingale_lot_sizing_val;
                local result = self.OpenFunction("B", math.floor(self._current_lot + 0.5), trade);
                self._trade = nil;
                self:SetRequestID(result.RequestID);
                if self._signaler ~= nil then
                    local command = string.format("action=create symbol=%s side=buy quantity=%s"
                        , trade.Instrument
                        , tostring(math.floor(self._current_lot + 0.5)));
                    self._signaler:SendCommand(command);
                end
                return true;
            end
        else
            local movement = (trade.Open - trade.Close) / pipSize;
            if self._step >= 0 then
                enoughtMovement = movement <= -self._step;
            else
                enoughtMovement = movement >= -self._step;
            end
            if enoughtMovement then
                self._current_lot = self._current_lot * self._martingale_lot_sizing_val;
                local result = self.OpenFunction("S", math.floor(self._current_lot + 0.5), trade);
                self._trade = nil;
                self:SetRequestID(result.RequestID);
                if self._signaler ~= nil then
                    local command = string.format("action=create symbol=%s side=sell quantity=%s"
                        , trade.Instrument
                        , tostring(math.floor(self._current_lot + 0.5)));
                    self._signaler:SendCommand(command);
                end
                return true;
            end
        end
        --self:UpdateStopLimits();
        return true;
    end
    function controller:CloseAll()
        core.host:trace("Closing all positions");
        local it = trading:FindTrade():WhenCustomID(CustomID)
        it:Do(function (trade) trading:Close(trade); end);
        if self._signaler ~= nil then
            signaler:SendCommand("action=close");
        end
        self._executed = true;
    end
    function controller:UpdateStopLimits()
        local trade = self:GetTrade();
        if trade == nil then
            return;
        end
        local offer = self:GetOffer();
        local bAmount = 0;
        local bPriceSumm = 0;
        local sAmount = 0;
        local sPriceSumm = 0;
        trading:FindTrade()
            :WhenCustomID(CustomID)
            :Do(function (trade)
                if trade.BS == "B" then
                    bAmount = bAmount + trade.AmountK
                    bPriceSumm = bPriceSumm + trade.Open * trade.AmountK;
                else
                    sAmount = sAmount + trade.AmountK
                    sPriceSumm = sPriceSumm + trade.Open * trade.AmountK;
                end
            end);
        local avgBPrice = bPriceSumm / bAmount;
        local avgSPrice = sPriceSumm / sAmount;
        local totalAmount = bAmount + sAmount;
        local avgPrice = avgBPrice * (bAmount / totalAmount) + avgSPrice * (sAmount / totalAmount);
        local stopPrice, limitPrice;
        if trade.BS == "B" then
            if self._martingale_stop ~= nil then
                stopPrice = avgPrice - self._martingale_stop * offer.PointSize;
                if trade.Close <= stopPrice then
                    self:CloseAll();
                end
                return;
            end
            if self._martingale_limit ~= nil then
                limitPrice = avgPrice + self._martingale_limit * offer.PointSize;
                if trade.Close >= limitPrice then
                    self:CloseAll();
                end
            end
            return;
        end
        if self._martingale_stop ~= nil then
            stopPrice = avgPrice + self._martingale_stop * offer.PointSize;
            if trade.Close >= stopPrice then
                self:CloseAll();
                return;
            end
        end
        if self._martingale_limit ~= nil then
            limitPrice = avgPrice - self._martingale_limit * offer.PointSize;
            if trade.Close <= limitPrice then
                self:CloseAll();
            end
        end
    end
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end

breakeven.STOP_ID = 1;
breakeven.LIMIT_ID = 2;

function breakeven:CreateOrderTrailingController()
    local controller = self:CreateBaseController();
    function controller:SetTrailingTarget(id)
        self._target_id = id;
        return self;
    end
    function controller:MoveUpOnly()
        self._up_only = true;
        return self;
    end
    function controller:SetIndicatorStream(stream, multiplicator, is_distance)
        self._stream = stream;
        self._stream_in_distance = is_distance;
        self._stream_multiplicator = multiplicator;
        return self;
    end
    function controller:SetIndicatorStreamShift(x, y)
        self._stream_x_shift = x;
        self._stream_y_shift = y;
        return self;
    end
    function controller:DoBreakeven()
        if self._executed then
            return false;
        end
        local order = self:GetOrder();
        if order == nil or (self._move_command ~= nil and not self._move_command.Finished) then
            return true;
        end
        if not order:refresh() then
            self._executed = true;
            return false;
        end
        local streamPeriod = NOW;
        if self._stream_x_shift ~= nil then
            streamPeriod = streamPeriod - self._stream_x_shift;
        end
        if not self._stream:hasData(streamPeriod) then
            return true;
        end
        return self:DoOrderTrailing(order, streamPeriod);
    end
    function controller:DoOrderTrailing(order, streamPeriod)
        local new_level;
        local offer = self:GetOffer();
        if self._stream_in_distance then
            local tick = self._stream:tick(streamPeriod) * self._stream_multiplicator;
            if self._stream_y_shift ~= nil then
                tick = tick + self._stream_y_shift * offer.PointSize;
            end
            if order.BS == "B" then
                new_level = breakeven:round(offer.Bid + tick, offer.Digits);
            else
                new_level = breakeven:round(offer.Ask - tick, offer.Digits);
            end
        else
            local tick = self._stream:tick(streamPeriod);
            if self._stream_y_shift ~= nil then
                if order.BS == "B" then
                    tick = tick - self._stream_y_shift * offer.PointSize;
                else
                    tick = tick + self._stream_y_shift * offer.PointSize;
                end
            end
            new_level = breakeven:round(tick, offer.Digits);
        end
        if self._up_only then
            if order.BS == "B" then
                if order.Rate >= new_level then
                    return true;
                end
            else
                if order.Rate <= new_level then
                    return true;
                end
            end
        end
        if self._min_profit ~= nil then
            if order.BS == "B" then
                if (offer.Bid - new_level) / offer.PointSize < self._min_profit then
                    return true;
                end
            else
                if (new_level - offer.Ask) / offer.PointSize < self._min_profit then
                    return true;
                end
            end
        end
        if order.Rate ~= new_level then
            self._move_command = self._parent._trading:ChangeOrder(order, new_level, order.TrlMinMove);
        end
    end
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end

function breakeven:CreateIndicatorTrailingController()
    local controller = self:CreateBaseController();
    function controller:SetTrailingTarget(id)
        self._target_id = id;
        return self;
    end
    function controller:MoveUpOnly()
        self._up_only = true;
        return self;
    end
    function controller:SetMinProfit(min_profit)
        self._min_profit = min_profit;
        return self;
    end
    function controller:SetIndicatorStream(stream, multiplicator, is_distance)
        self._stream = stream;
        self._stream_in_distance = is_distance;
        self._stream_multiplicator = multiplicator;
        return self;
    end
    function controller:SetIndicatorStreamShift(x, y)
        self._stream_x_shift = x;
        self._stream_y_shift = y;
        return self;
    end
    function controller:DoBreakeven()
        if self._executed then
            return false;
        end
        local trade = self:GetTrade();
        if trade == nil or (self._move_command ~= nil and not self._move_command.Finished) then
            return true;
        end
        if not trade:refresh() then
            self._executed = true;
            return false;
        end
        local streamPeriod = NOW;
        if self._stream_x_shift ~= nil then
            streamPeriod = streamPeriod - self._stream_x_shift;
        end
        if not self._stream:hasData(streamPeriod) then
            return true;
        end
        if self._target_id == breakeven.STOP_ID then
            return self:DoStopTrailing(trade, streamPeriod);
        elseif self._target_id == breakeven.LIMIT_ID then
            return self:DoLimitTrailing(trade, streamPeriod);
        end
        return self:DoOrderTrailing(trade, streamPeriod);
    end
    function controller:DoStopTrailing(trade, streamPeriod)
        local new_level;
        local offer = self:GetOffer();
        if self._stream_in_distance then
            local tick = self._stream:tick(streamPeriod) * self._stream_multiplicator;
            if self._stream_y_shift ~= nil then
                tick = tick + self._stream_y_shift * offer.PointSize;
            end
            if trade.BS == "B" then
                new_level = breakeven:round(trade.Open - tick, offer.Digits);
            else
                new_level = breakeven:round(trade.Open + tick, offer.Digits);
            end
        else
            local tick = self._stream:tick(streamPeriod);
            if self._stream_y_shift ~= nil then
                if trade.BS == "B" then
                    tick = tick + self._stream_y_shift * offer.PointSize;
                else
                    tick = tick - self._stream_y_shift * offer.PointSize;
                end
            end
            new_level = breakeven:round(self._stream:tick(streamPeriod), offer.Digits);
        end
        if self._min_profit ~= nil then
            if trade.BS == "B" then
                if (new_level - trade.Open) / offer.PointSize < self._min_profit then
                    return true;
                end
            else
                if (trade.Open - new_level) / offer.PointSize < self._min_profit then
                    return true;
                end
            end
        end
        if self._up_only then
            if trade.BS == "B" then
                if trade.Stop >= new_level then
                    return true;
                end
            else
                if trade.Stop <= new_level then
                    return true;
                end
            end
            return true;
        end
        if trade.Stop ~= new_level then
            self._move_command = self._parent._trading:MoveStop(trade, new_level);
        end
        return true;
    end
    function controller:DoLimitTrailing(trade, streamPeriod)
        assert(self._up_only == nil, "Not implemented!!!");
        local new_level;
        local offer = self:GetOffer();
        if self._stream_in_distance then
            local tick = self._stream:tick(streamPeriod) * self._stream_multiplicator;
            if self._stream_y_shift ~= nil then
                tick = tick + self._stream_y_shift * offer.PointSize;
            end
            if trade.BS == "B" then
                new_level = breakeven:round(trade.Open + tick, offer.Digits);
            else
                new_level = breakeven:round(trade.Open - tick, offer.Digits);
            end
        else
            local tick = self._stream:tick(streamPeriod);
            if self._stream_y_shift ~= nil then
                if trade.BS == "B" then
                    tick = tick - self._stream_y_shift * offer.PointSize;
                else
                    tick = tick + self._stream_y_shift * offer.PointSize;
                end
            end
            new_level = breakeven:round(tick, offer.Digits);
        end
        if self._min_profit ~= nil then
            if trade.BS == "B" then
                if (trade.Open - new_level) / offer.PointSize < self._min_profit then
                    return true;
                end
            else
                if (new_level - trade.Open) / offer.PointSize < self._min_profit then
                    return true;
                end
            end
        end
        if trade.Limit ~= new_level then
            self._move_command = self._parent._trading:MoveLimit(trade, new_level);
        end
    end
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end

function breakeven:CreateTrailingLimitController()
    local controller = self:CreateBaseController();
    function controller:SetDirection(direction)
        self._direction = direction;
        return self;
    end
    function controller:SetTrigger(trigger)
        self._trigger = trigger;
        return self;
    end
    function controller:SetStep(step)
        self._step = step;
        return self;
    end
    function controller:DoBreakeven()
        if self._executed then
            return false;
        end
        local trade = self:GetTrade();
        if trade == nil or (self._move_command ~= nil and not self._move_command.Finished) then
            return true;
        end
        if not trade:refresh() then
            self._executed = true;
            return false;
        end
        if self._direction == 1 then
            if trade.PL >= self._trigger then
                local offer = self:GetOffer();
                local target_limit;
                if trade.BS == "B" then
                    target_limit = self._initial_limit + self._step * offer.PointSize; 
                else
                    target_limit = self._initial_limit - self._step * offer.PointSize; 
                end
                self._initial_limit = target_limit;
                self._trigger = self._trigger + self._step;
                self._move_command = self._parent._trading:MoveLimit(trade, target_limit);
                return true;
            end
        elseif self._direction == -1 then
            if trade.PL <= -self._trigger then
                local offer = self:GetOffer();
                local target_limit;
                if trade.BS == "B" then
                    target_limit = self._initial_limit - self._step * offer.PointSize; 
                else
                    target_limit = self._initial_limit + self._step * offer.PointSize; 
                end
                self._initial_limit = target_limit;
                self._trigger = self._trigger + self._step;
                self._move_command = self._parent._trading:MoveLimit(trade, target_limit);
                return true;
            end
        else
            core.host:trace("No direction is set for the trailing limit");
        end
        return true;
    end
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end

function breakeven:ActionOnTrade(action)
    local controller = self:CreateBaseController();
    controller._action = action;
    function controller:DoBreakeven()
        if self._executed then
            return false;
        end
        local trade = self:GetTrade();
        if trade == nil then
            return true;
        end
        if not trade:refresh() then
            self._executed = true;
            return false;
        end
        self._action(trade, self);
        self._executed = true;
        return true;
    end
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end

function breakeven:CreateOnCandleClose()
    local controller = self:CreateBaseController();
    controller._trailing = 0;
    function controller:SetSource(source)
        self._source = source;
        return self;
    end
    function controller:SetBarsToLive(bars_to_live)
        self._bars_to_live = bars_to_live;
        return self;
    end
    function controller:DoBreakeven()
        if self._executed then
            return true;
        end
        local trade = self:GetTrade();
        if trade == nil then
            return true;
        end
        if not trade:refresh() then
            self._executed = true;
            return false;
        end
        local index = core.findDate(self._source, trade.Time, false);
        if self._source:size() - 1 - index >= self._bars_to_live then
            self._command = self._parent._trading:Close(trade);
            self._executed = true;
            return false;
        end
        return true;
    end
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end

function breakeven:PartialClose()
    local controller = self:CreateBaseController();
    controller._trailing = 0;
    function controller:SetWhen(when)
        self._when = when;
        return self;
    end
    function controller:SetPartialClose(amountPercent)
        self._close_percent = amountPercent;
        return self;
    end
    function controller:DoPartialClose()
        
    end
    function controller:DoBreakeven()
        if self._close_percent == nil then
            return true;
        end
        local trade = self:GetTrade();
        if trade == nil then
            return true;
        end
        if not trade:refresh() then
            self._close_percent = nil;
            return false;
        end
        if trade.PL >= self._when then
            local base_size = core.host:execute("getTradingProperty", "baseUnitSize", trade.Instrument, trade.AccountID);
            local to_close = breakeven:round(trade.Lot * self._close_percent / 100.0 / base_size) * base_size;
            trading:ParialClose(trade, to_close);
            self._close_percent = nil;
        end
        return true;
    end
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end

function breakeven:CreateController()
    local controller = self:CreateBaseController();
    controller._trailing = 0;
    function controller:SetWhen(when)
        self._when = when;
        return self;
    end
    function controller:SetTo(to)
        self._to = to;
        return self;
    end
    function controller:SetTrailing(trailing)
        self._trailing = trailing
        return self;
    end
    function controller:SetPartialClose(amountPercent)
        self._close_percent = amountPercent;
        return self;
    end
    function controller:getTo()
        local trade = self:GetTrade();
        local offer = self:GetOffer();
        if trade.BS == "B" then
            return offer.Bid - (trade.PL - self._to) * offer.PointSize;
        else
            return offer.Ask + (trade.PL - self._to) * offer.PointSize;
        end
    end
    function controller:DoPartialClose()
        local trade = self:GetTrade();
        if trade == nil then
            return true;
        end
        if not trade:refresh() then
            self._close_percent = nil;
            return false;
        end
        local base_size = core.host:execute("getTradingProperty", "baseUnitSize", trade.Instrument, trade.AccountID);
        local to_close = breakeven:round(trade.Lot * self._close_percent / 100.0 / base_size) * base_size;
        trading:ParialClose(trade, to_close);
        self._close_percent = nil;
        return true;
    end
    function controller:DoBreakeven()
        if self._executed then
            if self._close_percent ~= nil then
                if self._command ~= nil and self._command.Finished or self._command == nil then
                    self._close_percent = nil;
                    return self:DoPartialClose();
                end
            end
            return false;
        end
        local trade = self:GetTrade();
        if trade == nil then
            return true;
        end
        if not trade:refresh() then
            self._executed = true;
            return false;
        end
        if trade.PL >= self._when then
            if self._to ~= nil then
                self._command = self._parent._trading:MoveStop(trade, self:getTo(), self._trailing);
            end
            self._executed = true;
            return false;
        end
        return true;
    end
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end

function breakeven:RestoreTrailingOnProfitController(controller)
    controller._parent = self;
    function controller:SetProfitPercentage(profit_pr, min_profit)
        self._profit_pr = profit_pr;
        self._min_profit = min_profit;
        return self;
    end
    function controller:GetClosedTrade()
        if self._closed_trade == nil then
            self._closed_trade = core.host:findTable("closed trades"):find("OpenOrderReqID", self._request_id);
            if self._closed_trade == nil then return nil; end
        end
        if not self._closed_trade:refresh() then return nil; end
        return self._closed_trade;
    end
    function controller:getStopPips(trade)
        local stop = trading:FindStopOrder(trade);
        if stop == nil then
            return nil;
        end
        local offer = self:GetOffer();
        if trade.BS == "B" then
            return (stop.Rate - trade.Open) / offer.PointSize;
        else
            return (trade.Open - stop.Rate) / offer.PointSize;
        end
    end
    function controller:DoBreakeven()
        if self._executed then
            return false;
        end
        if self._move_command ~= nil and not self._move_command.Finished then
            return true;
        end
        local trade = self:GetTrade();
        if trade == nil then
            if self:GetClosedTrade() ~= nil then
                self._executed = true;
            end
            return true;
        end
        if not trade:refresh() then
            self._executed = true;
            return false;
        end
        if trade.PL < self._min_profit then
            return true;
        end
        local new_stop = trade.PL * (self._profit_pr / 100);
        local current_stop = self:getStopPips(trade);
        if current_stop == nil or current_stop < new_stop then
            local offer = self:GetOffer();
            if trade.BS == "B" then
                if not trailing_mark:hasData(NOW) then
                    trailing_mark[NOW] = trade.Close;
                end
                self._move_command = self._parent._trading:MoveStop(trade, trade.Open + new_stop * offer.PointSize);
            else
                if not trailing_mark:hasData(NOW) then
                    trailing_mark[NOW] = trade.Close;
                end
                self._move_command = self._parent._trading:MoveStop(trade, trade.Open - new_stop * offer.PointSize);
            end
            return true;
        end
        return true;
    end
end

function breakeven:CreateTrailingOnProfitController()
    local controller = self:CreateBaseController();
    controller._trailing = 0;
    self:RestoreTrailingOnProfitController(controller);
    self._controllers[#self._controllers + 1] = controller;
    return controller;
end
breakeven:RegisterModule(Modules);

trading = {};
trading.Name = "Trading";
trading.Version = "4.29";
trading.Debug = false;
trading.AddAmountParameter = true;
trading.AddStopParameter = true;
trading.AddLimitParameter = true;
trading.AddBreakevenParameters = true;
trading._ids_start = nil;
trading._signaler = nil;
trading._account = nil;
trading._all_modules = {};
trading._request_id = {};
trading._waiting_requests = {};
trading._used_stop_orders = {};
trading._used_limit_orders = {};
function trading:trace(str) if not self.Debug then return; end core.host:trace(self.Name .. ": " .. str); end
function trading:RegisterModule(modules) for _, module in pairs(modules) do self:OnNewModule(module); module:OnNewModule(self); end modules[#modules + 1] = self; self._ids_start = (#modules) * 100; end

function trading:AddPositionParameters(parameters, id, section_id)
    if self.AddAmountParameter then
        parameters:addDouble("amount" .. id, "Trade Amount", "", 1);
        parameters:addString("amount_type" .. id, "Amount Type", "", "lots");
        parameters:addStringAlternative("amount_type" .. id, "In Lots", "", "lots");
        parameters:addStringAlternative("amount_type" .. id, "% of Equity", "", "equity");
        parameters:addStringAlternative("amount_type" .. id, "Risk % of Equity", "", "risk_equity");
    end
    if CreateStopParameters == nil or not CreateStopParameters(parameters, id) then
        parameters:addGroup("  Stop parameters " .. section_id);
        parameters:addString("stop_type" .. id, "Stop Order", "", "no");
        parameters:addStringAlternative("stop_type" .. id, "No stop", "", "no");
        parameters:addStringAlternative("stop_type" .. id, "In Pips", "", "pips");
        if not DISABLE_ATR_STOP_LIMIT then
            parameters:addStringAlternative("stop_type" .. id, "ATR", "", "atr");
        end
        parameters:addStringAlternative("stop_type" .. id, "High/low", "", "highlow");
        parameters:addDouble("stop" .. id, "Stop Value", "In pips or ATR period", 30);
        if not DISABLE_ATR_STOP_LIMIT then
            parameters:addDouble("atr_stop_mult" .. id, "ATR Stop Multiplicator", "", 2.0);
        end
        parameters:addBoolean("use_trailing" .. id, "Trailing stop order", "", false);
        parameters:addInteger("trailing" .. id, "Trailing in pips", "Use 1 for dynamic and 10 or greater for the fixed trailing", 1);
    end
    if CreateLimitParameters ~= nil then
        CreateLimitParameters(parameters, id);
    else
        parameters:addGroup("  Limit parameters " .. section_id);
        parameters:addString("limit_type" .. id, "Limit Order", "", "no");
        parameters:addStringAlternative("limit_type" .. id, "No limit", "", "no");
        parameters:addStringAlternative("limit_type" .. id, "In Pips", "", "pips");
        if not DISABLE_ATR_STOP_LIMIT then
            parameters:addStringAlternative("limit_type" .. id, "ATR", "", "atr");
        end
        parameters:addStringAlternative("limit_type" .. id, "Multiplicator of stop", "", "stop");
        parameters:addStringAlternative("limit_type" .. id, "High/low", "", "highlow");
        parameters:addDouble("limit" .. id, "Limit Value", "In pips or ATR period", 30);
        if not DISABLE_ATR_STOP_LIMIT then
            parameters:addDouble("atr_limit_mult" .. id, "ATR Limit Multiplicator", "", 2.0);
        end
        if not DISABLE_LIMIT_TRAILING then
            parameters:addString("TRAILING_LIMIT_TYPE" .. id, "Trailing Limit", "", "Off");
            parameters:addStringAlternative("TRAILING_LIMIT_TYPE" .. id, "Off", "", "Off");
            parameters:addStringAlternative("TRAILING_LIMIT_TYPE" .. id, "Favorable", "moves limit up for long/buy positions, vice versa for short/sell", "Favorable");
            parameters:addStringAlternative("TRAILING_LIMIT_TYPE" .. id, "Unfavorable", "moves limit down for long/buy positions, vice versa for short/sell", "Unfavorable");
            parameters:addDouble("TRAILING_LIMIT_TRIGGER" .. id, "Trailing Limit Trigger in Pips", "", 0);
            parameters:addDouble("TRAILING_LIMIT_STEP" .. id, "Trailing Limit Step in Pips", "", 10);
        end
    end
    if self.AddBreakevenParameters then
        parameters:addGroup("  Breakeven parameters " .. section_id);
        parameters:addBoolean("use_breakeven" .. id, "Use Breakeven", "", false);
        parameters:addDouble("breakeven_when" .. id, "Breakeven Activation Value, in pips", "", 10);
        parameters:addDouble("breakeven_to" .. id, "Breakeven To, in pips", "", 0);
        parameters:addString("breakeven_trailing" .. id, "Trailing after breakeven", "", "default");
        parameters:addStringAlternative("breakeven_trailing" .. id, "Do not change", "", "default");
        parameters:addStringAlternative("breakeven_trailing" .. id, "Set trailing", "", "set");
        parameters:addBoolean("breakeven_close" .. id, "Partial close on breakeven", "", false);
        parameters:addDouble("breakeven_close_amount" .. id, "Partial close amount, %", "", 50);
    end
end

function trading:Init(parameters, count)
    parameters:addBoolean("allow_trade", "Allow strategy to trade", "", true);
    parameters:setFlag("allow_trade", core.FLAG_ALLOW_TRADE);
    parameters:addString("account", "Account to trade on", "", "");
    parameters:setFlag("account", core.FLAG_ACCOUNT);
    parameters:addString("allow_side", "Allow side", "", "both")
    parameters:addStringAlternative("allow_side", "Both", "", "both")
    parameters:addStringAlternative("allow_side", "Long/buy only", "", "buy")
    parameters:addStringAlternative("allow_side", "Short/sell only", "", "sell")
    parameters:addBoolean("close_on_opposite", "Close on Opposite", "", true);
    if ENFORCE_POSITION_CAP ~= true then
        parameters:addBoolean("position_cap", "Position Cap", "", false);
        parameters:addInteger("no_of_positions", "Max # of open positions", "", 1);
        parameters:addInteger("no_of_buy_position", "Max # of buy positions", "", 1);
        parameters:addInteger("no_of_sell_position", "Max # of sell positions", "", 1);
    end
    
    if count == nil or count == 1 then
        parameters:addGroup("Position");
        self:AddPositionParameters(parameters, "", "");
    else
        for i = 1, count do
            parameters:addGroup("Position #" .. i);
            parameters:addBoolean("use_position_" .. i, "Open position #" .. i, "", i == 1);
            self:AddPositionParameters(parameters, "_" .. i, "#" .. i);
        end
    end
end

function trading:Prepare(name_only)
    if name_only then return; end
end

function trading:ExtUpdate(id, source, period)
end

function trading:OnNewModule(module)
    if module.Name == "Signaler" then self._signaler = module; end
    self._all_modules[#self._all_modules + 1] = module;
end

function trading:AsyncOperationFinished(cookie, success, message, message1, message2)
    local res = self._waiting_requests[cookie];
    if res ~= nil then
        res.Finished = true;
        res.Success = success;
        if not success then
            res.Error = message;
            if self._signaler ~= nil then
                self._signaler:Signal(res.Error);
            else
                self:trace(res.Error);
            end
        elseif res.OnSuccess ~= nil then
            res:OnSuccess();
        end
        self._waiting_requests[cookie] = nil;
    elseif cookie == self._order_update_id then
        for _, order in ipairs(self._monitored_orders) do
            if order.RequestID == message2 then
                order.FixStatus = message1;
            end
        end
    elseif cookie == self._ids_start + 2 then
        if not success then
            if self._signaler ~= nil then
                self._signaler:Signal("Close order failed: " .. message);
            else
                self:trace("Close order failed: " .. message);
            end
        end
    end
end

function trading:getOppositeSide(side) if side == "B" then return "S"; end return "B"; end

function trading:getId()
    for id = self._ids_start, self._ids_start + 100 do
        if self._waiting_requests[id] == nil then return id; end
    end
    return self._ids_start;
end

function trading:CreateStopOrder(trade, stop_rate, trailing)
    local valuemap = core.valuemap();
    valuemap.Command = "CreateOrder";
    valuemap.OfferID = trade.OfferID;
    valuemap.Rate = stop_rate;
    if trade.BS == "B" then
        valuemap.BuySell = "S";
    else
        valuemap.BuySell = "B";
    end

    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        valuemap.OrderType = "S";
        valuemap.AcctID  = trade.AccountID;
        valuemap.TradeID = trade.TradeID;
        valuemap.Quantity = trade.Lot;
        valuemap.TrailUpdatePips = trailing;
    else
        valuemap.OrderType = "SE"
        valuemap.AcctID  = trade.AccountID;
        valuemap.NetQtyFlag = "Y"
    end

    local id = self:getId();
    local success, msg = terminal:execute(id, valuemap);
    if not(success) then
        local message = "Failed create stop " .. msg;
        self:trace(message);
        if self._signaler ~= nil then
            self._signaler:Signal(message);
        end
        local res = {};
        res.Finished = true;
        res.Success = false;
        res.Error = message;
        return res;
    end
    local res = {};
    res.Finished = false;
    res.RequestID = msg;
    self._waiting_requests[id] = res;
    self._request_id[trade.TradeID] = msg;
    return res;
end

function trading:CreateLimitOrder(trade, limit_rate)
    local valuemap = core.valuemap();
    valuemap.Command = "CreateOrder";
    valuemap.OfferID = trade.OfferID;
    valuemap.Rate = limit_rate;
    if trade.BS == "B" then
        valuemap.BuySell = "S";
    else
        valuemap.BuySell = "B";
    end
    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        valuemap.OrderType = "L";
        valuemap.AcctID  = trade.AccountID;
        valuemap.TradeID = trade.TradeID;
        valuemap.Quantity = trade.Lot;
    else
        valuemap.OrderType = "LE"
        valuemap.AcctID  = trade.AccountID;
        valuemap.NetQtyFlag = "Y"
    end
    local success, msg = terminal:execute(200, valuemap);
    if not(success) then
        terminal:alertMessage(trade.Instrument, limit_rate, "Failed create limit " .. msg, core.now());
    else
        self._request_id[trade.TradeID] = msg;
    end
end

function trading:ChangeOrder(order, rate, trailing)
    local min_change = core.host:findTable("offers"):find("Instrument", order.Instrument).PointSize;
    if math.abs(rate - order.Rate) > min_change then
        self:trace(string.format("Changing an order to %s", tostring(rate)));
        -- stop exists
        local valuemap = core.valuemap();
        valuemap.Command = "EditOrder";
        valuemap.AcctID  = order.AccountID;
        valuemap.OrderID = order.OrderID;
        valuemap.TrailUpdatePips = trailing;
        valuemap.Rate = rate;
        local id = self:getId();
        local success, msg = terminal:execute(id, valuemap);
        if not(success) then
            local message = "Failed change order " .. msg;
            self:trace(message);
            if self._signaler ~= nil then
                self._signaler:Signal(message);
            end
            local res = {};
            res.Finished = true;
            res.Success = false;
            res.Error = message;
            return res;
        end
        local res = {};
        res.Finished = false;
        res.RequestID = msg;
        self._waiting_requests[id] = res;
        return res;
    end
    local res = {};
    res.Finished = true;
    res.Success = true;
    return res;
end

function trading:IsLimitOrder(order)
    local order_type = order.Type;
    if order_type == "L" or order_type == "LT" or order_type == "LTE" then
        return true;
    end
    return order.ContingencyType == 3 and order_type == "LE";
end

function trading:IsStopOrder(order) 
    local order_type = order.Type;
    if order_type == "S" or order_type == "ST" or order_type == "STE" then
        return true;
    end
    return order.ContingencyType == 3 and order_type == "SE";
end

function trading:IsLimitOrderType(order_type) return order_type == "L" or order_type == "LE" or order_type == "LT" or order_type == "LTE"; end

function trading:IsStopOrderType(order_type) return order_type == "S" or order_type == "SE" or order_type == "ST" or order_type == "STE"; end

function trading:FindLimitOrder(trade)
    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        local order_id;
        if trade.LimitOrderID ~= nil and trade.LimitOrderID ~= "" then
            order_id = trade.LimitOrderID;
            self:trace("Using limit order id from the trade");
        elseif self._request_id[trade.TradeID] ~= nil then
            self:trace("Searching limit order by request id: " .. tostring(self._request_id[trade.TradeID]));
            local order = core.host:findTable("orders"):find("RequestID", self._request_id[trade.TradeID]);
            if order ~= nil then
                order_id = order.OrderID;
                self._request_id[trade.TradeID] = nil;
            end
        end
        -- Check that order is stil exist
        if order_id ~= nil then return core.host:findTable("orders"):find("OrderID", order_id); end
    else
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:IsLimitOrder(row) and self._used_limit_orders[row.OrderID] ~= true then
                self._used_limit_orders[row.OrderID] = true;
                return row;
            end
            row = enum:next();
        end
    end
    return nil;
end

function trading:FindStopOrder(trade)
    local can_close = core.host:execute("getTradingProperty", "canCreateMarketClose", trade.Instrument, trade.AccountID);
    if can_close then
        local order_id;
        if trade.StopOrderID ~= nil and trade.StopOrderID ~= "" then
            order_id = trade.StopOrderID;
            self:trace("Using stop order id from the trade");
        elseif self._request_id[trade.TradeID] ~= nil then
            self:trace("Searching stop order by request id: " .. tostring(self._request_id[trade.TradeID]));
            local order = core.host:findTable("orders"):find("RequestID", self._request_id[trade.TradeID]);
            if order ~= nil then
                order_id = order.OrderID;
                self._request_id[trade.TradeID] = nil;
            end
        end
        -- Check that order is stil exist
        if order_id ~= nil then return core.host:findTable("orders"):find("OrderID", order_id); end
    else
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:IsStopOrder(row) and self._used_stop_orders[row.OrderID] ~= true then
                self._used_stop_orders[row.OrderID] = true;
                return row;
            end
            row = enum:next();
        end
    end
    return nil;
end

function trading:MoveStop(trade, stop_rate, trailing)
    local order = self:FindStopOrder(trade);
    if order == nil then
        if trailing == 0 then
            trailing = nil;
        end
        return self:CreateStopOrder(trade, stop_rate, trailing);
    else
        if trailing == 0 then
            if order.TrlMinMove ~= 0 then
                trailing = order.TrlMinMove
            else
                trailing = nil;
            end
        end
        return self:ChangeOrder(order, stop_rate, trailing);
    end
end

function trading:MoveLimit(trade, limit_rate)
    self:trace("Searching for a limit");
    local order = self:FindLimitOrder(trade);
    if order == nil then
        self:trace("Limit order not found, creating a new one");
        return self:CreateLimitOrder(trade, limit_rate);
    else
        return self:ChangeOrder(order, limit_rate);
    end
end

function trading:RemoveStop(trade)
    self:trace("Searching for a stop");
    local order = self:FindStopOrder(trade);
    if order == nil then self:trace("No stop"); return nil; end
    self:trace("Deleting order");
    return self:DeleteOrder(order);
end

function trading:RemoveLimit(trade)
    self:trace("Searching for a limit");
    local order = self:FindLimitOrder(trade);
    if order == nil then self:trace("No limit"); return nil; end
    self:trace("Deleting order");
    return self:DeleteOrder(order);
end

function trading:DeleteOrder(order)
    self:trace(string.format("Deleting order %s", order.OrderID));
    local valuemap = core.valuemap();
    valuemap.Command = "DeleteOrder";
    valuemap.OrderID = order.OrderID;

    local id = self:getId();
    local success, msg = terminal:execute(id, valuemap);
    if not(success) then
        local message = "Delete order failed: " .. msg;
        self:trace(message);
        if self._signaler ~= nil then
            self._signaler:Signal(message);
        end
        local res = {};
        res.Finished = true;
        res.Success = false;
        res.Error = message;
        return res;
    end
    local res = {};
    res.Finished = false;
    res.RequestID = msg;
    self._waiting_requests[id] = res;
    return res;
end

function trading:GetCustomID(qtxt)
    if qtxt == nil then
        return nil;
    end
    local metadata = self:GetMetadata(qtxt);
    if metadata == nil then
        return qtxt;
    end
    return metadata.CustomID;
end

function trading:FindOrder()
    local search = {};
    function search:WhenCustomID(custom_id) self.CustomID = custom_id; return self; end
    function search:WhenSide(bs) self.Side = bs; return self; end
    function search:WhenInstrument(instrument) self.Instrument = instrument; return self; end
    function search:WhenAccountID(account_id) self.AccountID = account_id; return self; end
    function search:WhenRate(rate) self.Rate = rate; return self; end
    function search:WhenOrderType(orderType) self.OrderType = orderType; return self; end
    function search:Do(action)
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        local count = 0
        while (row ~= nil) do
            if self:PassFilter(row) then
                if action(row) then
                    count = count + 1;
                end
            end
            row = enum:next();
        end
        return count;
    end
    function search:Summ(action)
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        local summ = 0
        while (row ~= nil) do
            if self:PassFilter(row) then
                summ = summ + action(row);
            end
            row = enum:next();
        end
        return summ;
    end
    function search:PassFilter(row)
        return (row.Instrument == self.Instrument or not self.Instrument)
            and (row.BS == self.Side or not self.Side)
            and (row.AccountID == self.AccountID or not self.AccountID)
            and (trading:GetCustomID(row.QTXT) == self.CustomID or not self.CustomID)
            and (row.Rate == self.Rate or not self.Rate)
            and (row.Type == self.OrderType or not self.OrderType);
    end
    function search:All()
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        local orders = {};
        while (row ~= nil) do
            if self:PassFilter(row) then orders[#orders + 1] = row; end
            row = enum:next();
        end
        return orders;
    end
    function search:First()
        local enum = core.host:findTable("orders"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then return row; end
            row = enum:next();
        end
        return nil;
    end
    return search;
end

function trading:FindTrade()
    local search = {};
    function search:WhenCustomID(custom_id) self.CustomID = custom_id; return self; end
    function search:WhenSide(bs) self.Side = bs; return self; end
    function search:WhenInstrument(instrument) self.Instrument = instrument; return self; end
    function search:WhenAccountID(account_id) self.AccountID = account_id; return self; end
    function search:WhenOpen(open) self.Open = open; return self; end
    function search:WhenOpenOrderReqID(open_order_req_id) self.OpenOrderReqID = open_order_req_id; return self; end
    function search:Do(action)
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        local count = 0
        while (row ~= nil) do
            if self:PassFilter(row) then
                if action(row) then
                    count = count + 1;
                end
            end
            row = enum:next();
        end
        return count;
    end
    function search:Summ(action)
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        local summ = 0
        while (row ~= nil) do
            if self:PassFilter(row) then
                summ = summ + action(row);
            end
            row = enum:next();
        end
        return summ;
    end
    function search:PassFilter(row)
        return (row.Instrument == self.Instrument or not self.Instrument)
            and (row.BS == self.Side or not self.Side)
            and (row.AccountID == self.AccountID or not self.AccountID)
            and (trading:GetCustomID(row.QTXT) == self.CustomID or not self.CustomID)
            and (row.Open == self.Open or not self.Open)
            and (row.OpenOrderReqID == self.OpenOrderReqID or not self.OpenOrderReqID);
    end
    function search:All()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        local trades = {};
        while (row ~= nil) do
            if self:PassFilter(row) then trades[#trades + 1] = row; end
            row = enum:next();
        end
        return trades;
    end
    function search:Any()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then 
                return true;
            end
            row = enum:next();
        end
        return false;
    end
    function search:Count()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        local count = 0;
        while (row ~= nil) do
            if self:PassFilter(row) then count = count + 1; end
            row = enum:next();
        end
        return count;
    end
    function search:First()
        local enum = core.host:findTable("trades"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then return row; end
            row = enum:next();
        end
        return nil;
    end
    return search;
end

function trading:FindClosedTrade()
    local search = {};
    function search:WhenCustomID(custom_id) self.CustomID = custom_id; return self; end
    function search:WhenSide(bs) self.Side = bs; return self; end
    function search:WhenInstrument(instrument) self.Instrument = instrument; return self; end
    function search:WhenAccountID(account_id) self.AccountID = account_id; return self; end
    function search:WhenOpenOrderReqID(open_order_req_id) self.OpenOrderReqID = open_order_req_id; return self; end
    function search:WhenTradeIDRemain(trade_id_remain) self.TradeIDRemain = trade_id_remain; return self; end
    function search:WhenCloseOrderID(close_order_id) self.CloseOrderID = close_order_id; return self; end
    function search:PassFilter(row)
        if self.TradeIDRemain ~= nil and row.TradeIDRemain ~= self.TradeIDRemain then return false; end
        if self.CloseOrderID ~= nil and row.CloseOrderID ~= self.CloseOrderID then return false; end
        return (row.Instrument == self.Instrument or not self.Instrument)
            and (row.BS == self.Side or not self.Side)
            and (row.AccountID == self.AccountID or not self.AccountID)
            and (trading:GetCustomID(row.QTXT) == self.CustomID or not self.CustomID)
            and (row.OpenOrderReqID == self.OpenOrderReqID or not self.OpenOrderReqID);
    end
    function search:Do(action)
        local enum = core.host:findTable("closed trades"):enumerator();
        local row = enum:next();
        local count = 0
        while (row ~= nil) do
            if self:PassFilter(row) then
                if action(row) then
                    count = count + 1;
                end
            end
            row = enum:next();
        end
        return count;
    end
    function search:Any()
        local enum = core.host:findTable("closed trades"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then
                return true;
            end
            row = enum:next();
        end
        return false;
    end
    function search:All()
        local enum = core.host:findTable("closed trades"):enumerator();
        local row = enum:next();
        local trades = {};
        while (row ~= nil) do
            if self:PassFilter(row) then trades[#trades + 1] = row; end
            row = enum:next();
        end
        return trades;
    end
    function search:First()
        local enum = core.host:findTable("closed trades"):enumerator();
        local row = enum:next();
        while (row ~= nil) do
            if self:PassFilter(row) then return row; end
            row = enum:next();
        end
        return nil;
    end
    return search;
end

function trading:ParialClose(trade, amount)
    -- not finished
    local account = core.host:findTable("accounts"):find("AccountID", trade.AccountID);
    local id = self:getId();
    if account.Hedging == "Y" then
        local valuemap = core.valuemap();
        valuemap.BuySell = trade.BS == "B" and "S" or "B";
        valuemap.OrderType = "CM";
        valuemap.OfferID = trade.OfferID;
        valuemap.AcctID = trade.AccountID;
        valuemap.TradeID = trade.TradeID;
        valuemap.Quantity = math.min(amount, trade.Lot);
        local success, msg = terminal:execute(id, valuemap);
        if success then
            local res = trading:ClosePartialSuccessResult(msg);
            self._waiting_requests[id] = res;
            return res;
        end
        return trading:ClosePartialFailResult(msg);
    end

    local valuemap = core.valuemap();
    valuemap.OrderType = "OM";
    valuemap.OfferID = trade.OfferID;
    valuemap.AcctID = trade.AccountID;
    valuemap.Quantity = math.min(amount, trade.Lot);
    valuemap.BuySell = trading:getOppositeSide(trade.BS);
    local success, msg = terminal:execute(id, valuemap);
    if success then
        local res = trading:ClosePartialSuccessResult(msg);
        self._waiting_requests[id] = res;
        return res;
    end
    return trading:ClosePartialFailResult(msg);
end

function trading:ClosePartialSuccessResult(msg)
    local res = {};
    if msg ~= nil then res.Finished = false; else res.Finished = true; end
    res.RequestID = msg;
    function res:ToJSON()
        return trading:ObjectToJson(self);
    end
    return res;
end
function trading:ClosePartialFailResult(message)
    local res = {};
    res.Finished = true;
    res.Success = false;
    res.Error = message;
    return res;
end

function trading:Close(trade)
    local valuemap = core.valuemap();
    valuemap.BuySell = trade.BS == "B" and "S" or "B";
    valuemap.OrderType = "CM";
    valuemap.OfferID = trade.OfferID;
    valuemap.AcctID = trade.AccountID;
    valuemap.TradeID = trade.TradeID;
    valuemap.Quantity = trade.Lot;
    local success, msg = terminal:execute(self._ids_start + 3, valuemap);
    if not(success) then
        if self._signaler ~= nil then self._signaler:Signal("Close failed: " .. msg); end
        return false;
    end

    return true;
end

function trading:ObjectToJson(obj)
    local json = {};
    function json:AddStr(name, value)
        local separator = "";
        if self.str ~= nil then separator = ","; else self.str = ""; end
        self.str = self.str .. string.format("%s\"%s\":\"%s\"", separator, tostring(name), tostring(value));
    end
    function json:AddNumber(name, value)
        local separator = "";
        if self.str ~= nil then separator = ","; else self.str = ""; end
        self.str = self.str .. string.format("%s\"%s\":%f", separator, tostring(name), value or 0);
    end
    function json:AddBool(name, value)
        local separator = "";
        if self.str ~= nil then separator = ","; else self.str = ""; end
        self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), value and "true" or "false");
    end
    function json:AddTable(name, value)
        local str = trading:ObjectToJson(value);
        local separator = "";
        if self.str ~= nil then separator = ","; else self.str = ""; end
        self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), tostring(str));
    end
    function json:ToString() return "{" .. (self.str or "") .. "}"; end
    
    local first = true;
    for idx,t in pairs(obj) do
        local stype = type(t)
        if stype == "number" then json:AddNumber(idx, t);
        elseif stype == "string" then json:AddStr(idx, t);
        elseif stype == "boolean" then json:AddBool(idx, t);
        elseif stype == "function" then --do nothing
        elseif stype == "table" then json:AddTable(idx, t);
        else core.host:trace(tostring(idx) .. " " .. tostring(stype));
        end
    end
    return json:ToString();
end

function trading:CreateEntryOrderSuccessResult(msg)
    local res = {};
    if msg ~= nil then res.Finished = false; else res.Finished = true; end
    res.RequestID = msg;
    function res:IsOrderExecuted()
        return self.FixStatus ~= nil and self.FixStatus == "F";
    end
    function res:GetOrder()
        if self._order == nil then
            self._order = core.host:findTable("orders"):find("RequestID", self.RequestID);
            if self._order == nil then return nil; end
        end
        if not self._order:refresh() then return nil; end
        return self._order;
    end
    function res:GetTrade()
        if self._trade == nil then
            self._trade = core.host:findTable("trades"):find("OpenOrderReqID", self.RequestID);
            if self._trade == nil then return nil; end
        end
        if not self._trade:refresh() then return nil; end
        return self._trade;
    end
    function res:GetClosedTrade()
        if self._closed_trade == nil then
            self._closed_trade = core.host:findTable("closed trades"):find("OpenOrderReqID", self.RequestID);
            if self._closed_trade == nil then return nil; end
        end
        if not self._closed_trade:refresh() then return nil; end
        return self._closed_trade;
    end
    function res:ToJSON()
        return trading:ObjectToJson(self);
    end
    return res;
end
function trading:CreateEntryOrderFailResult(message)
    local res = {};
    res.Finished = true;
    res.Success = false;
    res.Error = message;
    function res:GetOrder() return nil; end
    function res:GetTrade() return nil; end
    function res:GetClosedTrade() return nil; end
    function res:IsOrderExecuted() return false; end
    return res;
end

function trading:EntryOrder(instrument)
    local builder = {};
    builder.Offer = core.host:findTable("offers"):find("Instrument", instrument);
    builder.Instrument = instrument;
    builder.Parent = self;
    builder.valuemap = core.valuemap();
    builder.valuemap.Command = "CreateOrder";
    builder.valuemap.OfferID = builder.Offer.OfferID;
    builder.valuemap.AcctID = self._account;
    function builder:_GetBaseUnitSize() if self._base_size == nil then self._base_size = core.host:execute("getTradingProperty", "baseUnitSize", self.Instrument, self.valuemap.AcctID); end return self._base_size; end

    function builder:SetAccountID(accountID) self.valuemap.AcctID = accountID; return self; end
    function builder:SetAmount(amount) self.amount = amount; return self; end
    function builder:SetRiskPercentOfEquityAmount(percent) self._RiskPercentOfEquityAmount = percent; return self; end
    function builder:SetPercentOfEquityAmount(percent) self._PercentOfEquityAmount = percent; return self; end
    function builder:UpdateOrderType()
        if self.valuemap.BuySell == nil or self.valuemap.Rate == nil then
            return;
        end
        if self.valuemap.BuySell == "B" then 
            self.valuemap.OrderType = self.Offer.Ask > self.valuemap.Rate and "LE" or "SE"; 
        else 
            self.valuemap.OrderType = self.Offer.Bid > self.valuemap.Rate and "SE" or "LE"; 
        end 
    end
    function builder:SetSide(buy_sell) 
        self.valuemap.BuySell = buy_sell; 
        self:UpdateOrderType();
        return self; 
    end
    function builder:SetRate(rate) 
        self.valuemap.Rate = rate; 
        self:UpdateOrderType();
        return self; 
    end
    function builder:SetPipLimit(limit_type, limit) self.valuemap.PegTypeLimit = limit_type or "M"; self.valuemap.PegPriceOffsetPipsLimit = self.valuemap.BuySell == "B" and limit or -limit; return self; end
    function builder:SetLimit(limit) self.valuemap.RateLimit = limit; return self; end
    function builder:SetPipStop(stop_type, stop, trailing_stop) self.valuemap.PegTypeStop = stop_type or "O"; self.valuemap.PegPriceOffsetPipsStop = self.valuemap.BuySell == "B" and -stop or stop; self.valuemap.TrailStepStop = trailing_stop; return self; end
    function builder:SetStop(stop, trailing_stop) self.valuemap.RateStop = stop; self.valuemap.TrailStepStop = trailing_stop; return self; end
    function builder:UseDefaultCustomId() self.valuemap.CustomID = self.Parent.CustomID; return self; end
    function builder:SetCustomID(custom_id) self.valuemap.CustomID = custom_id; return self; end
    function builder:GetValueMap() return self.valuemap; end
    function builder:AddMetadata(id, val) if self._metadata == nil then self._metadata = {}; end self._metadata[id] = val; return self; end
    function builder:BuildValueMap()
        self.valuemap.Quantity = self.amount * self:_GetBaseUnitSize();
        if self._metadata ~= nil then
            self._metadata.CustomID = self.valuemap.CustomID;
            self.valuemap.CustomID = trading:ObjectToJson(self._metadata);
        end
        if self._PercentOfEquityAmount ~= nil then
            local equity = core.host:findTable("accounts"):find("AccountID", self.valuemap.AcctID).Equity;
            local used_equity = equity * self._PercentOfEquityAmount / 100.0;
            local emr = core.host:getTradingProperty("EMR", self.Offer.Instrument, self.valuemap.AcctID);
            self.valuemap.Quantity = math.floor(used_equity / emr) * self:_GetBaseUnitSize();
        elseif self._RiskPercentOfEquityAmount ~= nil then
            local equity = core.host:findTable("accounts"):find("AccountID", self.valuemap.AcctID).Equity;
            local affordable_loss = equity * self._RiskPercentOfEquityAmount / 100.0;
            assert(self.valuemap.RateStop ~= nil, "Only absolute stop is supported");
            local stop = math.abs(self.valuemap.RateStop - self.valuemap.Rate) / self.Offer.PointSize;
            local possible_loss = self.Offer.PipCost * stop;
            self.valuemap.Quantity = math.floor(affordable_loss / possible_loss) * self:_GetBaseUnitSize();
        end
        return self.valuemap;
    end
    function builder:Execute()
        self:BuildValueMap();
        local id = self.Parent:getId();
        local success, msg = terminal:execute(id, self.valuemap);
        if not(success) then
            local message = "Open order failed: " .. msg;
            self.Parent:trace(message);
            if self.Parent._signaler ~= nil then self.Parent._signaler:Signal(message); end
            return trading:CreateEntryOrderFailResult(message);
        end
        local res = trading:CreateEntryOrderSuccessResult(msg);
        self.Parent._waiting_requests[id] = res;
        return res;
    end
    return builder;
end

function trading:StoreMarketOrderResults(res)
    local str = "[";
    for i, t in ipairs(res) do
        local json = t:ToJSON();
        if str == "[" then str = str .. json; else str = str .. "," .. json; end
    end
    return str .. "]";
end
function trading:RestoreMarketOrderResults(str)
    local results = {};
    local position = 2;
    local result;
    while (position < str:len()) do
        local ch = string.sub(str, position, position);
        if ch == "{" then
            result = trading:CreateMarketOrderSuccessResult();
            position = position + 1;
        elseif ch == "}" then
            results[#results + 1] = result;
            result = nil;
            position = position + 1;
        elseif ch == "," then
            position = position + 1;
        else
            local name, value = string.match(str, '"([^"]+)":("?[^,}]+"?)', position);
            if value == "false" then
                result[name] = false;
                position = position + name:len() + 8;
            elseif value == "true" then
                result[name] = true;
                position = position + name:len() + 7;
            else
                if string.sub(value, 1, 1) == "\"" then
                    result[name] = value;
                    value:sub(2, value:len() - 1);
                    position = position + name:len() + 3 + value:len();
                else
                    result[name] = tonumber(value);
                    position = position + name:len() + 3 + value:len();
                end
            end
        end
    end
    return results;
end
function trading:CreateMarketOrderSuccessResult(msg)
    local res = {};
    if msg ~= nil then res.Finished = false; else res.Finished = true; end
    res.RequestID = msg;
    function res:GetTrade()
        if self._trade == nil then
            self._trade = core.host:findTable("trades"):find("OpenOrderReqID", self.RequestID);
            if self._trade == nil then return nil; end
        end
        if not self._trade:refresh() then return nil; end
        return self._trade;
    end
    function res:GetClosedTrade()
        if self._closed_trade == nil then
            self._closed_trade = core.host:findTable("closed trades"):find("OpenOrderReqID", self.RequestID);
            if self._closed_trade == nil then return nil; end
        end
        if not self._closed_trade:refresh() then return nil; end
        return self._closed_trade;
    end
    function res:ToJSON()
        local json = {};
        function json:AddStr(name, value)
            local separator = "";
            if self.str ~= nil then separator = ","; else self.str = ""; end
            self.str = self.str .. string.format("%s\"%s\":\"%s\"", separator, tostring(name), tostring(value));
        end
        function json:AddNumber(name, value)
            local separator = "";
            if self.str ~= nil then separator = ","; else self.str = ""; end
            self.str = self.str .. string.format("%s\"%s\":%f", separator, tostring(name), value or 0);
        end
        function json:AddBool(name, value)
            local separator = "";
            if self.str ~= nil then separator = ","; else self.str = ""; end
            self.str = self.str .. string.format("%s\"%s\":%s", separator, tostring(name), value and "true" or "false");
        end
        function json:ToString() return "{" .. (self.str or "") .. "}"; end
        
        local first = true;
        for idx,t in pairs(self) do
            local stype = type(t)
            if stype == "number" then json:AddNumber(idx, t);
            elseif stype == "string" then json:AddStr(idx, t);
            elseif stype == "boolean" then json:AddBool(idx, t);
            elseif stype == "function" or stype == "table" then --do nothing
            else core.host:trace(tostring(idx) .. " " .. tostring(stype));
            end
        end
        return json:ToString();
    end
    return res;
end
function trading:CreateMarketOrderFailResult(message)
    local res = {};
    res.Finished = true;
    res.Success = false;
    res.Error = message;
    function res:GetTrade() return nil; end
    return res;
end

function trading:MarketOrder(instrument)
    local builder = {};
    local offer = core.host:findTable("offers"):find("Instrument", instrument);
    builder.Instrument = instrument;
    builder.Offer = offer;
    builder.Parent = self;
    builder.valuemap = core.valuemap();
    builder.valuemap.Command = "CreateOrder";
    builder.valuemap.OrderType = "OM";
    builder.valuemap.OfferID = offer.OfferID;
    builder.valuemap.AcctID = self._account;
    function builder:_GetBaseUnitSize() if self._base_size == nil then self._base_size = core.host:execute("getTradingProperty", "baseUnitSize", self.Instrument, self.valuemap.AcctID); end return self._base_size; end
    function builder:SetAccountID(accountID) self.valuemap.AcctID = accountID; return self; end
    function builder:SetAmount(amount) self._amount = amount; return self; end
    function builder:SetRiskPercentOfEquityAmount(percent) self._RiskPercentOfEquityAmount = percent; return self; end
    function builder:SetPercentOfEquityAmount(percent) self._PercentOfEquityAmount = percent; return self; end
    function builder:SetSide(buy_sell) self.valuemap.BuySell = buy_sell; return self; end
    function builder:SetPipLimit(limit_type, limit)
        self.valuemap.PegTypeLimit = limit_type or "O";
        self.valuemap.PegPriceOffsetPipsLimit = self.valuemap.BuySell == "B" and limit or -limit;
        return self;
    end
    function builder:SetLimit(limit) self.valuemap.RateLimit = limit; return self; end
    function builder:SetPipStop(stop_type, stop, trailing_stop)
        self.valuemap.PegTypeStop = stop_type or "O";
        self.valuemap.PegPriceOffsetPipsStop = self.valuemap.BuySell == "B" and -stop or stop;
        self.valuemap.TrailStepStop = trailing_stop;
        return self;
    end
    function builder:SetStop(stop, trailing_stop) self.valuemap.RateStop = stop; self.valuemap.TrailStepStop = trailing_stop; return self; end
    function builder:SetCustomID(custom_id) self.valuemap.CustomID = custom_id; return self; end
    function builder:GetValueMap() return self.valuemap; end
    function builder:AddMetadata(id, val) if self._metadata == nil then self._metadata = {}; end self._metadata[id] = val; return self; end
    function builder:FillFields()
        local base_size = self:_GetBaseUnitSize();
        if self._metadata ~= nil then
            self._metadata.CustomID = self.valuemap.CustomID;
            self.valuemap.CustomID = trading:ObjectToJson(self._metadata);
        end
        if self._PercentOfEquityAmount ~= nil then
            local equity = core.host:findTable("accounts"):find("AccountID", self.valuemap.AcctID).Equity;
            local used_equity = equity * self._PercentOfEquityAmount / 100.0;
            local emr = core.host:getTradingProperty("EMR", self.Offer.Instrument, self.valuemap.AcctID);
            self.valuemap.Quantity = math.floor(used_equity / emr) * base_size;
            core.host:trace(used_equity / emr);
        elseif self._RiskPercentOfEquityAmount ~= nil then
            local equity = core.host:findTable("accounts"):find("AccountID", self.valuemap.AcctID).Equity;
            local affordable_loss = equity * self._RiskPercentOfEquityAmount / 100.0;
            assert(self.valuemap.PegPriceOffsetPipsStop ~= nil, "Only pip stop are supported");
            local possible_loss = self.Offer.PipCost * self.valuemap.PegPriceOffsetPipsStop;
            self.valuemap.Quantity = math.floor(affordable_loss / possible_loss) * base_size;
        else
            self.valuemap.Quantity = self._amount * base_size;
        end
    end
    function builder:Execute()
        self.Parent:trace(string.format("Creating %s OM for %s", self.valuemap.BuySell, self.Instrument));
        self:FillFields();
        local id = self.Parent:getId();
        local success, msg = terminal:execute(id, self.valuemap);
        if not(success) then
            local message = "Open order failed: " .. msg;
            self.Parent:trace(message);
            if self.Parent._signaler ~= nil then
                self.Parent._signaler:Signal(message);
            end
            return trading:CreateMarketOrderFailResult(message);
        end
        local res = trading:CreateMarketOrderSuccessResult(msg);
        self.Parent._waiting_requests[id] = res;
        return res;
    end
    return builder;
end

function trading:ReadValue(json, position)
    local whaitFor = "";
    local start = position;
    while (position < json:len() + 1) do
        local ch = string.sub(json, position, position);
        position = position + 1;
        if ch == "\"" then
            start = position - 1;
            whaitFor = ch;
            break;
        elseif ch == "{" then
            start = position - 1;
            whaitFor = "}";
            break;
        elseif ch == "," or ch == "}" then
            return string.sub(json, start, position - 2), position - 1;
        end
    end
    while (position < json:len() + 1) do
        local ch = string.sub(json, position, position);
        position = position + 1;
        if ch == whaitFor then
            return string.sub(json, start, position - 1), position;
        end
    end
    return "", position;
end
function trading:JsonToObject(json)
    local position = 1;
    local result;
    local results;
    while (position < json:len() + 1) do
        local ch = string.sub(json, position, position);
        if ch == "{" then
            result = {};
            position = position + 1;
        elseif ch == "}" then
            if results ~= nil then
                position = position + 1;
                results[#results + 1] = result;
            else
                return result;
            end
        elseif ch == "," then
            position = position + 1;
        elseif ch == "[" then
            position = position + 1;
            results = {};
        elseif ch == "]" then
            return results;
        else
            if result == nil then
                return nil;
            end
            local name = string.match(json, '"([^"]+)":', position);
            local value, new_pos = trading:ReadValue(json, position + name:len() + 3);
            position = new_pos;
            if value == "false" then
                result[name] = false;
            elseif value == "true" then
                result[name] = true;
            else
                if string.sub(value, 1, 1) == "\"" then
                    result[name] = value:sub(2, value:len() - 1);
                elseif string.sub(value, 1, 1) == "{" then
                    result[name] = trading:JsonToObject(value);
                else
                    result[name] = tonumber(value);
                end
            end
        end
    end
    return nil;
end

function trading:GetMetadata(qtxt)
    if qtxt == "" then
        return nil;
    end
    local position = 1;
    local result;
    while (position < qtxt:len() + 1) do
        local ch = string.sub(qtxt, position, position);
        if ch == "{" then
            result = {};
            position = position + 1;
        elseif ch == "}" then
            return result;
        elseif ch == "," then
            position = position + 1;
        else
            if result == nil then
                return nil;
            end
            local name, value = string.match(qtxt, '"([^"]+)":("?[^,}]+"?)', position);
            if value == "false" then
                result[name] = false;
                position = position + name:len() + 8;
            elseif value == "true" then
                result[name] = true;
                position = position + name:len() + 7;
            else
                if string.sub(value, 1, 1) == "\"" then
                    result[name] = value;
                    value:sub(2, value:len() - 1);
                    position = position + name:len() + 3 + value:len();
                else
                    result[name] = tonumber(value);
                    position = position + name:len() + 3 + value:len();
                end
            end
        end
    end
    return nil;
end

function trading:GetTradeMetadata(trade)
    return self:GetMetadata(trade.QTXT);
end
trading:RegisterModule(Modules);
