
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=18031

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
    indicator:name("Level Stop Reverse With Alert");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
   
   
   	indicator.parameters:addGroup("Selection");	
	indicator.parameters:addString("Mode", "Method", "Method" , "ATR");
	indicator.parameters:addStringAlternative("Mode", "ATR", "" , "ATR");
	indicator.parameters:addStringAlternative("Mode", "Smoothed ATR", "" , "SATR");
	indicator.parameters:addStringAlternative("Mode", "PIP", "" , "PIP");
	
    indicator.parameters:addGroup("ATR");	
	indicator.parameters:addDouble("AP", "ATR Period", "" , 14);
	indicator.parameters:addDouble("Multiplier", "Multiplier", "" , 3);
	
	indicator.parameters:addGroup("Smoothed ATR");	
	indicator.parameters:addDouble("MP", "Smoothed Period", "" , 14);
	indicator.parameters:addDouble("SMultiplier", "SmoothedMultiplier", "" , 2.824);
	
	 indicator.parameters:addGroup("Pip");	
	indicator.parameters:addDouble("Pip", "Pip Distance", "" , 50);
   
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("LSR_color", "Color of LSR", "Color of LSR", core.rgb(0, 0, 255));	
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);	
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("UpC", "Up Arrow Coloor", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DownC", "Down Arrow Coloor", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("ArrowSize", "ArrowSize", "", 7);
	indicator.parameters:addInteger("ArrowDistance", "ArrowDistance", "", 25);
	indicator.parameters:addBoolean("Use", "Use Arrow Alert", "", false);	
	

	indicator.parameters:addGroup("Early Warning Alert");
	indicator.parameters:addInteger("SIZE", "Early Warning channel distance (in Pips)", "", 10, 0 , 1000000);
	
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
	
	
	Parameters (1, "LSR Line");
	Parameters (2, "Top Line Early Warning");
	Parameters (3, "Bottom Line Early Warning");
	
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

local 	Number = 3;

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
local SIZE;
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local Use;
local Alert;
local Indicator;
local PlaySound;

local U={};
local D={};

local Mode;
local Multiplier;
local AP;
local MP;
local Pip;
-- Streams block
local LSR = nil;
local ATR, MA;
local SMultiplier;
local font;
local ArrowDistance;
local upI, downI;
-- Routine
function Prepare(nameOnly)     
    
    source = instance.source;
	SIZE = instance.parameters.SIZE;
	ArrowDistance = instance.parameters.ArrowDistance;
	ArrowSize = instance.parameters.ArrowSize;
    Use = instance.parameters.Use;
    Pip = instance.parameters.Pip;
    Mode = instance.parameters.Mode;
	AP = instance.parameters.AP;
	MP = instance.parameters.MP;
	Multiplier = instance.parameters.Multiplier;
	SMultiplier= instance.parameters.SMultiplier;
	
 
   first =source:first();

    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. Mode.. ", " .. AP.. ", " .. Multiplier.. ", " ..MP.. ", " ..SMultiplier.. ", " ..Pip.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	if Use then
	upI = instance:createTextOutput ("UpI", "Up", "Wingdings", ArrowSize, core.H_Center, core.V_Top, instance.parameters.UpC, 0);
    downI = instance:createTextOutput ("DnI", "Dn", "Wingdings", ArrowSize, core.H_Center, core.V_Bottom, instance.parameters.DownC, 0);
	end

    local name;
	if Mode == "ATR" then
	name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Mode) .. ", " .. tostring(AP).. ", " .. tostring(Multiplier).. ")";
	elseif Mode == "SATR" then
  	name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Mode) .. ", " .. tostring(AP).. ", " .. tostring(MP).. ", " .. tostring(SMultiplier).. ")";
	else
	name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Mode) .. ", " .. tostring(Pip).. ")";
	end
	
    instance:name(name);
	
	if  Mode == "ATR" or  Mode == "SATR" then 
	ATR = core.indicators:create( "ATR", source,  AP);
	first = math.max(first, ATR.DATA:first())
	end
	
	if Mode == "SATR" then
	MA = core.indicators:create( "EMA", ATR.DATA,  MP);
	first = math.max(first, MA.DATA:first())
	end

 
        LSR = instance:addStream("LSR", core.Line, name, "LSR", instance.parameters.LSR_color, first);
		LSR:setWidth(instance.parameters.width);
        LSR:setStyle(instance.parameters.style);
    
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
   if  Mode == "ATR" or  Mode == "SATR" then 
	ATR:update(mode);
	end
	
	if Mode == "SATR" then
	MA:update(mode);
	end
	
	if period < first then
	return;
	end

	
	local Delta;
	
	if Mode == "ATR" then 
	Delta= ATR.DATA[period] * Multiplier;
	elseif Mode == "SATR" then
	Delta= MA.DATA[period] * SMultiplier;
	else
	Delta= Pip * source:pipSize();
	end
	
	 LSR[period] =  LSR[period-1];
	
	if period == first then
		if source.close[period] > source.close[period] then
		LSR[period] = source.close[period]- Delta;
		else
		LSR[period] = source.close[period]+ Delta;
		end
	end	
	
        if source.close[period-1] <= LSR[period-1]  and  source.close[period] < LSR[period-1] then
		LSR[period] = math.min(source.close[period]+ Delta, LSR[period-1] );
		elseif source.close[period-1] >= LSR[period-1] and  source.close[period] >LSR[period-1] then
		LSR[period] = math.max(source.close[period]- Delta, LSR[period-1]);
		else
		
				  if  source.close[period] > LSR[period-1] then
				  LSR[period]=source.close[period]- Delta;
				   else 
				   LSR[period]=source.close[period]+ Delta;
				  end
	if Use then
	
	local Level;
			upI:setNoData (period);
			downI:setNoData (period);
			
			if source.close[period-1] > LSR[period-1]
			and  source.close[period] < LSR[period] 
			then
			Level= source.high[period] +ArrowDistance*source:pipSize();	
			downI:set(period, Level, "\226");
			elseif source.close[period-1] < LSR[period-1]
			and  source.close[period] > LSR[period] 
			then
			Level= source.low[period] -ArrowDistance*source:pipSize();
			upI:set(period, Level, "\225");
			end  
 
    end
				 
                
		
		end

	local Level;

	
	
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
	
    Activate (1, period);
	Activate (2, period);
    Activate (3, period);
