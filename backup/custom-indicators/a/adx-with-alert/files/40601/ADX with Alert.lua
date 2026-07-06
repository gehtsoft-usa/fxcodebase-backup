-- Id: 7448

-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=23594

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

function Init()
    indicator:name("ADX with Alert");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
   
   
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "ADX Period", "", 14, 2, 1000);

	indicator.parameters:addDouble("Level1", "1.Level", "", 10);
	indicator.parameters:addDouble("Level2", "2.Level", "", 20);
	indicator.parameters:addDouble("Level3", "3.Level", "", 30);
	
	indicator.parameters:addString("Filter", "Directional Filter", "", "Any");
	indicator.parameters:addStringAlternative("Filter", "ADX Cross", "", "Any");
    indicator.parameters:addStringAlternative("Filter", "ADX CrossOver", "", "Up");
    indicator.parameters:addStringAlternative("Filter", "ADX CrossUnder", "", "Down");
	
	 indicator.parameters:addGroup("Indicator Style");
	 indicator.parameters:addColor("ADX_color", "ADX color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("ADX_width", "ADX Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("ADX_style", "ADX Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("ADX_style", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("L1C", "1. Level Color", " ", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("L1W", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("L1S", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("L1S", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("L2C", "2. Level Color", " ", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("L2W", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("L2S", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("L2S", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("L3C", "3. Level Color", " ", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("L3W", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("L3S", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("L3S", core.FLAG_LINE_STYLE);


	
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
	
	
	Parameters (1, "1. Level")
	Parameters (2, "2. Level")
	Parameters (3, "3. Level")
	Parameters (4, "Up/Down Tick") 

	
	
end

function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", false);


    indicator.parameters:addFile("UpSound"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("UpSound"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("DownSound"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("DownSound"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 4;

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

local Alert;
local Indicator;
local PlaySound;
local U={};
local D={};

local L1C, L1S, L1W;
local L2C, L2S, L2W;
local L3C, L3S, L3W;

local Period;
local Level1, Level2,Level3;

local ADX;
local Filter;
-- Routine
function Prepare(nameOnly)
    
    source = instance.source;	
	
	
	Period = instance.parameters.Period;
	Level1 = instance.parameters.Level1;
    Level2 = instance.parameters.Level2;
    Level3 = instance.parameters.Level3;
	
	Filter= instance.parameters.Filter;
	
	L1C = instance.parameters.L1C;
	L1S = instance.parameters.L1S;
	L1W = instance.parameters.L1W;
	
	L2C = instance.parameters.L2C;
	L2S = instance.parameters.L2S;
	L2W = instance.parameters.L2W;
	
	L3C = instance.parameters.L3C;
	L3S = instance.parameters.L3S;
	L3W = instance.parameters.L3W;
	
 
    local name = profile:id() .. "(" .. source:name() .. ", " ..Period .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	

    Indicator = core.indicators:create("ADX", source, Period);
    	

    first = Indicator.DATA:first()+1;
	
    ADX = instance:addStream("ADX", core.Line, name .. ". ADX", " ADX", instance.parameters.ADX_color, first);
    ADX:setPrecision(math.max(2, instance.source:getPrecision()));
	ADX:setWidth(instance.parameters.ADX_width);
    ADX:setStyle(instance.parameters. ADX_style);

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
	  Up[i]=instance.parameters:getString("UpSound" .. i);
	  Down[i]=instance.parameters:getString("DownSound" .. i);
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
 
    Indicator:update(mode);

     if period < first then
     return;
     end	 
         ADX[period] = Indicator.DATA[period] ;
    
 
 end
 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 


    Calculate(period, mode);
	
	
	local i;
	for i = 1, Number , 1 do
		 if ON[i] then
		 down[i]:setNoData (period); 
		 up[i]:setNoData (period);
		 end
   end	 
   
   if period < first then
	return;
	end

	
    Activate (1, period)
	Activate (2, period)
	Activate (3, period)
	Activate (4, period)
	
end

function Activate (id, period)


		
	  if id == 1  and ON[id]  then
	  
	     core.host:execute("drawLine", 1, source:date(first), Level1, source:date(source:size()-1), Level1, L1C, L1S, L1W);
		 
			if 	 core.crossesOver(Indicator.DATA, Level1,period) 
			then
			                 if Filter~="Down" then
						     up[id]:set(period , Level1, "\108");	
						     end
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
								   if Filter~="Down" then
								  SoundAlert(Up[id]);
								  EmailAlert(  Label[id] .." Cross Over");
								  end
							  end
			elseif 	 core.crossesUnder(Indicator.DATA, Level1,period) 				
            then			
			
			            	if Filter~="Up" then		 
			               down[id]:set(period , Level1, "\108");	
                           end      						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1
							 then
							 D[id]=source:serial(period);
								 if Filter~="Up" then
								 SoundAlert(Down[id]);			 
								 EmailAlert( Label[id] .. " Cross Under");
								 end							 
			                 end			   
	         end
			
	  
	  elseif id == 2  and ON[id] then
	  
	       core.host:execute("drawLine", 2, source:date(first), Level2, source:date(source:size()-1), Level2, L2C, L2S, L2W);
		   
	        if 	core.crossesOver(Indicator.DATA, Level2,period) 
			then
			                 if Filter~="Down" then 
						     up[id]:set(period ,Level2, "\108");	
						     end
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
								   if Filter~="Down" then
								  U[id]=source:serial(period);
								  SoundAlert(Up[id]);
								  EmailAlert(  Label[id] .." Cross Over");
								  end
							  end
			elseif	core.crossesUnder(Indicator.DATA, Level2,period) 	
            then			
			
			            	if Filter~="Up" then			 
			               down[id]:set(period ,Level2, "\108");	
                           end  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1
							 then
							 D[id]=source:serial(period);
								  if Filter~="Up" then
								 SoundAlert(Down[id]);			 
								 EmailAlert( Label[id] .. " Cross Under");	
								  end							 
			                 end			   
	         end
	       
	  elseif id == 3  and ON[id] then	 
 	  
          core.host:execute("drawLine", 3, source:date(first), Level3, source:date(source:size()-1), Level3, L3C, L3S, L3W);
		  
            if core.crossesOver(Indicator.DATA, Level3,period) 
			then
			                  if Filter~="Down" then
						     up[id]:set(period , Level3, "\108");	
							  end
						   
			     
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
								   if Filter~="Down" then
								  SoundAlert(Up[id]);
								  EmailAlert(  Label[id] .." Cross Over");
								  end
							  end
			elseif	core.crossesUnder(Indicator.DATA, Level3,period) 	
            then			
			
			               if Filter~="Up" then				 
			               down[id]:set(period , Level3, "\108");	
                           end  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1
							 then
							 D[id]=source:serial(period);
									  if Filter~="Up" then
									 SoundAlert(Down[id]);			 
									 EmailAlert( Label[id] .. " Cross Under");	
                                     end									 
			                  end			   
	         end
			 
		 elseif id == 4  and ON[id] then	 
 	  
          
		  
            if  Indicator.DATA[period] >Indicator.DATA[period-1] 
			and  Filter~="Down"  
			then
			           
						    -- up[id]:set(period , Level3, "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
								 
								  SoundAlert(Up[id]);
								  EmailAlert(  Label[id].. " Up"  );
								   
							  end
			elseif	Indicator.DATA[period] < Indicator.DATA[period-1] 
			and  Filter~="Up"  
            then			
			
			           						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1
							 then
							 D[id]=source:serial(period);
									  
									 SoundAlert(Down[id]);			 
									 EmailAlert( Label[id] .. " Down");	
									 							 
			                  end			   			
		   	
            end
           	  
	  end
	  
		   
    

end

function SoundAlert(Sound)
 
	if not PlaySound then
	return
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
 

   local text=  profile:id() .. "(" .. source:instrument() .. ")".. Subject..", " .. LABEL ;
   terminal:alertEmail(Email,  Subject, text);
end
	 
	 
function AsyncOperationFinished (cookie, success, message)
end

