-- Id: 21765
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66410

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

--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local Number = 4;
local Symbol={"\225","\226"};
local Font={"Wingdings", "Wingdings"};
local Alert_Name={ "Alert" ,"Alert" ,"Alert" ,"Alert"};
local Signal_Name={"Up Trend", "Up Trend Exit","Down Trend", "Down Trend Exit"};
--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\




function Init()
    indicator:name("Three MA Trend Continuation");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
   
    
    indicator.parameters:addGroup("1. MA Calculation");		
	 
    indicator.parameters:addInteger("Period1", "Fast Period MA", "", 10, 2, 2000 );
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
    indicator.parameters:addStringAlternative("Method1", "DEMA", "DEMA" , "DEMA");
	indicator.parameters:addStringAlternative("Method1", "TEMA", "TEMA" , "TEMA");  
	indicator.parameters:addStringAlternative("Method1", "PAR_MA", "PAR_MA" , "PAR_MA");  

	
	
	indicator.parameters:addGroup("2. MA Calculation");			
	indicator.parameters:addInteger("Period2", "Slow Period MA", "", 15, 2, 2000);
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
    indicator.parameters:addStringAlternative("Method2", "DEMA", "DEMA" , "DEMA");
	indicator.parameters:addStringAlternative("Method2", "TEMA", "TEMA" , "TEMA");  
	indicator.parameters:addStringAlternative("Method2", "PAR_MA", "PAR_MA" , "PAR_MA");  
	
	indicator.parameters:addGroup("3. MA Calculation");			
	indicator.parameters:addInteger("Period3", "Slow Period MA", "", 50, 2, 2000);
	indicator.parameters:addString("Method3", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
    indicator.parameters:addStringAlternative("Method3", "DEMA", "DEMA" , "DEMA");
	indicator.parameters:addStringAlternative("Method3", "TEMA", "TEMA" , "TEMA");  
	indicator.parameters:addStringAlternative("Method3", "PAR_MA", "PAR_MA" , "PAR_MA"); 

		
	indicator.parameters:addGroup("Indicator Style");   
    indicator.parameters:addColor("color1", "1. MA color", "MA color", core.rgb(0,255,0));
	indicator.parameters:addInteger("width1", "MA Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style1", "MA Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "2. MA color", "MA color", core.rgb(255,0,0));
	indicator.parameters:addInteger("width2", "MA Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style2", "MA Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
 
    indicator.parameters:addColor("color3", "3. MA color", "MA color", core.rgb(0,0,255));
	indicator.parameters:addInteger("width3", "MA Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style3", "MA Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
 
	 
	 
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("UpTrendColorExit", "Exit of Up Trend Color", "", core.rgb(0, 255, 255));
	indicator.parameters:addColor("DownTrendColorExit", "Exit of Down Trend Color", "", core.rgb(255, 0, 255));
	
	indicator.parameters:addInteger("Size", "Label Size", "", 15, 1 , 100);
	
	indicator.parameters:addBoolean("Show_Lines", "Show Lines", "", true);
	
	    indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Signal_Execution", "Signal Execution", "", "End of Turn");
    indicator.parameters:addStringAlternative("Signal_Execution", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Signal_Execution", "Live", "", "Live");  
	
 
	indicator.parameters:addString("Alert_Execution", "Alert Execution", "", "Live");
    indicator.parameters:addStringAlternative("Alert_Execution", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Alert_Execution", "Live", "", "Live");  

   
   	indicator.parameters:addString("Alert_Triger", "Alert Triger", "", "Both");
    indicator.parameters:addStringAlternative("Alert_Triger", "Timer", "", "Timer");
	indicator.parameters:addStringAlternative("Alert_Triger", "Price", "", "Price");
    indicator.parameters:addStringAlternative("Alert_Triger", "Both", "", "Both");
	
    indicator.parameters:addInteger("Timer", "Execution Timer (in seconds)", "", 1, 0, 1000);
 
   
    
 
	 
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
--indicator.parameters:addBoolean("Show_Unconfirmed", "Show Unconfirmed Signals", "", false);
 
  
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, Alert_Name[1], Signal_Name[1], core.rgb(0, 255, 0));	
	Parameters (2, Alert_Name[2], Signal_Name[2], core.rgb(0, 0, 255));	
    Parameters (3, Alert_Name[3], Signal_Name[3], core.rgb(255, 0, 0));	
	Parameters (4, Alert_Name[4], Signal_Name[4], core.rgb(0, 0, 255));	
	 
	
end



function Parameters ( id, Label1,Label2,internal_color )
  
  
   indicator.parameters:addGroup(Label1 .. " Alert");
  
    indicator.parameters:addBoolean("Alert_ON"..id , "Show " .. Label2 .." Alert" , "", true);
    indicator.parameters:addBoolean("Signal_ON"..id , "Show " .. Label2 .." Signal" , "", true); 
	

    indicator.parameters:addFile("Sound"..id, Label2 .. " Sound", "", "");
    indicator.parameters:setFlag("Sound"..id, core.FLAG_SOUND);

    indicator.parameters:addString("Alert_Label1"..id, "Alert Label", "", Label1);
	 indicator.parameters:addString("Alert_Label2"..id, "Alert Signal", "", Label2);
	 
	 
	-- indicator.parameters:addColor("Color"..id, "Label Color", "",internal_color); 
--	indicator.parameters:addInteger("Size"..id, "Label Size", "", 10, 1 , 100);

end 


local Sound={};
local Label1={};
local Label2={};
local Signal_ON={}; 
local Alert_ON={}; 
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local Show;
 
local PlaySound;
--local Live;
--local FIRST=true;
local OnlyOnce;
local ItIs={};
local Color={};
local Size={};
local OnlyOnceFlag;
local ShowAlert;
local Alert={}; 
local AlertLevel={};
local ToTime;
local Shift=0; 
local Timer;
--local Show_Unconfirmed;
local Signal_Execution, Alert_Execution,Alert_Triger;
local Alignment={};
--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
 
local first;
local source = nil;
local Size;
local Indicator1,Indicator2,Indicator3;
local Method1, Period1;
local Method2, Period2;
local Method3, Period3;
local MA1,MA2,MA3;
local AlertData;
local UpTrendColor, DownTrendColor, UpTrendColorExit, DownTrendColorExit;


-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	 	Alert_Triger= instance.parameters.Alert_Triger;
		
		
	if Alert_Triger ~= "Timer" then
    core.host:execute("subscribeTradeEvents", 1, "offers");
    end
	

	
	Timer= instance.parameters.Timer 
	Initialization();	
	instance:ownerDrawn(true);	
	
	if Alert_Triger ~= "Price" then
    core.host:execute ("setTimer", 3 , Timer);
	end
 
 
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	UpTrendColorExit= instance.parameters.UpTrendColorExit;
	DownTrendColorExit= instance.parameters.DownTrendColorExit;
	Size=instance.parameters.Size;
	

	
	 
	Method1 = instance.parameters.Method1;	
	Method2 = instance.parameters.Method2;
    Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;	
   
	Method3 = instance.parameters.Method3;
    Period3 = instance.parameters.Period3;
	
	Show_Lines= instance.parameters.Show_Lines;

	assert(core.indicators:findIndicator( Method1 ) ~= nil, "Please, download and install ".. Method1 .. ".LUA indicator");
	assert(core.indicators:findIndicator( Method2 ) ~= nil, "Please, download and install ".. Method2 .. ".LUA indicator");
	assert(core.indicators:findIndicator( Method3 ) ~= nil, "Please, download and install ".. Method3 .. ".LUA indicator");
     
	source = instance.source; 

 
	 -- Create short and long EMAs for the source
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    Indicator1 = core.indicators:create(Method1, source , Period1);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
	Indicator2 = core.indicators:create(Method2, source , Period2);
    assert(core.indicators:findIndicator(Method3) ~= nil, Method3 .. " indicator must be installed");
	Indicator3 = core.indicators:create(Method3, source , Period3);
	
	first=math.max(Indicator1.DATA:first(),Indicator2.DATA:first(),Indicator3.DATA:first() );

	
	if Show_Lines then 
    MA1=instance:addStream("MA1",core.Line, name .. ".MA1", "MA1", instance.parameters.color1,  Indicator1.DATA:first());
	MA1:setWidth(instance.parameters.width1);
    MA1:setStyle(instance.parameters.style1);
	
	 MA2=instance:addStream("MA2",core.Line, name .. ".MA2", "MA2", instance.parameters.color2,  Indicator2.DATA:first());
	MA2:setWidth(instance.parameters.width2);
    MA2:setStyle(instance.parameters.style2);
	
	 MA3=instance:addStream("MA3",core.Line, name .. ".MA3", "MA3", instance.parameters.color3,  Indicator3.DATA:first());
	MA3:setWidth(instance.parameters.width3);
    MA3:setStyle(instance.parameters.style3);
	
	else
	
	MA1=instance:addInternalStream(0, 0);
	MA2=instance:addInternalStream(0, 0);
	MA3=instance:addInternalStream(0, 0);
	
	end
  
		AlertData=instance:addInternalStream(0, 0);
		 
     
	 instance:ownerDrawn(true);
	
end

function ReleaseInstance()
core.host:execute ("killTimer", 3 );
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
		 
		 
		   if AlertData:hasData(period) then
		     
		    if AlertData[period] > 0 and AlertData[period]~=AlertData[period-1]  then			
			visible, y = context:pointOfPrice (MA3[period]);
			
			if AlertData[period]== 2 then
			Color=UpTrendColor;
			Symbol="\252";
			else
			Color=UpTrendColorExit;
			Symbol="\251";
			end
			
			  width, height = context:measureText (1,  Symbol, 0);
              context:drawText (1,   Symbol, Color, -1,  x-width/2 ,  y , x+width/2 , y+height, 0 );	
   
			elseif AlertData[period] < 0 and AlertData[period]~=AlertData[period-1] then
			visible, y = context:pointOfPrice (MA3[period]);
			
			if AlertData[period]== -2 then
			Color=DownTrendColor;
			Symbol="\252";
			else
			Color=DownTrendColorExit;
			Symbol="\251";
			end
			
			
			width, height = context:measureText (1,  Symbol, 0);
			 context:drawText (1,   Symbol, Color, -1,  x-width/2  ,  y-height, x+width/2 ,y, 0 );	
		    end
		 
		    
		 
		end
		end
		
  
end		


 


 
 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 



     Indicator1:update(mode);
	 Indicator2:update(mode);
	 Indicator3:update(mode);
 
	
	
     if period > Indicator1.DATA:first() then
	 MA1[period]=  Indicator1.DATA[period];
	 end
	 
	 if period > Indicator2.DATA:first() then
	 MA2[period]=  Indicator2.DATA[period];
	 end
	 
	 if period > Indicator3.DATA:first() then
	 MA3[period]=  Indicator3.DATA[period];
	 end
	 
	 
	 
	 if period < first then
	 return;
	 end
	 
     Resolve(period);
	 
	 
	 if Signal_Execution~= "Live" then
	period=period-1;	 
	end
	

    for id=1, Number, 1 do
    Signal_Logic (id, period);
	end
 
end


function  Resolve(period)


if source[period]> MA1[period]
and source[period]> MA2[period]
and source[period]> MA3[period]
then
AlertData[period]=2;
elseif source[period]< MA1[period]
and source[period]< MA2[period]
and source[period]< MA3[period]
then
AlertData[period]=-2;
elseif source[period]< MA1[period]
and source[period]< MA2[period]
and source[period]> MA3[period]
then
AlertData[period]=1;
elseif source[period]> MA1[period]
and source[period]> MA2[period]
and source[period]< MA3[period]
then
AlertData[period]=-1;
else
AlertData[period]=AlertData[period-1];
end

end



--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

function  Initialization ()


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
	
	Signal_Execution = instance.parameters.Signal_Execution;
	Alert_Execution = instance.parameters.Alert_Execution;

	 
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	--Live = instance.parameters.Live;
	Show_Unconfirmed= instance.parameters.Show_Unconfirmed;

     for i= 1, Number , 1 do
		Alert[i]=instance:addInternalStream(0, 0);
	--	AlertLevel[i]=instance:addInternalStream(0, 0);
	--	Alignment[i]= instance:addInternalStream(0, 0);
     end
	 
	 
    
	 SendEmail = instance.parameters.SendEmail;
	 
	 local i;
	 for i = 1, Number , 1 do 
	  Label1[i]=instance.parameters:getString("Alert_Label1" .. i);
	  Label2[i]=instance.parameters:getString("Alert_Label2" .. i);
	  Signal_ON[i]=instance.parameters:getBoolean("Signal_ON" .. i);
	  Alert_ON[i]=instance.parameters:getBoolean("Alert_ON" .. i);
	 end
	 
	 
	 

    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
	
    assert(not (SendEmail and (Email == "" or Email == nil )), "E-mail address must be specified");
	
	
	--for i = 1, Number , 1 do 
	--  Color[i]=instance.parameters:getColor("Color" .. i);
	---  Size[i]=instance.parameters:getInteger("Size" .. i);
--	end  
	
	 PlaySound = instance.parameters.PlaySound;
    if PlaySound then
    
	  for i = 1, Number , 1 do 
	  Sound[i]=instance.parameters:getString("Sound" .. i);
	 
	  end
	
    else 
	
	  for i = 1, Number , 1 do 
       Sound[i]=nil; 
	  end
		
    end
    
        for i = 1, Number , 1 do 
	  	 assert( not(PlaySound  and (Sound[i] == "" or Sound[i] == nil ) ), "Sound file must be chosen");
    
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	ItIs[i] = nil; 
	end
		 
end	


--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\


function Signal_Logic (id, period)


       
	  --  if not Show_Unconfirmed then
	   -- Alert[id][period]= 0;	
		--end
  
	
	  
	    if id== 1  then   
			if  AlertData[period] ==2 
			and AlertData[period-1] ~=2 
			then
			           
						    
         
                Alert[id][period]= 1;	
 			--	AlertLevel[id][period]= Slow[period] 
			--	Alignment[id][period]= -1;		   
					
						   							  
			else 		
			 
						   
		  
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
		
		if id== 2   then  
			if  AlertData[period] ==1 
			and AlertData[period-1] ~=1 
			then
			           
						    
         
                Alert[id][period]= 2;	
 			--	AlertLevel[id][period]= Slow[period] 
				--Alignment[id][period]= -1;		   
			
						   
							  							  
			else 
			 
		 
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
		
		 if id== 3  then   
			if  AlertData[period] ==-2 
			and AlertData[period-1] ~=-2 
			then
			           
						    
         
                Alert[id][period]= 3;	
 			--	AlertLevel[id][period]= Slow[period] 
			--	Alignment[id][period]= 1;		   
					
						   							  
			else 		
			 
						   
		  
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
		
		if id== 4  then  
			if  AlertData[period] ==-1 
			and AlertData[period-1] ~=-1 
			then
			           
						    
         
                Alert[id][period]= 4;	
 				--AlertLevel[id][period]= Slow[period] 
			--	Alignment[id][period]= 1;		   
			
						   
							  							  
			else 
			 
		 
		     Alert[id][period]= 0;
			                
	         end
			
	    end
		
		
		


end

--//////////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\





function AsyncOperationFinished (cookie, success, message)

    if cookie~=1
	and cookie~= 3 
	then
	return;
	end
	
 
	
    local Last_Period=source:size()-1;
	
	
	if Signal_Execution~= "Live" then
	Last_Period=Last_Period-1;	 
	end
	
    if Alert_Execution~= "Live" then
	Last_Period=Last_Period-1;	 
	end
	
	
     if Last_Period < first 
	 then
	 return;
	 end
	
	
	for i=1, Number, 1 do
    Alert_Logic (i, Last_Period);
    end
	
	
	

end




 

function Alert_Logic (id, period)



   
   
  
  
	if not  Alert_ON[id]  then
	return;
	end
	
	  
	    if   Alert[id][period]== id  then   
		 
			           
  	   
							  if ItIs[id]~=source:serial(period)  
							  --and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  ItIs[id]=source:serial(period);
							  SoundAlert(Sound[id]);
							  EmailAlert( Label1[id], Label2[id]);
							  SendAlert( Label1[id],Label2[id],period); 
							  Pop(Label1[id], Label2[id], period );  
							  OnlyOnceFlag=false;
							  end 
		else
		
							   ItIs[id]=nil;
			 
			
	    end
		
 
	  
		   
       -- if FIRST then
        --FIRST=false;      
       -- end		

end

 

function SoundAlert(internal_sound)
 if not PlaySound then
 return;
 end

  terminal:alertSound(internal_sound, RecurrentSound);
end

 


function EmailAlert( label1,label2 )

if not SendEmail then
return
end
 
   local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label1  .. delim .. "Alert : " .. label2 ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  "Date : " .. DATA.month.." / ".. DATA.day .."Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
   
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
	
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 
	 
	 
	 
function Pop(label1,label2 , period)
 
 
 if not Show then
   return;
   end
 
   local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
   
   local delim = "\013\010";   
	
   local Symbol= "Instrument : " .. source:instrument() ;
   local TF= "Time Frame : " .. source:barSize();   
    local Time =  "Date : " .. DATA.month.." / ".. DATA.day .. delim .. "Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
    local Text= Symbol .. delim ..  TF .. delim ..  Time.. delim ..  label1 .. ":" ..    label2     
   core.host:execute ("prompt", 1, profile:id(),  Text );


end

function SoundAlert(sound_file)
 if not PlaySound then
 return;
 end
 
 terminal:alertSound(sound_file, RecurrentSound);
end

function EmailAlert(label1,label2, period)

if not SendEmail then
return
end

   local delim = "\013\010";   

     local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
	
   local Symbol= "Instrument : " .. source:instrument() ;
   local TF= "Time Frame : " .. source:barSize();   
    local Time =  "Date : " .. DATA.month.." / ".. DATA.day .. delim .. "Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
   
    local Text= Symbol .. delim ..  TF .. delim ..  Time.. delim ..  label1 .. ":" ..    label2  
	
 
 terminal:alertEmail(Email, profile:id(), Text);
end
	 


function SendAlert(label1,label2, period)
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
  
    local Text= Symbol .. delim ..  TF .. delim ..  Time.. delim ..  label1 .. ":" ..    label2  
	
 
    terminal:alertMessage(source:instrument(), source[NOW], Text, source:date(NOW));
end


 

