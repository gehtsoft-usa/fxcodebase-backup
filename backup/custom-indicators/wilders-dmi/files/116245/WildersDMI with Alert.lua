-- Id: 20322
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65402

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
    indicator:name("Wilders DMI indicator");
    indicator:description("Wilders DMI indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ADXPeriod", "ADX Period", "", 13);
    indicator.parameters:addDouble("Level", "Level", "", 20);
    indicator.parameters:addBoolean("DMI_Only", "Show DMI only", "", false);
	
	
	indicator.parameters:addBoolean("Spike", "Spike Only", "", true);
	indicator.parameters:addDouble("MinSpike", "Min. ADX Level Cross Spike", "", 2);
	indicator.parameters:addDouble("Growth", "Min. ADX Growth Spike", "",2);
	
	indicator.parameters:addInteger("Selector", "Overlay Selector", "", 1);
    indicator.parameters:addIntegerAlternative("Selector", "ADX Spike Alert with Level filter ", "", 1);
    indicator.parameters:addIntegerAlternative("Selector", "ADX Spike Alert", "", 2);
    indicator.parameters:addIntegerAlternative("Selector", "DIP/DIM Alert", "", 3);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("DIPclr", "DIP Color", "DIP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DIMclr", "DIM Color", "DIM Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("ADXclr", "ADX Color", "ADX Color", core.rgb(0, 0, 255));
	
	
	  indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "Execution", "", "End of Turn");
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

	
	Parameters (1, "ADX Spike Alert with Level filter ");	
	Parameters (2, "ADX Spike Alert");	
	Parameters (3, "DIP/DIM Alert");	
	
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


local MinSpike,Spike,Growth,Selector;

local first;
local source = nil;
local ADXPeriod;
local Level;
local DMI_Only;
local DIP, DIM, ADX;
local wDIP, wDIM, wTR;
local sf;

local ChartLabelUp;
local ChartLabelDown;
function Prepare(nameOnly)
    source = instance.source;
    ADXPeriod=instance.parameters.ADXPeriod;
    Level=instance.parameters.Level;
    DMI_Only=instance.parameters.DMI_Only;
	Selector=instance.parameters.Selector;
    sf=(ADXPeriod-1)/ADXPeriod;
    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
    first = source:first()+2;
    wDIP = instance:addInternalStream(first, 0);
    wDIM = instance:addInternalStream(first, 0);
    wTR = instance:addInternalStream(first, 0);
    DIP = instance:addStream("DIP", core.Line, name .. ".DIP", "DIP", instance.parameters.DIPclr, first);
    DIP:setPrecision(math.max(2, instance.source:getPrecision()));
    DIM = instance:addStream("DIM", core.Line, name .. ".DIM", "DIM", instance.parameters.DIMclr, first);
    DIM:setPrecision(math.max(2, instance.source:getPrecision()));
    ADX = instance:addStream("ADX", core.Line, name .. ".ADX", "ADX", instance.parameters.ADXclr, first);	
    ADX:setPrecision(math.max(2, instance.source:getPrecision()));
	ADX :addLevel( Level);
	
	

	
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
	
	ChartLabelUp = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top,UpTrendColor, 0);
    ChartLabelDown = instance:createTextOutput ("Down", "Down", "Wingdings", Size, core.H_Center, core.V_Bottom, DownTrendColor, 0);
	
	 
	core.host:execute ("attachTextToChart", "Up");
	core.host:execute ("attachTextToChart","Down");
 
	
	  MinSpike= instance.parameters.MinSpike;
	  Spike = instance.parameters.Spike;
   	  Growth= instance.parameters.Growth;

     for i= 1, Number , 1 do
		Alert[i]=instance:addInternalStream(0, 0);
		AlertLevel[i]=instance:addInternalStream(0, 0);
     end
	
	Initialization();	
	instance:ownerDrawn(true);	 
	
	
end

function Update(period, mode)
   if period<first then
   return;
   end
   
    local currTR=math.max(source.high[period], source.close[period-1])-math.min(source.low[period], source.close[period-1]);
    local DeltaHi=source.high[period]-source.high[period-1];
    local DeltaLo=source.low[period-1]-source.low[period];
    local plusDM=0;
    local minusDM=0;

    if DeltaHi>DeltaLo and DeltaHi>0 then
      plusDM=DeltaHi;
    end

    if DeltaLo>DeltaHi and DeltaLo>0 then
      minusDM=DeltaLo;
    end

    wDIP[period]=sf*wDIP[period-1]+plusDM;
    wDIM[period]=sf*wDIM[period-1]+minusDM;
    wTR[period]=sf*wTR[period-1]+currTR;

    DIP[period]=0;
    DIM[period]=0;

    if wTR[period]>0 then
      DIP[period]=100*wDIP[period]/wTR[period];
      DIM[period]=100*wDIM[period]/wTR[period];
    end

    local DX;

    if DIP[period]+DIM[period]>0 then
      DX=100*math.abs(DIP[period]-DIM[period])/(DIP[period]+DIM[period])
    else
      DX=0;
    end

    ADX[period]=sf*ADX[period-1]+DX/ADXPeriod;
 
   

	
	
	if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
	
	if period<first then
    return;
    end
	
    Activate (1, period);
	Activate (2, period);
	Activate (3, period)
