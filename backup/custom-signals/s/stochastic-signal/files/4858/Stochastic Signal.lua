-- Id: 1782
-- More information about this indicator can be found at:
-- http://fxcodebase.com/

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
function Init()
    strategy:name("Stochastic Signal");   
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
	strategy:description("Signals BUY / SELL when the stochastic K% or D% Line crosses under/over the overbought/oversold level, stochastic K%, D% Lines crosses  Each other..");

    strategy.parameters:addGroup(resources:get("R_ParamGroup"));

    strategy.parameters:addInteger("K", resources:get("R_K"), "", 5, 2, 1000);
    strategy.parameters:addInteger("D", resources:get("R_D"), "", 3, 1, 1000);
    strategy.parameters:addInteger("SD", resources:get("R_SD"), "", 3, 1, 1000);

    strategy.parameters:addString("A1", resources:get("R_A1"), "", "MVA");
    strategy.parameters:addStringAlternative("A1", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("A1", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("A1", "MetaTrader", "", "MT");

    strategy.parameters:addString("A2", resources:get("R_A2"), "", "MVA");
    strategy.parameters:addStringAlternative("A2", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("A2", "EMA", "", "EMA");

    strategy.parameters:addString("L", resources:get("R_L"), "", "K");
    strategy.parameters:addStringAlternative("L", "%K Overbought/ Oversold", "", "K");
    strategy.parameters:addStringAlternative("L", "%D Overbought/ Oversold", "", "D");
	strategy.parameters:addStringAlternative("L", "%K / %D Cross", "", "C");
    strategy.parameters:addStringAlternative("L", "%K / %D Cross in Overbought/ Oversold", "", "B");
	
    strategy.parameters:addInteger("OS", resources:get("R_OS"), "", 20, 1, 100);
    strategy.parameters:addInteger("OB", resources:get("R_OB"), "", 80, 1, 100);

    strategy.parameters:addString("Type", resources:get("R_PriceType"), "", "Bid");
    strategy.parameters:addStringAlternative("Type", resources:get("R_Bid"), "", "Bid");
    strategy.parameters:addStringAlternative("Type", resources:get("R_Ask"), "", "Ask");

    strategy.parameters:addString("Period", resources:get("R_PeriodType"), "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup(resources:get("R_SignalGroup"));

    strategy.parameters:addBoolean("ShowAlert", resources:get("R_ShowAlert"), "", true);
    strategy.parameters:addBoolean("PlaySound", resources:get("R_PlaySound"), "", false);
    strategy.parameters:addFile("SoundFile", resources:get("R_SoundFile"), "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
	strategy.parameters:addBoolean("SendEmail", resources:get("R_SENDEMAIL"), "", false);
    strategy.parameters:addString("Email", resources:get("R_EMAILADDRESS"), resources:get("R_EMAILADDRESSDESCR"), "");
	strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local SoundFile;
local SendEmail, Email;
local Stoch;
local Line, Line2;
local OS, OB;
local BUY, SELL;
local gExtSource = nil;        -- the source stream
local gLoading = false;     -- the flag indicating whether the data are loading

function Prepare()
    ShowAlert = instance.parameters.ShowAlert;

    local PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

    OS = instance.parameters.OS;
    OB = instance.parameters.OB;

    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), resources:get("R_SoundFileError"));

	SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), resources:get("R_EmailAddressError"));
	
    BUY = resources:get("R_BUY")
    SELL = resources:get("R_SELL")
    
    SetSource(instance.parameters.Period, instance.parameters.Type == "Bid");

    Stoch = core.indicators:create("STOCHASTIC", gExtSource, instance.parameters.K, instance.parameters.D, instance.parameters.SD, instance.parameters.A1, instance.parameters.A2);

    if instance.parameters.L == "K" then
        Line = Stoch:getStream(0);  -- %K
    elseif  instance.parameters.L == "D" then
        Line = Stoch:getStream(1);  -- %D
	elseif 	instance.parameters.L == "B" or instance.parameters.L == "C" then
	    Line = Stoch:getStream(0);  -- %K
		Line2 = Stoch:getStream(1);  -- %D
    end       
    
    local name = profile:id() .. "(" .. instance.bid:instrument() .. "(" .. instance.parameters.Period  .. ")" .. "," .. instance.parameters.K .. "," .. instance.parameters.D .. "," .. instance.parameters.SD .. "," .. instance.parameters.A1 .. "," .. instance.parameters.A2   .. "," .. OS .. "," .. OB .. ")";    
    instance:name(name);
	
	ExtSetupSignal(resources:get("R_Name") .. ":", ShowAlert);
	ExtSetupSignalMail(name);	
end

-- when tick source is updated
function Update()

    if gLoading then
        return;
    end
    
    local period;

    period = GetCandle();
    if period == nil then
        return
    end

    -- update moving average
    Stoch:update(core.UpdateLast);

    if (period >= Line:first() + 1) and  (instance.parameters.L ~="C")  and  (instance.parameters.L ~="B") then
        if core.crossesOver(Line, OS, period) then
		    ExtSignal(gExtSource, period, BUY, SoundFile, Email)            
        elseif core.crossesUnder(Line, OB, period) then
		    ExtSignal(gExtSource, period, SELL, SoundFile, Email)            
        end
    end
	
	if (instance.parameters.L =="C") then
		 if (period >= Line2:first() + 1)  then
			if core.crossesOver(Line, Line2, period) then
				ExtSignal(gExtSource, period, BUY, SoundFile, Email)            
			elseif core.crossesUnder(Line, Line2, period) then
				ExtSignal(gExtSource, period, SELL, SoundFile, Email)            
			end
		end
	end
	
	if  (instance.parameters.L =="B") then
		if (period >= Line2:first() + 1) then
			if core.crossesOver(Line, Line2, period) and Line[period-1] < OS then
				ExtSignal(gExtSource, period, BUY, SoundFile, Email)            
			elseif core.crossesUnder(Line, Line2, period) and Line[period-1]> OB then
				ExtSignal(gExtSource, period, SELL, SoundFile, Email)            
			end
		end
	end
	
end

--
-- The helper file for the strategies
--

local gPeriod = nil;        -- the period code
local gLoading = false;     -- the flag indicating whether the data are loading

-- ------------------------------------------------------------------------
-- Sets the source to gSource variable
-- @param period    The period code
-- @param sound     The flag indicating whether bid or ask must be used
-- ------------------------------------------------------------------------
function SetSource(period, bid)
    gPeriod = period;
    if period == "t1" then
        assert(false, resources:get("R_CandleError"));
    else
        gLoading = true;
        gExtSource = core.host:execute("getHistory", 1, instance.bid:instrument(), period, 0, 0, bid);
        gLoading = true;
    end
end

function AsyncOperationFinished(cookie)
    gLoading = false;
end

local gPreviousCandle = nil;
-- -----------------------------------------------------------------------
-- The function returns the period number to be processed or
-- nil in case the candle is not closed yet
-- -----------------------------------------------------------------------
function GetCandle()
    local period;

    if gExtSource ~= nil then
        if gLoading then
            return nil;
        end

        -- for the external source the correct candle is
        -- the previous to the latest candle
        period = gExtSource:size() - 2;
        if period < gExtSource:first() then
            return nil;
        end
        -- if we called again to the same previous candle
        -- just return
        local date = gExtSource:date(period);
        if gPreviousCandle ~= nil and gPreviousCandle >= date then
            return nil;
        end
        gPreviousCandle = date;
        return period;
    else
        return gExtSource:size() - 1;
    end
end

function AsyncOperationFinished(cookie)
    gLoading = false;
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helperAlert.lua");

