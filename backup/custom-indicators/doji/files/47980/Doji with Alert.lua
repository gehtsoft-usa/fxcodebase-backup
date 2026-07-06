-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27419
-- Id: 18158

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
    indicator:name("Doji Bar");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	 indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addString("Type", "Doji Type", "", "All");
    indicator.parameters:addStringAlternative("Type", "All Types", "", "All");
    indicator.parameters:addStringAlternative("Type", "Dragonfly/Gravestone Doji", "", "Dragonfly/Gravestone");
     indicator.parameters:addInteger("Trend", "Trend Period", " ", 1);
    indicator.parameters:addInteger("Delta", "Open/Close difference (% of body length)", " ", 5);
	indicator.parameters:addInteger("Wick", "Dragonfly / Gravestone Doji max. Wick Size(% of body length)", " ", 5);
	 
	 indicator.parameters:addGroup("Style");	

 
	 
	 
	indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "Execution", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	indicator.parameters:addGroup("Alert Style");
   	indicator.parameters:addColor("Top", "Top Color Doji", " ", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Bottom", "Bottom Color Doji", " ", core.rgb(0, 255, 0));
	indicator.parameters:addColor("No", "No Color Doji", " ", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, "Doji");	
	
end



function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);


    indicator.parameters:addFile("Up"..id, Label .. " Top Doji Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Bottom Doji Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Neutral"..id, Label .. " Neutral Doji Sound", "", "");
    indicator.parameters:setFlag("Neutral"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 1;
local Up={};
local Down={};
local Neutral={};
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
local font;
local ShowAlert;
local first;
local source = nil;
local Price2, Price1;
local Indicator;
local Method1, Period1;
local Method2, Period2;
local  slow, Slow;
local Fast, fast;
local Shift=0; 
local Alert={}; 
local AlertLevel={};

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Delta=nil;

local first;
local source = nil;
local Size;
-- Streams block
local up = nil;
local down = nil;
local no;
local Wick;
local Type;
local Trend;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	Trend =  instance.parameters.Trend;
    first = source:first()+Trend;
	Type =  instance.parameters.Type;
	
	Delta =  instance.parameters.Delta;
	Wick =  instance.parameters.Wick;
	
	
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live; 
	Size=instance.parameters.Size;
	
    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	down = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Bottom, first);
    up = instance:createTextOutput ("Down", "Down", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Top, first);
	no = instance:createTextOutput ("Neutral", "Neutral", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.No, first);
	
	 for i= 1, Number , 1 do
		Alert[i]=instance:addInternalStream(0, 0);
		
     end
	
	Initialization();	
	 
end

 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period <  first  then
	return;
	end
	
	up:setNoData (period);
	down:setNoData (period);
	no:setNoData (period);
	
	 Alert[period]=0;
	
	local Percentage = (source.high[period]- source.low[period])/100;
	local Diff = (source.open[period]- source.close[period]) / Percentage ;
	local Label;
	
	
	
	              if math.abs(Diff) <= Delta then
				  
							
							if Type == "All" then
						  
								   if  ( source.high[period] - math.max (source.open[period] ,source.close[period] )) / Percentage    <  Wick then
								   Label = "Dragonfly  Doji";	
								   down:set(period, source.low[period], "\225", Label);			   
								  
								   Alert[period]=1;
							      elseif  (  math.min (source.open[period] ,source.close[period] ) -source.low[period] ) / Percentage    <  Wick then
								   Label = "Gravestone  Doji";
									up:set(period, source.high[period], "\226", Label);
									 Alert[period]=2;
								  else			
							  
							 					 
								 
										  Label = "Doji";
										  
										   Alert[period]=3;
									  
										  if source.open[period-1-Trend]  < source.open[period]  then
										  up:set(period, source.high[period], "\226", Label);
										  elseif source.open[period-1-Trend]  > source.open[period]  then
										  down:set(period, source.low[period], "\225", Label);
										  else
										  no:set(period, source.low[period], "\225", Label);
										  end
										  
								  end
							
						  elseif Type == "Dragonfly/Gravestone" then 
						      
							  
							     if  ( source.high[period] - math.max (source.open[period] ,source.close[period] )) / Percentage    <  Wick then
								   Label = "Dragonfly  Doji";	
								   Alert[period]=1;

								   down:set(period, source.low[period], "\225", Label);			   
							      elseif  (  math.min (source.open[period] ,source.close[period] ) -source.low[period] ) / Percentage    <  Wick then
								   Label = "Gravestone  Doji";
									up:set(period, source.high[period], "\226", Label);
									 Alert[period]=2;

						         end
						  end
				end		  
				
				
	 if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
	
	
     if period < first then
	 return;
	 end
	
    Activate (1, period);
 
 
 
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
	
    assert(not (SendEmail and (Email == "" or Email == nil )), "E-mail address must be specified");
	
	
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
	  	 assert( not(PlaySound  and (Up[i] == "" or Up[i] == nil ) ), "Sound file must be chosen");
        assert (not (PlaySoundand  and (Down[i] == "" or Down[i] == nil)), "Sound file must be chosen");
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	U[i] = nil;
	D[i] = nil;	 
	end
		 
end	



function Activate (id, period)


  
   
   
  
  
	  if id == 1  and ON[id]  then
	  
	       
			if   Alert[period]==1 
			and  Alert[period- 1] ~=1
			then
			           
			 
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Dragonfly  Doji ", period);
							  SendAlert( Label[id]," Dragonfly  Doji ", period); 
							  Pop(Label[id], " Dragonfly  Doji ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif   Alert[period]==2 
			and  Alert[period- 1] ~=2
            then		    
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Gravestone Doji ", period);								 
							 Pop(Label[id], " Gravestone Doji ", period );  	
							 SendAlert( Label[id]," Gravestone Doji ", period);
							 OnlyOnceFlag=false;
			                 end			   
	         elseif   Alert[period]==3 
			and  Alert[period- 1] ~=3
            then		    
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Doji ", period);								 
							 Pop(Label[id], " Doji ", period );  	
							 SendAlert( Label[id]," Doji ", period);
							 OnlyOnceFlag=false;
			                 end			   
	         end
			
	  
	 
	  end
	  
		   
        if FIRST then
        FIRST=false;      
        end		

end


function AsyncOperationFinished (cookie, success, message)
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
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
   
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
	
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 
	 
	 
	 

function Pop(label , Subject, period)
  
   if not Show then
   return;
   end
   
    local date = source:date(period);
	local DATA = core.dateToTable (date);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
   
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
   
   core.host:execute ("prompt", 1, label , text );


end


function SendAlert(label ,Subject, period)
    if not ShowAlert then
        return;
    end
	
	local date = source:date(period);
	local DATA = core.dateToTable (date);
	
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
 
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
 
    terminal:alertMessage(source:instrument(), source[NOW], text, source:date(NOW));
end

 
 
 


