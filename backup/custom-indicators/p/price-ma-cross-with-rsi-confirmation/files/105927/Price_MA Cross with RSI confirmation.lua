
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63405

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
    indicator:name("Price_MA Cross with RSI confirmation");
    indicator:description("");
   indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
   
    
    indicator.parameters:addGroup("MA Calculation");		
	indicator.parameters:addBoolean("Show_MA", "Show MA", "", true );
    indicator.parameters:addInteger("Period", "MA Period", "", 14, 2, 2000 );
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "DEMA" , "DEMA");
	indicator.parameters:addStringAlternative("Method", "TEMA", "TEMA" , "TEMA");  
	indicator.parameters:addStringAlternative("Method", "PAR_MA", "PAR_MA" , "PAR_MA");  
	indicator.parameters:addStringAlternative("Method", "VARMA", "VARMA" , "VARMA");  
	
	indicator.parameters:addGroup("VARMA Calculation"); 
    indicator.parameters:addInteger("P1", "Period", "", 9, 2, 2000);
	indicator.parameters:addInteger("P2", "Smoothing", "", 2, 1, 200);

	indicator.parameters:addGroup("RSI Calculation");		
	indicator.parameters:addBoolean("Filter", "Use RSI Alert Filter ", "", true);	
    indicator.parameters:addInteger("RSI_Period", "RSI Period", "", 14, 2, 2000 );
	indicator.parameters:addDouble("BuyLevel", "Buy Level", "",50 );
	indicator.parameters:addDouble("SellLevel", "Sell Level", "", 50 );
    
    indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	indicator.parameters:addGroup("Line Style");
	 indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor", "Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DownTrendColor", "Down Trend Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	
	

	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, " Price/MA ");	
	
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
local BuyLevel, SellLevel;
local RSI, MA;
local Method, Period;
local RSI_Period;
local Shift=0; 
local Show_MA, ma;
local P1,P2;
local Filter;
-- Routine
function Prepare(nameOnly) 
    
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Filter= instance.parameters.Filter;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	Size=instance.parameters.Size;
	Show_MA= instance.parameters.Show_MA;
	P1= instance.parameters.P1;
	P2= instance.parameters.P2;
	
		
	Method = instance.parameters.Method;	
    Period = instance.parameters.Period;
	RSI_Period = instance.parameters.RSI_Period;	
   
	BuyLevel= instance.parameters.BuyLevel;
	SellLevel= instance.parameters.SellLevel; 
     
	source = instance.source; 
	
	 


    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. Method .. ", " .. Period .. ", " .. RSI_Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	font = core.host:execute("createFont", "Wingdings", Size, false, false);
	
	 -- Create short and long EMAs for the source
	 
	if Method== "VARMA" then
	assert(core.indicators:findIndicator(Method) ~= nil, "Please, download and install ".. Method.. ".LUA indicator");    	 
    MA = core.indicators:create(Method, source.close, P1,P2);
	else
	 MA = core.indicators:create(Method, source.close, Period);
	end
	
	RSI = core.indicators:create("RSI", source.close, RSI_Period);
	if Show_MA then	
	ma = instance:addStream("MA", core.Line, name .. ".MA", "MA", instance.parameters.color, MA.DATA:first());
    ma:setWidth(instance.parameters.width);
    ma:setStyle(instance.parameters.style);
	else
	ma = instance:addInternalStream(MA.DATA:first(), 0);
	end
	
	

	first=math.max(MA.DATA:first(),RSI.DATA:first() );
 
	   
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
-- TODO: Add your code for calculation output values
function Update(period, mode) 



     RSI:update(mode);
	 MA:update(mode);
	 
	 if period < MA.DATA:first() then
	 return;
	 end
	 
	 ma[period]=MA.DATA[period];

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
	  
	       
			if  source.close[period] >  MA.DATA[period] 
			and   source.close[period-1] <=  MA.DATA[period-1] 	
			then
			           
			 if RSI.DATA[period]> BuyLevel	 then		    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\254");
             else
			  core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\253");
			 end
 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and ( RSI.DATA[period]> BuyLevel	or not Filter)
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							  SendAlert("Crossed over");  
							        
									Pop(Label[id], " Cross Over " );  	
								    
								 
							  end
			elseif  source.close[period] <  MA.DATA[period] 
			and   source.close[period-1] >=  MA.DATA[period-1] 			
            then			
			
			            	if  RSI.DATA[period]< SellLevel then		 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART,  source.high[period], core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\254");						   
						   else
						    core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART,  source.high[period], core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\253");						   
						   end
		     U[id] = nil;
		                       
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and (RSI.DATA[period]< SellLevel or not Filter)
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
	 

