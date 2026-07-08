-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1968

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
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
function Init()
    indicator:name("Market Facilitation Index");
    indicator:description("Bill Williams' Market facilitation index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Volume Indicators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("RANGE", "Range", "Multiplication factor, which brings the difference in points down to whole", 1, 0.00001, 100);
	
	 indicator.parameters:addDouble("CrossLevel", "Alert Level", "Alert Level", 0);

    indicator.parameters:addGroup("Style");
    local colors = core.colors();
    indicator.parameters:addColor("MUVU_Color", "MFI Up/Volume Up Color", "", colors.Lime);
    indicator.parameters:addColor("MDVD_Color", "MFI Down/Volume Down Color", "", colors.SaddleBrown);
    indicator.parameters:addColor("MUVD_Color", "MFI Up/Volume Down Color", "", colors.Blue);
    indicator.parameters:addColor("MDVU_Color", "MFI Down/Volume Up Color", "", colors.Pink);
	
	
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

	
	Parameters (1, "Level");	
end

local source;
local RANGE;
local first;
local first1;
local MFI;
local point;
local MUVU;
local MDVD;
local MUVD;
local MDVU;
local MU;
local VU;
local CrossLevel;

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

function Prepare(nameOnly)  
    source = instance.source;
    first = source:first() + 1;
    first1 = source:first();
    RANGE = instance.parameters.RANGE;
    point = source:pipSize();


    local name;
    name = profile:id() .. "(" .. source:name() .. "," .. RANGE .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
	end
	
	
	ToTime=instance.parameters.ToTime;
	CrossLevel=instance.parameters.CrossLevel;
	
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
	
	  assert(source:supportsVolume(), "The source must have volume");

    MFI   = instance:addStream("MUVU", core.Bar, name .. ".MFI", "MFI", instance.parameters.MUVU_Color, first);
    MFI:setPrecision(5);
	MFI:setPrecision(math.max(2, instance.source:getPrecision()));
    MU = instance:addInternalStream(0, 0);
    VU = instance:addInternalStream(0, 0);
	
	
	for i= 1, Number , 1 do
		Alert[i]=instance:addInternalStream(0, 0);
		AlertLevel[i]=instance:addInternalStream(0, 0);
     end
	
	Initialization();	
	instance:ownerDrawn(true);	
 
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

function Update(period, mode)
   
    MU[period] = 0;
    VU[period] = 0;

    if period >= first1 then
        MFI[period] = RANGE * (source.high[period] - source.low[period]) / (source.volume[period] * point);
    end

    if period >= first then
        local mu, vu;

        mu = MU[period - 1];
        vu = VU[period - 1];

        if MFI[period] > MFI[period - 1] then
            mu = 1;
        elseif MFI[period] < MFI[period - 1] then
            mu = -1;
        end

        if source.volume[period] > source.volume[period - 1] then
            vu = 1;
        elseif source.volume[period] < source.volume[period - 1] then
            vu = -1;
        end

        MU[period] = mu;
        VU[period] = vu;

        if mu > 0 and vu > 0 then
             MFI:setColor(period, instance.parameters.MUVU_Color);  
        elseif mu < 0 and vu < 0 then
             MFI:setColor(period, instance.parameters.MDVD_Color);  
        elseif mu > 0 and vu < 0 then
             MFI:setColor(period, instance.parameters.MUVD_Color);  
        elseif mu < 0 and vu > 0 then
             MFI:setColor(period, instance.parameters.MDVU_Color);  
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


function Activate (id, period)


   Alert[id][period]=0;
   
   
  
  
	  if id == 1  and ON[id]  then
	  
	       
			if  MFI[period] >CrossLevel 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= MFI[period]
						   
			
			
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over ");
							  SendAlert( Label[id]," Crossed over "); 
							  Pop(Label[id], " Cross Over ", period );  
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

