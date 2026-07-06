-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63496

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams

function Init()
    indicator:name("Zig Zag Alert");
    indicator:description("");
   indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
   
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Depth", "Depth", "The minimal amount of bars where there will not be the second maximum", 12);
    indicator.parameters:addInteger("Deviation", "Deviation", "Distance in pips to eliminate the second maximum in the last Depth periods", 5);
    indicator.parameters:addInteger("Backstep", "Backstep", "The minimal amount of bars between maximums/minimums", 3);
		
	--indicator.parameters:addGroup("Indicator Style");   
    --indicator.parameters:addColor("Color", "Bar color", "Bar color", core.rgb(0,255,0));
   
   
	
    indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
 
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, " New Zig Zag ");	
	Parameters (2, " Zig Zag Trend Continuation ");
    Parameters (3, " Zig Zag Trend Fading ");	
end

function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);


    indicator.parameters:addFile("Up"..id, Label .. " Up Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Down Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 3;
local Up={};
local Down={};
local Label={};
local ON={};
local Size;
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local Show;
local Alert;
local PlaySound;
local Live;
local FIRST=true;
local OnlyOnce;
local U={};
local D={};
 local OnlyOnceFlag;
local ShowAlert;
local first;
local source = nil;
local Shift=0; 

 local Color, Depth, Deviation, Backstep; 
 local ZigZag;
-- Routine
function Prepare(nameOnly)
    
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	 
  
	-- Color= instance.parameters.Color;
	 Depth= instance.parameters.Depth;
	 Deviation= instance.parameters.Deviation;
	 Backstep= instance.parameters.Backstep;
   
	

	 
	source = instance.source; 


    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	 -- Create short and long EMAs for the source
    ZigZag = core.indicators:create("ZIGZAG", source , Depth, Deviation, Backstep);
	first=ZigZag.DATA:first();  
	
	
	Initialization();
end


function  Initialization ()
    
	 SendEmail = instance.parameters.SendEmail;
	 
	 local i;
	 for i = 1, Number , 1 do 
	  Label[i]=instance.parameters:getString("Label" .. i);
	  ON[i]=instance.parameters:getBoolean("ON" .. i);
	 end 

    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
	
	
	 PlaySound = instance.parameters.PlaySound;
    if PlaySound then
    
	  for i = 1, Number , 1 do 
	  Up[i]=instance.parameters:getString("Up" .. i);
	  Down[i]=instance.parameters:getString("Down" .. i);
	  end
	
    else 
	
	  for i = 1, Number , 1 do 
       Up[i]=nil;
	  Down[i]=nil;
	  end
		
    end
    
        for i = 1, Number , 1 do 
	  assert(not(PlaySound) or (PlaySound and Up[i] ~= "") or (PlaySound and Up[i] ~= ""), "Sound file must be chosen"); 
	 assert(not(PlaySound) or (PlaySound and Down[i] ~= "") or (PlaySound and Down[i] ~= ""), "Sound file must be chosen");
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	U[i] = nil;
	D[i] = nil;	 
	end
		 
end	

 
local LastUP=nil
local LastDOWN=nil
local OldLastUP=nil;
local OldLastDOWN=nil;
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period )   
  
    if period < source:size()-1 then
	return;
	end
	
    ZigZag:update(core.UpdateAll );
	
	if Live~= "Live" then
	period=period-2;  
    else 
    period=period-1; 	
	end
	
	FindLast(period); 
	
    
 
end

function FindLast(Start)
local EndLoop=false;

