-- Id: 1303
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
    strategy:name("Feuerstein");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("Feuerstein Signal ");

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
end

local SoundFile;

local FastMA;
local SlowMA;

local CCI;
local HA;
local STOCHASTIC;


local BS=0;
local SS=0;

local ADX;
local adxflag;

local RSI;

local old;

local sum=0;
local mvaflagB=0;
local cgiflagB=0;

local mvaflagS=0;
local cgiflagS=0;

local rsiflagB=0;
local rsiflagS=0;

local stochasticflagB=0;
local stochasticflagS=0;

local haflagB=1;   
local haflagS=0;

local S;

local SHORT, LONG;
local bSource = nil; 

function Prepare()
   
    ShowAlert = instance.parameters.ShowAlert;
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end

    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");
    assert(instance.parameters.Period ~= "t1", "Signal cannot be applied on ticks");

    SHORT = "Short";
    LONG = "Long";

    ExtSetupSignal("Feuerstein", ShowAlert);

  
   bSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");

    FastMA = core.indicators:create("MVA", bSource.close, 13);
    SlowMA = core.indicators:create("MVA", bSource.close, 21);
	ADX = core.indicators:create("ADX", bSource, 14);
	HA = core.indicators:create("HA", bSource);
	STOCHASTIC = core.indicators:create("STOCHASTIC", bSource, 8,3,3);
	RSI = core.indicators:create("RSI", bSource.close, 14)
	
		
	CCII  = core.indicators:create("CCI", bSource, 14);
    
    local name = profile:id() .. "Feuerstein";
    instance:name(name);
end

-- when tick source is updated
function ExtUpdate(id, source, period)
    -- update moving average
	
    FastMA:update(core.UpdateLast);
    SlowMA:update(core.UpdateLast);
	CCII:update(core.UpdateLast);
	HA:update(core.UpdateLast);
	STOCHASTIC:update(core.UpdateLast);
	RSI:update(core.UpdateLast);
	ADX:update(core.UpdateLast);
		 
	
	 if not(SlowMA.DATA:hasData(period - 1)) then
        return;
     end
	 if not(FastMA.DATA:hasData(period - 1)) then
        return;
     end
	 
	  if not(CCII.DATA:hasData(period - 1)) then
       return;
    end
	 
	
        
        if core.crossesOver(FastMA.DATA, SlowMA.DATA, period)then
        mvaflagB=1;   
        mvaflagS=0;   		
        end
          
        if core.crossesUnder(FastMA.DATA, SlowMA.DATA, period) then
         mvaflagB=0;
		 mvaflagS=1; 
        end
		
	
		if core.crossesOver(CCII.DATA, -100, period)then
        cgiflagB=1;   
        cgiflagS=0; 		
        end
          
         if core.crossesUnder(CCII.DATA, 100, period) then
         cgiflagB=0; 
		 cgiflagS=1;  
        end
		
		if HA.high[period] == HA.open[period] then
        haflagB=0;   
        haflagS=1; 		
        elseif  HA.low[period] == HA.open[period]  then
         haflagB=1; 
		 haflagS=0;
        else
		 haflagB=0; 
		 haflagS=0;
		end
		
		if core.crossesUnder(STOCHASTIC.DATA, 80, period) or core.crossesUnder(STOCHASTIC.DATA, 50, period) then
        stochasticflagB=0;   
        stochasticflagS=1; 		
        elseif  core.crossesOver(STOCHASTIC.DATA, 20, period)  or  core.crossesOver(STOCHASTIC.DATA, 50, period) then
         stochasticflagB=1; 
		 stochasticflagS=0;
        end
		
		if core.crossesUnder(RSI.DATA, 70, period) or core.crossesUnder(RSI.DATA, 50, period) then
        rsiflagB=0;   
        rsiflagS=1; 		
        elseif  core.crossesOver(RSI.DATA, 30, period)  or  core.crossesOver(RSI.DATA, 50, period) then
         rsiflagB=1; 
		 rsiflagS=0;
        end
				
		
        BS= cgiflagB + mvaflagB+haflagB + stochasticflagB + rsiflagB;
		 SS= cgiflagS + mvaflagS+haflagS + stochasticflagS +rsiflagS;
		 
				
		if  core.crossesOver(ADX.DATA, 25, period)  then
		adxflag= "Yes"
		end    
		
		if  core.crossesUnder(ADX.DATA, 25, period)  then
		adxflag= "No"
		end  
		
		  
		  if  BS >=4 and old ~="Buy"and adxflag=="Yes" then
		  old="Buy"
		
		  ExtSignal(bSource.close, period, LONG, SoundFile);
		  end
		  
		  if SS>=4 and old ~= "Sell" and adxflag== "Yes" then
		  old ="Sell"
		  ExtSignal(bSource.close, period, SHORT, SoundFile);
             
		  
		end
           
    
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
