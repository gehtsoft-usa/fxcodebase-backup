-- Id: 12881
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60454

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("Distance from Line");
    indicator:description("Distance from Line");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	Parameters (1 ,  core.rgb(0, 255, 0) );
	Parameters (2 , core.rgb(255, 0, 0) );	
	Parameters (3 ,core.rgb(0, 0, 255)  );
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Method", "Method", "Method" , "Pip");
    indicator.parameters:addStringAlternative("Method", "Pip", "Pip" , "Pip");
	indicator.parameters:addStringAlternative("Method", "Value", "Value" , "Value");
	indicator.parameters:addStringAlternative("Method", "Percentage", "Percentage" , "Percentage"); 
	
	--[[indicator.parameters:addInteger("Method", "Method", "Method" ,  1 );
    indicator.parameters:addIntegerAlternative("Method", "Pip", "Pip" ,  1 );
	indicator.parameters:addIntegerAlternative("Method", "Value", "Value" ,  2 );
	indicator.parameters:addIntegerAlternative("Method", "Percentage", "Percentage", 3 )]]
	
	indicator.parameters:addBoolean("Sign" , "Sign reversal", "", true);	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("Size", "Font Size", "", 20); 
    indicator.parameters:addColor("Color", "Label Color ", " ", core.rgb(0, 0, 0));
	
	  indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addFile("Sound",   "Alert Sound", "", "");
    indicator.parameters:setFlag("Sound", core.FLAG_SOUND);
--	indicator.parameters:addGroup("Alerts Dialog box");  
	--indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL); 
   
end


