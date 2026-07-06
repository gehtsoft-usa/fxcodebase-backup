-- Id: 15507
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=358

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

function Init()
    indicator:name("GMACD with Alert");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SN", "Short", "", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long", "", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal Line", "", 9, 2, 1000);
	
	indicator.parameters:addString("Method1", "MACD MA Type", "MA Type" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "HMA", "HMA" , "HMA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method1", "VAMA", "VAMA" , "VAMA");	
	
	
	indicator.parameters:addString("Method2", "MACD MA Type", "MA Type" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "HMA", "HMA" , "HMA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method2", "VAMA", "VAMA" , "VAMA");	
	
	indicator.parameters:addString("Type1", "Price Type", "", "C");
    indicator.parameters:addStringAlternative("Type1", "OPEN", "", "O");
    indicator.parameters:addStringAlternative("Type1", "HIGH", "", "H");
    indicator.parameters:addStringAlternative("Type1", "LOW", "", "L");
    indicator.parameters:addStringAlternative("Type1","CLOSE", "", "C");
    indicator.parameters:addStringAlternative("Type1", "MEDIAN", "", "M");
    indicator.parameters:addStringAlternative("Type1", "TYPICAL", "", "T");
    indicator.parameters:addStringAlternative("Type1", "WEIGHTED", "", "W");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("SIGNAL_color", "The signal line color", "", core.rgb(127, 255, 0));
    indicator.parameters:addColor("HISTOGRAM_color", "The histogramm color", "", core.rgb(127, 127, 127));
    indicator.parameters:addColor("HISTOGRAM_color1", "The histogramm color 1", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("HISTOGRAM_color2", "The histogramm color 2", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);	
	
	
	indicator.parameters:addGroup("Indicator Style");   
    indicator.parameters:addColor("color1", "Fast MA color", "MA color", core.rgb(0,255,0));
	indicator.parameters:addInteger("width1", "MA Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style1", "MA Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "Slow MA color", "MA color", core.rgb(255,0,0));
	indicator.parameters:addInteger("width2", "MA Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style2", "MA Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, "MA Cross");	
end

-- Indicator instance initialization routine


function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);


    indicator.parameters:addFile("Up"..id, Label .. " Cross Over Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Cross Under Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local Number = 1;
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
local UpTrendColor, DownTrendColor;
local OnlyOnceFlag;
local font;
local ShowAlert;

-- Parameters block
local SN;
local LN;
local IN;

local Method1;
local Method2;
local Type1;

local firstPeriodMACD;
local firstPeriodSIGNAL;
local source;

local EMAS = nil;
local EMAL = nil;
local MVAI = nil;

-- Streams block
local MACD = nil;
local SIGNAL = nil;
local HISTOGRAM = nil;
local Signal;
local UpLabel, DownLabel,NeutralLabel;

-- Routine
function Prepare(nameOnly)

   
    Type1= instance.parameters.Type1;	
    Method1= instance.parameters.Method1;
	Method2= instance.parameters.Method2;
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
    source = instance.source;
	
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	Size=instance.parameters.Size;
	--font = core.host:execute("createFont", "Wingdings", Size, false, false);
	-- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. SN .. ", " .. LN .. ", " .. IN .. ", " .. Method1 ..  ", " .. Method2 .."," .. Type1 .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	 assert(core.indicators:findIndicator(Method1) ~= nil, "Please, download and install "..Method1..  " indicator");
	 assert(core.indicators:findIndicator(Method2) ~= nil, "Please, download and install "..Method2..  " indicator");
	 
	local  P1; 
	 
	if Type1 == "O" then
        P1 = source.open;
    elseif Type1 == "H" then
        P1 = source.high;
    elseif Type1 == "L" then
        P1 = source.low;
    elseif Type1 == "M" then
        P1 = source.median;
    elseif Type1 == "T" then
        P1 = source.typical;
    elseif Type1 == "W" then
        P1 = source.weighted;
    else
        P1 = source.close;
    end

    -- Check parameters
    if (LN <= SN) then
       error("The short EMA period must be smaller than long EMA period");
    end

    -- Create short and long EMAs for the source
    if Method1 == "VAMA" then
    EMAS = core.indicators:create(Method1, source, SN);
    EMAL = core.indicators:create(Method1, source, LN);
	else
	EMAS = core.indicators:create(Method1, P1, SN);
    EMAL = core.indicators:create(Method1, P1, LN);
	end
	
	firstPeriodMACD=math.max(EMAS.DATA:first(), EMAL.DATA:first());

    -- Create the output stream for the MACD. The first period is equal to the
    -- biggest first period of source EMA streams
    firstPeriodMACD = EMAL.DATA:first();


    HISTOGRAM = instance:addStream("H", core.Bar, name .. ".H", "H", instance.parameters.HISTOGRAM_color, firstPeriodMACD);
    HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));
    -- Create MVA for the MACD output stream.
    MVAI = core.indicators:create(Method2, HISTOGRAM, IN); 	
	firstPeriodSIGNAL=MVAI.DATA:first();
	
    SIGNAL = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_color, firstPeriodSIGNAL);
    SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
	SIGNAL:setWidth(instance.parameters.width);
    SIGNAL:setStyle(instance.parameters.style);
	
	Initialization();
	
	UpLabel = instance:createTextOutput("UpLabel", "UpLabel", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.HISTOGRAM_color1, 0);
    DownLabel = instance:createTextOutput("DownLabel", "DownLabel", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.HISTOGRAM_color2, 0);
   
	
	core.host:execute ("attachTextToChart", "UpLabel");
	core.host:execute ("attachTextToChart", "DownLabel");
 
	Signal = instance:addInternalStream(0, 0); 	   
	Initialization();
