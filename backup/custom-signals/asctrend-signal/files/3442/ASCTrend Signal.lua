-- Id: 1194
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
    strategy:name("ASCTrend Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("ASCTrend Signal");

    strategy.parameters:addGroup("Parameters");

     strategy.parameters:addInteger("RISK", "RISK", "No description", 3);
	
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

local ASC=nil;

local BUY, SELL;

local BarSource = nil;         -- the source stream

local RISK;
 
 local Flag=nil;

function Prepare()

    -- collect parameters
    RISK = instance.parameters.RISK;
    ShowAlert = instance.parameters.ShowAlert;

    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");

    SELL = " Up Trend";
    BUY = " Down Trend";

    ExtSetupSignal("  ASCTREND", ShowAlert);

    BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");

    assert(core.indicators:findIndicator("ASCTREND") ~= nil, "ASCTREND" .. " indicator must be installed");
    ASC = core.indicators:create("ASCTREND", BarSource, RISK, true);

	
    local name = profile:id() .. "(" .. instance.bid:instrument()  .. "(" .. instance.parameters.Period  .. ")" .. "," .. RISK ..")";
    instance:name(name);
	
	Flag=nil;
end



-- when tick source is updated
function ExtUpdate(id, source, period)

    
		
		            ASC:update(core.UpdateLast);
						   
						if  ASC.buff[period]  ==  1 and Flag ~= "Buy"  then
							ExtSignal(BarSource.close, period, BUY, SoundFile);
							Flag="Buy"
						end
						
						if  ASC.buff[period]  ==  -1  and Flag~= "Sell"  then
							 ExtSignal(BarSource.close, period, SELL, SoundFile);
							 Flag="Sell";
						end
							
					   
						   
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
