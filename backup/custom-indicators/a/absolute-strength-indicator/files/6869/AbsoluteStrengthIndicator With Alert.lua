-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2987
-- Id: 

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Absolute Strength Indicator");
    indicator:description("Absolute Strength Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	 indicator.parameters:addString("Method", "Method", "", "RSI");
    indicator.parameters:addStringAlternative("Method", "RSI", "", "RSI");
    indicator.parameters:addStringAlternative("Method", "Stoch", "", "Stoch");
    indicator.parameters:addStringAlternative("Method", "ADX", "", "ADX");
	
	indicator.parameters:addString("Method1", "Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");   
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
	
	
		indicator.parameters:addString("Type1", "CLOSE", "", "C");
    indicator.parameters:addStringAlternative("Type1", "OPEN", "", "O");
    indicator.parameters:addStringAlternative("Type1", "HIGH", "", "H");
    indicator.parameters:addStringAlternative("Type1", "LOW", "", "L");
    indicator.parameters:addStringAlternative("Type1","CLOSE", "", "C");
    indicator.parameters:addStringAlternative("Type1", "MEDIAN", "", "M");
    indicator.parameters:addStringAlternative("Type1", "TYPICAL", "", "T");
    indicator.parameters:addStringAlternative("Type1", "WEIGHTED", "", "W");
	
	
	 indicator.parameters:addInteger("Length", "Period for Evaluation", "", 10);
	 indicator.parameters:addInteger("Signal", "Period for Signal", "", 5);
	 indicator.parameters:addInteger("Smoothing", "Period for Smoothing", "", 5);
	 
	  indicator.parameters:addDouble("OverBought", "OverBought", "", 0);
	   indicator.parameters:addDouble("OverSold", "OverSold", "", 0);

	 indicator.parameters:addGroup("Selector");   
	 indicator.parameters:addBoolean("ShowBulls", "Show Bulls", "" , true);
	 indicator.parameters:addBoolean("ShowBears", "Show Bears", "" , true);
	
	 indicator.parameters:addGroup("Bulls Style");   
    indicator.parameters:addColor("Bulls_color", "Color of Bulls", "Color of Bulls", core.rgb(0, 255, 0));
		indicator.parameters:addInteger("Bullswidth", "Line Width", "", 1, 1, 5);
     indicator.parameters:addInteger("Bullsstyle", "Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("Bullsstyle", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("Bears Style");
    indicator.parameters:addColor("Bears_color", "Color of Bears", "Color of Bears", core.rgb(255, 0, 0));
		indicator.parameters:addInteger("Bearswidth", "Line Width", "", 1, 1, 5);
     indicator.parameters:addInteger("Bearsstyle", "Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("Bearsstyle", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("Bulls Signal Style");
    indicator.parameters:addColor("SignalBulls_color", "Color of SignalBulls", "Color of SignalBulls", core.rgb(0, 255, 128));
		indicator.parameters:addInteger("SignalBullswidth", "Line Width", "", 1, 1, 5);
     indicator.parameters:addInteger("SignalBullsstyle", "Line Style", "", core.LINE_DASH);
	indicator.parameters:setFlag("SignalBullsstyle", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("Bears Signal Style");
    indicator.parameters:addColor("SignalBears_color", "Color of SignalBears", "Color of SignalBears", core.rgb(255, 0, 128));	
	indicator.parameters:addInteger("SignalBearswidth", "Line Width", "", 1, 1, 5);
     indicator.parameters:addInteger("SignalBearsstyle", "Line Style", "", core.LINE_DASH);
	indicator.parameters:setFlag("SignalBearsstyle", core.FLAG_LINE_STYLE);	
	
	
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

	
	Parameters (1, "Bulls");	
	Parameters (2, "Bears");	
	Parameters (3, "Bears/Bears");	
	
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
local Method;
local Method1;

local first;
local source = nil;

 local BullsAVGofAVG;
 local BearsAVGofAVG; 
-- Streams block
local Bulls = nil;
local Bears = nil;
local SignalBulls = nil;
local SignalBears = nil;
local Length;
local BullsTemp, BearsTemp;
local MA;
local BullsAVG, BearsAVG;
local OverBought, OverSold;
local Smoothing, Signal;
local Type1,P1;

local AVGBull;
local AVGBear;
local ShowBulls, ShowBears;

-- Routine
function Prepare(nameOnly)
     ShowBulls= instance.parameters.ShowBulls;
	 ShowBears= instance.parameters.ShowBears;
    Smoothing = instance.parameters.Smoothing;
	Signal = instance.parameters.Signal;  
    Type1=instance.parameters.Type1;
    OverBought = instance.parameters.OverBought;
	OverSold = instance.parameters.OverSold;
    Length = instance.parameters.Length;
    Method = instance.parameters.Method;
	Method1= instance.parameters.Method1;
    source = instance.source;
   
	
	
	if Type1 == "O" then
        P1 = source.open;
    elseif Type1 == "H" then
        P1 = source.high;
    elseif Type1 == "L" then
        P1 = source.low;
    elseif Type1 == "M" then
        P1 = source.median;
    elseif Type1 == "T" then
        P1 = source.typical;
    elseif Type1 == "W" then
        P1 = source.weighted;
    else
        P1 = source.close;
    end
    local name = profile:id() .. "(" .. source:name() .. ", " .. Method .. ", ".. Method1.. "," .. Length.. ",".. Smoothing .."," .. Signal.. ")";
	instance:name(name);
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
	
	MA= core.indicators:create("MVA", P1, 2);
	
	first = MA.DATA:first();
	
	BullsTemp = instance:addInternalStream(0, 0);
	BearsTemp = instance:addInternalStream(0, 0); 
	
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
	BullsAVG= core.indicators:create(Method1,BullsTemp, Length);
	BearsAVG= core.indicators:create(Method1, BearsTemp, Length);
	
	AVGBull= core.indicators:create(Method1,BullsAVG.DATA, Smoothing);
	AVGBear= core.indicators:create(Method1, BearsAVG.DATA, Smoothing);
	
	 BullsAVGofAVG= core.indicators:create(Method1,AVGBull.DATA, Signal); 
  BearsAVGofAVG = core.indicators:create(Method1,AVGBear.DATA, Signal); 
	
	if ShowBulls then
    Bulls = instance:addStream("Bulls", core.Line, name .. ".Bulls", "Bulls", instance.parameters.Bulls_color, AVGBull.DATA:first());
    Bulls:setPrecision(math.max(2, instance.source:getPrecision()));
	Bulls:setWidth(instance.parameters.Bullswidth);
	Bulls:setStyle(instance.parameters.Bullsstyle);
	SignalBulls = instance:addStream("SignalBulls", core.Line, name .. ".SignalBulls", "SignalBulls", instance.parameters.SignalBulls_color,  BullsAVGofAVG.DATA:first());
    SignalBulls:setPrecision(math.max(2, instance.source:getPrecision()));
	SignalBulls:setWidth(instance.parameters.SignalBullswidth);
	SignalBulls:setStyle(instance.parameters.SignalBullsstyle);
	else
	Bulls= instance:addInternalStream(0, 0);
	SignalBulls= instance:addInternalStream(0, 0);
	end
	
	if ShowBears then 
    Bears = instance:addStream("Bears", core.Line, name .. ".Bears", "Bears", instance.parameters.Bears_color,  AVGBull.DATA:first());
    Bears:setPrecision(math.max(2, instance.source:getPrecision()));
	Bears:setWidth(instance.parameters.Bearswidth);
	Bears:setStyle(instance.parameters.Bearsstyle);   
    SignalBears = instance:addStream("SignalBears", core.Line, name .. ".SignalBears", "SignalBears", instance.parameters.SignalBears_color, BearsAVGofAVG.DATA:first());
    SignalBears:setPrecision(math.max(2, instance.source:getPrecision()));
	SignalBears:setWidth(instance.parameters.SignalBearswidth);
	SignalBears:setStyle(instance.parameters.SignalBearsstyle);
	else
	Bears= instance:addInternalStream(0, 0);
	SignalBears= instance:addInternalStream(0, 0);
	end
	
	
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
function Update(period,mode)
    if period < first or  not source:hasData(period) then
    return;
    end	
	
			MA:update(mode); 
			
 
					
			if Method == "RSI" then
	
				BullsTemp[period] = 0.5*(math.abs(MA.DATA[period]-MA.DATA[period-1])+(MA.DATA[period]-MA.DATA[period-1]));
				BearsTemp[period] = 0.5*(math.abs(MA.DATA[period]-MA.DATA[period-1])-(MA.DATA[period]-MA.DATA[period-1]));
			
			elseif  Method == "Stoch" then	
				local min,max;
				min, max = core.minmax(source, core.range(period -Length , period));
				BullsTemp[period] = MA.DATA[period]-min;
				BearsTemp[period] = max-MA.DATA[period];
				
				
			elseif  Method == "ADX" then			
			   BullsTemp[period] = 0.5*(math.abs(source.high[period]-source.high[period-1])+(source.high[period]-source.high[period-1]));
			   BearsTemp[period] = 0.5*(math.abs(source.low[period-1]-source.low[period])+(source.low[period-1]-source.low[period]));       
			   
			end
			   
			   
			  BullsAVG:update(mode); 
             BearsAVG:update(mode); 			 
			
			   
			   AVGBull:update(mode); 
               AVGBear:update(mode); 			 
			   
			   if period < AVGBull.DATA:first()  then
			   return;
			   end
			   
			    Bulls[period] =AVGBull.DATA[period];
			   Bears[period] =AVGBear.DATA[period]; 
			   
			   
				 if OverBought > 0 and OverSold > 0  then
				
				SignalBulls[period]=OverBought/100*( Bulls[period]+Bears[period]);
				SignalBears[period] =OverSold/100*( Bulls[period]+Bears[period]);
				
				else			
				
				  BullsAVGofAVG:update(mode); 
                  BearsAVGofAVG:update(mode); 
				  if  period < BearsAVGofAVG.DATA:first()  then
				  return;
				  end
				  
				SignalBulls[period]=BullsAVGofAVG.DATA[period];
				SignalBears[period]=BearsAVGofAVG.DATA[period];
			    end
				
				
	if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
	
	 
	
    Activate (1, period);
	Activate (2, period);	
    Activate (3, period);		
end



function Activate (id, period)


   Alert[id][period]=0;
   
   
  
  
	  if id == 1  and ON[id]  then
	  
	       
			if  Bulls[period] > SignalBulls[period] 
			and   Bulls[period-1] <= SignalBulls[period-1] 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= SignalBulls[period] 
						   
			
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
							  
			elseif  Bulls[period] < SignalBulls[period] 
			and   Bulls[period-1] >= SignalBulls[period-1] 
            then			
			
			            			 
			                Alert[id][period]= -1;	
							AlertLevel[id][period]= SignalBulls[period] 
						   
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
	  
	  
	  if id == 2  and ON[id]  then
	  
	       
			if  Bears[period] > SignalBears[period] 
			and   Bears[period-1] <= SignalBears[period-1] 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= SignalBears[period] 
						   
			
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
							  
			elseif  Bears[period] < SignalBears[period] 
			and   Bears[period-1] >= SignalBears[period-1] 
            then			
			
			            			 
			                Alert[id][period]= -1;	
							AlertLevel[id][period]= SignalBears[period] 
						   
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
	  
	  
	  if id == 3  and ON[id]  then
	  
	       
			if  Bulls[period] > Bears[period] 
			and   Bulls[period-1] <= Bears[period-1] 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= Bears[period] 
						   
			
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
							  
			elseif  Bulls[period] < Bears[period] 
			and   Bulls[period-1] >= Bears[period-1] 
            then			
			
			            			 
			                Alert[id][period]= -1;	
							AlertLevel[id][period]= Bears[period] 
						   
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