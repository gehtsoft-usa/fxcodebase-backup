-- Id: 7922
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2431

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
    indicator:name("MASO with Alert");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
   
   
   indicator.parameters:addGroup("First MA Slope Parameters ");
	indicator.parameters:addString("Price1", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");	
    indicator.parameters:addInteger("First_Period", " First MA Period", "", 25);
    indicator.parameters:addString("First_Method", "Method of First MA", "", "EMA");
    indicator.parameters:addStringAlternative("First_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("First_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("First_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("First_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("First_Method", "TMA", "", "TMA");
	indicator.parameters:addStringAlternative("First_Method", "HMA", "", "HMA");
    indicator.parameters:addDouble("First_Slope", "Slope", "pip/minute", 0);
    indicator.parameters:addInteger("First_Bars", "Bars", "", 1);

	
	
	indicator.parameters:addGroup("Second MA Slope Parameters ");
	indicator.parameters:addString("Price2", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");	
     indicator.parameters:addInteger("Second_Period", " Second MA Period", "", 50);
    indicator.parameters:addString("Second_Method", "Method of Second MA", "", "EMA");
    indicator.parameters:addStringAlternative("Second_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Second_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Second_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Second_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Second_Method", "TMA", "", "TMA");
	indicator.parameters:addStringAlternative("Second_Method", "HMA", "", "HMA");
    indicator.parameters:addDouble("Second_Slope", "Slope", "pip/minute", 0);
    indicator.parameters:addInteger("Second_Bars", "Bars", "", 1);
	
	
	 indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up_color", "Color of Up", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down_color", "Color of Down", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Contradictory_color", "Color of Contradictory", "", core.rgb(255, 128, 0));
	indicator.parameters:addColor("Flat_color", "Color of Flat", "", core.rgb(128, 128, 128));


	
	indicator.parameters:addGroup("Alert Style");  
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	
	
	Parameters (1, "Up", core.rgb(0, 255, 0))
	Parameters (2, "Down", core.rgb(255, 0, 0))
	Parameters (3, "Contradictory", core.rgb(255, 128, 0))
	Parameters (4, "Flat", core.rgb(128, 128, 128))

	
	
end

function Parameters ( id, Label, Color )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", false);


    indicator.parameters:addFile("Sound"..id, Label .. " Sound", "", "");
    indicator.parameters:setFlag("Sound"..id, core.FLAG_SOUND);
	
	indicator.parameters:addColor("Color"..id, Label.. "Color", "", Color);

	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 4;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Sound={};
local Color={};
local Label={};
local ON={};
local first;
local source = nil;
local Line;
local Size;
local Email;
local SendEmail;
local RecurrentSound ,SoundFile  ;
local Price1, Price2;
local Alert;
local Symbol={};
local PlaySound;

local indicator1;
local indicator2;
local FIRST= false;
local open=nil;
local close=nil;
local high=nil;
local low=nil;
 
local A={};
local Keep;

local First_Period,First_Method,First_Slope,First_Bars, Second_Period,Second_Method,Second_Slope,Second_Bars;
local Flat_color,Contradictory_color,Up_color,Down_color;


-- Routine
function Prepare(nameOnly)   
    
    source = instance.source;
	FIRST= true;
    Flat_color = instance.parameters.Flat_color;
	Contradictory_color = instance.parameters.Contradictory_color;
	Up_color = instance.parameters.Up_color;
	Down_color = instance.parameters.Down_color;
	
    First_Period = instance.parameters.First_Period;
    First_Method = instance.parameters.First_Method;
    First_Slope = instance.parameters.First_Slope;
    First_Bars = instance.parameters.First_Bars;
	
	Second_Period = instance.parameters.Second_Period;
    Second_Method = instance.parameters.Second_Method;
    Second_Slope = instance.parameters.Second_Slope;
    Second_Bars = instance.parameters.Second_Bars;
	
	Price1 = instance.parameters.Price1;
	Price2 = instance.parameters.Price2;
	
	assert(core.indicators:findIndicator("MA_SLOPE") ~= nil, "Please, download and install MA_SLOPE");

	
    local name = profile:id() .. "(" .. source:name() .. ", " .. First_Period .. ", "..First_Method.. ", "..First_Slope.. ", "..First_Bars.. ", ".. Second_Period ..", ".. Second_Method .. ", "..  Second_Slope..", " .. Second_Bars.. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	Keep = instance:addInternalStream(source:first(), 0);
	
	open = instance:addStream("open", core.Line, name, "open", Flat_color, source:first())
    high = instance:addStream("high", core.Line, name, "high", Flat_color, source:first())
    low = instance:addStream("low", core.Line, name, "low", Flat_color, source:first())
    close = instance:addStream("close", core.Line, name, "close", Flat_color, source:first())
    instance:createCandleGroup("ZONE", "", open, high, low, close);
	
	
	
	
	indicator1=core.indicators:create("MA_SLOPE", source[Price1], First_Period,First_Method , First_Slope, First_Bars, Up_color,Down_color, Flat_color);
	indicator2=core.indicators:create("MA_SLOPE", source[Price2], Second_Period,Second_Method , Second_Slope, Second_Bars, Up_color,Down_color, Flat_color);
	
	first=math.max(indicator1.DATA:first(),indicator2.DATA:first())

	
	Initialization();
  
end


function  Initialization ()
     Size=instance.parameters.Size;
	 SendEmail = instance.parameters.SendEmail;
	 
	 local i;
	 for i = 1, Number , 1 do 
	  Label[i]=instance.parameters:getString("Label" .. i);
	  ON[i]=instance.parameters:getBoolean("ON" .. i);
	 Sound[i]=instance.parameters:getString("Sound" .. i);
	  Color[i]=instance.parameters:getInteger("Color" .. i);
	  
	
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
	  Sound[i]=instance.parameters:getString("Sound" .. i);
	  end
	
    else 
	
	  for i = 1, Number , 1 do 
       Sound[i]=nil;
	  end
		
    end
    
        for i = 1, Number , 1 do 
	  
	 assert(not(PlaySound) or (PlaySound and Sound[i] ~= "") or (PlaySound and Sound[i] ~= ""), "Sound file must be chosen");
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	A[i] = nil;	
	end
		
	

	
end	


 function Calculate(period, mode)
 
     high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];	 
	

       if period < first and source:hasData(period) then
	   
	   open:setColor(period, Flat_color);	
	
	   Keep[period]=Flat_color;
	   return;
	   end
	
	   indicator1:update(mode);
	   indicator2:update(mode);
	   
	   if period < first then
	   return;
	   end
	   
			
							if  indicator1.DATA:colorI(period) ==  Up_color
                            and   indicator2.DATA:colorI(period) ==  Up_color	
							then
							 open:setColor(period, Up_color);	
							
							 Keep[period]=Up_color;
							 
							elseif   indicator1.DATA:colorI(period) ==  Down_color
                            and   indicator2.DATA:colorI(period) == Down_color
							then 
							
							 open:setColor(period, Down_color);	
							
							Keep[period]=Down_color;
							else 
							 open:setColor(period, Contradictory_color);	
                           
                             Keep[period]=Contradictory_color;							
							end
				 				 
			
 
 end
 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 

    Calculate(period, mode);
	

	
    Activate (1, period)
	Activate (2, period)
	Activate (3, period)
	Activate (4, period)
end


function Activate (id, period)


		
	  if id == 1   then
	  
	  
				 
				   
					if 	Keep[period] == Up_color					
					then
					
					
					A[2] = nil;
					 A[3] = nil;
					 A[4] = nil;
					 
					 if  ON[id] then
							   
								
								   
					
								   
									  if A[id]~=true 
									  and period == source:size()-1
									  then
									  A[id]=true ;
									  SoundAlert(Sound[id]);
									  EmailAlert(  Label[id] .." Alert");
									  end
									  
				  end
		  end
		end	  
		

		 if id == 2  then	
		     
		   
				if 	Keep[period] ==  Down_color			
				then
				
				A[1] = nil;
		    	A[3] = nil;
		    	A[4] = nil;
				
				 if ON[id]  then
							   
							
					
								   
									  if A[id]~=true 
									  and period == source:size()-1
									  then
									  A[id]=true ;
									  SoundAlert(Sound[id]);
									  EmailAlert(  Label[id] .." Alert");
									  end
				end
		end
	end
	
	if id == 3 then
	
	       
	
	
      
				
				if 	Keep[period] == Contradictory_color			
				then
				
				
			A[1] = nil;
			 A[2] = nil;
			 A[4] = nil;
			 
			   if  ON[id]  then	
							   
					        
					
								   
									  if A[id]~=true 
									  and period == source:size()-1
									  then
									  A[id]=true ;
									  SoundAlert(Sound[id]);
									  EmailAlert(  Label[id] .." Alert");
									  end
				end
		end
	end

	 if id == 4   then
	 
	     
	 
						
				if 	Keep[period] ==  Flat_color				
				then
				
				
				    A[1] = nil;
					 A[2] = nil;
					 A[3] = nil;
					 
					 if  ON[id] then	
							   
								
								   
					
								   
									  if A[id]~=true 
									  and period == source:size()-1
									  then
									  A[id]=true 
									  SoundAlert(Sound[id]);
									  EmailAlert(  Label[id] .." Alert");
									  end										  
				end
			 end 
	
	   
    end

end

function SoundAlert(Sound)

 if FIRST then
 FIRST=false;
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
 

  local text=  profile:id() .. "(" .. source:instrument() .. ")"  .. Subject..", " .. LABEL ;
 terminal:alertEmail(Email, Subject, text);
end
	 

