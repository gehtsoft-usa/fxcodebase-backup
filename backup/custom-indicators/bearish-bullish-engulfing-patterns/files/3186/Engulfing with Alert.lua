-- Id: 16127
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1613&p=3186#p3186

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
    indicator:name("Engulfing Bar");
    indicator:description("Bar Helper");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addBoolean("Complet", "Use Complet candle", "", false);
	indicator.parameters:addBoolean("Same", "Same Color Filter", "", false);	
    indicator.parameters:addBoolean("ma", "MA Filter", "", false);
	
	indicator.parameters:addString("ShowTrend", "Up/Down Trend Filter", "", "Both");
    indicator.parameters:addStringAlternative("ShowTrend", "Both", "", "Both");
    indicator.parameters:addStringAlternative("ShowTrend", "Up", "", "Up");
	indicator.parameters:addStringAlternative("ShowTrend", "Down", "", "Down");
	
	indicator.parameters:addInteger("Period", "MA Period", "Period" , 50);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
	
	indicator.parameters:addGroup("Style");	

	indicator.parameters:addColor("Top", "Color of Bullish bar", "Color of Bullish bar", core.rgb(255, 0, 255));
	indicator.parameters:addColor("Bottom", "Color of Bearish bar", "Color of Bearish bar", core.rgb(0, 0, 0));
	indicator.parameters:addString("Type", "Presentation Type", "", "Arrows");
    indicator.parameters:addStringAlternative("Type", "Arrows", "", "Arrows");
    indicator.parameters:addStringAlternative("Type", "Candles Color", "", "Color");
	indicator.parameters:addColor("UP", "Color of Up Candle", "Color of Up Candle", core.COLOR_UPCANDLE);
	indicator.parameters:addColor("DOWN", "Color of Down Candle", "Color of Down Candle", core.COLOR_DOWNCANDLE);
	
	
	
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

	
	Parameters (1, "Engulfing");	
		
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
local ShowTrend;
local Number = 1;
local Up={};
local Down={};
local Label={};
local ON={};
local Email;
local SendEmail;
local RecurrentSound ,SoundFile  ;
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
local Shift=0; 
 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local UP, DOWN;
local Method;
local first;
local source = nil;
local ma, MA;
-- Streams block
local up = nil;
local down = nil;
local Period;
local Same=nil
local Bar=nil;
local Type;
local open=nil;
local close=nil;
local high=nil;
local low=nil;
local Complet;
local Signal;
-- Routine
function Prepare()
    source = instance.source;
	ShowTrend =  instance.parameters.ShowTrend;
	Complet =  instance.parameters.Complet;
    Type =  instance.parameters.Type;
	Same =  instance.parameters.Same;
	Method =  instance.parameters.Method;
	ma =  instance.parameters.ma;
	UP =  instance.parameters.UP;
	DOWN =  instance.parameters.DOWN;
	Period =  instance.parameters.Period;
	
	
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
		
	
	
    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
    if (nameOnly) then
        return;
	end

    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA = core.indicators:create(Method, source.close,Period);
	
	 first = MA.DATA:first();
	
	
	Signal = instance:addInternalStream(0, 0);
	
    if Type == "Arrows" then	
	down = instance:createTextOutput ("Up", "Up", "Wingdings", 20, core.H_Center, core.V_Top, instance.parameters.Bottom, 0);
    up = instance:createTextOutput ("Down", "Down", "Wingdings", 20, core.H_Center, core.V_Bottom, instance.parameters.Top, 0);
	else
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), source:first())
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0),  source:first())
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0),  source:first())
    instance:createCandleGroup("Bars", "", open, high, low, close);
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
    
	if Type == "Arrows" then
    up:setNoData (period);
	down:setNoData (period);
	else
	
	
	    high[period]= source.high[period];
		low[period]= source.low[period];		   
		close[period] = source.close[period];
		open[period]  = source.open[period];
	
	
		if source.close[period] > source.open[period] then
		open:setColor(period, UP );
		else
		open:setColor(period, DOWN );
		end
	end

    if period < first+1  then	
	return;
	end
	
	
	Signal[period]=0;
			
			if Same
			and ((source.close[period] > source.open[period] and  source.close[period-1] < source.open[period-1] )
			or(source.close[period] < source.open[period] and  source.close[period-1] > source.open[period-1]))
			then
			return;	  
			end
	 
	
	local Filter=nil;
	
	if ma then	
	
	    MA:update(mode);
		if source.close[period] > MA.DATA[period] then
		Filter = true;
		elseif source.close[period] < MA.DATA[period] then
		Filter = false;
		end	
	end
	
                
				    if  (B1(period) or B2(period))	
					and (Filter == nil or Filter == true)
					and ShowTrend~="Down"
					then
							 if Type == "Arrows" then
							up:set(period, source.low[period], "\225"); 
							else
							open:setColor(period, instance.parameters.Top );
							end
							
							Signal[period]=1;
					end
									
					
					if (S1(period) or S2(period))	
					and (Filter == nil or Filter == false)
					and ShowTrend~="Up"
                    then					
							 if Type == "Arrows" then
							down:set(period, source.high[period], "\226");
							else
							open:setColor(period, instance.parameters.Bottom );
							end
							
							Signal[period]=-1;
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
end



function B1 (period)


	if  not Complet then
	return 	false;
	end

 
if  source.low[period]<=  math.min( source.low[period-1]	, source.high[period-1])	
and source.close[period]>   math.max( source.low[period-1]	, source.high[period-1])		
then
return true;
end

end 

function S1 (period)

    if  not Complet then
	return false;
	end


if source.high[period] >=   math.max( source.low[period-1]	, source.high[period-1])	
and source.close[period]<   math.min( source.low[period-1]	, source.high[period-1])	
then
return true;
end

end 


function B2 (period)


     if   Complet then
	return false;
	end


if  source.open[period]<=  math.min( source.open[period-1]	, source.close[period-1])	
and source.close[period]>  math.max( source.open[period-1]	, source.close[period-1])	
then
return true;
end

end 

function S2 (period)


    if   Complet then
	return 	false;
	end

if  source.open[period]>=  math.max( source.open[period-1]	, source.close[period-1])	
and source.close[period] <  math.min( source.open[period-1]	, source.close[period-1])	
then
return true;
end

end 



function ReleaseInstance()
end	   

function Activate (id, period)

  
	  if id == 1  and ON[id]  then
	  
	       
			if  Signal[period] ==1 
			and    Signal[period-1] ~=1 
			then
			           
						    
           

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Bullish bar ", period);
							  SendAlert(" Bullish bar ");  
							        
									Pop(Label[id], " Bullish bar " );  	
								    
								 
							  end
			elseif  Signal[period] ==-1 
			and    Signal[period-1] ~=-1 
            then			
			
			            			 
			     
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Bearish bar ", period);	
								 
									Pop(Label[id], " Bearish bar " );  	
								    SendAlert("  Bearish bar ");
							 
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
	 



 