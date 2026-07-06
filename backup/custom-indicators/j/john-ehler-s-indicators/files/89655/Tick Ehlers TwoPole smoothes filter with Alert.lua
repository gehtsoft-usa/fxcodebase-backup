
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1262

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
    indicator:name("Ehlers TwoPole smoothes filter with Alert");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
   
   
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("CuttOffPeriod", "CuttOffPeriod", "", 15);
	
	 indicator.parameters:addGroup("Indicator Style");
	  indicator.parameters:addColor("clr_Line", "Color of Line", "Color of Line", core.rgb(255, 0, 0));
	    indicator.parameters:addInteger("widthLinReg1", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg1", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg1", core.FLAG_LINE_STYLE);

	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	
	
	Parameters (1, "Price / Ehlers TwoPole smoothes filter ")

	

	
	
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

local FIRST=true;
local CuttOffPeriod;

local U={};
local D={};
local Show;
local Filter;

local BuffLine=nil;
local a1;
local b1;
local coeff1, coeff2, coeff3;

-- Routine
function Prepare(nameOnly)   
    
    source = instance.source;
	
	FIRST=true;
	  
	CuttOffPeriod = instance.parameters.CuttOffPeriod;
    Show = instance.parameters.Show;

    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. CuttOffPeriod .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
   first = source:first();
	 BuffLine = instance:addStream("BuffLine", core.Line, name .. ".BuffLine", "BuffLine", instance.parameters.clr_Line, first+4);
	BuffLine:setWidth(instance.parameters.widthLinReg1);
    BuffLine:setStyle(instance.parameters.styleLinReg1);
    a1=math.exp(-math.sqrt(2.)*math.pi/CuttOffPeriod);
    b1=2.*a1*math.cos(math.pi*math.sqrt(2.)/CuttOffPeriod);
    coeff2=b1;
    coeff3=-a1*a1;
    coeff1=1.-coeff2-coeff3;
	
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
 
   
     if period>first+4 then
      BuffLine[period]=coeff1*source[period]+coeff2*BuffLine[period-1]+coeff3*BuffLine[period-2];
     else
      BuffLine[period]=source[period];
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
	 
end

function Activate (id, period)


		
	  if id == 1  and ON[id]  then
	  
	       
			if 	source[period -1 ]<= BuffLine[period-1] 
			and source[period  ]>BuffLine[period] 
			then
			           
						     up[id]:set(period , BuffLine[period], "\108");	
						   
			               
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  if Show then
							  core.host:execute ("prompt", 1, Label[id] .." Cross Over", Label[id] .." Cross Over");
							 end	
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  end
			elseif 	source[period -1 ]>= BuffLine[period-1] 
			and source[period  ]<BuffLine[period] 		
            then			
			
			            			 
			               down[id]:set(period , BuffLine[period], "\108");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1
							 then
							  if Show then
							    core.host:execute ("prompt", 1, Label[id] .." Cross Under", Label[id] .." Cross Under");
							 end
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");								   
			                     end			   
	         end
			
       end
    

end

function AsyncOperationFinished (cookie, success, message)
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
 

  local text= profile:id() .. "(" .. source:instrument() .. ")"  .. Subject..", " .. LABEL  ;
   terminal:alertEmail(Email,  Subject, text);
end
	 
 
