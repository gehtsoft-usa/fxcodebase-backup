-- Id: 16862
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64002&p=108719#p108719

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
    indicator:name("BFS Signal");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 
   indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("PeriodWATR", "Period WATR", "", 7);
	indicator.parameters:addDouble("Kwatr", "Kwatr", "",0.7); 
   indicator.parameters:addBoolean("HighLow", "High Low", "", false);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("color1", "Line color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "Line style", core.LINE_SOLID);
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
   indicator.parameters:addColor("color2", "Line color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "Line style", core.LINE_SOLID);
	indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);

    indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("OB", "Overbought Level","",1);
    indicator.parameters:addDouble("OS","Oversold Level","", 0);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
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

	
	Parameters (1, "Line Cross");	

   
	
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
local Shift=0; 
local Alert={}; 
local AlertLevel={};



local first=nil;
local source = nil;

local PeriodWATR, Kwatr, HighLow;

local g_ibuf_100, g_ibuf_104;
--local  g_ibuf_108, g_ibuf_112;

function Prepare(onlyName)
    source = instance.source;

	PeriodWATR =instance.parameters.PeriodWATR;
	Kwatr =instance.parameters.Kwatr;
	HighLow=instance.parameters.HighLow;
	
	OB=instance.parameters.OB;
	OS=instance.parameters.OS;
	
	
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	UpTrendColor = instance.parameters.UpTrendColor;
	DownTrendColor = instance.parameters.DownTrendColor;
	Size=instance.parameters.Size;
	
	
    local name = profile:id().. ", " .. source:name() ;
	

	instance:name(name);
	if onlyName then
		return;
	end
	
    g_ibuf_100 = instance:addStream("Line1", core.Line, name, "1.Line", instance.parameters.color1, source:first()+PeriodWATR)
    g_ibuf_100:setPrecision(math.max(2, instance.source:getPrecision()));
	g_ibuf_100:setWidth(instance.parameters.width1);
    g_ibuf_100:setStyle(instance.parameters.style1);
	g_ibuf_100:addLevel(OB, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	g_ibuf_100:addLevel(OS, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
	
	g_ibuf_104 = instance:addStream("Line2", core.Line, name, "2.Line", instance.parameters.color2, source:first()+PeriodWATR)
    g_ibuf_104:setPrecision(math.max(2, instance.source:getPrecision()));
	g_ibuf_104:setWidth(instance.parameters.width2);
    g_ibuf_104:setStyle(instance.parameters.style2);
	
	--g_ibuf_108 = instance:addInternalStream(0, 0);
	--g_ibuf_112 = instance:addInternalStream(0, 0);
  
  
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
	  assert( not(PlaySound and(Up[i] == "" or Up[i] == nil ) ), "Sound file must be chosen");
        assert (not (PlaySound and (Down[i] == "" or Down[i] == nil)), "Sound file must be chosen");
	end
	 
    RecurrentSound = instance.parameters.RecurrentSound;
	
	for i = 1, Number , 1 do 
	U[i] = nil;
	D[i] = nil;	 
	end
		 
end	



 
local li_8=0;
local li_12=0;
local li_16=0;
local ld_20=0;
local ld_28=0;
local ld_36=0;
local ld_44=0;
local ld_52=0;
local ld_60=0;
local ld_68=0;
local ld_76=0;
local ld_84=0;
local ld_100=0;
local ld_108=0;
local ld_116=0;
local ld_124=0;
local ld_132=0;
local ld_140=0;
local ld_148=0;
local ld_156=0;
local ld_164=0;
local ld_172=0;
local ld_180=0;
local ld_188=0;
local ld_196=0;
local ld_204=0;
local ld_212=0;
local li_unused_220=0;
local li_unused_224=0;
local li_unused_228=0;
local ld_232=0;
local ld_240=0;
local ld_248=0;
local ld_256=0;
local ld_264=0;
local ld_272=0;
local li_280 = 0;
local li_284 = 0;

function Update(period)

Calculate(period);


    if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
				
	if period  < PeriodWATR then
	return;
	end

	
    Activate (1, period)
 
end

function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

function Calculate (li_4)

ld_52 = 0;
ld_60=0;


if li_4  < PeriodWATR then
return;
end

for  li_0 = PeriodWATR - 1,  0,  -1 do
ld_60 = 1.0 * (PeriodWATR - li_0) / PeriodWATR + 1.0;
ld_52 =  ld_52 +ld_60 * math.abs(source.high[ li_4-li_0] - (source.low[  li_4-li_0] ));
end


ld_68 = ld_52 / PeriodWATR;
ld_76 = math.max(ld_68, ld_76);

if (li_4 ==  PeriodWATR)then
ld_84 = ld_68;
end

ld_84 = math.min(ld_68, ld_84);
li_unused_220 = round((Kwatr * ld_84 / source:pipSize()),0);
li_unused_224 = round((Kwatr * ld_76 /source:pipSize()),0);
li_unused_228 = round((Kwatr / 2.0 * (ld_76 + ld_84) / source:pipSize()),0);
 
ld_232 = Kwatr * ld_84;
ld_240 = Kwatr * ld_76;
ld_248 = Kwatr / 2.0 * (ld_76 + ld_84);

ld_272 = source.close[li_4];
ld_256 = source.high[li_4];
ld_264 = source.low[li_4];

if  HighLow   then

 ld_28 = ld_264 + 2.0 * ld_232;
ld_20 = ld_256 - 2.0 * ld_232;
ld_108 = ld_264 + 2.0 * ld_240;
ld_100 = ld_256 - 2.0 * ld_240;
ld_140 = ld_264 + 2.0 * ld_248;
ld_132 = ld_256 - 2.0 * ld_248;

if (ld_272 > ld_44)  then  li_8 = 1; end
if (ld_272 < ld_36) then li_8 = -1; end
if (ld_272 > ld_124) then li_12 = 1; end
if (ld_272 < ld_116) then li_12 = -1; end
if (ld_272 > ld_156) then li_16 = 1; end
if (ld_272 < ld_148) then li_16 = -1; end
else
 
ld_28 = ld_272 + 2.0 * ld_232;
ld_20 = ld_272 - 2.0 * ld_232;
ld_108 = ld_272 + 2.0 * ld_240;
ld_100 = ld_272 - 2.0 * ld_240;
ld_140 = ld_272 + 2.0 * ld_248;
ld_132 = ld_272 - 2.0 * ld_248;

if (ld_272 > ld_44) then li_8 = 1; end
if (ld_272 < ld_36) then li_8 = -1; end
if (ld_272 > ld_124) then li_12 = 1; end
if (ld_272 < ld_116) then li_12 = -1; end
if (ld_272 > ld_156) then li_16 = 1; end
if (ld_272 < ld_148) then li_16 = -1; end
end



if (li_8 > 0 and ld_20 < ld_36) then ld_20 = ld_36; end
if (li_8 < 0 and ld_28 > ld_44) then ld_28 = ld_44; end
if (li_12 > 0 and ld_100 < ld_116) then ld_100 = ld_116; end
if (li_12 < 0 and ld_108 > ld_124) then ld_108 = ld_124; end
if (li_16 > 0 and ld_132 < ld_148)then  ld_132 = ld_148; end
if (li_16 < 0 and ld_140 > ld_156)then  ld_140 = ld_156; end
if (li_8 > 0) then ld_164 = ld_20 + ld_232; end
if (li_8 < 0)  then ld_164 = ld_28 - ld_232; end
if (li_12 > 0) then ld_172 = ld_100 + ld_240; end
if (li_12 < 0)then ld_172 = ld_108 - ld_240; end
if (li_16 > 0)then ld_180 = ld_132 + ld_248; end
if (li_16 < 0)then ld_180 = ld_140 - ld_248; end

ld_204 = ld_172 - ld_240;
ld_212 = ld_172 + ld_240;
ld_188 = (ld_164 - ld_204) / (ld_212 - ld_204);
ld_196 = (ld_180 - ld_204) / (ld_212 - ld_204);
g_ibuf_100[li_4] = ld_188;
g_ibuf_104[li_4] = ld_196;
ld_36 = ld_20;
ld_44 = ld_28;
ld_116 = ld_100;
ld_124 = ld_108;
ld_148 = ld_132;
ld_156 = ld_140;

 -- Alert Code

--[[
li_280 = li_284;

if (g_ibuf_100[li_4] > g_ibuf_104[li_4])  then 
li_284 = 1;  
else 
li_284 = -1;
end
if (li_280 == -1 and li_284 == 1) then g_ibuf_108[li_4] = g_ibuf_104[li_4]; end
if (li_280 == 1 and li_284 == -1) then g_ibuf_112[li_4] = g_ibuf_104[li_4]; end
]]


 end
 
 
function Activate (id, period)


   Alert[id][period]=0;
   
   
  
  
	  if id == 1  and ON[id]  then
	  
	       
			if  g_ibuf_100[period] > g_ibuf_104[period] 
			and   g_ibuf_100[period-1] <= g_ibuf_104[period-1] 
			then
			           
						    
         
                Alert[id][period]= 1;	
 				AlertLevel[id][period]= g_ibuf_104[period] 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over ", period);
							  SendAlert( Label[id]," Crossed over ", period); 
							  Pop(Label[id], " Cross Over ", period );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif  g_ibuf_100[period] < g_ibuf_104[period] 
			and   g_ibuf_100[period-1] >= g_ibuf_104[period-1] 
            then			
			
			            			 
			                Alert[id][period]= -1;	
							AlertLevel[id][period]= g_ibuf_104[period] 
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under ", period);								 
							 Pop(Label[id], " Cross Under ", period );  	
							 SendAlert( Label[id]," Crossed under ", period);
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

 
 
 