end

function Activate (id, period)


		
	  if id == 1  and ON[id]  then
	  
	       
			if 	LSR[period-1] > source.close[period-1]
			and LSR[period] < source.close[period]
			then
			           
						     up[id]:set(period , LSR[period], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  end
			elseif	LSR[period-1] < source.close[period-1]
			and LSR[period] > source.close[period]		
            then			
			
			            			 
			               down[id]:set(period , LSR[period], "\108");	  						   
						   
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
	  
	        if 	LSR[period-1] > source.close[period-1] +SIZE*source:pipSize() 
			and LSR[period] < source.close[period]+SIZE*source:pipSize() 
			then
			           
						     up[id]:set(period ,  LSR[period] +SIZE*source:pipSize()  ,"\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  end
			elseif		LSR[period-1] < source.close[period-1]+SIZE*source:pipSize() 
			and LSR[period] > source.close[period] +SIZE*source:pipSize() 
            then			
			
			            			 
			               down[id]:set(period ,  LSR[period] +SIZE*source:pipSize() , "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");								   
			                     end			   
	         end
	       
	  
	         elseif id == 3  and ON[id] then
	  
	        if 	LSR[period-1] > source.close[period-1] -SIZE*source:pipSize() 
			and LSR[period] < source.close[period] - SIZE*source:pipSize() 
			then
			           
						     up[id]:set(period ,  LSR[period] -SIZE*source:pipSize() , "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  end
			elseif	LSR[period-1] < source.close[period-1]
			and LSR[period] > source.close[period] 				
            then			
			
			            			 
			               down[id]:set(period ,  LSR[period] -SIZE*source:pipSize() , "\108");	  						   
						   
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
  
  Alert:invoke( "PlaySound", Sound, RecurrentSound);
  
end


function AsyncOperationFinished (cookie, success, message)
end


function EmailAlert( Subject)

if not SendEmail then
return
end
 
    local date = source:date(NOW);
	local DATA = core.dateToTable (date);
	
    local LABEL =  DATA.month..", ".. DATA.day ..", ".. DATA.hour  ..", ".. DATA.min ..", ".. DATA.sec;
  local text= profile:id() .. "(" .. source:instrument() .. ")" .. source[NOW]..", " .. Subject..", " .. LABEL;
  terminal:alertEmail(Email, Subject, text);

 
end
	 

