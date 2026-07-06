-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=18333

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
    indicator:name("RSI Alert");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator); 
   
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 14);
	indicator.parameters:addDouble("OBL", "Overbought Line Level", "", 70);
	indicator.parameters:addDouble("CL", "Central Line Level", "", 50);
	indicator.parameters:addDouble("OSL", "Oversold Line Level", "", 30);
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");
	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addString("O", "Location", "Oscillator" , "O");
	indicator.parameters:addStringAlternative("O", "Oscillator", "" , "O");
	indicator.parameters:addStringAlternative("O", "Indicator", "" , "I");
    indicator.parameters:addColor("Down", "Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Up", "Down Trend Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);

	
	indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("S1", "Allow  Central Line Cross Alert", "", true);
	indicator.parameters:addBoolean("S2", "Allow  Overbought Line Cross Alert", "", true);
	indicator.parameters:addBoolean("S3", "Allow  Oversold Line  Cross Alert", "", true);

	
	indicator.parameters:addGroup("Alerts");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);
	
	
    indicator.parameters:addFile("COS", "Central Line Cross over Sound File", "", "");
    indicator.parameters:setFlag("COS", core.FLAG_SOUND);
	
	indicator.parameters:addFile("CUS", "Central Line Cross under Sound File", "", "");
    indicator.parameters:setFlag("CUS", core.FLAG_SOUND);
	
	
	 indicator.parameters:addFile("OBCOS", "Overbought Line Cross over Sound File", "", "");
    indicator.parameters:setFlag("OBCOS", core.FLAG_SOUND);
	
	indicator.parameters:addFile("OBCUS", "Overbought Line Cross under Sound File", "", "");
    indicator.parameters:setFlag("OBCUS", core.FLAG_SOUND);
	
	
	
	 indicator.parameters:addFile("OSCOS", "Oversold Line Cross over Sound File", "", "");
    indicator.parameters:setFlag("OSCOS", core.FLAG_SOUND);
	
	indicator.parameters:addFile("OSCUS", "Oversold Line Cross under Sound File", "", "");
    indicator.parameters:setFlag("OSCUS", core.FLAG_SOUND);
	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local OBL, OSL, CL;
local O;
local first;
local source = nil;
local Line;
local up, down;
local Size;
local Email;
local SendEmail;
local COS, CUS, RecurrentSound ,SoundFile  ;
local OBCOS, OBCUS, OSCOS, OSCUS;
local CO, CU, TO, TU, BO, BU;
local Alert;
local Indicator;
local Period;
local Price;
local PlaySound;
local S1, S2, S3;
-- Routine
function Prepare(nameOnly)   
    S1=instance.parameters.S1;
	S2=instance.parameters.S2;
	S3=instance.parameters.S3;
    OBL=instance.parameters.OBL;
    OSL=instance.parameters.OSL;	
	CL=instance.parameters.CL;
    source = instance.source;
    Period=instance.parameters.Period;
	Size=instance.parameters.Size;
	O=instance.parameters.O;
	Price=instance.parameters.Price;
	
	 SendEmail = instance.parameters.SendEmail;

    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
	
	
	 PlaySound = instance.parameters.PlaySound;
    if PlaySound then
        COS = instance.parameters.COS;
		CUS = instance.parameters.CUS;
		OBCOS = instance.parameters.OBCOS;
		OBCUS = instance.parameters.OBCUS;
		OSCOS = instance.parameters.OSCOS;
		OSCUS = instance.parameters.OSCUS;
    else
        COS = nil;
		CUS = nil;
		OBCOS=nil;
		OBCUS=nil;
		OSCOS=nil;
		OSCUS=nil;
    end
    assert(not(PlaySound) or (PlaySound and COS ~= "") or (PlaySound and COS ~= ""), "Sound file must be chosen"); 
	 assert(not(PlaySound) or (PlaySound and CUS ~= "") or (PlaySound and CUS ~= ""), "Sound file must be chosen");
	 
	 assert(not(PlaySound) or (PlaySound and OBCOS ~= "") or (PlaySound and OBCOS ~= ""), "Sound file must be chosen"); 
	 assert(not(PlaySound) or (PlaySound and OBCUS ~= "") or (PlaySound and OBCUS ~= ""), "Sound file must be chosen");
	 
	  assert(not(PlaySound) or (PlaySound and OSCOS ~= "") or (PlaySound and OSCOS ~= ""), "Sound file must be chosen"); 
	 assert(not(PlaySound) or (PlaySound and OSCUS ~= "") or (PlaySound and OSCUS ~= ""), "Sound file must be chosen");
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	CO=nil;
	CU=nil;	
	
	TO=nil;
	TU=nil;	
	
	BO=nil;
	BU=nil;
	
    local name = profile:id() .. "(" .. source:name() ..", ".. Period..  ")";
    instance:name(name);
	if nameOnly then
		return;
	end
	
	Indicator = core.indicators:create( "RSI", source, Period)
	 first = Indicator.DATA:first();	
	
	 up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Up, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Down, 0);
  
