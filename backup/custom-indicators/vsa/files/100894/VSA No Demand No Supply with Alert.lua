-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62307

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("VSA No Demand No Supply");
    indicator:description("VSA No Demand No Supply");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	
	indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live"); 
	
	indicator.parameters:addGroup("Calculation");  
    indicator.parameters:addInteger("NumberofTicks", "Number of Ticks", "Number of Ticks", 0);
	
	indicator.parameters:addGroup("Style"); 
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
    indicator.parameters:addColor("NSLabelColor", "Color of NoSupply", "Color of Label", core.rgb(0, 255, 0));
	indicator.parameters:addColor("NDLabelColor", "Color of NoDemand", "Color of Label", core.rgb(255,0 , 0));
	
	
 
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	
	Parameters (1, "VSA")
end


function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);
    

    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 1;

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

 local HT1,HT2,HT3,HT4;
 local LT1,LT2,LT3,LT4;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local NumberofTicks;

local first;
local source = nil;
local Size, NSLabelColor, NDLabelColor, font;
-- Streams block

 local O,L,H,C,Vol;
 
 function ReleaseInstance()
       core.host:execute("deleteFont", font);
end	   


-- Routine
function Prepare(nameOnly)
    NumberofTicks = instance.parameters.NumberofTicks;
    source = instance.source;
    first = source:first()+5;
	Size = instance.parameters.Size;
	NSLabelColor = instance.parameters.NSLabelColor;
	NDLabelColor = instance.parameters.NDLabelColor;
	
	
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	
	font = core.host:execute("createFont", "Wingdings", Size, false, false);
 
	HT1 = instance:addInternalStream(first, 0);
	LT1 = instance:addInternalStream(first, 0);
	HT2 = instance:addInternalStream(first, 0);
	LT2 = instance:addInternalStream(first, 0);
	HT3 = instance:addInternalStream(first, 0);
	LT3 = instance:addInternalStream(first, 0);
	HT4 = instance:addInternalStream(first, 0);
	LT4 = instance:addInternalStream(first, 0);
	
	H=source.high;
    L=source.low;
	O=source.open;
	C=source.close;
	Vol=source.volume;
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(NumberofTicks) .. ")";
    instance:name(name);
	
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



function Activate (id, period, Flag, Data )

   local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
 
	  if id == 1  and ON[id]  then
	  
	       
			if  Flag==1
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, Data[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, NDLabelColor, "\108");

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " No Demand ", period);
							  SendAlert(" No Demand ");  
							        
									Pop(Label[id], "  No Demand  " );  	
								    
								 
							  end
			elseif  Flag== 2
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, Data[period], core.CR_CHART, core.H_Center, core.V_Top, font, NSLabelColor, "\108");						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " No Supply", period);	
								 
									Pop(Label[id], " No Supply " );  	
								    SendAlert(" No Supply ");
							 
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
	 



 function Plot(Data, period, Label)
	 if Data[period]>= LT1[period] then
	 Activate (1, period, 1 , Data);
	 else 
	  Activate (1, period, 2 , Data);
	 end
 end;

	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not source:hasData(period) then
	return;
	end
    
	HT1[period]=L[period] - NumberofTicks*source:pipSize();
    LT1[period]=H[period] + NumberofTicks*source:pipSize();
	
	HT2[period]=L[period] - 2*NumberofTicks*source:pipSize();
    LT2[period]=H[period] + 2*NumberofTicks*source:pipSize();
	
	HT3[period]=L[period] - 3*NumberofTicks*source:pipSize();
    LT3[period]=H[period] + 3*NumberofTicks*source:pipSize();
	
	HT4[period]=L[period] - 4*NumberofTicks*source:pipSize();
    LT4[period]=H[period] + 4*NumberofTicks*source:pipSize();
	
	core.host:execute ("removeLabel", source:serial(period));
	
	
	if H[period]>H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]==O[period] and C[period]==H[period] and C[period]>C[period-1] and Vol[period]<Vol[period-1]and Vol[period]<Vol[period-2] then  
	Plot(LT1,period,"NoDemand");	 
end; 


if L[period]<L[period-1] and H[period]<=H[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]==O[period] and C[period]==L[period] and C[period]<C[period-1] and Vol[period]<Vol[period-1]and Vol[period]<Vol[period-2] then  
	Plot(HT1,period,"NoSupply");	 
