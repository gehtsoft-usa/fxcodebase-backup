-- Id: 1179
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
    strategy:name("Kuskus Starlight signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Kuskus Starlight signal");

    strategy.parameters:addGroup("Parameters");


    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addInteger("R", "RangePeriods", "RangePeriods", 30);
    strategy.parameters:addDouble("P", "PriceSmoothing", "PriceSmoothing", 0.3);
    strategy.parameters:addDouble("I", "IndexSmoothing", "IndexSmoothing", 0.3);

    strategy.parameters:addString("Period", "Timeframe", "", "m5");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
end

local Range=nil;
local  Price=nil;
local  Index=nil;

local KUSKUS=nil;

local ShowAlert;
local SoundFile;
local BUY, SELL;
local BarSource = nil;         -- the source stream
local first;

function Prepare()

    ShowAlert = instance.parameters.ShowAlert;

    Range=instance.parameters.R;
    Price=instance.parameters.P;
    Index=instance.parameters.I;


    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");

    BUY = " Up Trend";
    SELL = " Down Trend";

    ExtSetupSignal(" Kuskus Starlight", ShowAlert);

    BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");

    assert(core.indicators:findIndicator("KUSKUS_STARLIGHT") ~= nil, "KUSKUS_STARLIGHT" .. " indicator must be installed");
    KUSKUS  = core.indicators:create("KUSKUS_STARLIGHT", BarSource, Range, Price, Index, true)
    first = KUSKUS.DATA:first() + 1;

    local name = profile:id() .. " ( " .. instance.bid:instrument()  .. " ( " .. instance.parameters.Period  .. " ) ".. Range.. ", ".. Price..", " .. Index .." )";
    instance:name(name);
end



-- when tick source is updated
function ExtUpdate(id, source, period)

    KUSKUS:update(core.UpdateLast);
    if period > first then
           if core.crossesOver(KUSKUS.DATA, 0, period) then
                ExtSignal(BarSource.close, period, BUY, SoundFile);
           elseif core.crossesUnder(KUSKUS.DATA, 0, period) then
                ExtSignal(BarSource.close, period, SELL, SoundFile);
            end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