function Parameters (id ,Color)
    indicator.parameters:addGroup(id ..". Line");
	indicator.parameters:addColor("LineColor"..id, "Line Color ", " ",Color);
	indicator.parameters:addInteger("width"..id, "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style"..id, "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..id, core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Method;
local first;
local source; 
 
 
local LineColor={};
local Num=3;
local Sign;
-- Streams block
local Color = nil;
local Size;
local Width={};
local Style={};
local Level={};
local db;



local Last={}; 
 ---

 local CalcMode;
local Email;
local SendEmail; 
local Sound;
local  RecurrentSound ,SoundFile  ;
local Show;
local PlaySound;
local Alert=nil;
local Count;
local AlertNumber;

-- Routine
function Prepare(nameOnly)
    Color = instance.parameters.Color;
	Size = instance.parameters.Size;
	Method = instance.parameters.Method;
	Sign = instance.parameters.Sign;
    source = instance.source;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. Method  .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	 
	
	require("storagedb");
   
	
	for i = 1 , 3 , 1 do   
	 
	     Width[i]=  instance.parameters:getDouble ("width"..i);
		 Style[i]=  instance.parameters:getDouble ("style"..i);
	     LineColor[i]=  instance.parameters:getDouble ("LineColor"..i); 
	   
   end

    

	
	 db = storagedb.get_db(profile:id() .. "(" .. source:name());
	 
	 core.host:execute("addCommand", 1, "Set First Level", "");
	core.host:execute("addCommand",  2, "Set Second Level"  , "");
	core.host:execute("addCommand",  3, "Set Third Level", "");
	core.host:execute("addCommand",  4, "Reset");
	
	 core.host:execute ("setTimer",  5,  1);
	 
	 
	
	instance:ownerDrawn(true);
	
	 SendEmail = instance.parameters.SendEmail;
	 
	if SendEmail then
        Email = instance.parameters.Email;
    else
        Email = nil;
    end
    assert(not(SendEmail) or (SendEmail and Email ~= ""), "E-mail address must be specified");
	

	
	RecurrentSound= instance.parameters.RecurrentSound;
    Show= instance.parameters.Show; 
	PlaySound = instance.parameters.PlaySound;
	
    if PlaySound then 
	  Sound=instance.parameters.Sound; 
    else  
      Sound=nil;
	 end
	 
	 
	  assert(not(PlaySound) or (PlaySound and Sound ~= "") or (PlaySound and Sound ~= ""), "Sound file must be chosen"); 

	  instance:ownerDrawn(true);

	  
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
  
end


local pattern = "([^;]*);([^;]*)";
function AsyncOperationFinished(cookie, success, message)
 
 local level, date,pos;
 
 if cookie ==  1 then
 level, date = string.match(message, pattern, pos);
 db:put(tostring(1).."Level", level);
 elseif cookie ==  2 then
 level, date = string.match(message, pattern, pos);
 db:put(tostring(2).."Level", level);
 elseif cookie ==  3 then
 level, date = string.match(message, pattern, pos);
 db:put(tostring(3).."Level", level);
 elseif cookie ==  4 then
 
  db:put(tostring(1).."Level", 0);
  db:put(tostring(2).."Level", 0);
  db:put(tostring(3).."Level", 0);
 end
  
 
end

local init = false;
 
function Draw(stage, context)

    if stage ~= 2 then
	return;
	end
	
	
	
	Level[1]=tonumber(db:get (tostring(1).."Level", 0));
	Level[2]=tonumber(db:get (tostring(2).."Level", 0));
	Level[3]=tonumber(db:get (tostring(3).."Level", 0));
	
	
	context:setClipRectangle (  context:left (), context:top(), context:right (), context:bottom());
	
        if not init then
            context:createSolidBrush(1, Color);
			context:createPen (2, context.SOLID, 1, Color);	
			context:createFont (3, "Arial", Size,  Size, 0);
			
            for i= 1, Num , 1 do
				 
				context:createPen (10+i, context:convertPenStyle(Style[Num]), Width[i], LineColor[i]);	
				 
            end 			
            init = true;			
		end	
		
		
		
	 x1= context:left ();
     x2= context:right ();
	 
	 local i;
	 local Shift;
	 local Number=0;
	 local Text="";
	 local All="";
	 
	 for i= 1, Num , 1 do	
	 
					 if Level[i]~= 0  then 
					 
					 
					       if  core.crossesOver  (source, Level[i], source:size()-1) 
							 and Last[i]~= source:serial(source:size()-1)
							 then	
							  Last[i]= source:serial(source:size()-1)
							 GiveAlert("Cross Over " ..  string.format("%." .. 2 .. "f",  Level[i])  );
							 elseif  core.crossesUnder  (source, Level[i], source:size()-1) 
							 and Last[i]~= source:serial(source:size()-1)
							 then 
							 Last[i]= source:serial(source:size()-1)
							GiveAlert("Cross Under" ..   string.format("%." .. 2 .. "f",  Level[i])  );
							 end
					 
					 
					 	
					
                                             visible, y1 = context:pointOfPrice (Level[i]);	
								 y2= y1;	  
								 Text="";
				  
								 
								 if Method == "Pip" then
								 --if Method ==  1  then 
										 Shift = (Level[i] - source [source:size()-1] )/source:pipSize() ;
										 
										 if Sign then
										 Shift= -Shift;
										 end
										 
										 Number=1;
										  Text=  string.format("%." .. Number .. "f", Shift ) .. " Pips";
								   elseif Method == "Percentage" then
								--  elseif Method == 2 then
										 Shift =(Level[i] - source [source:size()-1] )/ (Level[i]/100);
										 
										  if Sign then
										 Shift= -Shift;
										  end
										 
										 Number=2;
										 Text= string.format("%." .. Number .. "f", Shift ) .. " %";
								   elseif Method =="Value" then
								  --  elseif Method ==  3  then
										  Shift = (Level[i] - source [source:size()-1] )
										   if Sign then
										  Shift= -Shift;
										   end
										 
										 
										  Number=source:getPrecision ();
										  Text= string.format("%." .. Number .. "f", Shift ) .. " Value";					
					  
					 end 
					 
					 
									  All=  All .." ".. tostring(i).. " : " .. Text;
								
									 local width, height = context:measureText (3, Text, 0)	 
									 context:drawText (3, Text , Color, -1, x2-width, y1, x2, y1+height, context.LEFT);     	 
									 context:drawLine (10+i, x1, y1, x2, y2);
				 
								
					 end
								
					  
				
				 
				 
	 end
	 
	 core.host:execute ("setStatus", All)
end 




function GiveAlert(Label) 
    
	SoundAlert(Sound);
	--Pop("Alert",  source:instrument(), Label   ); 
	EmailAlert(  "Alert",   source:instrument(), Label  );
end


function EmailAlert( label ,  Instrument,Label )

if not SendEmail then
return
end

  
   
	local DATA = core.dateToTable (core.now());
	
    
   local delim = "\013\010";  
  
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day .. delim .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
   
     local text = " Instrument : " .. Instrument.. delim ..  Time.. delim  .. Label .. " : " ..label;
	

 
   terminal:alertEmail(Email, Label .. " : " ..label, text);
end

 
 

function SoundAlert(iAlert )
 if not PlaySound then
 return;
 end
  
  terminal:alertSound(iAlert, RecurrentSound);
 
 
end

	 



