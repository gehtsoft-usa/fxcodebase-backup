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

    -- This indicator is a work in progress.
    -- It is being written by the user 'Tortoise' on the FXCodebase.com forum.

    -- All users are welcome to use and modify the code, but please would you be kind enough
    -- to post your improvements and experiences on the FXCodebase.com forum so that we can
    -- all benefit from your experience.

    -- The intent is to produce a fully functional 'TDSequential' indicator as described
    -- by Jason Perl in the book 'DeMark Indicators', Bloomberg 2008.

    -- This is version 1.2, completed on the 15th April 2010
    -- So-far the indicator contains 'TDSetup' and 'TDST Levels'
    -- TDSetup shows the numbers 1 to 9 of a setup sequence.
    -- The current bar is not included until it closes.
    -- TDST Levels are calculated at the close of each complete setup (i.e. on the completion
    -- of bar 9).  The TDST Level line then jumps to that level, starting at bar 1 (i.e. it is
    -- re-painted back 8 bars).  The lines look messy, but they allow you to see what the TDST
    -- Levels were during each Setup sequence in the past.

    -- Next job is to identify a Perfected Setup, then to add TD Countdown.


    function Init()
        indicator:name("Tortoise's TDSetup with TDST");
        indicator:description("TD Setup & TDST based on Jason Perl's Book");
        indicator:requiredSource(core.Bar);
        indicator:type(core.Indicator);

        indicator.parameters:addGroup("TD Setup");
        indicator.parameters:addInteger("Lookback", "No. of Bars to Look Back", "No. of Bars to Look Back", 4, 1, 25);
        indicator.parameters:addColor("BuySU_color", "Color of Buy Setup", "Color of Buy Setup", core.rgb(0, 127, 0));
        indicator.parameters:addColor("SellSU_color", "Color of Perfect Sell Setup", "Color of Perfect Sell Setup", core.rgb(127, 0, 0));
        indicator.parameters:addColor("BuyPSU_color", "Color of Perfect Buy Setup", "Color of Perfect Buy Setup", core.rgb(0, 127, 0));
        indicator.parameters:addColor("SellPSU_color", "Color of Sell Setup", "Color of Sell Setup", core.rgb(127, 0, 0));
        indicator.parameters:addColor("TDSTSup_color", "Color of TDST Support", "Color of TDST Support", core.rgb(80, 200, 100));
        indicator.parameters:addColor("TDSTRes_color", "Color of TDST Resistance", "Color of TDST Resistance", core.rgb(200, 80, 100));

        indicator.parameters:addGroup("TD Countdown");
        indicator.parameters:addBoolean("TDCountdown", "Enable TD Countdown", "Enable Countdown", false);
        indicator.parameters:addColor("BuyCNT_color", "Color of Buy Countdown", "Color of Buy Countdown", core.rgb(0, 127, 0));
        indicator.parameters:addColor("SellCNT_color", "Color of Sell Countdown", "Color of Sell Countdown", core.rgb(127, 0, 0));
    end

    -- Parameters block
    local first = 3;
    local source = nil;
    local point;
    -- Streams block
    local BuySU, SellSU = nil, nil;
    local bCountdown = 0;
    local sCountdown = 0;
    local CountTest = nil;
    local bTDCountDown;
    -- Routine
    function Prepare(nameOnly)
        source = instance.source;
        first = source:first();
        lookback = instance.parameters.Lookback;
        bTDCountDown = instance.parameters.TDCountdown;
        point = source:pipSize();
        BuySUCount, SellSUCount = 0, 0;
        TDSTSupVal, TDSTResVal = 0, 0;
        InBuySU, InSellSU, BuySUComplete, SellSUComplete = false, false, false, false;
        LastCompleteBuySU, LastCompleteSellSU = 0, 0;
        BuyBookmark, SellBookmark = 1, 2;
        local name = profile:id() .. "(" .. source:name() .. ")";
        instance:name(name);
		if   (nameOnly) then
        return;
        end
	
        BuySU = instance:createTextOutput ("BuySetup", "BuySetup", "Arial", 10, core.H_Center, core.V_Bottom, instance.parameters.BuySU_color, 0);
        SellSU = instance:createTextOutput ("SellSetup", "SellSetup", "Arial", 10, core.H_Center, core.V_Top, instance.parameters.SellSU_color, 0);
        TDSTSup = instance:addStream ("Sup", core.Line, "TDST Support Line", "Sup", instance.parameters.TDSTSup_color, first);
        TDSTRes = instance:addStream ("Res", core.Line, "TDST Resistance Line", "Res", instance.parameters.TDSTRes_color, first);

        BuyPSU = instance:createTextOutput ("PerfectBuySetup", "PerfectBuySetup", "Wingdings", 18, core.H_Center, core.V_Bottom, instance.parameters.BuyPSU_color, 0);
        SellPSU = instance:createTextOutput ("PerfectSellSetup", "PerfectSellSetup", "Wingdings", 18, core.H_Center, core.V_Top, instance.parameters.SellPSU_color, 0);

        BuyCNT = instance:createTextOutput ("BuyCountdown", "BuyCountdown", "Arial", 12, core.H_Right, core.V_Bottom, instance.parameters.BuyCNT_color, 0);
        SellCNT = instance:createTextOutput ("SellCountdown", "SellCountdown", "Arial", 12, core.H_Right, core.V_Top, instance.parameters.SellCNT_color, 0);
        BuyCNTS = instance:createTextOutput ("BuyCountSignal", "BuyCountSignal", "Wingdings", 12, core.H_Center, core.V_Bottom, instance.parameters.BuyCNT_color, 0);
        SellCNTS = instance:createTextOutput ("SellCountSignal", "SellCountSignal", "Wingdings", 12, core.H_Center, core.V_Top, instance.parameters.SellCNT_color, 0);
    end

