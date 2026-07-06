-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62576

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
    indicator:name("Commodity Channel Index with zone and trend highlighting");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");

    indicator.parameters:addInteger("N", "Number of Periods", "", 17, 2, 1000);	
    indicator.parameters:addInteger("overbought", "Overbought level", "", 100);
    indicator.parameters:addInteger("oversold", "Oversold level", "", -100);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrCCI", "Line (neutral)", "", core.rgb(0, 255, 255));
    indicator.parameters:addColor("clrCCIUp", "Line (uptrend)", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrCCIDn", "Line (downtrend)", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthCCI", "Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("styleCCI", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleCCI", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addBoolean("fill", "Highlight Areas over/under levels", "", true);

    indicator.parameters:addInteger("transparency", "Highlight transparency (%)", "", 30); 
	 indicator.parameters:addColor("clrFill", "Over Level Fill Color", "", core.rgb(255, 255, 0));
    indicator.parameters:addColor("clrBg", "Background Fill Color", "Leave this parameter in its default value", core.COLOR_BACKGROUND);

    indicator.parameters:addGroup("Levels");
    indicator.parameters:addInteger("level_overboughtsold_width", "Level Line Width (in pixels)", "", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Level Line Style", "", core.LINE_DOT);
    indicator.parameters:addColor("level_overboughtsold_color", "","", core.COLOR_CUSTOMLEVEL);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
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

	
	Parameters (1, "Trend");	
	
end

local n;
local source;
local first;
local cci,CCI;
local clr, clrUp, clrDn;

local fill, clrFill, clrBg;
local ob_level;
local ob_highlight1;
local ob_highlight2;
local os_level;
local os_highlight1;
local os_highlight2;
local trend;

function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);


    indicator.parameters:addFile("Up"..id, Label .. " Up Trend Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " Down Trend Sound", "", "");
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
local Shift=0; 
local Alert={}; 
local AlertLevel={};


function Prepare(onlyName)
    source = instance.source;
	
	
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	Size=instance.parameters.Size;

    local name;
    n = instance.parameters.N;

    name = profile:id() .. "(" .. source:name() .. "," .. n .. ")";
    instance:name(name);
    if onlyName then
        return ;
    end

    trend = instance:addInternalStream(0, 0);
    
    cci = core.indicators:create("CCI", source, n);
    first = cci.DATA:first();

    clr = instance.parameters.clrCCI;
    clrUp = instance.parameters.clrCCIUp;
    clrDn = instance.parameters.clrCCIDn;


    CCI = instance:addStream("CCI", core.Line, name, "CCI", clr, first);
    CCI:setWidth(instance.parameters.widthCCI);
    CCI:setStyle(instance.parameters.styleCCI);
    CCI:setPrecision(2); 
    CCI:addLevel(0, core.LINE_NONE);
    CCI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    CCI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
 

    fill = instance.parameters.fill;
    if fill then
        clrFill = instance.parameters.clrFill;
        clrBg = instance.parameters.clrBg;
        ob_level = instance.parameters.overbought;
        ob_highlight1 = instance:addInternalStream(first, 0);
        ob_highlight2 = instance:addInternalStream(first, 0);
        instance:createChannelGroup("ob", "ob", ob_highlight1, ob_highlight2, clrFill, 100 - instance.parameters.transparency);
        os_level = instance.parameters.oversold;
        os_highlight1 = instance:addInternalStream(first, 0);
        os_highlight2 = instance:addInternalStream(first, 0);
        instance:createChannelGroup("os", "os", os_highlight1, os_highlight2, clrFill, 100 - instance.parameters.transparency);
    end
	
	
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
              context:drawText (1,   "\225", UpTrendColor, -1,  x-width/2 ,  y-height , x+width/2 , y, 0 );	
   
			elseif Alert[Level][period]== -1 then
			visible, y = context:pointOfPrice (AlertLevel[Level][period]);
			width, height = context:measureText (1,  "\226", 0);
			 context:drawText (1,   "\226", DownTrendColor, -1,  x-width/2  ,  y , x+width/2 ,y+height, 0 );	
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
	  	 assert( not(PlaySound and ON[i] and (Up[i] == "" or Up[i] == nil ) ), "Sound file must be chosen");
        assert (not (PlaySoundand and ON[i]  and (Down[i] == "" or Down[i] == nil)), "Sound file must be chosen");
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	U[i] = nil;
	D[i] = nil;	 
	end
		 
end	


function Update(period, mode)
     
   cci:update(mode);
    if period <= first then
	return;
	end
	
   CCI[period]= cci.DATA[period];
  
  
         trend[period] = trend[period - 1];

        if CCI[period - 1] <= ob_level
		and  CCI[period] > ob_level then
        trend[period] = 1;
        elseif CCI[period - 1] >= os_level
		and CCI[period] < os_level then
        trend[period] = -1;
        end
  
        if trend[period] == 0 then
            CCI:setColor(period, clr);
        elseif trend[period] == 1 then
            CCI:setColor(period, clrUp);
        elseif trend[period] == -1 then
            CCI:setColor(period, clrDn);
        end

		
		 if fill   then
        ob_highlight1[period] = CCI[period];
        ob_highlight1:setColor(period, clrFill);
        ob_highlight2[period] = ob_level;
        if CCI[period] < ob_level then
            if CCI[period - 1] < ob_level then
                ob_highlight1[period] = nil;
            else
                ob_highlight1:setColor(period, clrBg);
            end
        else
            if CCI[period - 1] < ob_level then
                ob_highlight1[period - 1] = CCI[period - 1];
                ob_highlight1:setColor(period - 1, clrBg);
            end
        end
        os_highlight1[period] = CCI[period];
        os_highlight1:setColor(period, clrFill);
        os_highlight2[period] = os_level;

        if CCI[period] > os_level then
            if CCI[period - 1] > os_level then
                os_highlight1[period] = nil;
            else
                os_highlight1:setColor(period, clrBg);
            end
        else
            if CCI[period - 1] > os_level then
               os_highlight1[period - 1] = CCI[period - 1];
               os_highlight1:setColor(period - 1, clrBg);
            end
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
	
    Activate (1, period);
 
end



function Activate (id, period)


   Alert[id][period]=0;
   
   
  
  
	  if id == 1  and ON[id]  then
	  
	       
			if  trend[period] ==1 
			and  trend[period-1] ~=1 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= CCI[period];
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Up Trend ", period);
							  SendAlert( Label[id]," Up Trend ", period); 
							  Pop(Label[id], " Up Trend ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif  trend[period] ==-1 
			and  trend[period-1] ~=-1 
            then			
			
			            			 
			                Alert[id][period]= -1;	
							AlertLevel[id][period]= CCI[period];
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Down Trend ", period);								 
							 Pop(Label[id], " Down Trend ", period );  	
							 SendAlert( Label[id]," Down Trend ", period);
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
