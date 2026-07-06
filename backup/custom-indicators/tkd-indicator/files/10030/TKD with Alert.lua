-- Id: 15700

-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=3477

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

-- The indicator is Richard Tao Adaptive Stochastic KD with Trailing Signal  
-- Richard Tao Predictor serials number 2 version 1.1

-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("RichardTaoKDStochastic");
    indicator:description("Richard Tao Adaptive Stochastic");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Tao");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Periods for %K", "", 30, 2, 1000);
    indicator.parameters:addInteger("M", "Periods for Smooth", "", 3);
    indicator.parameters:addInteger("D", "Distance percentage", "", 100);
    indicator.parameters:addInteger("C", "Coefficient percentage", "", 100);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrT", "LineColor of the T", "", core.rgb(0, 64, 128));
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("clrF", "LineColor of the F", "", core.rgb(128, 64, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("clrS", "LineColor of the S", "", core.rgb(0, 128, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);
	
	indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("UpTrendColor1", "1. Alert Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("DownTrendColor1", "1. Alert Down Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("UpTrendColor2", "2. Alert Up Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("DownTrendColor2", "2. Alert Down Trend Color", "", core.rgb(0, 0, 255));
	
	indicator.parameters:addInteger("Size", "Label Size", "", 10, 1 , 100);
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, " T/S Cross");
    Parameters (2, " T/F Cross");		
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
local UpTrendColor1, DownTrendColor1;
local UpTrendColor2, DownTrendColor2;
local OnlyOnceFlag;
local font;
local ShowAlert;
local Shift=0; 


-- Parameters block
local fk;
local mk;
local md;

local source = nil;
local smin = nil;
local smax = nil;
local FastK = nil;
local fFirst = nil;

-- Streams block
local T = nil;
local M = nil;
local F = nil;
local S = nil;
-- Processes indicator parameters and creates output streams
function Prepare(nameOnly)
    
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	UpTrendColor1 = instance.parameters.UpTrendColor1;
	DownTrendColor1 = instance.parameters.DownTrendColor1;
	UpTrendColor2 = instance.parameters.UpTrendColor2;
	DownTrendColor2 = instance.parameters.DownTrendColor2;
	Size=instance.parameters.Size;
	font = core.host:execute("createFont", "Wingdings", Size, false, false);
	

	 fk = instance.parameters.N;
    mk = instance.parameters.M;
    if mk < 4 then md = 3 else md = mk end
    source = instance.source;

    smin = instance:addInternalStream(source:first() + fk - 1, 0);
    smax = instance:addInternalStream(source:first() + fk - 1, 0);
    FastK = instance:addInternalStream(smin:first(), 0);
    fFirst = FastK:first();
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. fk .. ", " .. mk .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end

    T = instance:addStream("T", core.Line, name .. ".T", "T", instance.parameters.clrT, fFirst + mk);
    T:setPrecision(math.max(2, instance.source:getPrecision()));
	T:setWidth(instance.parameters.width1);
    T:setStyle(instance.parameters.style1);
		
    F = instance:addStream("F", core.Line, name .. ".F", "F", instance.parameters.clrF, T:first())
    F:setPrecision(math.max(2, instance.source:getPrecision()));
	F:setWidth(instance.parameters.width2);
    F:setStyle(instance.parameters.style2);
		
    S = instance:addStream("S", core.Line, name .. ".S", "S", instance.parameters.clrS, T:first());
    S:setPrecision(math.max(2, instance.source:getPrecision()));
	S:setWidth(instance.parameters.width3);
    S:setStyle(instance.parameters.style3);
		
		
    M = instance:addInternalStream(T:first()+md, 0);
	
    T:addLevel(50+instance.parameters.D/100*25);
    T:addLevel(50-instance.parameters.D/100*25);
	
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


local prehilo = 0;
-- Indicator calculation routine
function Update(period, mode)
   if period < fFirst then
   return;
   end
   
        local rangeT = core.rangeTo(period, fk);
        local minLow = core.min(source.low, rangeT);
        local maxHigh = core.max(source.high, rangeT);
        smin[period] = source.close[period] - minLow;
        smax[period] = maxHigh - minLow;
        if smax[period] > 0 then
            FastK[period] = smin[period] / smax[period] * 100;
        else
            FastK[period] = 50;
        end
    
    if period  < T:first() then
	return;
	end
        local rangeT = core.rangeTo(period, mk);
        local sumMax = core.sum(smax, rangeT);
        if sumMax == 0 then
            T[period] = 50;
        else
            local sumMin = core.sum(smin, rangeT);
            T[period] = sumMin / sumMax * 100;
        end
   
    if period < M:first() then
	return;
	end
	
	
        M[period] = core.avg(T, core.rangeTo(period, md));
        
        F[period] = GetFastSignal(T, F, instance.parameters.D/100*25, instance.parameters.C/100, period);
        S[period] = GetSlowSignal(T, F, S, fk, instance.parameters.D/100*25, instance.parameters.C/100, period);
  
    
	
	  core.host:execute ("removeLabel", source:serial(period)); 
	  
	 Activate (1, period);
	 Activate (2, period)
end
function GetFastSignal(T, F, dist, coef, period)
    local cent = 50;
    local dift = (T[period] - T[period-1]);
    local thet = T[period];
    local pres = cent;
    if F:hasData(period-1) then pres = (F[period-1]) end
    
    local signal = pres;
    local dire = 0;
    
    if (thet-pres)*dift > 0 then
        --move far
        if (thet-cent)*dift>0 and math.abs(thet-cent)-dist>0 
        then dire=0.5 else dire=0.1 end
    else
        --move near
        --if (thet-cent)*dift<0 and math.abs(thet-cent)-dist>0  then dire=0.5 end
        if (thet-cent)*dift<0 then dire=0.5 end
    end
    --set step follow
    signal = pres + (thet-pres)*dire*(coef);
    
    return signal
end

function GetSlowSignal(T, F, S, N, dist, coef, period)
    local cent = 50;
    local thet = T[period];
    local pret = T[period-1];
    local thef = F[period];
    local pref = F[period];
    local pres = cent;
    if S:hasData(period-1) then
        pres = (S[period-1]);
        pref = F[period-1];
    end
    
    local signal = pres;
    local dire = 0;
    
    if math.abs(thet-cent)-dist > 0 then
        if prehilo<=0 and (thet-cent)-dist>0 then prehilo=1 end
        if prehilo>=0 and (thet-cent)+dist<0 then prehilo=-1 end
    end
        
    if (thef-pref)*(pref-pres)<0 then
        --converge
        dire = -2.0;
        signal = pres + (thef-pref)*dire*(coef);
    else
        --diverge
        if (thef-pres)*(thef-cent)>0 then dire = 2.618/N else dire = 1/N end
        signal = pres + (thef-pres)*dire*(coef);
    end
    --boundry correction
    signal = math.max(0, signal);
    signal = math.min(100, signal);

    --crossesunder correction
    if (thet-signal)<=0 and pret-pres>=0 and (thet-cent)+dist>0 then signal=cent+dist end 
    if (thet-signal)<=0 and pret-pres>=0 and (thet-cent)+dist<0 then signal=cent end 
    --crossesover correction
    if (thet-signal)>=0 and pret-pres<=0 and (thet-cent)-dist<0 then signal=cent-dist end 
    if (thet-signal)>=0 and pret-pres<=0 and (thet-cent)-dist>0 then signal=cent end 
     
    return signal
end


function ReleaseInstance()
       core.host:execute("deleteFont", font);
end	   

function Activate (id, period)

  
     --[[
	 An alert for T and S cross to define up and down. An additional alert with different color and sound options for T and F cross.
	 This would further define up in up, down in up, down in down and up in down. 
	 ]]
  
	  if id == 1  and ON[id]  then
	  
	       
			if  T[period] > S[period] 
			and   T[period-1] <= S[period-1] 
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, S[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor1, "\225");

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Up Trend ", period);
							  SendAlert("  Up Trend  ");  
							        
									Pop(Label[id], "  Up Trend  " );  	
								    
								 
							  end
			elseif  T[period] < S[period] 
			and   T[period-1] >= S[period-1] 
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, S[period], core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor1, "\226");						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Down Trend ", period);	
								 
									Pop(Label[id], "  Down Trend  " );  	
								    SendAlert(" Down Trend  ");
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
	  
	  if id == 2  and ON[id]  then
	  
	       
			if  T[period] > F[period] 
			and   T[period-1] <= F[period-1] 
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, F[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor2, "\225");

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  
							  iNote=" Up in ";
							  if T[period] < F[period] then
							  iNote=iNote.. " Down Trend ";
							  else
							   iNote=iNote.. " Up Trend ";
							  end
							   
							   
							  EmailAlert(  Label[id], iNote , period);
							  SendAlert(iNote);  
							  Pop(Label[id], iNote );  	
							
 							
								 
							  end
			elseif  T[period] < F[period] 
			and   T[period-1] >= F[period-1] 
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, F[period], core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor2, "\226");						   
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 
							 iNote=" Down in ";
							  if T[period] < F[period] then
							  iNote=iNote.. " Down Trend ";
							  else
							   iNote=iNote.. " Up Trend ";
							  end
							 
							 EmailAlert( Label[id] , iNote , period);	
							 Pop(Label[id], iNote );  	
							 SendAlert( iNote );
							 
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
	 

