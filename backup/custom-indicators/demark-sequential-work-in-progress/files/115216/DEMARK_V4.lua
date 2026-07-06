-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=646

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


--[[
   This indicator is a work in progress.
   It is a collaborative effort being written by users on the FXCodebase.com forum,
   based on chapter 1 of Jason Perl's book 'DeMark Indicators' (Bloomberg 2008).

   All users are welcome to use and modify the code, but please would you be kind enough
   to post your improvements and experiences on the FXCodebase.com forum so that we can
   all benefit from your experience.

   TRADEMARK NOTE:  All the DeMark indicator names consisting of "TD" are registered trademarks.
   Would users modifying the code please be careful to avoid using these trademarks, unless you
   have written permission from Market Studies or Thomas DeMark.
   Our intent is to use the ~logic~ behind Tom DeMark's indicators, not necessarily to exactly
   replicate the real DeMark indicators.

   This is version 1.4
   Version 1.2 was the first shared version.  It contained the 1-9 setup count and setup trend levels.
   Version 1.3 included 'perfected' setup.
   Version 1.4 includes the 1-13 countdown.  A completed buy or sell countdown results in a basic
   buy or sell signal.  The countdown is cancelled if a setup completes in the opposite direction,
   and it starts back at 1 if a new setup completes in the same direction.
]]

function Init()
    indicator:name("DeMark Sequential Indicator");
    indicator:description("Sequential Indicator based on Chapter 1 of Jason Perl's Book 'DeMark Indicators', Bloomberg 2008");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Options");
    indicator.parameters:addBoolean("ShowPerf", "Show Setup Perfection?", "Whether or not to show arrows on perfected setups.", true);
    indicator.parameters:addBoolean("ShowCDown", "Show Countdown", "Whether of not to show the countdown after a setup.", true);
    indicator.parameters:addInteger("Perfection_Wait", "Perfection Wait", "No. of Bars to Keep Looking for Setup Perfection", 13, 0, 300);
    indicator.parameters:addInteger("Lookback", "Setup Look-Back", "No. of Bars to Look Back in Setup Calculations", 4, 1, 25);
    indicator.parameters:addGroup("Refresh parameters");
    indicator.parameters:addInteger("RefreshTime", "Refresh time, in seconds", "Refresh time, in seconds", 10);    
    indicator.parameters:addGroup("Colors");
    indicator.parameters:addColor("BuySU_color", "Buy Setup Color", "Color of Buy Setup Digits and Arrow", core.rgb(0, 127, 0));
    indicator.parameters:addColor("SellSU_color", "Sell Setup Color", "Color of Sell Setup Digits and Arrow", core.rgb(127, 0, 0));
    indicator.parameters:addColor("TrendSup_color", "Color of Trend Support", "Color of Trend Support", core.rgb(100, 220, 120));
    indicator.parameters:addColor("TrendRes_color", "Color of Trend Resistance", "Color of Trend Resistance", core.rgb(220, 100, 120));
    indicator.parameters:addColor("BuyCNT_color", "Color of Buy Countdown", "Color of Buy Countdown", core.rgb(0, 255, 127));
    indicator.parameters:addColor("SellCNT_color", "Color of Sell Countdown", "Color of Sell Countdown", core.rgb(255, 0, 127));
end

-- Parameters block
local first;
local source = nil;
-- Streams block
local BuySU, SellSU = nil, nil;
local bCountdown = 0;
local sCountdown = 0;
local BuyCDTest, SellCDTest = nil, nil;
local TimerID;

