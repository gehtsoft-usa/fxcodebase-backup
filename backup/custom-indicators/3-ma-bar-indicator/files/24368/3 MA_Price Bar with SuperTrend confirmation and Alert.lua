-- Id: 13631

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=9634

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
    indicator:name("3 MA_Price Bar with SuperTrend confirmation and Alert");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");  
	
	
    indicator.parameters:addGroup("Three MA Calculation");
    indicator.parameters:addInteger("P1", "1. Period", "1. Period", 34);
    indicator.parameters:addInteger("P2", "2. Period", "2. Period", 68);
    indicator.parameters:addInteger("P3", "3. Period", "3. Period", 102);
	indicator.parameters:addString("Price", "Price Type", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");
	
	indicator.parameters:addGroup("Super Trend Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "No description", 10);
    indicator.parameters:addDouble("M", "Multiplier", "No description", 1.5);
	
	indicator.parameters:addString("Type", "Smoothing type", "", "EMA");
    indicator.parameters:addStringAlternative("Type", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("Type", "EMA", "EMA", "EMA");
	indicator.parameters:addStringAlternative("Type" , "LWMA", "", "LWMA");	
	indicator.parameters:addStringAlternative("Type" , "KAMA", "", "KAMA");	
	indicator.parameters:addStringAlternative("Type" , "SMMA", "", "SMMA");	
	indicator.parameters:addStringAlternative("Type" , "TMA", "", "TMA");	
	indicator.parameters:addStringAlternative("Type" , "VIDYA", "", "VIDYA");	
	indicator.parameters:addStringAlternative("Type" , "WMA", "", "WMA");	
				
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Color for Up Trend", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Dn", "Color for Down Trend", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Color for No Trend", "", core.rgb(255, 255, 0));
	 indicator.parameters:addInteger("Size", "Arrow Size", "", 10);
	 
	 indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	
	
	Parameters (1, "Trend") 
end

function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);
    indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	

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
local P1;
local P2;
local P3;
local Type;

local Size;

local first;
local source = nil;
local N;
local M;
local Live;
-- Streams block
local Indicator={};
local Out = nil;
local Price;

local up, down;

local Up={};
local Down={};
local Label={};
local ON={};
local Size;
local Email;
local SendEmail;
local  RecurrentSound ,SoundFile  ;
local Show;
local Alert;
local PlaySound;
local Live;
local FIRST=true;
local OnlyOnce;
local U={};
local D={}; 
local OnlyOnceFlag;  
local ShowAlert;
-- Routine
function Prepare(nameOnly)

    OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	
    Price= instance.parameters.Price;
    P1 = instance.parameters.P1;
    P2 = instance.parameters.P2;
    P3 = instance.parameters.P3;
	N = instance.parameters.N;
    M = instance.parameters.M;
	Type = instance.parameters.Type;
    source = instance.source;
    Size = instance.parameters.Size; 
	


    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Type) .. ", " .. tostring(P1) .. ", " .. tostring(P2) .. ", " .. tostring(P3).. ", " .. tostring(N) .. ", " .. tostring(M) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	assert(core.indicators:findIndicator("SUPERTREND") ~= nil, "Please, download and install SUPERTREND.LUA indicator");	
	
    assert(core.indicators:findIndicator(Type) ~= nil, Type .. " indicator must be installed");
	 Indicator[1] = core.indicators:create(Type, source[Price], P1);
	 Indicator[2] = core.indicators:create(Type, source[Price], P2);
	 Indicator[3] = core.indicators:create(Type, source[Price], P3);
	 Indicator[4] = core.indicators:create("SUPERTREND", source, N, M, core.rgb(0, 255, 0), core.rgb(255, 0, 0));
	 
	 first = math.max(Indicator[1].DATA:first(),Indicator[2].DATA:first(),Indicator[3].DATA:first(), Indicator[4].DATA:first());

 
        Out = instance:addStream("Out", core.Bar, name, "Out", instance.parameters.Up, first);
		Out:addLevel(0);
		Out:setPrecision(math.max(2, source:getPrecision()));
   
	
	up = instance:createTextOutput("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Dn, 0);
     down = instance:createTextOutput("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Up, 0);
	
	core.host:execute ("attachTextToChart", "Up");
	core.host:execute ("attachTextToChart", "Dn");
	
	Initialization();
	
end


function  Initialization ()
    
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
	end
		 
end	


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
 
 
 Calculation (period, mode);
	
  if period < first then
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
	  
	       
			if   Out:colorI(period)==  instance.parameters.Up 
			and Out:colorI(period-1)~=  instance.parameters.Up 
			then
			           
						    
              
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Up ", period);
							  SendAlert(" Up ");  
							  Pop(Label[id], " Up " );  	
								    
								 
							  end
			elseif   Out:colorI(period)==  instance.parameters.Dn 
			and Out:colorI(period-1)~=  instance.parameters.Dn 
            then			
			
			            			 
			             
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Down ", period);	
								 
									Pop(Label[id], " Down " );  	
								    SendAlert(" Down ");
							 
			                  end	 
			elseif   Out:colorI(period)==  instance.parameters.No 
			and Out:colorI(period-1)~=  instance.parameters.No 
            then			
			
			            			 
			             
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Neutral ", period);	
								 
									Pop(Label[id], " Neutral " );  	
								    SendAlert(" Neutral");
							 
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
  
   if not Show then
   return;
   end
   
   core.host:execute ("prompt", 1, label ,   " ( " .. source:instrument() .. " : " .. source:barSize() .. " ) "  ..   label .. " : " .. note );
 
end


function SendAlert(message)
    if not ShowAlert then
        return;
    end
  
 
   terminal:alertMessage(source:instrument(), source[NOW], message, source:date(NOW));
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
 

function EmailAlert( label , Subject, period)

if not SendEmail then
return
end

 if OnlyOnce and OnlyOnceFlag== false then
 return;
 end

 
    local date = source:date(period);
	local DATA = core.dateToTable (date);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  

    local text = Note  .. delim ..  Symbol .. delim .." Time Frame " ..  source:barSize()  .. delim .. Time;

 
   terminal:alertEmail(Email, profile:id(), text);
end
	 




function Calculation(period, mode)

   if period < period or  not source:hasData(period) then
	return;
	end
	
	 Indicator[1]:update(mode);
	 Indicator[2]:update(mode);
	 Indicator[3]:update(mode);
	  Indicator[4]:update(mode);
	 
	  Out[period] = 1;
	 
	 if   source.close[period] > Indicator[1].DATA[period] 
	 and Indicator[1].DATA[period] > Indicator[2].DATA[period]
	 and  Indicator[2].DATA[period] > Indicator[3].DATA[period]
	 and  Indicator[4].DATA:colorI(period) ==  core.rgb(0, 255, 0) 
	 then
	  Out:setColor(period, instance.parameters.Up);  
	  if Out:colorI(period-1)~=  instance.parameters.Up then
	  down:set(period, source.low[period], "\225");
	  end
	  up:setNoData (period);

	  elseif   source.close[period] < Indicator[1].DATA[period]
	 and Indicator[1].DATA[period] < Indicator[2].DATA[period]
	 and  Indicator[2].DATA[period] < Indicator[3].DATA[period] 
	  and  Indicator[4].DATA:colorI(period) ==  core.rgb(255, 0, 0) 
	 then
	  Out:setColor(period, instance.parameters.Dn); 
	    if Out:colorI(period-1)~=  instance.parameters.Dn then
	    up:set(period, source.high[period], "\226");
		end
		 down:setNoData (period);
	 else
	 
	  Out:setColor(period, instance.parameters.No);  
	   up:setNoData (period);
	  down:setNoData (period);
	 end
end
