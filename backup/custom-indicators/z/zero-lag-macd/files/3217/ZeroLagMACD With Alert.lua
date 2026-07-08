-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1623
-- Id: 14960

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Zero Lag MACD");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   
	
	
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("FMA", "Fast EMA periods", "", 12, 1, 5000);
    indicator.parameters:addInteger("SMA", "Slow EMA Periods", "", 24, 1, 5000);
    indicator.parameters:addInteger("SigMA", "Signal EMA periods", "", 9, 1, 5000);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MACD_color", "Color of MACD", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("SIG_color", "Color of Signal", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("HIS_color_Up", "Color of Historgram Up", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("HIS_color_Down", "Color of Historgram Down", "", core.rgb(255,0, 0));
	
	
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	
	Parameters (1, "MACD/Signal");
	Parameters (2, "MACD/Zero");
	Parameters (3, "Histogram/Zero");
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

local 	Number = 3;

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local FMA;
local SMA;
local SigMA;

local FMA_I;
local SMA_I;
local FMA_I2;
local SMA_I2;
local SigMA_I;
local SigMA_I2;

local firstMACD, firstSIG;
local source = nil;

-- Streams block
local MACD = nil;
local SIG = nil;
local HIS = nil;


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
 

-- Routine
function Prepare(nameOnly)

    OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	Size=instance.parameters.Size;
	
    FMA = instance.parameters.FMA;
    SMA = instance.parameters.SMA;
    SigMA = instance.parameters.SigMA;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. FMA .. ", " .. SMA .. ", " .. SigMA .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
    font = core.host:execute("createFont", "Wingdings", Size, false, false);

    FMA_I = core.indicators:create("EMA", source, FMA);
    SMA_I = core.indicators:create("EMA", source, SMA);
    FMA_I2 = core.indicators:create("EMA", FMA_I.DATA, FMA);
    SMA_I2 = core.indicators:create("EMA", SMA_I.DATA, SMA);

    firstMACD = math.max(FMA_I2.DATA:first(), SMA_I2.DATA:first());

    MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACD_color, firstMACD);
	
    MACD:setWidth(instance.parameters.width1);
    MACD:setStyle(instance.parameters.style1);
    SigMA_I = core.indicators:create("EMA", MACD, SigMA);
    SigMA_I2 = core.indicators:create("EMA", SigMA_I.DATA, SigMA);

    firstSIG = SigMA_I2.DATA:first();
    SIG = instance:addStream("SIG", core.Line, name .. ".SIG", "SIG", instance.parameters.SIG_color, firstSIG);
	SIG:setWidth(instance.parameters.width2);
    SIG:setStyle(instance.parameters.style2);
    HIS = instance:addStream("HISTOGRAM", core.Bar, name .. ".HIS", "HIS", instance.parameters.HIS_color_Up, firstSIG);
	
	
	MACD:setPrecision(math.max(2, source:getPrecision()));
	SIG:setPrecision(math.max(2, source:getPrecision()));
	HIS:setPrecision(math.max(2, source:getPrecision()));
	
	
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
function Update(period, mode)
    FMA_I:update(mode);
    FMA_I2:update(mode);
    SMA_I:update(mode);
    SMA_I2:update(mode);

    if period < firstMACD then
	return;
	end
        MACD[period] = (2 * FMA_I.DATA[period] - FMA_I2.DATA[period]) -
                       (2 * SMA_I.DATA[period] - SMA_I2.DATA[period]);
   

    SigMA_I:update(mode);
    SigMA_I2:update(mode);

    if period < firstSIG then 
	return;
	end
	
        SIG[period] = 2 * SigMA_I.DATA[period] - SigMA_I2.DATA[period];
        HIS[period] = MACD[period] - SIG[period];
		
		if HIS[period] > 0 then
		HIS:setColor(period,  instance.parameters.HIS_color_Up);
		else		
		HIS:setColor(period,  instance.parameters.HIS_color_Down);
		end
		
		
	core.host:execute ("removeLabel", source:serial(period)); 
  
	
    Activate (1, period);
	Activate (2, period);
	Activate (3, period);
    
end


function ReleaseInstance()
       core.host:execute("deleteFont", font);
end	   

function Activate (id, period)

   local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
 
	  if id == 1  and ON[id]  then
	  
	       
			if  MACD[period] > SIG[period] 
			and   MACD[period-1] <= SIG[period-1] 
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, SIG[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
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
			elseif  MACD[period] < SIG[period] 
			and   MACD[period-1] >= SIG[period-1] 
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, SIG[period], core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
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
			
	  
	 
	  end
	  
	  if id == 2  and ON[id]  then
	  
	       
			if  MACD[period] > 0
			and   MACD[period-1] <= 0
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, 0, core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
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
			elseif  MACD[period] < 0
			and   MACD[period-1] >= 0
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, 0, core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
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
			
	  
	 
	  end
	  
	  if id == 3  and ON[id]  then
	  
	       
			if  HIS[period] > 0
			and   HIS[period-1] <= 0
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, 0, core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
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
			elseif HIS[period] < 0
			and   HIS[period-1] >= 0
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, 0, core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
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
  
  core.host:execute ("prompt", 1, label ,   " ( " .. source:instrument() .. " ) "  ..   label .. " : " .. note );
  

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
   
    
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;    
    local text = Note  .. delim ..  Symbol   .. delim .. Time;
	
	
 terminal:alertEmail(Email, profile:id(), text);
 
 
end
	 



