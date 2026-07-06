-- Id: 10832
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=26221


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
    indicator:name("Rainbow Volume");
    indicator:description("Rainbow Volume");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
   
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "Period", 10);
	
	indicator.parameters:addGroup("Style"); 
	indicator.parameters:addColor("UUC", "Up Price / Up Volume Color", "Up Price / Up Volume Color", core.rgb(0,255,0));
	indicator.parameters:addColor("UDC", "Up Price / Down Volume Color", "Up Price / Down Volume Color", core.rgb(0,0,255));
	indicator.parameters:addColor("DDC", "Down Price / Down Volume Color", "Down Price / Down Volume Color", core.rgb(255,0,0));
	indicator.parameters:addColor("DUC", "Down Price / Up Volume Color", "Down Price / Up Volume Color", core.rgb(255,128,0));
    indicator.parameters:addColor("NC", "Neutral Color", "Neutral Color", core.rgb(128, 128, 128));
	

	
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("Color", "Alert Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	
	
	Parameters (1, "Color Change")
end



function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("On" , "Show " .. Label .." Alert" , "", true);


    indicator.parameters:addFile("Sound", Label .. " Aler Sound", "", "");
    indicator.parameters:setFlag("Sound", core.FLAG_SOUND);
	

	
	 indicator.parameters:addString("Label", "Label", "", Label);

end 

local 	Number = 1;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Sound, Color,Label;
local first;
local source = nil;
local On,Size,SendEmail;
-- Streams block
local Volume = nil;
local NC, UUP,DDC, UDC, DUC, Last ;
local S,RecurrentSound,alert, Alert;
local Show;
local Live="End of Turn";
local FIRST=true;
-- Routine
function Prepare(nameOnly)
    Show= instance.parameters.Show;
    Sound= instance.parameters.Sound;
	Live= instance.parameters.Live;
	Label= instance.parameters.Label;
	Color= instance.parameters.Color;
	On= instance.parameters.On;	
	Size=instance.parameters.Size;
	SendEmail = instance.parameters.SendEmail;
	
	
	  source = instance.source;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

   
    if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
	
	
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
	
	
	 PlaySound = instance.parameters.PlaySound;
	 
	 
    if not PlaySound then
       Sound=nil;
	end      
       
	  assert(not(PlaySound) or (PlaySound and Sound ~= "") or (PlaySound and Sound ~= ""), "Sound file must be chosen"); 
 
	 
    RecurrentSound = instance.parameters.RecurrentSound;	 
	S  = nil;	
    FIRST=true	
	Last = instance:addInternalStream(0, 0);
	
		if On then
		alert  = instance:createTextOutput ("Alert", "Alert", "Wingdings", Size, core.H_Center, core.V_Center, instance.parameters.Color, 0);		 
		end 

	
	
    Period = instance.parameters.Period;
	NC = instance.parameters.NC;
	UUC = instance.parameters.UUC;
	DDC = instance.parameters.DDC;
	UDC = instance.parameters.UDC;
	DUC = instance.parameters.DUC;
	
   
	
	 assert(source:supportsVolume(), "The source must have volume");

	

    
        Volume = instance:addStream("Volume", core.Bar, name, "Volume", NC, first);
    Volume:setPrecision(math.max(2, instance.source:getPrecision()));
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values

function Calculate(period, mode)
Volume:setColor(period, NC);
	
	
	if period < first or not source:hasData(period) then
	return;
	end
	
	
        Volume[period] = source.volume[period];
		
		if source.close[period] > source.close[period-Period] and source.volume[period] > source.volume[period-Period] then		
		Volume:setColor(period, UUC);
		Last[period]= 1;
		elseif source.close[period] > source.close[period-Period] and source.volume[period] < source.volume[period-Period] then	
		Volume:setColor(period, UDC);
		Last[period]= 2;
		elseif source.close[period] < source.close[period-Period] and source.volume[period] > source.volume[period-Period] then	
		Volume:setColor(period, DUC);
		Last[period]= 4;
        elseif source.close[period] < source.close[period-Period] and source.volume[period] < source.volume[period-Period] then	
		Volume:setColor(period, DDC);
		Last[period]= 3;
		else
		Volume:setColor(period, NC);
		Last[period]= 0;
		end


end

function Update(period)

    	 if On then
		 alert:setNoData (period); 		 
		 end
   	 
   
   if period < first then
return;
end

    Calculate(period, mode);
	  Activate ( period);
end

function Activate ( period)

   local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
 
	  if  On  then
	  
	       
			if Last[period]~= Last[period-1]
			then
			           
						    alert:set(period , 0, "\108");	
						   
			
			 
						   
							  if period == source:size()-1-Shift
							  and S~=source:serial(period)
							  and not FIRST 
							  then
							  S=source:serial(period);
							  SoundAlert(Sound);
							  EmailAlert(  Label, Decode(period) , period);
							    
							        if Show then
									Pop(Label,  Decode(period) );  	
								    end
								 
							  end
		  end
			
	  
	 
	  end
	  
		   
        if FIRST then
        FIRST=false;      
        end		

end

function Decode (period)

local From, To;

if Last[period] == 1 then
To=  "Up Price / Up Volume";
elseif Last[period] == 2 then
To=  "Up Price / Down Volume";
elseif Last[period] == 3 then
To=  "Down Price / Down Volume";
elseif Last[period] == 4 then
To=  "Down Price / Up Volume";
else
To=  "Neutral";
end

if Last[period-1] == 1 then
From=  "Up Price / Up Volume";
elseif Last[period-1] == 2 then
From=  "Up Price / Down Volume";
elseif Last[period-1] == 3 then
From=  "Down Price / Down Volume";
elseif Last[period-1] == 4 then
From=  "Down Price / Up Volume";
else
From=  "Neutral";
end

   return " From :" .. From .. " To : " .. To;


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
   
     local text = Note  .. delim ..  Symbol .. delim .. TF .. delim .. Time;
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 


