	
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7575

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


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Long/Short Candle");
    indicator:description("Long/Short Candle");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PERIOD", "Period", "Period", 10);
	indicator.parameters:addString("Type", "Body/Wick", "", "Body");
    indicator.parameters:addStringAlternative("Type", "Body", "", "Body");
    indicator.parameters:addStringAlternative("Type", "Wick", "", "Wick");
	
	indicator.parameters:addBoolean("Reversal", "Reversal Filter", "", false);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UpColor", "Color of Up Candle", "Color of Up Candle", core.COLOR_UPCANDLE );
    indicator.parameters:addColor("DownColor", "Color of Down Candle", "Color of Down Candle", core.COLOR_DOWNCANDLE );
	
	indicator.parameters:addBoolean("Show_Overlay", "Show Overlay", "", true);
    indicator.parameters:addColor("Long", "Color of Long Candle", "Color of Long Candle", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Short", "Color of Short Candle", "Color of Short Candle", core.rgb(128, 128, 128));
	
	 indicator.parameters:addInteger("Size", "Font Size", "Font Size", 15);
	 
	 
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
 
	
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, "Up/Down Alert");	


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
local ShowAlert;
local Alert={}; 
local AlertLevel={};
local ToTime;
local Shift=0; 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local PERIOD;
local Reversal;
local first;
local source = nil;
local Show_Overlay;
-- Streams block
local open = nil;
local close = nil;
local high = nil;
local low = nil;

 
local Long;
local Short;
local Type;
local RAW;
local UpColor, DownColor;
local font, Size;

-- Routine
 function Prepare(nameOnly)  
    
    
	Show_Overlay= instance.parameters.Show_Overlay;
    UpColor = instance.parameters.UpColor;
	Reversal = instance.parameters.Reversal;
	DownColor = instance.parameters.DownColor;
    Type = instance.parameters.Type;
    PERIOD = instance.parameters.PERIOD;
    source = instance.source;
    first = source:first()+PERIOD+1; 
    Short = instance.parameters.Short;
	Long = instance.parameters.Long;
    local name = profile:id() .. "(" .. source:name() .. ", " .. PERIOD .. ")";
    instance:name(name);
	
	if   (nameOnly) then
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
	Size=instance.parameters.Size;
	
	
	RAW= instance:addInternalStream(0, 0);
	font = core.host:execute("createFont", "Wingdings", Size, true, false);
	
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("LS", "LS", open, high, low, close);
	
	  for i= 1, Number , 1 do
		Alert[i]=instance:addInternalStream(0, 0);
     end
	
	Initialization();	
	
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
   
   
     core.host:execute ("removeLabel", source:serial(period))
    if Type == "Body" then
    RAW[period]= math.abs(source.close[period] - source.open[period]);
	else
	RAW[period]= source.high[period] - source.low[period];
	end

    if period < first or not  source:hasData(period) then	
	return;
	end
	if source.open[period]  <   source.close[period]  then
	open:setColor(period, UpColor);	
	elseif source.open[period]  >   source.close[period]  then
	open:setColor(period, DownColor);
    end	
		
	high[period]= source.high[period];
	low[period]= source.low[period];		   
	close[period] = source.close[period];
	open[period]  = source.open[period];
	
	
	
	
	local min, max;
	min, max =  mathex.minmax (RAW, period-PERIOD-1, period-1);

   if Reversal    
   and not ( (source.open[period]  <   source.close[period]  and source.open[period-1] >   source.close[period-1])
   or (source.open[period]  >   source.close[period]  and source.open[period-1] <   source.close[period-1]))
   then   
   return;   
   end   
   
   
   Alert[1][period]=0;
   
   if RAW[period] > max 
   or  RAW[period] < min 
   then 
   
	   if source.open[period]  <   source.close[period] then
	   DrawArrow (period, true);
	   Alert[1][period]=1;
	   else
	   DrawArrow (period, false);
	    Alert[1][period]=-1;
	   end
   end
	
	
	if Show_Overlay then
	
	
		if RAW[period] > max then 
		open:setColor(period, Long);	
		
		elseif RAW[period] < min then 
		open:setColor(period, Short);			
		end	
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
	
    Activate (1, period)
 
	    
end


function DrawArrow (period, Flag)

	if Flag then
	core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom,
								 font, UpColor, "\217");
	else							 
	core.host:execute("drawLabel1", source:serial(period),source:date(period), core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top,
								 font, DownColor, "\218");							 
	end
end

function ReleaseInstance()
       core.host:execute("deleteFont", font);
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



function Activate (id, period)


   
   
   
  
  
	  if id == 1  and ON[id]  then
	  
	       
			if  Alert[id][period]== 1 
			and  Alert[id][period-1]~= 1 
			then
			           
						    
          
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Up Candle ");
							  SendAlert( Label[id]," Up Candler "); 
							  Pop(Label[id], " Up Candle ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif  Alert[id][period]== -1 
			and  Alert[id][period-1]~= -1 
            then			
			
			            	 
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Down Candle ");								 
							 Pop(Label[id], " Down Candle ", period );  	
							 SendAlert( Label[id]," Down Candle ");
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
	 
	 
	 
	 

function Pop(label , Subject )
  
   if not Show then
   return;
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
	
   
   core.host:execute ("prompt", 1, label , text );


end


function SendAlert(label ,Subject, period)
    if not ShowAlert then
        return;
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
	
 
    terminal:alertMessage(source:instrument(), source[NOW], text, now);
end
