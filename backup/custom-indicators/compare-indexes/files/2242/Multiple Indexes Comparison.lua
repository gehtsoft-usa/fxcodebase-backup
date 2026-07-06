-- Id: 16854
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1170&p=2242#p2242

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
    indicator:name("Multiple Indexes Comparison");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");  
    indicator.parameters:addString("Instrument1", "1. Instrument", "", "EUR/USD");
    indicator.parameters:addString("Instrument2", "2. Instrument", "", "GBP/USD");
	indicator.parameters:addString("Instrument3", "3. Instrument", "", "AUD/USD");
    indicator.parameters:addString("Instrument4", "4. Instrument", "", "USD/JPY");
	indicator.parameters:addString("Instrument5", "5. Instrument", "", "USD/CHF");
	
	indicator.parameters:addString("Instrument6", "6. Instrument", "", "EUR/USD");
    indicator.parameters:addString("Instrument7", "7. Instrument", "", "GBP/USD");
	indicator.parameters:addString("Instrument8", "8. Instrument", "", "AUD/USD");
    indicator.parameters:addString("Instrument9", "9. Instrument", "", "USD/JPY");
	indicator.parameters:addString("Instrument10", "10. Instrument", "", "USD/CHF");
 
	
    indicator.parameters:addDouble("Coeff1", "1. Instrument Coefficient", "", -1);
    indicator.parameters:addDouble("Coeff2", "2. Instrument Coefficient", "", -1);
	indicator.parameters:addDouble("Coeff3", "3. Instrument Coefficient", "", -1);
    indicator.parameters:addDouble("Coeff4", "4. Instrument Coefficient", "", 1);
	indicator.parameters:addDouble("Coeff5", "5. Instrument Coefficient", "", 1);
	
	indicator.parameters:addDouble("Coeff6", "6. Instrument Coefficient", "", 0);
    indicator.parameters:addDouble("Coeff7", "7. Instrument Coefficient", "", 0);
	indicator.parameters:addDouble("Coeff8", "8. Instrument Coefficient", "", 0);
    indicator.parameters:addDouble("Coeff9", "9. Instrument Coefficient", "", 0);
	indicator.parameters:addDouble("Coeff10", "10. Instrument Coefficient", "", 0);
 
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("color", "Line color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("OB", "Overbought Level","", 100);
    indicator.parameters:addDouble("OS","Oversold Level","", 100);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

   
		
    indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
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
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, "OB Cross");	
	Parameters (2, "OS Cross");	 
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

local Number = 2;
local Up={};
local Down={};
local Label={};
local ON={};
local Size;
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local Show;
local PlaySound;
local Live;
local FIRST=true;
local OnlyOnce;
local U={};
local D={};
local UpTrendColor, DownTrendColor;
local OnlyOnceFlag;
local ShowAlert;
local Shift=0; 
local Alert={}; 
local AlertLevel={};



local first=nil;
local source = nil;
 
local loading ={};
local dayoffset;
local weekoffset;
local Comp = nil;
local Instrument={};
local Coeff={};
local Source={};

local Index;
local iNumber=0;
local OB,OS;

function Prepare(nameOnly)
    source = instance.source;
	
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	Size=instance.parameters.Size;
	
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
	OB=instance.parameters.OB;
	OS=instance.parameters.OS;
	
	
    local name = profile:id().. ", " .. source:name() ;
	iNumber=0;
	
	
	for i= 1 , 10 , 1 do
   
	if instance.parameters:getDouble("Coeff" .. i)~= 0 then
		iNumber=iNumber+1;
		
		Coeff[iNumber]=instance.parameters:getDouble("Coeff" .. i);
		Instrument[iNumber]=instance.parameters:getString("Instrument" .. i);
		end
	end
	
	for i= 1 , iNumber , 1 do
		name= name ..   "+(" .. Coeff[i] .. ")*" .. Instrument[i]
    end	
    instance:name(name);
	if nameOnly then 
        return;
    end
	for i= 1 , iNumber , 1 do
		Source[i] = core.host:execute("getSyncHistory",Instrument[i], source:barSize(), source:isBid(), 1, 200+i, 100+i);
		loading[i]=true;
    end	
    Index = instance:addStream("Index", core.Line, name, "Index", instance.parameters.color, source:first())
    Index:setPrecision(math.max(2, instance.source:getPrecision()));
	Index:setWidth(instance.parameters.width);
    Index:setStyle(instance.parameters.style);
	Index:addLevel(OB, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Index:addLevel(OS, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
	
	
     for i= 1, Number , 1 do
		Alert[i]=instance:addInternalStream(0, 0);
		AlertLevel[i]=instance:addInternalStream(0, 0);
     end
	
	InitializationAlert();	
	instance:ownerDrawn(true);	 
	
end
 

function Update(period)
  
  local p={};
  local Flag=false;
  
  	for i= 1, iNumber, 1 do
	    p[i]= Initialization(period,i);
		
		if loading[i] or p[i]== false then		
		Flag=true;
		end
		
		
	end
		
	
	if Flag then
	return;
	end	
  
  
   Index[period] = 0;
  
  
        for i = 1, iNumber, 1 do	
            if 		 Source[i].close:hasData(p[i]) then
            Index[period] = Index[period] + Source[i].close[p[i]] *Coeff[i];			
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
function AsyncOperationFinished(cookie)
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
	
		if Flag and Count > 0 then
		core.host:execute ("setStatus", " Loading ".. (iNumber-Count) .."/" .. iNumber);
		else
		core.host:execute ("setStatus", " Loaded ".. (iNumber-Count) .."/" .. iNumber);		 
		instance:updateFrom(0);	
		end
			  
   
		return core.ASYNC_REDRAW ;
end

---Alert



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


function  InitializationAlert ()
    
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
	  assert(not(PlaySound and ON[i]) or (PlaySound and ON[i] and Up[i] ~= "") or (PlaySound and ON[i] and Up[i] ~= ""), "Sound file must be chosen");
        assert(not(PlaySound and ON[i] ) or (PlaySound and ON[i] and Down[i] ~= "") or (PlaySoundand and ON[i]  and Down[i] ~= ""), "Sound file must be chosen");
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	U[i] = nil;
	D[i] = nil;	 
	end
		 
end	


function Activate (id, period)


   if Index[period]== nil 
   or Index[period-1]== nil 
   then
   return;
   end


   Alert[id][period]=0;
   
   
  
  
	  if id == 1  and ON[id]  then
	  
	       
			if  Index[period] > OB
			and   Index[period-1] <= OB
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= OB; 
						   
			
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
							  
			elseif Index[period] < OB
			and    Index[period-1] >= OB
            then			
			
			            			 
			                Alert[id][period]= -1;	
							AlertLevel[id][period]= OB;
						   
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
	  
	       
			if  Index[period] > OS
			and   Index[period-1] <= OS
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= OS; 
						   
			
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
							  
			elseif Index[period] < OS
			and    Index[period-1] >= OS
            then			
			
			            			 
			                Alert[id][period]= -1;	
							AlertLevel[id][period]= OS;
						   
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

 
 
 
 
