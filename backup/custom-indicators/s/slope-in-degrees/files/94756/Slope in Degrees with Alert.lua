-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60870


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
    indicator:name("Slope in Degrees");
    indicator:description("Slope in Degrees");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "End of Turn / Live", "", "Live");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");  
	indicator.parameters:addBoolean("Show", "Show Dialog box Alert", "", true);
	 indicator.parameters:addBoolean("OnlyOnce", "Alert Once", "Subsequent Alert will be ignored.", false);	
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 1, 1, 1000);
	
	indicator.parameters:addGroup("Style");
     
	indicator.parameters:addInteger("height", "Height (% of chart height)", "", 20);
    indicator.parameters:addColor("up", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("color", "Label Color", "", core.rgb(0, 0, 0));
    indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100);
	
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 45);
    indicator.parameters:addDouble("oversold","Oversold Level","", -45);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	indicator.parameters:addBoolean("Alternate", "Alternate OB/OS Colors", "", false);
	
		
	indicator.parameters:addGroup("Alerts Sound");   
    indicator.parameters:addBoolean("PlaySound", "Play Sound", "", true);	
    indicator.parameters:addBoolean("RecurrentSound", "Recurrent Sound", "", false);
	
	indicator.parameters:addGroup("Alerts Email");   
	indicator.parameters:addBoolean("SendEmail", "Send Email", "", true);
    indicator.parameters:addString("Email", "Email", "", "");
    indicator.parameters:setFlag("Email", core.FLAG_EMAIL);
	
	
	Parameters (1, "Zero Line Cross")
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


-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local 	Number = 1;

local Period;
local height,up, down,transparency;
local first;
local source = nil;
local color;
-- Streams block
local Slope = nil;
local Alternate;
local iLabel={0,10, 20,30, 40, 50, 60, 70, 80, 90, -10, -20, -30, -40, -50, -60,-70, -80, -90};
local Live;
local OnlyOnceFlag;
local Label={};

local Up={};
local Down={};
local ON={};
local Email;
local SendEmail;
local RecurrentSound ,SoundFile  ;
local Show;
local Alert;
local PlaySound;
local FIRST=true;
local OnlyOnce;
local U={};
local D={};

function AsyncOperationFinished (cookie, success, message)
end


function Pop(label , note)
  
   if not Show then
   return;
   end
   
  core.host:execute ("prompt", 1, label ,   " ( " .. source:instrument() .. " ) "  ..   label .. " : " .. note );
  
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
   
   local text="";
    
    local Time =  " Date : " .. DATA.month.." / ".. DATA.day .." Time:  ".. DATA.hour  .." / ".. DATA.min .." / ".. DATA.sec;    
    text = Note  .. delim ..  Symbol   .. delim .. Time;
	 
	
   terminal:alertEmail(Email, profile:id(), text);  
 
 
end
	 
 
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Alternate = instance.parameters.Alternate;
	OnlyOnceFlag=true;
	FIRST=true;
	OnlyOnce = instance.parameters.OnlyOnce;
	Show = instance.parameters.Show;
	Live = instance.parameters.Live;
	height = instance.parameters.height/100;
	up = instance.parameters.up;
	down = instance.parameters.down;
	color = instance.parameters.color;
	transparency = instance.parameters.transparency;
    source = instance.source;
    first = source:first()+Period+1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	 Slope = instance:addInternalStream(0, 0);
	 
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



local init = false;
 