end
--[[

function ReleaseInstance()
       core.host:execute("deleteFont", font);
end	]]

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
function Update(period, mode)

    EMAS:update(mode);
	EMAL:update(mode);	
	
	UpLabel:setNoData (period);
	DownLabel:setNoData (period);
	 
	
	if   period < firstPeriodMACD then
	return;
	end
				
	HISTOGRAM[period] = EMAS.DATA[period] - EMAL.DATA[period];
	
				 
	MVAI:update(mode);
	if period < firstPeriodSIGNAL then
	return;
	end
			 
	SIGNAL[period] = MVAI.DATA[period];
	
				 
		        if HISTOGRAM[period] > 0 and HISTOGRAM[period] > SIGNAL[period] then 
					if Signal[period-1] ~= 1 then		
					 UpLabel:set(period, source.low[period], "\225") 
					end
				HISTOGRAM:setColor(period, instance.parameters.HISTOGRAM_color1); 	               
                Signal[period] = 1;				
				elseif HISTOGRAM[period] < 0 and HISTOGRAM[period] < SIGNAL[period] then 
					if Signal[period-1] ~= -1 then		
					DownLabel:set(period, source.high[period], "\226")
					end
				
				HISTOGRAM:setColor(period, instance.parameters.HISTOGRAM_color2);
				Signal[period] = -1;		
				else
				HISTOGRAM:setColor(period, instance.parameters.HISTOGRAM_color);  
				Signal[period] = 0;		
				end
		 
 
	 Activate (1, period);
	 
end



function Activate (id, period)

if not ON[id]
then 
return;
end

local Shift=0;


	   if Live~= "Live" then
		period=period-1;
		Shift=1;
		end
	 
	  
	       
			if  HISTOGRAM[period] > 0 and HISTOGRAM[period] > SIGNAL[period]
			then
			           
			 
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							  SendAlert("Crossed over");  
							        
									Pop(Label[id], " Cross Over " );  	
								    
								 
							  end
			elseif HISTOGRAM[period] < 0 and HISTOGRAM[period] < SIGNAL[period] 
			then 
         
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 
									Pop(Label[id], " Cross Under " );  	
								    SendAlert("Crossed under");
							 
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
   
    
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	 
	
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 