end



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
		 --LEvel
		 for iLevel = 1 , Number ,  1 do
		   if Alert[iLevel]:hasData(period) then
		     
		    if Alert[iLevel][period]== 1 then
			visible, y = context:pointOfPrice (AlertLevel[iLevel][period]);
			
			  width, height = context:measureText (1,  "\225", 0);
              context:drawText (1,   "\225", UpTrendColor, -1,  x-width/2 ,  y-height , x+width/2 , y, 0 );	
   
			elseif Alert[iLevel][period]== -1 then
			visible, y = context:pointOfPrice (AlertLevel[iLevel][period]);
			width, height = context:measureText (1,  "\226", 0);
			 context:drawText (1,   "\226", DownTrendColor, -1,  x-width/2  ,  y , x+width/2 ,y+height, 0 );	
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





function Activate (id, period)


  
  
	  if id == 1  and ON[id]  then
	  
	       
			if  ADX[period] > Level
			and (( Spike and math.abs(ADX[period]-ADX[period-1]) >  MinSpike) or not Spike)
			then
			           
				Alert[id][period] =1;   
 				AlertLevel[id][period]= Level;
				if Selector== 1 then
				ChartLabelUp:set(period, source.high[period ], "\217");	
                end				
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " ADX Strong Trend Spike Up ");
							  SendAlert( Label[id]," ADX Strong Trend Spike Up "); 
							  Pop(Label[id], " ADX Strong Trend Spike Up ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif  ADX[period] < Level
			and (( Spike and math.abs(ADX[period]-ADX[period-1]) >  MinSpike) or not Spike)
            then			
			
			            			 
			              Alert[id][period] =-1;   
 				         AlertLevel[id][period]= Level;
						 if Selector== 1 then
				         ChartLabelDown:set(period, source.low[period ], "\219");	
                          end	
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " ADX Weak trend Spike Down ");								 
							 Pop(Label[id], " ADX Weak trend Spike Down ", period );  	
							 SendAlert( Label[id]," ADX Weak trend Spike Down ");
							 OnlyOnceFlag=false;
			                 end			   
	         end
			
	  
	 
	  end
	  
	  
	  	  if id == 2  and ON[id]  then
	  
	       
			if 	(( Spike and math.abs(ADX[period]-ADX[period-1]) >  Growth) )
			and ADX[period] > ADX[period-1]
			then
			           
				Alert[id][period] =1;   
 				AlertLevel[id][period]= ADX[period];
				if Selector== 2 then
				ChartLabelUp:set(period, source.high[period ], "\217");	
                end			   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " ADX Spike Up ");
							  SendAlert( Label[id]," ADX Spike Up "); 
							  Pop(Label[id], " ADX Spike Up ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif (( Spike and math.abs(ADX[period]-ADX[period-1]) >  Growth) )
			and ADX[period] < ADX[period-1]
            then			
			
			            			 
			              Alert[id][period] =-1;   
 				         AlertLevel[id][period]= ADX[period];
						 if Selector== 2 then
				         ChartLabelDown:set(period, source.low[period ], "\218");	
                          end	
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " ADX Spike Down ");								 
							 Pop(Label[id], " ADX Spike Down ", period );  	
							 SendAlert( Label[id]," ADX Spike Down ");
							 OnlyOnceFlag=false;
			                 end			   
	         end
			
	  
	 
	  end
	  
	  
	  	  if id == 3  and ON[id]  then
	  
	       
			if  DIP[period] > DIM[period]
			and   DIP[period-1] <= DIM[period-1]
			then
			           
				Alert[id][period] =1;   
 				AlertLevel[id][period]=DIM[period];
				if Selector== 3 then
				ChartLabelUp:set(period, source.high[period ], "\217");	
                end			   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Up Trend ");
							  SendAlert( Label[id]," Up Trend  "); 
							  Pop(Label[id], " Up Trend  ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif  DIP[period]< DIM[period]
			and   DIP[period-1] >= DIM[period-1]
            then			
			
			            			 
			              Alert[id][period] =-1;   
 				         AlertLevel[id][period]= DIP[period];
						 if Selector== 3 then
				         ChartLabelDown:set(period, source.low[period ], "\218");	
                          end	
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Down Trend ");								 
							 Pop(Label[id], " Down Trend ", period );  	
							 SendAlert( Label[id]," Down Trend ");
							 OnlyOnceFlag=false;
			                 end			   
	         end
			
	  
	 
	  end
		   
        if FIRST then
        FIRST=false;      
        end		

end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

 
 
			  if cookie == 100 then
			  loading  = true;
		      elseif  cookie == 101 then
			  loading  = false;			  	 
               instance:updateFrom(0);            
              return core.ASYNC_REDRAW ;
			  end
		 

	
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

 
 
 
