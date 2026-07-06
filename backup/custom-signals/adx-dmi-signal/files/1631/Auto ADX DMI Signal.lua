-- Id: 547
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
    strategy:name("ADX DMI Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("ADX DMI Signal");

    strategy.parameters:addGroup("Parameters");
  
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");
	
	strategy.parameters:addInteger("ADX", "ADX Period", "ADX Period", 14, 2, 1000);
    strategy.parameters:addInteger("DMI", "DMI Period", "DMI Period", 14, 1, 1000);
	
	 strategy.parameters:addInteger("ADXL", "ADX Level", "ADX Level", 20, 0, 100);
	
	strategy.parameters:addBoolean("ADXON", "ADX ON", "ADX ON", false);
	
	strategy.parameters:addBoolean("AutoADXON", "Auto ADX ON", "Auto ADX ON", false);
   
    strategy.parameters:addString("Period", "Timeframe", "", "m1");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
end

local SoundFile;

local ADX;
local DMI;

local ADXON;
local AutoADXON;

local SHORT, LONG;
local bSource = nil; 

local ADXS;
local DMIS;
local first;
local ADXL;

function Prepare()
   
    ShowAlert = instance.parameters.ShowAlert;
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
	
	ADXP = instance.parameters.ADX;
	DMIP = instance.parameters.DMI;
	ADXON = instance.parameters.ADXON;
	ADXL= instance.parameters.ADXL;
	AutoADXON= instance.parameters.AutoADXON;
   

    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");
    assert(instance.parameters.Period ~= "t1", "Signal cannot be applied on ticks");

    SHORT = "Short";
    LONG = "Long";

    ExtSetupSignal("ADX DMI Signal", ShowAlert);

    bSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");

		
	ADX  = core.indicators:create("ADX", bSource, ADXP);
	DMI  = core.indicators:create("DMI", bSource, DMIP);
	first= math.max(ADX.DATA:first(), DMI.DATA:first() )+1;
    
    local name = profile:id() .. "ADX DMI Signal";
    instance:name(name);
end


local DMIFLAG=nil;
local FLAG=nil;
local last=nil;

-- when tick source is updated
function ExtUpdate(id, source, period)
    -- update moving average
	
	if period < first  then
	return;
	end
	
    ADX:update(core.UpdateLast);
	DMI:update(core.UpdateLast);
	
	                
									
					if core.crossesOver(DMI.DIP, DMI.DIM, period) then
					FLAG=1;
					
					    if (AutoADXON) then 
						ADXL= DMI.DIP[period];
						end
					
					end
					
					if core.crossesUnder(DMI.DIP, DMI.DIM, period) then
					FLAG=-1;
					
					    if (AutoADXON) then 
						ADXL= DMI.DIP[period];
						end
					end
                      
                    if FLAG~=last then
					last=FLAG;
					DMIFLAG=nil;
					end
		             			  
		 
	                 if (ADXON) then 
					 
					     if  (AutoADXON) then
					    
								if DMI.DIP[period] > DMI.DIM[period] and DMIFLAG~= "Buy" and ADX.DATA[period] >ADXL then
								  DMIFLAG="Buy";
								  ExtSignal(bSource, period, LONG, SoundFile);
								end
						  
								if  DMI.DIP[period] < DMI.DIM[period]  and DMIFLAG~= "Sell" and ADX.DATA[period] >ADXL  then
								  DMIFLAG="Sell";
								  ExtSignal(bSource, period, SHORT, SoundFile);
								end
							 
					     else
					 
								 if DMI.DIP[period] > DMI.DIM[period] and DMIFLAG~= "Buy" and ADX.DATA[period] >ADXL then
									DMIFLAG="Buy";
									ExtSignal(bSource, period, LONG, SoundFile);
								end
							  
								if  DMI.DIP[period] < DMI.DIM[period]  and DMIFLAG~= "Sell" and ADX.DATA[period] >ADXL  then
									DMIFLAG="Sell";
									ExtSignal(bSource, period, SHORT, SoundFile);
								end
					  
					    end
					else
						if DMI.DIP[period] > DMI.DIM[period]  and DMIFLAG~= "Buy" then
						     DMIFLAG="Buy";
							ExtSignal(bSource, period, LONG, SoundFile);
						end
						  
						if  DMI.DIP[period] < DMI.DIM[period] and DMIFLAG ~= "Sell" then
						    DMIFLAG="Sell";
							ExtSignal(bSource, period, SHORT, SoundFile);
						end	
					 end 
    end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
