-- Id: 17297
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
    strategy:name("Highly Adaptable Pivot Strategy with MA Cross/Position Filter");
    strategy:description("");
	
strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");
	
	strategy.parameters:addGroup("Price");
    strategy.parameters:addString("Type", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
	
    strategy.parameters:addGroup("Strategy Parameters");
	strategy.parameters:addString("TF", "Strategy Time frame", "", "m5");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);
    strategy.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish strategy instances", "HAPSWCPF");

	strategy.parameters:addGroup("Pivot");
	strategy.parameters:addString("PivotTF", "Pivot Time frame", "", "D1");
    strategy.parameters:setFlag("PivotTF", core.FLAG_PERIODS);
    strategy.parameters:addString("CalcMode", "Calculation mode", "The mode of pivot calculation.", "Pivot");
    strategy.parameters:addStringAlternative("CalcMode", "Classic Pivot", "", "Pivot");
    strategy.parameters:addStringAlternative("CalcMode", "Camarilla", "", "Camarilla");
    strategy.parameters:addStringAlternative("CalcMode", "Woodie", "", "Woodie");
    strategy.parameters:addStringAlternative("CalcMode", "Fibonacci", "", "Fibonacci");
    strategy.parameters:addStringAlternative("CalcMode", "Floor", "", "Floor");
    strategy.parameters:addStringAlternative("CalcMode", "Fibonacci Retracement", "", "FibonacciR");
	
	strategy.parameters:addGroup("MA Filter");
	strategy.parameters:addBoolean("Filter1", "MA Cross Filter", "", false);
	strategy.parameters:addBoolean("Filter2", "MA Position Filter", "", false);
	strategy.parameters:addInteger("Period", "MA Period", "Period" , 14);
	strategy.parameters:addString("Method", "MA Method", "Method" , "MVA");
    strategy.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    strategy.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    strategy.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    strategy.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    strategy.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    strategy.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    strategy.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    strategy.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");

	strategy.parameters:addGroup("Actions");
    AddLevel(1, "R4");
    AddLevel(2, "MR34");
    AddLevel(3, "R3");
    AddLevel(4, "MR23");
    AddLevel(5, "R2");
    AddLevel(6, "MR12");
    AddLevel(7, "R1");
    AddLevel(8, "MR01");
    AddLevel(9, "P");
    AddLevel(10, "MS01");
    AddLevel(11, "S1");
    AddLevel(12, "MS12");
    AddLevel(13, "S2");
    AddLevel(14, "MS23");
    AddLevel(15, "S3");
    AddLevel(16, "MS34");
    AddLevel(17, "S4");

    CreateTradingParameters();
end


