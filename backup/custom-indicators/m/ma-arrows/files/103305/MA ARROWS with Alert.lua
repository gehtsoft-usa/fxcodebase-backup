-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62872
-- Id: 16395

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+


function Init()
    indicator:name("Advanced fractal");
    indicator:description("Predicts a reversal in the current trend.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Period", "Period",10);
	indicator.parameters:addInteger("FastPeriod", "Fast MA Period", "Period",3);
	indicator.parameters:addString("FastMethod", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("FastMethod", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("FastMethod", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("FastMethod", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("FastMethod", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("FastMethod", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("FastMethod", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("FastMethod", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("FastMethod", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("SlowPeriod", "Fast MA Period", "Period",3);
	indicator.parameters:addString("SlowMethod", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("SlowMethod", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("SlowMethod", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("SlowMethod", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("SlowMethod", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("SlowMethod", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("SlowMethod", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("SlowMethod", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("SlowMethod", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("DOWN", "Down fractal color", "Down fractal color", core.rgb(255,0,0)); 
	indicator.parameters:addInteger("Size", "Font Size", "", 10, 1 , 100);	 
	
	indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
 
	
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
 
local OnlyOnceFlag;
local font;
local ShowAlert;
local first;
local source = nil;
local Price2, Price1;
local Indicator;
local Method1, Period1;
local Method2, Period2;
local  slow, Slow;
local Fast, fast;
local Shift=0;

local source;
local up, down;  
local Range;
local Period;
local first;
local FastPeriod, SlowPeriod;
local FastMethod, SlowMethod;
local Fast, Slow;
function Prepare(nameOnly)
    source = instance.source; 
	Period = instance.parameters.Period;
	FastPeriod= instance.parameters.FastPeriod;
	SlowPeriod= instance.parameters.SlowPeriod;
	FastMethod= instance.parameters.FastMethod;
	SlowMethod= instance.parameters.SlowMethod;
	
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	 
	Size=instance.parameters.Size;
  local name = profile:id() ;
	instance:name(name);
	if nameOnly then
		return;
	end
	font = core.host:execute("createFont", "Wingdings", Size, false, false);
	
    assert(core.indicators:findIndicator(FastMethod) ~= nil, FastMethod .. " indicator must be installed");
	Fast = core.indicators:create(FastMethod, source.close, FastPeriod);	
    assert(core.indicators:findIndicator(SlowMethod) ~= nil, SlowMethod .. " indicator must be installed");
	Slow = core.indicators:create(SlowMethod, source.open, SlowPeriod);
	
    up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.UP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.DOWN, 0);
	first=math.max(source:first()+Period, Fast.DATA:first(), Slow.DATA:first());
	Range = instance:addInternalStream(0, 0);
	 
	
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

function Update(period, mode)
 
      Fast:update(mode);
	  Slow:update(mode);
	  
      
	  Range[period]= source.high[period]-source.low[period];
		
       period=period-1;
	   
       if period < first+1 then
	   return;
	   end
	   
	   local Average= mathex.avg(Range, period-Period+1, period);	   
	   
	   
	   

	   
	   
	   up:setNoData (period);
	   down:setNoData (period);
	   
	   if ((Fast.DATA[period] > Slow.DATA[period]) and (Fast.DATA[period-1] < Slow.DATA[period-1]) and (Fast.DATA[period+1] > Slow.DATA[period+1])) then
        
      
			 down:set(period, source.low[period]-Range[period]*0.3, "\225");
			 
			 Activate (1, period,-1)
        
        elseif ((Fast.DATA[period] < Slow.DATA[period]) and (Fast.DATA[period-1] > Slow.DATA[period-1]) and (Fast.DATA[period+1] < Slow.DATA[period+1])) then
            
			 up:set(period , source.high[period]+ Range[period]*0.3, "\226");
			 
			  Activate (1, period, 1)
 
       end
	   
		    
	      
	 
end


function ReleaseInstance()
       core.host:execute("deleteFont", font);
end	   

function Activate (id, period,Flag)


	  if Live~= "Live" then
	period=period-1;
	Shift=2;
	else
	Shift=1;
	end
	
  
	  if id == 1  and ON[id]  then
	  
	       
			if Flag==1
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
			elseif  Flag==-1
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
	 


