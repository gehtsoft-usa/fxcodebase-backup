--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams

function Init()
    indicator:name("T3 Cross");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
   
   
    indicator.parameters:addGroup("Calculation");
     indicator.parameters:addDouble("VF1", "First Line Volume Factor", "Volume Factor", 0.7);
    indicator.parameters:addInteger("F1", "First Line Period", "Period",20,2,2000);
	
	indicator.parameters:addDouble("VF2", "Second Line Volume Factor", "Volume Factor", 0.7);
    indicator.parameters:addInteger("F2", "Second Line Period", "Period",40,2,2000);
	
	indicator.parameters:addGroup("Indicator Style");
	indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "1. Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style1", "1. Line style", "Line style", core.LINE_SOLID);	

	 indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(0,255, 0));
	indicator.parameters:addInteger("width2", "2. Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style2", "2. Line style", "Line style", core.LINE_SOLID);

	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	

	
	indicator.parameters:addGroup("Alerts");  

     indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   
	
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true); 
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	 
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	
	Parameters (1, "Price  / 1. Line Cross")
	Parameters (2, "Price / 2. Line Cross")
    Parameters (3, "1. Line / 2. Line Cross")
	

	
	
end

function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", false);


    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 3;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Up={};
local Down={};
local Label={};
local ON={};
local first;
local source = nil;
local Line;
local up={};
local down={};
local Size;
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local ShowAlert, Show;
local Alert;
local Indicator;
local PlaySound;
local Live;
local U={};
local D={};
local VF1, VF2;
local F1, F2;
local One, Two;


local EMA11;
local EMA12;
local EMA13;
local EMA14;
local EMA15;
local EMA16;

local EMA21;
local EMA22;
local EMA23;
local EMA24;
local EMA25;
local EMA26;
local c11,c12,c13,c14;
local c21,c22,c23,c24;

-- Streams block


-- Routine
function Prepare()   
    
    source = instance.source;	
	Live = instance.parameters.Live;
	F1 = instance.parameters.F1;
	F2 = instance.parameters.F2;
    VF1 = instance.parameters.VF1;
	VF2 = instance.parameters.VF2;
	
	ShowAlert= instance.parameters.ShowAlert;
	Show= instance.parameters.Show;
	

    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. VF1 .. ", " .. F1 .. ", " .. VF2 .. ", " .. F2 .. ")";
    instance:name(name);
	
	 EMA11 = core.indicators:create("EMA", source,   F1);
	 EMA12 = core.indicators:create("EMA", EMA11.DATA,  F1);
     EMA13 = core.indicators:create("EMA", EMA12.DATA,  F1);
	 EMA14 = core.indicators:create("EMA", EMA13.DATA,  F1);
	 EMA15 = core.indicators:create("EMA", EMA14.DATA,  F1);
	 EMA16 = core.indicators:create("EMA", EMA15.DATA,  F1);
	 
	 EMA21 = core.indicators:create("EMA", source,   F2);
	 EMA22 = core.indicators:create("EMA", EMA21.DATA,  F2);
     EMA23 = core.indicators:create("EMA", EMA22.DATA,  F2);
	 EMA24 = core.indicators:create("EMA", EMA23.DATA,  F2);
	 EMA25 = core.indicators:create("EMA", EMA24.DATA,  F2);
	 EMA26 = core.indicators:create("EMA", EMA25.DATA,  F2);
	
 
	first = source:first();

    One = instance:addStream("One", core.Line, name .. ".One", "One", instance.parameters.color1, first +F1*6);
	One:setWidth(instance.parameters.width1);
    One:setStyle(instance.parameters.style1);

     Two = instance:addStream("Two", core.Line, name .. ".Two", "Two", instance.parameters.color2, first + F2*6);
	Two:setWidth(instance.parameters.width2);
    Two:setStyle(instance.parameters.style2);

	
	Initialization();
  
end


function  Initialization ()
     Size=instance.parameters.Size;
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
	
		if ON[i] then
		up[i] = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Up, 0);
		down[i] = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Down, 0);
		end
	end
		
	

	
