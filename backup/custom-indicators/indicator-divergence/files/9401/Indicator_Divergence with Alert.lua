-- Id: 16955
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3846

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Indicator Divergence");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");   
    indicator.parameters:addString("IN", "Indicator", "", "");
    indicator.parameters:setFlag("IN",core.FLAG_INDICATOR);
    indicator.parameters:addString("Price", "Price", "", "close");
    indicator.parameters:addStringAlternative("Price", "close", "", "close");
    indicator.parameters:addStringAlternative("Price", "open", "", "open");
    indicator.parameters:addStringAlternative("Price", "high", "", "high");
    indicator.parameters:addStringAlternative("Price", "low", "", "low");
    indicator.parameters:addStringAlternative("Price", "median", "", "median");
    indicator.parameters:addStringAlternative("Price", "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price", "weighted", "", "weighted");
    indicator.parameters:addInteger("Frames", "Frames", "Frames", 5);
    indicator.parameters:addBoolean("I", "Indicator mode", "Keep true value to display labels and lines. Set this parameter to false when the indicator is used in another indicator.", true);
	indicator.parameters:addBoolean("Simple", "Simple Fractal", "", false);
	
	indicator.parameters:addGroup("Style");  
    indicator.parameters:addColor("D_color", "Color of Divergence line", "", core.rgb(0, 155, 255));
    indicator.parameters:addColor("UP_color", "Color of Uptrend", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DN_color", "Color of Downtend", "", core.rgb(0, 255, 0));
	
	
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
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, "Bullish");		
	Parameters (2, "Bearish");	

end

function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);


    indicator.parameters:addFile("Up"..id, Label .. " Up Trend Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Down Trend Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local Number = 2;
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
local I;
local DD;
local UP_color;
local DN_color;
local Price;
local Frames;

local first;
local source = nil;

-- Streams block
local iD = nil;
local UP = nil;
local DN = nil;
local Ind = nil;
local lineid = nil;
local Signal;
local Simple;
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
	Simple=instance.parameters.Simple;
	
    I = instance.parameters.I;
    DD = instance.parameters.DD;
    Price = instance.parameters.Price;
    UP_color = instance.parameters.UP_color;
    DN_color = instance.parameters.DN_color;
    Frames = instance.parameters.Frames;
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.IN .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    local ind_ = core.indicators:findIndicator(instance.parameters:getString("IN"));
    local params = instance.parameters:getCustomParameters("IN");
    if  ind_:requiredSource() == core.Tick then
     if Price=="close" then
      Ind = ind_:createInstance(source.close, params);
     elseif Price=="open" then
      Ind = ind_:createInstance(source.open, params);
     elseif Price=="high" then
      Ind = ind_:createInstance(source.high, params);
     elseif Price=="low" then
      Ind = ind_:createInstance(source.low, params);
     elseif Price=="median" then
      Ind = ind_:createInstance(source.median, params);
     elseif Price=="typical" then
      Ind = ind_:createInstance(source.typical, params);
     else
      Ind = ind_:createInstance(source.weighted, params);
     end
    else
     Ind = ind_:createInstance(source, params);
    end 
    first = Ind.DATA:first();

    iD = instance:addStream(instance.parameters.IN, core.Line, name .. "." .. instance.parameters.IN, instance.parameters.IN, instance.parameters.D_color, first, -1);
    iD:setPrecision(math.max(2, instance.source:getPrecision()));
    if I then
        UP = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.UP_color, -1);
        DN = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.DN_color, -1);
    else
        UP = instance:addStream("UP", core.Bar, name .. ".UP", "UP", instance.parameters.D_color, first, -1);
    UP:setPrecision(math.max(2, instance.source:getPrecision()));
        DN = instance:addStream("DN", core.Bar, name .. ".DN", "DN", instance.parameters.D_color, first, -1);
    DN:setPrecision(math.max(2, instance.source:getPrecision()));
    end
	
	Signal = instance:addInternalStream(0, 0);
	
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



local pperiod = nil;
local pperiod1 = nil;
local line_id = 0;

-- Indicator calculation routine
function Update(period, mode)


    period = period - 1;
	
   
       -- if recaclulation started - remove all
    if pperiod ~= nil and pperiod > period then
        core.host:execute("removeAll");
    end
    pperiod = period;
    -- process only candles which are already closed closed.
    if pperiod1 ~= nil and pperiod1 == source:serial(period) then
        return ;
    end
    pperiod1 = source:serial(period)
   

    Ind:update(mode);
    if period >= first then
        iD[period] = Ind.DATA[period];
		--D
         if Simple then
		            if period >= first + 2 then
						processBullish(period-1);
						processBearish(period-1);
					end
		 else
					if period >= first + 2 then
						processBullish(period - 2);
						processBearish(period - 2);
					end
	     end
    end
   
   
    if Simple then
   
			if Live~= "Live" then
			period=period-2;
			Shift=3;
			else
			period=period-1;
			Shift=2;
			end
	
	else
	
			if Live~= "Live" then
			period=period-3;
			Shift=4;
			else
			period=period-2;
			Shift=3;
			end
	
	end
	
	
     if period < first then
	 return;
	 end
	
    Activate (1, period);
	Activate (2, period);
	
end