end; 


if H[period]>H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]==O[period] and C[period]==(((H[period]-L[period])*0.5)+L[period]) and C[period]>C[period-1] and Vol[period]<Vol[period-1] and Vol[period]<Vol[period-2]   then  
	Plot(LT1,period,"NoDemand"); 
end;


if L[period]<L[period-1] and H[period]<=H[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]==O[period] and C[period]==(((H[period]-L[period])*0.5)+L[period]) and C[period]<C[period-1] and Vol[period]<Vol[period-1] and Vol[period]<Vol[period-2]  then  
	Plot(HT1,period,"NoSupply"); 
end;



if H[period]>H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]==O[period] and C[period]==L[period] and C[period]>C[period-1] and Vol[period]<Vol[period-1] and Vol[period]<Vol[period-2]   then  
	Plot(LT1,period,"NoDemand"); 
end;

if L[period]<L[period-1] and H[period]<=H[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]==O[period] and C[period]==H[period] and C[period]<C[period-1] and Vol[period]<Vol[period-1] and Vol[period]<Vol[period-2]  then  
	Plot(HT1,period,"NoSupply"); 
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


 

if H[period-2]>H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]==O[period-2] and C[period-2]>C[period-3] and C[period-2]==C[period-1] and C[period-2]>C[period] and H[period-2]>=H[period-1] and H[period-2]>=H[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(LT3,period,"NoDemand"); 
end;

if L[period-2]<L[period-3] and H[period-2]<=H[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]==O[period-2] and C[period-2]<C[period-3] and C[period-2]==C[period-1] and C[period-2]<C[period] and L[period-2]<=L[period-1] and L[period-2]<=L[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4]   then  
	Plot(HT3,period,"NoSupply"); 
end;


if H[period-2]>H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]~=O[period-2] and C[period-2]==H[period-2] and C[period-2]>C[period-3] and C[period-2]==C[period-1] and C[period-2]>C[period] and H[period-2]>=H[period-1] and H[period-2]>=H[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then   
	Plot(LT3,period,"NoDemand"); 
end;

if L[period-2]<L[period-3] and H[period-2]<=H[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]~=O[period-2] and C[period-2]==L[period-2] and C[period-2]<C[period-3] and C[period-2]==C[period-1] and C[period-2]<C[period] and L[period-2]<=L[period-1] and L[period-2]<=L[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(HT3,period,"NoSupply"); 
end;


if H[period-2]>H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]~=O[period-2] and C[period-2]==((H[period-2]-L[period-2])*0.5)+L[period-2] and C[period-2]>C[period-3] and C[period-2]==C[period-1] and C[period-2]>C[period] and H[period-2]>=H[period-1] and H[period-2]>=H[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(LT3,period,"NoDemand"); 
end;

if L[period-2]<L[period-3] and H[period-2]<=H[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]~=O[period-2] and C[period-2]==((H[period-2]-L[period-2])*0.5)+L[period-2] and C[period-2]<C[period-3] and C[period-2]==C[period-1] and C[period-2]<C[period] and L[period-2]<=L[period-1] and L[period-2]<=L[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(HT3,period,"NoSupply"); 
end;


if H[period-2]>H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]~=O[period-2] and C[period-2]==L[period-2] and C[period-2]>C[period-3] and C[period-2]==C[period-1] and C[period-2]>C[period] and H[period-2]>=H[period-1] and H[period-2]>=H[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(LT3,period,"NoDemand"); 
end;

if L[period-2]<L[period-3] and H[period-2]<=H[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]~=O[period-2] and C[period-2]==H[period-2] and C[period-2]<C[period-3] and C[period-2]==C[period-1] and C[period-2]<C[period] and L[period-2]<=L[period-1] and L[period-2]<=L[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(HT3,period,"NoSupply"); 
end;


if H[period-3]>H[period-4] and L[period-3]>=L[period-4] and (H[period-3]-L[period-3])<(H[period-4]-L[period-4]) and C[period-3]==O[period-3] and C[period-3]==H[period-3] and C[period-3]>C[period-4] and C[period-3]==C[period-2] and C[period-3]==C[period-1] and C[period-3]>C[period] and H[period-3]>=H[period-2] and H[period-3]>=H[period-1] and H[period-3]>=H[period] and Vol[period-3]<Vol[period-4] and Vol[period-3]<Vol[period-5] then  
	Plot(LT4,period,"NoDemand"); 
end;

if L[period-3]<L[period-4] and H[period-3]<=H[period-4] and (H[period-3]-L[period-3])<(H[period-4]-L[period-4]) and C[period-3]==O[period-3] and C[period-3]==L[period-3] and C[period-3]<C[period-4] and C[period-3]==C[period-2] and C[period-3]==C[period-1] and C[period-3]<C[period] and L[period-3]<=L[period-2] and L[period-3]<=L[period-1] and L[period-3]<=L[period] and Vol[period-3]<Vol[period-4] and Vol[period-3]<Vol[period-5]  then  
	Plot(HT4,period,"NoSupply"); 
end;


if H[period-3]>H[period-4] and L[period-3]>=L[period-4] and (H[period-3]-L[period-3])<(H[period-4]-L[period-4]) and C[period-3]==O[period-3] and C[period-3]==((H[period-3]-L[period-3])*0.5)+L[period-3] and C[period-3]>C[period-4] and C[period-3]==C[period-2] and C[period-3]==C[period-1] and C[period-3]>C[period] and H[period-3]>=H[period-2] and H[period-3]>=H[period-1] and H[period-3]>=H[period] and Vol[period-3]<Vol[period-4] and Vol[period-3]<Vol[period-5]  then  
	Plot(LT4,period,"NoDemand"); 
end;

if L[period-3]<L[period-4] and H[period-3]<=H[period-4] and (H[period-3]-L[period-3])<(H[period-4]-L[period-4]) and C[period-3]==O[period-3] and C[period-3]==((H[period-3]-L[period-3])*0.5)+L[period-3] and C[period-3]<C[period-4] and C[period-3]==C[period-2] and C[period-3]==C[period-1] and C[period-3]<C[period] and L[period-3]<=L[period-2] and L[period-3]<=L[period-1] and L[period-3]<=L[period] and Vol[period-3]<Vol[period-4] and Vol[period-3]<Vol[period-5]  then  
	Plot(HT4,period,"NoSupply"); 
end;


if H[period-3]>H[period-4] and L[period-3]>=L[period-4] and (H[period-3]-L[period-3])<(H[period-3]-L[period-3]) and C[period-3]==O[period-3] and C[period-3]==L[period-3] and C[period-3]>C[period-4] and C[period-3]==C[period-2] and C[period-3]==C[period-1] and C[period-3]>C[period] and H[period-3]>=H[period-2] and H[period-3]>=H[period-1] and H[period-3]>=H[period] and Vol[period-3]<Vol[period-4] and Vol[period-3]<Vol[period-5] then  
	Plot(LT4,period,"NoDemand"); 
end;

if L[period-3]<L[period-4] and H[period-3]<=H[period-4] and (H[period-3]-L[period-3])<(H[period-3]-L[period-3]) and C[period-3]==O[period-3] and C[period-3]==H[period-3] and C[period-3]<C[period-4] and C[period-3]==C[period-2] and C[period-3]==C[period-1] and C[period-3]<C[period] and L[period-3]<=L[period-2] and L[period-3]<=L[period-1] and L[period-3]<=L[period] and Vol[period-3]<Vol[period-4] and Vol[period-3]<Vol[period-5]   then  
	Plot(HT4,period,"NoSupply"); 
end;


if H[period]<=H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]==O[period] and C[period]==H[period] and C[period]>C[period-1] and Vol[period]<Vol[period-1] and Vol[period]<Vol[period-2] then  
	Plot(LT1,period,"NoDemand"); 
end;

if H[period]<=H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]==O[period] and C[period]==L[period] and C[period]<C[period-1] and Vol[period]<Vol[period-1] and Vol[period]<Vol[period-2] then  
	Plot(HT1,period,"NoSupply"); 
end;


if H[period]<=H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]==O[period] and C[period]==((H[period]-L[period])*0.5)+L[period] and C[period]>C[period-1] and Vol[period]<Vol[period-1] and Vol[period]<Vol[period-2]  then  
	Plot(LT1,period,"NoDemand"); 
end;

if H[period]<=H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]==O[period] and C[period]==((H[period]-L[period])*0.5)+L[period] and C[period]<C[period-1] and Vol[period]<Vol[period-1] and Vol[period]<Vol[period-2] then  
	Plot(HT1,period,"NoSupply"); 
