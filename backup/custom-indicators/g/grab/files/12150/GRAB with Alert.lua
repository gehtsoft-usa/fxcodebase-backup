-- Id: 10142

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4893

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
    indicator:name("Grab Candles");
    indicator:description("Grab Candles");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("MA"); 
    indicator.parameters:addInteger("Period", "Period", "Period", 34);   
	
		indicator.parameters:addString("Method", "Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addBoolean("Show", "Show MA Lines", "", true);
    indicator.parameters:addColor("Short_Up", "Color of Down Trend Up", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Short_Down", "Color of Down Trend Down", "", core.rgb(200, 0, 0));
    indicator.parameters:addColor("Long_Up", "Color of Up Trend Up", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("Long_Down", "Color of Up Trend Down", "", core.rgb(0, 200, 0));
    indicator.parameters:addColor("Range_Up", "Color of Range Up", "", core.rgb(128, 128, 128));
	indicator.parameters:addColor("Range_Down", "Color of Range Down", "", core.rgb(100, 100, 100));
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Neutral", "Neutral Trend Color", "", core.rgb(255, 128, 0));
	indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts");  
	indicator.parameters:addBoolean("ShowDialog", "Show Dialog box Alert", "", true);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	
	
	Parameters (1, "GRAB Indicator Alert")
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block


function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", false);


    indicator.parameters:addFile("Up"..id, Label .. " Up Trend Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Neutral"..id, Label .. " Neutral Trend Sound", "", "");
    indicator.parameters:setFlag("Neutral"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Down Trend Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local Up={};
local Neutral={};
local Down={};
local Label={};
local ON={};
local Line;
local up={};
local neutral={};
local down={};
local Size;
local Email;
local SendEmail;
local RecurrentSound ,SoundFile  ;
local ShowDialog;
local Alert;
local Indicator;
local PlaySound;

local FIRST=true;
local U={};
local D={};
local N={};

local 	Number = 1;
local Period;

local first;
local source = nil;

-- Streams block
local Open = nil;
local Close = nil;
local High = nil;
local Low = nil;

local Method;


local MA={};
local OUT={};

local Show;
-- Routine
function Prepare(nameOnly) 
    Period = instance.parameters.Period;
	ShowDialog = instance.parameters.ShowDialog;
    source = instance.source;
	Show = instance.parameters.Show;
	Method = instance.parameters.Method;
    
    FIRST=true;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. Method .. ", " .. Period .. ")";
    instance:name(name);
   
    if   (nameOnly) then
        return;
    end
	
		 
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	 MA["High"] =   core.indicators:create(Method, source.high, Period);	 
	 MA["Low"] =   core.indicators:create(Method, source.low, Period);	 
	 MA["Close"] =   core.indicators:create(Method, source.close, Period);	 
	 
	 first = MA["Low"].DATA:first();
	 
	  Open = instance:addStream("O", core.Line, name .. ".Open", "Open", core.rgb(0, 0, 0), first);
    Close = instance:addStream("C", core.Line, name .. ".Close", "Close", core.rgb(0, 0, 0), first);
    High = instance:addStream("H", core.Line, name .. ".High", "High", core.rgb(0, 0, 0), first);
    Low = instance:addStream("L", core.Line, name .. ".Low", "Low", core.rgb(0, 0, 0), first);
	
	 instance:createCandleGroup("ZONE", "", Open, High, Low, Close);
	
	if Show then
	OUT["High"] = instance:addStream("High", core.Line, name .. ".High", "High", instance.parameters.Short_Up, first);
    OUT["Low"] = instance:addStream("Low", core.Line, name .. ".Low", "Low", instance.parameters.Long_Up, first);
    OUT["Close"] = instance:addStream("Close", core.Line, name .. ".Close", "Close", instance.parameters.Range_Up, first);
	else
	
	OUT["High"] =  instance:addInternalStream (0, 0);
    OUT["Low"] =  instance:addInternalStream (0, 0);
    OUT["Close"] =  instance:addInternalStream (0, 0);
	
	end
   
	 Initialization();
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period < first or not source:hasData(period) then
	return;
	end
	
  
    Calculate(period, mode);
	
	
	local i;
	for i = 1, Number , 1 do
		  if ON[i] then
		 down[i]:setNoData (period); 
		 up[i]:setNoData (period);
		 neutral[i]:setNoData (period);
		 end
   end	 
	
    Activate (1, period);
	
  
end

 function Calculate(period, mode)
 
 	MA["High"]:update(mode);
	MA["Low"]:update(mode);
	MA["Close"]:update(mode);
	
	OUT["High"][period]= MA["High"].DATA[period];
	OUT["Low"][period]= MA["Low"].DATA[period];
	OUT["Close"][period]= MA["Close"].DATA[period];	
	
	    Open[period] = source.open[period];
        Close[period] = source.close[period];
        High[period] = source.high[period];
        Low[period] = source.low[period];
	
	
	if source.open[period]<= source.close[period] and source.close[period] > MA["High"].DATA[period] then
	
       Open:setColor(period, instance.parameters.Long_Up);
	elseif 	source.open[period] >= source.close[period] and source.close[period] > MA["High"].DATA[period] then
	
	 Open:setColor(period, instance.parameters.Long_Down);
		
	end	
	
	
	if source.open[period]<= source.close[period] and source.close[period] < MA["Low"].DATA[period] then
	
       Open:setColor(period, instance.parameters.Short_Up);
	elseif 	source.open[period] >= source.close[period] and source.close[period] < MA["Low"].DATA[period] then
	
	Open:setColor(period, instance.parameters.Short_Down);
	end	
    
	
	if source.open[period]<= source.close[period] and source.close[period] < MA["High"].DATA[period] and source.close[period] > MA["Low"].DATA[period] then
	
       Open:setColor(period, instance.parameters.Range_Up);
	elseif 	source.open[period] >=source.close[period] and source.close[period] < MA["High"].DATA[period] and source.close[period] > MA["Low"].DATA[period] then
	
	Open:setColor(period, instance.parameters.Range_Down);
		
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
	  Neutral[i]=instance.parameters:getString("Neutral" .. i);
	  end
	
    else 
	
	  for i = 1, Number , 1 do 
       Up[i]=nil;
	   Neutral[i]=nil;
	  Down[i]=nil;
	  end
		
    end
    
        for i = 1, Number , 1 do 
	  assert(not(PlaySound) or (PlaySound and Up[i] ~= "") or (PlaySound and Up[i] ~= ""), "Sound file must be chosen"); 
	   assert(not(PlaySound) or (PlaySound and Neutral[i] ~= "") or (PlaySound and Neutral[i] ~= ""), "Sound file must be chosen"); 
	 assert(not(PlaySound) or (PlaySound and Down[i] ~= "") or (PlaySound and Down[i] ~= ""), "Sound file must be chosen");
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	U[i] = nil;
	N[i] = nil;
	D[i] = nil;
	
		if ON[i] then
		up[i] = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Up, 0);
		neutral[i] = instance:createTextOutput ("Neutral", "Neutral", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Neutral, 0);
		down[i] = instance:createTextOutput ("Down", "Down", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Down, 0);
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
 

  local text=  profile:id() .. "(" .. source:instrument() .. ")"  .. Subject..", " .. LABEL ;
  terminal:alertEmail(Email, Subject, text);
end
	 




function Activate (id, period)


		
	  if id == 1  and ON[id]  then
	  
	       
			if   source.close[period] > MA["High"].DATA[period]
			and  source.close[period-1] <= MA["High"].DATA[period-1]
			then
			           
						     up[id]:set(period ,  MA["Close"].DATA[period], "\108");	
						   
			
			 D[id] = nil;
			 N[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  
									if ShowDialog then
								  core.host:execute ("prompt", 1,   profile:id(), "(" .. source:instrument()  .." / " .. source:barSize() .. ") ".. Label[id] .." Cross Over");
								 end	
								 
							 
							 
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id] .." Up Trend");
							  end
		 elseif   source.close[period] < MA["Low"].DATA[period]
			and  source.close[period-1] >= MA["Low"].DATA[period-1]
			then
			           
						     down[id]:set(period ,  MA["Close"].DATA[period], "\108");	
						   
			
			 U[id] = nil;
			 N[id] = nil;
						   
							  if D[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  
									if ShowDialog then
								   core.host:execute ("prompt", 1,   profile:id(), "(" .. source:instrument()  .." / " .. source:barSize() .. ") ".. Label[id] .." Cross Under");
								 end	
							  D[id]=source:serial(period);
							  SoundAlert(Down[id]);
							  EmailAlert(  Label[id] .." Down Trend");
							  end
     
	  
	       
		 elseif   source.close[period] > MA["Low"].DATA[period]
			and  source.close[period] < MA["High"].DATA[period]
			and ( source.close[period-1] <= MA["Low"].DATA[period-1]
			or  source.close[period-1] >= MA["High"].DATA[period-1])
			then
			           
						     neutral[id]:set(period , MA["Close"].DATA[period], "\108");	
						   
			
			 U[id] = nil;
			 D[id] = nil;
						   
							  if N[id]~=source:serial(period) 
							  and period == source:size()-1
							  then
							  
							  if ShowDialog then
								   core.host:execute ("prompt", 1,   profile:id(), "(" .. source:instrument()  .." / " .. source:barSize() .. ") ".. Label[id] .." Neutral Trend");
								 end	 
								 
								 
							  N[id]=source:serial(period);
							  SoundAlert(Neutral[id]);
							  EmailAlert(  Label[id] .." Neutral Trend");
							  end
							 
        end							  
   end
end


function AsyncOperationFinished (cookie, success, message)
end