-- Id: 18054
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


function Init()
    indicator:name("Alligator MA Cross with Alert");
    indicator:description("")
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
	

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("JawN", "Alligator Jaw smoothing periods", "", 13, 1, 300);
    indicator.parameters:addInteger("JawS", "Alligator Jaw shifting periods", "", 8, 0, 300);

    indicator.parameters:addInteger("TeethN", "Alligator Teeth smoothing periods", "", 8, 1, 300);
    indicator.parameters:addInteger("TeethS", "Alligator Teeth shifting periods", "", 5, 0, 300);

    indicator.parameters:addInteger("LipsN", "Alligator Lips smoothing periods", "", 5, 1, 300);
    indicator.parameters:addInteger("LipsS", "Alligator Lips shifting periods", "", 3, 0, 300);

    indicator.parameters:addString("MTH","Smoothing method", "", "SMMA");
    indicator.parameters:addStringAlternative("MTH", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MTH", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MTH", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MTH", "LSMA", "", "REGRESSION");
    indicator.parameters:addStringAlternative("MTH", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MTH", "Vidya1995", "", "VIDYA");
    indicator.parameters:addStringAlternative("MTH", "Vidya1992", "", "VIDYA92");
    indicator.parameters:addStringAlternative("MTH", "Wilders", "", "WMA");
	
	 indicator.parameters:addGroup("MA Calculation");
	 
	 indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	

	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("Period", "Period", "Period" , 50);
  
	indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "Execution", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor0", "Up Trend Color", "",core.COLOR_LABEL );
	indicator.parameters:addColor("DownTrendColor0", "Down Trend Color", "",core.COLOR_LABEL );
	
	indicator.parameters:addColor("UpTrendColor1", "Jaw Cross Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("DownTrendColor1", "Jaw Cross Down Trend Color", "", core.rgb(0, 0, 255));
	
	indicator.parameters:addColor("UpTrendColor2", "Teeth Cross Up Trend Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("DownTrendColor2", "Teeth Cross Down Trend Color", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addColor("UpTrendColor3", "Lips Cross Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DownTrendColor3", "Lips Cross Down Trend Color", "", core.rgb(0, 255, 0));
	
 
	indicator.parameters:addInteger("FontSize", "Label Size", "", 20, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, "MA/Jaw");	
	Parameters (2, "MA/Teeth");
	Parameters (3, "MA/Lips");
  
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


local Number = 3;
local Up={};
local Down={};
local Label={};
local ON={};
local FontSize;
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
local UpTrendColor={};
local DownTrendColor={};
local OnlyOnceFlag;
local font;
local ShowAlert;
local AlertShift=0; 
local Alert={}; 
local AlertLevel={};
-- Routine


-- lines parameters
local JawN, JawS;
local TeethN, TeethS;
local LipsN, LipsC;
--local Type={};

-- indicator source
local source;

 

-- lines
local Jaw, Teeth, Lips;
-- lines sources
local JawSrc, TeethSrc, LipsSrc;
local Price, Method, Period ,MA,ma;
local SignalCountUp, SignalCountDown;

-- process parameters and prepare for calculations
function Prepare()

    OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	 
	FontSize=instance.parameters.FontSize;
	
 
	for i= 1, 3, 1  do
	UpTrendColor[i]=instance.parameters:getColor("UpTrendColor"..i);
    DownTrendColor[i]=instance.parameters:getColor("DownTrendColor"..i);
	end
	
	UpTrendColor[4]=instance.parameters:getColor("UpTrendColor".. 0 );
    DownTrendColor[4]=instance.parameters:getColor("DownTrendColor" .. 0 );
	
    assert(core.indicators:findIndicator(instance.parameters.MTH) ~= nil, "Please download and install"  .. instance.parameters.MTH .. ".lua indicator");

    JawN = instance.parameters.JawN;
    JawS = instance.parameters.JawS;
    TeethN = instance.parameters.TeethN;
    TeethS = instance.parameters.TeethS;
    LipsN = instance.parameters.LipsN;
    LipsS = instance.parameters.LipsS;
	Price = instance.parameters.Price;
	Method = instance.parameters.Method;
	Period = instance.parameters.Period;
	 

    source = instance.source;
    JawSrc = core.indicators:create(instance.parameters.MTH, source.median, JawN, core.rgb(0, 0, 0));
    TeethSrc = core.indicators:create(instance.parameters.MTH, source.median, TeethN, core.rgb(0, 0, 0));
    LipsSrc = core.indicators:create(instance.parameters.MTH, source.median, LipsN, core.rgb(0, 0, 0));
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	ma = core.indicators:create(Method, source[Price], Period);

    local name = profile:id() .. "(" .. source:name() .. ", " .. JawN .. "(" .. JawS .. ")," .. TeethN .. "(" .. TeethS .. ")," .. LipsN .. "(" .. LipsS .. "), " .. instance.parameters.MTH .. ")";
    instance:name(name);
 
    Jaw= instance:addInternalStream( JawSrc.DATA:first() + JawS, JawS);
    Teeth= instance:addInternalStream(  TeethSrc.DATA:first() + TeethS, TeethS);
    Lips= instance:addInternalStream( LipsSrc.DATA:first() + LipsS, LipsS);
	MA= instance:addInternalStream(0, 0);
	SignalCountUp= instance:addInternalStream(0, 0);
    SignalCountDown= instance:addInternalStream(0, 0);
	
	--Type= instance:addInternalStream(0, 0);
	
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
           context:createFont (1, "Wingdings", FontSize, FontSize, 0);
		    context:createFont (2, "Wingdings", FontSize*2, FontSize*2, 0);
			 context:createFont (3, "Wingdings", FontSize*3, FontSize*3, 0);
            init = true;
        end
		
		

		
		for period= math.max(context:firstBar (),source:first()), math.min( context:lastBar (), source:size()-1), 1 do
		
		
		 x, x1, x2= context:positionOfBar (period);
		 
		 for Level = 1 , Number ,  1 do
		    
		     
			 
			 
				 
						if SignalCountUp[period]>= 2 then
						visible, y = context:pointOfPrice (AlertLevel[Level][period]);
						
						  width, height = context:measureText (SignalCountUp[period],  "\225", 0);
						  context:drawText (SignalCountUp[period],   "\225", UpTrendColor[4], -1,  x-width/2 ,  y , x+width/2 , y+height, 0 );	
			   
						elseif  SignalCountDown[period] >= 2 then
						visible, y = context:pointOfPrice (AlertLevel[Level][period]);
						width, height = context:measureText (SignalCountDown[period],  "\226", 0);
						 context:drawText (SignalCountDown[period],   "\226", DownTrendColor[4], -1,  x-width/2  ,  y-height , x+width/2 ,y, 0 );	
						
						
						elseif Alert[Level][period] > 0  then
								visible, y = context:pointOfPrice (AlertLevel[Level][period]);
								
								  width, height = context:measureText (1,  "\225", 0);
								  context:drawText (1,   "\225", UpTrendColor[math.abs(Alert[Level][period])], -1,  x-width/2 ,  y , x+width/2 , y+height, 0 );	
					   
					  elseif  Alert[Level][period] < 0   then
								visible, y = context:pointOfPrice (AlertLevel[Level][period]);
								width, height = context:measureText (1,  "\226", 0);
								 context:drawText (1,   "\226", DownTrendColor[math.abs(Alert[Level][period])], -1,  x-width/2  ,  y-height , x+width/2 ,y, 0 );	
														
						
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


function Update(period, mode)
    JawSrc:update(mode);
    TeethSrc:update(mode);
    LipsSrc:update(mode);
	ma:update(mode);

    if (period + JawS >= 0 and period >= JawSrc.DATA:first()) then
        Jaw[period + JawS] = JawSrc.DATA[period];
    end

    if (period + TeethS >= 0 and period >= TeethSrc.DATA:first()) then
        Teeth[period + TeethS] = TeethSrc.DATA[period];
    end

    if (period + LipsS >= 0 and period >= LipsSrc.DATA:first()) then
        Lips[period + LipsS] = LipsSrc.DATA[period];
    end
	
	if ( period >= ma.DATA:first()) then
        MA[period ] = ma.DATA[period];
   end

   
    if Live~= "Live" then
	period=period-1;
	AlertShift=1;
	else
	AlertShift=0;
	end
	
	
	SignalCountUp[period]=0;
	SignalCountDown[period]=0;
	
    Activate (1, period);
	Activate (2, period);
	Activate (3, period );
 
end


function Activate (id, period)


   Alert[id][period]=0;
   
   
 
  
	  if id == 1  and ON[id]    then
	  
	       
			if  MA[period] > Jaw[period] 
			and   MA[period-1] <= Jaw[period-1] 
			then
			SignalCountUp[period]=  SignalCountUp[period]+1;        
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= source.low[period] 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-AlertShift 
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
							  
			elseif  MA[period] < Jaw[period] 
			and   MA[period-1] >= Jaw[period-1] 
            then			
			SignalCountDown[period]=  SignalCountDown[period]+1;    
			            			 
			                Alert[id][period]= -1;	
							AlertLevel[id][period]= source.high[period] 
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-AlertShift 
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
	 
	 
	 	  if id == 2  and ON[id]      then
	  
	       
			if  MA[period] > Teeth[period] 
			and   MA[period-1] <= Teeth[period-1] 
			then
			SignalCountUp[period]=  SignalCountUp[period]+1;               
						    
         
                Alert[id][period]= 2;	
 				AlertLevel[id][period]= source.low[period] 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-AlertShift 
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
							  
			elseif  MA[period] < Teeth[period] 
			and   MA[period-1] >= Teeth[period-1] 
            then			
			SignalCountDown[period]=  SignalCountDown[period]+1;    
			            			 
			                Alert[id][period]= -2;	
							AlertLevel[id][period]= source.high[period]  
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-AlertShift 
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

	  	  if id == 3  and ON[id]     then
	  
	       
			if  MA[period] > Lips[period] 
			and   MA[period-1] <= Lips[period-1] 
			then
			SignalCountUp[period]=  SignalCountUp[period]+1;               
						    
         
                Alert[id][period]= 3;	
 				AlertLevel[id][period]= source.low[period] 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-AlertShift 
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
							  
			elseif  MA[period] < Lips[period] 
			and   MA[period-1] >= Lips[period-1] 
            then			
			SignalCountDown[period]=  SignalCountDown[period]+1;    
			            			 
			                Alert[id][period]= -3;	
							AlertLevel[id][period]= source.high[period] 
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-AlertShift 
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