end;


if H[period]<=H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]==O[period] and C[period]==L[period] and C[period]>C[period-1] and Vol[period]<Vol[period-1] and Vol[period]<Vol[period-2]   then  
	Plot(LT1,period,"NoDemand"); 
end;

if H[period]<=H[period-1] and L[period]>=L[period-1] and (H[period]-L[period])<(H[period-1]-L[period-1]) and C[period]==O[period] and C[period]==H[period] and C[period]<C[period-1] and Vol[period]<Vol[period-1] and Vol[period]<Vol[period-2]  then  
	Plot(HT1,period,"NoSupply"); 
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]==O[period-2] and C[period-2]>C[period-3] and C[period-2]==C[period-1] and C[period-2]>C[period] and H[period-2]>=H[period-1] and H[period-2]>=H[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4]  then  
	Plot(LT3,period,"NoDemand"); 
end;

if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]==O[period-2] and C[period-2]<C[period-3] and C[period-2]==C[period-1] and C[period-2]<C[period] and L[period-2]<=L[period-1] and L[period-2]<=L[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4]  then  
	Plot(HT3,period,"NoSupply"); 
end;


if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]~=O[period-2] and C[period-2]==H[period-2] and C[period-2]>C[period-3] and C[period-2]==C[period-1] and C[period-2]>C[period] and H[period-2]>=H[period-1] and H[period-2]>=H[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(LT3,period,"NoDemand"); 
end;

if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]~=O[period-2] and C[period-2]==L[period-2] and C[period-2]<C[period-3] and C[period-2]==C[period-1] and C[period-2]<C[period] and L[period-2]<=L[period-1] and L[period-2]<=L[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(HT3,period,"NoSupply"); 
end;


if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]~=O[period-2] and C[period-2]==((H[period-2]-L[period-2])*0.5)+L[period-2] and C[period-2]>C[period-3] and C[period-2]==C[period-1] and C[period-2]>C[period] and H[period-2]>=H[period-1] and H[period-2]>=H[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(LT3,period,"NoDemand"); 
end;

if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]~=O[period-2] and C[period-2]==((H[period-2]-L[period-2])*0.5)+L[period-2] and C[period-2]<C[period-3] and C[period-2]==C[period-1] and C[period-2]<C[period] and L[period-2]<=L[period-1] and L[period-2]<=L[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(HT3,period,"NoSupply"); 
end;


if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]~=O[period-2] and C[period-2]==L[period-2] and C[period-2]>C[period-3] and C[period-2]==C[period-1] and C[period-2]>C[period] and H[period-2]>=H[period-1] and H[period-2]>=H[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(LT3,period,"NoDemand"); 
end;

if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]~=O[period-2] and C[period-2]==H[period-2] and C[period-2]<C[period-3] and C[period-2]==C[period-1] and C[period-2]<C[period] and L[period-2]<=L[period-1] and L[period-2]<=L[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(HT3,period,"NoSupply"); 
end;


if H[period-3]<=H[period-4] and L[period-3]>=L[period-4] and (H[period-3]-L[period-3])<(H[period-4]-L[period-4]) and C[period-3]==O[period-3] and C[period-3]==H[period-3] and C[period-3]>C[period-4] and C[period-3]==C[period-2] and C[period-3]==C[period-1] and C[period-3]>C[period] and H[period-3]>=H[period-2] and H[period-3]>=H[period-1] and H[period-3]>=H[period] and Vol[period-3]<Vol[period-4] and Vol[period-3]<Vol[period-5]  then  
	Plot(LT4,period,"NoDemand"); 
end;

if H[period-3]<=H[period-4] and L[period-3]>=L[period-4] and (H[period-3]-L[period-3])<(H[period-4]-L[period-4]) and C[period-3]==O[period-3] and C[period-3]==L[period-3] and C[period-3]<C[period-4] and C[period-3]==C[period-2] and C[period-3]==C[period-1] and C[period-3]<C[period] and L[period-3]<=L[period-2] and L[period-3]<=L[period-1] and L[period-3]<=L[period] and Vol[period-3]<Vol[period-4] and Vol[period-3]<Vol[period-5]   then  
	Plot(HT4,period,"NoSupply"); 
end;


if H[period-3]<=H[period-4] and L[period-3]>=L[period-4] and (H[period-3]-L[period-3])<(H[period-4]-L[period-4]) and C[period-3]==O[period-3] and C[period-3]==((H[period-3]-L[period-3])*0.5)+L[period-3] and C[period-3]>C[period-4] and C[period-3]==C[period-2] and C[period-3]==C[period-1] and C[period-3]>C[period] and H[period-3]>=H[period-2] and H[period-3]>=H[period-1] and H[period-3]>=H[period] and Vol[period-3]<Vol[period-4] and Vol[period-3]<Vol[period-5]  then  
	Plot(LT4,period,"NoDemand"); 
end;

if H[period-3]<=H[period-4] and L[period-3]>=L[period-4] and (H[period-3]-L[period-3])<(H[period-4]-L[period-4]) and C[period-3]==O[period-3] and C[period-3]==((H[period-3]-L[period-3])*0.5)+L[period-3] and C[period-3]<C[period-4] and C[period-3]==C[period-2] and C[period-3]==C[period-1] and C[period-3]<C[period] and L[period-3]<=L[period-2] and L[period-3]<=L[period-1] and L[period-3]<=L[period] and Vol[period-3]<Vol[period-4] and Vol[period-3]<Vol[period-5]  then  
	Plot(HT4,period,"NoSupply"); 
end;


if H[period-3]<=H[period-4] and L[period-3]>=L[period-4] and (H[period-3]-L[period-3])<(H[period-4]-L[period-4]) and C[period-3]==O[period-3] and C[period-3]==L[period-3] and C[period-3]>C[period-4] and C[period-3]==C[period-2] and C[period-3]==C[period-1] and C[period-3]>C[period] and H[period-3]>=H[period-2] and H[period-3]>=H[period-1] and H[period-3]>=H[period] and Vol[period-3]<Vol[period-4] and Vol[period-3]<Vol[period-5]  then  
	Plot(LT4,period,"NoDemand"); 
end;

if H[period-3]<=H[period-4] and L[period-3]>=L[period-4] and (H[period-3]-L[period-3])<(H[period-4]-L[period-4]) and C[period-3]==O[period-3] and C[period-3]==H[period-3] and C[period-3]<C[period-4] and C[period-3]==C[period-2] and C[period-3]==C[period-1] and C[period-3]<C[period] and L[period-3]<=L[period-2] and L[period-3]<=L[period-1] and L[period-3]<=L[period] and Vol[period-3]<Vol[period-4] and Vol[period-3]<Vol[period-5]   then  
	Plot(HT4,period,"NoSupply"); 
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==H[period-1] and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==L[period-1] and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])==(H[period-3]-L[period-3]) and C[period-2]==O[period-2] and C[period-2]==H[period-2] and C[period-2]>C[period-3] and C[period-2]==C[period-1] and C[period-2]>C[period] and H[period-2]>=H[period-1] and H[period-2]>=H[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(LT3,period,"NoDemand"); 
end;

if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])==(H[period-3]-L[period-3]) and C[period-2]==O[period-2] and C[period-2]==L[period-2] and C[period-2]<C[period-3] and C[period-2]==C[period-1] and C[period-2]<C[period] and L[period-2]<=L[period-1] and L[period-2]<=L[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] then  
	Plot(HT3,period,"NoSupply"); 
