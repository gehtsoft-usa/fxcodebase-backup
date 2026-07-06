-- Id: 1305
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
    strategy:name("SAR EMA MVA Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("SAR EMA MVA Signal");

    strategy.parameters:addGroup("Parameters");

    strategy.parameters:addInteger("FastEMAFrame", "Fast EMA Period", "", 5,2, 2000);
	strategy.parameters:addInteger("SlowEMAFrame", "Slow EMA Period", "", 10,2, 2000);
	strategy.parameters:addInteger("MVAFrame", "MVA Period", "", 20, 2, 1000);
	strategy.parameters:addDouble("SARStep", "SAR Step", "", 0.02, 0.001, 1);
	strategy.parameters:addDouble("SARMax", "SAR MAX", "", 0.2, 0.001, 10);
	
	
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
local FastEMA, SlowEMA, MVA, SAR;
local BUY, SELL;
local BarSource = nil;         -- the source stream

 local FastEMAFrame, SlowEMAFrame, MVAFrame, SARStep, SARMAX;
 
 
local FastFlag;
local EMAFlag, MVAFlag, SARFlag;
local FLAG=nil;
local reset=nil;


function Prepare()
   

    -- collect parameters
    FastEMAFrame = instance.parameters.FastEMAFrame;
	SlowEMAFrame = instance.parameters.SlowEMAFrame;
	
	MVAFrame = instance.parameters.MVAFrame;
			
	SARStep=instance.parameters.SARStep
	SARMAX=instance.parameters.SARMax;
	
    assert(FastEMAFrame < SlowEMAFrame,"Number of periods for Fast EMA must be less than number of periods for Slow EMA");
	

    ShowAlert = instance.parameters.ShowAlert;

    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");

    SELL = "Short";
    BUY = "Long";

    ExtSetupSignal(" SAR EMA MVA", ShowAlert);

    BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");

    FastEMA = core.indicators:create("EMA", BarSource.close, FastEMAFrame);
	SlowEMA = core.indicators:create("EMA", BarSource.close, SlowEMAFrame);
	MVA = core.indicators:create("MVA", BarSource.close, MVAFrame);
	SAR = core.indicators:create("SAR", BarSource, SARStep, SARMax);
	
	
    local name = profile:id() .. "(" .. instance.bid:instrument()  .. "(" .. instance.parameters.Period  .. ")" .. "," .. FastEMAFrame ..",".. SlowEMAFrame .. ",".. MVAFrame ..")";
    instance:name(name);
end



-- when tick source is updated
function ExtUpdate(id, source, period)		 
		
		            FastEMA:update(core.UpdateLast);
					SlowEMA:update(core.UpdateLast);
					MVA:update(core.UpdateLast);
					SAR:update(core.UpdateLast);
					
					if period > math.max( MVAFrame, FastEMAFrame, SlowEMAFrame) then	
					
					
					    					 
					
					     if SAR.DATA[period] < BarSource.close[period]  and   SARFlag ~= "Buy" then
						   SARFlag= "Buy";	
						   reset=1;            		   		   
						   end
						   
						   if SAR.DATA[period] > BarSource.close[period]  and   SARFlag ~= "Sell"  then
						   SARFlag= "Sell";	
						   reset=1;            		   
						   end
                           
						   
						   if core.crossesOver(FastEMA.DATA, SlowEMA.DATA, period)   then
						   EMAFlag= "Buy";	
						   reset=1;            		   		   
						   end
						   
						   if core.crossesUnder(FastEMA.DATA, SlowEMA.DATA, period)   then
						   EMAFlag= "Sell";	
						   reset=1;            		   
						   end
						   
						   if core.crossesOver(BarSource.close, MVA.DATA, period)   then
						   MVAFlag= "Buy";	
						   reset=1;            		   		   
						   end
						   
						   if core.crossesUnder(BarSource.close, MVA.DATA, period)   then
						   MVAFlag= "Sell";	
						   reset=1;            		   
						   end
						
						
						   if reset== 1 then
						   FLAG=nil;
						   reset=0;
						   end
						   
						   
							if  EMAFlag == "Buy" and   MVAFlag == "Buy" and  SARFlag == "Buy"  and FLAG~="Buy"  then
							FLAG = "Buy";
							ExtSignal(BarSource.close, period, BUY, SoundFile);
							end
							
							if  EMAFlag == "Sell" and   MVAFlag == "Sell" and  SARFlag == "Sell"  and FLAG~="Sell" then
							FLAG = "Sell";
							ExtSignal(BarSource.close, period, SELL, SoundFile);							
							end
		end				   
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
