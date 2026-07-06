-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=31&t=76045

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 

function Init()
    strategy:name("RSI Divergence")
    strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert")
    strategy:description("Signals when the RSI Divergence detected")

    strategy.parameters:addInteger("N", "Periods for RSI Divergence", "", 7, 2, 200)

    strategy.parameters:addString("Period", "Time frame", "", "m1")
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS)

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true)
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false)
    strategy.parameters:addFile("SoundFile", "Sound File", "", "")
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND)
    strategy.parameters:addBoolean("signaler_send_email", "Send Email", "", false)
    strategy.parameters:addString("signaler_email", "Email", "", "")
    strategy.parameters:setFlag("signaler_email", core.FLAG_EMAIL)
    strategy.parameters:addInteger("signaler_ToTime", "Convert the date to", "", 6)
    strategy.parameters:addIntegerAlternative("signaler_ToTime", "EST", "", 1)
    strategy.parameters:addIntegerAlternative("signaler_ToTime", "UTC", "", 2)
    strategy.parameters:addIntegerAlternative("signaler_ToTime", "Local", "", 3)
    strategy.parameters:addIntegerAlternative("signaler_ToTime", "Server", "", 4)
    strategy.parameters:addIntegerAlternative("signaler_ToTime", "Financial", "", 5)
    strategy.parameters:addIntegerAlternative("signaler_ToTime", "Display", "", 6)
end

local N
local SoundFile
local gSource = nil -- the source stream
local signaler_send_email
local signaler_email
local signaler_ToTime;

function Prepare(nameOnly)
    signaler_send_email = instance.parameters.signaler_send_email
    signaler_email = instance.parameters.signaler_email
    signaler_ToTime = instance.parameters.signaler_ToTime;
    N = instance.parameters.N

    ShowAlert = instance.parameters.ShowAlert

    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile
    else
        SoundFile = nil
    end

    local name =
        profile:id() .. "(" .. instance.bid:instrument() .. "(" .. instance.parameters.Period .. ")" .. "," .. N .. ")"
    instance:name(name)

    if (nameOnly) then
        return
    end

    assert(
        core.indicators:findIndicator("RSI_DIVERGENCE") ~= nil,
        "Please, download and install RSI_DIVERGENCE.LUA indicator"
    )

    assert(not (PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified")

    ExtSetupSignal(profile:id() .. ":", ShowAlert)

    assert(instance.parameters.Period ~= "t1", "Can't be applied on ticks!")

    gSource = ExtSubscribe(1, nil, instance.parameters.Period, true, "bar")
end

local RSI = nil

-- when tick source is updated
function ExtUpdate(id, source, period)
    if RSI == nil then
        RSI = core.indicators:create("RSI_DIVERGENCE", gSource, N, false)
    end

    RSI:update(core.UpdateLast)

    if period <= N + 10 then
        return
    end

    local v

    if RSI:getStream(1):hasData(period - 2) then
        v = RSI:getStream(1)[period - 2]
        if v > 0 then
            SendSignal(gSource, period, "Classic Bearish", SoundFile)
        elseif v < 0 then
            SendSignal(gSource, period, "Reversal Bearish", SoundFile)
        end
    end
    if RSI:getStream(2):hasData(period - 2) then
        v = RSI:getStream(2)[period - 2]
        if v > 0 then
            SendSignal(gSource, period, "Classic Bullish", SoundFile)
        elseif v < 0 then
            SendSignal(gSource, period, "Reversal Bullish", SoundFile)
        end
    end
end

function SendSignal(source, period, message, soundFile)
    ExtSignal(gSource, period, message, soundFile)
    if signaler_send_email then
        terminal:alertEmail(signaler_email, message, FormatEmail(source, NOW, message));
    end
end

function FormatEmail(source, period, message)
    --format email subject
    local subject = message .. "(" .. source:instrument() .. ")";
    --format email text
    local delim = "\013\010";
    local signalDescr = "Signal";
    local symbolDescr = "Symbol: " .. source:instrument();
    local messageDescr = "Message: " .. message;
    local ttime = core.dateToTable(core.host:execute("convertTime", core.TZ_EST, signaler_ToTime, source:date(period)));
    local dateDescr = string.format("Time:  %02i/%02i %02i:%02i", ttime.month, ttime.day, ttime.hour, ttime.min);
    local priceDescr = "Price: " .. source[period];
    local text = "You have received this message because the following signal alert was received:"
        .. delim .. signalDescr .. delim .. symbolDescr .. delim .. messageDescr .. delim .. dateDescr .. delim .. priceDescr;
    return subject, text;
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua")
-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=31&t=76045

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 