end;


if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])==(H[period-3]-L[period-3]) and C[period-2]==O[period-2] and C[period-2]==((H[period-2]-L[period-2])*0.5)+L[period-2] and C[period-2]>C[period-3] and C[period-2]==C[period-1] and C[period-2]>C[period] and H[period-2]>=H[period-1] and H[period-2]>=H[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4]   then  
	Plot(LT3,period,"NoDemand"); 
end;

if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])==(H[period-3]-L[period-3]) and C[period-2]==O[period-2] and C[period-2]==((H[period-2]-L[period-2])*0.5)+L[period-2] and C[period-2]<C[period-3] and C[period-2]==C[period-1] and C[period-2]<C[period] and L[period-2]<=L[period-1] and L[period-2]<=L[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4]  then  
	Plot(HT3,period,"NoSupply"); 
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]>C[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]<C[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==H[period-1] and C[period-1]==C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]>C[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==L[period-1] and C[period-1]==C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]<C[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]==C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]>C[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1] ~=O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]==C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]<C[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==L[period-1] and C[period-1]==C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]>C[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==H[period-1] and C[period-1]==C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]<C[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]==O[period-2] and C[period-2]==((H[period-2]-L[period-2])*0.5)+L[period-2] and C[period-2]==C[period-3] and C[period-2]==C[period-1] and C[period-2]>C[period] and H[period-2]>=H[period-1] and H[period-2]>=H[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] and C[period-3]>C[period-4] then  
	Plot(LT3,period,"NoDemand"); 