function AddLevel(Number, Desc) 
	strategy.parameters:addString("Action".. Number, Desc .. " Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. Number, "No Action", "", "NO");
    strategy.parameters:addStringAlternative("Action".. Number, "Sell", "", "SELL");
	strategy.parameters:addStringAlternative("Action".. Number, "Buy", "", "BUY");
	strategy.parameters:addStringAlternative("Action".. Number, "Close Position", "", "CLOSE");
	strategy.parameters:addStringAlternative("Action".. Number, "Alert", "", "Alert");
	strategy.parameters:addDouble("Pips".. Number, Desc .. " Pips", "", 0, -1000.0, 1000.0);
end

function CreateTradingParameters()
    strategy.parameters:addGroup("Trading Parameters");

    strategy.parameters:addBoolean("AllowTrade", "Allow strategy to trade", "", false);
    strategy.parameters:setFlag("AllowTrade", core.FLAG_ALLOW_TRADE);
    strategy.parameters:addString("ALLOWEDSIDE", "Allowed side", "Allowed side for trading or signaling, can be Sell, Buy or Both", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Buy", "", "Buy");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Sell", "", "Sell");

    strategy.parameters:addBoolean("AllowMultiple", "Allow Multiple", "Should we allow multiple positions in the same direction.", true);
    strategy.parameters:addInteger("MultipleLimit", "Open Position Limit", "The number of open positions in the same direction allowed for each instance of this strategy. Zero for unlimited.", 0, 0, 1000);
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

local TriggerSource, PivotSource;

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
local SetLimit;
local Limit;
local SetStop;
local Stop;
local TrailingStop;
local ShowAlert;
local Email;
local SendEmail;
local BaseSize;
local PipSize;

local Action={};
local Pips={};
local CustomID;
local CalcMode;
local O_PIVOT = 1;
local O_CAM = 2;
local O_WOOD = 3;
local O_FIB = 4;
local O_FLOOR = 5;
local O_FIBR = 6;

local PeriodDate;
local P;
local S1;
local S2;
local S3;
local S4;
local R1;
local R2;
local R3;
local MA, Period, Method, Filter1, Filter2;
local stream;
function Prepare( nameOnly)
    CustomID = instance.parameters.CustomID;

    if instance.parameters.CalcMode == "Pivot" then
        CalcMode = O_PIVOT;
    elseif instance.parameters.CalcMode == "Camarilla" then
        CalcMode = O_CAM;
    elseif instance.parameters.CalcMode == "Woodie" then
        CalcMode = O_WOOD;
    elseif instance.parameters.CalcMode == "Fibonacci" then
        CalcMode = O_FIB;
    elseif instance.parameters.CalcMode == "Floor" then
        CalcMode = O_FLOOR;
    elseif instance.parameters.CalcMode == "FibonacciR" then
        CalcMode = O_FIBR;
    else
        assert(false, "Unknown calculation mode: " .. instance.parameters.CalcMode);
    end
	
	
	Period=instance.parameters.Period;
	Method=instance.parameters.Method;
	Filter1=instance.parameters.Filter1;
	Filter2=instance.parameters.Filter2;
	


    assert(instance.parameters.PivotTF ~= "t1", "The pivot time frame must not be tick");

    local name = profile:id() .. "( " .. instance.bid:name() .. "," .. instance.parameters.CalcMode .. "," .. CustomID .. "," ..  " )";
    instance:name(name);

    PrepareTrading();

    if nameOnly then
        return ;
    end

    PivotSource = ExtSubscribe(1, nil, instance.parameters.PivotTF, instance.parameters.Type == "Bid", "bar");
    PipSize = PivotSource.close:pipSize();
    if (instance.parameters.TF == "t1") then
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	     MA = core.indicators:create(Method, TriggerSource, Period);
        TriggerSource = ExtSubscribe(2, nil, "t1", instance.parameters.Type == "Bid", "close");
    else
        TriggerSource = ExtSubscribe(2, nil, instance.parameters.TF, instance.parameters.Type == "Bid", "bar");
		 MA = core.indicators:create(Method, TriggerSource.close, Period);
    end
	
 

	local i = 1;
    while (i <= 17) do
        Pips[i] = instance.parameters:getDouble("Pips" .. i) * PipSize;
        Action[i]= instance.parameters:getString("Action" .. i);
        i = i + 1;
	end
end

function UpdateStream(period)
    CalcLevels(PivotSource, period);
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
    SetLimit = instance.parameters.SetLimit;
    Limit = instance.parameters.Limit;
    SetStop = instance.parameters.SetStop;
    Stop = instance.parameters.Stop;
    TrailingStop = instance.parameters.TrailingStop;
end

function ExtUpdate(id, source, period)  -- The method called every time when a new bid or ask price appears.
    if AllowTrade then
        if not(checkReady("trades")) or not(checkReady("orders")) then
            return ;
        end
    end
	
	 if Filter1 or Filter2 then
			 MA:update(core.UpdateLast);
			 if period < MA.DATA:first() then
			 return
			 end
	end

    if (id == 1) then
        -- pivot source so calculate pivot levels.
        CalcLevels(PivotSource, period);

    elseif (id == 2) then
        -- trigger source so check the actions
        if (INDEX == nil) then
            return;
        end

        if (TriggerSource:isBar()) then
            stream = TriggerSource.close;
        else
            stream = TriggerSource;
        end
		

        if core.crosses(stream, R4, period) then	
            ACTION(1, "R4", period);								
        end

        if core.crosses(stream, MR34, period) then
            ACTION(2, "MR34", period);								
        end

        if core.crosses(stream, R3, period) then
            ACTION(3, "R3", period);								
        end

        if core.crosses(stream, MR23, period) then
            ACTION(4, "MR23", period);								
        end

        if core.crosses(stream, R2, period) then
            ACTION(5, "R2", period);								
        end

        if core.crosses(stream, MR12, period) then
            ACTION(6, "MR12", period);								
        end

        if core.crosses(stream, R1, period) then
            ACTION(7, "R1", period);								
        end

        if core.crosses(stream, MR01, period) then
            ACTION(8, "MR01", period);								
        end
   
        -- pivot line so check for cross.
        if core.crosses(stream, P, period) then
            ACTION(9, "P", period);								
        end

        if core.crosses(stream, MS01, period) then
            ACTION(10, "MS01", period);								
        end

        if core.crosses(stream, S1, period) then		
            ACTION(11, "S1", period);								
        end

        if core.crosses(stream, MS12, period) then
            ACTION(12, "MS12", period);								
        end

        if core.crosses(stream, S2, period) then
            ACTION(13, "S2", period);								
        end

        if core.crosses(stream, MS23, period) then
            ACTION(14, "MS23", period);								
        end

        if core.crosses(stream, S3, period) then
            ACTION(15, "S3", period);								
        end

        if core.crosses(stream, MS34, period) then
            ACTION(16, "MS34", period);								
        end

        if core.crosses(stream, S4, period) then
            ACTION(17, "S4", period);								
        end
    else
        -- unknown source.
        return;
    end
end

function CalcLevels(ref, period)
    if (period - 1 < ref:first()) then
        -- not enough data
        return;
    end

    if (ref:serial(period) == INDEX) then
        -- already calculated;
        return;
    end

    -- if we are daily or less, ignore saturdays.
    if (ref:barSize() ~= "M1" and ref:barSize() ~= "W1") then
        local theDate = core.dateToTable(ref:date(period));
        if (theDate.wday == 7) then
            -- need to ignore saturday's or it messes up the pivots.
            return;
        end
    end

    local prev_i = period;
    INDEX = ref:serial(period);

    -- calculate the pivot level
    if CalcMode == O_PIVOT or CalcMode == O_FIB or CalcMode == O_FLOOR then
        P = (ref.high[prev_i] + ref.close[prev_i] + ref.low[prev_i]) / 3;
    elseif CalcMode == O_CAM then
        -- P[period] = (ref.high[prev_i] + ref.close[prev_i] + ref.low[prev_i]) / 3;
        P = ref.close[prev_i];
    elseif CalcMode == O_FIBR then
        P = (ref.high[prev_i] + ref.low[prev_i]) / 2;
    elseif CalcMode == O_WOOD then
        local open;
        if (prev_i == ref:size() - 1) then
            -- for a live day take close as open of the next period
            open = ref.open[prev_i];
        else
            open = ref.open[prev_i + 1];
        end
        P = (ref.high[prev_i] + ref.low[prev_i] + open * 2 ) / 4;
    end

    local h, l, r, p;
    h = ref.high[prev_i];
    l = ref.low[prev_i];
    r = h - l;
    p = P;

    -- calculate the other levels
    if CalcMode == O_PIVOT then
        R4 = p + r * 3;
        R3 = p + r * 2;
        R2 = p + r;
        R1 = p * 2 - l;

        S1 = p * 2 - h;
        S2 = p - r;
        S3 = p - r * 2;
        S4 = p - r * 3;
    elseif CalcMode == O_CAM then
        R4 = p + r * 1.1 / 2;
        R3 = p + r * 1.1 / 4;
        R2 = p + r * 1.1 / 6;
        R1 = p + r * 1.1 / 12;

        S1 = p - r * 1.1 / 12;
        S2 = p - r * 1.1 / 6;
        S3 = p - r * 1.1 / 4;
        S4 = p - r * 1.1 / 2;
    elseif CalcMode == O_WOOD then
        R4 = h + (2 * (p - l) + r);
        R3 = h + 2 * (p - l);
        R2 = p + r;
        R1 = p * 2 - l;

        S1 = p * 2 - h;
        S2 = p - r;
        S3 = l - 2 * (h - p);
        S4 = l - (r + 2 * (h - p));
    elseif CalcMode == O_FIB then
        R4 = p + 1.618 * (h - l);
        R3 = p + 1 * (h - l);
        R2 = p + 0.618 * (h - l);
        R1 = p + 0.382 * (h - l);

        S1 = p - 0.382 * (h - l);
        S2 = p - 0.618 * (h - l);
        S3 = p - 1 * (h - l);
        S4 = p - 1.618 * (h - l);
    elseif CalcMode == O_FLOOR then
        R4 = 0;
        R3 = h + (p - l) * 2;
        R2 = p + r;
        R1 = p * 2 - l;

        S1 = p * 2 - h;
        S2 = p - r;
        S3 = l - (h - p) * 2;
        S4 = 0;
    elseif CalcMode == O_FIBR then
        R4 = l + (h - l) * 1.272;
        R3 = l + (h - l) * 1.0;
        R2 = l + (h - l) * 0.764;
        R1 = l + (h - l) * 0.618;

        S1 = l + (h - l) * 0.382;
        S2 = l + (h - l) * 0.236;
        S3 = l + (h - l) * 0.0;
        S4 = l + (h - l) * -0.272;
    end

    -- calculate mid points
    MR01 = 0.5 * (P + R1);
    MR12 = 0.5 * (R1 + R2);
    MR23 = 0.5 * (R2 + R3);
    MR34 = 0.5 * (R3 + R4);
    MS01 = 0.5 * (P + S1);
    MS12 = 0.5 * (S1 + S2);
    MS23 = 0.5 * (S2 + S3);
    MS34 = 0.5 * (S3 + S4);

    -- apply pip modifications
    R4 = R4 + Pips[1];
    MR34 = MR34 + Pips[2];
    R3 = R3 + Pips[3];
    MR23 = MR23 + Pips[4];
    R2 = R2 + Pips[5];
    MR12 = MR12 + Pips[6];
    R1 = R1 + Pips[7];
    MR01 = MR01 + Pips[8];
    P = P + Pips[9];
    MS01 = MS01 + Pips[10];
    S1 = S1 + Pips[11];
    MS12 = MS12 + Pips[12];
    S2 = S2 + Pips[13];
    MS23 = MS23 + Pips[14];
    S3 = S3 + Pips[15];
    MS34 = MS34 + Pips[16];
    S4 = S4 + Pips[17];


end

-- NG: Introduce async function for timer/monitoring for the order results
function ExtAsyncOperationFinished(cookie, success, message)
    if cookie == 200 and not success then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Open order failed" .. message, instance.bid:date(instance.bid:size() - 1));
    elseif cookie == 201 and not success then
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Close order failed" .. message, instance.bid:date(instance.bid:size() - 1));
    end
end

function ACTION (Flag, Line, period)

        if Filter1 and not core.crosses (stream, MA.DATA, period ) then
		return
		end
		


    if Action[Flag] ==  "NO" then
        return;	
							
    elseif Action[Flag] ==  "BUY" then
	
	
	    if Filter2 and stream[period] <  MA.DATA[period]  then
		return
		end
	
	  
	  if AllowTrade then		
        BUY();
        Signal ("Pivot Level " .. Line .. " Crossed - Buy"); 
      else
	   Signal ("Pivot Level " .. Line .. " Crossed - Buy");
	  end
    elseif Action[Flag] ==  "SELL" then
	
	    if Filter2 and stream[period] >  MA.DATA[period]  then
		return
		end
		
		
        if AllowTrade then		 
		SELL();
        Signal ("Pivot Level " .. Line .. " Crossed - Sell");
        else
		 Signal ("Pivot Level " .. Line .. " Crossed - Sell");
		end
    elseif Action[Flag] ==  "CLOSE" then
        if AllowTrade then
            if haveTrades("B") then
                exitTrade("B");
                Signal ("Pivot Level " .. Line .. " Crossed - Close Long");
            end							

            if haveTrades("S") then
                exitTrade("S");
                Signal ("Pivot Level " .. Line .. " Crossed - Close Short");
            end	
        else
            Signal ("Pivot Level " .. Line .. " Crossed - Close Trades!");
        end	

    elseif Action[Flag] ==  "Alert" then	
        Signal ("Pivot Level " .. Line .. " Crossed!");
    end
end

-- ---------------------------------------------------------
-- Trace helper function
-- ---------------------------------------------------------
function ExtTrace(message)
    local theDate = core.dateToTable(core.host:execute("convertTime", 1, 4, math.max(instance.bid:date(instance.bid:size() - 1), instance.ask:date(instance.ask:size() - 1))));
    core.host:trace(string.format("%d/%02d/%02d %02d:%02d:%02d ", theDate.year, theDate.month, theDate.day, theDate.hour, theDate.min, theDate.sec) .. " " .. message);
end

--===========================================================================--
--                    TRADING UTILITY FUNCTIONS                              --
--============================================================================--
function BUY()
    if AllowTrade then
        if ALLOWEDSIDE == "Sell"  then
            -- we are not allowed buys.
            return;
        end 

        enter("B");
    end
end   
    
function SELL ()		
    if AllowTrade then
        if ALLOWEDSIDE == "Buy"  then
            -- we are not allowed sells.
            return;
        end

        enter("S");
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
        return true;
    end

    -- do not enter if position in the
    -- specified direction already exists
    local count = tradesCount(BuySell);
    if (AllowMultiple) then
        -- if we allow multiple trades
        if (MultipleLimit > 0 and (count >= MultipleLimit)) then
            -- we have exceeded our multiple limit count.
            return true;
        end
    else
        if count > 0 then
            -- if we have more than one trade and we aren't allowed multiple, abort.
            return true;
        end
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

-- exit from the specified direction
function exitTrade(BS)
    if not(AllowTrade) then
        return true;
    end

    local valuemap, success, msg;
    valuemap = core.valuemap();

    -- switch the direction since the order must be in oppsite direction
    if BS == "B" then
        BuySell = "S";
    else
        BuySell = "B";
    end
    valuemap.OrderType = "CM";
    valuemap.OfferID = Offer;
    valuemap.AcctID = Account;
    valuemap.NetQtyFlag = "Y"; -- this forces all trades to close in the opposite direction.
    valuemap.BuySell = BuySell;
    valuemap.CustomID = CustomID;
    success, msg = terminal:execute(201, valuemap);

    if not(success) then
        core.host:trace("Close order failed" .. msg);
        terminal:alertMessage(instance.bid:instrument(), instance.bid[instance.bid:size() - 1], "Close order failed" .. msg, instance.bid:date(instance.bid:size() - 1));
        return false;
    end

    return true;
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
		
		
		




