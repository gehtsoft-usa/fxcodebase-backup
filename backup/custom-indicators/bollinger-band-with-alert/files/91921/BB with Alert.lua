
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60189

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
function Init()
    indicator:name("Bollinger Band");
    indicator:description("Provides a relative definition of high and low based on standard deviations and a simple moving average.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Bollinger");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Period","Period", 20, 1, 10000);
    indicator.parameters:addDouble("Dev","Number of standard deviations","The number of standard deviations.", 2.0, 0.0001, 1000.0);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1","Top Band lines Color","", core.rgb(255, 0, 0));
	
    indicator.parameters:addInteger("width1","Top Band lines Width","", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Top Band lines Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addColor("clr2","Bottom Band lines Color","", core.rgb(255, 0, 0));
	 
	indicator.parameters:addInteger("width2","Bottom Band lines Width","", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Bottom Band lines Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addBoolean("HideAve", "Hide average line","Defines whether the BB average line is hidden.", true);
    indicator.parameters:addColor("clrBBA", "Average line Color","", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthBBA", "Average line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleBBA", "Average line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleBBA", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");
	
	indicator.parameters:addInteger("ToTime", "Convert the date to", "", 6);
    indicator.parameters:addIntegerAlternative("ToTime", "EST", "", 1);
    indicator.parameters:addIntegerAlternative("ToTime", "UTC", "", 2);
    indicator.parameters:addIntegerAlternative("ToTime", "Local", "", 3);
    indicator.parameters:addIntegerAlternative("ToTime", "Server", "", 4);
    indicator.parameters:addIntegerAlternative("ToTime", "Financial", "", 5);
	indicator.parameters:addIntegerAlternative("ToTime", "Display", "", 6);	
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts");
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	indicator.parameters:addBoolean("ShowHistorical", "Show Historical", "", true);
	
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, "Central Line");
	Parameters (2, "Top Line");
	Parameters (3, "Bottom Line");
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
local up={};
local down={};
local Size;
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local Show;
local ShowHistorical;
 
local Indicator;
local PlaySound;
local Live;
local FIRST=true;
local U={};
local D={};
local Dev;
local UpTrendColor, DownTrendColor;
local Alert={};
local AlertLevel={};
local ShowAlert;
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;

local firstPeriod;
local source = nil;

-- Streams block
local TL = nil;
local BL = nil;
local AL = nil;

local ToTime;

-- Routine
function Prepare(nameOnly)

    FIRST=true;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	
	ShowAlert = instance.parameters.ShowAlert;
	ShowHistorical = instance.parameters.ShowHistorical;
	
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
	
	
    N = instance.parameters.N;
    Dev = instance.parameters.Dev;
    source = instance.source;
    firstPeriod = source:first() + N - 1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. Dev .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    TL = instance:addStream("TL", core.Line, name .. ".TL", "TL", instance.parameters.clr1, firstPeriod)
    TL:setWidth(instance.parameters.width1);
    TL:setStyle(instance.parameters.style1);
    BL = instance:addStream("BL", core.Line, name .. ".BL", "BL", instance.parameters.clr2, firstPeriod)
    BL:setWidth(instance.parameters.width2);
    BL:setStyle(instance.parameters.style2);
    if not instance.parameters.HideAve then
        AL	= instance:addInternalStream(0, 0);
	else
	    AL = instance:addStream("AL", core.Line, name .. ".AL", "AL", instance.parameters.clrBBA, firstPeriod)
        AL:setWidth(instance.parameters.widthBBA);
        AL:setStyle(instance.parameters.styleBBA);
        
    end
	
	Initialization();
	instance:ownerDrawn(true);
	
	 for i= 1, Number , 1 do
		Alert[i]=instance:addInternalStream(0, 0);
		AlertLevel[i]=instance:addInternalStream(0, 0);
     end
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
	 
	end
		
	

	
end	


 function Calculate(period)
 
    if period >= firstPeriod then
        local ml = mathex.avg(source, period - N + 1, period);
        local d = mathex.stdev(source, period - N + 1, period);
        local Dd = Dev * d;
        TL[period] = ml + Dd;
        BL[period] = ml - Dd;        
        AL[period] = ml;
      
    end
 
 end

-- Indicator calculation routine
function Update(period)
 Calculate(period);
 
   
 if period < firstPeriod then
return;
end
	
    Activate (1, period); 
	Activate (2, period); 
	Activate (3, period); 
end


function Activate (id, period)

   local Shift=0; 

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
	
	  Alert[id][period]=0;
 
    if not ShowHistorical  then
	    Alert[id][period-1]=0;
    end

	  if id == 1  and ON[id]  then
	  
	       
			if source[period] > AL[period]
			and source[period-1] <= AL[period-1]
			then
			           
						  
			Alert[id][period]= 1;	
 			AlertLevel[id][period]= AL[period];		   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over ", period);
							   SendAlert( Label[id]," Cross Over ", period);     
							        if Show then
									Pop(Label[id], " Cross Over ", period );  	
								    end
								 
							  end
			elseif  source[period] < AL[period]
			and source[period-1] >= AL[period-1]
            then			
			
			            			 
			Alert[id][period]= -1;	
 			AlertLevel[id][period]= AL[period];		             
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under ", period);
                             SendAlert( Label[id]," Cross Under ", period);   							 
								 if Show then
									Pop(Label[id], " Cross Under ", period );  	
								 end
							 
			                  end			   
	         end
			
	  elseif id == 2  and ON[id]  then
	  
	       --Top Line 
			if source[period] > TL[period]
			and source[period-1] <= TL[period-1]
			then
			           
						 
			Alert[id][period]= 1;	
 			AlertLevel[id][period]= TL[period];					   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							  SendAlert( Label[id]," Cross Over ", period);   
							        if Show then
									Pop(Label[id], " Cross Over " , period);  	
								    end
								 
							  end
			elseif  source[period] < TL[period]
			and source[period-1] >= TL[period-1]
            then			
			
			            			 
			Alert[id][period]= -1;	
 			AlertLevel[id][period]= TL[period];	              
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under ", period);	
							  SendAlert( Label[id], " Cross Under ", period);   
								 if Show then
									Pop(Label[id], " Cross Under ", period);  	
								 end
							 
			                  end			   
	         end
			 
			 
			elseif id == 3  and ON[id]  then 
			 --Bottom Line 
			if source[period] > BL[period]
			and source[period-1] <= BL[period-1]
			then
			           
						 
			Alert[id][period]= 1;	
 			AlertLevel[id][period]= BL[period];				   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Under ", period);
							  SendAlert( Label[id]," Cross Under ", period);      
							        if Show then
									Pop(Label[id], " Cross Under ", period );  	
								    end
								 
							  end
			elseif  source[period] < BL[period]
			and source[period-1] >= BL[period-1]
            then			
			
			            			 
			Alert[id][period]= -1;	
 			AlertLevel[id][period]= BL[period];	             
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under ", period);	
							 SendAlert( Label[id],  " Cross Under ", period);   
								 if Show then
									Pop(Label[id], " Cross Under " , period);  	
								 end
							 
			                  end			   
	         end
			
	  
	 
	  end
	 

	  
		   
        if FIRST then
        FIRST=false;      
        end		

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
		 
		 for Level = 1 , Number ,  1 do
		   if Alert[Level]:hasData(period) then
		     
		    if Alert[Level][period]== 1 then
			visible, y = context:pointOfPrice (AlertLevel[Level][period]);
			
			  width, height = context:measureText (1,  "\225", 0);
              context:drawText (1,   "\225", UpTrendColor, -1,  x-width/2 ,  y-height , x+width/2 , y, 0 );	
   
			elseif Alert[Level][period]== -1 then
			visible, y = context:pointOfPrice (AlertLevel[Level][period]);
			width, height = context:measureText (1,  "\226", 0);
			 context:drawText (1,   "\226", DownTrendColor, -1,  x-width/2  ,  y , x+width/2 ,y+height, 0 );	
		    end
		  end
		    
		 
		end
		end
		
  
end		



function AsyncOperationFinished (cookie, success, message)
end

function Pop(AlertLabel , AlertText, period)
 
 
   local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
   
   local delim = "\013\010";   
	
   local Symbol= "Instrument : " .. source:instrument() ;
   local TF= "Time Frame : " .. source:barSize();   
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .. delim .. " Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
    local Text= Symbol .. delim ..  TF .. delim ..  Time.. delim ..  AlertLabel .. ":" ..    AlertText     
   core.host:execute ("prompt", 1, profile:id(),  Text );


end

function SoundAlert(Sound)
 if not PlaySound then
 return;
 end
 
 terminal:alertSound(Sound, RecurrentSound);
end

function EmailAlert(AlertLabel , AlertText, period)

if not SendEmail then
return
end

   local delim = "\013\010";   

     local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
	
   local Symbol= "Instrument : " .. source:instrument() ;
   local TF= "Time Frame : " .. source:barSize();   
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .. delim .. " Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
   
    local Text= Symbol .. delim ..  TF .. delim ..  Time.. delim ..  AlertLabel .. ":" ..    AlertText  
	
 
 terminal:alertEmail(Email, profile:id(), Text);
end
	 


function SendAlert(AlertLabel , AlertText, period)
    if not ShowAlert then
        return;
    end
	
	local delim = "\013\010";  
	
	 local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
	
   local Symbol= "Instrument : " .. source:instrument() ;
   local TF= "Time Frame : " .. source:barSize();   
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .. delim ..  "Time :"   .. DATA.hour  .. " / ".. DATA.min .." / ".. DATA.sec; 
  
    local Text= Symbol .. delim ..  TF .. delim ..  Time.. delim ..  AlertLabel .. ":" ..    AlertText  
	
 
    terminal:alertMessage(source:instrument(), source[NOW], Text, source:date(NOW));
end


