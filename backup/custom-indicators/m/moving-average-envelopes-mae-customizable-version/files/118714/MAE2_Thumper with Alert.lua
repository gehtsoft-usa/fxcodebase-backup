-- Id: 21682
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=658

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
    indicator:name("Moving Average Envelope (New Version)");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods for Moving Average", "", 14);
    indicator.parameters:addString("MET", "Moving Average Method", "The methods marked by an asterisk (*) require the appropriate indicators to be loaded.", "MVA");
    indicator.parameters:addStringAlternative("MET", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MET", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MET", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MET", "SMMA*", "", "SMMA");
    indicator.parameters:addStringAlternative("MET", "Vidya (1995)*", "", "VIDYA");
    indicator.parameters:addStringAlternative("MET", "Vidya (1992)*", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MET", "Wilders*", "", "WMA");

    indicator.parameters:addDouble("B", "Band Width", "", 25);
    indicator.parameters:addString("BWU", "Band Width Units", "", "%%");
    indicator.parameters:addStringAlternative("BWU", "In 1/100 of percent", "", "%%");
    indicator.parameters:addStringAlternative("BWU", "In pips", "", "pip(s)");
    indicator.parameters:addInteger("Period", "Periods for Switch", "", 3);
    
    indicator.parameters:addGroup("Shift");
    indicator.parameters:addString("Method", "Method", "Method" , "Pips");
    indicator.parameters:addStringAlternative("Method", "Pips", "Pips" , "Pips");
    indicator.parameters:addStringAlternative("Method", "Value", "Value" , "Value");
	indicator.parameters:addStringAlternative("Method", "Percentage", "Percentage" , "Percentage");
    indicator.parameters:addInteger("SX", "Shift in periods", "Postive is future, negative is past", 0);
    indicator.parameters:addDouble("SY", "Shift in points", "", 0);


    indicator.parameters:addGroup("Style");
    indicator.parameters:addBoolean("SM", "Show MA line", "", true);
    indicator.parameters:addColor("MVA_color", "Color of MA line", "", core.rgb(0, 0, 255)); 
    indicator.parameters:addColor("UpC", "Color of Up Band", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DownC", "Color of Down Band", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("NeutralC", "Neutral Color", "", core.rgb(128, 128, 128));
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

	
	Parameters (1, "Top Line");	
	Parameters (2, "Bottom Line");	
	Parameters (3, "Central Line");	

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

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local N;
local B;
local BWU;
local MET;
local SM;

local first;
local first2 = 0;
local source = nil;
local IND;
local Period;

-- Streams block
local MVA = nil;
local UB = nil;
local LB = nil;

-- Shift params
local SX, SY;
local ShiftMethod;
local UpC, DownC,NeutralC;

-- output candles
local open=nil;
local close=nil;
local high=nil;
local low=nil;
local color=nil;


-- Routine
 function Prepare(nameOnly) 
    N = instance.parameters.N;
    B = instance.parameters.B;
    BWU = instance.parameters.BWU;
    MET = instance.parameters.MET;
    SM = instance.parameters.SM;
    source = instance.source;
    assert(core.indicators:findIndicator(MET) ~= nil, MET .. " indicator must be installed");
    IND = core.indicators:create(MET, source, N);
    ShiftMethod=instance.parameters.Method;
    SX = instance.parameters.SX;

    UpC=instance.parameters.UpC;
	DownC=instance.parameters.DownC;
	NeutralC=instance.parameters.NeutralC;
	
	Period=instance.parameters.Period;

    first = IND.DATA:first();    
    first2 = first + SX;
    if first2 < 0 then
        first2 = 0;
    end


    local name = profile:id() .. "(" .. source:name() .. "," .. MET .. "(" .. N .. ")," .. B .. BWU .. ", " .. instance.parameters.SX .. " bars," .. instance.parameters.SY .. " points)";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	if  instance.parameters.ToTime == 1 then
	ToTime=core.TZ_EST;
	elseif  instance.parameters.ToTime == 2 then
	ToTime=core.TZ_UTC;
	elseif  instance.parameters.ToTime == 3 then
	ToTime=core.TZ_LOCAL;
	elseif  instance.parameters.ToTime == 4 then
	ToTime=core.TZ_SERVER;
	elseif  instance.parameters.ToTime == 5 then
	ToTime=core.TZ_FINANCIAL;
	elseif  instance.parameters.ToTime == 6 then
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
	
	
	
	

    if BWU == "%%" then
        BWU = 1;
    else
        BWU = 2;
        B = B * source:pipSize();
    end

    if SM then
        MVA = instance:addStream("MVA", core.Line, name .. ".MVA", "MVA", instance.parameters.MVA_color, first2, SX);
	else
	   MVA= instance:addInternalStream(0, 0);
    end
    
	if Method=="Pips" then
        SY = instance.parameters.SY * source:pipSize();
    else 
        SY = instance.parameters.SY;
	end

    UB = instance:addStream("UB", core.Line, name .. ".UB", "UB", instance.parameters.UpC, first2, SX);
    LB = instance:addStream("LB", core.Line, name .. ".LB", "LB", instance.parameters.DownC, first2, SX);   
    
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);

	color = instance:addInternalStream(0, 0);
	
	
	for i= 1, Number , 1 do
		Alert[i]=instance:addInternalStream(0, 0);
		AlertLevel[i]=instance:addInternalStream(0, 0);
     end
	
	Initialization();	
	instance:ownerDrawn(true);
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




-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];


    local p1 = period + SX;
    if p1 >= 0 and period >= first then   
        IND:update(mode);

        local d = IND.DATA[period];
        local s;

        if BWU == 1 then
            s = d * B / 10000;
        else
            s = B;
        end

        
            if ShiftMethod~="Percentage" then
                MVA[p1] = d + SY;
            else
                MVA[p1] = d + (d/100)*SY;
            end
     
                    
        if ShiftMethod~="Percentage" then
            UB[p1] = (d + s)+ SY;
            LB[p1] = (d - s)+ SY;
        else
            UB[p1] = (d + s) + ((d + s)/100)*SY;
            LB[p1] = (d - s) + ((d - s)/100)*SY;
        end
        
        if period >= first + SX - Period then
            Check(period);
            if color[period] == 1 then 
                open:setColor(period, UpC);
            elseif color[period] == -1  then
                open:setColor(period, DownC);	
            else 
                open:setColor(period, NeutralC);				 
            end
        else
            open:setColor(period, NeutralC);		
        end
    else
        open:setColor(period, NeutralC);			
    end
	
	  if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
	
	
  
	
    Activate (1, period)
	Activate (2, period)
	Activate (3, period)

end

function Check(period)
    local i;
	local T=1;
	local D=1;
	local N=1;

	for i= period, period-Period+1, -1 do
	     
	    if (UB:size() < i or LB:size() < i) then 
	        return 
	    end   
	   
	        
	    if source.close[i]< UB[i] then
		T=0;
		end
		
		if source.close[i]> LB[i] then
		D=0;
		end
		
		if source.close[i]<  LB[i] or  source.close[i]> UB[i] then
		N=0;
		end
	
	    if T== 0 and D== 0 and N== 0 then
		return;
		end
	
	end
	
    
    if T== 1 then 
        color[period]= 1;
	elseif D== 1 then 
        color[period]=-1;
	elseif N== 1 then 
        color[period] =0; 
     end

end



function Activate (id, period)


   Alert[id][period]=0;
   
   
  
  
	  if id == 1  and ON[id] 
	  and period > first2+2
	  then
	  
	       
			if  source.close[period] > UB[period] 
			and   source.close[period-1] <= UB[period-1] 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= UB[period] 
						   
			
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
							  
			elseif  source.close[period] < UB[period] 
			and   source.close[period-1] >= UB[period-1] 
            then			
			
			            			 
			                Alert[id][period]= -1;	
							AlertLevel[id][period]= UB[period] 
						   
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
	  
	  
	  if id == 2  and ON[id]
	  and period > first2+2
	  then
	  
	       
			if  source.close[period] > LB[period] 
			and   source.close[period-1] <= LB[period-1] 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= LB[period] 
						   
			
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
							  
			elseif  source.close[period] < LB[period] 
			and   source.close[period-1] >= LB[period-1] 
            then			
			
			            			 
			                Alert[id][period]= -1;	
							AlertLevel[id][period]=LB [period] 
						   
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
	  
	  
	  
	  if id == 3  and ON[id] 
	  and period > IND.DATA:first()+2
	  then
	  
	       
			if  source.close[period] > MVA [period] 
			and   source.close[period-1] <= MVA[period-1] 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= MVA[period] 
						   
			
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
							  
			elseif  source.close[period] < MVA[period] 
			and   source.close[period-1] >= MVA[period-1] 
            then			
			
			            			 
			                Alert[id][period]= -1;	
							AlertLevel[id][period]= MVA[period] 
						   
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


function AsyncOperationFinished (cookie, success, message)
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
	 
	 
	 
	 
function Pop(AlertLabel , AlertText, period)
 
 
 if not Show then
   return;
   end
 
   local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
   
   local delim = "\013\010";   
	
   local Symbol= "Instrument : " .. source:instrument() ;
   local TF= "Time Frame : " .. source:barSize();   
    local Time =  "Date : " .. DATA.month.." / ".. DATA.day .. delim .. " Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
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
    local Time =  "Date : " .. DATA.month.." / ".. DATA.day .. delim .. " Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
   
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
    local Time =  "Date : " .. DATA.month.." / ".. DATA.day .. delim ..  "Time :"   .. DATA.hour  .. " / ".. DATA.min .." / ".. DATA.sec; 
  
    local Text= Symbol .. delim ..  TF .. delim ..  Time.. delim ..  AlertLabel .. ":" ..    AlertText  
	
 
    terminal:alertMessage(source:instrument(), source[NOW], Text, source:date(NOW));
end
