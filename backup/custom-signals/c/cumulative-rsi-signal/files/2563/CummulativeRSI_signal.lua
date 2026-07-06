-- Id: 912
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
-- strategy profile initialization routine
function Init()
    strategy:name("Cumulative RSI");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("The strategy described in Chapter 9 of Trading Strategies That Work by Larry Connors and Cesar Alvarez.");

    strategy.parameters:addGroup("Parameters");
    strategy.parameters:addInteger("MN", "MVA period", "", 200, 1, 1000);
    strategy.parameters:addInteger("N", "RSI period", "", 2, 2, 200);
    strategy.parameters:addInteger("X", "RSI accumulation", "", 2, 1, 200);
    strategy.parameters:addDouble("EL", "Enter Level", "", 35, 0, 200);
    strategy.parameters:addDouble("EX", "Exit Level", "", 65, 0, 200);
    strategy.parameters:addString("Source", "Price", "", "C");
    strategy.parameters:addStringAlternative("Source", "Close", "", "C");
    strategy.parameters:addStringAlternative("Source", "Median", "", "M2");
    strategy.parameters:addStringAlternative("Source", "Typical", "", "M3");
    strategy.parameters:addString("Method", "Moving average method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "MVA");
    strategy.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("Method", "SMMA*", "", "SMMA");
    strategy.parameters:addStringAlternative("Method", "Vidya (1995)*", "", "VIDYA");
    strategy.parameters:addStringAlternative("Method", "Vidya (1992)*", "", "VIDYA92");
    strategy.parameters:addStringAlternative("Method", "Wilders*", "", "WMA");
    strategy.parameters:addString("Period", "Timeframe", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);
    strategy.parameters:addGroup("Signals");
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
end

local SoundFile;
local gSource = nil;
local gTickSource = nil;
local gMa = nil;
local gRsi = nil;
local gRsi1 = nil;
local gMaData = nil;
local gRsiData = nil;
local gRsi1Data = nil;
local first;
local inPosition = false;
local EX, EL;

function Prepare()
    local ShowAlert = instance.parameters.ShowAlert;
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
    EX = instance.parameters.EX;
    EL = instance.parameters.EL;
    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");
    assert(instance.parameters.Period ~= "t1", "Signal cannot be applied on ticks");
    ExtSetupSignal("Cumulative RSI signal:", ShowAlert);
    gSource = ExtSubscribe(1, nil, instance.parameters.Period, true, "bar");
    if instance.parameters.Source == "C" then
        gTickSource = gSource.close;
    elseif instance.parameters.Source == "M2" then
        gTickSource = gSource.median;
    elseif instance.parameters.Source == "M3" then
        gTickSource = gSource.typical;
    else
        assert(false, "Unknown price type is chosen");
    end

    assert(core.indicators:findIndicator(instance.parameters.Method) ~= nil, instance.parameters.Method .. " indicator must be installed");
    gMa = core.indicators:create(instance.parameters.Method, gTickSource, instance.parameters.MN);
    gMaData = gMa.DATA;
    assert(core.indicators:findIndicator("CUMULATIVERSI") ~= nil, "CUMULATIVERSI" .. " indicator must be installed");
    gRsi = core.indicators:create("CUMULATIVERSI", gTickSource, instance.parameters.N, instance.parameters.X, instance.parameters.EL, instance.parameters.EX);
    gRsiData = gRsi.DATA;
    gRsi1 = core.indicators:create("RSI", gTickSource, instance.parameters.N);
    gRsi1Data = gRsi1.DATA;
    first = math.max(gRsiData:first() + 1, gMaData:first());
    local name = profile:id() .. "(" .. instance.bid:instrument() .. "(" .. instance.parameters.Period  .. ")," .. instance.parameters.Method .. "," .. instance.parameters.MN .. "," .. instance.parameters.N .. "," .. instance.parameters.X  .. "," .. instance.parameters.EL  .. "," .. instance.parameters.EX .. ")";
    instance:name(name);
end

function ExtUpdate(id, source, period)
    if id == 1 and period >= first then
        gMa:update(core.UpdateLast);
        gRsi:update(core.UpdateLast);
        gRsi1:update(core.UpdateLast);

        if gTickSource[period] > gMaData[period] and
           core.crossesUnder(gRsiData, EL, period) then
            ExtSignal(gSource, period, "Enter", SoundFile);
            inPosition = true;
        elseif inPosition and
               core.crossesOver(gRsi1Data, EX, period) then
            ExtSignal(gSource, period, "Exit", SoundFile);
            inPosition = false;
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
