-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64483
-- Id: 17712

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Custom Pivot");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
    indicator.parameters:addGroup("Calculation"); 
 
    	indicator.parameters:addString("TF", "Bar Size to display High/Low", "", "D1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	local iLevel={0,38,61,78,100,138,161,200};
  	indicator.parameters:addInteger("iShift", "Shift", "", 0);
  
  

    for i=2, 8, 1 do	
		
		indicator.parameters:addDouble("Level"..i, (i-1)..". Level", "", iLevel[i]);		
		
	end
	
	indicator.parameters:addBoolean("level_value_in_label", "Show Level Value in Label", "", false);
	
	
	local Color={core.rgb(128, 128, 128), core.rgb(255, 0, 0), core.rgb(0, 255, 0), core.rgb(0, 0, 255), core.rgb(128, 255, 0), core.rgb(255, 128, 0), core.rgb(128, 0, 255), core.rgb(255, 0, 128)};
	
	for i=1, 8, 1 do	
	 if i== 1 then
	  indicator.parameters:addGroup("Pivot Line Style"); 
	 else
	 indicator.parameters:addGroup((i-1)..". Line Style"); 
	 end
	indicator.parameters:addColor("Color"..i, "Line Color", "", Color[i]);  
    indicator.parameters:addInteger("Width"..i, "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("Style"..i, "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Style"..i, core.FLAG_LINE_STYLE);
	end
 
	      indicator.parameters:addColor("iLabel", "Label Color", "Label", core.COLOR_LABEL );
		indicator.parameters:addInteger("iSize", "Font Size", "", 20);
		
		
		  indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "Execution", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Arrow Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, "Pivot Line");
    Parameters (2, "R1 Line");	
	Parameters (3, "R2 Line");	
	Parameters (4, "R3 Line");	
	Parameters (5, "R4 Line");	
	Parameters (6, "R5 Line");	
	Parameters (7, "R6 Line");
	Parameters (8, "R7 Line");
	
	Parameters (9, "S1 Line");	
	Parameters (10, "S2 Line");	
	Parameters (11, "S3 Line");	
	Parameters (12, "S4 Line");	
	Parameters (13, "S5 Line");	
	Parameters (14, "S6 Line");	
	Parameters (15, "S7 Line");	
	
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

local 	Number = 15;
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
local Shift=0; 
local Alert={}; 
local AlertLevel={};

local source;                    
 
 
      local LabelText={"PP", "R1", "R2", "R3", "R4",  "R5", "R6", "R7", "S1", "S2", "S3", "S4",  "S5", "S6", "S7"  } ;
	  local Value= {};
     local FinalLevel={};	--Level
     local Color={};
     local Style={};
     local Width={};	
     local Level={};	 
      local TF;
	  local Source;
	  local loading = false;
	  local iShift;
	  local iLabel;
	  local iSize;
function Prepare(nameOnly)
    source = instance.source;
	first=source:first();  
    local name = profile:id() ;
	instance:name(name); 
	if nameOnly then
		return;
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
	
	if instance.parameters.level_value_in_label then
		LabelText = {"PP",
					 "R" .. instance.parameters.Level2,
					 "R" .. instance.parameters.Level3,
					 "R" .. instance.parameters.Level4,
					 "R" .. instance.parameters.Level5,
					 "R" .. instance.parameters.Level6,
					 "R" .. instance.parameters.Level7,
					 "R" .. instance.parameters.Level8,
					 "S" .. instance.parameters.Level2,
					 "S" .. instance.parameters.Level3,
					 "S" .. instance.parameters.Level4,
					 "S" .. instance.parameters.Level5,
					 "S" .. instance.parameters.Level6,
					 "S" .. instance.parameters.Level7,
					 "S" .. instance.parameters.Level8};
	end
	
 
    TF = instance.parameters.TF;
	iShift = instance.parameters.iShift;
	iLabel = instance.parameters.iLabel;
	iSize = instance.parameters.iSize;
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	
	Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0, 100, 101);
	loading=true;
	

	 
	 for i=1, 8 , 1 do
		 if i==1 then
		 Level[i]=0;
		 else	 
		 Level[i]=instance.parameters:getDouble("Level" ..i);
		 end
		 
		 Color[i]=instance.parameters:getColor("Color" ..i)
         Style[i]=instance.parameters:getInteger("Style" ..i)
         Width[i]=instance.parameters:getInteger("Width" ..i)
 
	 end
	 
	 	 FinalLevel[1]= nil;	
          instance:ownerDrawn(true);
	 
	      for i= 1, Number , 1 do
		Alert[i]=instance:addInternalStream(0, 0);
		AlertLevel[i]=instance:addInternalStream(0, 0);
     end
	
	Initialization();
	
 


 
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end

-- P
local init = false;
 