end;

if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]==O[period-2] and C[period-2]==((H[period-2]-L[period-2])*0.5)+L[period-2] and C[period-2]==C[period-3] and C[period-2]==C[period-1] and C[period-2]<C[period] and L[period-2]<=L[period-1] and L[period-2]<=L[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] and C[period-3]<C[period-4] then  
	Plot(HT3,period,"NoSupply"); 
end;


if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]==O[period-2] and C[period-2]==L[period-2] and C[period-2]==C[period-3] and C[period-2]==C[period-1] and C[period-2]>C[period] and H[period-2]>=H[period-1] and H[period-2]>=H[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] and C[period-3]>C[period-4]   then  
	Plot(LT3,period,"NoDemand"); 
end;

if H[period-2]<=H[period-3] and L[period-2]>=L[period-3] and (H[period-2]-L[period-2])<(H[period-3]-L[period-3]) and C[period-2]==O[period-2] and C[period-2]==H[period-2] and C[period-2]==C[period-3] and C[period-2]==C[period-1] and C[period-2]<C[period] and L[period-2]<=L[period-1] and L[period-2]<=L[period] and Vol[period-2]<Vol[period-3] and Vol[period-2]<Vol[period-4] and C[period-3]<C[period-4]  then  
	Plot(HT3,period,"NoSupply"); 
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==H[period-1] and C[period-1]==C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]>C[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==L[period-1] and C[period-1]==C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]<C[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]==C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]>C[period-3]  then  
	Plot(LT2,period,"NoDemand"); 
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]==C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]<C[period-3]   then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==L[period-1] and C[period-1]==C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]>C[period-3]   then  
	Plot(LT2,period,"NoDemand"); 
