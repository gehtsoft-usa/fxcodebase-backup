-- Id: 3276
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
    strategy:name("VTDMI Signal");
	strategy:setTag("NonOptimizableParameters", "Email,SendEmail,SoundFile,RecurrentSound,PlaySound,ShowAlert");
    strategy:description("VTDMI Signal");

    strategy.parameters:addGroup("Price Parameters");
    strategy.parameters:addString("TF", "TF", "Time frame", "m1");
    strategy.parameters:setFlag("TF", core.FLAG_PERIODS);	
    
    strategy.parameters:addGroup("Parameters");
    strategy.parameters:addInteger("N", "Number of periods", "", 14, 1, 1000);
	  strategy.parameters:addBoolean("Confirmation", "Use Level Confirmation", "", false);
	   strategy.parameters:addInteger("Level", "Level", "", 20,0, 100);
	   
	strategy.parameters:addString("Type", "Confirmation Type", "", "Simple");
    strategy.parameters:addStringAlternative("Type", "Simple", "", "Simple");
    strategy.parameters:addStringAlternative("Type", "Advanced", "", "Advanced");
	 
	 strategy.parameters:addString("SIDE", "Allow Short/Long/Both Positions", "", "BOTH");
    strategy.parameters:addStringAlternative("SIDE", "Both", "", "BOTH");
    strategy.parameters:addStringAlternative("SIDE", "Short", "", "SHORT");
	strategy.parameters:addStringAlternative("SIDE", "Long", "", "LONG");
	 
   

    strategy.parameters:addGroup("Notification");
    strategy.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
    strategy.parameters:addBoolean("PlaySound", "Play Sound", "", true);
    strategy.parameters:addBoolean("RecurSound", "Recurrent Sound", "", true);
    strategy.parameters:addFile("SoundFile", "Sound File", "", "");
    strategy.parameters:setFlag("SoundFile", core.FLAG_SOUND);
    strategy.parameters:addBoolean("SendEmail", "Send Email", "", true);
    strategy.parameters:addString("Email", "Email", "", "");
    strategy.parameters:setFlag("Email", core.FLAG_EMAIL);
end

-- Parameters block
local Level;
local SIDE;
local gSource = nil; -- the source stream
local PlaySound;
local RecurrentSound;
local SoundFile;
local Email;
local SendEmail;
local Confirmation;
local Type;
local N;
local ShowAlert;

--TODO: Add variable(s) for your strategy if needed

local first;
local VT= nil;
local  DIP, DIM;

-- strategy instance initialization routine
-- Processes strategy parameters and subscribe to price streams
-- TODO: Calculate all constants, create instances all necessary indicators and load all required libraries
function Prepare(nameOnly)
   Type= instance.parameters.Type;
   Level= instance.parameters.Level;
   Confirmation= instance.parameters.Confirmation;
    N = instance.parameters.N;
    SIDE= instance.parameters.SIDE;   
    AllowMultiple= instance.parameters.AllowMultiple;
    local name = profile:id() .. "(" .. instance.bid:instrument() .. ")";
    instance:name(name);

    if nameOnly then
        return ;
    end
	
        assert(instance.parameters.TF ~= "t1", "The strategy cannot be applied on ticks.");
  

    ShowAlert = instance.parameters.ShowAlert;
    if ShowAlert then
        PlaySound = instance.parameters.PlaySound;
        if PlaySound then
            RecurrentSound = instance.parameters.RecurSound;
            SoundFile = instance.parameters.SoundFile;
        else
            SoundFile = nil;
        end
        assert(not(PlaySound) or (PlaySound and SoundFile ~= ""), "Sound file must be specified");

        SendEmail = instance.parameters.SendEmail;
        if SendEmail then
            Email = instance.parameters.Email;
        else
            Email = nil;
        end
        assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
    end


    gSource = ExtSubscribe(2, nil, instance.parameters.TF, true, "bar");
	
    
    assert(core.indicators:findIndicator("VTDMI") ~= nil, "VTDMI" .. " indicator must be installed");
    VT = core.indicators:create("VTDMI", gSource, N);
    DIP = VT:getStream(0);
    DIM =VT:getStream(1);
   
    first = VT.DATA:first() + 2;

   
    
end

-- strategy calculation routine
-- TODO: Add your code for decision making
-- TODO: Update the instance of your indicator(s) if needed
function ExtUpdate(id, source, period)

VT:update(core.UpdateLast);
   
   if id == 2  and period > first then
      
        
			if not Confirmation   then
				if core.crossesOver(DIP, DIM,period) then 	 
							SIGNAL (true,source, period);
				elseif core.crossesUnder(DIP, DIM,period) then  
							SIGNAL (false,source, period);
				end    
			elseif  Confirmation and Type == "Simple" then
			   if core.crossesOver(DIP, DIM,period) and DIP[period] > Level  then 	 
							SIGNAL (true,source, period);
				elseif core.crossesUnder(DIP, DIM,period) and DIM[period] > Level then  
							SIGNAL (false,source, period);
				end    
			elseif Confirmation and  Type == "Advanced" then	
			     if core.crossesOver(DIP, DIM,period) and DIP[period] > Level  or core.crossesOver(DIP, Level,period) and DIP[period] > DIM[period]  then 	 
							SIGNAL (true,source, period);
				elseif core.crossesUnder(DIP, DIM,period) and DIM[period] > Level  or  core.crossesOver(DIM, Level,period) and DIM[period] > DIP[period]then  
							SIGNAL (false,source, period);
				end    
			end	
    end
		    
	
end

function SIGNAL (FLAG,source, period)

		if FLAG then
					
					
					if SIDE == "SHORT" then
					return;
					end
					
					          
								 if ShowAlert then
									terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Enter Long", instance.bid:date(NOW));
								end
								if SoundFile ~= nil then
									terminal:alertSound(SoundFile, RecurrentSound);
								end
								
								if Email ~= nil then
								 terminal:alertEmail(Email, "Enter Long", profile:id() .. ", "..instance.bid:instrument()..", " .. instance.bid[NOW]..", " .. "Enter Long");
								end

						 

		else
		               
						
						if SIDE == "LONG" then
						return;
						end
			
			             if ShowAlert then
							terminal:alertMessage(instance.bid:instrument(), instance.bid[NOW], "Enter Short", instance.bid:date(NOW));
						end
						if SoundFile ~= nil then
							terminal:alertSound(SoundFile, RecurrentSound);
						end
						
						if Email ~= nil then
						 terminal:alertEmail(Email, "Enter Short", profile:id() ..", " ..instance.bid:instrument()..", " .. instance.bid[NOW]..", " .. "Enter Short");
						end
					
					

					  
		end
end

dofile(core.app_path() .. "\\strategies\\standard\\include\\helper.lua");
