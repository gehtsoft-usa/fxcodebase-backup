-- Id: 2139
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
    strategy:name("Spread Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Spread Signal");	

	strategy.parameters:addGroup("Spread Target Level");
	strategy.parameters:addDouble("TARGET", "Spread Target Level", "", 0 );   
	
	strategy.parameters:addGroup("Spread Selector"); 
    strategy.parameters:addString("PAIR1", "First Currency Pair", " ", "EUR/USD");
    strategy.parameters:setFlag("PAIR1",core.FLAG_INSTRUMENTS);	
	
	strategy.parameters:addString("PAIR2", "Second Currency Pair", " ", "USD/JPY");
    strategy.parameters:setFlag("PAIR2",core.FLAG_INSTRUMENTS);

    strategy.parameters:addGroup("Parameters");
  
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
	strategy.parameters:addBoolean("Recurrent", "RecurrentSound", "", false);
	
	strategy.parameters:addGroup("Email Parameters");
	strategy.parameters:addBoolean("SendEmail", "Send email", "", false);
    strategy.parameters:addString("Email", "Email address", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

local Email;
local RecurrentSound;
local SoundFile;

local IndicatorSource = {}; 
local Parameters={};
local TARGET;

function Prepare()

    Parameters[1]= instance.parameters.PAIR1;
	Parameters[2]= instance.parameters.PAIR2;
    TARGET= instance.parameters.TARGET;
	
    assert(not (Parameters[1] == Parameters[2]), "Selected currency pairs should vary");
	
    RecurrentSound= instance.parameters.Recurrent;
	
	local SendEmail = instance.parameters.SendEmail;
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "Email address must be specified");
	
	    
    ShowAlert = instance.parameters.ShowAlert;
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
	
    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");
    assert(instance.parameters.Period ~= "t1", "Signal cannot be applied on ticks");  
   
	IndicatorSource[1] = ExtSubscribe(1, Parameters[1], instance.parameters.Period, instance.parameters.Type == "Bid", "bar");	
	IndicatorSource[2] = ExtSubscribe(2, Parameters[2], instance.parameters.Period, instance.parameters.Type == "Bid", "bar");	
	    
    local name = profile:id() .. "Spread Signal";
    instance:name(name);
end

local Delta;
local ONE, TWO;
local LAST;
local LEVEL=nil;
-- when tick source is updated
function ExtUpdate(id, source, period)	

            if LAST~= period and ONE ~= nil and TWO ~= nil then
			LAST=period;
			LEVEL = ONE-TWO;
			end		 	   	
			
			if id == 1 then 
			ONE=nil;
			TWO=nil;
			end		

			if id ==1 then
			ONE = IndicatorSource[1].close[period];
			elseif id == 2 then
			TWO = IndicatorSource[2].close[period];
			end
			
			if  ONE ~= nil and TWO ~= nil then			
			Delta= ONE-TWO;
			    
				if   LEVEL ~= nil then
					if LEVEL < TARGET and Delta > TARGET  then 
					ALERT (Delta, "Cross Over ");
					elseif  LEVEL > TARGET and Delta < TARGET then
					ALERT (Delta,"Cross Under ");
					end					
				end	
            end			
          		
end

function ALERT(Label, SIDE)   

                if ShowAlert then
                terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW],SIDE .. Label, instance.bid:date(NOW));
                end

                if SoundFile ~= nil then
                    terminal:alertSound(SoundFile, RecurrentSound);
               end
				
				if Email ~= nil then
				terminal:alertEmail (Email, "Spread Alert between " ..Parameters[1].. " and " ..Parameters[1] .." have " .. SIDE .. " Target ".. TARGET .. " Rate", " Spread Between " ..Parameters[1].. " and " ..Parameters[1] .." have " .. SIDE .. " Target ".. TARGET .. " Rate" )
				end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
