-- Id: 17739
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64479

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

function Init()
    indicator:name("Cointegration Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	
	
	indicator.parameters:addGroup(  "Calculation");
	
	indicator.parameters:addInteger("Trailing", "Trailing Period", "" , 34);
	indicator.parameters:addDouble("Deviation", "Deviation", "" , 2);
	indicator.parameters:addInteger("Period", "MA Period", "" , 34);
	
	indicator.parameters:addString("Method", "Data Selector", "" , "Available");
    indicator.parameters:addStringAlternative("Method", "Available data", "" , "Available");
    indicator.parameters:addStringAlternative("Method", "Trailing", "" , "Trailing");
	indicator.parameters:addStringAlternative("Method", "Select by user", "" , "User");
	
	
    Add(1, "EUR/SUD");
	Add(2, "EUR/SUD");
	Add(3, "EUR/SUD");
    Add(4, "EUR/SUD");
	Add(5, "EUR/SUD");
	Add(6, "EUR/SUD");
	Add(7, "EUR/SUD");
	Add(8, "EUR/SUD");
	Add(9, "EUR/SUD");
	Add(10, "EUR/SUD");
	
	
	indicator.parameters:addGroup(  "Line Style");
	
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style" , "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width1", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1" , "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);
	
	
	indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width2", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2" , "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addColor("color3", "MA Line Color", "", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("width3", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3" , "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);
	
	
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
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, "Top Line");	
	Parameters (2, "Central Line");	
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

 
function Add(id, Instrument)
   
     indicator.parameters:addGroup(  id.. ". Instrument");
    if id == 1 then
    indicator.parameters:addBoolean("On"..id, "Use this Instrument", "", true);
	else
	 indicator.parameters:addBoolean("On"..id, "Use this Instrument", "", false);
	end
	
   	indicator.parameters:addString("Instrument"..id, "Instrument", "", Instrument);
    indicator.parameters:setFlag("Instrument"..id, core.FLAG_INSTRUMENTS );
    indicator.parameters:addDouble("Weight"..id, "Weight", "", 100);

  
end 
 
 
local dayoffset,weekoffset;
local Weight={};
local Source ={};
local Instrument={};
local Method;
local Trailing;
local source = nil;
local loading={}; 
local p={};
local iNumber ; 
local Cointegration;
local Top,Bottom,MA;
local Deviation;
local Period;
local pattern = "([^;]*);([^;]*)";
local db;
local start={};
local PipCost={};
-- Routine
function Prepare(nameOnly)   
	  
    source = instance.source; 
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");	
	Method= instance.parameters.Method;
	Trailing= instance.parameters.Trailing;
	Deviation= instance.parameters.Deviation;
	Period= instance.parameters.Period;
	
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	Size=instance.parameters.Size;
	
 
	iNumber=0;

    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end	
	local i;
		for  i = 1, 10, 1 do
			 if instance.parameters:getBoolean ("On"..i) then
			 iNumber=iNumber+1;
			 Instrument[iNumber]= instance.parameters:getString("Instrument" .. i);
			 Weight[iNumber]= instance.parameters:getDouble("Weight" .. i);
			 Source[iNumber] = core.host:execute("getSyncHistory",Instrument[iNumber], source:barSize(), source:isBid(), 0, 200+i, 100+i);			
			loading[iNumber]=true;
			
			PipCost[iNumber] = core.host:findTable("offers"):find("Instrument", Instrument[iNumber]).PipCost;
		 
		  end
	end
	
	require("storagedb");
    db = storagedb.get_db(name);	
	db:put("Date", source:date(source:first()));  
	
	Cointegration = instance:addStream("Cointegration", core.Line, name, "Cointegration", instance.parameters.color, source:first());
    Cointegration:setPrecision(math.max(2, instance.source:getPrecision()));
	Cointegration:setWidth(instance.parameters.width);
    Cointegration:setStyle(instance.parameters.style);
	
	
	Top = instance:addStream("Top", core.Line, name, "Top", instance.parameters.color1, source:first());
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
	Top:setWidth(instance.parameters.width1);
    Top:setStyle(instance.parameters.style1);
	
	Bottom = instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.color2, source:first());
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
	Bottom:setWidth(instance.parameters.width2);
    Bottom:setStyle(instance.parameters.style2);
	
	MA = instance:addStream("MA", core.Line, name, "MA", instance.parameters.color3, source:first());
    MA:setPrecision(math.max(2, instance.source:getPrecision()));
	MA:setWidth(instance.parameters.width3);
    MA:setStyle(instance.parameters.style3);
	
	core.host:execute("addCommand", 1,  profile:id() .. " Select Start Time");
	
	
	   for i= 1, Number , 1 do
		Alert[i]=instance:addInternalStream(0, 0);
		AlertLevel[i]=instance:addInternalStream(0, 0);
     end
	
	iInitialization();	
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


