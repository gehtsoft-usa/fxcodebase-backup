-- Id: 1696
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
    strategy:name("MAE Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("MAE Signal");

    
	strategy.parameters:addGroup("MAE Parameters");
    strategy.parameters:addInteger("N", "Number of periods of Moving Average", "", 7, 2, 1000);
	strategy.parameters:addDouble("Upper", "Upper percentage value", "", 0.5, 0, 10.);
    strategy.parameters:addDouble("Lower", "Lower percentage value", "", 0.5, 0, 10.);
	
	strategy.parameters:addString("T", "CrossOver Type", "", "C");
    strategy.parameters:addStringAlternative("T", "High / Low", "", "HL");
    strategy.parameters:addStringAlternative("T", "Close", "", "C");
	 strategy.parameters:addStringAlternative("T", "Both", "", "B");
 

    strategy.parameters:addGroup("Price Parameters");
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
    strategy.parameters:addString("Period", "Timeframe", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
   strategy.parameters:addFile("SoundFile", "Sound File", "", "");
	 strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    strategy.parameters:addBoolean("SendEmail", "Send email", "", false);
    strategy.parameters:addString("Email", "Email address", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local tsource = nil;
local MAE;
local first;
local N;
local Upper;
local Lower;
local Email;

function Prepare()
    local ShowAlert, PlaySound, SendEmail;

    ShowAlert = instance.parameters.ShowAlert;

    local PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");

    SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "Email address must be specified");

	N = instance.parameters.N;
	Lower = instance.parameters.Lower;
    Upper = instance.parameters.Upper;
	T = instance.parameters.T; 
	 
    local name;
		
    name = profile:id() .. "(" .. instance.bid:instrument()  .. "[" .. instance.parameters.Period  .. "]" ..
                           "," .. N  .. "," .. Upper .. ", ".. Lower  .. ")";
    instance:name(name);    

    ExtSetupSignal(name .. ":", ShowAlert);
    ExtSetupSignalMail(name);

    ExtSubscribe(1, nil, "t1", true, "close");
end

function ExtUpdate(id, source, period)
    if id == 1 and tsource == nil then
        tsource = ExtSubscribe(2, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
        MAE = core.indicators:create("MAE", tsource.close, N, Upper, Lower);
        first = MAE.DATA:first() + 1;
    elseif id == 2 and period > first then
        MAE:update(core.UpdateLast);
		
		
		if T == "C" or  T == "B" then
					if core.crossesOver(tsource.close, MAE.ME1, period, period-1) then
					ExtSignal(instance.bid, instance.bid:size() - 1, "Upper Belt CrossesOver", SoundFile, Email);
					end
					
					if core.crossesUnder(tsource.close, MAE.ME1, period, period-1) then
					ExtSignal(instance.bid, instance.bid:size() - 1, "Upper Belt CrossesUnder", SoundFile, Email);
					end
					
					if core.crossesUnder(tsource.close, MAE.ME2, period, period-1) then
					ExtSignal(instance.bid, instance.bid:size() - 1, "Lower Belt CrossesUnder", SoundFile, Email);
					end		
					
					if core.crossesOver(tsource.close, MAE.ME2, period, period-1) then
					ExtSignal(instance.bid, instance.bid:size() - 1, "Lower Belt CrossesOver", SoundFile, Email);
					end		
		end
		if T == "HL" or  T == "B"  then
		
		          
					
					 if tsource.low[period] < MAE.ME1[period]  and tsource.high[period-1] > MAE.ME1[period] then
					ExtSignal(instance.bid, instance.bid:size() - 1, "Upper Belt Touch", SoundFile, Email);
					end				
					
				
					
					if tsource.low[period] < MAE.ME2[period] and tsource.high[period] > MAE.ME2[period]  then
					ExtSignal(instance.bid, instance.bid:size() - 1, "Lower Belt Touch", SoundFile, Email);
					end		
		end

    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");