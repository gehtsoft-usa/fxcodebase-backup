-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62223

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
    indicator:name("Renko Stop");
    indicator:description("Renko Stop");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("decay", "Decay", "Decay", 250);
    indicator.parameters:addInteger("detection", "Detection", "Detection", 1);
    indicator.parameters:addInteger("smooth", "Smooth", "Smooth", 2);
	indicator.parameters:addInteger("rma_smooth", "RMA Smooth", "RMA Smooth", 12);
	
	
	indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("UpColor", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DownColor", "Color of Down", "Color of Down", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("transparency", "Channel transparency (%)", "", 70, 0, 100);
	
	
	indicator.parameters:addGroup("Mode");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");  

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
	
	Parameters (1, "Trend");
  	
   

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

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



local decay;
local detection;
local smooth;

local first;
local source = nil;

-- Streams block
local topfill = nil;
local botfill = nil;
local smoothprice, rma;
local dosc;
local rma_smooth;
local UpColor, DownColor;
local Color;
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
    font = core.host:execute("createFont", "Wingdings", Size, false, false);
   
    detection = instance.parameters.detection;
    smooth = instance.parameters.smooth;
	rma_smooth= instance.parameters.rma_smooth;
    source = instance.source;
    first = source:first()+detection;
	UpColor= instance.parameters.UpColor;
	DownColor= instance.parameters.DownColor;
	
	decay = instance.parameters.decay*source:pipSize();
	dosc= instance:addInternalStream(source:first(), 0);
	smoothprice= instance:addInternalStream(source:first()+smooth, 0);
	Color= instance:addInternalStream(source:first(), 0);
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(decay) .. ", " .. tostring(detection) .. ", " .. tostring(smooth) .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	    rma= instance:addInternalStream(source:first(), 0);
        topfill = instance:addStream("topfill", core.Line, name .. ".topfill", "topfill", UpColor, math.max(detection, smooth,rma_smooth));
        botfill = instance:addStream("botfill", core.Line, name .. ".botfill", "botfill", UpColor, math.max(detection, smooth,rma_smooth));
		instance:createChannelGroup("Channel", "Channel", topfill, botfill, UpColor, 100 - instance.parameters.transparency);

  
	
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
function Update(period)
 
		
	 Calculate(period );

    core.host:execute ("removeLabel", source:serial(period)); 
   
     if period < first then
	 return;
	 end
	
    Activate (1, period)
    
end

function  Calculate (period)
   if period < first or  not  source:hasData(period) then
	return;
	end
	ll, hh= mathex.minmax(source, period-detection+1, period); 
	
	
	local rprice= round(source.close[period]/decay, 0)*decay;
    local predosc= dosc[period-1]; 
	
	if hh > predosc + decay and hh+decay < predosc + decay  then
	dosc[period]= predosc + decay ;
	elseif hh > predosc + decay and hh+decay > predosc + decay  then
	dosc[period]=  rprice ;
	elseif ll < predosc - decay and ll-decay > predosc - decay then 
	dosc[period]= predosc - decay;
    elseif   ll < predosc - decay and ll-decay < predosc - decay then 
	dosc[period]= rprice;
    else
	dosc[period]= predosc;
	end
 
	
	if period < rma_smooth 
	or period < smooth 
	then
	return;
	end
	
	smoothprice[period] =  mathex.avg(source.close, period-smooth +1, period); 
	rma[period]= mathex.avg(dosc, period-rma_smooth+1, period);
	
	Color[period]=Color[period-1];

	if (smoothprice[period] >  rma[period] and smoothprice[period-1] <=  rma[period-1] )
	or (smoothprice[period] <  rma[period] and smoothprice[period-1] >=  rma[period-1] )
	then
	 
	   if source.close[period] > rma[period] then
	   Color[period]=1;
	   elseif source.close[period] < rma[period] then
	   Color[period]=-1;
	   end
	   
	   
	end
	
	if Color[period]== 1 then
	topfill:setColor(period, UpColor);
	botfill:setColor(period, UpColor);
	elseif Color[period]== -1 then 
	topfill:setColor(period, DownColor);
	botfill:setColor(period, DownColor);
	end
	

        topfill[period] = math.max(smoothprice[period], rma[period]);
        botfill[period] = math.min(smoothprice[period], rma[period]);
		
		
		
end

function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
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
	  
	       
			if  Color[period]== 1 
			and    Color[period-1]~= 1 
			then
			           
						    
             core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, topfill[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, UpTrendColor, "\225");

 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Up ", period);
							  SendAlert(" Up ");  
							        
									Pop(Label[id], " Up " );  	
								    
								 
							  end
			elseif  Color[period]== -1 
			and    Color[period-1]~= -1 
            then			
			
			            			 
			               core.host:execute("drawLabel1", source:serial(period), source:date(period),  core.CR_CHART, topfill[period], core.CR_CHART, core.H_Center, core.V_Top, font, DownTrendColor, "\226");						   
						   
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
 
   
    --    Alert:invoke("ShowAlert", message);
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
--  Alert:invoke( "PlaySound", Sound, RecurrentSound);
 
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
  --Alert:invoke( "SendEmail", Email, profile:id(),  text );
 
end
	 

