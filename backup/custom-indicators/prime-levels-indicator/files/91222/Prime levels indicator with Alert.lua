-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60016&hilit=levels

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



function AddParam(id, Enable, Level, Color, Width, Style)
    indicator.parameters:addBoolean("Enable" .. id, "Enable level " .. id, "", Enable);
    indicator.parameters:addInteger("Level" .. id, "Level " .. id .. " (Last digits)", "", Level);
    indicator.parameters:addColor("Color" .. id, "Level " .. id .. " color", "", Color);
    indicator.parameters:addInteger("Width" .. id, "Level " .. id .. " width", "", Width);
    indicator.parameters:addInteger("Style" .. id, "Level " .. id .. " style", "", Style);
    indicator.parameters:setFlag("Style" .. id, core.FLAG_LINE_STYLE);
end

local pipSize;
local ShowLabels;
local FontSize;
local DigitsNumber;
local Dig;

function Init()
    indicator:name("Prime levels indicator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    
	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addInteger("LookBack", "LookBack Period", "", 0);
    indicator.parameters:addInteger("DigitsNumber", "Number of last digits", "", 2);
    
    AddParam(1, true, 0, core.rgb(255, 0, 0), 1, core.LINE_SOLID);
    AddParam(2, true, 50, core.rgb(0, 0, 255), 1, core.LINE_DASH);
    AddParam(3, true, 17, core.rgb(128, 128, 0), 1, core.LINE_SOLID);
    AddParam(4, true, 83, core.rgb(0, 255, 0), 1, core.LINE_SOLID);
    AddParam(5, true, 67, core.rgb(0, 128, 128), 1, core.LINE_SOLID);
    AddParam(6, true, 33, core.rgb(255, 255, 0), 1, core.LINE_SOLID);
    AddParam(7, false, 0, core.rgb(128, 128, 128), 1, core.LINE_SOLID);
    AddParam(8, false, 0, core.rgb(128, 128, 128), 1, core.LINE_SOLID);
    AddParam(9, false, 0, core.rgb(128, 128, 128), 1, core.LINE_SOLID);
    AddParam(10, false, 0, core.rgb(128, 128, 128), 1, core.LINE_SOLID);
	
	AddParam(11, false, 0, core.rgb(128, 128, 128), 1, core.LINE_SOLID);
    AddParam(12, false, 0, core.rgb(128, 128, 128), 1, core.LINE_DASH);
    AddParam(13, false, 0, core.rgb(128, 128, 128), 1, core.LINE_SOLID);
    AddParam(14, false, 0, core.rgb(128, 128, 128), 1, core.LINE_SOLID);
    AddParam(15, false, 0, core.rgb(128, 128, 128), 1, core.LINE_SOLID);
    AddParam(16, false, 0, core.rgb(128, 128, 128), 1, core.LINE_SOLID);
    AddParam(17, false, 0, core.rgb(128, 128, 128), 1, core.LINE_SOLID);
    AddParam(18, false, 0, core.rgb(128, 128, 128), 1, core.LINE_SOLID);
    AddParam(19, false, 0, core.rgb(128, 128, 128), 1, core.LINE_SOLID);
    AddParam(20, false, 0, core.rgb(128, 128, 128), 1, core.LINE_SOLID);
	
    
    indicator.parameters:addBoolean("ShowLabels", "Show labels", "", true);
    indicator.parameters:addInteger("FontSize", "Labels font size", "", 0);
	
	  indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addFile("Sound",   "Alert Sound", "", "");
    indicator.parameters:setFlag("Sound", core.FLAG_SOUND);
	indicator.parameters:addGroup("Alerts Dialog box");  
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL); 
end

local source = nil;

local Last={}; 
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
local LookBack;
-- initializes the instance of the indicator
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    source = instance.source;
    pipSize = source:pipSize();
    ShowLabels=instance.parameters.ShowLabels;
	LookBack=instance.parameters.LookBack;
    DigitsNumber=instance.parameters.DigitsNumber;
    Dig=math.pow(10, DigitsNumber);
    FontSize=instance.parameters.FontSize;
 
	
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
    
    instance:setLabelColor(instance.parameters.Color1);
end

function Update(period)
end

local init = false;

function Draw(stage, context)
 local i, iLevel;
    if stage == 0 then
    
        if not init then
            for i=1, 20, 1 do
             context:createPen(i, context:convertPenStyle(instance.parameters:getInteger("Style" .. i)), instance.parameters:getInteger("Width" .. i), instance.parameters:getColor("Color" .. i));
            end 
            if FontSize==0 then
               context:createFont(21, "Arial", 0, -context:pointsToPixels(pipSize), 0);
            else  
               context:createFont(21, "Arial", 0, FontSize, 0);
            end 
            init = true;
        end
        
        local top, bottom = context:top(), context:bottom();
        local topPrice, bottomPrice = context:priceOfPoint(top), context:priceOfPoint(bottom);
        local left, right = context:left(), context:right();
        
        local MaxLevel, MinLevel;
        local Level;
        local v, y;
        local w, h;
        for i=1, 20, 1 do
         if instance.parameters:getBoolean("Enable" .. i) then
          Level=instance.parameters:getInteger("Level" .. i)*pipSize;
          MaxLevel=math.floor((topPrice-Level)/(Dig*pipSize))*(Dig*pipSize)+Level;
          MinLevel=math.ceil((bottomPrice-Level)/(Dig*pipSize))*(Dig*pipSize)+Level;
          iLevel=MinLevel;
          while iLevel<=MaxLevel do
		  
		      
				     if  core.crossesOver  (source, iLevel, source:size()-1) 
							 and Last[i]~= source:serial(source:size()-1)
							 then	
							  Last[i]= source:serial(source:size()-1)
							 GiveAlert("Cross Over " ..  string.format("%." .. 2 .. "f",  iLevel)  );
							 elseif  core.crossesUnder  (source, iLevel, source:size()-1) 
							 and Last[i]~= source:serial(source:size()-1)
							 then 
							 Last[i]= source:serial(source:size()-1)
							GiveAlert("Cross Under" ..   string.format("%." .. 2 .. "f",  iLevel)  );
							 end
	 
           v, y=context:pointOfPrice(iLevel);
           context:drawLine(i, left, y, right, y);
           if ShowLabels then
            w, h=context:measureText(21, iLevel, context.LEFT);
            context:drawText(21, iLevel, instance.parameters:getColor("Color" .. i), -1, right-w, y, right, y+h, context.CENTER+context.VCENTER);
           end
           iLevel=iLevel+Dig*pipSize;
          end
         end
        end

    end
end




function GiveAlert(Label) 
    
	SoundAlert(Sound);
	Pop("Alert",  source:instrument(), Label   ); 
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
 

function Pop(label , Instrument,Label )

   if not Show then
   return;
   end
   
  	local DATA = core.dateToTable (core.now());
	
    
   local delim = "\013\010";  
  
   local Time =  " Date : " .. DATA.month.." / ".. DATA.day.. delim .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec; 
   
     local text = " Instrument : " .. Instrument.. delim ..  Time.. delim  .. Label .. " : " ..label;

   core.host:execute ("prompt", 1,  Label .. " : " ..label ,   text );


end

function SoundAlert(iAlert )
 if not PlaySound then
 return;
 end
  
  
  
 terminal:alertSound(iAlert, RecurrentSound);
end

function AsyncOperationFinished(cookie)
end




