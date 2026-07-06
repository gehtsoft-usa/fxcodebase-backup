-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59547
-- Id: 10028

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
function Init()
    indicator:name("Extreme Candle Range Alert");
    indicator:description("Extreme Range Alert");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addString("Method", "Range Type", "" , "Close/Open");
    indicator.parameters:addStringAlternative("Method", "Close/Open", "Close/Open" , "Close/Open");
    indicator.parameters:addStringAlternative("Method", "High/Low", "High/Low" , "High/Low");
	indicator.parameters:addDouble("Min", "Min Level", "", 10 );
	indicator.parameters:addDouble("Max", "Max Level", "", 110);
	indicator.parameters:addDouble("Delta", "Delta", "", 0);
	
	indicator.parameters:addBoolean("Live", "Live", "", false);	
	
	indicator.parameters:addGroup("MA Filter Calculation");	
	indicator.parameters:addBoolean("Filter", "Use MA Filter", "", false);	
	
	indicator.parameters:addInteger("MAPeriod", "Period", "Period", 14);
	indicator.parameters:addString("MAMethod", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("MAMethod", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MAMethod", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("MAMethod", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MAMethod", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MAMethod", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MAMethod", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MAMethod", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MAMethod", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	
	
	Parameters (1, "High Line ", true);
	Parameters (2, "Low Line ", true);
	Parameters (3, "High Extreme ", true);
	Parameters (4, "Low Extreme ", true);
	

end

function Parameters ( id, Label, Flag )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", Flag);


    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
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
local Line;
local up={};
local down={};
local Size;
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local Min, Max;
local Alert;
local Indicator;
local PlaySound;

local FIRST=true;

local U={};
local D={};

local Color, Period;
local Method;
local first;
local source = nil;
local ATR;
-- Streams block
local Ratio;
local Delta;
local Filter;
local Live;
local Shift;
local MAPeriod, MAMethod,MA;
-- Routine
function Prepare(nameOnly)
    Color= instance.parameters.Color;
	Min= instance.parameters.Min;
	Max= instance.parameters.Max;
	Method= instance.parameters.Method;
	Period= instance.parameters.Period;
	Delta= instance.parameters.Delta;
	Filter= instance.parameters.Filter;
	
	MAPeriod = instance.parameters.MAPeriod;
	MAMethod= instance.parameters.MAMethod;
	Live= instance.parameters.Live;
    source = instance.source;
	
	FIRST=true
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(Method) .. ")";
    instance:name(name);
	
    if (not (nameOnly)) then
		ATR = core.indicators:create("ATR", source, Period);
    assert(core.indicators:findIndicator(MAMethod) ~= nil, MAMethod .. " indicator must be installed");
		MA = core.indicators:create(MAMethod, source.close, MAPeriod);
		first = math.max(ATR.DATA:first(), MA.DATA:first());
        Ratio  = instance:addInternalStream(0, 0);
		Initialization();
    end
	
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
function Update(period, mode)

 ATR:update(mode);
 MA:update(mode);

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
   
   if Filter and not ((source.close[period-1 ] >= MA.DATA[period-1] and source.close[period ] < MA.DATA[period])
   or (source.close[period-1 ] <= MA.DATA[period-1] and source.close[period ] > MA.DATA[period]))
   then
   return;	
   end
   
   if not Live then
   period=period-1;
   Shift=1;
   else
   Shift=0;
   end
	
	Activate (1, period)
	Activate (2, period)
	Activate (3, period)
	Activate (4, period) 
  
end

function Activate (id, period)


		
	  if id == 1  and ON[id]  then
	  
	       
			if  Ratio[period-1] < Max
			and Ratio[period] >  Max
			then
			           
						     up[id]:set(period , source.high[period]+source:pipSize()*Delta, "\108", tostring(Ratio[period]));	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1 -Shift
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  end
			elseif  Ratio[period-1] > Max
			and Ratio[period] <  Max		
            then			
			
			            			 
			               down[id]:set(period , source.high[period]+source:pipSize()*Delta, "\108", tostring(Ratio[period]));	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1 -Shift
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");								   
			                     end			   
	         end
			
	elseif id == 2  and ON[id]  then
	  
	       
			if  Ratio[period-1] < Min
			and Ratio[period] >  Min		
			then
			           
						     up[id]:set(period , source.low[period]- source:pipSize()*Delta, "\108",tostring(Ratio[period]));	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1 -Shift
							  then
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Cross Over");
							  end
			elseif  Ratio[period-1] > Min
			and Ratio[period] <  Min		
            then			
			
			            			 
			               down[id]:set(period , source.low[period]- source:pipSize()*Delta, "\108", tostring(Ratio[period]));	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1 -Shift
							 then
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Cross Under");								   
			                     end			   
	         end
	end		
	if id == 3  and ON[id]  then
	  
	       
			if  Ratio[period-1] >  Max
			then
			           
						     up[id]:set(period-1 , source.high[period-1]+source:pipSize()*Delta, "\108",tostring(Ratio[period-1]));	
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period-1) 
							  and period == source:size()-1 -Shift
							  then
							  U[id]=source:serial(period-1);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Zone");
							  end
			end
			
	end
	if id == 4  and ON[id]  then
	  
	       
			if  Ratio[period-1] < Min
				
            then			
			
			            			 
			               down[id]:set(period-1 , source.low[period-1]-source:pipSize()*Delta, "\108",tostring( Ratio[period-1]));	  						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period-1)
							 and period == source:size()-1 -Shift
							 then
							 D[id]=source:serial(period-1);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] .. " Zone");								   
			                 end			   
	         end
			
	end        
	
end

function Calculate (period, mode)
   
	
	local X;
	
	if Method ==  "Close/Open" then
	X= math.abs(source.open[period]- source.close[period]);
	else
	X= source.high[period]- source.low[period];
	end
	
	
	
    Ratio[period] = X/(ATR.DATA[period]/100);
   
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
 

   local text = profile:id() .. "(" .. source:instrument() .. ")"  .. Subject..", " .. LABEL;
   
   terminal:alertEmail(Email, Subject, text);
end
	 

function AsyncOperationFinished (cookie, success, message)
end

