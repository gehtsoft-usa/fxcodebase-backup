-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60263
 

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("MACD Squeeze");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 

    indicator.parameters:addGroup("MACD Calculation");
    indicator.parameters:addInteger("SN", "Short EMA", "The period of the short EMA", 8);
    indicator.parameters:addInteger("LN", "Long EMA", "The period of the Long EMA", 21);
    
	indicator.parameters:addGroup("Bollinger Calculation");
	 indicator.parameters:addInteger("N", "Bollinger Period", "", 20);
	 indicator.parameters:addDouble("NM", "Bollinger Deviation", "", 2);
	 indicator.parameters:addString("BBMethod", "Keltner MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("BBMethod", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("BBMethod", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("BBMethod", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("BBMethod", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("BBMethod", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("BBMethod", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("BBMethod", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("BBMethod", "WMA", "WMA" , "WMA");
	 
	 indicator.parameters:addGroup("Keltner Calculation");
	 indicator.parameters:addInteger("A", "Keltner Period", "", 20);
	 indicator.parameters:addDouble("AM", "Keltner Deviation", "", 1.5);
	 indicator.parameters:addInteger("AP", "ATR Period", "", 10);
	 indicator.parameters:addString("Method", "Keltner MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addGroup("MACD Style");
    indicator.parameters:addColor("MACDUP", "Color of UP MACD", "Color of UP MACD", core.rgb(0, 255, 0));
	indicator.parameters:addColor("MACDDOWN", "Color of DOWN MACD", "Color of DOWN MACD", core.rgb(255, 0, 0));
	
	
	 indicator.parameters:addGroup("Component Style");
	  indicator.parameters:addBoolean("Show_Component", "Show Component", "", false);
	  indicator.parameters:addColor("BL", "Color of Bollinger Lines", "Color of Bollinger Lines", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("KL", "Color of Keltner Lines", "Color of Keltner Lines", core.rgb(255, 0, 0));
	 
	  indicator.parameters:addGroup("Squeeze Style");	
    indicator.parameters:addColor("In", "Color of In Squeeze", "Color of Squeeze", core.rgb(128, 128, 128));
	indicator.parameters:addColor("Out", "Color of Out Squeeze", "Color of Squeeze", core.rgb(0, 0, 255));
	 indicator.parameters:addInteger("FontSize", "Font size", "", 10);
	 
	 
	 indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "Execution", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");  

 
	 
	indicator.parameters:addInteger("ToTime", "Convert the date to", "", 6);
    indicator.parameters:addIntegerAlternative("ToTime", "EST", "", 1);
    indicator.parameters:addIntegerAlternative("ToTime", "UTC", "", 2);
    indicator.parameters:addIntegerAlternative("ToTime", "Local", "", 3);
    indicator.parameters:addIntegerAlternative("ToTime", "Server", "", 4);
    indicator.parameters:addIntegerAlternative("ToTime", "Financial", "", 5);
	indicator.parameters:addIntegerAlternative("ToTime", "Display", "", 6);	

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, "In Squeeze");	
	Parameters (2, "Out Squeeze");	
	
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

local 	Number = 2;
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
local ShowAlert;
local Alert={}; 
local AlertLevel={};
local ToTime;
local Shift=0; 



-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local SN;
local LN;
local Method; 
 local BBMethod;
local source = nil;
local first;
local EMAS = nil;
local EMAL = nil;
local Show_Component;
-- Streams block
local MACD = nil;
local N, NM;
local A, AM;
local ATR;
--local Squeeze;
local FontSize;
local BBMA;
local BTL, BBL;
local KTL, KBL;
local In, Out;
local AP;
local font;
function ReleaseInstance()
       core.host:execute("deleteFont", font);
	   
end

local Signal;

-- Routine
function Prepare(nameOnly)
    In= instance.parameters.In;
	Out= instance.parameters.Out;
	AP= instance.parameters.AP;
    Show_Component= instance.parameters.Show_Component;
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
	Method = instance.parameters.Method;
	BBMethod = instance.parameters.BBMethod;
     
	N = instance.parameters.N;
	NM = instance.parameters.NM;
	AM = instance.parameters.AM;
	A = instance.parameters.A;
	FontSize = instance.parameters.FontSize;
    source = instance.source;
	
       local name = profile:id() .. "(" .. source:name() .. ", " .. SN .. ", " .. LN   .. ", " .. N .. ", " .. NM .. ", " .. BBMethod .. ", " .. A .. ", " .. AM.. ", " .. AP.. ", " .. Method.. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	
	ToTime=instance.parameters.ToTime;
	
	if ToTime == 1 then
	ToTime=core.TZ_EST;
	elseif ToTime == 2 then
	ToTime=core.TZ_UTC;
	elseif ToTime == 3 then
	ToTime=core.TZ_LOCAL;
	elseif ToTime == 4 then
	ToTime=core.TZ_SERVER;
	elseif ToTime == 5 then
	ToTime=core.TZ_FINANCIAL;
	elseif ToTime == 6 then
	ToTime=core.TZ_TS;
	end
	
    
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	Size=instance.parameters.Size;
	
	
	
	font = core.host:execute("createFont", "Wingdings", FontSize, false, false);
	
    assert(core.indicators:findIndicator(BBMethod) ~= nil, BBMethod .. " indicator must be installed");
	 BBMA = core.indicators:create(BBMethod, source.close, N);
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA = core.indicators:create(Method, source.close, A);
	ATR = core.indicators:create("ATR", source, AP);
	EMAS = core.indicators:create("EMA", source.close, SN);
    EMAL = core.indicators:create("EMA", source.close, LN);
	first= math.max(BBMA.DATA:first(), MA.DATA:first(),ATR.DATA:first() ,EMAS.DATA:first(),EMAL.DATA:first() );
	if Show_Component then
	
	BTL= instance:addStream("BTL", core.Line, name .. ".BB Top Line", "BB Top Line", instance.parameters.BL, first);	
    BTL:setPrecision(math.max(2, instance.source:getPrecision()));
	BBL= instance:addStream("BBL", core.Line, name .. ".BB Bottom Line", "BB Bottom Line", instance.parameters.BL, first);	
    BBL:setPrecision(math.max(2, instance.source:getPrecision()));
	 
	
	KTL= instance:addStream("KTL", core.Line, name .. ".Keltner Top Line", "Keltner Top Line", instance.parameters.KL, first);	
    KTL:setPrecision(math.max(2, instance.source:getPrecision()));
	KBL= instance:addStream("KBL", core.Line, name .. ".Keltner Bottom Line", "Keltner Bottom Line", instance.parameters.KL, first);
    KBL:setPrecision(math.max(2, instance.source:getPrecision()));
	
    core.host:execute ("attachOuputToChart", "BTL");	
	core.host:execute ("attachOuputToChart", "BBL");	
	core.host:execute ("attachOuputToChart", "KTL");	
	core.host:execute ("attachOuputToChart", "KBL");	
	
	else
	BTL= instance:addInternalStream(0, 0);
	BBL= instance:addInternalStream(0, 0);
	
	KTL= instance:addInternalStream(0, 0);
	KBL= instance:addInternalStream(0, 0);
	end
	
	
    
	MACD = instance:addStream("MACD", core.Bar, name .. ".MACD", "MACD", instance.parameters.MACDUP, first);	
    MACD:setPrecision(math.max(2, instance.source:getPrecision()));
	
	
	for i= 1, Number , 1 do
		Alert[i]=instance:addInternalStream(0, 0);
		AlertLevel[i]=instance:addInternalStream(0, 0);
     end
	
	Initialization();	
	instance:ownerDrawn(true);	 
	
	Signal= instance:addInternalStream(0, 0);
	
	end
	
	local init = false;
 
function Draw(stage, context)
 
	 if stage~= 2 then
	  return;
	  end
	  
	  
	
        if not init then
           context:createFont (1, "Wingdings", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
		
		

		
		for period= math.max(context:firstBar (),source:first()), math.min( context:lastBar (), source:size()-1), 1 do
		
		 
		
		 x, x1, x2= context:positionOfBar (period);
		 
		 for Level = 1 , Number ,  1 do
		   if Alert[Level]:hasData(period) then
		     
		    if Alert[Level][period]== 1 then
			visible, y = context:pointOfPrice (AlertLevel[Level][period]);
			
			  width, height = context:measureText (1,  "\225", 0);
              context:drawText (1,   "\225", UpTrendColor, -1,  x-width/2 ,  y , x+width/2 , y+height, 0 );	
   
			elseif Alert[Level][period]== -1 then
			visible, y = context:pointOfPrice (AlertLevel[Level][period]);
			width, height = context:measureText (1,  "\226", 0);
			 context:drawText (1,   "\226", DownTrendColor, -1,  x-width/2  ,  y-height, x+width/2 ,y, 0 );	
		    end
		  end
		    
		 
		end
		end
		
  
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
   
    MA:update(mode);
 ATR:update(mode);
 EMAS:update(mode);
    EMAL:update(mode);	
	  BBMA:update(mode);
	  
	  if period < first then
	  return;
	  end
	  
	
    CalculateMACD( period);	
	BB(period);
	Keltner(period);
	
	
	if BTL[period] < KTL[period]  and  BBL[period] >KBL[period] then
	core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, 0, core.CR_CHART, core.H_Center, core.V_Center,
                             font, Out, "\108");
	Signal[period]=2;						 
    else
     core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, 0, core.CR_CHART, core.H_Center, core.V_Center,
                             font, In, "\108");
	Signal[period]=1;							 
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
	Activate (2, period);
end

function Keltner(period)

        KTL[period] = MA.DATA[period] + ATR.DATA[period]*AM;
        KBL[period] = MA.DATA[period] - ATR.DATA[period]*AM;
end

function CalculateMACD (period)
	
  
	
      
         MACD[period] = EMAS.DATA[period] - EMAL.DATA[period];
   
		
			if MACD[period] > MACD[period-1] then
			MACD:setColor(period, instance.parameters.MACDUP); 
			else
			MACD:setColor(period, instance.parameters.MACDDOWN); 
			end
			
end			

function BB(period)

      
		
	    if period < BBMA.DATA:first() then
		return;
		end
		
        local ml = BBMA.DATA[period];
        local d = mathex.stdev(source.close, period - N + 1, period);
        local Dd = NM * d;
        BTL[period] = ml + Dd;
        BBL[period] = ml - Dd;
       
 

end



function Activate (id, period)


   Alert[id][period]=0;
   
   
  
  
	  if id == 1  and ON[id]  then
	  
	       
			if  Signal[period] == 1 
			and   Signal[period-1] ~= 1 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= 0 
						   
			
			 
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " In Squeeze  ");
							  SendAlert( Label[id]," In Squeeze "); 
							  Pop(Label[id], " In Squeeze ", period );  
							  OnlyOnceFlag=false;
							  end
							  
		 
	  
	  end
	  end
	  
	    if id == 2  and ON[id]  then
	  
	       
			if  Signal[period] == 2 
			and   Signal[period-1] ~= 2 
			then
			           
						    
         
                Alert[id][period]= -1;	
 				AlertLevel[id][period]= 0 
						   
			
			 
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Out Squeeze  ");
							  SendAlert( Label[id]," Out Squeeze "); 
							  Pop(Label[id], " Out Squeeze ", period );  
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

 


