-- Id: 1165
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
    strategy:name("Slope direction line oscillator signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Slope direction line oscillator signal");

    strategy.parameters:addGroup("Parameters");

	
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
	
	
	strategy.parameters:addInteger("Frame1", "Short Period", " Short Period", 40);
		
	strategy.parameters:addString("Method1", "Method1", "", "SMA");
    strategy.parameters:addStringAlternative("Method1", "SMA", "", "SMA");
    strategy.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
    strategy.parameters:addString("Price1", "Price", "", "close");
    strategy.parameters:addStringAlternative("Price1", "open", "", "open");
    strategy.parameters:addStringAlternative("Price1", "close", "", "close");
    strategy.parameters:addStringAlternative("Price1", "high", "", "high");
    strategy.parameters:addStringAlternative("Price1", "low", "", "low");
	
	strategy.parameters:addInteger("Frame2", "Long Period", " Long Period", 80);
	
	strategy.parameters:addString("Method2", "Method2", "", "SMA");
    strategy.parameters:addStringAlternative("Method2", "SMA", "", "SMA");
    strategy.parameters:addStringAlternative("Method2", "EMA", "", "EMA");
    strategy.parameters:addString("Price2", "Price", "", "close");
    strategy.parameters:addStringAlternative("Price2", "open", "", "open");
    strategy.parameters:addStringAlternative("Price2", "close", "", "close");
    strategy.parameters:addStringAlternative("Price2", "high", "", "high");
    strategy.parameters:addStringAlternative("Price2", "low", "", "low");
	

    strategy.parameters:addString("Period", "Timeframe", "", "m5");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
end

local Price1, Price2,Method1, Method2, Frame1, Frame2 ;

local SDLO=nil;

local Flag=nil;

local ShowAlert;
local SoundFile;
local BUY, SELL, NEUTRAL;
local BarSource = nil;         -- the source stream

function Prepare()
    
    ShowAlert = instance.parameters.ShowAlert;
	
	Price1=instance.parameters.Price1; 
	Price2=instance.parameters.Price2; 
	Method1=instance.parameters.Method1;
	Method2=instance.parameters.Method2; 
	Frame1=instance.parameters.Frame1;
	Frame2=instance.parameters.Frame2;

    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");

    BUY = " Up Trend";
    SELL = " Down Trend";
	NEUTRAL = " Indefinite Trend";

    ExtSetupSignal(" Slope direction line oscillator", ShowAlert);

    BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
	
    assert(core.indicators:findIndicator("SDLO") ~= nil, "SDLO" .. " indicator must be installed");
	SDLO  = core.indicators:create("SDLO", BarSource, Frame1,  Method1, Price1, Frame2,  Method2, Price2);
	
    local name = profile:id() .. "(" .. instance.bid:instrument()  .. "(" .. instance.parameters.Period  .. ")" ..")";
    instance:name(name);
end



-- when tick source is updated
function ExtUpdate(id, source, period)


        if period > math.max(Frame1, Frame2) then	

        SDLO:update(core.UpdateLast);
							
							
									if SDLO.UP[period] == 1 and  SDLO.UP[period-1]~=1  and Flag ~= "Buy" then
									ExtSignal(BarSource.close, period, BUY, SoundFile);
									Flag="Buy"
									end
									
									if SDLO.DOWN[period] == 1 and  SDLO.DOWN[period-1]~=1  and Flag ~= "Sell"  then
									ExtSignal(BarSource.close, period, SELL, SoundFile);
                                    Flag="Sell"									
									end
									
									if SDLO.NEUTRAL[period] == 1 and  SDLO.NEUTRAL[period-1]~=1  and Flag ~= "Neutral"  then
									ExtSignal(BarSource.close, period, NEUTRAL, SoundFile);
                                    Flag="Neutral"									
									end
									
							
		end					
					   
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
