-- Id: 1538
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
    strategy:name("ADX DMI SAR Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("ADX DMI SAR Signal");

	strategy.parameters:addGroup("Reset");
	strategy.parameters:addBoolean("RESET", "Reset if there is no active signal  ", "", true);
	
	strategy.parameters:addGroup("ADX");
	strategy.parameters:addInteger("ADX", "ADX Period", "ADX Period", 14, 2, 1000);
	strategy.parameters:addInteger("ADXL", "ADX Level", "ADX Level", 20, 0, 100);
	
	strategy.parameters:addGroup("DMI");
    strategy.parameters:addInteger("DMI", "DMI Period", "DMI Period", 14, 1, 1000);	 
	 strategy.parameters:addInteger("DMIL", "DMI Level", "DMI Level", 17, 0, 100);
	 
	strategy.parameters:addGroup("SAR");
	strategy.parameters:addDouble("Step", "SAR Step", "", 0.02, 0.001, 1);
    strategy.parameters:addDouble("Max", "SAR Max", "", 0.2, 0.001, 10);
	
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

local ADX;
local DMI;
local SAR;


local SHORT, LONG;
local bSource = nil; 

local ADXFlag;
local DMIFlag;
local DIPFlag;
local DIMFlag;
local SARFlag;

local Step;
local Max;

local RESET;
local first;
function Prepare()
   
    ShowAlert = instance.parameters.ShowAlert;
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
	
	ADXP = instance.parameters.ADX;
	DMIP = instance.parameters.DMI;
	ADXL= instance.parameters.ADXL;
	DMIL=instance.parameters.DMIL;
	Step= instance.parameters.Step;
	Max=instance.parameters.Max;
	RESET=instance.parameters.RESET;
   

    assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");
    assert(instance.parameters.Period ~= "t1", "Signal cannot be applied on ticks");

    SHORT = "Short";
    LONG = "Long";

    ExtSetupSignal("ADX DMI Signal", ShowAlert);

    bSource = ExtSubscribe(1, nil, instance.parameters.Period, instance.parameters.Type == "Bid", "bar");

		
	ADX  = core.indicators:create("ADX", bSource, ADXP);
	DMI  = core.indicators:create("DMI", bSource, DMIP);
	SAR  = core.indicators:create("SAR", bSource, Step, Max);
	first= math.max(ADX.DATA:first(), DMI.DATA:first() )+1;
    
    local name = profile:id() .. "ADX DMI SAR Signal";
    instance:name(name);
end

-- when tick source is updated
function ExtUpdate(id, source, period)
    -- update moving average
	

    ADX:update(core.UpdateLast);
	DMI:update(core.UpdateLast);
	SAR:update(core.UpdateLast);
	
	 if period < first  then
	return;
	end           
									
					if core.crossesOver(DMI.DIP, DMI.DIM, period) then
					DMIFlag="Buy";				
		            end
					if core.crossesUnder(DMI.DIP, DMI.DIM, period) then
					DMIFlag="Sell";				
		            end
					
					if core.crossesOver(DMI.DIP, DMIL, period) then
					DIPFlag="Strong";				
		            end
					if core.crossesUnder(DMI.DIP, DMIL, period) then
					DIPFlag="Weak";				
		            end
					
					if core.crossesOver(DMI.DIM, DMIL, period) then
					DIMFlag="Strong";				
		            end
					if core.crossesUnder(DMI.DIM, DMIL, period) then
					DIMFlag="Weak";				
		            end
		             			  
		            if core.crossesOver(DMI.DIP, DMI.DIM, period) then
					DMIFlag="Buy";				
		            end
					if core.crossesUnder(DMI.DIP, DMI.DIM, period) then
					DMIFlag="Sell";				
		            end 
					
					
					
					if core.crossesOver(ADX.DATA, ADXL, period) then
					ADXFlag="Strong";				
		            end
					if core.crossesUnder(ADX.DATA, ADXL, period) then
					ADXFlag="Weak";				
		            end 
					
					if core.crossesOver(SAR.UP, SAR.DN, period) then
					SARFlag="DownTrend";				
		            end
					if core.crossesOver(SAR.DN, SAR.UP, period) then
					SARFlag="UpTrend";				
		            end 
					
					if RESET then
					  
					   if ADXFlag=="Weak"  then
					   FLAG=nil;
					   end
					   
					   if DIPFlag=="Weak" and DIMFlag=="Weak" then
					   FLAG=nil;
					   end
					   
					   
					end
	                
					
						if ADXFlag=="Strong" and DMIFlag=="Buy" and FLAG~= "Buy" and DIPFlag=="Strong" and SARFlag=="UpTrend" then
						    FLAG="Buy";
							ExtSignal(bSource, period, LONG, SoundFile);
						end
						  
						if  ADXFlag=="Strong" and DMIFlag=="Sell" and FLAG~= "Sell" and DIMFlag=="Strong" and SARFlag=="DownTrend" then
						    FLAG="Sell";
							ExtSignal(bSource, period, SHORT, SoundFile);
						end	
					  
  end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
