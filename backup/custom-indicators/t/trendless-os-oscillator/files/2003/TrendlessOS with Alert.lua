-- Id: 13905

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1057

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


function Init()
    indicator:name("TrendlesOS");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
     indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("SMA_Period", "Period of SMA", " ", 7);
    indicator.parameters:addDouble("OBLevel", "OBLevel", " ", 0.0047);
    indicator.parameters:addDouble("OSLevel", "OSLevel", " ", -0.00473);
    indicator.parameters:addString("DisplayMode", "DisplayMode", "", "line");
    indicator.parameters:addStringAlternative("DisplayMode", "line", "", "line");
    indicator.parameters:addStringAlternative("DisplayMode", "histogram", "", "histogram");
    
	 indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color_1", "Color 1", "Color 1", core.rgb(0, 255, 0));
    indicator.parameters:addColor("color_2", "Color 2", "Color 2", core.rgb(0, 128, 0));
    indicator.parameters:addColor("color_3", "Color 3", "Color 3", core.rgb(255, 255, 0));
    indicator.parameters:addColor("color_4", "Color 4", "Color 4", core.rgb(255, 128, 0)); 
	 indicator.parameters:addColor("color_5", "Color 5", "Color 5", core.rgb(255, 0, 0)); 
	
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
	
	Parameters (1, "1. OB Line Cross");
	Parameters (2, "2. OB Line Cross");
	Parameters (3, "3. OB Line Cross");
	
	Parameters (4, "1. OS Line Cross");
	Parameters (5, "2. OS Line Cross");
	Parameters (6, "3. OS Line Cross");
 
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

local ShowAlert;
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

local 	Number = 6;

local SMA_Period;
local OBLevel;
local OSLevel;
local DisplayMode;

local MA;

local first;
local source = nil;
local buff1=nil;
local buff2=nil;
local buff3=nil;
local buff4=nil;
local buff5=nil;

function Prepare(nameOnly)
    SMA_Period = instance.parameters.SMA_Period;
    OBLevel = instance.parameters.OBLevel;
    OSLevel = instance.parameters.OSLevel;
    DisplayMode = instance.parameters.DisplayMode;
    source = instance.source;
    MA = core.indicators:create("MVA", source, SMA_Period);
	
	
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	Size=instance.parameters.Size;
	
    
    first = MA.DATA:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. SMA_Period .. ", " .. OBLevel .. ", " .. OSLevel .. ", " .. DisplayMode .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	 font = core.host:execute("createFont", "Wingdings", Size, false, false);
	
	
    if DisplayMode=="line" then
     buff1 = instance:addStream("buff1", core.Line, name .. ".buff1", "buff1", instance.parameters.color_1, first);   
     buff1:addLevel(0.8*OSLevel);    
     buff1:addLevel(0.6*OSLevel);    
     buff1:addLevel(0.8*OBLevel);    
     buff1:addLevel(0.6*OBLevel);    
     buff1:addLevel(OBLevel);    
     buff1:addLevel(OSLevel);    
    else
     buff1 = instance:addStream("buff1", core.Bar, name .. ".buff1", "buff1", instance.parameters.color_1, first);  
     buff1:addLevel(0.8*OSLevel);    
     buff1:addLevel(0.6*OSLevel);    
     buff1:addLevel(0.8*OBLevel);    
     buff1:addLevel(0.6*OBLevel);    
     buff1:addLevel(OBLevel);    
     buff1:addLevel(OSLevel);    
    end 
	
	
	buff1:setPrecision(math.max(2, instance.source:getPrecision()));
	
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

function Update(period, mode)


Calculate(period, mode);


     core.host:execute ("removeLabel", source:serial(period)); 
   
     if period < first then
	 return;
	 end
	 
	 
	Activate (1, period);
	Activate (2, period);
	Activate (3, period);
	Activate (4, period);
	Activate (5, period);
	Activate (6, period);
  
end