function Update(period)
        if period > lookback and period < source:size() - 1 and source:hasData(period) then
            if InBuySU == true and BuySUCount < 9 then
            -- we're currently in an uncompleted prospective TD Buy Setup.
                if source.close[period] < source.close[period - lookback] then
                -- the setup remains intact
                    BuySUCount = BuySUCount + 1;
                    BuySU:set(period, source.low[period], BuySUCount);
                    if BuySUCount == 9 then
                        -- The TD Buy Setup has just completed.
                        BuySUComplete = true;
                        InBuySU = false;
                        -- calculate the new TDST Resistance level.
                        TDSTResVal = math.max(source.high[period - 8], source.high[period - 7], source.high[period - 6], source.high[period - 5]);
                        -- draw the new TDST Resistance level back to bar #1 of the TDSetup.
                        core.drawLine(TDSTRes, core.range(period - 8, period), TDSTResVal, period - 8, TDSTResVal, period);    
                        -- looking for perfect Setup
                        if  (source.low[period] <= source.low[period-3] and source.low[period] <= source.low[period-2]) or
                            (source.low[period-1] <= source.low[period-3] and source.low[period-1] <= source.low[period-2]) then
                            BuyPSU:set(period, source.low[period]- 5*point, "\225", "Perfect Buy Setup");

                            -- Perfect Setup found starting TP Countdown
                            sCountdown = 0;
                            bCountdown = 1;
                            BuyCNT:set(period, source.low[period]- 10*point, bCountdown, "Buy Counter");
                            -- Perfect Setup found starting TP Countdown
                        end
                    end
                else
                -- the setup has been broken
                    for a = 1, BuySUCount, 1 do
                    -- clear away the existing setup numbers
                        BuySU:set(period - a, source.low[period - a], " ");
                    end
                    -- reset the TD Buy Setup tracking variables
                    InBuySU, BuySUCount = false, 0;
                end
            elseif InSellSU == true and SellSUCount < 9 then
            -- we're currently in an uncompleted prospective TD Sell Setup.
                if source.close[period] > source.close[period - lookback] then
                -- the setup remains intact
                    SellSUCount = SellSUCount + 1;
                    SellSU:set(period, source.high[period], SellSUCount);
                    if SellSUCount == 9 then
                        -- The TD Sell Setup has just completed.
                        SellSUComplete = true;
                        InSellSU = false;
                        -- calculate a new TDST Support level.
                        TDSTSupVal = math.min(source.low[period - 8], source.low[period - 7], source.low[period - 6], source.low[period - 5]);
                        -- draw the new TDST Support level back to bar #1 of the TDSetup.
                        core.drawLine(TDSTSup, core.range(period - 8, period), TDSTSupVal, period - 8, TDSTSupVal, period); 
                        -- looking for perfect Setup
                        if  (source.high[period] >= source.high[period-3] and source.high[period] >= source.high[period-2]) or
                            (source.high[period-1] >= source.high[period-3] and source.high[period-1] >= source.high[period-2]) then
                            SellPSU:set(period, source.high[period]+ 5*point, "\226", "Perfect Sell Setup");
