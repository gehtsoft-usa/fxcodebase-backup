-- Id: 16053

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63289

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

function Init()
    indicator:name("Heikin Ashi Trend Bars");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator); 
    indicator:setTag("replaceSource", "t");
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");

    indicator.parameters:addInteger("Period", "Periods", "", 34, 1, 1000);
    indicator.parameters:addBoolean("ShowMA", "Show MA", "", true);
   
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("UP", "Color of Up Candel", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DOWN", "Color of Down Candle", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("NEUTRAL", "Color of Neutral Candle", "", core.rgb(128,128,128));
	
	indicator.parameters:addColor("color", "Color of MA Line", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
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

	
	Parameters (1, "Trend");	
	
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
 
local iopen = nil;
local ihigh = nil;

local open = nil;
local high = nil;
local low = nil;
local close = nil;

local first;
local UP, DOWN,NEUTRAL;
local Open, Close;

local ShowMA;

local color;
-- Routine
function Prepare(nameOnly)
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
	font = core.host:execute("createFont", "Wingdings", Size, false, false);
   
    -- was missing, so N1 was not set
    Period = instance.parameters.Period;
	Method= instance.parameters. Method;
	ShowMA= instance.parameters.ShowMA;
	
	UP = instance.parameters.UP;
	DOWN = instance.parameters.DOWN;
    NEUTRAL= instance.parameters.NEUTRAL;
	
	color= instance.parameters.color;

    first = source.close:first() ;
	
    iopen = instance:addInternalStream(first, 0);
    iclose = instance:addInternalStream(first, 0);
    
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    Open = core.indicators:create(Method, iopen, Period);
	Close = core.indicators:create(Method, iclose, Period);
	
	 local name = "Heikin Ashi Trend Bars" .. "(" .. source:name() .. "," .. Method .. "," .. Period.. ")"
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	
    if ShowMA then
    MA = instance:addStream("MA", core.Line, name, "MA", color, Open.DATA:first());
	MA:setWidth(instance.parameters.width);
    MA:setStyle(instance.parameters.style);
	else
	MA = instance:addInternalStream(Open.DATA:first(), 0);
    end	
	
   
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("HAS", "HAS", open, high, low, close);
	
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
 
 
        if period  < first then
		open:setColor(period, NEUTRAL);	
		return;
		end
		
		
            iclose[period] =  (source.open[period] + source.high[period] + source.low[period] + source.close[period])/4;
    
	        if period== first then
			iopen[period]=(source.open[period] + source.close[period]) / 2
			else
			iopen[period]=(iopen[period-1] + iclose[period-1]) / 2
			end
	
      
        Open:update(mode);
        Close:update(mode);
		
		
		if period < Open.DATA:first() then
		return;
		end
		
  
        MA[period]= (Open.DATA[period] + Close.DATA[period])/2

        open[period] = source.open[period];
        close[period] = source.close[period];
        high[period] = source.high[period];
        low[period] = source.low[period];
		
		
		if source.typical[period] > MA[period] then
		open:setColor(period, UP);	
		else
		open:setColor(period, DOWN);		 
		end		
		
		
	if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
	
	core.host:execute ("removeLabel", source:serial(period)); 
    
	
    Activate (1, period);
   
end



function ReleaseInstance()
       core.host:execute("deleteFont", font);
end	   

function Activate (id, period)

  
	  if id == 1  and ON[id]  then
	  
	       
			if source.typical[period] > MA[period]
			and   source.typical[period-1] <= MA[period-1]
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, low[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id],  " Up " , period);
							  SendAlert(" Up ");  
							        
									Pop(Label[id], " Up " );  	
								    
								 
							  end
			elseif source.typical[period] < MA[period]
			and   source.typical[period-1] >= MA[period-1]
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, high[period], core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
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
	 


 