function EmailAlert( label , Subject)

if not SendEmail then
return
end
 
   local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
    
   local delim = "\013\010";  
   local Note=  profile:id().. delim.. " Label : " ..label  .. delim .. " Alert : " .. Subject ;   
   local Symbol= "Instrument : " .. source:instrument() ;
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;  
   
   
    local TF= "Time Frame : " .. source:barSize();       
    local text = Note  .. delim ..  Symbol .. delim .. TF  .. delim .. Time;
	
	
 
   terminal:alertEmail(Email, profile:id(), text);
end
	 
	 
	 
	 
function Pop(AlertLabel , AlertText, period)
 
 
 if not Show then
   return;
   end
 
   local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
   
   local delim = "\013\010";   
	
   local Symbol= "Instrument : " .. source:instrument() ;
   local TF= "Time Frame : " .. source:barSize();   
    local Time =  "Date : " .. DATA.month.." / ".. DATA.day .. delim .. " Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
    local Text= Symbol .. delim ..  TF .. delim ..  Time.. delim ..  AlertLabel .. ":" ..    AlertText     
   core.host:execute ("prompt", 1, profile:id(),  Text );


end

function SoundAlert(Sound)
 if not PlaySound then
 return;
 end
 
 terminal:alertSound(Sound, RecurrentSound);
