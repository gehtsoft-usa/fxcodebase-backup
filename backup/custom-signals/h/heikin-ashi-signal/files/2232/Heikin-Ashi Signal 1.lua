-- Id: 778
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
    strategy:name("Heikin-Ashi Signal 1");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Heikin-Ashi Signal 1");

    strategy.parameters:addGroup("Parameters");

    strategy.parameters:addDouble("Doji", "Doji candle sensitivity in pips", "", 0.25, 0, 100);

    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addString("Period", "Timeframe", "", "m5");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
end

local ShowAlert;
local SoundFile;
local BarSource = nil;         -- the source stream
local HA = nil;
local Doji;

-- candle types
local UP = 1;
local DJ = 0;
local DN = -1;

function Prepare()
    -- collect parameters
    ShowAlert = instance.parameters.ShowAlert;

    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

    assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");

    Doji = instance.parameters.Doji;

    ExtSetupSignal("Heikin-Ashi Signal", ShowAlert);
    BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
    local ps;
    ps = BarSource:pipSize();
    if ps > 1 then
        ps = math.pow(10, -ps);
    end
    Doji = Doji * ps;
    HA = core.indicators:create("HA", BarSource);

    local name = profile:id() .. "(" .. instance.bid:instrument()  .. ")"
    instance:name(name);
end

-- when tick source is updated
function ExtUpdate(id, source, period)
    HA:update(core.UpdateLast);

    if not(HA.close:hasData(period - 1)) then
        return ;
    end

    local p = Decode(period - 1);
    local c = Decode(period);

    if c == DJ then
        ExtSignal(source.close, period, "Doji", SoundFile);
    elseif c == UP and p ~= UP then
        ExtSignal(source.close, period, "Turns to Up", SoundFile);
    elseif c == DN and p ~= DN then
        ExtSignal(source.close, period, "Turns to Dn", SoundFile);
    end
end

function Decode(period)
    if math.abs(HA.open[period] - HA.close[period]) <= Doji then
        return DJ;
    elseif HA.open[period] > HA.close[period] then
        return DN;
    else
        return UP;
    end

end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
