-- Id: 16081

-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=63500

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
    indicator:name("Four Moving Average Alert");
    indicator:description("");
   indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
   
    
    indicator.parameters:addGroup("Calculation");		
	indicator.parameters:addString("Price1", "1. MA Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");	
    indicator.parameters:addInteger("Period1", "MA Period", "", 10, 2, 4000 );
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
    indicator.parameters:addStringAlternative("Method1", "DEMA", "DEMA" , "DEMA");
	indicator.parameters:addStringAlternative("Method1", "TEMA", "TEMA" , "TEMA");  
	indicator.parameters:addStringAlternative("Method1", "PAR_MA", "PAR_MA" , "PAR_MA");  

	
	indicator.parameters:addString("Price2", "2. MA Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");	
	indicator.parameters:addInteger("Period2", "MA Period", "", 20, 2, 4000);
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
    indicator.parameters:addStringAlternative("Method2", "DEMA", "DEMA" , "DEMA");
	indicator.parameters:addStringAlternative("Method2", "TEMA", "TEMA" , "TEMA");  
	indicator.parameters:addStringAlternative("Method2", "PAR_MA", "PAR_MA" , "PAR_MA");  
	
	
	
	indicator.parameters:addString("Price3", "3. MA Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price3", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price3", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price3", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price3","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price3", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price3", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price3", "WEIGHTED", "", "weighted");	
    indicator.parameters:addInteger("Period3", "MA Period", "", 30, 2, 4000 );
	indicator.parameters:addString("Method3", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
    indicator.parameters:addStringAlternative("Method3", "DEMA", "DEMA" , "DEMA");
	indicator.parameters:addStringAlternative("Method3", "TEMA", "TEMA" , "TEMA");  
	indicator.parameters:addStringAlternative("Method3", "PAR_MA", "PAR_MA" , "PAR_MA");  

	
	indicator.parameters:addString("Price4", "4. MA Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price4", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price4", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price4", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price4","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price4", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price4", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price4", "WEIGHTED", "", "weighted");	
	indicator.parameters:addInteger("Period4", "MA Period", "", 40, 2, 4000);
	indicator.parameters:addString("Method4", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method4", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method4", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method4", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method4", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method4", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method4", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method4", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method4", "WMA", "WMA" , "WMA");
    indicator.parameters:addStringAlternative("Method4", "DEMA", "DEMA" , "DEMA");
	indicator.parameters:addStringAlternative("Method4", "TEMA", "TEMA" , "TEMA");  
	indicator.parameters:addStringAlternative("Method4", "PAR_MA", "PAR_MA" , "PAR_MA");  


		
	indicator.parameters:addGroup("Indicator Style");   
    indicator.parameters:addColor("color1", "1. MA color", "MA color", core.rgb(0,255,0));
	indicator.parameters:addInteger("width1", "MA Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style1", "MA Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "2. MA color", "MA color", core.rgb(255,0,0));
	indicator.parameters:addInteger("width2", "MA Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style2", "MA Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
 
    indicator.parameters:addColor("color3", "3. MA color", "MA color", core.rgb(0,0,255));
	indicator.parameters:addInteger("width3", "MA Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style3", "MA Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color4", "4. MA color", "MA color", core.rgb(128,128,128));
	indicator.parameters:addInteger("width4", "MA Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style4", "MA Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
	
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
local first;
local source = nil;
local Price2, Price1;
local Price3, Price4;
local Method1, Period1;
local Method2, Period2;
local Method3, Period3; 
local Method4, Period4; 
local  ma1, MA1, ma2,MA2, ma3, MA3,ma4, MA4; 
local Shift=0; 
 
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
	
	
	
	Price2 = instance.parameters.Price2;
	Price1 = instance.parameters.Price1;
	Method1 = instance.parameters.Method1;	
	Method2 = instance.parameters.Method2;
    Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;	
   
    
	Price3 = instance.parameters.Price3;
	Price4 = instance.parameters.Price4;
	Method3 = instance.parameters.Method3;	
	Method4 = instance.parameters.Method4;
    Period3 = instance.parameters.Period3;
	Period4 = instance.parameters.Period4; 
     
	source = instance.source; 


    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator( Method1 ) ~= nil, "Please, download and install ".. Method1 .. ".LUA indicator");
	assert(core.indicators:findIndicator( Method2 ) ~= nil, "Please, download and install ".. Method2 .. ".LUA indicator");
	assert(core.indicators:findIndicator( Method3 ) ~= nil, "Please, download and install ".. Method3 .. ".LUA indicator");
	assert(core.indicators:findIndicator( Method4 ) ~= nil, "Please, download and install ".. Method4 .. ".LUA indicator");
	
	font = core.host:execute("createFont", "Wingdings", Size, false, false);
	
	 -- Create short and long EMAs for the source
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    ma1 = core.indicators:create(Method1, source[Price1], Period1);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
	ma2 = core.indicators:create(Method2, source[Price2], Period2);
    assert(core.indicators:findIndicator(Method3) ~= nil, Method3 .. " indicator must be installed");
	ma3 = core.indicators:create(Method3, source[Price3], Period3);
    assert(core.indicators:findIndicator(Method4) ~= nil, Method4 .. " indicator must be installed");
	ma4 = core.indicators:create(Method4, source[Price4], Period4);
	
	first=math.max(ma1.DATA:first(),ma2.DATA:first(), ma3.DATA:first(), ma4.DATA:first() );

    MA1 = instance:addStream("MA1", core.Line, name .. ".MA1", "MA1", instance.parameters.color1,  first);
	MA1:setWidth(instance.parameters.width1);
    MA1:setStyle(instance.parameters.style1);
	
	MA2 = instance:addStream("MA2", core.Line, name .. ".MA2", "MA2", instance.parameters.color2,  first);
	MA2:setWidth(instance.parameters.width2);
    MA2:setStyle(instance.parameters.style2);
	
	MA3 = instance:addStream("MA3", core.Line, name .. ".MA3", "MA3", instance.parameters.color3,  first);
	MA3:setWidth(instance.parameters.width3);
    MA3:setStyle(instance.parameters.style3);
	
	
	MA4 = instance:addStream("MA4", core.Line, name .. ".MA4", "MA4", instance.parameters.color4,  first);
	MA4:setWidth(instance.parameters.width4);
    MA4:setStyle(instance.parameters.style4);
	   
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


 function Calculate(period, mode)
 
   
	
	 ma1:update(mode);
	 ma2:update(mode);
	 ma3:update(mode);
	 ma4:update(mode);

	 if   period < first then
	return;
	end
	
	MA1[period]= ma1.DATA[period];
	MA2[period]= ma2.DATA[period];
	MA3[period]= ma3.DATA[period];
	MA4[period]= ma4.DATA[period];
 
 end
 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 



    Calculate(period, mode);

    if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
	
	core.host:execute ("removeLabel", source:serial(period)); 
    
	
     if period < first then
	 return;
	 end
	
    Activate (1, period)
 
end

function ReleaseInstance()
       core.host:execute("deleteFont", font);
end	   

function Activate (id, period)

  
	  if id == 1  and ON[id]  then
	  
	       
			if
			(
			(source.close[period] > MA1[period] 
			and source.close[period-1] <= MA1[period-1] 
			)
			or
			(source.close[period] > MA2[period] 
			and source.close[period-1] <= MA2[period-1] 
			)
			or
			(source.close[period] > MA3[period] 
			and source.close[period-1] <= MA3[period-1] 
			)
			or
			(source.close[period] > MA4[period] 
			and source.close[period-1] <= MA4[period-1] 
			)
			)
			and source.close[period] > MA1[period] 
			and  source.close[period] > MA2[period] 
			and  source.close[period] > MA3[period] 
			and  source.close[period] > MA4[period] 
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART,source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
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
			elseif 
			 (
			(source.close[period] < MA1[period] 
			and source.close[period-1] >= MA1[period-1] 
			)
			or
			(source.close[period] < MA2[period] 
			and source.close[period-1] >= MA2[period-1] 
			)
			or
			(source.close[period] < MA3[period] 
			and source.close[period-1] >= MA3[period-1] 
			)
			or
			(source.close[period] < MA4[period] 
			and source.close[period-1] >= MA4[period-1] 
			)
			)
			and source.close[period] < MA1[period] 
			and  source.close[period] < MA2[period] 
			and  source.close[period] < MA3[period] 
			and  source.close[period] < MA4[period] 
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
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
	 