-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
    lookback = instance.parameters.Lookback;
    waitlimit = instance.parameters.Perfection_Wait;
    showperf = instance.parameters.ShowPerf;
    showcdown = instance.parameters.ShowCDown;
    BuySUCount, SellSUCount = 0, 0;
    TrendSupVal, TrendResVal = 0, 0;
    Bar67Low, Bar67High = 0, 0;
    SellPerfWaitCount, BuyPerfWaitCount = 0, 0;
    InBuySU, InSellSU = false, false;
    SeekingBuyPerfection, SeekingSellPerfection = false, false;
    InBuyCD, InSellCD = false, false;
    BuyDoppelganger, SellDoppelganger = false, false;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	if   (nameOnly) then
        return;
    end
	
    BuySU = instance:createTextOutput ("BuySU", "Buy Setup 1 to 9", "Arial", 10, core.H_Center, core.V_Bottom, instance.parameters.BuySU_color, 0);
    SellSU = instance:createTextOutput ("SellSU", "Sell Setup 1 to 9", "Arial", 10, core.H_Center, core.V_Top, instance.parameters.SellSU_color, 0);
    TrendSup = instance:addStream ("Sup", core.Line, "Trend Support Line", "Sup", instance.parameters.TrendSup_color, first);
    TrendRes = instance:addStream ("Res", core.Line, "Trend Resistance Line", "Res", instance.parameters.TrendRes_color, first);
    BuyPSU = instance:createTextOutput ("PerfBuySU", "Perfected Buy Setup Arrows", "Wingdings 3", 12, core.H_Center, core.V_Bottom, instance.parameters.BuySU_color, 0);
    SellPSU = instance:createTextOutput ("PerfSellSU", "Perfected Sell Setup Arrows", "Wingdings 3", 12, core.H_Center, core.V_Top, instance.parameters.SellSU_color, 0);
    BuyCNT = instance:createTextOutput ("BuyCD", "Buy Countdown 1 to 13", "Arial", 10, core.H_Center, core.V_Bottom, instance.parameters.BuyCNT_color, 0);
    SellCNT = instance:createTextOutput ("SellCD", "Sell Countdown 1 to 13", "Arial", 10, core.H_Center, core.V_Top, instance.parameters.SellCNT_color, 0);
    BuyCNTS = instance:createTextOutput ("Buy", "Basic Buy Signal", "Wingdings", 14, core.H_Center, core.V_Bottom, instance.parameters.BuyCNT_color, 0);
    SellCNTS = instance:createTextOutput ("Sell", "Basic Sell Signal", "Wingdings", 14, core.H_Center, core.V_Top, instance.parameters.SellCNT_color, 0);

    if instance.parameters.RefreshTime>0 then
        TimerID=core.host:execute("setTimer", 100, instance.parameters.RefreshTime);
    end
end

function AsyncOperationFinished(id, success, msg)
 if id == 100 then
  instance:updateFrom(first);
 end
end

