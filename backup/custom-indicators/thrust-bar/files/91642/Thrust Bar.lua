-- Id: 10733
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60137

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
    indicator:name("Thrust Bar");
    indicator:description("Thrust Bar");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");
	
	
	
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "ATR Period", "Period", 14);	
	indicator.parameters:addString("Method", "Method", "Method" , "ATR");
    indicator.parameters:addStringAlternative("Method", "ATR", "ATR" , "ATR");
    indicator.parameters:addStringAlternative("Method", "Pips", "Pips" , "Pips");
	
    indicator.parameters:addDouble("Multiplier", "Multiplier/Pips", "Multiplier/Pips", 2); 
	
	
	indicator.parameters:addString("Side", "Side", "Side" , "Both");
    indicator.parameters:addStringAlternative("Side", "Long", "Long" , "Long");
    indicator.parameters:addStringAlternative("Side", "Short", "Short" , "Short");
	indicator.parameters:addStringAlternative("Side", "Both", "Both" , "Both");
	
	--indicator:name("Style");
	--indicator.parameters:addColor("LabelColor", "Label Color","", core.rgb(0, 0, 255));
	
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Up Thrust Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Thrust Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	
	
	Parameters (1, "Alert")
	
end



function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);


    indicator.parameters:addFile("Up"..id, Label .. " Up Thrust Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Down Thrust Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 1;



-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Method;
local first;
local source = nil;
local ATR;
local LabelColor;
-- Streams block
local Multiplier,Side;
local name;

-- Alert

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

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Side = instance.parameters.Side;
	Method = instance.parameters.Method;
	Multiplier = instance.parameters.Multiplier;
	FIRST=true;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	source = instance.source;
    name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(Method).. ", " .. tostring(Multiplier) .. ", " .. tostring(Side).. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	if Method =="ATR" then
	ATR = core.indicators:create("ATR", source, Period);
    first = ATR.DATA:first()+1;
	else
	first = source:first()+1;
	end
	
	core.host:execute ("setStatus", name)
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
   
   
	 
     if Method =="ATR" then
     ATR:update(mode); 
	 end
   
    if period < first   then
    return;  
    end

  	
	 Activate (1, period )
	
 
end


function Activate (id, period)



   local X,Y;
   local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
	

    if Method =="ATR" then  
	X=(ATR.DATA[period]* Multiplier)/source:pipSize();
	else
	X=Multiplier;
	end
	
	Y= ((source.close[period]-source.open[period])/source:pipSize())
	
	--core.host:execute ("setStatus", X.. " " .. Y)
 
	  if id == 1  and ON[id]  then
	  
	       
			if Y > X  and Side~= "Short"
			then
			           
						     up[id]:set(period , source.low[period], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Up Thrust", period);
							    
							        if Show then
									Pop(Label[id], " Up Thrust " );  	
								    end
								 
			
             end
			end
			if   Y < -X  and Side~= "Long"
            then			
			
			            			 
			               down[id]:set(period , source.high[period], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Down Thrust ", period);	
								 if Show then
									Pop(Label[id], " Down Thrust " );  	
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
   
     local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	 
 terminal:alertEmail(Email, profile:id(), text);
end
	 
 
	

