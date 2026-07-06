-- Id: 892
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
    strategy:name("CASH COW STRATEGY SIGNAL");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("CASH COW STRATEGY SIGNAL");

    strategy.parameters:addGroup("Parameters");
	
	strategy.parameters:addInteger("Short", "Short Moving Average Period", "Short Moving Average Period", 5,2,2000);
	strategy.parameters:addInteger("Long", " Long Moving Average Period", "Long Moving Average Period", 20,2,2000);
    strategy.parameters:addDouble("Bottom", "Band Offset in percent", "Band Offset in percent", 1.2,0,100);
    strategy.parameters:addDouble("Top", "Band Offset in percent", "Band Offset in percent", 0.6,0,100);
		 
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
local CCSS = nil; 

local ShortSMA; 
local LongSMA; 

local ShortFrame;
local LongFrame;

local Top;
local Bottom;

local UP;
local DOWN;

function Prepare()
    -- collect parameters
	
	   
    ShowAlert = instance.parameters.ShowAlert;
	
	ShortFrame = instance.parameters.Short;
	LongFrame = instance.parameters.Long;
    Top = instance.parameters.Top;
    Bottom = instance.parameters.Bottom;
	
	
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
	
	
     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");

    SELL = " Short Set Up";
    BUY = " Long Set Up";

    ExtSetupSignal("CASH COW STRATEGY", ShowAlert);

   BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");
   
	ShortSMA = core.indicators:create("MVA", BarSource.close, ShortFrame);
	LongSMA = core.indicators:create("MVA", BarSource.close, LongFrame);
	
    local name = profile:id() .. "(" .. instance.bid:instrument()  .. ")" 
    instance:name(name);
end


-- when tick source is updated
function ExtUpdate(id, source, period)	
       
    ShortSMA:update(core.UpdateLast);
	LongSMA:update(core.UpdateLast);
	 
	 	          if not(ShortSMA.DATA:hasData(period - 1)) then
				  		return ;
				  	end
					
				  if not(LongSMA.DATA:hasData(period - 1)) then
				  		return ;
				  	end	
					
					
			 if ShortSMA.DATA[period] >  LongSMA.DATA[period] then
		
				UP= (Top+ 100)/100;
				DOWN=  (100-Bottom)/100;
				  
				High=  ShortSMA.DATA[period]*UP;
				Central=ShortSMA.DATA[period];
				Low=  ShortSMA.DATA[period]*DOWN;

            elseif ShortSMA.DATA[period] <  LongSMA.DATA[period] then
		
				UP= (Bottom+ 100)/100;
				DOWN=  (100-Top)/100;
				 
				Low=  ShortSMA.DATA[period]*UP;
				Central=ShortSMA.DATA[period];
				High=  ShortSMA.DATA[period]*DOWN;
			 
            end	
			

		   if  BarSource.high[period] <  High and  BarSource.high[period] > Central and  BarSource.close[period] < Central and  BarSource.close[period] > Low then
			     if ShortSMA.DATA[period] > ShortSMA.DATA[period-1] and LongSMA.DATA[period] > LongSMA.DATA[period-1] then
			    ExtSignal(BarSource.close, period, BUY, SoundFile);
				 end
			end
	
				
			if  BarSource.low[period] >  High and  BarSource.low[period] < Central and  BarSource.close[period] > Central and  BarSource.close[period] < Low then
				if ShortSMA.DATA[period] < ShortSMA.DATA[period-1] and LongSMA.DATA[period] < LongSMA.DATA[period-1] then
				ExtSignal(BarSource.close, period, SELL, SoundFile);
				end
			end	
				
				
						  
							   
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
