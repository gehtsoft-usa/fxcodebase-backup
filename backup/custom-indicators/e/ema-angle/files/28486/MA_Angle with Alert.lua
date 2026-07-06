-- Id: 9806
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1294

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
    indicator:name("MA Angle with Alert");
    indicator:description(" Determines the angle between two MAs");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("F", "Period", "Period", 50, 2, 2000);
    indicator.parameters:addInteger("S", "Shift", "Shift", 6, 0, 2000);
	indicator.parameters:addDouble("T", "Treshold", "Treshold", 0.3 , 0, 100);
	indicator.parameters:addString("Price", "Price Source", "", "median");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
	indicator.parameters:addString("Method", "Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "HMA" , "HMA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method", "VAMA", "VAMA" , "VAMA");	
	indicator.parameters:addStringAlternative("Method", "NONLAGMA", "NONLAGMA", "NONLAGMA"); 
	indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA", "VIDYA"); 
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Top", "Color of Top", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Bottom", "Color of Bottom", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Zero", "Color of Zero", "", core.rgb(255, 215, 0));
	
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
	
	Parameters (1, "MA Angle / Central Line")
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

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame=nil;
local Shift=nil;
local Treshold = nil;
local Method;
local UP=nil;
local DOWN = nil;
local ZERO=nil;

local first;
local source = nil;

-- Streams block
local Angle = nil;
local Flag = nil;


local BC=nil;
local ZC=nil;
local TC=nil;
local Price;
local MA=nil;


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
    Method=instance.parameters.Method;
    Price=instance.parameters.Price;
    BC=instance.parameters.Bottom;
    ZC=instance.parameters.Zero;
    TC=instance.parameters.Top;

    Frame = instance.parameters.F;
    Shift = instance.parameters.S;
	Treshold = instance.parameters.T;
    source = instance.source;
    
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame ..  ", " ..  Shift .. ", " .. Treshold.. ", " .. Method .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end 
	
	
		assert(core.indicators:findIndicator(Method) ~= nil, "Please, download and install " ..  Method ..".LUA indicator");
		
  
		
    if Method == "VAMA" then

	 	local p;
				 if Price == "open" then
					p = "O";
				elseif Price == "high" then
					p = "H";
				elseif Price == "low" then
					p = "L";
				elseif Price == "close" then
					p = "C";
				elseif Price == "median" then
					p = "M";
				elseif  Price == "weighted" then
					p = "W";
				 elseif  Price == "typical" then
				  p = "T"
   			  end
	
	
	MA = core.indicators:create(Method, source, Frame, p);
	else
	MA = core.indicators:create(Method, source[Price], Frame);
	end
	
	first = MA.DATA:first();
	
    Angle = instance:addStream("Angle", core.Bar, name, "Angle", TC, first);
    Angle:setPrecision(math.max(2, instance.source:getPrecision()));
	
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
 
   MA:update(mode);
  
    if period < Frame + Shift  or not  source:hasData(period)  then
	return;
	end
        	      
      Angle[period] = ( MA.DATA[period] - MA.DATA[period-Shift])/ source:pipSize();	  
	
      
      if Angle[period] >= Treshold then
       Angle:setColor(period,TC);
      elseif Angle[period] <=  -Treshold then
        Angle:setColor(period,BC);
      else 
	    Angle:setColor(period,ZC);
	  end	
	  
 end
 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)


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
    
end



function Activate (id, period)


		
	  if id == 1  and ON[id]  then
	  
	       
			if 	Angle[period-1] < 0
			and Angle[period] >  0
			then
			           
						     up[id]:set(period , 0, "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] , " Cross Over", period);
							  end
			elseif	Angle[period-1] > 0 
			and  Angle[period] <  0			
            then			
			
			            			 
			               down[id]:set(period , 0, "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);								   
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

 


function EmailAlert( label , Subject, period)

if not SendEmail then
return
end
  
    local date = source:date(period);
	local DATA = core.dateToTable (date);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. "  " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
    
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
 
	
 
   terminal:alertEmail(Email, profile:id(), text);
end


function AsyncOperationFinished (cookie, success, message)
end