function processBullish(period)
    if isTrough(period) then
        local curr, prev;
        curr = period;
        prev = prevTrough(period);
        if prev ~= nil then
            if Ind.DATA[curr] > Ind.DATA[prev] and source.low[curr] < source.low[prev] then
                if I then
                    DN:set(curr, Ind.DATA[curr], "\225", "Classic bullish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), Ind.DATA[prev], source:date(curr), Ind.DATA[curr], DN_color);
					Signal[curr]=1;
                else
                    DN[period] = curr - prev;
					Signal[curr]=1;
                end
            elseif Ind.DATA[curr] < Ind.DATA[prev] and source.low[curr] > source.low[prev] then
                if I then
                    DN:set(curr, Ind.DATA[curr], "\225", "Reversal bullish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), Ind.DATA[prev], source:date(curr), Ind.DATA[curr], DN_color);
					Signal[curr]=2;
                else
                    DN[period] = -(curr - prev);
					Signal[curr]=2;
                end
            end
        end

    end
end

function isTrough(period)
    local i;
    if Ind.DATA[period] < Ind.DATA[period - 1] and Ind.DATA[period] < Ind.DATA[period + 1] then
        for i = period - 1, period-Frames, -1 do
            if i<=first then
             return true;
            end
            if Ind.DATA[period]>Ind.DATA[i] then
             return false;
            end
        end
        return true;
    end
    return false;
end

function prevTrough(period)
    local i;
    for i = period - 5, first, -1 do
        if Ind.DATA[i] <= Ind.DATA[i - 1] 
		and (Ind.DATA[i] < Ind.DATA[i - 2] or Simple)
		and	Ind.DATA[i] <= Ind.DATA[i + 1] 
		and (Ind.DATA[i] < Ind.DATA[i + 2] or Simple)
		then
           return i;
        end
    end
    return nil;
end

function processBearish(period)
    if isPeak(period) then
        local curr, prev;
        curr = period;
        prev = prevPeak(period);
        if prev ~= nil then
            if Ind.DATA[curr] < Ind.DATA[prev] and source.high[curr] > source.high[prev] then
                if I then
                    UP:set(curr, Ind.DATA[curr], "\226", "Classic bearish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), Ind.DATA[prev], source:date(curr), Ind.DATA[curr], UP_color);
					Signal[curr]=3;
                else
                    UP[period] = curr - prev;
					Signal[curr]=3;
                end
            elseif Ind.DATA[curr] > Ind.DATA[prev] and source.high[curr] < source.high[prev] then
                if I then
                    UP:set(curr, Ind.DATA[curr], "\226", "Reversal bearish");
                    line_id = line_id + 1;
                    core.host:execute("drawLine", line_id, source:date(prev), Ind.DATA[prev], source:date(curr), Ind.DATA[curr], UP_color);
					Signal[curr]=4;
                else
                    UP[period] = -(curr - prev);
					Signal[curr]=4;
                end
            end
        end

    end
end

function isPeak(period)
    local i;
    if Ind.DATA[period] > Ind.DATA[period - 1] and Ind.DATA[period] > Ind.DATA[period + 1] then
        for i = period - 1, period-Frames, -1 do
            if i<=first then
             return true;
            end
            if Ind.DATA[period]<Ind.DATA[i] then
             return false;
            end
        end
        return true;
    end
    return false;
end

function prevPeak(period)
    local i;
    for i = period - 5, first, -1 do
        if Ind.DATA[i] >= Ind.DATA[i - 1] 
		and (Ind.DATA[i] > Ind.DATA[i - 2] or Simple)
		and Ind.DATA[i] >= Ind.DATA[i + 1]
		and (Ind.DATA[i] > Ind.DATA[i + 2] or Simple)
		then
           return i;
        end
    end
    return nil;
end



function Activate (id, period)


 
   
   
  
  
	  if id == 1  and ON[id]  then
	  
	       
			if  Signal[period]== 1
			and   Signal[period-1]~= 1
			then
			           
						    
         
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Classic Divergence ", period);
							  SendAlert( Label[id]," Classic Divergence ", period); 
							  Pop(Label[id], " Classic Divergence ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif  Signal[period]== 2
			and   Signal[period-1]~= 2
            then			
			
			            			 
			          
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Reversal Divergence ", period);								 
							 Pop(Label[id], " Reversal Divergence ", period );  	
							 SendAlert( Label[id]," Reversal Divergence ", period);
							 OnlyOnceFlag=false;
			                 end			   
	         end
			
	  
	 
	  end
	  
	  
	   if id == 2  and ON[id]  then
	  
	       
			if  Signal[period]== 3
			and   Signal[period-1]~= 3
			then
			           
						    
         
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Classic Divergence ", period);
							  SendAlert( Label[id]," Classic Divergence ", period); 
							  Pop(Label[id], " Classic Divergence ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif  Signal[period]== 4
			and   Signal[period-1]~= 4
            then			
			
			            			 
			          
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Reversal Divergence ", period);								 
							 Pop(Label[id], " Reversal Divergence ", period );  	
							 SendAlert( Label[id]," Reversal Divergence ", period);
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

 


function EmailAlert( label , Subject, period)

if not SendEmail then
return
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
	 
	 
	 
	 

function Pop(label , Subject, period)
  
   if not Show then
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
	
   
   core.host:execute ("prompt", 1, label , text );


end


function SendAlert(label ,Subject, period)
    if not ShowAlert then
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
	
 
    terminal:alertMessage(source:instrument(), source[NOW], text, source:date(NOW));
end

 
 
 