end;

if H[period-1]<=H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])==(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]==H[period-1] and C[period-1]==C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]<Vol[period-3] and C[period-2]<C[period-3]   then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]==Vol[period-2] and Vol[period-1]<=Vol[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]==Vol[period-2] and Vol[period-1]<=Vol[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==H[period-1] and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]==Vol[period-2] and Vol[period-1]<=Vol[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

 

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==L[period-1] and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]==Vol[period-2] and Vol[period-1]<=Vol[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end; 

if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]==Vol[period-2] and Vol[period-1]<=Vol[period-3] then   
	Plot(LT2,period,"NoDemand"); 
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]==Vol[period-2] and Vol[period-1]<=Vol[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==L[period-1] and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]==Vol[period-2] and Vol[period-1]<=Vol[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==H[period-1] and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]==Vol[period-2] and Vol[period-1]<=Vol[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]==Vol[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]==O[period-1] and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]==Vol[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==H[period-1] and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]==Vol[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==L[period-1] and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]==Vol[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]==Vol[period-3] then  
	Plot(LT2,period,"NoDemand"); 
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==((H[period-1]-L[period-1])*0.5)+L[period-1] and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]==Vol[period-3] then  
	Plot(HT2,period,"NoSupply"); 
end;


if H[period-1]>H[period-2] and L[period-1]>=L[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==L[period-1] and C[period-1]>C[period-2] and C[period-1]>C[period] and H[period-1]>=H[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]==Vol[period-3] then 
	Plot(LT2,period,"NoDemand"); 
end;

if L[period-1]<L[period-2] and H[period-1]<=H[period-2] and (H[period-1]-L[period-1])<(H[period-2]-L[period-2]) and C[period-1]~=O[period-1] and C[period-1]==H[period-1] and C[period-1]<C[period-2] and C[period-1]<C[period] and L[period-1]<=L[period] and Vol[period-1]<Vol[period-2] and Vol[period-1]==Vol[period-3] then  
	Plot(HT2,period,"NoSupply");
end;
 
	
end

