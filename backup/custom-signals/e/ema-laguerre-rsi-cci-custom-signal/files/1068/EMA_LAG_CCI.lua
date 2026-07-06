-- Id: 322
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
    strategy:name("EMA/Laguerre RSI/CCI signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Signals BUY when EMA grows and Lag_RSI = 1 and CCI < -5. Signals SELL when EMA falls, Lag_RSI = -1 and  ");

    strategy.parameters:addGroup("Parameters");

    strategy.parameters:addInteger("EMA", "EMA Parameter", "", 120);
    strategy.parameters:addDouble("LAG", "Laguerre RSI", "", 0.7);
    strategy.parameters:addInteger("CCI", "CCI Parameter", "", 14);
    strategy.parameters:addInteger("TP", "Limit in pips", "", 15);
    strategy.parameters:addInteger("SL", "Stop loss in pips", "", 15);

    strategy.parameters:addString("Period", "Timeframe", "", "m5");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
end

local SoundFile;
local EMA;
local LAG;
local CCI;
local gSourceBid = nil;
local gSourceAsk = nil;
local TP;
local SL;
local first;

local BidFinished = false;
local AskFinished = false;
local LastBidCandle = nil;

function Prepare()
    local FastN, SlowN;

    ShowAlert = instance.parameters.ShowAlert;
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");
    assert(instance.parameters.Period ~= "t1", "Signal cannot be applied on ticks");

    ExtSetupSignal("EMA/Lag_RSI/CCI signal:", ShowAlert);

    gSourceBid = core.host:execute("getHistory", 1, instance.bid:instrument(), instance.parameters.Period, 0, 0, true);
    gSourceAsk = core.host:execute("getHistory", 2, instance.bid:instrument(), instance.parameters.Period, 0, 0, false);

    TP = instance.parameters.TP * instance.bid:pipSize();
    SL = instance.parameters.SL * instance.bid:pipSize();

    EMA = core.indicators:create("EMA", gSourceBid.close, instance.parameters.EMA);
    assert(core.indicators:findIndicator("LAGUERRE_RSI") ~= nil, "LAGUERRE_RSI" .. " indicator must be installed");
    LAG = core.indicators:create("LAGUERRE_RSI", gSourceBid.close, instance.parameters.LAG);
    CCI = core.indicators:create("CCI", gSourceBid, instance.parameters.CCI);

    first = math.max(EMA.DATA:first(), LAG.DATA:first(), CCI.DATA:first()) + 2;

    local name = profile:id() .. "(" .. instance.bid:instrument() .. "(" .. instance.parameters.Period  .. ")" .. instance.parameters.EMA .. "," .. instance.parameters.LAG .. "," .. instance.parameters.CCI .. ")";
    instance:name(name);
end

local LONG = nil;
local SHORT = nil;
local LastDirection=nil;

-- when tick source is updated
function Update()
    if not(BidFinished) or not(AskFinished) then
        return ;
    end

    local period;

    -- check for TP/SL (exit logic)
    if LONG ~= nil then
        period = gSourceBid:size() - 1;
        -- check profit
        if gSourceBid.high[period] >= LONG + TP then
            ExtSignal(gSourceBid.high, period, "Exit Buy (L)", SoundFile);
            LONG = nil;
        elseif gSourceBid.low[period] <= LONG - SL then
            ExtSignal(gSourceBid.high, period, "Exit Buy (S)", SoundFile);
            LONG = nil;
        end
    end
    if SHORT ~= nil then
        period = gSourceAsk:size() - 1;
        -- check profit
        if gSourceAsk.low[period] <= SHORT - TP then
            ExtSignal(gSourceBid.low, period, "Exit Sell (L)", SoundFile);
            SHORT = nil;
        elseif gSourceAsk.high[period] >= SHORT + SL then
            ExtSignal(gSourceBid.high, period, "Exit Sell (S)", SoundFile);
            SHORT = nil;
        end
    end

    -- update moving average
    EMA:update(core.UpdateLast);
    LAG:update(core.UpdateLast);
    CCI:update(core.UpdateLast);

    -- calculate enter logic
    if LastBidCandle == nil or LastBidCandle ~= gSourceBid:serial(gSourceBid:size() - 1) then
        LastBidCandle = gSourceBid:serial(gSourceBid:size() - 1);

        period = gSourceBid:size() - 2;
        if period >= first then
            if LONG == nil and EMA.DATA[period - 2] < EMA.DATA[period - 1] and
               LAG.DATA[period] == 1 and CCI.DATA[period] < -5 and LastDirection~=1 then
                ExtSignal(gSourceAsk, period, "Buy", SoundFile);
                LONG = gSourceAsk.close[period];
                LastDirection=1;
            elseif SHORT == nil and EMA.DATA[period - 2] > EMA.DATA[period - 1] and
                   LAG.DATA[period] == 1 and CCI.DATA[period] > 5 and LastDirection~=-1 then
                ExtSignal(gSourceBid, period, "Sell", SoundFile);
                SHORT = gSourceBid.close[period];
                LastDirection=-1;
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

