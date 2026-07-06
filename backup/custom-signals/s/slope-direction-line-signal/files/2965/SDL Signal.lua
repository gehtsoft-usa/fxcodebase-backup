-- Id: 2333
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
    strategy:name("Slope direction line Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Slope direction line Signal");

    strategy.parameters:addGroup("Parameters");
  
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
	
	strategy.parameters:addInteger("Frame", "Period", "Period", 80);
	
    strategy.parameters:addString("Method", "Method", "", "MVA");
    strategy.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    strategy.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    strategy.parameters:addStringAlternative("Method", "TMA", "", "TMA"); 
	
	strategy.parameters:addInteger("IN" , "Data Source", "", 4);
    strategy.parameters:addIntegerAlternative("IN" , "Open", "", 1);
    strategy.parameters:addIntegerAlternative("IN", "High", "", 2);
    strategy.parameters:addIntegerAlternative("IN" , "Low", "", 3);
	strategy.parameters:addIntegerAlternative("IN" , "Close", "", 4);
	strategy.parameters:addIntegerAlternative("IN", "Median", "", 5);
    strategy.parameters:addIntegerAlternative("IN" , "Typical", "", 6);
	strategy.parameters:addIntegerAlternative("IN" , "Weighted ", "", 7);
	
   
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

local SDL;

local Up;
local Down;
local IN;
local Price;

local BarSource = nil; 


function Prepare()
   
    ShowAlert = instance.parameters.ShowAlert;
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
	
	Frame = instance.parameters.Frame;
	Method = instance.parameters.Method;
	Price = instance.parameters.Price;
	IN = instance.parameters.IN;   

    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");
    assert(instance.parameters.Period ~= "t1", "Signal cannot be applied on ticks");

    
	Up = " Up Trend";
	Down = " Down Trend";
	
    ExtSetupSignal("Slope direction line", ShowAlert);

    BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
	
	    if IN == 1 then
		Price= BarSource.open;
		elseif  IN == 2 then
		Price= BarSource.high;
		elseif  IN == 3 then
		Price= BarSource.low;
		elseif  IN == 4 then
		Price= BarSource.close;
		elseif  IN == 5 then
		Price= BarSource.median;
		elseif  IN == 6 then
		Price= BarSource.typical;
		elseif  IN == 7 then
		Price= BarSource.weighted;
		end
		
    assert(core.indicators:findIndicator("SLOPE_DIRECTION_LINE") ~= nil, "SLOPE_DIRECTION_LINE" .. " indicator must be installed");
	SDL  = core.indicators:create("SLOPE_DIRECTION_LINE",Price, Frame, Method, true )	
	    
    local name = profile:id() .. "Slope direction line";
    instance:name(name);
end



function ExtUpdate(id, source, period)

    SDL:update(core.UpdateLast);
	
			if SDL.DATA:hasData(period)	and  SDL.DATA:hasData(period-1) then
							if  core.crossesOver( BarSource.close, SDL.Trend, period)  then						
							   ExtSignal(BarSource.close, period, Up, SoundFile);							
							end
							
							if  core.crossesUnder( BarSource.close, SDL.Trend, period)   then	
							    ExtSignal(BarSource.close, period, Down, SoundFile);
							end
            end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