function Calculate (period,mode)

 
  MA:update(mode);
  
  if (period<first) then
 return;
 end
  
  buff1[period]=source[period]-MA.DATA[period];
  
  
   if DisplayMode=="line" then
   return;
   end
  
  if buff1[period]>0.6*OSLevel and buff1[period]<0.6*OBLevel then
    buff1:setColor(period, instance.parameters.color_2);
  elseif (buff1[period]>0.8*OSLevel and buff1[period]<=0.6*OSLevel) or (buff1[period]>=0.6*OBLevel and buff1[period]<0.8*OBLevel) then
   buff1:setColor(period, instance.parameters.color_3);
  elseif (buff1[period]>OSLevel and buff1[period]<=0.8*OSLevel) or (buff1[period]>=0.8*OBLevel and buff1[period]<OBLevel) then
    buff1:setColor(period, instance.parameters.color_3);
  else
    buff1:setColor(period, instance.parameters.color_5);
  end

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
	  
	       
			if  buff1[period] >  OBLevel 
			and   buff1[period-1] <= OBLevel 
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, OBLevel , core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
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
			elseif  buff1[period] < OBLevel
			and   buff1[period-1] >= OBLevel
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, OBLevel, core.CR_CHART, core.H_Center, core.V_Top, font, UpTrendColor, "\226");						   
						   
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
	  
	       
			if  buff1[period] >   0.8* OBLevel 
			and   buff1[period-1] <= 0.8*  OBLevel 
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, 0.8* OBLevel , core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
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
			elseif  buff1[period] < 0.8* OBLevel
			and   buff1[period-1] >= 0.8* OBLevel
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, 0.8* OBLevel, core.CR_CHART, core.H_Center, core.V_Top, font, UpTrendColor, "\226");						   
						   
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
	  
	       
			if  buff1[period] >  0.6* OBLevel 
			and   buff1[period-1] <= 0.6*OBLevel 
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, 0.6*OBLevel , core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
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
			elseif  buff1[period] < 0.6*OBLevel
			and   buff1[period-1] >= 0.6*OBLevel
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, 0.6*OBLevel, core.CR_CHART, core.H_Center, core.V_Top, font, UpTrendColor, "\226");						   
						   
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
	  
	  
	  --******************************
	  
	  
	  if id == 4  and ON[id]  then
	  
	       
			if  buff1[period] >  OSLevel 
			and   buff1[period-1] <= OSLevel 
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, OSLevel , core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
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
			elseif  buff1[period] < OSLevel
			and   buff1[period-1] >= OSLevel
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, OSLevel, core.CR_CHART, core.H_Center, core.V_Top, font, UpTrendColor, "\226");						   
						   
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
	  
	  
	   if id == 5  and ON[id]  then
	  
	       
			if  buff1[period] >   0.8* OSLevel 
			and   buff1[period-1] <= 0.8*  OSLevel 
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, 0.8* OSLevel , core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
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
			elseif  buff1[period] < 0.8* OSLevel
			and   buff1[period-1] >= 0.8* OSLevel
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, 0.8* OSLevel, core.CR_CHART, core.H_Center, core.V_Top, font, UpTrendColor, "\226");						   
						   
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
	  
	  
	   if id == 6  and ON[id]  then
	  
	       
			if  buff1[period] >  0.6* OSLevel 
			and   buff1[period-1] <= 0.6*OSLevel 
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, 0.6*OSLevel , core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
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
			elseif  buff1[period] < 0.6*OSLevel
			and   buff1[period-1] >= 0.6*OSLevel
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, 0.6*OSLevel, core.CR_CHART, core.H_Center, core.V_Top, font, UpTrendColor, "\226");						   
						   
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
 
  core.host:execute ("prompt", 1, label ,   " ( " .. source:instrument() .. " ) "  ..   label .. " : " .. note );
  
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
   
     
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;    
    local text = Note  .. delim ..  Symbol   .. delim .. Time;
 
 terminal:alertEmail(Email, profile:id(), text);
end
	 



