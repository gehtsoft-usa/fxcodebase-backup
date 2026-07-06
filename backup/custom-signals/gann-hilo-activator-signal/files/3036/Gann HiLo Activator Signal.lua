-- Id: 1053
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
    strategy:name("Gann HiLo Activator Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Simple Gann HiLo Activator Signal");

    strategy.parameters:addGroup("Parameters");
  
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
	
	strategy.parameters:addInteger("Frame", "Period", "Period", 10);
	  
    strategy.parameters:addString("Period", "Timeframe", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
end

local SoundFile;

local Frame;
local Method;
local Price;

local GHLA=nil;

local Up;
local Down;


local BarSource = nil; 


function Prepare()
   
    ShowAlert = instance.parameters.ShowAlert;
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
	
	Frame = instance.parameters.Frame;
	   

    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");
    assert(instance.parameters.Period ~= "t1", "Signal cannot be applied on ticks");

    
	Up = " Up Trend";
	Down = " Down Trend";
	
    ExtSetupSignal(" Gann HiLo Activator", ShowAlert);
	assert(core.indicators:findIndicator("GHLA") ~= nil, "Please, download and install GHLA.LUA indicator");

    BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
		
	GHLA  = core.indicators:create("GHLA", BarSource, Frame);
	
	    
    local name = profile:id() .. "Gann HiLo Activator";
    instance:name(name);
end



function ExtUpdate(id, source, period)


    if period > Frame then
	
	
                            GHLA:update(core.UpdateLast);
	
				
							if  core.crossesOver( BarSource.close, GHLA.DATA, period)  then						
							   ExtSignal(BarSource.close, period, Up, SoundFile);							
							end
							
							if  core.crossesUnder( BarSource.close, GHLA.DATA, period)   then	
							    ExtSignal(BarSource.close, period, Down, SoundFile);
							end
							
	end						
  
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
