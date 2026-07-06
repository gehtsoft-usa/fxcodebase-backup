-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63382

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
    indicator:name("Period High & Low");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 

    indicator.parameters:addGroup("Calculation");
 

    indicator.parameters:addInteger("Period1", "1.Period", "", 5);
    indicator.parameters:addInteger("Period2", "2. Period", "", 15);
	indicator.parameters:addInteger("Period3", "3. Period", "", 45);

    indicator.parameters:addGroup("Style");
 
    indicator.parameters:addColor("Color1", "1. Extreme color", "Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Color2", "2. Extreme color", "Color", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Color3", "2. Extreme color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("Size", "Font Size", "Size", 15);
	
	  indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");   

	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	indicator.parameters:addBoolean("ShowAlert", "Show Alert", "", true);

	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", false);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);

	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", false);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);

	
	Parameters (1, "1. Period Alert");	
	Parameters (2, "2. Period Alert");	
	Parameters (3, "3. Period Alert");	
end

function Parameters ( id, Label )
  
  
   indicator.parameters:addGroup(Label .. " Alert");
  
    indicator.parameters:addBoolean("ON"..id , "Show " .. Label .." Alert" , "", true);


    indicator.parameters:addFile("Up"..id, Label .. " New Top Sound", "", "");
    indicator.parameters:setFlag("Up"..id, core.FLAG_SOUND);
	
	indicator.parameters:addFile("Down"..id, Label .. " New Bottom Sound", "", "");
    indicator.parameters:setFlag("Down"..id, core.FLAG_SOUND);
	
	 indicator.parameters:addString("Label"..id, "Label", "", Label);

end 

local 	Number = 3;
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
local Shift; 

local first;
local Color1, Color2, Color3; 
local name;
local Period1,Period2,Period3;


local pmax1p;
local pmax2p;
local pmax3p;
local pmin1p;
local pmin2p;
local pmin3p;		
	
function Prepare(onlyName)
    source = instance.source;
    Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Period3=instance.parameters.Period3;
    Size=instance.parameters.Size;
	
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	ShowAlert = instance.parameters.ShowAlert;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
		
	first=source:first()+math.max(Period1, Period2, Period3);
    name = profile:id() .. "(" .. source:name() .. ", " .. Period1 .. ", " .. Period2.. ", " .. Period3 .. ")";
    instance:name(name);
	
    if onlyName then
        return ;
    end 
	
    Color1 = instance.parameters.Color1;
    Color2 = instance.parameters.Color2;
	Color3 = instance.parameters.Color3;
   
    instance:ownerDrawn(true);
	
	
	
	Initialization();	
	instance:ownerDrawn(true);	 

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




local init = false;
 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
	
        if not init then
            context:createFont (1, "Wingdings", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
 
       local Last=source:size()-1;
	   
	   if Live~= "Live" then
	   Last=Last-1;
	   end
	   
	   
       local min1,max1, min1p, max1p = mathex.minmax(source, Last-Period1+1, Last);
	   local min2,max2, min2p, max2p = mathex.minmax(source, Last-Period2+1, Last);
	   local min3,max3, min3p, max3p = mathex.minmax(source, Last-Period3+1, Last);
	   
	   
	    x, x1, x2 = context:positionOfBar (min1p);
		visible, y = context:pointOfPrice (min1)
	    width, height = context:measureText (1, "\233" , context.CENTER  );  
		context:drawText (1,  "\233", Color1, -1, x-width/2 , y , x+width/2  , y+height, context.CENTER   );	
		
		
		x, x1, x2 = context:positionOfBar (max1p);
		visible, y= context:pointOfPrice (max1)
		context:drawText (1,  "\234", Color1, -1, x-width/2 , y-height, x+width/2  , y, context.CENTER   );	
	   
	  
	  
	     x, x1, x2 = context:positionOfBar (min2p);
		visible, y = context:pointOfPrice (min2)
	    width, height = context:measureText (1, "\233" , context.CENTER  );  
		context:drawText (1,  "\233", Color2, -1, x-width/2 , y+height , x+width/2  , y+height*2, context.CENTER   );	
		
		
		x, x1, x2 = context:positionOfBar (max2p);
		visible, y= context:pointOfPrice (max2)
		context:drawText (1,  "\234", Color2, -1, x-width/2 , y-height*2, x+width/2  , y-height, context.CENTER   );	
		
		
		
		 x, x1, x2 = context:positionOfBar (min3p);
		visible, y = context:pointOfPrice (min3)
	    width, height = context:measureText (1, "\233" , context.CENTER  );  
		context:drawText (1,  "\233", Color3, -1, x-width/2 , y+height*2 , x+width/2  , y+height*3, context.CENTER   );	
		
		
		x, x1, x2 = context:positionOfBar (max3p);
		visible, y= context:pointOfPrice (max3)
		context:drawText (1,  "\234", Color3, -1, x-width/2 , y-height*3, x+width/2  , y-height*2, context.CENTER   );	
end

		

function Update(period, mode)


   
	
     if period < source:size()-1 then
	 return;
	 end
	 
	if Live~= "Live" then
	period=period-1;
	Shift=1;
	else
	Shift=0;
	end
	
	 
	   local min1,max1, min1p, max1p = mathex.minmax(source, period-Period1+1, period);
	   local min2,max2, min2p, max2p = mathex.minmax(source, period-Period2+1, period);
	   local min3,max3, min3p, max3p = mathex.minmax(source, period-Period3+1, period);
	   
	 
 
	
	 
	if max1p ~=	pmax1p  then
	pmax1p =max1p;
	Activate (1,1, period, pmax1p )
	end
	
	if max2p ~= pmax2p 	then
	pmax2p = max2p;
	Activate (2,2, period,pmax2p )
	end
	
	if max3p ~= pmax3p then
	pmax3p =max3p;	
	Activate (3,3, period,pmax3p )
	end
 
	
 
    
 
	 
	
	if min3p ~= pmin3p then
	pmin3p = min3p;
	Activate (3, -3,period,pmin3p )
	end
	
	if min2p ~= pmin2p then
	pmin2p = min2p;
	Activate (2, -2,period,pmin2p )
	end
	
	if  min1p ~= pmin1p then 	 
	pmin1p = min1p;
	Activate (1, -1,period,pmin1p )
	end
	
	
	
	 
    
end


function Activate (id, Flag, period, p)

 
  
  
	  if (id == 1  and ON[id])
	  or (id == 2  and ON[id])
	  or (id == 3  and ON[id])
	  then
	  
	       
			if  Flag> 0
			then
			           
						    
         
               
			
			-- D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							  then
							  
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id],  id.. ". Period Top " , p);
							  SendAlert( Label[id], id.. ". Period Top ", p); 
							  Pop(Label[id],  id.. ". Period Top ", p );  
							  OnlyOnceFlag=false;
							  end
							  
			elseif  Flag < 0
            then			
			
			            	 
						   
		    --- U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 and  (not OnlyOnce or (OnlyOnce and OnlyOnceFlag~= false))
							 then							
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] ,  id.. ". Period Bottom " , p);								 
							 Pop(Label[id], id..  ". Period Bottom " , p );  	
							 SendAlert( Label[id], id.. ". Period Bottom ", p);
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

 
 
 

