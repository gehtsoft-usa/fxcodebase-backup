-- Id: 1245
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
    strategy:name("Money Generator signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Money Generator signal");

    strategy.parameters:addGroup("Parameters");


    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addDouble("KAMAFrame", "KAMA Number of periods", "KAMA Number of periods", 2, 2, 2000);
    strategy.parameters:addDouble("MVAFrame", "MVA Number of periods", "MVA Number of periods", 7, 2, 2000);

    strategy.parameters:addString("Period", "Timeframe", "", "m5");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
end

local KAMAFrame=nil;
local MVAFrame=nil;

local KAMA=nil;
local MVA=nil;

local ShowAlert;
local SoundFile;
local BUY, SELL;
local BarSource = nil;         -- the source stream
local first;

function Prepare()

    ShowAlert = instance.parameters.ShowAlert;

    MVAFrame=instance.parameters.MVAFrame;
	KAMAFrame=instance.parameters.KAMAFrame;
	
	

    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");

    BUY = " Up Trend";
    SELL = " Down Trend";

    ExtSetupSignal(" Money Generator", ShowAlert);

    BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
	
	
	KAMA  = core.indicators:create("KAMA", BarSource.close, KAMAFrame);
	MVA  = core.indicators:create("MVA", KAMA.DATA, MVAFrame);
    

    local name = profile:id() .. " ( " .. instance.bid:instrument()  .. " ( " .. instance.parameters.Period  .. " ) ".. MVAFrame .. ", ".. KAMAFrame .." )";
    instance:name(name);
end



-- when tick source is updated
function ExtUpdate(id, source, period)

    KAMA:update(core.UpdateLast);
	MVA:update(core.UpdateLast);
	
    if period > math.max(MVAFrame, KAMAFrame) +1  then
           if core.crossesOver(KAMA.DATA, MVA.DATA, period) then
                ExtSignal(BarSource.close, period, BUY, SoundFile);
           elseif core.crossesUnder(KAMA.DATA, MVA.DATA, period) then
                ExtSignal(BarSource.close, period, SELL, SoundFile);
            end
    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
