-- Id: 753
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
    strategy:name("Heikin-Ashi Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Heikin-Ashi Signal");

    strategy.parameters:addGroup("Parameters");

	 strategy.parameters:addBoolean("Wick", "Wick Filtering", "", false);
 
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
local BUY, SELL;
local BarSource = nil;         -- the source stream
local HA=nil;
local FLAG=nil;
local Wick=nil;

function Prepare()
   

    -- collect parameters
   
    ShowAlert = instance.parameters.ShowAlert;
	Wick = instance.parameters.Wick;

    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");

    SELL = "Short";
    BUY = "Long";

    ExtSetupSignal("Heikin-Ashi Signal", ShowAlert);

    BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");

    HA = core.indicators:create("HA", BarSource);
	
    local name = profile:id() .. "(" .. instance.bid:instrument()  .. ")" 
    instance:name(name);
end



-- when tick source is updated
function ExtUpdate(id, source, period)		
				
		
		            HA:update(core.UpdateLast);	
					
										
					if not(HA.close:hasData(period - 1)) then
				  		return ;
				  	end

					
					
							if  HA.open[period] < HA.close[period] and FLAG~="Buy" then
							    if not Wick then
							    FLAG = "Buy";
								ExtSignal(BarSource.close, period, BUY, SoundFile);
								elseif HA.open[period] < HA.close[period] and FLAG~="Buy" and HA.low[period]== HA.open[period] then
								FLAG = "Buy";
								ExtSignal(BarSource.close, period, BUY, SoundFile);
								end
							end
							
							if  HA.open[period] > HA.close[period] and FLAG~="Sell" then
								if not Wick then
								FLAG = "Sell";
								ExtSignal(BarSource.close, period, SELL, SoundFile);
								elseif HA.open[period] > HA.close[period] and FLAG~="Sell" and HA.high[period]== HA.open[period] then
								FLAG = "Sell";
								ExtSignal(BarSource.close, period, SELL, SoundFile);
								end
							
							end
							
					   
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