end	


 function Calculate(period, mode)
 
    EMA11:update(mode);
	EMA12:update(mode);
	EMA13:update(mode);
	EMA14:update(mode);
	EMA15:update(mode);
	EMA16:update(mode);
   
   c11= -VF1*VF1*VF1;
   c12= 3*VF1*VF1+3*VF1*VF1*VF1;
   c13= -6*VF1*VF1-3*VF1-3*VF1*VF1*VF1;
   c14= 1+3*VF1+VF1*VF1*VF1+3*VF1*VF1;
	
 
   if period >= F1*6 and source:hasData(period) then
   One[period] = c11*EMA16.DATA[period]+c12*EMA15.DATA[period]+c13*EMA14.DATA[period]+c14*EMA13.DATA[period];
   end
   
   
    EMA21:update(mode);
	EMA22:update(mode);
	EMA23:update(mode);
	EMA24:update(mode);
	EMA25:update(mode);
	EMA26:update(mode);
   
   c21= -VF2*VF2*VF2;
   c22= 3*VF2*VF2+3*VF2*VF2*VF2;
   c23= -6*VF2*VF2-3*VF2-3*VF2*VF2*VF2;
   c24= 1+3*VF2+VF2*VF2*VF2+3*VF2*VF2;
	
 
   if period >= F2*6 and source:hasData(period) then
   Two[period] = c21*EMA26.DATA[period]+c22*EMA25.DATA[period]+c23*EMA24.DATA[period]+c24*EMA23.DATA[period];
   end

  
 
 end
 
local Shift;
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 

if period < first then
return;
end

    Calculate(period, mode);
	
	
	if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
	
	local i;
	for i = 1, Number , 1 do
		  if ON[i] then
		 down[i]:setNoData (period); 
		 up[i]:setNoData (period);
		 end
   end	 
	
    Activate (1, period)
	Activate (2, period)
	Activate (3, period)
end

function Activate (id, period)


		
	  if id == 1  and ON[id]  then
	  
	       
			if 	One[period-1] < source[period-1]
			and One[period] >  source[period]
			then
			           
						     up[id]:set(period , One[period], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  Pop(Label[id], " Cross Over " );  	
								 SendAlert(" Cross Over ");
							  end
			elseif 	One[period-1] > source[period-1]
			and One[period] <  source[period]
			then	
			
			            			 
			               down[id]:set(period , One[period], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");
                             Pop(Label[id], " Cross Under " );  	
							 SendAlert("Crossed under");							 
			                     end			   
	         end
			
	  
	  elseif id == 2  and ON[id] then
	  
	       
  		   if 	Two[period-1] < source[period-1]
			and Two[period] >  source[period]
			then
			           
						     up[id]:set(period , Two[period], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  Pop(Label[id], " Cross Over " );  	
							  SendAlert(" Cross Over ");
							  end
			elseif 	Two[period-1] > source[period-1]
			and Two[period] <  source[period]
			then	
			
			            			 
			               down[id]:set(period , Two[period], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");	
                              Pop(Label[id], " Cross Under " );  	
							 SendAlert("Crossed under");							 
			                     end			   
	         end
	       
	  elseif id == 3  and ON[id] then	  	

       
			   if 	One[period-1] < Two[period-1]
					and One[period] >  Two[period]
					then
							   
									 up[id]:set(period , One[period], "\108");	
								   
					
					 D[id] = nil;
								   
									  if U[id]~=source:serial(period) 
									  and period == source:size()-1-Shift
									  then
									  U[id]=source:serial(period);
									  SoundAlert(Up[id]);
									  EmailAlert(  Label[id] .." Cross Over");
									  Pop(Label[id], " Cross Over " );  	
								      SendAlert(" Cross Over ");
									  end
					elseif 	One[period-1] > Two[period-1]
					and One[period] <  Two[period]
					then	
					
											 
								   down[id]:set(period , One[period], "\108");	  						   
								   
					 U[id] = nil;
				   
									 if  D[id]~=source:serial(period)
									 and period == source:size()-1-Shift
									 then
									 D[id]=source:serial(period);
									 SoundAlert(Down[id]);			 
									 EmailAlert( Label[id] .. " Cross Under");
									 Pop(Label[id], " Cross Under " );  	
								      SendAlert("Crossed under");
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
 

   local text=  profile:id() .. "(" .. source:instrument() .. ")" .. source[NOW]..", " .. Subject..", " .. LABEL ;
  terminal:alertEmail(Email, Subject, text);
end

function Pop(label , note)
  
   if not Show then
   return;
   end
 
  core.host:execute ("prompt", 1, label ,   " ( " .. source:instrument() .. " ) "  ..   label .. " : " .. note );
  
end


function SendAlert(message)
    if not ShowAlert then
        return;
    end
 
    terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW));
end
	 

function AsyncOperationFinished (cookie, success, message)
end
