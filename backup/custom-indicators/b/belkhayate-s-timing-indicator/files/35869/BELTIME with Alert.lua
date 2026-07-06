-- Id: 6870
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=715

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
    indicator:name("BELTIME with Alert");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
     indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("N", "Number of bars", "No description", 5);
	
	 indicator.parameters:addGroup("Levels"); 
	 indicator.parameters:addDouble("OB3", "3. OB", "", 10);
	 indicator.parameters:addDouble("OB1", "2. OB", "", 8);
	 indicator.parameters:addDouble("OB2", "1. OB", "", 6);
	 indicator.parameters:addDouble("OS1", "1. OS", "", -6);
	 indicator.parameters:addDouble("OS2", "2. OS", "", -8);
	  indicator.parameters:addDouble("OS3", "3. OS", "", -10);
	 
	 
	indicator.parameters:addInteger("level_overboughtsold_width", "Width", "",  1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("level_overboughtsold_color", "Color", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Up Cross Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Down", "Down Cross Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	
	 
	Parameters (1, "OB1 ");
	Parameters (2, "OB2 ");
	Parameters (3, "OS1 ")
	Parameters (4, "OS2 ")
    Parameters (5, "Zero Line ")
	Parameters (6, "OB3 ")
	Parameters (7, "OS3 ")
	 
	 
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

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Up={};
local Down={};
local Label={};
local ON={};
local Line;
local up={};
local down={};
local Size;
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local U={};
local D={};

local Alert;
local Indicator;
local PlaySound;
local 	Number = 7;


local N;

local first;
local source = nil;

-- Streams block
local O = nil;
local H = nil;
local L = nil;
local C = nil;

local OB1, OB2, OS1, OS2, OB3, OS3;

-- Routine
function Prepare(nameOnly) 
    N = instance.parameters.N;
    source = instance.source;
    first = source:first() + N;
	
	OB1 = instance.parameters.OB1;
	OB2 = instance.parameters.OB2;
	OS1 = instance.parameters.OS1;
	OS2 = instance.parameters.OS2;
	OB3 = instance.parameters.OB3;
	OS3 = instance.parameters.OS3;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    O = instance:addStream("O", core.Line, name .. ".O", "O", 0, first);
    O:setPrecision(math.max(2, instance.source:getPrecision()));
    H = instance:addStream("H", core.Line, name .. ".H", "H", 0, first);
    H:setPrecision(math.max(2, instance.source:getPrecision()));
    L = instance:addStream("L", core.Line, name .. ".L", "L", 0, first);
    L:setPrecision(math.max(2, instance.source:getPrecision()));
    C = instance:addStream("C", core.Line, name .. ".C", "C", 0, first);
    C:setPrecision(math.max(2, instance.source:getPrecision()));
    O:addLevel(OB1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    O:addLevel(OB2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    O:addLevel(OS1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    O:addLevel(OS2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	 O:addLevel(OS3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    O:addLevel(OB3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    O:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    instance:createCandleGroup("BT", "BT", O, H, L, C);
	
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
 
   if period < first then
	return;
	end
        local  sumhigh, sumlow, avg1, avg2;   
		
        sumhigh = mathex.sum (source.high, period - N+1, period);
        sumlow = mathex.sum (source.low, period - N+1, period);
        avg1 = (sumhigh + sumlow) / (2 * N);
        avg2 = (sumhigh - sumlow) / (5 * N);

        O[period] = (source.open[period] - avg1) / avg2;
        H[period] = (source.high[period] - avg1) / avg2;
        L[period] = (source.low[period] - avg1) / avg2;
        C[period] = (source.close[period] - avg1) / avg2;
 
 end


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


     Calculate(period, mode);
	 
	local i;
	for i = 1, Number , 1 do
		  if ON[i] then
		 down[i]:setNoData (period); 
		 up[i]:setNoData (period);
		 end
   end	 
  
    Activate (1, period);
	Activate (2, period);
	Activate (3, period);
	Activate (4, period);
	Activate (5, period);
	Activate (6, period);
	Activate (7, period);
end


function Activate (id, period)


		
	  if id == 1  and ON[id]  then
	  
	       
			if 	C[period-1] < OB1
			and C[period] >  OB1
			then
			           
						     up[id]:set(period , OB1, "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  end
			elseif	C[period-1] > OB1 
			and  C [period] <  OB1			
            then			
			
			            			 
			               down[id]:set(period , OB1, "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");								   
			                     end			   
	         end
			
	  
	  end
	  
	  if id == 2  and ON[id]  then
	  
	       
			if 	C[period-1] < OB2
			and C[period] >  OB2
			then
			           
						     up[id]:set(period , OB2, "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  end
			elseif	C[period-1] > OB2 
			and  C [period] <  OB2			
            then			
			
			            			 
			               down[id]:set(period , OB2, "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");								   
			                     end			   
	         end
			
	  
	  end
	  
	   if id == 3  and ON[id]  then
	  
	       
			if 	C[period-1] < OS1
			and C[period] >  OS1
			then
			           
						     up[id]:set(period , OS1, "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  end
			elseif	C[period-1] > OS1 
			and  C [period] <  OS1			
            then			
			
			            			 
			               down[id]:set(period , OS1, "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");								   
			                     end			   
	         end
			
	  
	  end
	  
	  if id == 4  and ON[id]  then
	  
	       
			if 	C[period-1] < OS2
			and C[period] >  OS2
			then
			           
						     up[id]:set(period , OS2, "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  end
			elseif	C[period-1] > OS2 
			and  C [period] <  OS2			
            then			
			
			            			 
			               down[id]:set(period , OS2, "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");								   
			                     end			   
	         end
			
	  
	  end
	  
	   if id == 5  and ON[id]  then
	  
	       
			if 	C[period-1] < 0
			and C[period] >  0
			then
			           
						     up[id]:set(period , 0, "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  end
			elseif	C[period-1] > 0 
			and  C [period] <  0			
            then			
			
			            			 
			               down[id]:set(period , 0, "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");								   
			                 end			   
	         end
			
	  
	  end
	  
	  if id == 6  and ON[id]  then
	  
	       
			if 	C[period-1] < OB3
			and C[period] >  OB3
			then
			           
						     up[id]:set(period , OB3, "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  end
			elseif	C[period-1] > OB3 
			and  C [period] <  OB3			
            then			
			
			            			 
			               down[id]:set(period , OB3, "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");								   
			                 end			   
	         end
			
	  
	  end
	  
	  
	  
	  if id == 7  and ON[id]  then
	  
	       
			if 	C[period-1] < OS3
			and C[period] >  OS3
			then
			           
						     up[id]:set(period , OS3, "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  end
			elseif	C[period-1] > OS3 
			and  C [period] <  OS3			
            then			
			
			            			 
			               down[id]:set(period , OS3, "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");								   
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
 

  local text= profile:id() .. "(" .. source:instrument() .. ")" .. source[NOW]..", " .. Subject..", " .. LABEL;
  terminal:alertEmail(Email, Subject, text);
end
	 

function AsyncOperationFinished (cookie, success, message)
end

