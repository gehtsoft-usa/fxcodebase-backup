-- Id: 11638
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=28103

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Reverse Engineering RSI");
    indicator:description("Reverse Engineering RSI");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");
	
	
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("WildPer", "Period", "Period", 14);
	indicator.parameters:addDouble("value3", "OB Level", "Level", 70);
	indicator.parameters:addDouble("value1", "Central Level", "Level", 50);
	indicator.parameters:addDouble("value2", "OS", "Level", 30);
	
	
   indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("color1", "Color of 1. Line", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("color2", "Color of 2. Line", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("color3", "Color of 3. Line", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
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
	
	
	Parameters (1, "Overbought Line");
	Parameters (2, "Oversold Line")
	Parameters (3, "Central Line")
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

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local WildPer; 
local first;
local source = nil;

-- Streams block
local L1, L2, L3 ;
local K, ExpPer;
local AUC,ADC;

local value1 = 50;
local value2 = 30;
local value3 = 70;

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
 
-- Routine
function Prepare(nameOnly)
    FIRST=true;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	
	
    WildPer = instance.parameters.WildPer;
    value = instance.parameters.value;
    source = instance.source;
	value1= instance.parameters.value1;
	value2= instance.parameters.value2;
	value3= instance.parameters.value3;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(WildPer)   .. ")";
    instance:name(name);
	
	ExpPer = 2 * WildPer - 1;	
	K = 2 / (ExpPer + 1);
	
    
    if (not (nameOnly)) then
		AUC = instance:addInternalStream(0, 0);
		ADC = instance:addInternalStream(0, 0);
        L1 = instance:addStream("L1", core.Line, name .. value1, value1, instance.parameters.color1, first);
		L1:setWidth(instance.parameters.width1);
        L1:setStyle(instance.parameters.style1);
        L2 = instance:addStream("L2", core.Line, name .. value2, value2, instance.parameters.color2, first);
		L2:setWidth(instance.parameters.width2);
        L2:setStyle(instance.parameters.style2);
        L3 = instance:addStream("L3", core.Line, name .. value3, value3, instance.parameters.color3, first);	
		L3:setWidth(instance.parameters.width3);
        L3:setStyle(instance.parameters.style3);
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


 function Calculate(period, mode)
 
 	if(source[period] > source[period-1]) then
		AUC[period] = K * (source[period] - source[period-1]) + (1 - K) * AUC[period-1];
		ADC[period] = (1 - K) * ADC[period-1];	 
	else 
		AUC[period] = (1 - K) * AUC[period-1];
		ADC[period] = K * (source[period-1] - source[period]) + (1 - K) * ADC[period-1];
	end
	
		
	local x1 = (WildPer - 1) * (ADC[period] * value1 / (100 - value1) - AUC[period]);
	
	if(x1 >= 0) then 
		L1[period]  = source[period] + x1;
	else
		L1[period] =  source[period] + x1 * (100 - value1) / value1;
	end	
	
	
	local x2 = (WildPer - 1) * (ADC[period] * value2 / (100 - value2) - AUC[period]);
	
	if(x2 >= 0) then 
		L2[period]  = source[period] + x2;
	else
		L2[period] =  source[period] + x2 * (100 - value2) / value2;
	end

    local x3 = (WildPer - 1) * (ADC[period] * value3 / (100 - value3) - AUC[period]);
	
	if(x3 >= 0) then 
		L3[period]  = source[period] + x3;
	else
		L3[period] =  source[period] + x3 * (100 - value3) / value3;
	end		
	
 
 end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first   then
	return;
	end
      
   Calculate(period, mode)
	
   	local i;
	for i = 1, Number , 1 do
		  if ON[i] then
		 down[i]:setNoData (period); 
		 up[i]:setNoData (period);
		 end
   end
   
   
    if period < first +1  then
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
 
	  if id == 3  and ON[id]  then
	  
	       
			if source[period] > L1[period]
			and source[period-1] <=  L1[period-1]
			then
			           
						     up[id]:set(period ,  L1[period], "\108");	
						   
			
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
			elseif  source[period] <  L1[period]
			and source[period-1] >=  L1[period-1]
			then
			            			 
			               down[id]:set(period , L1[period], "\108");	  						   
						   
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
			
	  
	 
	    elseif id == 1  and ON[id]  then
	  
	       
			if source[period] > L3[period]
			and source[period-1] <=  L3[period-1]
			then
			           
						     up[id]:set(period ,  L3[period], "\108");	
						   
			
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
			elseif  source[period] <  L3[period]
			and source[period-1] >=  L3[period-1]
			then
			            			 
			               down[id]:set(period , L3[period], "\108");	  						   
						   
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
			
	  
	 
	    elseif id == 2  and ON[id]  then
	  
	       
			if source[period] > L2[period]
			and source[period-1] <=  L2[period-1]
			then
			           
						     up[id]:set(period ,  L2[period], "\108");	
						   
			
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
			elseif  source[period] <  L2[period]
			and source[period-1] >=  L2[period-1]
			then
			            			 
			               down[id]:set(period , L2[period], "\108");	  						   
						   
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
   " ( " .. source:instrument()  .. " ) "  ..   label .. " : " .. note );


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
   
     local text = Note  .. delim ..  Symbol .. delim .. Time;
 
terminal:alertEmail(Email, profile:id(), text);
end
	 