end

function EmailAlert(AlertLabel , AlertText, period)

if not SendEmail then
return
end

   local delim = "\013\010";   

     local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
	
   local Symbol= "Instrument : " .. source:instrument() ;
   local TF= "Time Frame : " .. source:barSize();   
    local Time =  "Date : " .. DATA.month.." / ".. DATA.day .. delim .. " Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
   
    local Text= Symbol .. delim ..  TF .. delim ..  Time.. delim ..  AlertLabel .. ":" ..    AlertText  
	
 
 terminal:alertEmail(Email, profile:id(), Text);
end
	 


function SendAlert(AlertLabel , AlertText, period)
    if not ShowAlert then
        return;
    end
	
	local delim = "\013\010";  
	
	 local now = core.host:execute("getServerTime");
	now = core.host:execute ("convertTime",  core.TZ_EST, ToTime, now);
	local DATA = core.dateToTable (now);
	
   local Symbol= "Instrument : " .. source:instrument() ;
   local TF= "Time Frame : " .. source:barSize();   
    local Time =  "Date : " .. DATA.month.." / ".. DATA.day .. delim ..  "Time :"   .. DATA.hour  .. " / ".. DATA.min .." / ".. DATA.sec; 
  
    local Text= Symbol .. delim ..  TF .. delim ..  Time.. delim ..  AlertLabel .. ":" ..    AlertText  
	
 
    terminal:alertMessage(source:instrument(), source[NOW], Text, source:date(NOW));
end