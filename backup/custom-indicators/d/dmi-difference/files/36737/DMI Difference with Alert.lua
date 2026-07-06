-- Id: 13983
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=20973

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("DMI Difference");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("DMI Calculation");
	indicator.parameters:addInteger("Period", "Period", "", 14, 2, 1000);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
	indicator.parameters:addGroup("Zone Style");
	indicator.parameters:addBoolean("ShowZones" , "Show Zones" , "", true);
	indicator.parameters:addColor("Top", "OB Zone Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Bottom", "OS Zone Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Transparency", "Channel transparency (%)", "", 70, 0, 100);

	
	indicator.parameters:addDouble("Top_Level", "Top Level", "", 25);
	indicator.parameters:addDouble("Bottom_Level", "Bottom Level", "", -25);
	
	indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live"); 
	
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
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
	
	Parameters (1, "Zero Line");
	Parameters (2, "OB Line");
	Parameters (3, "OS Line");
   
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

local 	Number = 3; 
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local ShowZones;
local Top, Bottom;
local  Difference=nil;
local OB,OS;
local Max, Step, Period;
local Transparency;
local DMI;
local SAR;


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
local UpTrendColor, DownTrendColor;
local OnlyOnceFlag;
local font;
local ShowAlert;

local Difference_OB, Difference_OS;
function Prepare(nameOnly)
    Period= instance.parameters.Period;	
	source = instance.source;
	ShowZones= instance.parameters.ShowZones;
	Top= instance.parameters.Top;
	Bottom= instance.parameters.Bottom;
	Top_Level= instance.parameters.Top_Level;
	Bottom_Level= instance.parameters.Bottom_Level;
	Transparency= instance.parameters.Transparency;
   
    local name = profile:id() .. "(" .. source:name() ..", ".. Period.. ")";
    instance:name(name);
	if nameOnly then
		return;
	end
	
	DMI=core.indicators:create("DMI",  source, Period); 
	
	first= DMI.DATA:first();

    	
	Difference = instance:addStream("Difference", core.Line, name, "Difference",  instance.parameters.color, first);
	Difference:setWidth(instance.parameters.width );
    Difference:setStyle(instance.parameters.style );
	Difference:addLevel(Top_Level);
    Difference:addLevel(Bottom_Level);
	
	Difference:setPrecision(math.max(2, instance.source:getPrecision()));
	
	OS = instance:addInternalStream(0, 0);
	OB = instance:addInternalStream(0, 0);
	
    Difference_OS = instance:addInternalStream(0, 0);
	Difference_OB = instance:addInternalStream(0, 0);	
	
	if ShowZones then
	instance:createChannelGroup ("OB", "OB",   Difference_OS, OS, Top, Transparency);
	instance:createChannelGroup ("OS", "OS",   OB, Difference_OB,  Bottom, Transparency);
	end
	
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	Size=instance.parameters.Size;
	
	font = core.host:execute("createFont", "Wingdings", Size, false, false);
	
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

-- Indicator calculation routine
function Update(period, mode)
		

			DMI:update(mode);
			
			if period < first then
			return;
			end
	    
    Difference[period]= DMI.DIP[period]-DMI.DIM[period];
	OB[period]= Top_Level;
	Difference_OB[period]=100; 
	 
	OS[period]=Bottom_Level;	
    Difference_OS[period]= -100; 
	
	core.host:execute ("removeLabel", source:serial(period)); 
	
	Activate (1, period);
	Activate (2, period);
	Activate (3, period);
	 
	
 end
 
 
 
function ReleaseInstance()
       core.host:execute("deleteFont", font);
end	   

function Activate (id, period)

   local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
 
	  if id == 1  and ON[id]  then
	  
	       
			if  Difference[period] > 0
			and   Difference[period-1] <= 0
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, 0, core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							  SendAlert("Crossed over");  
							        
									Pop(Label[id], " Cross Over " );  	
								    
								 
							  end
			elseif  Difference[period] < 0
			and   Difference[period-1] >= 0
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, 0, core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 
									Pop(Label[id], " Cross Under " );  	
								    SendAlert("Crossed under");
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
	  
	   if id == 2  and ON[id]  then
	  
	       
			if  Difference[period] > Top_Level
			and   Difference[period-1] <= Top_Level
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, Top_Level, core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							  SendAlert("Crossed over");  
							        
									Pop(Label[id], " Cross Over " );  	
								    
								 
							  end
			elseif  Difference[period] < Top_Level
			and   Difference[period-1] >= Top_Level
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, Top_Level, core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 
									Pop(Label[id], " Cross Under " );  	
								    SendAlert("Crossed under");
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
	  
	  
	   if id == 3  and ON[id]  then
	  
	       
			if  Difference[period] > Bottom_Level
			and   Difference[period-1] <= Bottom_Level
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, Bottom_Level, core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							  SendAlert("Crossed over");  
							        
									Pop(Label[id], " Cross Over " );  	
								    
								 
							  end
			elseif  Difference[period] < Bottom_Level
			and   Difference[period-1] >= Bottom_Level
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, Bottom_Level, core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 
									Pop(Label[id], " Cross Under " );  	
								    SendAlert("Crossed under");
							 
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
	 




