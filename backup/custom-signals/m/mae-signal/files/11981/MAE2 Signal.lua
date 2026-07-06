-- Id: 4171
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
    strategy:name("MAE2 Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("MAE2 Signal");

    
	strategy.parameters:addGroup("Calculation");
    strategy.parameters:addInteger("N", "Number of periods for Moving Average", "", 14);
    strategy.parameters:addString("MET", "Moving Average Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "MVA");
    strategy.parameters:addStringAlternative("MET", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("MET", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("MET", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("MET", "SMMA*", "", "SMMA");
    strategy.parameters:addStringAlternative("MET", "Vidya (1995)*", "", "VIDYA");
    strategy.parameters:addStringAlternative("MET", "Vidya (1992)*", "", "VIDYA92");
    strategy.parameters:addStringAlternative("MET", "Wilders*", "", "WMA");

    strategy.parameters:addInteger("B", "Band Width", "", 25);
    strategy.parameters:addString("BWU", "Band Width Units", "", "%%");
   strategy.parameters:addStringAlternative("BWU", "In 1/100 of percent", "", "%%");
    strategy.parameters:addStringAlternative("BWU", "In pips", "", "pip(s)");
	
	strategy.parameters:addBoolean("SM", "Show MA line", "", true);
 
   strategy.parameters:addString("T", "CrossOver Type", "", "C");
    strategy.parameters:addStringAlternative("T", "Touch", "", "HL");
    strategy.parameters:addStringAlternative("T", "Cross", "", "C");
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


local first;
local Email;

local IND;

-- Streams block
local MVA = nil;
local tsource = nil;

local N;
local B;
local BWU;
local MET;
local SM;

local T;

function Prepare()

    T = instance.parameters.T;
      N = instance.parameters.N;
    B = instance.parameters.B;
    BWU = instance.parameters.BWU;
    MET = instance.parameters.MET;
    SM = instance.parameters.SM;
	
	
	

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

		 
    local name;
		
    name  = profile:id() .. "(" .. instance.bid:instrument() .. "," .. MET .. "(" .. N .. ")," .. B .. ", " .. BWU .. ")";
    instance:name(name);    
	
	 tsource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
    assert(core.indicators:findIndicator("MAE2") ~= nil, "MAE2" .. " indicator must be installed");
     IND = core.indicators:create("MAE2", tsource.close, N, MET , B, BWU, SM);   
        first = IND.DATA:first() + 1;
		
	
    ExtSetupSignal(name .. ":", ShowAlert);
    ExtSetupSignalMail(name);

   
end

function ExtUpdate(id, source, period)
   
       
    if id ==1 and period > first then
    
        IND:update(core.UpdateLast);

       
		
		
		if T == "C" or  T == "B" then
					if core.crossesOver(tsource.close, IND.UB, period, period-1) then
					ExtSignal(instance.bid, instance.bid:size() - 1, "Upper Belt CrossesOver", SoundFile, Email);
					end
					
					if core.crossesUnder(tsource.close, IND.UB, period, period-1) then
					ExtSignal(instance.bid, instance.bid:size() - 1, "Upper Belt CrossesUnder", SoundFile, Email);
					end
					
					if core.crossesUnder(tsource.close, IND.LB, period, period-1) then
					ExtSignal(instance.bid, instance.bid:size() - 1, "Lower Belt CrossesUnder", SoundFile, Email);
					end		
					
					if core.crossesOver(tsource.close,IND.LB, period, period-1) then
					ExtSignal(instance.bid, instance.bid:size() - 1, "Lower Belt CrossesOver", SoundFile, Email);
					end		
					
					if SM then
					
							if core.crossesUnder(tsource.close, IND.MVA, period, period-1) then
							ExtSignal(instance.bid, instance.bid:size() - 1, "Central Line CrossesUnder", SoundFile, Email);
							end		
							
							if core.crossesOver(tsource.close, IND.MVA, period, period-1) then
							ExtSignal(instance.bid, instance.bid:size() - 1, "Central Line CrossesOver", SoundFile, Email);
							end		
					end
		end
		if T == "HL" or  T == "B"  then
		
		          
					 if tsource.low[period] < IND.UB[period]  and tsource.high[period-1] > IND.UB[period] then
					
					ExtSignal(instance.bid, instance.bid:size() - 1, "Upper Belt Touch", SoundFile, Email);
					end				
					
				
					
					if tsource.low[period] < IND.LB[period] and tsource.high[period] > IND.LB[period]  then
					ExtSignal(instance.bid, instance.bid:size() - 1, "Lower Belt Touch", SoundFile, Email);
					end		
					
					
					if SM then
							if tsource.low[period] < IND.MVA[period] and tsource.high[period] > IND.MVA[period]  then
							ExtSignal(instance.bid, instance.bid:size() - 1, "Central Line Touch", SoundFile, Email);
							end		
					end
		end

    end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");