end
local LAST;
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 

if period < first then
return;
end

	 Indicator:update(mode);
	 down:setNoData (period); 
      up:setNoData (period); 	
		if S1 then    
			if 	Indicator.DATA[period-1] > CL
			and Indicator.DATA[period]  <  CL
			then
			            if  O == "O" then			              
						    up:set(period , CL, "\218");
						else   
						     up:set(period , source[period], "\218");	
						end	 
						   	
						   down:setNoData (period); 	  
						   
			
			CU = nil;
						   
							  if CO~=source:serial(period) 
							  and period == source:size()-1
							  then
							 CO=source:serial(period);
							 SoundAlert(COS);
							 EmailAlert(  "Central Line Cross Under");
							 end
			elseif	Indicator.DATA[period-1] < CL 
			and Indicator.DATA[period]  >  CL			
            then			
			
			             if  O == "O" then	
						     down:set(period , CL, "\217");
                         else						 
			               down:set(period , source[period], "\217");							  
						end   
						   up:setNoData (period); 	  
						   
		     CO = nil;
		   
			                 if  CU~=source:serial(period)
							 and period == source:size()-1
							 then
							CU=source:serial(period);
							 SoundAlert(CUS);			 
							 EmailAlert(  "Central Line Cross Under");								   
			                     end			   
	         end
	  end

      if S2	  then
			 --********************************
			 if 	Indicator.DATA[period-1] > OSL
			and Indicator.DATA[period]  <  OSL
			then
			            if  O == "O" then			              
						    up:set(period , OSL, "\218");
						else   
						     up:set(period , source[period], "\218");	
						end	 
						   	
						   down:setNoData (period); 	  
						   
			
			BU = nil;
						   
							  if BO~=source:serial(period) 
							  and period == source:size()-1
							  then
							 BO=source:serial(period);
							 SoundAlert(OSCOS);
							 EmailAlert(  "OS Line Cross Under");
							 end
			elseif	Indicator.DATA[period-1] < OSL 
			and Indicator.DATA[period]  >  OSL			
            then			
			
			             if  O == "O" then	
						     down:set(period , OSL, "\217");
                         else						 
			               down:set(period , source[period], "\217");							  
						end   
						   up:setNoData (period); 	  
						   
		     BO = nil;
		   
			                 if  BU~=source:serial(period)
							 and period == source:size()-1
							 then
							BU=source:serial(period);
							 SoundAlert(OSCUS);			 
							 EmailAlert(  "OS Line Cross Under");								   
			                     end			   
	         end
			 
	  end

    if S3 then	  
			 --************************************
			 
			 if 	Indicator.DATA[period-1] > OBL
			and Indicator.DATA[period]  <  OBL
			then
			            if  O == "O" then			              
						    up:set(period , OBL, "\218");
						else   
						     up:set(period , source[period], "\218");	
						end	 
						   	
						   down:setNoData (period); 	  
						   
			
			TU = nil;
						   
							  if TO~=source:serial(period) 
							  and period == source:size()-1
							  then
							 TO=source:serial(period);
							 SoundAlert(OBCOS);
							 EmailAlert(  "OB Line Cross Under");
							 end
			elseif	Indicator.DATA[period-1] < OBL 
			and Indicator.DATA[period]  >  OBL			
            then			
			
			             if  O == "O" then	
						     down:set(period , OBL, "\217");
                         else						 
			               down:set(period , source[period], "\217");							  
						end   
						   up:setNoData (period); 	  
						   
		     TO = nil;
		   
			                 if  TU~=source:serial(period)
							 and period == source:size()-1
							 then
							TU=source:serial(period);
							 SoundAlert(OBCUS);			 
							 EmailAlert(  "OB Line Cross Under");								   
			                     end			   
	         end
			 
    end
end



function SoundAlert(Sound)
 
  if not PlaySound then
  return;
  end
  
  terminal:alertSound(Sound, RecurrentSound);
end

 

function EmailAlert( Subject)

if not SendEmail then
return
end
 
    local date = source:date(NOW);
	local DATA = core.dateToTable (date);
	
    local LABEL =  DATA.month..", ".. DATA.day ..", ".. DATA.hour  ..", ".. DATA.min ..", ".. DATA.sec;
 

  local text=   profile:id() .. "(" .. source:instrument() .. ")" .. source[NOW]..", " .. Subject..", " .. LABEL  ;
 terminal:alertEmail(Email, Subject, text);
end
	 

