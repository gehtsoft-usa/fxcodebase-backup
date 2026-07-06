-- Id: 982
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
    strategy:name("Advanced Moving Average Strategy");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("");

    strategy.parameters:addGroup("Fast Moving Average");
    strategy.parameters:addInteger("FMA_N", "Fast Moving Average Period", "", 5);
    strategy.parameters:addString("FMA_M", "Moving Average Method", "The methods marked by an asterisk (*) require the appropriate strategys to be loaded.", "MVA");
    strategy.parameters:addStringAlternative("FMA_M", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("FMA_M", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("FMA_M", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("FMA_M", "TMA", "", "TMA");
    strategy.parameters:addStringAlternative("FMA_M", "SMMA*", "", "SMMA");
    strategy.parameters:addStringAlternative("FMA_M", "Vidya (1995)*", "", "VIDYA");
    strategy.parameters:addStringAlternative("FMA_M", "Vidya (1992)*", "", "VIDYA92");
    strategy.parameters:addStringAlternative("FMA_M", "Wilders*", "", "WMA");
    strategy.parameters:addStringAlternative("FMA_M", "TEMA*", "", "TEMA1");
    strategy.parameters:addString("FMA_P", "Fast Moving Average Price", "", "C");
    strategy.parameters:addStringAlternative("FMA_P", "Open", "", "O");
    strategy.parameters:addStringAlternative("FMA_P", "High", "", "H");
    strategy.parameters:addStringAlternative("FMA_P", "Low", "", "L");
    strategy.parameters:addStringAlternative("FMA_P", "Close", "", "C");
    strategy.parameters:addStringAlternative("FMA_P", "Median", "", "M");
    strategy.parameters:addStringAlternative("FMA_P", "Typical", "", "T");
    strategy.parameters:addStringAlternative("FMA_P", "Weighted", "", "W");
    strategy.parameters:addInteger("FMA_ST", "Fast Moving Average Time Shift (in bars)", "", 0, 0, 200);

    strategy.parameters:addGroup("Slow Moving Average");
    strategy.parameters:addInteger("SMA_N", "Slow Moving Average Period", "", 20);
    strategy.parameters:addString("SMA_M", "Moving Average Method", "The methods marked by an asterisk (*) require the appropriate strategys to be loaded.", "MVA");
    strategy.parameters:addStringAlternative("SMA_M", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("SMA_M", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("SMA_M", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("SMA_M", "TMA", "", "TMA");
    strategy.parameters:addStringAlternative("SMA_M", "SMMA*", "", "SMMA");
    strategy.parameters:addStringAlternative("SMA_M", "Vidya (1995)*", "", "VIDYA");
    strategy.parameters:addStringAlternative("SMA_M", "Vidya (1992)*", "", "VIDYA92");
    strategy.parameters:addStringAlternative("SMA_M", "Wilders*", "", "WMA");
    strategy.parameters:addStringAlternative("SMA_M", "TEMA*", "", "TEMA1");
    strategy.parameters:addString("SMA_P", "Slow Moving Average Price", "", "C");
    strategy.parameters:addStringAlternative("SMA_P", "Open", "", "O");
    strategy.parameters:addStringAlternative("SMA_P", "High", "", "H");
    strategy.parameters:addStringAlternative("SMA_P", "Low", "", "L");
    strategy.parameters:addStringAlternative("SMA_P", "Close", "", "C");
    strategy.parameters:addStringAlternative("SMA_P", "Median", "", "M");
    strategy.parameters:addStringAlternative("SMA_P", "Typical", "", "T");
    strategy.parameters:addStringAlternative("SMA_P", "Weighted", "", "W");
    strategy.parameters:addInteger("SMA_ST", "Slow Moving Average Time Shift (in bars)", "", 0, 0, 200);

    strategy.parameters:addGroup("Price History");
    strategy.parameters:addString("PriceType", "Price Type", "", "Bid");
    strategy.parameters:addStringAlternative("PriceType", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("PriceType", "Bid", "", "Ask");
    strategy.parameters:addString("Period", "Time frame", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Alert");
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound file", "", "");
	
	strategy.parameters:addString("ALLOWEDSIDE", "Allowed side", "Allowed signal side, can be CrossUnder, CrossOver or Both", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Both", "", "Both");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Over", "", "Over");
    strategy.parameters:addStringAlternative("ALLOWEDSIDE", "Under", "", "Under");
end

local gSource;
local FMA, SMA;
local first;
local ALLOWEDSIDE;
function CreateIndicator(method, n, price, st)
    local source;
    if price == "O" then
        source = gSource.open;
    elseif price == "H" then
        source = gSource.high;
    elseif price == "L" then
        source = gSource.low;
    elseif price == "C" then
        source = gSource.close;
    elseif price == "M" then
        source = gSource.median;
    elseif price == "T" then
        source = gSource.typical;
    elseif price == "W" then
        source = gSource.weighted;
    end
    assert(core.indicators:findIndicator("SHIFT_MA") ~= nil, "SHIFT_MA" .. " indicator must be installed");
    return core.indicators:create("SHIFT_MA", source, n, method, st, 0);
end

function Prepare()
    local ShowAlert;

    ShowAlert = instance.parameters.ShowAlert;
	ALLOWEDSIDE= instance.parameters.ALLOWEDSIDE;
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");
    ExtSetupSignal(profile:id() .. ":", ShowAlert);

    assert(instance.parameters.Period ~= "t1", "Can't be applied on ticks!");
    gSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.PriceType == "Bid", "bar");

    FMA = CreateIndicator(instance.parameters.FMA_M, instance.parameters.FMA_N, instance.parameters.FMA_P, instance.parameters.FMA_ST);
    SMA = CreateIndicator(instance.parameters.SMA_M, instance.parameters.SMA_N, instance.parameters.SMA_P, instance.parameters.SMA_ST );

    first = math.max(FMA.DATA:first(), SMA.DATA:first()) + 1;

    local name = profile:id() .. "(" .. gSource:name() .. ", " .. instance.parameters.FMA_M .. "," .. instance.parameters.FMA_N .. "," .. instance.parameters.FMA_P .. "," .. instance.parameters.FMA_ST 
                                                       .. ", " .. instance.parameters.SMA_M .. "," .. instance.parameters.SMA_N .. "," .. instance.parameters.SMA_P .. "," .. instance.parameters.SMA_ST  .. ")";
    instance:name(name);
end

function ExtUpdate(id, source, period)
    FMA:update(core.UpdateLast);
    SMA:update(core.UpdateLast);
    if id == 1 and period > first then
        if core.crossesOver(FMA.DATA, SMA.DATA, period) and ALLOWEDSIDE ~= "Under"  then         
            ExtSignal(gSource, period, "Fast over Slow", SoundFile);
        elseif core.crossesOver(FMA.DATA, SMA.DATA, period)and ALLOWEDSIDE ~= "Over" then
            ExtSignal(gSource, period, "Fast under Slow", SoundFile);
        end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
