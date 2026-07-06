
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65461&p=116519#p116519

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
function Init()
    indicator:name("Trend Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
 
 

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SlowLength", "Slow Length","", 7);	
	indicator.parameters:addInteger("SlowPipDisplace", "Slow Pip Displace","", 0);
	
	 indicator.parameters:addInteger("FastLength", "Fast Length","", 3);	
	indicator.parameters:addInteger("FastPipDisplace", "Slow Pip Displace","", 0);
	
	indicator.parameters:addBoolean("ShowCandles", "Show Candles", "", true);
	indicator.parameters:addBoolean("ShowCross", "Show Cross", "", true);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "1. Line Color","", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width1","Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addColor("color2", "2. Line Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width2","Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addGroup("Candle Style");
	indicator.parameters:addColor("Down_Color", "Up Trend Color","Up Trend Color", core.rgb(0,255,0));
	indicator.parameters:addColor("Up_Color", "Down Trend Color","Down Trend Color", core.rgb(255,0,0));
	indicator.parameters:addColor("Neutral_Color", "Neutral Trend Color","Neutral Trend Color", core.rgb(128,128,128));
	indicator.parameters:addInteger("Size", "Font Size","",10);
	
	
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
	
	 
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, "Cross");	
    Parameters (2, "Trend");
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

local 	Number = 2;
local Up={};
local Down={};
local Label={};
local ON={};
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
local OnlyOnceFlag;
local ShowAlert;
local Alert={}; 
local AlertLevel={};
local ToTime;
local Shift=0; 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
 

local first;
local source = nil;
local  SlowLength, SlowPipDisplace,FastLength,FastPipDisplace;
local ShowCandles;

-- Streams block
local Line1, Line2 = nil;
local Trend;

local open=nil;
local close=nil;
local high=nil;
local low=nil;
local Up_Color, Down_Color , Neutral_Color;
local Cross,ShowCross;

local Size, cross_up, cross_down;
-- Routine
function Prepare(nameOnly) 


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
	
	
     
   
    SlowLength= instance.parameters.SlowLength;
	SlowPipDisplace= instance.parameters.SlowPipDisplace;
	FastLength= instance.parameters.FastLength;
	FastPipDisplace= instance.parameters.FastPipDisplace;
	ShowCandles= instance.parameters.ShowCandles;
	Size= instance.parameters.Size;
	ShowCross= instance.parameters.ShowCross;
	
	Up_Color = instance.parameters.Up_Color;
	Down_Color = instance.parameters.Down_Color;
	Neutral_Color = instance.parameters.Neutral_Color; 
	
    source = instance.source;
    first = source:first()+math.max(SlowLength, FastLength);

    local name = profile:id() .. "(" .. source:name() .. ", " .. SlowLength .. ", " .. FastLength.. ")";
    instance:name(name); 
	
	if   (nameOnly) then
        return;
    end
	
	Trend = instance:addInternalStream(0, 0);
	Cross= instance:addInternalStream(0, 0);
	
	
    Line1 = instance:addStream("Line1", core.Line, name, "Line1", instance.parameters.color1, first);
    Line1:setWidth(instance.parameters.width1);
    Line1:setStyle(instance.parameters.style1);
	
	
	Line2 = instance:addStream("Line2", core.Line, name, "Line2", instance.parameters.color2, first);
    Line2:setWidth(instance.parameters.width2);
    Line2:setStyle(instance.parameters.style2);
	
	if ShowCandles then
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
	end
	
	if ShowCross then
	cross_up = instance:createTextOutput ("Cross_Up", "Cross Up", "Wingdings",  Size, core.H_Center, core.V_Center, Down_Color, 0);
	cross_down = instance:createTextOutput ("Cross_Down", "Cross DOwn", "Wingdings",  Size, core.H_Center, core.V_Center, Up_Color, 0);
    end
	
 
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
 
function Update(period)
    if period < first then
	return;
	end
	
	if ShowCandles then
	high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];
	end
	
	 local  pipMultiplier = source:pipSize()*math.pow(10,source:getPrecision()%2);
	 
	 local L1, H1= mathex.minmax(source, period -SlowLength +1 ,period); 
	 local L2, H2= mathex.minmax(source, period -FastLength +1 ,period); 
 
         local High1 = H1+ SlowPipDisplace*pipMultiplier;
         local Low1  = L1 - SlowPipDisplace*pipMultiplier;
         local High2 = H2 + FastPipDisplace*pipMultiplier;
         local Low2  = L2 - FastPipDisplace*pipMultiplier;
		 
            if   source.close[period]>Line1[period-1]  then
            Line1[period] = Low1;
            else 
			Line1[period] = High1; 
            end            
            if   source.close[period]>Line2[period-1]  then
            Line2[period] = Low2;
            else  
			Line2[period] = High2;   
	        end
			
			Cross[period]=Cross[period-1];
			Trend[period] =  0;
		
		       if (source.close[period]<Line1[period] and source.close[period]<Line2[period]) then
			   Trend[period] =  1;
			   end
               if (source.close[period]>Line1[period] and source.close[period]>Line2[period])  then
			   Trend[period] = -1; 
			   end
			   
			   
			   if ShowCandles then
               if (Trend[period]== 1) then 
			   open:setColor(period, Up_Color);
               elseif (Trend[period]==-1)  then 
			   open:setColor(period, Down_Color);
			   else 
			   open:setColor(period, Neutral_Color);
			   end
			   end
			   
			   
			       Cross[period]= Cross[period-1];
				   
				   
				  if (Line1[period]>Line2[period] or Trend[period] ==  1)  then   Cross[period] =  1;  end
                 if (Line1[period]<Line2[period] or Trend[period] == -1)  then  Cross[period] = -1;  end
				  
				  
				
				if ShowCross and Cross[period] ~=Cross[period-1] then
						
						
						max=math.max(Line1[period], Line2[period]);
						min=math.min(Line1[period], Line2[period]);
						
						if Cross[period] == 1 then
						cross_down:set(period, max, "\108", max);		
                        cross_up:setNoData(period  );						
						elseif Cross[period] == -1 then
						cross_up:set(period, min, "\108", min); 
						cross_down:setNoData(period  );
						else
						cross_up:setNoData(period  );
						cross_down:setNoData(period  );
						end
				
				end
			

    if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
	
	 
    Activate (1, period);
	Activate (2, period);
 			
	 
end



function Activate (id, period)

 
  
	  if id == 1  and ON[id]  then
	  
	       
			if  Cross[period]==-1
			and  Cross[period]~= Cross[period-1]
			then
			           
						    
         
                
			
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
							  
			elseif  Cross[period]==1
			and  Cross[period]~= Cross[period-1]
            then			
			
			 
						   
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
	  
	       
			if  Trend[period]==-1
			and  Trend[period]~= Trend[period-1]
			then
			           
						    
         
                
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Up Trend ");
							  SendAlert( Label[id]," Up Trend "); 
							  Pop(Label[id], " Up Trend ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif  Trend[period]==1
			and  Trend[period]~= Trend[period-1]
            then			
			
			 
						   
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

 
 
 
 