function Update(period)
    if period > lookback and period < source:size() - 1 and source:hasData(period) then
        if InBuySU == true and BuySUCount < 9 then
        -- we're currently in an uncompleted prospective buy setup sequence.
            if source.close[period] < source.close[period - lookback] then
            -- the setup remains intact
                BuySUCount = BuySUCount + 1;
                BuySU:set(period, source.low[period], BuySUCount, "Buy Setup Count 1 to 9");
                if BuySUCount == 9 then
                    -- The buy setup sequence has just completed.
                    InBuySU, InBuyCD = false, true;
                    if InSellCD == true then
                        InSellCD = false;
                        SellCNT:set(period, source.high[period], "X", "Sell Countdown Cancelled");
                    end
                    Bar67Low = math.min(source.low[period - 3], source.low[period - 2]);
                    -- calculate the new Trend Resistance level.
                    TrendResVal = math.max(source.high[period - 8], source.high[period - 7], source.high[period - 6], source.high[period - 5], source.high[period - 4], source.high[period - 3]);
                    -- draw the new Trend Resistance level back to bar #1 of the setup sequence.
                    core.drawLine(TrendRes, core.range(period - 8, period), TrendResVal, period - 8, TrendResVal, period);   
                    -- looking for perfect Setup
                    if showperf == true and  (source.low[period] <= Bar67Low or source.low[period-1] <= Bar67Low) then
                        BuyPSU:set(period, source.low[period], "\010\143", "Perfected Buy Setup");
                        SeekingBuyPerfection = false;
                    elseif showperf == true then
                        SeekingBuyPerfection = true;
                        BuyPerfWaitCount = 0;
                    end
                    -- start countdown?
                    if showcdown == true and source.close[period] <= source.low[period - 2] then
                        bCountdown = 1;
                        BuyCNT:set(period, source.low[period], "\010\010" .. bCountdown, "Buy Countdown 1 to 13");
                        BuyDoppelganger = true;
                    elseif showcdown == true then
                        bCountdown = 0;
                        BuyDoppelganger = false;
                    end
                end
            else
            -- the setup has been broken
                for a = 1, BuySUCount, 1 do
                -- clear away the existing setup numbers
                    BuySU:setNoData(period - a);
                end
                -- reset the buy setup tracking variables
                InBuySU, BuySUCount = false, 0;
            end
        elseif InSellSU == true and SellSUCount < 9 then
        -- we're currently in an uncompleted prospective sell setup sequence.
            if source.close[period] > source.close[period - lookback] then
            -- the setup remains intact
                SellSUCount = SellSUCount + 1;
                SellSU:set(period, source.high[period], SellSUCount, "Sell Setup Count 1 to 9");
                if SellSUCount == 9 then
                    -- The sell setup sequence has just completed.
                    InSellSU, InSellCD = false, true;
                    if InBuyCD == true then
                        InBuyCD = false;
                        BuyCNT:set(period, source.low[period], "X", "Buy Countdown Cancelled");
                    end
                    Bar67High = math.max(source.high[period - 3], source.high[period - 2]);
                    -- calculate a new Trend Support level.
                    TrendSupVal = math.min(source.low[period - 8], source.low[period - 7], source.low[period - 6], source.low[period - 5]);
                    -- draw the new Trend Support level back to bar #1 of the setup sequence.
                    core.drawLine(TrendSup, core.range(period - 8, period), TrendSupVal, period - 8, TrendSupVal, period);
                    -- looking for perfect Setup
                    if showperf == true and (source.high[period] >= Bar67High or source.high[period-1] >= Bar67High) then
                        SellPSU:set(period, source.high[period], "\144\010", "Perfected Sell Setup");
                        SeekingSellPerfection = false;
                    elseif showperf == true then
                        SeekingSellPerfection = true;
                        SellPerfWaitCount = 0;
                    end
                    -- start countdown?
                    if showcdown == true and source.close[period] >= source.high[period - 2] then
                        sCountdown = 1;
                        SellCNT:set(period, source.high[period], sCountdown .. "\010\010", "Sell Countdown 1 to 13");
                        SellDoppelganger = true;
                    elseif showcdown == true then
                        sCountdown = 0;
                        SellDoppelganger = false;
                    end     
                end
            else
            -- the setup has been broken
                for a = 1, SellSUCount, 1 do
                -- clear away the existing setup numbers
                    SellSU:setNoData(period - a);
                end
                -- reset the buy setup tracking variables
                InSellSU, SellSUCount = false, 0;
            end
        end
        if showperf == true and SeekingSellPerfection == true and SellPerfWaitCount <= waitlimit then
        -- a sell setup has recently completed, but it has not been perfected
            if (source.high[period] >= Bar67High) then
            -- setup has just been perfected
                SeekingSellPerfection = false;
                SellPSU:set(period, source.high[period], "\144", "Perfected Sell Setup");
            else
                SellPerfWaitCount = SellPerfWaitCount + 1;
            end
        end
        if showperf == true and SeekingBuyPerfection == true and BuyPerfWaitCount <= waitlimit then
        -- a buy setup has recently completed, but it has not been perfected
            if (source.low[period] <= Bar67Low) then
            -- setup has just been perfected
                SeekingBuyPerfection = false;
                BuyPSU:set(period, source.low[period], "\143", "Perfected Buy Setup");
            else
                BuyPerfWaitCount = BuyPerfWaitCount + 1;
            end
        end
    -- Countdown Calculations
        if showcdown == true and InBuyCD == true and BuyDoppelganger == false then
            if bCountdown < 12 and source.close[period] <= source.low[period - 2] then
                -- countdown.
                bCountdown = bCountdown + 1;
                BuyCNT:set(period, source.low[period], "\010" .. bCountdown, "Buy Countdown 1 to 13");
                if bCountdown == 8 then
                    BuyCDTest = source.close[period];
                end
            elseif bCountdown == 12 and source.close[period] <= source.low[period - 2] and source.low[period] <= BuyCDTest then
                -- we have countdown bar 13:  a completed countdown, which could be used as a buy signal.
                bCountdown = 13;
                InBuyCD = false;
                BuyCNT:set(period, source.low[period], "\010" .. bCountdown, "Buy Countdown 1 to 13");
                BuyCNTS:set(period, source.low[period], "\010\010\225", "Basic Buy Signal");
            elseif bCountdown == 12 and source.close[period] <= source.low[period - 2] then
                -- this WOULD be bar 13 but it's still above bar 8 of the countdown.
                BuyCNT:set(period, source.low[period], "\010+", "Count 13 (buy signal) has been deferred");
            end
        else
            BuyDoppelganger = false;
        end
        if showcdown == true and InSellCD == true and SellDoppelganger == false then
            if sCountdown < 12 and source.close[period] >= source.high[period - 2] then
                -- countdown.
                sCountdown = sCountdown + 1;
                SellCNT:set(period, source.high[period], sCountdown .. "\010", "Sell Countdown 1 to 13");
                if sCountdown == 8 then
                    SellCDTest = source.close[period];
                end
            elseif sCountdown == 12 and source.close[period] >= source.high[period - 2] and source.high[period] >= SellCDTest then
                -- we have countdown bar 13:  a completed countdown, which could be used as a sell signal.
                sCountdown = 13;
                InSellCD = false;
                SellCNT:set(period, source.high[period], sCountdown .. "\010", "Sell Countdown 1 to 13");
                SellCNTS:set(period, source.high[period], "\226\010\010", "Basic Sell Signal");
            elseif sCountdown == 12 and source.close[period] >= source.high[period - 2] then
                -- this WOULD be bar 13 but it's still below bar 8 of the countdown.
                SellCNT:set(period, source.high[period], "+\010", "Count 13 (sell signal) has been deferred");
            end
        else
            SellDoppelganger = false;
        end
    -- If there's not currently a setup sequence happening, check if a new one is just starting.
        if InBuySU == false and InSellSU == false then
            if source.close[period - 1] > source.close[period - 1 - lookback] and source.close[period] < source.close[period - lookback] then
            -- a bearish price flip has occurred.  This is bar 1 of a possible buy setup sequence.
                InBuySU, InSellSU = true, false;
                BuySUCount, SellSUCount = 1, 0;
                BuySU:set(period, source.low[period], BuySUCount);
            elseif source.close[period - 1] < source.close[period - 1 - lookback] and source.close[period] > source.close[period - lookback] then
            -- a bullish price flip has occurred.  This is bar 1 of a possible sell setup sequence.
                InSellSU, InBuySU = true, false;
                SellSUCount, BuySUCount = 1, 0;
                SellSU:set(period, source.high[period], SellSUCount);
            end
        end
    -- extend the existing Trend Level lines up to the current bar.
    core.drawLine(TrendRes, core.range(period - 1, period), TrendResVal, period - 1, TrendResVal, period);       
    core.drawLine(TrendSup, core.range(period - 1, period), TrendSupVal, period - 1, TrendSupVal, period);       
    end
end

function ReleaseInstance()
    if instance.parameters.RefreshTime>0 then
        core.host:execute("killTimer", TimerID);
    end
end
