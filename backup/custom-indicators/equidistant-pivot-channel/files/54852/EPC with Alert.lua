-- Id: 11082
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32176

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
    indicator:name("Equidistant Pivot Channel with Alert");
    indicator:description("Equidistant Pivot Channel");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
 
     indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");

    indicator.parameters:addGroup("Pivot Calculation");
    indicator.parameters:addString("BS", "Time Frame", "", "D1");
    indicator.parameters:setFlag("BS", core.FLAG_PERIODS);

    indicator.parameters:addString("CalcMode", "Pivot","", "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", "Pivot", "", "Pivot");
    indicator.parameters:addStringAlternative("CalcMode", "Camarilla", "", "Camarilla");
    indicator.parameters:addStringAlternative("CalcMode", "Woodie", "", "Woodie");
    indicator.parameters:addStringAlternative("CalcMode", "Fibonacci", "", "Fibonacci");
    indicator.parameters:addStringAlternative("CalcMode", "Floor", "", "Floor");
    indicator.parameters:addStringAlternative("CalcMode", "FibonacciR", "", "FibonacciR");
	
	 indicator.parameters:addGroup("Levels");
	 indicator.parameters:addDouble("First", "1. Line (in Pips)", "", 20);
	 indicator.parameters:addDouble("Second", "2. Line (in Pips)", "", 40);
	
	 indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Pivot_color", "Color of Pivot", "Color of Pivot", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color1", "Color of 1. Pivot", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "1. Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "1. Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("color2", "Color of 2. Line", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width2", "2. Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "2. Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
 
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	
	
	Parameters (1, "2. Top Line Cross");
	Parameters (2, "1. Top Line Cross");
	Parameters (3, "Central Line Cross");
	Parameters (4, "1. Bottom Line Cross");
	Parameters (5, "2. Bottom Line Cross");
end

function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", false);


    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 5;

local Up={};
local Down={};
local Label={};
local ON={};
local Line;
local up={};
local down={};
local Size;
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local Show;
local Alert;
local PlaySound;
local Live;
local FIRST=true;
local U={};
local D={};


-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local BS, CalcMode;
local first;
local source = nil;
local Pivot;
local Top={};
local Bottom={};
-- Streams block
local PIVOT;
local First, Second;
-- Routine
function Prepare(nameOnly)
    FIRST=true;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	
    BS = instance.parameters.BS;
	CalcMode = instance.parameters.CalcMode;
	First = instance.parameters.First;
	Second = instance.parameters.Second;
    source = instance.source;
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(BS).. ", " .. tostring(CalcMode) .. ", " .. tostring(First).. ", " .. tostring(Second).. ")";
    instance:name(name);

    if (not (nameOnly)) then
		PIVOT = core.indicators:create("PIVOT", source, BS,CalcMode, "HIST" );
		first = PIVOT.DATA:first();
        Pivot = instance:addStream("Pivot", core.Line, name, "Pivot", instance.parameters.Pivot_color, first);
		Pivot:setWidth(instance.parameters.width);
        Pivot:setStyle(instance.parameters.style);
		
		Top[1] = instance:addStream("Top1", core.Line, name, "1.Top", instance.parameters.color1, first);
		Top[1]:setWidth(instance.parameters.width1);
        Top[1]:setStyle(instance.parameters.style1);
		
		Top[2] = instance:addStream("Top2", core.Line, name, "2.Top", instance.parameters.color2, first);
		Top[2]:setWidth(instance.parameters.width2);
        Top[2]:setStyle(instance.parameters.style2);
		
		Bottom[1] = instance:addStream("Bottom1", core.Line, name, "1.Bottom", instance.parameters.color1, first);
		Bottom[1]:setWidth(instance.parameters.width1);
        Bottom[1]:setStyle(instance.parameters.style1);
		
		
		Bottom[2] = instance:addStream("Bottom2", core.Line, name, "2.Bottom", instance.parameters.color2, first);
		Bottom[2]:setWidth(instance.parameters.width2);
        Bottom[2]:setStyle(instance.parameters.style2);
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


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
 local i;
	for i = 1, Number , 1 do
		  if ON[i] then
		 down[i]:setNoData (period); 
		 up[i]:setNoData (period);
		 end
   end	 

  Calculation(period, mode);
  
 
   

end


function Activate (id, period)

   local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
 
	  if id == 3  and ON[id]  then
	  
	       
			if source.close[period] > Pivot[period]
			and source.close[period-1] <= Pivot[period-1]
			then
			           
						     up[id]:set(period , Pivot[period], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							    
							        if Show then
									Pop(Label[id], " Cross Over " );  	
								    end
								 
							  end
			elseif  source.close[period] < Pivot[period]
			and source.close[period-1] >= Pivot[period-1]
            then			
			
			            			 
			               down[id]:set(period , Pivot[period], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 if Show then
									Pop(Label[id], " Cross Under " );  	
								 end
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
	  if id == 1  and ON[id]  then
	  
	       
			if source.close[period] > Top[2][period]
			and source.close[period-1] <= Top[2][period-1]
			then
			           
						     up[id]:set(period , Top[2][period], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							    
							        if Show then
									Pop(Label[id], " Cross Over " );  	
								    end
								 
							  end
			elseif  source.close[period] < Top[2][period]
			and source.close[period-1] >= Top[2][period-1]
            then			
			
			            			 
			               down[id]:set(period , Top[2][period], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 if Show then
									Pop(Label[id], " Cross Under " );  	
								 end
							 
			                  end			   
	         end
			
	  
	 
	  end
	  if id == 2  and ON[id]  then
	  
	       
			if source.close[period] > Top[1][period]
			and source.close[period-1] <= Top[1][period-1]
			then
			           
						     up[id]:set(period , Top[1][period], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							    
							        if Show then
									Pop(Label[id], " Cross Over " );  	
								    end
								 
							  end
			elseif  source.close[period] < Top[1][period]
			and source.close[period-1] >= Top[1][period-1]
            then			
			
			            			 
			               down[id]:set(period , Top[1][period], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 if Show then
									Pop(Label[id], " Cross Under " );  	
								 end
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
	   if id == 4  and ON[id]  then
	  
	       
			if source.close[period] > Bottom[1][period]
			and source.close[period-1] <= Bottom[1][period-1]
			then
			           
						     up[id]:set(period , Bottom[1][period], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							    
							        if Show then
									Pop(Label[id], " Cross Over " );  	
								    end
								 
							  end
			elseif  source.close[period] < Bottom[1][period]
			and source.close[period-1] >= Bottom[1][period-1]
            then			
			
			            			 
			               down[id]:set(period , Bottom[1][period], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 if Show then
									Pop(Label[id], " Cross Under " );  	
								 end
							 
			                  end			   
	         end
			
	  
	 
	  end
	  if id == 5  and ON[id]  then
	  
	       
			if source.close[period] > Bottom[2][period]
			and source.close[period-1] <= Bottom[2][period-1]
			then
			           
						     up[id]:set(period , Bottom[2][period], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							    
							        if Show then
									Pop(Label[id], " Cross Over " );  	
								    end
								 
							  end
			elseif  source.close[period] < Bottom[2][period]
			and source.close[period-1] >= Bottom[2][period-1]
            then			
			
			            			 
			               down[id]:set(period , Bottom[2][period], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 if Show then
									Pop(Label[id], " Cross Under " );  	
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
   " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) "  ..   label .. " : " .. note );


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
   local TF= "Time Frame : " .. source:barSize();    
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
   
     local text = Note  .. delim ..  Symbol .. delim .. TF .. delim .. Time;
	
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 


function Calculation(period, mode)
  core.host:execute ("removeAll")
    PIVOT:update(mode);
   
    if period< source:size()-1   then
	return;
	end
	
    local i;
	for i= first, source:size()-1 do
	   if PIVOT.DATA:hasData(i) then
	   Pivot[i] = PIVOT.DATA[i];
	   Top[1][i] = PIVOT.DATA[i]+First*source:pipSize();
	   Top[2][i] = PIVOT.DATA[i]+Second*source:pipSize();
	   Bottom[1][i] = PIVOT.DATA[i]-First*source:pipSize();
	   Bottom[2][i] = PIVOT.DATA[i]-Second*source:pipSize();
	   
	   Activate (1, i);
	   Activate (2, i);
	   Activate (3, i);
	   Activate (4, i);
	   Activate (5, i);
	   
	   end
	   
   end
end

function AsyncOperationFinished (cookie, success, message)
end