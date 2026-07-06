-- Id: 18869
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=32838

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

-- The indicator corresponds to the Ichimoku Kinko Hyo indicator in MetaTrader.

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("MACD / CCI Consensus");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
   
    indicator.parameters:addGroup("Selector");
    indicator.parameters:addBoolean("One", "Use MACD Filter", "", true);
	indicator.parameters:addBoolean("Two", "Use CCI Filter", "", true);

	indicator.parameters:addGroup("MACD Calculation");
		
    indicator.parameters:addString("MACD_Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("MACD_Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("MACD_Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("MACD_Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("MACD_Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("MACD_Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("MACD_Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("MACD_Price", "WEIGHTED", "", "weighted");	
	
	indicator.parameters:addInteger("MACD_Short", "Short Period", "", 144);
	indicator.parameters:addInteger("MACD_Long", "Long Period", "", 233);
	indicator.parameters:addInteger("MACD_Signal", "Signal Period", "", 21);
	
	 indicator.parameters:addInteger("MACD_Selektor", "MACD Component", "",  0);
    indicator.parameters:addIntegerAlternative("MACD_Selektor", "MACD", "", 0);
    indicator.parameters:addIntegerAlternative("MACD_Selektor", "Signal", "", 1);
	indicator.parameters:addIntegerAlternative("MACD_Selektor", "Histogram", "", 2);
	
	indicator.parameters:addGroup("CCI Calculation");
	indicator.parameters:addInteger("CCI", "Period", "", 50);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral color", "", core.rgb(0, 0, 255));
	 indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);

	 
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

	
	ParametersFunction (1, "  Alert ");	

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local first;
local source = nil;
local open, close;
local Parameters={}; 
local Indicator={};


function ParametersFunction ( id, Label )
  
  
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

 
 


-- Routine
 function Prepare(nameOnly)   
 
     
   
	Transparency= (100 -instance.parameters.Transparency);
	
	One= instance.parameters.One;
	Two= instance.parameters.Two;
	
	
	
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live; 
	
	Parameters["CCI"] = instance.parameters.CCI;
	
	Parameters["MACD_Short"] = instance.parameters.MACD_Short;
	Parameters["MACD_Long"] = instance.parameters.MACD_Long;
	Parameters["MACD_Signal"] = instance.parameters.MACD_Signal;
    Parameters["MACD_Price"] = instance.parameters.MACD_Price;
	Parameters["MACD_Selektor"] = instance.parameters.MACD_Selektor;
	
	
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    
   if   (nameOnly) then
        return;
    end
	
	if One then
	  Indicator["MACD"]= core.indicators:create("MACD", source[Parameters["MACD_Price"]] ,Parameters["MACD_Short"], Parameters["MACD_Long"], Parameters["MACD_Signal"]);
	 first = math.max(first,Indicator["MACD"].DATA:first() );
	end
	
	if Two then
	 Indicator["CCI"]= core.indicators:create("CCI", source ,Parameters["CCI"]);
	 first = math.max(first,Indicator["CCI"].DATA:first() );
	end
	
	open = instance:addStream("open", core.Line, name, "", core.rgb(0, 0, 0), first);
    open:setPrecision(math.max(2, instance.source:getPrecision()));
    close = instance:addStream("high", core.Line, name, "", core.rgb(0, 0, 0), first);   
    close:setPrecision(math.max(2, instance.source:getPrecision()));
   instance:createChannelGroup("UpGroup","Up" , open, close, instance.parameters.Up, Transparency);
   
   
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
function Update(period, mode)


    open[period] = 1;
	close[period] = 0;

	
	open:setColor(period, instance.parameters.No);	

   
	local ONE=nil;
	local TWO=nil;
		
	Alert[1][period]= Alert[1][period-1];
	
		if One then
		
	     Indicator["MACD"]:update(mode);
			
		    if Indicator["MACD"]:getStream(Parameters["MACD_Selektor"])[period]   > Indicator["MACD"]:getStream(Parameters["MACD_Selektor"])[period-1] then
			ONE  = true;
			else
			ONE = false;
			end  
	   
        end
		
		if Two then
		 
		  Indicator["CCI"]:update(mode);
		   
		    if Indicator["CCI"].DATA[period] >  0 then
			TWO = true;
			else
			TWO = false;
			end
			
		end
		
		 
		
		 
		
		if not One and  not Two 
		then
		open:setColor(period, instance.parameters.No);	  
        Alert[1][period]= 0; 		
		elseif (ONE == true or not One)  
		and (TWO  == true  or not Two)  		
		then		
		open:setColor(period, instance.parameters.Up);
		 Alert[1][period]= 1; 	
        elseif(ONE == false or not One) 
		and  (TWO == false or not Two) 
		then
		open:setColor(period, instance.parameters.Dn);
		 Alert[1][period]= -1; 	
		else
		open:setColor(period, instance.parameters.No);	
        Alert[1][period]= 0; 			
		end
		
		
		 Activate (1, period);
        
  
end


function Activate (id, period)


 
   
   
  
  
	  if id == 1  and ON[id]  then
	  
	       
			if  Alert[id][period]== 1 
			and  Alert[id][period-1]~=1
			then
			           
			 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Up Trend ", period);
							  SendAlert( Label[id]," Up Trend ", period); 
							  Pop(Label[id], " Up Trend ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif Alert[id][period]== -1 
			and  Alert[id][period-1]~=-1
            then			
			 
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Down Trend ", period);								 
							 Pop(Label[id], " Down Trend ", period );  	
							 SendAlert( Label[id]," Down Trend ", period);
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

 
 
 



