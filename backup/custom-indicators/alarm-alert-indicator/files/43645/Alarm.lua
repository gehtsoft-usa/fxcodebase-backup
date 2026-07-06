
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=25398

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
    indicator:name("Alarm");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	Parameters (1, "1. Alarm", true)
	Parameters (2, "2. Alarm", false)
	Parameters (3, "3. Alarm", false)
	Parameters (4, "4. Alarm", false)
	Parameters (5, "5. Alarm", false)
	
   
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	
	 indicator.parameters:addGroup("Style");  
    indicator.parameters:addBoolean("Show", "Show Seconds", "", true);
	indicator.parameters:addColor("LabelColor", "Label Color", "", core.rgb(0, 0, 0));
	indicator.parameters:addInteger("Size", "ArrowSize", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
 
end


function Parameters ( id, Label, Flag)
  
  
    local i;
	local Labels={ "EST", "UTC","Local","Chart", "Server", "Financial", "Sydney","Tokyo", "London", "New York"};
	
    indicator.parameters:addGroup(id.. ". Alarm");
	 
	
	indicator.parameters:addBoolean("USE".. id, "Use this Clock", "", Flag);	
	
	
	indicator.parameters:addInteger("Referent" .. id , "Referent Time", "" , 3);	
    for i = 1, 10, 1 do	
     indicator.parameters:addIntegerAlternative("Referent" .. id,  Labels[i], "",  i);	
	end 
	
	
	indicator.parameters:addInteger("H" .. id , "Hour", "" , -1);	
	indicator.parameters:addIntegerAlternative("H" .. id,  "Select Hours", "", -1);	

    for i = 0, 23, 1 do	
     indicator.parameters:addIntegerAlternative("H" .. id,  i, "",i);	
	end 
	
	indicator.parameters:addInteger("M" .. id , "Minutes", "" , -1);
	indicator.parameters:addIntegerAlternative("M" .. id,  "Select Minutes", "", -1);	
    for i = 0, 59, 1 do	
     indicator.parameters:addIntegerAlternative("M" .. id,  i, "", i);		 
	end 
	
	
  
    indicator.parameters:addBoolean("PlaySound" .. id, "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound" .. id, "Recurrent Sound", "", false);


    indicator.parameters:addFile("Sound"..id, "Alert Sound", "", "");
    indicator.parameters:setFlag("Sound"..id, core.FLAG_SOUND);
	
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 


-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
    local Referent={   };
   	local Labels={ "EST", "UTC","Local","Chart", "Server", "Financial", "Sydney","Tokyo", "London", "New York"};

	local source = nil;
	local L={};	
	local SourceData={};	
	local Size;
	local USE={};
	local Count=5;
    local Number;
    local id;
	local Size, LabelColor;
	local  Shift;
	local Hour;
	local TimeShift={0,0,0,0,0,0,15,13,4,0};
	local Arial; 
	local Show;
	local H={};
    local M={};   
	 local DAY;
	--()()()()()()Customized segment ()()()()()()()
 
local Sound={};
local Label={};
local Email;
local SendEmail;
local  RecurrentSound={};
local SoundFile={};   

local Alert;
local PlaySound={};
local A={};
	--()()()()()()()()()()()()()()()()()()()()()()()()
	

function ReleaseInstance()
       core.host:execute("deleteFont", Arial);
   end	
	
-- Routine
function Prepare(nameOnly)
   Show=instance.parameters.Show;
    source = instance.source;   

	
	LabelColor=instance.parameters.LabelColor;
    Shift=instance.parameters.Shift;
    Size=instance.parameters.Size;
	
	Arial = core.host:execute("createFont", "Arial", Size, true, false);
   

    local i;
    local name = profile:id() .. "(" .. source:name() ;
	name = name .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	
	
	Initialization();
	
		local e,s;
	s, e = core.getcandle("H1", 0, 0, 0);
	Hour=e-s;
	
	local s, e;
	s, e = core.getcandle("D1", 0, 0, 0);
	DAY= e-s;
	
	Number=0;
	
    for i = 1, Count, 1 do
	
	  
	
	    USE[i]=instance.parameters:getBoolean("USE" .. i);
		
		
	   
	     if USE[i]  then
		    Number=Number+1;
	  	    Referent[Number] = instance.parameters:getInteger("Referent" .. i);
             H[Number] = instance.parameters:getInteger("H" .. i);
	         M[Number] = instance.parameters:getInteger("M" .. i);
			 Label[Number]=instance.parameters:getString("Label" .. i);
	      
			 
			  PlaySound[Number] = instance.parameters:getBoolean("PlaySound" .. i); 
              RecurrentSound[Number] = instance.parameters:getBoolean("RecurrentSound" .. i) ;
			 
			     if PlaySound[Number] then
				  Sound[Number]=instance.parameters:getString("Sound" .. i);				
				else 
				   Sound[Number]=nil;
				end
				
					 
				  assert(not(PlaySound[Number]) or (PlaySound[Number] and Sound[Number] ~= "") or (PlaySound[Number] and Sound[Number] ~= ""), "Sound file must be chosen"); 
			  
	 
		   
		   L[Number] = Labels[Referent[Number]];
		   
		   
		   	A[Number] = nil;	
		 
		 end   
		   
	  
    end
    
   	
 
	
	core.host:execute ("setTimer", 1, 0)
	  
	
end


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


if period < source:size() -1 then
return;
end
	
	    
end

function Calculation (  i )

        
	 
	    local server= core.host:execute("getServerTime");
		local date = core.host:execute("convertTime", 5, Referent[i], server)-- TimeShift[i]*Hour;
		local tab = core.dateToTable(date);
		local str;

	 	if  Show then
		 str = string.format("%02i:%02i:%02i", tab.hour, tab.min, tab.sec);
		 else
		  str = string.format("%02i:%02i", tab.hour, tab.min );
		 end

	  
		
       	 id = id+1;		
		 core.host:execute("drawLabel1", id, -i*75, core.CR_RIGHT,25+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,  Arial,  LabelColor , Labels[Referent[i]]);	
		
		
		 
		id = id+1;					
		 core.host:execute("drawLabel1", id, -i*75, core.CR_RIGHT,25+Shift+Size, core.CR_TOP, core.H_Right, core.V_Bottom,  Arial, LabelColor,   str );	
		 

		 
		if H[i]==-1 or M[i]==-1 then
		return;
		end
		
      local Hour=1/24;
      local Minute=Hour/60;
      local Second=Minute/60;
	
	   local  date1=  H[i]*Hour +   M[i]*Minute;
		
	   local  date=  tab.hour*Hour + tab.min*Minute + tab.sec*Second;		
 
	
	
		
		if  Show then
		 str = string.format("%02i:%02i:%02i", H[i], M[i], 0);
		 else
		  str = string.format("%02i:%02i", H[i], M[i] );
		 end
		 
		
      id = id+1;					
		 core.host:execute("drawLabel1", id, -i*75, core.CR_RIGHT,25+Shift+Size*2, core.CR_TOP, core.H_Right, core.V_Bottom,  Arial, LabelColor,   str );
		 
		local past=0;
		if date > date1 then
         past = ( date- date1);
		 past = DAY - past;
		else
		 past = ( date1-date);
		 past =  past;
		end
		
		local TS=0;
		past=math.floor(( past) * 86400 + 0.5);
		
		
		local h=1
		local m=1
		local s=1;
		
		    s = math.floor(past % 60);
            m = math.floor((past / 60)) % 60;
            h = math.floor(past / 3600);
			
			if h== 0 and m== 0  and s== 0  then
			Activate (i);
			end
			
			
				  
		  if  Show then
		 str = string.format("%02i:%02i:%02i", h, m, s);
		 else
		  str = string.format("%02i:%02i",  h, m );
		 end
 

        id = id+1;					
		 core.host:execute("drawLabel1", id, -i*75, core.CR_RIGHT,25+Shift+Size*3, core.CR_TOP, core.H_Right, core.V_Bottom,  Arial, LabelColor,   str );	 
end


function AsyncOperationFinished(cookie, success, message)

	 local i;

		id=0;
		for i = 1 ,Number , 1  do	
       	 
		   Calculation( i );
		   		
		end	

	 if cookie == 1 then
	 return core.ASYNC_REDRAW ;
	 end	 
	
	return 0;
     
 end
 
 function ReleaseInstance()
    core.host:execute("killTimer", 1);
end


function SoundAlert( id)

if not PlaySound[id] then
return;
end 
 
  
 terminal:alertSound( Sound[id], RecurrentSound[id]);
end

 

function EmailAlert( Subject)

if not SendEmail then
return
end
 
    local date = source:date(NOW);
	local DATA = core.dateToTable (date);
	
    local LABEL =  DATA.month..", ".. DATA.day ..", ".. DATA.hour  ..", ".. DATA.min ..", ".. DATA.sec;
 

   local text=  profile:id() .. "(" .. source:instrument() .. ")"  .. Subject..", " .. LABEL;
   terminal:alertEmail(Email, Subject, text);
end
	 
	 
	 
function Activate (id )

            				  if A[id]~=source:serial(source:size()-1) 							 
							  then
							  A[id]=source:serial(source:size()-1);
							  SoundAlert(id );
							  EmailAlert(  Label[id] );
							  end
			
   
	
	return;
	
end 		


function  Initialization ()
  
	 SendEmail = instance.parameters.SendEmail;

    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
	
	
end		
