-- Id: 759

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1123

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
 

function Init()
    strategy:name("Altr Trend signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("");

    strategy.parameters:addGroup("Parameters");
    
    strategy.parameters:addInteger("K", "K", "No description", 30);
    strategy.parameters:addDouble("KStop", "KStop", "No description", 0.5);
    strategy.parameters:addInteger("Kperiod", "Kperiod", "No description", 150);
    strategy.parameters:addInteger("PerADX", "PerADX", "No description", 14);

    strategy.parameters:addString("Period", "Timeframe", "", "m5");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
end

local SoundFile;
local gSourceBid = nil;
local gSourceAsk = nil;
local first;

local BidFinished = false;
local AskFinished = false;
local LastBidCandle = nil;

local ADX;

function Prepare(nameOnly) 
    ShowAlert = instance.parameters.ShowAlert;
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
	
	
	local name = profile:id() .. "(" .. instance.bid:instrument() .. "(" .. instance.parameters.Period  .. ")" .. instance.parameters.K .. ")" .. instance.parameters.KStop .. ")" .. instance.parameters.Kperiod .. ")" .. instance.parameters.PerADX .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
    
    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");
    assert(instance.parameters.Period ~= "t1", "Signal cannot be applied on ticks");

    ExtSetupSignal("Altr Trend signal:", ShowAlert);

    gSourceBid = core.host:execute("getHistory", 1, instance.bid:instrument(), instance.parameters.Period, 0, 0, true);
    gSourceAsk = core.host:execute("getHistory", 2, instance.bid:instrument(), instance.parameters.Period, 0, 0, false);

    ADX = core.indicators:create("ADX", gSourceBid, instance.parameters.PerADX);

    first = ADX.DATA:first() + instance.parameters.Kperiod;

    
end

local LastDirection=nil;

-- when tick source is updated
function Update()
    if not(BidFinished) or not(AskFinished) then
        return ;
    end

    local period;

    -- update moving average
    ADX:update(core.UpdateLast);

    -- calculate enter logic
    if LastBidCandle == nil or LastBidCandle ~= gSourceBid:serial(gSourceBid:size() - 1) then
        LastBidCandle = gSourceBid:serial(gSourceBid:size() - 1);

        period = gSourceBid:size() - 1;
        if period > first then
         local SSP=math.ceil(instance.parameters.Kperiod/ADX.DATA[period-1]);
         local AvgRange=0.;
         for i=period-SSP,period,1 do
          AvgRange=AvgRange+math.abs(gSourceBid.high[i]-gSourceBid.low[i]);
         end
         local Range=AvgRange/(SSP+1);
         local SsMax=core.max(gSourceBid.high,core.rangeTo(period,SSP-1));
         local SsMin=core.min(gSourceBid.low,core.rangeTo(period,SSP-1));
         local smin=SsMin+(SsMax-SsMin)*instance.parameters.K/100.;
         local smax=SsMax-(SsMax-SsMin)*instance.parameters.K/100.;
         
         if gSourceBid.close[period]<smin and LastDirection~=-1 then
          ExtSignal(gSourceBid, period, "Sell", SoundFile);
          LastDirection=-1;
         end
         if gSourceBid.close[period]>smax and LastDirection~=1 then
          ExtSignal(gSourceAsk, period, "Buy", SoundFile);
          LastDirection=1;
         end
        
        end
    end
end

function AsyncOperationFinished(cookie)
    if cookie == 1 then
        BidFinished = true;
    elseif cookie == 2 then
        AskFinished = true;
    end
end

local gSignalBase = "";     -- the base part of the signal message
local gShowAlert = false;   -- the flag indicating whether the text alert must be shown

-- ---------------------------------------------------------
-- Sets the base message for the signal
-- @param base      The base message of the signals
-- ---------------------------------------------------------
function ExtSetupSignal(base, showAlert)
    gSignalBase = base;
    gShowAlert = showAlert;
    return ;
end

-- ---------------------------------------------------------
-- Signals the message
-- @param message   The rest of the message to be added to the signal
-- @param period    The number of the period
-- @param sound     The sound or nil to silent signal
-- ---------------------------------------------------------
function ExtSignal(source, period, message, soundFile)
    if source:isBar() then
        source = source.close;
    end
    if gShowAlert then
        terminal:alertMessage(source:instrument(), source[period], gSignalBase .. message, source:date(period));
    end
    if soundFile ~= nil then
        terminal:alertSound(soundFile, false);
    end
end

