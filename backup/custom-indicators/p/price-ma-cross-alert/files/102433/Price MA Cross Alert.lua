-- Id: 14833
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59311

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
    indicator:name("Price MA Cross Alert");
    indicator:description("");
    indicator:setTag("AllowAllSources", "y");
    indicator:type(core.Indicator);
	
	
	 indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");
   
   
    indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addString("Price", "Price Source (If Bar is Used)", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
	
    indicator.parameters:addInteger("MP", "MA Period", "", 14);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "DEMA" , "DEMA");
	indicator.parameters:addStringAlternative("Method", "TEMA", "TEMA" , "TEMA");  
	indicator.parameters:addStringAlternative("Method", "PAR_MA", "PAR_MA" , "PAR_MA");  
    indicator.parameters:addStringAlternative("Method", "VAMA", "VAMA" , "VAMA")
	
	 indicator.parameters:addGroup("Indicator Style");   
    indicator.parameters:addColor("MA_color", "MA color", "(MA Color) Blue", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("MA_width", "MA Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("MA_style", "MA Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("MA_style", core.FLAG_LINE_STYLE);
	
	


	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	 indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	
	
	Parameters (1, "Price / MA Line")
 
	

	
	
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
local OnlyOnce;
local OnlyOnceFlag= true;
local FIRST=true;
 
local Live;
local U={};
local D={};

local Method, MP;
local  MA, ma;
local Price; 

-- Streams block
 
-- Routine
function Prepare(nameOnly)    
    
    Live = instance.parameters.Live;
	OnlyOnceFlag= true
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	Method = instance.parameters.Method;	
	

    MP = instance.parameters.MP;
	Price = instance.parameters.Price;
	
	if instance.source:isBar() and Method~= "VAMA" then
        source = instance.source[Price];
    elseif instance.source:isBar() and Method== "VAMA" then	    
        source = instance.source;
	elseif not instance.source:isBar()  then
	    source = instance.source;
    end
	 
		   -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. Method .. ", " .. MP .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator( Method ) ~= nil, "Please, download and install ".. Method .. ".LUA indicator");
	
	if not instance.source:isBar() and Method == "VAMA" then
	error("VAMA requires Bar Source" );
	end
	
	
	 
	 

	
	 -- Create short and long EMAs for the source
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    ma = core.indicators:create(Method, source, MP);
	

    MA = instance:addStream("MA", core.Line, name .. ".MA", "MA", instance.parameters.MA_color,  ma.DATA:first());
	MA:setWidth(instance.parameters.MA_width);
    MA:setStyle(instance.parameters.MA_style);
	   
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
 
   
	
	 ma:update(mode);

	 if ma.DATA:first()> period then
	return;
	end
	
	MA[period]= ma.DATA[period];
 
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
   
   if period < ma.DATA:first()+1 then
return;
end
	
    Activate (1, period);
 
end

function Activate (id, period)


	local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
	
	  if id == 1  and ON[id]  then
	  
	    if source:isBar() then   
			if 	source.close[period-1] <= MA[period-1]
			and source.close[period] > MA[period ]
			then
			           
						     up[id]:set(period , MA[period], "\225");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  OnlyOnceFlag=false;
							  end
							  
							  
							 
			elseif 	source.close[period-1] >= MA[period-1]
			and source.close[period ] < MA[period ]	
            then			
			
			            			 
			               down[id]:set(period , MA[period], "\226");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period ==source:size()-1-Shift
							 and not FIRST 
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");	
                             OnlyOnceFlag=false;							 
			                     end			   
	         end
		else
		
		      if 	source[period-1] <= MA[period-1]
			and source[period] > MA[period ]
			then
			           
						     up[id]:set(period , MA[period], "\225");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  OnlyOnceFlag=false;
							  end
							  
							  
							 
			elseif 	source[period-1] >= MA[period-1]
			and source[period ] < MA[period ]	
            then			
			
			            			 
			               down[id]:set(period , MA[period], "\226");	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period ==source:size()-1-Shift
							 and not FIRST 
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");	
                             OnlyOnceFlag=false;							 
			                     end			   
	         end
        end		
	  
	 
	  end
	  
		   
       
        if FIRST then
        FIRST=false;      
        end		

end

function SoundAlert(Sound)
 if not PlaySound then
 return;
 end
 
 if OnlyOnce and OnlyOnceFlag== false then
 return;
 end

 
 terminal:alertSound(Sound, RecurrentSound);
end
 

function EmailAlert( Subject)

if not SendEmail then
return
end

 if OnlyOnce and OnlyOnceFlag== false then
 return;
 end
 
    local date = source:date(NOW);
	local DATA = core.dateToTable (date);
	
    local label =  DATA.month..", ".. DATA.day ..", ".. DATA.hour  ..", ".. DATA.min ..", ".. DATA.sec;
 

  local text =  profile:id() .. "(" .. source:instrument() .. ")"  .. Subject..", " .. label;
  terminal:alertEmail(Email, Subject, text);
 
end
	 

