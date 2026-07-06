-- Id: 19107

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65113

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
    indicator:name("RSI_Color");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	 
    indicator.parameters:addInteger("Period", "Period", "Period", 14);

	
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("color", "Color of RSI", "Color of RSI", core.rgb(0, 0, 255));
	indicator.parameters:addColor("OB", "Color of RSI in OB Zone", "Color of RSI", core.rgb(0, 255,0 ));
	indicator.parameters:addColor("OS", "Color of RSI in OS Zoen", "Color of RSI", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
	
	
	indicator.parameters:addGroup("Levels");	
	
	
	indicator.parameters:addInteger("ArrowSize","Arrow Size","", 10);
	indicator.parameters:addDouble("Level1","Oversold Level","", 60);
	indicator.parameters:addColor("level_overboughtsold_color1", "Line Color","", core.rgb(33, 167, 238));
    indicator.parameters:addInteger("level_overboughtsold_width1","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style1", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style1", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addDouble("Level2","Oversold Level","", 40);
	indicator.parameters:addColor("level_overboughtsold_color2", "Line Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("level_overboughtsold_width2","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style2", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style2", core.FLAG_LEVEL_STYLE);
	
	  indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "Execution", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	

	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, "Alert");	
	
	
	
end


function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);


    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 1;
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
local Shift=0; 
local Alert={}; 
local AlertLevel={};

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local OS, OB;
local first;
local source = nil;
-- Streams block
local RSI = nil;
local rsi;
local upcross, downcross;
local ArrowSize;
-- Routine
function Prepare( nameOnly)
    Period = instance.parameters.Period; 	
	OS= instance.parameters.OS;
	OB= instance.parameters.OB;
	ArrowSize= instance.parameters.ArrowSize;
	
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	   
    source = instance.source;
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
	rsi = core.indicators:create("RSI", source.close, Period);
    first = rsi.DATA:first();
	
        RSI = instance:addStream("RSI", core.Line, name, "RSI", instance.parameters.color, first);
        RSI:setPrecision(math.max(2, instance.source:getPrecision()));
	
        RSI:setWidth(instance.parameters.width);
        RSI:setStyle(instance.parameters.style);
		
		RSI:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style1, instance.parameters.level_overboughtsold_width1, instance.parameters.level_overboughtsold_color1);
		RSI:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style2, instance.parameters.level_overboughtsold_width2, instance.parameters.level_overboughtsold_color2);
		
		 upcross = instance:createTextOutput ("Up", "Up", "Wingdings", ArrowSize, core.H_Center, core.V_Bottom, instance.parameters.level_overboughtsold_color2, 0);
         downcross = instance:createTextOutput ("Dn", "Dn", "Wingdings", ArrowSize, core.H_Center, core.V_Top, instance.parameters.level_overboughtsold_color1, 0);
		 core.host:execute ("attachTextToChart", "Up");
		 core.host:execute ("attachTextToChart", "Dn");
		
    
	
	  for i= 1, Number , 1 do
		Alert[i]=instance:addInternalStream(0, 0);
     end
	
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

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    rsi:update(mode);
	 

    if period < first or not  source:hasData(period) then
	return;
	end
	
	 upcross:setNoData(period);
	 downcross:setNoData(period);
	 
	  
	
        RSI[period] =  rsi.DATA[period]  ;
      
	  
	 if RSI[period]> instance.parameters.Level1 then
	 RSI:setColor(period, OB); 	 
	 elseif RSI[period]< instance.parameters.Level2 then
	 RSI:setColor(period, OS); 
	 else
	 RSI:setColor(period, instance.parameters.color); 
	 end
	 
	 if RSI[period]< instance.parameters.Level1
     and RSI[period-1]>= instance.parameters.Level1
     then	 
	 downcross:set(period , source.high[period], "\234", source.high[period]);
	 Alert[period]=-1;
	 elseif RSI[period]> instance.parameters.Level2
     and RSI[period-1]<= instance.parameters.Level2
     then	 
	 upcross:set(period , source.low[period], "\233", source.low[period]);
	 Alert[period]=1;
	 end
	 
	
    if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
	 
	
     Activate (1, period);
end



function Activate (id, period)


   
   
   
  
  
	  if id == 1  and ON[id]  then
	  
	       
			if  Alert[period] == 1 
			and    Alert[period-1] ~= 1 
			then
			           
						    
         
              
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over ", period);
							  SendAlert( Label[id]," Crossed over ", period); 
							  Pop(Label[id], " Cross Over ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif  Alert[period] == -1 
			and    Alert[period-1] ~= -1 
            then			
			
			             
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under ", period);								 
							 Pop(Label[id], " Cross Under ", period );  	
							 SendAlert( Label[id]," Crossed under ", period);
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

 
 
 

