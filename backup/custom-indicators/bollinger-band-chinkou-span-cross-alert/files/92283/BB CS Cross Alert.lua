-- Id: 11007
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60245

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Bollinger Band / Chinkou Span Cross Alert");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator:setTag("group", "Bollinger");

    indicator.parameters:addGroup("BB Calculation");
    indicator.parameters:addInteger("N", "Period","Period", 20, 1, 10000);
	indicator.parameters:addDouble("Dev","Number of standard deviations","The number of standard deviations.", 2.0, 0.0001, 1000.0);
	
	indicator.parameters:addGroup("Chinkou Span Calculation");
	indicator.parameters:addInteger("Y", "Kijun-sen period","Kijun-sen period", 26, 1, 10000);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrBBP","Band lines Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthBBB","Band lines Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleBBB", "Band lines Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleBBB", core.FLAG_LEVEL_STYLE);

    indicator.parameters:addBoolean("HideAve", "Hide average line","Defines whether the BB average line is hidden.", true);
    indicator.parameters:addColor("clrBBA", "Average line Color","", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthBBA", "Average line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleBBA", "Average line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleBBA", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addColor("clrCS", "Chinkou Span line Color","", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthCS", "Chinkou Span line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleCS", "Chinkou Span line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleCS", core.FLAG_LEVEL_STYLE);
	 
	
	indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	
 
	
	Parameters (1, "Chikou Span Top Band Cross");
	Parameters (2, "Chikou Span Bottom Band Cross")
	Parameters (3, "Chikou Span Central Band Cross") 
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

local Kijun;
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
local Alert;
local Indicator;
local PlaySound;
local Live;
local FIRST=true;
local U={};
local D={};
local Dev;
local CS;
local csFirst;
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
local ICH,ich;
-- Routine
function Prepare(nameOnly)
    Kijun = instance.parameters.Y;
	 
    FIRST=true;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	
	
    N = instance.parameters.N;
    Dev = instance.parameters.Dev;
    source = instance.source;
    firstPeriod = source:first() + N - 1;
	
	
	  local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. Dev.. ", " .. Kijun.. ")";
	instance:name(name)
	if nameOnly then
		return;
	end
	
	CS = instance:addStream("CS", core.Line, name .. ".CS", "CS", instance.parameters.clrCS, source:first(), -Kijun)
	 CS:setWidth(instance.parameters.widthCS);
    CS:setStyle(instance.parameters.styleCS);
     csFirst = CS:first() + Kijun;
   
    TL = instance:addStream("TL", core.Line, name .. ".TL", "TL", instance.parameters.clrBBP, firstPeriod)
    TL:setWidth(instance.parameters.widthBBB);
    TL:setStyle(instance.parameters.styleBBB);
    BL = instance:addStream("BL", core.Line, name .. ".BL", "BL", instance.parameters.clrBBP, firstPeriod)
    BL:setWidth(instance.parameters.widthBBB);
    BL:setStyle(instance.parameters.styleBBB);
    if not instance.parameters.HideAve then
        AL	= instance:addInternalStream(0, 0);
	else
	    AL = instance:addStream("AL", core.Line, name .. ".AL", "AL", instance.parameters.clrBBA, firstPeriod)
        AL:setWidth(instance.parameters.widthBBA);
        AL:setStyle(instance.parameters.styleBBA);
        
    end
	
	Initialization();
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
	
		if ON[i] then
		up[i] = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Up, 0);
		down[i] = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Down, 0);
		end
	end
		
	

	
end	


 function Calculate(period)
 
      if (period >= csFirst) then
        CS[period - Kijun] = source[period];
    end

	
 
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
 
 
local i;
	for i = 1, Number , 1 do
		  if ON[i] then
		 down[i]:setNoData (period); 
		 up[i]:setNoData (period);
		 end
   end	 
   
 if period < firstPeriod+ Kijun
 or period < csFirst
 then
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
 
	  if id == 1  and ON[id]  then
	  
	       
			if  CS[period-Kijun] > TL[period-Kijun]
			and CS[period-1-Kijun] <= TL[period-1-Kijun]
			then
			           
						     up[id]:set(period-Kijun , TL[period-Kijun], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Chikou Span Top Band Cross Over", period);
							    
							        if Show then
									Pop(Label[id], " Chikou Span Top Band Cross Over " );  	
								    end
								 
							  end
			elseif  CS[period-Kijun] < TL[period-Kijun]
			and CS[period-1-Kijun] >= TL[period-1-Kijun]
            then			
			
			            			 
			               down[id]:set(period-Kijun , TL[period-Kijun], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Chikou Span Top Band Cross Under", period);	
								 if Show then
									Pop(Label[id], " Chikou Span Top Band Cross Under " );  	
								 end
							 
			                  end			   
	         end
			
	 end

	  
	  --//////////BL
	  
	   if id == 2  and ON[id]  then
	  
	       
			if  CS[period-Kijun] > BL[period-Kijun]
			and CS[period-1-Kijun] <= BL[period-1-Kijun]
			then
			           
						     up[id]:set(period -Kijun, BL[period-Kijun], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Chikou Span Bottom Band Cross Over", period);
							    
							        if Show then
									Pop(Label[id], " Chikou Span Bottom Band Cross Over " );  	
								    end
								 
							  end
			elseif  CS[period-Kijun] < BL[period-Kijun]
			and CS[period-1-Kijun] >= BL[period-1-Kijun]
            then			
			
			            			 
			               down[id]:set(period-Kijun , BL[period-Kijun], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Chikou Span Bottom Band Cross Under", period);	
								 if Show then
									Pop(Label[id], " Chikou Span Bottom Band Cross Under " );  	
								 end
							 
			                  end			   
	         end
			
	 end
	  --///////////AL
	  
	   if id == 3  and ON[id]  then
	  
	       
			if  CS[period-Kijun] > AL[period-Kijun]
			and CS[period-1-Kijun] <= AL[period-1-Kijun]
			then
			           
						     up[id]:set(period-Kijun , AL[period-Kijun], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Chikou Span Central Line Cross Over", period);
							    
							        if Show then
									Pop(Label[id], " Chikou Span Central Line Cross  Over " );  	
								    end
								 
							  end
			elseif  CS[period-Kijun] < AL[period-Kijun]
			and CS[period-1-Kijun] >= AL[period-1-Kijun]
            then			
			
			            			 
			               down[id]:set(period-Kijun , AL[period-Kijun], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Chikou Span Central Central Line Cross Under", period);	
								 if Show then
									Pop(Label[id], " Chikou Span Central Central Line Cross Under " );  	
								 end
							 
			                  end			   
	         end
			
	 end
		   
        if FIRST then
        FIRST=false;      
        end		

end


function AsyncOperationFinished (cookie, success, message)
end


function Pop(label , note)

   core.host:execute ("prompt", 1, label ,
   " ( " .. source:instrument()  ..   label .. " : " .. note );


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
  --local TF= "Time Frame : " .. source:barSize();    
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
   
     local text = Note  .. delim ..  Symbol .. delim .. Time;
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 