function Draw(stage, context)
    if stage ~= 2
	or FinalLevel[1]== nil
	then
	return;
	end
	
        if not init then		
		for i= 1, 8, 1 do
		context:createPen (i, context:convertPenStyle (Style[i]), context:pointsToPixels (Width[i]), Color[i]);
		context:createFont (10, "Arial",   iSize, iSize, 0);
		  context:createFont (11, "Wingdings", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
		end
            init = true;

		end
		for i= 1, 8, 1 do
		
			if i == 1 then
			visible, y1= context:pointOfPrice (FinalLevel[i]);
			context:drawLine (i,context:left (), y1, context:right (), y1);
			
			width, height=context:measureText (10, LabelText[i], 0);
			context:drawText (10, LabelText[i], iLabel, -1, context:right ()-width, y1+height, context:right (), y1, 0);
			else
			
			visible, y1= context:pointOfPrice (FinalLevel[i]);
			context:drawLine (i,context:left (), y1, context:right (), y1);
			visible, y2= context:pointOfPrice (FinalLevel[i+7]);		
			context:drawLine (i,context:left (), y2, context:right (), y2);
			
			width1, height1=context:measureText (10, LabelText[i], 0);
			width2, height2=context:measureText (10, LabelText[i+7], 0);
			
			context:drawText (10, LabelText[i], iLabel, -1, context:right ()-width1, y1-height1, context:right (), y1, 0);
			context:drawText (10, LabelText[i+7], iLabel, -1, context:right ()-width2, y2-height2, context:right (), y2, 0);
			
			
			end
			
			 
		end
	
		for period= math.max(context:firstBar (),source:first()), math.min( context:lastBar (), source:size()-1), 1 do
		
		 
		
		 x, x1, x2= context:positionOfBar (period);
		 
		 for Level = 1 , Number ,  1 do
		   if Alert[Level]:hasData(period) then
		     
		    if Alert[Level][period]== 1 then
			visible, y = context:pointOfPrice (AlertLevel[Level][period]);
			
			  width, height = context:measureText (11,  "\225", 0);
              context:drawText (11,   "\225", UpTrendColor, -1,  x-width/2 ,  y-height , x+width/2 , y, 0 );	
   
			elseif Alert[Level][period]== -1 then
			visible, y = context:pointOfPrice (AlertLevel[Level][period]);
			width, height = context:measureText (11,  "\226", 0);
			 context:drawText (11,   "\226", DownTrendColor, -1,  x-width/2  ,  y , x+width/2 ,y+height, 0 );	
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

 
 
 local LastZone=0;
-- the function which is called to calculate the period
function Update(period  ) 	 


 if period < source:size()-1
 or loading
 then
 return;
 end
     
	  local Last= Source:size()-1-iShift;
      local  PreviousHigh  = Source.high[Last];
      local PreviousLow   = Source.low[Last];
      local PreviousClose = Source.close[Last];
      FinalLevel[1]  =  (PreviousHigh+PreviousLow+PreviousClose)/3;--1
      FinalLevel[2] = FinalLevel[1] + ((PreviousHigh-PreviousLow) *(Level[2]/100));
      FinalLevel[9] = FinalLevel[1] - ((PreviousHigh-PreviousLow) *( Level[2]/100));
      FinalLevel[3] = FinalLevel[1] + ((PreviousHigh-PreviousLow) *( Level[3]/100));
      FinalLevel[10] = FinalLevel[1] - ((PreviousHigh-PreviousLow) *( Level[3]/100));
      FinalLevel[4] = FinalLevel[1] + ((PreviousHigh-PreviousLow) *( Level[4]/100));
      FinalLevel[11] = FinalLevel[1] - ((PreviousHigh-PreviousLow) *( Level[4]/100));
      FinalLevel[5] = FinalLevel[1] + ((PreviousHigh-PreviousLow) *( Level[5]/100));
      FinalLevel[12] = FinalLevel[1] - ((PreviousHigh-PreviousLow) *( Level[5]/100));
      FinalLevel[6] = FinalLevel[1] + ((PreviousHigh-PreviousLow) *( Level[6]/100));
      FinalLevel[13] = FinalLevel[1] - ((PreviousHigh-PreviousLow) *( Level[6]/100));
      FinalLevel[7] = FinalLevel[1] + ((PreviousHigh-PreviousLow) *( Level[7]/100));
      FinalLevel[14] = FinalLevel[1] - ((PreviousHigh-PreviousLow) *( Level[7]/100));
      FinalLevel[8] = FinalLevel[1] + ((PreviousHigh-PreviousLow) *( Level[8]/100));
      FinalLevel[15] = FinalLevel[1] - ((PreviousHigh-PreviousLow) *( Level[8]/100));
	  

    if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
 
	for i= 1, 15, 1 do
    Activate (i, period);
	end
	
end



function Activate (id, period)


   Alert[id][period]=0;
   
   
  
  
	  if   ON[id]  then
	  
	       
			if  source.close[period] > FinalLevel[id]
			and   source.close[period-1] <= FinalLevel[id]
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= FinalLevel[id]
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over ", period);
							  SendAlert( Label[id]," Crossed over ", period); 
							  Pop(Label[id], " Cross Over ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif  source.close[period] < FinalLevel[id]
			and   source.close[period-1] >= FinalLevel[id]
            then			
			
			            			 
			                Alert[id][period]= -1;	
							AlertLevel[id][period]= FinalLevel[id]
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under ", period);								 
							 Pop(Label[id], " Cross Under ", period );  	
							 SendAlert( Label[id]," Crossed under ", period);
							 OnlyOnceFlag=false;
			                 end			   
	         end
			
	  
	 
	  end
	  
		   
        if FIRST then
        FIRST=false;      
        end		

end


 

function SoundAlert(Sound)
 if not PlaySound then
 return;
 end

  terminal:alertSound(Sound, RecurrentSound);
end

 


function EmailAlert( label , Subject, period)

if not SendEmail then
return
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
	 
	 
	 
	 

function Pop(label , Subject, period)
  
   if not Show then
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
	
   
   core.host:execute ("prompt", 1, label , text );


end


function SendAlert(label ,Subject, period)
    if not ShowAlert then
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
	
 
    terminal:alertMessage(source:instrument(), source[NOW], text, source:date(NOW));
end

 