function  iInitialization ()
    
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

    local Start=1;
    core.host:execute ("removeAll");
	
    local Flag = false;
  
	for i= 1, iNumber, 1 do
	
		
			p[i]= Initialization(period,i)	
			
	
		if loading[i] or p[i]== false then		
		Flag=true;
		end
	end
	
	
		if Method =="User" then
					local Date= tonumber(db:get("Date", 0));  
					if Date==0 then
					return;
					end	
					Start= core.findDate (source, Date, false); 
					if Start==-1 then
					return;
					end
					
					for i= 1, iNumber, 1 do					
					start[i]= Initialization(Start,i);						
					end
					
		 end
		
	
	if Flag then
	return;
	end	
	
	Cointegration[period]=0;
	 
	for i= 1, iNumber, 1 do 
	
	    if Method == "Available" then
			if p[i] > Source[i].close:first() then
			Cointegration[period]=Cointegration[period] + (((( Source[i].close[p[i]]-Source[i].close[Source[i].close:first()])/Source[i]:pipSize())*PipCost[i])*Weight[i]);
			end 
		elseif Method == "Trailing" then		
		   if p[i] > Trailing then
			Cointegration[period]=Cointegration[period] + ((((Source[i].close[p[i]]-Source[i].close[p[i] - Trailing+1 ])/Source[i]:pipSize())*PipCost[i])*Weight[i]);
			end 			
		else
		
		    Cointegration[period]=Cointegration[period] + (((( Source[i].close[p[i]]-Source[i].close[start[i]])/Source[i]:pipSize())*PipCost[i])*Weight[i]);
		end
		
		
	end
	
	if period <Period then
    return;
	end
	
	MA[period]= mathex.avg(Cointegration, period-Period+1, period);	
	local Delta= mathex.stdev (Cointegration, period-Period+1, period);	
	Top[period]= MA[period]+Delta*Deviation;
	Bottom[period]= MA[period]-Delta*Deviation;
	
	 if  period== source:size()-1 and  Method =="User" then
	 local min,max=mathex.minmax(MA, source:first(), source:size()-1);
     core.host:execute ("drawLine", 1, source:date(Start), min, source:date(Start), max , core.COLOR_LABEL );
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
	  
	       
			if  Cointegration[period] > Top[period] 
			and   Cointegration[period-1] <= Top[period-1] 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= Top[period] 
						   
			
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
							  
			elseif  Cointegration[period] < Top[period] 
			and   Cointegration[period-1] >= Top[period-1] 
            then			
			
			            			 
			                Alert[id][period]= -1;	
							AlertLevel[id][period]= Top[period] 
						   
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
	  
	   if id == 2  and ON[id]  then
	  
	       
			if  Cointegration[period] > MA[period] 
			and   Cointegration[period-1] <= MA[period-1] 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= MA[period] 
						   
			
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
							  
			elseif  Cointegration[period] < MA[period] 
			and   Cointegration[period-1] >= MA[period-1] 
            then			
			
			            			 
			                Alert[id][period]= -1;	
							AlertLevel[id][period]= MA[period] 
						   
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
	  
	  
	   if id == 3  and ON[id]  then
	  
	       
			if  Cointegration[period] > Bottom[period] 
			and   Cointegration[period-1] <= Bottom[period-1] 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= Bottom[period] 
						   
			
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
							  
			elseif  Cointegration[period] < Bottom[period] 
			and   Cointegration[period-1] >= Bottom[period-1] 
            then			
			
			            			 
			                Alert[id][period]= -1;	
							AlertLevel[id][period]= Bottom[period] 
						   
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

 
 
 




function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);
  
    if loading[id] or Source[id]:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(Source [id], Candle, false);
	 

    -- candle is not found
    if P < 0    then
        return false;
	else return P;	
    end
			
end	




-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie, success, message)
     local j;	 
	local Flag = false;	
	local Count=0;	
	
	
	
    for j = 1, iNumber, 1 do
		
			  if cookie == (100+j) then
			  loading[j] = true;
		      elseif  cookie == (200+j) then
			  loading[j] = false; 	 
              end
			  
		if loading[j] then
		Count=Count+1;
		Flag=true;
		end	 
   end
   
   
   if cookie == 1 then 
	 
	local Level, Date = string.match(message, pattern, 0);
	
	 
	db:put("Date", tostring(Date));  
	
	end
	--Number
		  
		if Flag then
		core.host:execute ("setStatus", " Loading ".. (iNumber-Count) .."/" .. iNumber);
		else
		core.host:execute ("setStatus", " Loaded ".. (iNumber-Count) .."/" .. iNumber);
		instance:updateFrom(0);	
		end
			  
	    
   
        
		return core.ASYNC_REDRAW ;
end




 