-- Perfect Setup found starting TP Countdown
                            bCountdown = 0 ;
                            sCountdown = 1;
                            SellCNT:set(period, source.high[period]+ 10*point, sCountdown, "Sell Counter");
-- Perfect Setup found starting TP Countdown
                        end     
                    end
                else
                -- the setup has been broken
                    for a = 1, SellSUCount, 1 do
                    -- clear away the existing setup numbers
                        SellSU:set(period - a, source.high[period - a], " ");
                    end
                    -- reset the TD Buy Setup tracking variables
                    InSellSU, SellSUCount = false, 0;
                end
            end

            if InBuySU == false and InSellSU == false then
                -- we're not currently in any possible TD Setup.  Check whether one is just starting.
                if source.close[period - 1] > source.close[period - 1 - lookback] and source.close[period] < source.close[period - lookback] then
                -- a Bearish TD Price Flip has occurred.  This is bar 1 of a possible TD Buy Setup.
                    InBuySU, BuySUComplete = true, false;
                    BuySUCount, SellSUCount = 1, 0;
                    BuySU:set(period, source.low[period], BuySUCount);
                elseif source.close[period - 1] < source.close[period - 1 - lookback] and source.close[period] > source.close[period - lookback] then
                -- a Bullish TD Price Flip has occurred.  This is bar 1 of a possible TD Sell Setup.
                    InSellSU, SellSUComplete = true, false;
                    SellSUCount, BuySUCount = 1, 0;
                    SellSU:set(period, source.high[period], SellSUCount);
                end
            end
        -- extend the existing TDST Level lines up to the current bar.
        core.drawLine(TDSTRes, core.range(period - 1, period), TDSTResVal, period - 1, TDSTResVal, period);       
        core.drawLine(TDSTSup, core.range(period - 1, period), TDSTSupVal, period - 1, TDSTSupVal, period); 
        
        -- TD Countdown Calculations----------------------------------------------------------------------------------------
        --if bTDCountDown == true then
            if bCountdown >= 1 and bCountdown < 13 and source.close[period] <= source.close[period-2] then
                if bCountdown==8 then
                    CountTest=source.close[period];
                end
                BuyCNT:set(period, source.low[period]- 10*point, bCountdown, "Buy Counter");
                bCountdown = bCountdown + 1;

            end
            if CountTest ~= nil then
                if  (bCountdown == 13 and source.close[period] <= source.close[period-1] and source.close[period] > CountTest) then
                    BuyCNTS:set(period, source.low[period]- 15*point, "\225", "Normal Buy Countdown Signal");
                end
                if  (bCountdown == 13 and source.close[period] <= source.close[period-1] and source.close[period] <= CountTest) then
                    bCountdown=0;
                    BuyCNT:set(period, source.low[period]- 20*point, "Buy Countdown Completed");
                    BuyCNTS:set(period, source.low[period]- 15*point, "\225", "Completed Buy Countdown Signal");
                end
            end

            if sCountdown >= 1 and sCountdown < 13 and source.close[period] >= source.close[period-2] then
                if sCountdown==8 then
                    CountTest=source.close[period];
                end
                SellCNT:set(period, source.high[period]+ 10*point, sCountdown, "Sell Counter");
                sCountdown = sCountdown + 1;

            end
            if CountTest ~= nil then
                if  (sCountdown == 13 and source.close[period] >= source.close[period-1] and source.close[period] < CountTest) then
                    SellCNTS:set(period, source.high[period]+ 15*point, "\226", "Normal Sell Countdown Signal");
                end
                if  (sCountdown == 13 and source.close[period] >= source.close[period-1] and source.close[period] >= CountTest) then
                    sCountdown=0;
                    SellCNT:set(period, source.high[period]+ 20*point, " Sell Countdown Completed");
                    SellCNTS:set(period, source.high[period]+ 15*point, "\226", "Completed Sell Countdown Signal");
                end
            end
        --end
      
        end
end

