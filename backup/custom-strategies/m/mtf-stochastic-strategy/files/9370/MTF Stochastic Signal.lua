-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=31&t=3833

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+
function Init()
    strategy:name("MTF Stochastic Signal");
    strategy:description("Signal in generated when All Time Frames Have the same indication");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound, ShowAlert");

    Parameters (1 , "H1" );
	Parameters (2 , "H4" );
	Parameters (3 , "H8" );
    Parameters (4 , "D1" );
	Parameters (5 , "W1" );
	
	 strategy.parameters:addGroup("Price Parameters");	 
    strategy.parameters:addString("Type", "Price type", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Bid", "", "Bid");
    strategy.parameters:addStringAlternative("Type", "Ask", "", "Ask");

    strategy.parameters:addString("Period", "Timeframe", "", "m5");
    strategy.parameters:setFlag("Period", core.FLAG_PERIODS);

    strategy.parameters:addGroup("Signals");

    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", false);
	strategy.parameters:addBoolean("RecurrentSound", "RecurrentSound", "", false);
	
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
	
	 strategy.parameters:addBoolean("SendEmail", "Send Email", "", true);
    strategy.parameters:addString("Email", "Email", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

function Parameters (id , FRAME )


  	strategy.parameters:addGroup(id..". STOCHASTIC TIME FRAME");
    strategy.parameters:addInteger("K"..id, "Number of periods for %K", "", 5, 2, 1000);
    strategy.parameters:addInteger("SD"..id, "%D slowing periods", "", 3, 2, 1000);
    strategy.parameters:addInteger("D"..id, "The number of periods for %D.", "", 3, 2, 1000);

    strategy.parameters:addString("KS"..id, "Smoothing type for %K", "", "MVA");
    strategy.parameters:addStringAlternative("KS"..id, "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("KS"..id, "EMA","", "EMA");
    strategy.parameters:addStringAlternative("KS"..id, "MT4","", "MT");
    
    strategy.parameters:addString("DS"..id, "Smoothing type for %D", "", "MVA");
    strategy.parameters:addStringAlternative("DS"..id, "MVA", "", "MVA");
    strategy.parameters:addStringAlternative("DS"..id, "EMA", "", "EMA"); 	
  
    strategy.parameters:addString("B"..id, "STOCHASTIC Time frame", "", FRAME);
    strategy.parameters:setFlag("B"..id, core.FLAG_PERIODS);
end

local first=1;
local ShowAlert;
local SoundFile;
local BUY, SELL;
local Email;
local SendEmail;
local RecurrentSound;
local DS={};
local KS={};
local K={};
local SD={};
local D={};
local stream={};
local Indicator={};


function Prepare(nameOnly)
	
	 local name = profile:id() .. "(" ..  instance.bid:name()  .. ")";
    instance:name(name); 


     if   (nameOnly) then
        return;
    end
	
	
	Email=instance.parameters.Email;
	RecurrentSound=instance.parameters.RecurrentSound;
	local i;
    for i= 1, 5, 1 do	
	DS[i]=instance.parameters:getString ("DS"..i);
    KS[i]=instance.parameters:getString ("KS"..i);
    K[i]=instance.parameters:getInteger ("K"..i);
    SD[i]=instance.parameters:getInteger ("SD"..i);
    D[i]=instance.parameters:getInteger ("D"..i);
	end
   
   
	   
    ShowAlert = instance.parameters.ShowAlert;
	
    if instance.parameters.PlaySound then
        SoundFile = instance.parameters.SoundFile;
    else
        SoundFile = nil;
    end
	
	
     assert(not(PlaySound) or (PlaySound and SoundFile ~= " "), "Sound file must be specified");	

	
	  local i;
	
	for i = 1, 5 , 1 do	 
			stream[i] = ExtSubscribe(i, nil, instance.parameters:getString ("B"..i), instance.parameters.Type == "Bid", "bar");				
			Indicator[i] = core.indicators:create("STOCHASTIC", stream[i], K[i],SD[i],D[i],KS[i],DS[i]);
		first= math.max(first,Indicator[i].DATA:first() );	
	end
		
	 
end


-- when tick source is updated
function ExtUpdate(id, source, period)	
       
	 local i;
	
	local Count=0;
	for i = 1, 5 , 1 do	    
    Indicator[i]:update(core.UpdateLast);
	
		if Indicator[i].DATA:hasData(Indicator[i].DATA:size()-1) and Indicator[i].DATA:hasData(Indicator[i].DATA:size()-2) then
		
			if  Indicator[i].DATA[Indicator[i].DATA:size()-1] >   Indicator[i].DATA[Indicator[i].DATA:size()-2] then
			Count= Count+1;
			elseif Indicator[i].DATA[Indicator[i].DATA:size()-1] <   Indicator[i].DATA[Indicator[i].DATA:size()-2] then
			Count= Count-1;
			end
		
		end
	
    end   
	
	if Count == 5  then
	Signal ("Enter Long Position")
	elseif  Count == -5  then
	Signal ("Enter Short Position")
    end	
						  
							   
end

function Signal (Label)

								  if ShowAlert then
									terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW],  Label, instance.bid:date(NOW));
								end
								if SoundFile ~= nil then
									terminal:alertSound(SoundFile, RecurrentSound);
								end
								
								if Email ~= nil then
								 terminal:alertEmail(Email, Label, profile:id() .. "(" .. instance.bid:instrument() .. ")" .. instance.bid[NOW]..", " .. Label..", " .. instance.bid:date(NOW));
								end
end					

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
