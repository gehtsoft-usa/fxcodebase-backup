-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1459

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
    indicator:name("Pin Bar with Alert");
    indicator:description("Pin Bar Helper");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("BB", "Body Lengt", "Body Lengt", 33);
	indicator.parameters:addInteger("BP", "Body Position", "Body Position", 33);
	indicator.parameters:addInteger("NB", "Nose Lengt", "Nose Lengt", 33);
	indicator.parameters:addBoolean("LA", "Left Eye Check", "Left Eye Check", true);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Top", "Color of Pin bar", "Color of Pin bar", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Bottom", "Color of Pin bar", "Color of Pin bar", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("Size", "Arrow Size", "Arrow Size", 10);
	
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	
	
	Parameters (1, "Pin Bar")
	
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

local 	Number = 1;
local Size;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Body=nil;
local Nose=nil;
local Position=nil;
local Left=nil;
local first;
local source = nil;

-- Streams block
local upx = nil;
local downx = nil;

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

local Alert;
local Indicator;
local PlaySound;

local FIRST=true;

local U={};
local D={};

-- Routine
 function Prepare(nameOnly)

    FIRST=true;
    source = instance.source;
    first = source:first();
	Size= instance.parameters.Size;
	Nose= instance.parameters.NB;
	Body = instance.parameters.BB;
	Position= instance.parameters.BP;
    Left =  instance.parameters.LA;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	downx = instance:createTextOutput ("Upx", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Bottom, 0);
    upx = instance:createTextOutput ("Downx", "Down", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Top, 0);
	up =  instance:addInternalStream(0, 0);
	down = instance:addInternalStream(0, 0);
	
	
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
	
		
	end
		
	

	
end	


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
   
	 if period < first or not  source:hasData(period) then
	return;
	end
		
	Calculation(period-1);	
    
	Activate (1, period-1);
 
	
end



function Activate (id, period)


		
	  if id == 1  and ON[id]  then
	  
	       
			if 	  up[period] == 1 
			then
			           
						     	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-2
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Up");
							  end
							  
							
							  
			elseif   down[period] == -1 
            then			
			
			            			 
			           				   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-2
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
 return;
 end

 if FIRST then
 FIRST= false;
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
 

  local text=  profile:id() .. "(" .. source:instrument() .. ")"  .. Subject..", " .. LABEL;
 terminal:alertEmail(Email, Subject, text);
end
	 

	  

function Calculation (period)

   
    upx:setNoData (period);
	downx:setNoData (period);
	up[period]=0;
	down[period]=0;

local Bar= (source.high[period]- source.low[period])/100;
	
			   if Left then 		   
			   
			   
			        if  math.abs(source.close[period]-source.open[period]) <= Bar* Body then
					
					
								 if math.max(source.close[period], source.open[period]) <= source.low[period] +  Bar *Position then 
									 if source.high[period]- source.high[period-1] >= Nose *Bar then
										 if source.low[period-1]< math.min (source.open[period],source.close[period]) and source.high[period-1] > math.max (source.open[period],source.close[period]) then 
										 upx:set(period, source.high[period], "\226");
										 up[period]=1;
										 end
									 end
								 end
								 if math.min(source.close[period], source.open[period]) >= source.high[period] -  Bar *Position then 
								   
									 if source.low[period-1] - source.low[period]  >= Nose *Bar then
									     if source.high[period-1] >  math.max (source.open[period],source.close[period]) and source.low[period-1] <  math.max (source.open[period],source.close[period]) then 
									      downx:set(period, source.low[period], "\225");
										  down[period]=-1;
										  end
									end
								 end			 
					end
			         
			   
			   else
			   
				
					if  math.abs(source.close[period]-source.open[period]) <= Bar* Body then
					
					
								 if math.max(source.close[period], source.open[period]) <= source.low[period] +  Bar *Position then 
									 if source.high[period]- source.high[period-1] >= Nose *Bar then
									 upx:set(period, source.high[period], "\226");
									 up[period]=1;
									 end
								 end
								 if math.min(source.close[period], source.open[period]) >= source.high[period] -  Bar *Position then 
								   
									 if source.low[period-1] - source.low[period]  >= Nose *Bar then
									downx:set(period, source.low[period], "\225");
									down[period]=-1;
									end
								 end			 
					end
				end	
end			


function AsyncOperationFinished (cookie, success, message)
end	