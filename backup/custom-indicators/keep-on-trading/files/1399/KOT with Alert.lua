-- Id: 8863
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=760

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
    indicator:name("Keep On Trading Overlay");
    indicator:description("Keep On Trading");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "ATR Period", "Period", 10);
	indicator.parameters:addInteger("LWMA", "LWMA Period", "Period", 3);
	indicator.parameters:addDouble("Multiplier", "Multiplier", "Multiplier", 0.1);
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("UpColor", "Color of Up Trend", " ", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DownColor", "Color of Down Trend", " ", core.rgb(255, 0, 0));
	indicator.parameters:addColor("NeutralColor", "Color of Neutral Trend", " ", core.rgb(128, 128, 128));
	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
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
	
	
	Parameters (1, "Cross")

	
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

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local U={};
local D={};
local 	Number = 1;
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

local Alert;
local PlaySound;

local FIRST=true;

local Period, LWMA;
local UpColor, DownColor, NeutralColor;
local first;
local source = nil;

-- Streams block
local  KOT=nil;

local KOTL;
local KOTH;

local HIGH;
local LOW;
local ATR;

local flag;

local signal;
   
local  KOTH;
local  KOTL;

local HLWMA;
local LLWMA;
local Multiplier;
-- Routine
function Prepare(nameOnly)

    FIRST=true;
    Period = instance.parameters.Period;
	LWMA = instance.parameters.LWMA;
    source = instance.source;
    Multiplier = instance.parameters.Multiplier;
	
	UpColor=instance.parameters.UpColor;
	DownColor=instance.parameters.DownColor;
	NeutralColor=instance.parameters.NeutralColor;
	
    local name = profile:id() .. " (" .. source:name() .. ", " .. Period .. ", " .. LWMA..   ", " .. Multiplier..")";
	instance:name(name);
	if nameOnly then
		return;
	end
   
	ATR = core.indicators:create("ATR", source, Period);
	HLWMA = core.indicators:create("LWMA", source.high, LWMA);
    LLWMA = core.indicators:create("LWMA", source.low, LWMA);
	
	first= math.max(ATR.DATA:first(), LLWMA.DATA:first())
    KOT = instance:addStream("KOT", core.Line, name, "KOT", NeutralColor, first);
	KOT:setWidth(instance.parameters.width);
    KOT:setStyle(instance.parameters.style);
	
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
 
 
   
	 KOT:setColor(period, Neutral);	

     ATR:update(mode); 
	 HLWMA:update(mode); 
	 LLWMA:update(mode); 
	 
    if period <  first then
	return;
	end
	
          
          if(source.close[period] < source.low[period-1] and source.close[period] < source.low[period-2]) then
		  flag =-1;
		  end
		  
		   if(source.close[period] > source.high[period-1] and source.close[period] > source.high[period-2]) then
		  flag =1;
		  end
		  		  
		  
		  HIGH=HLWMA.DATA[period];
		  LOW= LLWMA.DATA[period];
		  
		 
		     KOTH=HIGH +Multiplier*  ATR.DATA[period];
             KOTL=LOW -Multiplier* ATR.DATA[period];
			 
			
        
			 if flag == 1 then
			 signal = KOTL; 
			 end
		 
		     if flag == -1 then
		     signal = KOTH;	           	 		   
             end
			
			 KOT[period]=signal;
			 
		   
		   
		if source.close[period] >  KOT[period] then		 
		KOT:setColor(period, UpColor);
		elseif source.close[period] <  KOT[period] then
		KOT:setColor(period, DownColor);
        else
		KOT:setColor(period, NeutralColor);
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
	  
	       
			if 	source.close[period-1] < KOT[period-1]
			and  source.close[period] > KOT[period]
			then
			           
						     up[id]:set(period , KOT[period], "\108");	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  end
			elseif 	source.close[period-1] > KOT[period-1]
			and  source.close[period] < KOT[period]	
            then			
			
			            			 
			               down[id]:set(period , KOT[period], "\108");	  						   
						   
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

--********************************************************************************************************
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
 

  local text= profile:id() .. "(" .. source:instrument() .. ")"  .. Subject..", " .. LABEL ;
    terminal:alertEmail(Email,Subject, text);
end
	 
function AsyncOperationFinished (cookie, success, message)
end

