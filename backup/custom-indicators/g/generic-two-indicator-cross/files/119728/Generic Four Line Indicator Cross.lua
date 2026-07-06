-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66231

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
    indicator:name("Generic Four  Line Indicator Cross");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	

    indicator.parameters:addGroup("1. Indicator Selection");	
	indicator.parameters:addString("INDICATOR1", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR1",core.FLAG_INDICATOR);
	indicator.parameters:addInteger("Number1", "Data Stream Number", "", 1, 1 , 100);
	
    indicator.parameters:addGroup("2. Indicator Selection");	
	indicator.parameters:addString("INDICATOR2", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR2",core.FLAG_INDICATOR);
	indicator.parameters:addInteger("Number2", "Data Stream Number", "", 1, 1 , 100);
	
	indicator.parameters:addGroup("3. Indicator Selection");	
	indicator.parameters:addString("INDICATOR3", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR3",core.FLAG_INDICATOR);
	indicator.parameters:addInteger("Number3", "Data Stream Number", "", 1, 1 , 100);
	
	
	indicator.parameters:addGroup("4. Indicator Selection");	
	indicator.parameters:addString("INDICATOR4", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR4",core.FLAG_INDICATOR);
	indicator.parameters:addInteger("Number4", "Data Stream Number", "", 1, 1 , 100);
		
    
	indicator.parameters:addGroup("1.Line Style");  
	indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    
	indicator.parameters:addGroup("2.Line Style");
	indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("3.Line Style");
	indicator.parameters:addColor("color3", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("4.Line Style");
	indicator.parameters:addColor("color4", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
	
 
    indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "Execution", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");  

 
	 
	indicator.parameters:addInteger("ToTime", "Convert the date to", "", 6);
    indicator.parameters:addIntegerAlternative("ToTime", "EST", "", 1);
    indicator.parameters:addIntegerAlternative("ToTime", "UTC", "", 2);
    indicator.parameters:addIntegerAlternative("ToTime", "Local", "", 3);
    indicator.parameters:addIntegerAlternative("ToTime", "Server", "", 4);
    indicator.parameters:addIntegerAlternative("ToTime", "Financial", "", 5);
	indicator.parameters:addIntegerAlternative("ToTime", "Display", "", 6);	

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, "1./2. Line Cross");	
	Parameters (2, "1./3. Line Cross");	
	Parameters (3, "1./4. Line Cross");	
	Parameters (4, "2./3. Line Cross");	
	Parameters (5, "2./4. Line Cross");	
	Parameters (6, "3./4. Line Cross");	
	
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

 
local Number1;
local INDICATOR1;
local Number2;
local INDICATOR2;

local Number3;
local INDICATOR3;
local Number4;
local INDICATOR4;


local Indicator_FIRST=1;
local source;

local Indicator1= nil;
local Count1; 
local INDEX1;

local Indicator2= nil;
local Count2; 
local INDEX2;


local Indicator3= nil;
local Count3; 
local INDEX3;

local Indicator4= nil;
local Count4; 
local INDEX4;

 
local first; 

local  Signal={};

local 	Number = 6;
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
local ShowAlert;
local Alert={}; 
local AlertLevel={};
local ToTime;
local Shift=0; 
 
  
local First_Line,Second_Line, Third_Line,Fourth_Line;
function Prepare(nameOnly)
 
    source = instance.source;	
	 

    local name = profile:id() .. " " .. source:name()  .. " : " .. source:barSize();
	instance:name(name );
	if nameOnly then
		return;
	end
	
	ToTime=instance.parameters.ToTime;
	
	if ToTime == 1 then
	ToTime=core.TZ_EST;
	elseif ToTime == 2 then
	ToTime=core.TZ_UTC;
	elseif ToTime == 3 then
	ToTime=core.TZ_LOCAL;
	elseif ToTime == 4 then
	ToTime=core.TZ_SERVER;
	elseif ToTime == 5 then
	ToTime=core.TZ_FINANCIAL;
	elseif ToTime == 6 then
	ToTime=core.TZ_TS;
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
	
	 
	 
    INDICATOR1=instance.parameters.INDICATOR1;    
   	Number1=instance.parameters.Number1;
	Number1=Number1-1;
	
	
	INDICATOR2=instance.parameters.INDICATOR2;    
   	Number2=instance.parameters.Number2;
	Number2=Number2-1;
	
	
	INDICATOR3=instance.parameters.INDICATOR3;    
   	Number3=instance.parameters.Number3;
	Number3=Number3-1;
	
    INDICATOR4=instance.parameters.INDICATOR4;    
   	Number4=instance.parameters.Number4;
	Number4=Number4-1;
	
    for i= 1 , 6, 1 do	
	Signal[i]= instance:addInternalStream(0, 0);	 
    end	
	
		local iprofile1 = core.indicators:findIndicator(instance.parameters:getString("INDICATOR1"));
		local iparams1 = instance.parameters:getCustomParameters("INDICATOR1");
		
		local iprofile2 = core.indicators:findIndicator(instance.parameters:getString("INDICATOR2"));
		local iparams2 = instance.parameters:getCustomParameters("INDICATOR2");
		
		local iprofile3 = core.indicators:findIndicator(instance.parameters:getString("INDICATOR3"));
		local iparams3 = instance.parameters:getCustomParameters("INDICATOR3");
		
		local iprofile4 = core.indicators:findIndicator(instance.parameters:getString("INDICATOR4"));
		local iparams4 = instance.parameters:getCustomParameters("INDICATOR4");
		

		if  iprofile1:requiredSource() == core.Tick then			
			Indicator1 = iprofile1:createInstance( source.close, iparams1);
		else
			Indicator1 = iprofile1:createInstance(source, iparams1);
		end
		
		
		if  iprofile2:requiredSource() == core.Tick then			
			Indicator2 = iprofile2:createInstance( source.close, iparams2);
		else
			Indicator2 = iprofile2:createInstance(source, iparams2);
		end
		
		if  iprofile3:requiredSource() == core.Tick then			
			Indicator3 = iprofile3:createInstance( source.close, iparams3);
		else
			Indicator3 = iprofile3:createInstance(source, iparams3);
		end
		
		
		if  iprofile4:requiredSource() == core.Tick then			
			Indicator4 = iprofile4:createInstance( source.close, iparams4);
		else
			Indicator4 = iprofile4:createInstance(source, iparams4);
		end
	
	 Count1= Indicator1:getStreamCount ();
	 Count2= Indicator2:getStreamCount ();
	 Count3= Indicator3:getStreamCount ();
	 Count4= Indicator4:getStreamCount ();
	 
	 if Number1 >= Count1 then
	 Number1 = Count1;
	  assert( false, "Incorrect index of stream. The indicator has only ".. Count1  .. " stream(s).");
	 end	 
	 
	 
	  if Number2 >= Count2 then
	 Number2 = Count2;
	  assert( false, "Incorrect index of stream. The indicator has only ".. Count2  .. " stream(s).");
	 end	


    if Number3 >= Count3 then
	 Number3 = Count3;
	  assert( false, "Incorrect index of stream. The indicator has only ".. Count3 .. " stream(s).");
	 end		

    if Number4 >= Count4 then
	 Number4 = Count4;
	  assert( false, "Incorrect index of stream. The indicator has only ".. Count4  .. " stream(s).");
	 end		 
	 
	 
	INDEX1=  Indicator1:getStream (Number1);	
	INDEX2=  Indicator2:getStream (Number2);			
    INDEX3=  Indicator3:getStream (Number3);	
	INDEX4=  Indicator4:getStream (Number4);	
 
    Indicator_FIRST=math.max(INDEX1:first(),INDEX2:first(),INDEX3:first(),INDEX4:first() );
   
     First_Line = instance:addStream("First_Line", core.Line, "First_Line", "First_Line", instance.parameters.color1, Indicator_FIRST);
	 First_Line:setWidth(instance.parameters.width1);
     First_Line:setStyle(instance.parameters.style1);
	 
	 Second_Line = instance:addStream("Second_Line", core.Line, "Second_Line", "Second_Line", instance.parameters.color2, Indicator_FIRST);	 
	 Second_Line:setWidth(instance.parameters.width2);
     Second_Line:setStyle(instance.parameters.style2);
	 
	 
	 Third_Line = instance:addStream("Third_Line", core.Line, "Third_Line", "Third_Line", instance.parameters.color3, Indicator_FIRST);	 
	 Third_Line:setWidth(instance.parameters.width3);
     Third_Line:setStyle(instance.parameters.style3);
	 
	 
	  Fourth_Line = instance:addStream("Fourth_Line", core.Line, "Fourth_Line", "Fourth_Line", instance.parameters.color4, Indicator_FIRST);	 
	 Fourth_Line:setWidth(instance.parameters.width4);
     Fourth_Line:setStyle(instance.parameters.style4);
	
     for i= 1, Number , 1 do
		Alert[i]=instance:addInternalStream(0, 0);
		AlertLevel[i]=instance:addInternalStream(0, 0);
     end
	
	Initialization();	
	instance:ownerDrawn(true);	 
 	 
end



function Update(period, mode)

 
	if period < Indicator_FIRST then
	return;
	end
	 

   Indicator1:update(mode);
   Indicator2:update(mode);	
   Indicator3:update(mode);	
   Indicator4:update(mode);	
   
   
   First_Line[period]=INDEX1[period];
   Second_Line[period]=INDEX2[period];     
   Third_Line[period]=INDEX3[period];
   Fourth_Line[period]=INDEX4[period];   
				
										
												 
														if INDEX1[period]>  INDEX2[period] 
														and  INDEX1[period-1]<=  INDEX2[period-1] 
														then
														Signal[1][period]=1;													
														elseif  INDEX1[period]<  INDEX2[period]
														and  INDEX1[period-1]>=  INDEX2[period-1] 
														then
														Signal[1][period]=-1;		
														else
														Signal[1][period]=0;		
														end
										 
				                             
                                                        if INDEX1[period]>  INDEX3[period] 
														and  INDEX1[period-1]<=  INDEX3[period-1] 
														then
														Signal[2][period]=1;													
														elseif  INDEX1[period]<  INDEX3[period]
														and  INDEX1[period-1]>=  INDEX3[period-1] 
														then
														Signal[2][period]=-1;		
														else
														Signal[2][period]=0;		
														end 
														
														
														 if INDEX1[period]>  INDEX4[period] 
														and  INDEX1[period-1]<=  INDEX4[period-1] 
														then
														Signal[3][period]=1;													
														elseif  INDEX1[period]<  INDEX4[period]
														and  INDEX1[period-1]>=  INDEX4[period-1] 
														then
														Signal[3][period]=-1;		
														else
														Signal[3][period]=0;		
														end
														
														
														if INDEX2[period]>  INDEX3[period] 
														and  INDEX2[period-1]<=  INDEX3[period-1] 
														then
														Signal[4][period]=1;													
														elseif  INDEX2[period]<  INDEX3[period]
														and  INDEX2[period-1]>=  INDEX3[period-1] 
														then
														Signal[4][period]=-1;		
														else
														Signal[4][period]=0;		
														end
														
														
														if INDEX2[period]>  INDEX4[period] 
														and  INDEX2[period-1]<=  INDEX4[period-1] 
														then
														Signal[5][period]=1;													
														elseif  INDEX2[period]<  INDEX4[period]
														and  INDEX2[period-1]>=  INDEX4[period-1] 
														then
														Signal[5][period]=-1;		
														else
														Signal[5][period]=0;		
														end
														
														
														if INDEX3[period]>  INDEX4[period] 
														and  INDEX3[period-1]<=  INDEX4[period-1] 
														then
														Signal[6][period]=1;													
														elseif  INDEX3[period]<  INDEX4[period]
														and  INDEX3[period-1]>=  INDEX4[period-1] 
														then
														Signal[6][period]=-1;		
														else
														Signal[6][period]=0;		
														end
   

     if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
	
	 
	for i= 1, 6 , 1 do
			if i== 1 then
			Activate (i, period,INDEX2[period] );   
			elseif i== 2 then
			Activate (i, period,INDEX3[period] );
			elseif i== 3 then
			Activate (i, period,INDEX4[period] );	
			elseif i== 4 then
			Activate (i, period,INDEX3[period] );	
			elseif i== 5 then
			Activate (i, period,INDEX4[period] );
			elseif i== 6 then
			Activate (i, period,INDEX4[period] );
			end
    end
				
	
end
 

 
 --/////////////////////////////////////////////////////////////////
 
 
local init = false;
 
function Draw(stage, context)
 
	 if stage~= 2 then
	  return;
	  end
	  
	  
	
        if not init then
           context:createFont (1, "Wingdings", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
		
		

		
		for period= math.max(context:firstBar (),source:first()), math.min( context:lastBar (), source:size()-1), 1 do
		
		 
		
		 x, x1, x2= context:positionOfBar (period);
		 
		 for Level = 1 , Number ,  1 do
		   if Alert[Level]:hasData(period) then
		     
		    if Alert[Level][period]== 1 then
			visible, y = context:pointOfPrice (AlertLevel[Level][period]);
			
			  width, height = context:measureText (1,  "\225", 0);
              context:drawText (1,   "\225", UpTrendColor, -1,  x-width/2 ,  y , x+width/2 , y+height, 0 );	
   
			elseif Alert[Level][period]== -1 then
			visible, y = context:pointOfPrice (AlertLevel[Level][period]);
			width, height = context:measureText (1,  "\226", 0);
			 context:drawText (1,   "\226", DownTrendColor, -1,  x-width/2  ,  y-height, x+width/2 ,y, 0 );	
		    end
		  end
		    
		 
		end
		end
		
  
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
	
    assert(not (SendEmail and (Email == "" or Email == nil )), "E-mail address must be specified");
	
	
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
	  	 assert( not(PlaySound  and (Up[i] == "" or Up[i] == nil ) ), "Sound file must be chosen");
        assert (not (PlaySoundand  and (Down[i] == "" or Down[i] == nil)), "Sound file must be chosen");
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	U[i] = nil;
	D[i] = nil;	 
	end
		 
end	
 

function Activate (id, period, SignalLevel)


   Alert[id][period]=0;
   
   
  
  
	  if  ON[id]  then
	  
	       
			if  Signal[id][period]== 1
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= SignalLevel; 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over ");
							  SendAlert( Label[id]," Crossed over "); 
							  Pop(Label[id], " Cross Over ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif  Signal[id][period]== -1
            then			
			
			            			 
			                Alert[id][period]= -1;	
							AlertLevel[id][period]= SignalLevel;
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under ");								 
							 Pop(Label[id], " Cross Under ", period );  	
							 SendAlert( Label[id]," Crossed under ");
							 OnlyOnceFlag=false;
			                 end			   
	         end
			
	  
	 
	  end
	  
		   
        if FIRST then
        FIRST=false;      
        end		

end


function AsyncOperationFinished (cookie, success, message)
end

 

function SoundAlert(Sound)
 if not PlaySound then
 return;
 end

  terminal:alertSound(Sound, RecurrentSound);
end

 


function EmailAlert( label , Subject)

if not SendEmail then
return
end
 
   local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
   
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
	
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 
	 
	 
	 

function Pop(label , Subject )
  
   if not Show then
   return;
   end
   
   local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
	
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
   
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
   
   core.host:execute ("prompt", 1, label , text );


end


function SendAlert(label ,Subject, period)
    if not ShowAlert then
        return;
    end
	
	local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
 
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
 
    terminal:alertMessage(source:instrument(), source[NOW], text, now);
end
