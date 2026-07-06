-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2065

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
    indicator:name("Fibonacci Bollinger Bands with Alert");
    indicator:description("Fibonacci Bollinger Bands with Alert");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Indicator Calculation");
	
	
    indicator.parameters:addString("Mode", "Alert Mode", "" , "Any");
     indicator.parameters:addStringAlternative("Mode", "Cross", "" , "Cross");
     indicator.parameters:addStringAlternative("Mode", "Touch", "" , "Touch");
      indicator.parameters:addStringAlternative("Mode", "Any", "" , "Any");
	
    indicator.parameters:addInteger("MF", "Fibonacci Bollinger Bands Period", "", 20);
    indicator.parameters:addInteger("AF", "ATR Period", "", 20);
	local i,j;
	
	i=1;
    indicator.parameters:addDouble("F"..i, "1. Fibonacci Level", " ", 1.6180);
	i=2;
    indicator.parameters:addDouble("F"..i, "2. Fibonacci Level", " ", 2.6180);
	i=3;
    indicator.parameters:addDouble("F"..i, "3. Fibonacci Level", " ", 4.2360);
	
    indicator.parameters:addGroup("Indicator Style");

    indicator.parameters:addColor("CC", "Cental Line Color", " ", core.rgb(125, 125, 125));
	i=1;
    indicator.parameters:addColor("FC"..i, "Color of  1. Fibonacci", " ", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width"..i, "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style"..i, "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..i, core.FLAG_LINE_STYLE);
	i=2;
    indicator.parameters:addColor("FC"..i, "Color of 2. Fibonacci", " ", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width"..i, "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style"..i, "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..i, core.FLAG_LINE_STYLE);	
	i=3;
    indicator.parameters:addColor("FC"..i, "Color of 3. Fibonacci", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width"..i, "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style"..i, "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..i, core.FLAG_LINE_STYLE);
    
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
    
    
    Parameters (3, "Price / +3 ")
    Parameters (2, "Price / +2 ")
    Parameters (1, "Price / +1 ")
    Parameters (4, "Price / 0 ")
    Parameters (5, "Price / -1 ")
    Parameters (6, "Price / -2 ")
    Parameters (7, "Price / -3 ")
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

local 	Number = 7;


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
local Mode;
local Alert;
local Indicator;
local PlaySound;



local U={};
local D={};



local MF;
local AF;
local F={};
local FC={};
local source = nil;

-- Streams block
local SMA = nil;
local ATR =nil;
local Fibonacci = {};              
local Style={};
local Width={};
local CENTRAL=nil;

local ATRFirst=nil;
local MVAFirst=nil;

-- Routine
function Prepare(nameOnly)   

    
	local i;
    Mode = instance.parameters.Mode;	
    MF = instance.parameters.MF;
	AF = instance.parameters.AF;
	for i = 1, 3 , 1 do
	FC[i]= instance.parameters:getColor("FC".. i);
	F[i]= instance.parameters:getString("F".. i);
	Style[i]=instance.parameters:getString("style".. i);
    Width[i]=instance.parameters:getString("width".. i);
	end
    source = instance.source;
    first = source:first();
	
	
	  local name = profile:id() .. "(" .. source:name() .. ", " .. MF ..", ".. AF.. ", " .. F[1] .. ", " .. F[3] .. ", " .. F[3] .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
		
	SMA = core.indicators:create("MVA", source.close, MF);
	MVAFirst=SMA.DATA:first();
	ATR = core.indicators:create("ATR", source, AF);
	ATRFirst=ATR.DATA:first();
	 
    CENTRAL = instance:addStream("Central", core.Line, name .. ".Central", "CL", instance.parameters.CC,  math.max(MVAFirst,ATRFirst) );
	for i=1,3,1 do
    Fibonacci[i] = instance:addStream("Fibonacci"..i, core.Line, name .. ".F"..i, "F"..i, FC[i],  math.max(MVAFirst,ATRFirst));
	Fibonacci[i]:setWidth(Width[i]);
    Fibonacci[i]:setStyle(Style[i]);
	Fibonacci[4+i] = instance:addStream("Fibonacci"..(i+3), core.Line, name .. ".F"..i, "F"..i, FC[i],  math.max(MVAFirst,ATRFirst));
	Fibonacci[4+i]:setWidth(Width[i]);
    Fibonacci[4+i]:setStyle(Style[i]);
	end
	
	first = math.max(MVAFirst,ATRFirst);
    
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
function Update(period,mode)

    
    	

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
    Activate (5, period)
    Activate (6, period)  
    Activate ( 7, period)     
     
end




 function Calculate(period, mode)
 
      
    
	
		SMA:update(mode);
		ATR:update(mode);
		
        CENTRAL[period] = SMA.DATA[period];
		local i;
		for i=1,3, 1 do
                Fibonacci[i][period] = CENTRAL[period]+ATR.DATA[period]*F[i];
		Fibonacci[4+i][period] = CENTRAL[period]-ATR.DATA[period]*F[i];
	    end
   
    
 
 end
 
 
 

function Activate (id, period)

   if   Mode ~= "Touch" then
		
	  if id ~= 4  and ON[id]    then
	  
	       
			if 	source.close[period-1] < Fibonacci[id][period-1]
			and     source.close[period] > Fibonacci[id][period]
			then
			           
						     up[id]:set(period , Fibonacci[id][period], "\108");	
						   
			
			                                    D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  end
			elseif	source.close[period-1] > Fibonacci[id][period-1]
			and     source.close[period] < Fibonacci[id][period]		
                        then			
			
			            			 
			                                 down[id]:set(period , Fibonacci[id][period], "\108");	  						   
						   
		                                         U[id] = nil;
		   
			                                  if  D[id]~=source:serial(period)
							 and period == source:size()-1
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");								   
			                                   end			   
	                end
			
	  elseif id == 4  and ON[id]  then 
	  
	       if 	source.close[period-1] < CENTRAL[period-1]
			and     source.close[period] > CENTRAL[period]
			then
			           
						     up[id]:set(period , CENTRAL[period], "\108");	
						   
			
			                                    D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  end
			elseif	source.close[period-1] > CENTRAL[period-1]
			and     source.close[period] < CENTRAL[period]		
                        then			
			
			            			 
			                                 down[id]:set(period , CENTRAL[period], "\108");	  						   
						   
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
    
    if  Mode ~= "Cross" then
    
  
                   if id ~= 4  and ON[id]    then
	  
	       
			if 	source.low[period] < Fibonacci[id][period]
			and     source.high[period] > Fibonacci[id][period]			
			then
			           
						     up[id]:set(period , Fibonacci[id][period], "\108");	
						   
			
			                                    D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Touch");
							  end
		  end
			
	        elseif id == 4  and ON[id]  then 
	  
	                if 	source.low[period] < CENTRAL[period]
			and     source.high[period] > CENTRAL[period]
			
			then
			           
						     up[id]:set(period , CENTRAL[period], "\108");	
						   
			
			                                    D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Touch");
							  end
			
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
 

  local text= profile:id() .. "(" .. source:instrument() .. ")" .. source.close[NOW]..", " .. Subject..", " .. LABEL ;
 terminal:alertEmail(Email, Subject, text);
end
	 
function AsyncOperationFinished (cookie, success, message)
end

