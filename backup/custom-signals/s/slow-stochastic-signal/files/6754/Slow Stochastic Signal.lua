-- Id: 2636

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=29&t=2951

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

function Init()
    strategy:name("Slow Stochastic Signal");   
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
	strategy:description("Signals BUY / SELL when the stochastic K% or D% Line crosses under/over the overbought/oversold level, stochastic K%, D% Lines crosses  Each other..");

    strategy.parameters:addGroup("Parameters");

    strategy.parameters:addInteger("K", "K Period", "", 5, 2, 1000);
    strategy.parameters:addInteger("D", "D Period", "", 3, 1, 1000);
    strategy.parameters:addInteger("SD", "D slowing periods", "", 3, 1, 1000);


    strategy.parameters:addString("L", "Signal Type", "", "K");
    strategy.parameters:addStringAlternative("L", "%K Overbought/ Oversold", "", "K");
    strategy.parameters:addStringAlternative("L", "%D Overbought/ Oversold", "", "D");
	strategy.parameters:addStringAlternative("L", "%K / %D Cross", "", "C");
    strategy.parameters:addStringAlternative("L", "%K / %D Cross in Overbought/ Oversold", "", "B");
	
    strategy.parameters:addInteger("OS", "Overbought level", "", 20, 1, 100);
    strategy.parameters:addInteger("OB", "Oversold level" , "", 80, 1, 100);

    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addString("Period", "Period size", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Notification");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound file", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
	strategy.parameters:addBoolean("SendEmail", "Send e-mail", "", false);
    strategy.parameters:addString("Email", "E-mail address", "Note that to recieve e-mails, SMTP settings must be defined (see Signals Options).", "");
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

    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");

	SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
	
    BUY = "Buy";
    SELL = "Sell"
    
    SetSource(instance.parameters.Period, instance.parameters.Type == "Bid");

    Stoch = core.indicators:create("SSD", gExtSource, instance.parameters.K, instance.parameters.D, instance.parameters.SD);

 
	    Line = Stoch:getStream(0);  -- %K
		Line2 = Stoch:getStream(1);  -- %D
    
    
    local name = profile:id() .. "(" .. instance.bid:instrument() .. "(" .. instance.parameters.Period  .. ")" .. "," .. instance.parameters.K .. "," .. instance.parameters.D .. "," .. instance.parameters.SD  .. ")";    
    instance:name(name);
	
	ExtSetupSignal("Slow Stochastic Signal " .. ":", ShowAlert);
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

    if (period  < Line:first() )
	or (period  < Line2:first() )
	then
	return;
	end
	
    if  (instance.parameters.L ~="D")  then
          if core.crossesOver(Line2, OS, period)   then
				ExtSignal(gExtSource, period, BUY, SoundFile, Email)            
			elseif core.crossesUnder(Line2, OB, period)   then
				ExtSignal(gExtSource, period, SELL, SoundFile, Email)            
			end
    end
	
	
	  if  (instance.parameters.L ~="K")  then
          if core.crossesOver(Line, OS, period)   then
				ExtSignal(gExtSource, period, BUY, SoundFile, Email)            
			elseif core.crossesUnder(Line, OB, period)   then
				ExtSignal(gExtSource, period, SELL, SoundFile, Email)            
			end
    end
	
	
	if (instance.parameters.L =="C") then
 
			if core.crossesOver(Line, Line2, period) then
				ExtSignal(gExtSource, period, BUY, SoundFile, Email)            
			elseif core.crossesUnder(Line, Line2, period) then
				ExtSignal(gExtSource, period, SELL, SoundFile, Email)            
			end
	 
	end
	
	if  (instance.parameters.L =="B") then
		 
			if core.crossesOver(Line, Line2, period) and Line[period-1] < OS then
				ExtSignal(gExtSource, period, BUY, SoundFile, Email)            
			elseif core.crossesUnder(Line, Line2, period) and Line[period-1]> OB then
				ExtSignal(gExtSource, period, SELL, SoundFile, Email)            
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
        assert(false, "Signal cannot be applied on ticks");
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

