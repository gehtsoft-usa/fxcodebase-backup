 -- More information about this indicator can be found at:
 -- http://fxcodebase.com/code/viewtopic.php?f=17&t=70587

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("RiskReward Ratio Measuring Tool");
    indicator:description(" ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Entry Line Style");
	indicator.parameters:addColor("color_entry", "Line Color", "",core.rgb(0, 0, 255));
    
    indicator.parameters:addInteger("width_entry", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style_entry", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style_entry", core.FLAG_LINE_STYLE);	
    
	
	indicator.parameters:addGroup("Stop Line Style");
	indicator.parameters:addColor("color_stop", "Line Color", "",core.rgb(255, 0, 0));    
    indicator.parameters:addInteger("width_stop", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style_stop", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style_stop", core.FLAG_LINE_STYLE);	
	
	
	
	indicator.parameters:addGroup("Limit Line Style");
	indicator.parameters:addColor("color_limit", "Line Color", "",core.rgb(0, 255, 0));    
    indicator.parameters:addInteger("width_limit", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style_limit", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style_limit", core.FLAG_LINE_STYLE);	
 
	
	indicator.parameters:addGroup("Style");
	 indicator.parameters:addColor("Label", "Label Color", "Color of Label",core.rgb(0, 0, 0));
     indicator.parameters:addInteger("Size", "Font Size", "Font Size",10);
	  indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 50, 0, 100);
 
end
 
 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Size, Label;
local first;
local source = nil;
local pattern = "([^;]*);([^;]*)"; 
local db;
local Line_Date={};
local Line_Level={};
local style={};
local width={};
local color={};
local transparency;
local  Label_Text={"Entry", "Stop", "Limit"};

function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	 Size=  instance.parameters.Size;
    Label=  instance.parameters.Label;	

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	Line_Date={};
	Line_Level={};
	
		
	
    core.host:execute("addCommand", 1, "Entry Level");
	core.host:execute("addCommand", 2, "Stop Level");
	core.host:execute("addCommand", 3, "Limit Level");
    core.host:execute("addCommand", 4, "Reset");
	
	
	

	if   (nameOnly) then
        return;
    end
	
	
	color[1]=instance.parameters.color_entry;
	color[2]=instance.parameters.color_stop;
	color[3]=instance.parameters.color_limit;
	
	width[1]=instance.parameters.width_entry;
	width[2]=instance.parameters.width_stop;
	width[3]=instance.parameters.width_limit;
	
	
	style[1]=instance.parameters.style_entry;
	style[2]=instance.parameters.style_stop;
	style[3]=instance.parameters.style_limit;
 
		
	require("storagedb");
    db = storagedb.get_db(name);	 
	
	instance:ownerDrawn(true);
	
	core.host:execute("setTimer", 5, 1);
	
	
end


function ReleaseInstance()
core.host:execute ("killTimer", 5);
end 


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    
end


local init = false;

function Draw (stage, context)

    if stage  ~= 2 then
	return;
	end
 
 
	 
  
      context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
    if not init then
	init =true;
	
	for i= 1, 3, 1 do
	context:createPen (i, context:convertPenStyle (style[i]), context:pixelsToPoints (width[i]), color[i]);
	context:createSolidBrush (10+i, color[i]);
    end
	
		 context:createFont (10, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
	 
		
		transparency = context:convertTransparency(instance.parameters.transparency); 
	end
 
   
    local y={};
	
	x , x1, x2 = context:positionOfBar (source:size()-1);
	
    for i=1, 3 , 1 do
	
	
	   
	
		if Line_Level[i]~=0 and  Line_Level[i]~=nil
		then	
		
		  itis, y[i]= context:pointOfPrice (Line_Level[i]);
		   
		
		 context:drawLine (i, context:left (), y[i],context:right (), y[i]); 
		 
		 		 
        Text= Label_Text[i] .. " : " .. string.format("%." .. source:getPrecision() .. "f", Line_Level[i]);
	 
		Width, Height = context:measureText (10, Text, 0);
		
		context:drawText (10, Text, Label, -1, x+100, y[i]-Height,x+100+Width, y[i], 0);
		
		end
		
		
		
	
	end
	
	
 
	 
	
	
     	if y[2]~=nil and  y[1]~=nil then 
		context:drawRectangle (2, 12, x+25, y[1], x+50, y[2], transparency); 
		end
		
		if y[3]~=nil and  y[1]~=nil then 
		context:drawRectangle (3, 13, x+25, y[1], x+50,  y[3], transparency); 
		end
 
 
        if y[1]~= nil and  y[2]~= nil  and y[3]~= nil  then
        Text= "R/R Ratio : " .. string.format("%." .. 1 .. "f", math.abs( y[1]- y[3])/math.abs( y[1]- y[2]));
	 
		Width, Height = context:measureText (10, Text, 0);
		
		context:drawText (10, Text, Label, -1,  x+100, y[3],x+100 + Width, y[3]+Height, 0);
   
 
        end
end	


function AsyncOperationFinished(cookie, success, message)


  
	
	if cookie==1 then	
	Level, Date = string.match(message, pattern, 0);
	db:put("Entry_Level" , tostring(Level));  
    db:put("Entry_Date" , tostring(Date));  	
	end
	
	
	if cookie==2 then	
	Level, Date = string.match(message, pattern, 0);
	db:put("Stop_Level" , tostring(Level));  
    db:put("Stop_Date" , tostring(Date));  	
	end
	
	
	if cookie==3 then	
	Level, Date = string.match(message, pattern, 0);
	db:put("Limit_Level" , tostring(Level));  
    db:put("Limit_Date" , tostring(Date));  	
	end
	
	
	if  cookie==4 then	
	
		db:put("Entry_Level" , tostring(0));  
		db:put("Entry_Date" , tostring(0));  
			
		db:put("Stop_Level" , tostring(0));  
		db:put("Stop_Date" , tostring(0));  		
 
		db:put("Limit_Level" , tostring(0));  
		db:put("Limit_Date" , tostring(0));  	
		
	end
	
	
	if cookie==5 then	
	
    Line_Date[1]= tonumber(db:get ("Entry_Date", 0));
	Line_Date[2]= tonumber(db:get ("Stop_Date", 0));
	Line_Date[3]= tonumber(db:get ("Limit_Date", 0));
	
	Line_Level[1]= tonumber(db:get ("Entry_Level", 0));
	Line_Level[2]= tonumber(db:get ("Stop_Level", 0));
	Line_Level[3]= tonumber(db:get ("Limit_Level", 0));
	
	end
        
	instance:updateFrom(0);
    return core.ASYNC_REDRAW ;
	
end


