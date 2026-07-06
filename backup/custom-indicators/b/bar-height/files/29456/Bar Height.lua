-- Id: 6286
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15639

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
    indicator:name("Bar Height");
    indicator:description("High/Low or Open/Close Difference");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
   
   
    indicator.parameters:addGroup("Calculation");  
    indicator.parameters:addString("Type", "H/L - O/C", "", "High/Low");
    indicator.parameters:addStringAlternative("Type", "High/Low", "", "High/Low");
    indicator.parameters:addStringAlternative("Type", "Open/Close", "", "Open/Close");
	indicator.parameters:addStringAlternative("Type", "Open/Close + 2 x Wicks ", "", "Open/Close + 2 x Wicks");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Line Lovor", "", core.rgb(255, 0, 0));
	indicator.parameters:addString("Method", "Line Type", "Bar or Line", "Bar");
    indicator.parameters:addStringAlternative("Method", "Bar", "", "Bar");
    indicator.parameters:addStringAlternative("Method", "Line", "", "Line");
	
	indicator.parameters:addString("PIP", "Line Type", "Bar or Line", "YES");
    indicator.parameters:addStringAlternative("PIP", "Pip", "", "YES");
    indicator.parameters:addStringAlternative("PIP", "Value", "", "NO");
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Top Level","", 0);
    indicator.parameters:addDouble("oversold","Bottom Level","", 0);
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

	
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
	
	
	Parameters (1, "Bottom Line")
	Parameters (2, "Top Line")

	

	
	
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

local 	Number = 2;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Up={};
local Down={};
local Label={};
local ON={};
local first;
local source = nil;
local Line;
local up={};
local down={};
local Size;
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local oversold,overbought;
local Alert;
local Indicator;
local PlaySound;

local U={};
local D={};


local Type;
local PIP;
local source = nil;
local Difference = nil;
local Method;



-- Routine
function Prepare(nameOnly)   
    oversold = instance.parameters.oversold;
	overbought = instance.parameters.overbought;
    source = instance.source;
	first=source:first()
	
	 PIP = instance.parameters.PIP;
    Method = instance.parameters.Method;
    Type = instance.parameters.Type;
   

    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Type) .. ", " .. tostring(Method).. ")";
	instance:name(name);
	if nameOnly then
		return;
	end

	     if Method== "Bar" then
         Difference = instance:addStream("Difference", core.Bar, name, "Difference", instance.parameters.color, first);
		 else
		 Difference = instance:addStream("Difference", core.Line, name, "Difference", instance.parameters.color, first);
		 end
		 
		  if oversold~= 0 then
		  Difference:addLevel(oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		  end
		  
		  if overbought~= 0 then
		  Difference:addLevel(overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
          end		  
		 
		  if PIP == "YES" then
		  Difference:setPrecision (2);
		  else
		  Difference:setPrecision (4);
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
 
 
    if period >= first and source:hasData(period) then
	    if Type == "High/Low" then
         Difference[period] = source.high[period] -source.low[period];
		 elseif Type == "Open/Close" then
		 Difference[period] = math.abs(source.close[period] -source.open[period]);
		 else
		 Difference[period] = source.high[period] -source.low[period]
		 +  (source.high[period] - math.max(source.close[period],source.open[period] ) )
		 +  ( math.min(source.close[period],source.open[period] ) - source.low[period]  );
		 end
		 if PIP == "YES" then
		 Difference[period]=  Difference[period] / source:pipSize();
		 end
		 
    end
 
    
 
 end
 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 

if period < first then
return;
end

    Calculate(period, mode);
	
	
	local i;
	for i = 1, Number , 1 do
		  if ON[i] then
		 down[i]:setNoData (period); 
		 up[i]:setNoData (period);
		 end
   end	 
	
    Activate (1, period)
	Activate (2, period)

end

function Activate (id, period)


		
	  if id == 1  and ON[id]   then
	  
	       
			if 	Difference[period-1] < oversold
			and Difference[period] >  oversold
			 and oversold~= 0 
			then
			           
						     up[id]:set(period , oversold, "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  end
			elseif	Difference[period-1] > oversold 
			and  Difference [period] <  oversold	
             and oversold~= 0 			
            then			
			
			            			 
			               down[id]:set(period , oversold, "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");								   
			                     end			   
	         end
			
	  
	  elseif id == 2  and ON[id] then
	  
	        if 	Difference[period-1] <overbought
			and Difference[period] >  overbought
			and overbought~= 0
			then
			           
						     up[id]:set(period , overbought, "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  end
			elseif	Difference[period-1] > overbought
			and  Difference[period]  <  overbought	
            and overbought~= 0			
            then			
			
			            			 
			               down[id]:set(period , overbought, "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");								   
			                     end			   
	         end
	       
	  end
	  
		   
    

end

function SoundAlert(Sound)
  if not PlaySound then
  return;
  end
  
 
 terminal:alertSound(Sound, RecurrentSound);
end

 


function EmailAlert( Subject)

if not SendEmail then
return
end
 
    local date = source:date(NOW);
	local DATA = core.dateToTable (date);
	
    local LABEL =  DATA.month..", ".. DATA.day ..", ".. DATA.hour  ..", ".. DATA.min ..", ".. DATA.sec;
 

   local text= profile:id() .. "(" .. source:instrument() .. ")" .. source[NOW]..", " .. Subject..", " .. LABEL;
  terminal:alertEmail(Email, Subject, text)
end
	 

