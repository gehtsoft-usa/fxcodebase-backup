-- Id: 21759

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63793

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
function Init()
    indicator:name("Larry Williams' Percent Range");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
   

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "RLW Period","", 14, 2, 1000);
	 indicator.parameters:addInteger("Period", "Signal Period","", 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("RLWLine", "RLW Line Color","", core.rgb(0, 255, 0)); 
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
  
	indicator.parameters:addColor("SignalLine", "Signal Line Color","", core.rgb(255, 0, 0)); 
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);

    indicator.parameters:addGroup("BB");
    indicator.parameters:addInteger("Period_BB", "Period", "", 20, 1, 10000);
    indicator.parameters:addDouble("Deviation_BB", "Deviation", "", 2.0, 0.0001, 1000.0);
    indicator.parameters:addColor("BandsClr", "Bands line color", "Bands line color", core.rgb(255, 128, 64));
    indicator.parameters:addColor("AverageClr", "Average line color", "Average line color", core.rgb(0, 0, 255));
 
   indicator.parameters:addInteger("BB_width1", "Top Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("BB_style1", "Top Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("BB_style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addInteger("BB_width2", "Bottom Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("BB_style2", "Bottom Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("BB_style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addInteger("BB_width3", "Central Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("BB_style3", "Central Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("BB_style3", core.FLAG_LINE_STYLE);
	
	
   
    indicator.parameters:addGroup("Levels");
    -- Overbought/oversold level
    indicator.parameters:addInteger("overbought", "OB Level","", -20, -100, 0);
    indicator.parameters:addInteger("oversold","OS Level","", -80, -100, 0);
    indicator.parameters:addInteger("level_overboughtsold_width", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(255, 255, 0));
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
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

	
	Parameters (1, "RLW/Signal");	
	

	
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
local UpTrendColor, DownTrendColor;
local OnlyOnceFlag;
local font;
local ShowAlert;
local Shift=0; 
 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;
local Period;

local first;
local source = nil;

-- Streams block
local RLW = nil;
local SIGNAL = nil;

-- BB
local Period_BB;
local Deviation_BB;
local BB;
local BB_Top=nil;
local BB_Bottom=nil;
local BB_Middle=nil;

-- Routine
function Prepare(nameOnly) 


    n = instance.parameters.N;
	Period = instance.parameters.Period;
	
    source = instance.source;
    first = source:first() + n - 1;
	
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	Size=instance.parameters.Size;
	font = core.host:execute("createFont", "Wingdings", Size, false, false);
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    RLW = instance:addStream("RLW", core.Line, name, "RLW", instance.parameters.RLWLine, first);	
	RLW:setWidth(instance.parameters.width1);
    RLW:setStyle(instance.parameters.style1);
	
	SIGNAL = instance:addStream("SIGNAL", core.Line, name, "Signal", instance.parameters.SignalLine, first+Period);
    SIGNAL:setWidth(instance.parameters.width2);
    SIGNAL:setStyle(instance.parameters.style2);
		
    RLW:addLevel(0);
    RLW:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    RLW:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    RLW:addLevel(-100);
	RLW:addLevel(-50);
    
    Period_BB=instance.parameters.Period_BB;
    Deviation_BB=instance.parameters.Deviation_BB;
    BB = core.indicators:create("BB", RLW, Period_BB, Deviation_BB);
	
    BB_Top = instance:addStream("BB_Top", core.Line, name .. ".Top", "Top", instance.parameters.BandsClr, first);
    BB_Bottom = instance:addStream("BB_Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.BandsClr, first);
    BB_Middle = instance:addStream("BB_Middle", core.Line, name .. ".Middle", "Middle", instance.parameters.AverageClr, first);
	
	    BB_Top:setWidth(instance.parameters.BB_width1);
        BB_Top:setStyle(instance.parameters.BB_style1);
		
		BB_Bottom:setWidth(instance.parameters.BB_width2);
        BB_Bottom:setStyle(instance.parameters.BB_style2);
		
		BB_Middle:setWidth(instance.parameters.BB_width3);
        BB_Middle:setStyle(instance.parameters.BB_style3);
		
		RLW:setPrecision(math.max(2, instance.source:getPrecision()));
	    SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
	    BB_Top:setPrecision(math.max(2, instance.source:getPrecision()));
	    BB_Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
		BB_Middle:setPrecision(math.max(2, instance.source:getPrecision()));
	
	Initialization();
end

-- Indicator calculation routine
function Update(period)
    if period < first then
	return;
	end
        local from = period - n + 1;
        low, high = mathex.minmax(source, from, period);
        local diff = high - low;
        if (diff == 0) then
            RLW[period] = 0;
        else
            RLW[period] = (-100) * (high - source.close[period]) / diff;
        end
        
        BB:update(mode);
        BB_Top[period]=BB.TL[period];
        BB_Bottom[period]=BB.BL[period];
        BB_Middle[period]=BB.AL[period];
	
		if period < first+Period then
            return;
		end
		
		
		 low, high = mathex.minmax(RLW, period-Period+1, period);
		 
		 SIGNAL[period]= (high+low)/2;
		 
		 
		 
 

    if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
	
	core.host:execute ("removeLabel", source:serial(period)); 
    
	 
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

 



 

function ReleaseInstance()
       core.host:execute("deleteFont", font);
end	   

function Activate (id, period)

  
	  if id == 1  and ON[id]  then
	  
	       
			if  RLW[period] > SIGNAL[period] 
			and   RLW[period-1] <= SIGNAL[period-1] 
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, SIGNAL[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
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
			elseif  RLW[period] < SIGNAL[period] 
			and   RLW[period-1] >= SIGNAL[period-1] 
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, SIGNAL[period], core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
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
	 


 