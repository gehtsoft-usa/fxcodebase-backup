-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66107

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Trend Confirmation");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    local Period={5,10,20,50,100,200};
    for i= 1, 6,1 do
    Add(i, Period[i]);
	end
	
	
	indicator.parameters:addString("Y", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Left");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 
    indicator.parameters:addInteger("ShiftY", "Shift","" , 0);
 
	
	indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("LabelColor", "Label Color", "", core.rgb(0, 0, 0)); 
   indicator.parameters:addInteger("Size", "Font Size", "", 20);
 --   indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	
	
	indicator.parameters:addGroup("Alert Parameters");  
	
	  
    indicator.parameters:addBoolean("On"  , "Use  Alert" , "", true);
	
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
	
	 indicator.parameters:addString("Label" , "Label", "", "Trend Confirmation");

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);

	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
 
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	
    indicator.parameters:addFile("Up" ,  "  Up Trend Sound", "", "");
    indicator.parameters:setFlag("Up" , core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down" , "Down Trend Sound", "", "");
    indicator.parameters:setFlag("Down" , core.FLAG_SOUND);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL); 
   

end

function Add(id, Period)


	indicator.parameters:addGroup(id.. ". MA Calculation");
	
	indicator.parameters:addString("Price"..id, "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price"..id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price"..id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price"..id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price"..id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price"..id, "WEIGHTED", "", "weighted");	
	
	indicator.parameters:addInteger("Period"..id, "Period", "", Period);

	indicator.parameters:addString("Method"..id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method"..id, "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method"..id, "WMA", "WMA" , "WMA");
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

 
local LastSignal;
local PlaySound;
local Email;
local SendEmail; 
local Sound;
local  RecurrentSound ,SoundFile  ;
local Show;
local ToTime;
local OnlyOnceFlag=true;
local FIRST=true;
local Label, Up, Down, On;

local first;
local source = nil;
local X,Y;
local font;
local LabelColor;
local Size;
local ShiftY;
local Signal={0,0,0,0,0,0};
local S,B;
local MA={};

-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
 
   LastSignal=nil;
	
	
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
	
	
 
	 
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;  
	
	Initialization();
 
	
	 
	  
	Signal={0,0,0,0,0,0};
    S=0;
	B=0;

    Y=instance.parameters.Y;
	X=instance.parameters.X;  
	ShiftY=instance.parameters.ShiftY;
    LabelColor=instance.parameters.LabelColor;
	Size=instance.parameters.Size;   
    source = instance.source;
    first=source:first();
   
   
    for i= 1, 6, 1 do
	MA[i]=  core.indicators:create(instance.parameters:getString ("Method"..i), source[instance.parameters:getString ("Price"..i)], instance.parameters:getInteger ("Period"..i));
	 first=math.max(first, MA[i].DATA:first());
	end
	
    
 
    core.host:execute ("setTimer", 1, 1);
    instance:ownerDrawn(true);
	 
	 
	 
end

function  Initialization ()
    
	 SendEmail = instance.parameters.SendEmail; 
 
	  Label =instance.parameters.Label;
	  On=instance.parameters.On; 

    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
	
    assert(not (SendEmail and (Email == "" or Email == nil )), "E-mail address must be specified");
	
	
	 PlaySound = instance.parameters.PlaySound;
    if PlaySound then 
	  Up =instance.parameters.Up;
	  Down =instance.parameters.Down; 
    else  
       Up =nil;
	  Down =nil; 
    end 
	  	 assert( not(PlaySound  and (Up  == "" or Up  == nil ) ), "Sound file must be chosen");
        assert (not (PlaySoundand  and (Down  == "" or Down  == nil)), "Sound file must be chosen"); 
    RecurrentSound = instance.parameters.RecurrentSound; 
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
 
function Update(period)   

  
end
 
local init = false;
 
function Draw(stage, context)
 
	  if stage~= 2 then
	  return;
	  end
	
        if not init then
           context:createFont (1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
	
			
	local Text1=  "XXXXXXXX";
	 width, height = context:measureText (1, Text1, 0);
 
   local X={1,2,3,1,2,3};	
   local Y={1,1,1,2,2,2};  
   
   
   
   for i = 1, 6, 1 do
   if Signal[i]==1 then
   LabelText="Buy";
   elseif Signal[i]==-1 then
   LabelText="Sell";
   else
   LabelText="Neutral";
   end
   context:drawText (1,  LabelText, LabelColor, -1,  iX(context,width,X[i],1) ,  iY(context,height,Y[i],0) ,iX(context,width,X[i],2),iY(context,height,Y[i],1), 0 );	
   end
  
   
     local x=1;	
   local y=3;   
   context:drawText (1,  "Buy :", LabelColor, -1,  iX(context,width,x,1) ,  iY(context,height,y,0) ,iX(context,width,x,2),iY(context,height,y,1), 0 );	
   
    local x=2;	
   local y=3;       
   context:drawText (1,  B, LabelColor, -1,  iX(context,width,x,1) ,  iY(context,height,y,0) ,iX(context,width,x,2),iY(context,height,y,1), 0 );	
   
   
      local x=1;	
   local y=4;   
   context:drawText (1,  "Sell :", LabelColor, -1,  iX(context,width,x,1) ,  iY(context,height,y,0) ,iX(context,width,x,2),iY(context,height,y,1), 0 );	
   
    local x=2;	
   local y=4;    
   context:drawText (1,  S, LabelColor, -1,  iX(context,width,x,1) ,  iY(context,height,y,0) ,iX(context,width,x,2),iY(context,height,y,1), 0 );	
   
   local x=1;	
   local y=5;   
   context:drawText (1,  "Summary :", LabelColor, -1,  iX(context,width,x,1) ,  iY(context,height,y,0) ,iX(context,width,x,2),iY(context,height,y,1), 0 );	
   
    local x=2;	
   local y=5;    
   if B> S then
   LabelText="Buy";
   elseif B< S then
   LabelText="Sell";
   else
   LabelText="Neutral";
   end
   
   context:drawText (1,  LabelText , LabelColor, -1,  iX(context,width,x,1) ,  iY(context,height,y,0) ,iX(context,width,x,2),iY(context,height,y,1), 0 );	
   
   
end		
 
 
-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


    	if cookie == 1 then	
		
		B=0;
		S=0;
		            
					 if Live~= "Live" then 
					 Shift=1;
					 else
					 Shift=0;
					 end
			 
					
					for i = 1, 6, 1 do
					MA[i]:update(core.UpdateLast); 
					
					
					   if MA[i].DATA:hasData(MA[i].DATA:size()-1-Shift) then
								if source.close[source:size()-1-Shift]> MA[i].DATA[MA[i].DATA:size()-1-Shift] then
								Signal[i]=1;
								B=B+1;
								elseif source.close[source:size()-1-Shift]< MA[i].DATA[MA[i].DATA:size()-1-Shift] then
								Signal[i]=-1;
								S=S+1;
								else
								Signal[i]=0;
								end
						end
						
					end
					
			 
			
			
			         if On then
					 
					         if LastSignal== nil then
							       
								     if B > S
									 then		
									 LastSignal= 1;	
									 elseif  B < S
									 then							
									 LastSignal= -1;	
									 end	

                             else			
                                     if B == 6 
									 and LastSignal~= 2 
									 then		
									 LastSignal= 2;			 
									 SoundAlert(Up);			 
									 EmailAlert( Label , "Strong Up Trend ");								 
									 Pop(Label, "Strong Up Trend ", period );  	
									 SendAlert( Label,"Strong Up Trend "); 
									 elseif S== 6
									 and LastSignal~= -2 
									 then		
									 LastSignal= -2;			 
									 SoundAlert(Down);			 
									 EmailAlert( Label , "Strong Down Trend ");								 
									 Pop(Label, "Strong Down Trend ", period );  	
									 SendAlert( Label,"Strong Down Trend "); 	 
									 elseif B > S
									 and LastSignal~= 1		
									 and B~= 6
									 then		
									 LastSignal= 1;			 
									 SoundAlert(Up);			 
									 EmailAlert( Label , "Up Trend ");								 
									 Pop(Label, "Up Trend ", period );  	
									 SendAlert( Label,"Up Trend "); 
									 elseif  B < S
									 and LastSignal~= -1 
									 and S~= 6
									 then							
									 LastSignal= -1;			 
									 SoundAlert(Down);			 
									 EmailAlert( Label , "Down Trend ");								 
									 Pop(Label, "Down Trend ", period );  	
									 SendAlert( Label,"Down Trend "); 
									 end				
                             end							 
							 
			      end
			 
			
			
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
   local Note=  profile:id().. delim.. "Label : " ..label  .. delim .. "Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  "Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
   
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
   local Note=  profile:id().. delim.. "Label : " ..label  .. delim .. "Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  "Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
   
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
   local Note=  profile:id().. delim.. "Label : " ..label  .. delim .. "Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  "Date : " .. DATA.month.." / ".. DATA.day .."Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
 
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
 
    terminal:alertMessage(source:instrument(), source[NOW], text, now);
end


 

function iX(context, width,Shift,x)

	if X== "Left" then
	return  context:left()+ Shift*width +  width*(x-1) ;
	else
	return context:right() - width*Shift -  width*(1-(x-1));
	end
end



function iY(context, height,Index , Line)

	if Y== "Top" then
		return context:top()+Index*height +ShiftY*height + Line *height;
	else
		if Line== 1 then
		return context:bottom()-(Index+1)*height -ShiftY*height + height;
		else
		return context:bottom()-(Index+1)*height -ShiftY*height;
		end
	end
end
 