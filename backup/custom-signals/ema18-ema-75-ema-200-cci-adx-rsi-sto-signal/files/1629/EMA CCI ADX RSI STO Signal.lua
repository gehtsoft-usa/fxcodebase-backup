-- Id: 1302
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
    strategy:name("EMA CCI ADX RSI Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("EMA CCI ADX RSI STO Signal");

    strategy.parameters:addGroup("Parameters");

    strategy.parameters:addInteger("FastN", "Fast Period", "", 18);
	 strategy.parameters:addInteger("MidN", "Mid Period", "", 75);
    strategy.parameters:addInteger("SlowN", "Slow Period", "", 200);
	strategy.parameters:addInteger("ADXN", "ADX Period", "", 14, 2, 1000);
	strategy.parameters:addInteger("RSIN", "RSI Period", "", 14, 2, 1000);
	strategy.parameters:addInteger("CCIN", "CCI Period", "", 30, 2, 1000);
	strategy.parameters:addInteger("STOK", "K% LinePeriod", "", 5, 2, 1000);
	strategy.parameters:addInteger("STOD", "D% Line Period", "", 3, 2, 1000);
	strategy.parameters:addInteger("STOSD", "Slow %D Period" , "", 3, 2, 1000);
	
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
local FastMA, SlowMA, MidMA, ADX,RSI,CCI,STO;
local BUY, SELL;
local BarSource = nil;         -- the source stream

 local FastN, SlowN, MidN, ADXN,RSIN, STOK,STOD,STOSD,STOMethodD, STOMethodK;
 
 
local FastFlag, MidFlag, SlowFlag;
local RSIFlag, RSIOver, CCIFlag, CCIOver, STOFlag, STOOver ;
local FLAG;
local reset;
local ADXFlag;


function Prepare()
   

    -- collect parameters
    FastN = instance.parameters.FastN;
	MidN = instance.parameters.MidN;
    SlowN = instance.parameters.SlowN;
	ADXN = instance.parameters.ADXN;
	RSIN = instance.parameters.RSIN;
	CCIN = instance.parameters.CCIN;
	STOK = instance.parameters.STOK;
	STOD = instance.parameters.STOD;
	STOSD = instance.parameters.STOSD;
	
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

    ExtSetupSignal("EMA CCI ADX RSI STO Signal", ShowAlert);

    BarSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");

    assert(core.indicators:findIndicator(instance.parameters.Method) ~= nil, instance.parameters.Method .. " indicator must be installed");
    FastMA = core.indicators:create(instance.parameters.Method, BarSource.close, FastN);
	MidMA = core.indicators:create(instance.parameters.Method, BarSource.close, MidN);
    SlowMA = core.indicators:create(instance.parameters.Method, BarSource.close, SlowN);
	ADX = core.indicators:create("ADX", BarSource, ADXN);
	RSI = core.indicators:create("RSI", BarSource.close, RSIN);
	CCI = core.indicators:create("CCI", BarSource, CCIN);
	STO = core.indicators:create("STOCHASTIC", BarSource, STOK,STOSD,STOD,instance.parameters.Method,instance.parameters.Method);
   
    first= math.max(2, FastMA.DATA:first() +1, MidMA.DATA:first() +1, SlowMA.DATA:first() +1, ADX.DATA:first() +1 , RSI.DATA:first() +1, CCI.DATA:first() +1, STO.DATA:first() +1);

    local name = profile:id() .. "(" .. instance.bid:instrument()  .. "(" .. instance.parameters.Period  .. ")"  .. ")";
    instance:name(name);
end



-- when tick source is updated
function ExtUpdate(id, source, period)
					
					
					
		 
		
		            FastMA:update(core.UpdateLast);
					MidMA:update(core.UpdateLast);
					SlowMA:update(core.UpdateLast);
					ADX:update(core.UpdateLast);
					RSI:update(core.UpdateLast);
					CCI:update(core.UpdateLast);
					STO:update(core.UpdateLast);
					
					if period > first then	
					 
					
					
					

					      if core.crossesOver( ADX.DATA, 20, period) then
						  ADXFlag= "Strong";	  
						  reset=1; 
						  end
						  
						  if core.crossesUnder( ADX.DATA, 20, period) then
						  ADXFlag= "Weak";	  
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
						   
						   if core.crossesOver( RSI.DATA, 30, period) or core.crossesOver( RSI.DATA, 50, period) then
						   RSIFlag= "Buy";	
						   RSIOver=nil;
						   reset=1;            		   		   
						   end
						   
						   if core.crossesUnder( RSI.DATA, 70, period)  or core.crossesUnder( RSI.DATA, 50, period) then
						   RSIFlag= "Sell";	
						   RSIOver=nil;
						   reset=1;            		   
						   end
						   
						   if core.crossesOver( RSI.DATA, 70, period)   then
						    RSIOver= "Buy";	
							RSIFlag= nil;	
							reset=1;            		   		   
						   end
						   
						   if core.crossesUnder( RSI.DATA, 30, period)   then
						   RSIOver= "Sell";
						   RSIFlag= nil;			   
						  
						   reset=1;            		   
						   end
						   
						   
						   
						   if core.crossesOver( CCI.DATA, -100, period)  or core.crossesOver( CCI.DATA, 0, period) then
						   CCIFlag= "Buy";	
						   CCIOver=nil;
						   reset=1;            		   		   
						   end
						   
						   if core.crossesUnder( CCI.DATA, 100, period)   or core.crossesUnder( CCI.DATA, 0, period) then
						   CCIFlag= "Sell";	
						   CCIOver=nil;
						   reset=1;            		   
						   end
						   
						   if core.crossesOver( CCI.DATA, 100, period)  then
						   CCIOver= "Buy";	
						   CCIFlag= nil;	
						   reset=1;            		   		   
						   end
						   
						   if core.crossesUnder( CCI.DATA, -100, period)  then
						   CCIOver= "Sell";
						   CCIFlag= nil;			   
						   reset=1;            		   
						   end
						   
						   
						   
						   if core.crossesOver(STO.K, STO.D, period)   then
						   STOFlag= "Buy";	
						   STOOver=nil;
						   reset=1;            		   		   
						   end
						   
						   if core.crossesUnder (STO.K, STO.D, period)  then
						   STOFlag= "Sell";	
						   STOOver=nil;
						   reset=1;            		   
						   end
						   
						   if core.crossesOver(STO.K, 80, period)  then
						   STOOver= "Buy";	
						   STOFlag= nil;	
						   reset=1;            		   		   
						   end
						   
						   if core.crossesUnder( STO.K, 20, period)  then
						   STOOver= "Sell";
						   STOFlag= nil;			   
						   reset=1;            		   
						   end
						
						
						   if reset== 1 then
						   FLAG=nil;
						   reset=0;
						   end
						   
						   
							if  MidFlag == "Buy" and   FLAG ~= "Buy" and RSIFlag=="Buy" and RSIOver~= "Buy" and  ADXFlag== "Strong"and CCIFlag=="Buy" and CCIOver~= "Buy" and FastMA.DATA[period] > FastMA.DATA[period-1] and STOFlag=="Buy" and STOOver~= "Buy" then
							FLAG = "Buy";
							ExtSignal(BarSource.close, period, BUY, SoundFile);
							
							end
							
							if  MidFlag == "Sell" and FLAG ~= "Sell" and RSIFlag=="Sell" and RSIOver~= "Sell" and  ADXFlag== "Strong" and CCIFlag=="Sell"  and CCIOver~= "Sell"  and  FastMA.DATA[period] < FastMA.DATA[period-1] and STOFlag=="Sell" and STOOver~= "Sell" then
							FLAG = "Sell";
							ExtSignal(BarSource.close, period, SELL, SoundFile);
							
							end
		end				   
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
