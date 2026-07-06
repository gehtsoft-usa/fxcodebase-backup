-- Id: 582
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
    strategy:name("Big Range Bar Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Big Range Bar Signal");

    strategy.parameters:addGroup("Parameters");

    strategy.parameters:addInteger("FastN", "Fast Period", "", 5,2,1000);
	strategy.parameters:addInteger("MidN", "Mid Period", "", 20,2,1000);
    strategy.parameters:addInteger("SlowN", "Slow Period", "", 50,2,1000);
	strategy.parameters:addInteger("ATRN", "ATR Period", "", 14, 2, 1000);
	
	strategy.parameters:addInteger("BBN", "Bar Lengt (ATR Relativ)", "", 120,1,200);
	
	strategy.parameters:addString("Method", "Price Smoothing method", "", "EMA");
    strategy.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    strategy.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");

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
local FastMA, SlowMA, MidMA, ATR;
local BUY, SELL;
local TickSource = nil; 
local BarSource = nil;         -- the source stream

 local FastN, SlowN, MidN, ATRN;
 
 
local FastFlag, MidFlag, SlowFlag;
local FLAG;
local reset;
local ATRFlag, CloseFlag;
local BBN;

function Prepare()
   

    -- collect parameters
    FastN = instance.parameters.FastN;
	MidN = instance.parameters.MidN;
    SlowN = instance.parameters.SlowN;
	ATRN = instance.parameters.ADXN;
	BBN = instance.parameters.BBN;
	
	
    assert(FastN < MidN,"Number of periods for Fast MA must be less than number of periods for Mid MA");
	assert(MidN < SlowN,"Number of periods for Mid MA must be less than number of periods for Slow MA");

    ShowAlert = instance.parameters.ShowAlert;

    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");

    SELL = "Short";
    BUY = "Long";

    ExtSetupSignal("Big Range Bar Signal", ShowAlert);

    TickSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "close");
	BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");

    assert(core.indicators:findIndicator(instance.parameters.Method) ~= nil, instance.parameters.Method .. " indicator must be installed");
    FastMA = core.indicators:create(instance.parameters.Method, TickSource, FastN);
	MidMA = core.indicators:create(instance.parameters.Method, TickSource, MidN);
    SlowMA = core.indicators:create(instance.parameters.Method, TickSource, SlowN);
	ATR = core.indicators:create("ATR", BarSource, ATRN);
	


    local name = profile:id() .. "(" .. instance.bid:instrument()  .. "(" .. instance.parameters.Period  .. ")" .. "," .. FastN .. "," .. MidN  .. "," .. SlowN .. ")";
    instance:name(name);
end



-- when tick source is updated
function ExtUpdate(id, source, period)
					
					
		
		            FastMA:update(core.UpdateLast);
					MidMA:update(core.UpdateLast);
					SlowMA:update(core.UpdateLast);
					ATR:update(core.UpdateLast);
					
					
					if period > math.max(2, FastN, SlowN, MidN ) then	
					 
					if not(SlowMA.DATA:hasData(period - 1)) then
						return ;
					end
					
				  	if not(MidMA.DATA:hasData(period - 1)) then
				  		return ;
				  	end
					
					if not(FastMA.DATA:hasData(period - 1)) then
				  		return ;
				  	end
					
					if not(ATR.DATA:hasData(period - 1)) then
				  		return ;
				  	end
					
						
						   if core.crossesOver(FastMA.DATA, MidMA.DATA, period)   then
						   FastFlag= "Buy";	
						   reset=1;            		   		   
						   end
						   
						   if core.crossesUnder(FastMA.DATA, MidMA.DATA, period)   then
						   FastFlag= "Sell";	
						   reset=1;            		   
						   end
						   
						   
						   	   
						   if core.crossesOver(MidMA.DATA, SlowMA.DATA, period)   then
						   MidFlag= "Buy";	
						   reset=1;            		   		   
						   end
						   
						   if core.crossesUnder(MidMA.DATA, SlowMA.DATA, period)   then
						   MidFlag= "Sell";	
						   reset=1;            		   
						   end
						   
						   if (BarSource.high[period]- BarSource.low[period]) >  (ATR.DATA[period] /100)* BBN then
						   ATRFlag="Yes"
						   reset=1; 
						   end
						   
						   if (BarSource.high[period]- BarSource.low[period]) <  (ATR.DATA[period] /100)* BBN then
						   ATRFlag="No"
						   reset=1; 
						   end
						   
						   if BarSource.close[period] >  FastMA.DATA[period] then
						   CloseFlag="Buy"
						   reset=1; 
						   end
						   
						   if BarSource.close[period] <  FastMA.DATA[period] then
						   CloseFlag="Sell"
						   reset=1; 
						   end
						   
						   
						
						   if reset== 1 then
						   FLAG=nil;
						   reset=0;
						   end
						   
						   
							if  FastFlag == "Buy" and MidFlag == "Buy" and   FLAG ~= "Buy"  and ATRFlag=="Yes" and  BarSource.open[period] < BarSource.close[period] and CloseFlag=="Buy" then
							FLAG = "Buy";
							ExtSignal(TickSource, period, BUY, SoundFile);
							
							end
							
							if  FastFlag== "Sell" and MidFlag == "Sell" and FLAG ~= "Sell"   and ATRFlag=="Yes" and   BarSource.open[period] > BarSource.close[period] and CloseFlag=="Sell" then
							FLAG = "Sell";
							ExtSignal(TickSource, period, SELL, SoundFile);
							
							end
		end				   
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