for period=Start, first, -1 do
	if ZigZag.DATA[period-1]>ZigZag.DATA[period]
	and ZigZag.DATA[period-2]<ZigZag.DATA[period-1]
	and ZigZag.DATA[period+1 ]~=nil
	then
			if (period-1) ~= LastUP then 
	
			OldLastUP=LastUP;			 
			LastUP=period-1;	
			
			
			if OldLastUP== nil then
			OldLastUP=LastUP;
			end
				 
				  Activate (1, LastUP,1 ); 
				 
				
					if ZigZag.DATA[OldLastUP] < ZigZag.DATA[LastUP] then
					Activate (2, LastUP,1 ); 
					end
					
					if ZigZag.DATA[OldLastUP] > ZigZag.DATA[LastUP] then
					Activate (3, LastUP,1 ); 
					end
				 
			end	 
		
	EndLoop = true;
	end
	
	if ZigZag.DATA[period-1]<ZigZag.DATA[period ]
	and ZigZag.DATA[period-2]>ZigZag.DATA[period-1]
	and ZigZag.DATA[period+1 ]~=nil
	then
	 
	    if (period-1) ~= LastDOWN then
		
		OldLastDOWN=LastDOWN;	 
		LastDOWN=period-1;
		if OldLastDOWN == nil then
		OldLastDOWN=LastDOWN;
		end
		
			 
			 Activate (1, LastDOWN,-1 );
			 
				 if ZigZag.DATA[OldLastDOWN] > ZigZag.DATA[LastDOWN] then
				 Activate (2, LastDOWN,-1 );
				 end	

				 if ZigZag.DATA[OldLastDOWN] < ZigZag.DATA[LastDOWN] then
				 Activate (3, LastDOWN,-1 );
				 end	
			 
			 

             			 
		end
	EndLoop = true;
	end
	
	if EndLoop then
	break;
	end
	
end

end
 

function Activate (id, period, Flag)

  
	  if id == 1  and ON[id]  then
	  
	       
			if  Flag==1 
			then
			            
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period)  
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Up ", period);
							  SendAlert(" Up "); 
							  Pop(Label[id], " Up " );  	
								    
								 
							  end
			elseif  Flag== -1 
            then			
			
			            			 
			           					   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period) 
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Down ", period);
							 Pop(Label[id], " Down " );  
							 SendAlert(" Down ");
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
	  
	   if id == 2  and ON[id]  then
	  
	       
			if  Flag==1 
			then
			            
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period)  
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Higher High ", period);
							  SendAlert(" Higher High "); 
							  Pop(Label[id], " Higher High " );  	
								    
								 
							  end
			elseif  Flag== -1 
            then			
			
			            			 
			           					   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period) 
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Lower Low ", period);
							 Pop(Label[id], " Lower Low " );  
							 SendAlert(" Lower Low ");
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
	  
	  if id == 3  and ON[id]  then
	  
	       
			if  Flag==1 
			then
			            
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period)  
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Lower High ", period);
							  SendAlert(" Lower High "); 
							  Pop(Label[id], " Lower High " );  	
								    
								 
							  end
			elseif  Flag== -1 
            then			
			
			            			 
			           					   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period) 
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Higher Low ", period);
							 Pop(Label[id], " Higher Low " );  
							 SendAlert(" Higher Low ");
							 
			                  end			   
	         end
			
	  
	 
	  end
		   
        if FIRST then
        FIRST=false;      
        end		

end


function AsyncOperationFinished (cookie, success, message)
end


function Pop(label , note)
  
   if not Show then
   return;
   end
    
   core.host:execute ("prompt", 1, label ,   " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) "  ..   label .. " : " .. note );
 

end


function SendAlert(message)
    if not ShowAlert then
        return;
    end
 
    terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW));
end

function SoundAlert(Sound)
 if not PlaySound then
 return;
 end

  if OnlyOnce and OnlyOnceFlag== false then
 return;
 end
 
  terminal:alertSound(Sound, RecurrentSound);
end

 


function EmailAlert( label , Subject, period)

if not SendEmail then
return
end

 if OnlyOnce and OnlyOnceFlag== false then
 return;
 end

 
    local date = source:date(period);
	local DATA = core.dateToTable (date);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
   
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
 
	
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 