function Draw(stage, context)
    if stage~= 2 then
	return;
	end
	
	   if not init then
	   context:createSolidBrush(2, up);
       context:createPen(1, context.SOLID, 1, up);
	   
	   context:createSolidBrush(4, down);
       context:createPen(3, context.SOLID, 1, down);
	   
	   context:createFont (5, "Arial", 10, 10, 0)
	   
	    context:createPen(6, context:convertPenStyle (instance.parameters.level_overboughtsold_style), instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		context:createSolidBrush(7, instance.parameters.level_overboughtsold_color);
	   
	   
	   transparency = context:convertTransparency(instance.parameters.transparency);
	   init= true;
	   end
	   
	context:setClipRectangle (  context:left (), context:top(), context:right (), context:bottom());
	
	    local firstBar, lastBar = context:firstBar(), context:lastBar();
        firstBar=math.max(firstBar, first);
        lastBar=math.min(lastBar, source:size()-1);
	
		if firstBar<= first then
		return;
		end	

	local i;
	local x11,y11, x12,y12;
	local top, bottom; 
	local HeightCoeff;
	local min, max, Max;
	
	
	
	for i= firstBar,  	lastBar, 1 do	
		x1, x , x  = context:positionOfBar (i-Period); 
		visible, y1 = context:pointOfPrice (source[i-Period])
		x2, c1 , c2  = context:positionOfBar (i);	 
		visible, y2 = context:pointOfPrice (source[i])
		Slope[i] = AngleCalculation(x1,y1, x2,y2);
	end			 
	
	
          min,max=mathex.minmax(Slope, firstBar, lastBar);	 
			Max=math.max(math.abs(min), math.abs(max));
									
			top, bottom = context:top(), context:bottom();
			HeightCoeff=(bottom-top)*(height )/Max;
	
	for i= firstBar,  	lastBar, 1 do	
	
				x1, x , x  = context:positionOfBar (i-Period);
				y1=(source[i-Period]);	
				x2, c1 , c2  = context:positionOfBar (i);	
				y2= (source[i]);
	
			     BarHeight=HeightCoeff*Slope[i];
				 
					 if Slope[i] < 0 then
					y2=bottom-HeightCoeff* Max + BarHeight;
				     y1=bottom-HeightCoeff* Max ;
						 if Alternate and Slope[i] <= instance.parameters.oversold then
						 context:drawRectangle(6, 7, c1, y1, c2, y2, transparency);
						 else
						context:drawRectangle(1, 2, c1, y1, c2, y2, transparency);
						end
					else
					 y1=bottom-HeightCoeff* Max  +BarHeight;
				     y2=bottom-HeightCoeff* Max ;
							 if Alternate and Slope[i] >= instance.parameters.overbought then
							 context:drawRectangle(6, 7, c1, y1, c2, y2, transparency);
							else
							context:drawRectangle(3, 4, c1, y1, c2, y2, transparency);
							end
					end
			  
			 
				 
	end
	
	
 
	
	
	          for j= 1, 19, 1 do
					 	 
					   if math.abs(iLabel[j])<= Max then
					   iwidth, iheight = context:measureText (5, tostring(iLabel[j]), context.LEFT)	
					   y=bottom-HeightCoeff* Max - HeightCoeff* iLabel[j];					  
					   context:drawText (5,tostring( iLabel[j]), color, -1,  context:right ()-iwidth, y-iheight,  context:right  () , y, context.LEFT  )
                       end				 
			 	end
				
				     y=bottom-HeightCoeff* Max - HeightCoeff* (instance.parameters.overbought);			
					context:drawLine (6,  context:left (), y,  context:right (), y);
					  y=bottom-HeightCoeff* Max - HeightCoeff* (instance.parameters.oversold);			
	                context:drawLine (6,  context:left (), y,  context:right (), y);
					
					  y=bottom-HeightCoeff* Max - HeightCoeff* (0);			
	                context:drawLine (6,  context:left (), y,  context:right (), y);
end	

function  AngleCalculation(x1,y1, x2,y2)
	
		 return (math.atan2((y2-y1), (x2-x1)) * 180 / math.pi);
end


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    if period < source:size()-1 then
	return;
	end
	
	  core.host:execute("setStatus", string.format("%." .. 2 .. "f", -Slope[period])); 
	
    Activate (1, period)
	
	
end


function Activate (id, period)

   local Shift=0;
   

   if Live~= "Live" then
	period=period-1;
	Shift=1;
	end
 
	  if id == 1  and ON[id]  then
	  
	       
			if  Slope[period] < 0
			and   Slope[period-1] >= 0
			then
			           
						    
       
 						 
						   
			
			 D[id] = nil;
						   
							  if U[id]~=source:serial(period) 
							  and period == source:size()-1-Shift
							  and not FIRST 
							  then
							  OnlyOnceFlag=false;
							  U[id]=source:serial(period);
							  SoundAlert(Up[id]);
							  EmailAlert(  Label[id], " Cross Over", period);
							    
							        
									Pop(Label[id], " Cross Over " );  	
								    
								 
							  end
			elseif  Slope[period] > 0
			and   Slope[period-1] <= 0
            then			
			
			            			 
			               
						   
		     U[id] = nil;
		   
			                 if  D[id]~=source:serial(period)
							 and period == source:size()-1-Shift
							 and not FIRST 
							 then
							 OnlyOnceFlag=false;
							 D[id]=source:serial(period);
							 SoundAlert(Down[id]);			 
							 EmailAlert( Label[id] , " Cross Under", period);	
								 
									Pop(Label[id], " Cross Under " );  	
								  
							 
			                  end			   
	         end
			
	  
	 
	  end
	  
		   
        if FIRST then
        FIRST=false;      
        end		

end
