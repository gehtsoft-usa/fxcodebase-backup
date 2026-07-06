-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32568
-- Id: 11781

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Trans Currency Pair, Trans Time Frame Lines");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup("Parameters");	
    indicator.parameters:addString("Name", "Arhive Name", "", "Multi");
	
	
	local i;	
	for i=1,10, 1 	do
	Add(i);
	end
    
   
end 

function getRainbowColour(ratio)
    -- Using HSV colour system, where Hue is changed in proportion to ratio
    
    ratio = math.max(0, math.min(1, ratio));
    
    -- NOTE: hue is an angular value and can be 0..360, but it wraps around back to 'red' again
    -- which looks a bit weird so I limit to 300 degrees
    local hue = 300 * (1 - ratio);
    
    -- Convert back to RGB
    return convertHSVtoRGB(hue, 1, 1);
end

function convertHSVtoRGB(hue, saturation, value)
    -- http://en.wikipedia.org/wiki/HSL_and_HSV
    -- Hue is an angle (0..360), Saturation and Value are both in the range 0..1
    
    local hi = (math.floor(hue / 60)) % 6;
    local f = hue / 60 - math.floor(hue / 60);

    value = value * 255;
    local v = math.floor(value);
    local p = math.floor(value * (1 - saturation));
    local q = math.floor(value * (1 - f * saturation));
    local t = math.floor(value * (1 - (1 - f) * saturation));

    if hi == 0 then
        return core.rgb(v, t, p);
    elseif hi == 1 then
        return core.rgb(q, v, p);
    elseif hi == 2 then
        return core.rgb(p, v, t);
    elseif hi == 3 then
        return core.rgb(p, q, v);
    elseif hi == 4 then
        return core.rgb(t, p, v);
    else
        return core.rgb(v, p, q);
    end
end

function Add(i)
     indicator.parameters:addGroup(i.. ". Line Style");	
    indicator.parameters:addColor("Color"..i, "Line Color", "Line Color", getRainbowColour(i/10));
	indicator.parameters:addInteger("Width"..i, "Line width", "", 1, 1, 4);
    indicator.parameters:addInteger("Style"..i, "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style"..i, core.FLAG_LINE_STYLE);
	indicator.parameters:addBoolean("Extend"..i , "Extend Line", "", true);
end

local first;
local source = nil;
local Name;
local db; 
local Color={};
local Style={};
local Width={};
local Extend={};
local Period;
function Prepare(nameOnly)
    
    source = instance.source;
    first = source:first();
	Name=instance.parameters.Name;

    local name = profile:id() .. "(" .. source:name()  .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end

   
	LoadParameters();
	
	core.host:execute ("addCommand", 101,"Add Horizontal Line", "");
	core.host:execute ("addCommand", 102,"Add Vertical Line", "");
	core.host:execute ("addCommand", 105,"Add 1. Point of Trend Line", "");
	core.host:execute ("addCommand", 106,"Add 2. Point of Trend Line", "");
	core.host:execute ("addCommand", 104,"Delete Line", "");
	core.host:execute ("addCommand", 103,"Reset", "");
	local i;
	
	for i=1, 10 , 1 do	
	Extend[i]=instance.parameters:getBoolean("Extend" .. i);
	Color[i]=  instance.parameters:getColor("Color" .. i);
    Style[i]=instance.parameters:getInteger("Style" .. i);
    Width[i]=instance.parameters:getInteger("Width" .. i);
	core.host:execute ("addCommand", 200+i, "Select Line ".. i .. ". Line", "");	 
	end   		
	 core.host:execute ("setTimer", 111,  1); 
end

function LoadParameters()
require("storagedb");
db  = storagedb.get_db(Name);
db:put(tostring("Selected"), tostring(1));	
end

function Update(period)
    if period < source:size()-1 then
	return;
	end
		
end

function Draw()

 core.host:execute ("removeAll");
 
if not source:hasData(first)
or not source:hasData(source:size()-1)
then
return;
end

local i, Date1, Level1, Date2, Level2, Type1, Type2, Instrument1, Instrument2;
for i = 1, 10, 1 do

Date1=tonumber(db:get (tostring(i.."Date1"), 0));
Level1=tonumber(db:get (tostring(i.."Level1"), 0));
Date2=tonumber(db:get (tostring(i.."Date2"), 0));
Level2=tonumber(db:get (tostring(i.."Level2"), 0));
Type1=(db:get (tostring(i.."Type1"), 0));
Type2=(db:get (tostring(i.."Type2"), 0));
Instrument1=(db:get (tostring(i.."Instrument1"), 0));
Instrument2=(db:get (tostring(i.."Instrument2"), 0));

    if Level2 == 0 and Level1  ~= 0 and Date1 ~= 0 then
	
	          if Type1== "H"  and Instrument1 == source:name()  then   
	          core.host:execute("drawLine", i, source:date(source:first()), Level1, source:date(source:size()-1) , Level1, Color[i], Style[i], Width[i]);
			  elseif Type1 == "V"  then
			  core.host:execute("drawLine", i, Date1,math.huge, Date1, 0,Color[i], Style[i], Width[i]);
			  end
	elseif  Level1 ~= 0 and Level2  ~= 0  and Instrument1 == source:name() and Instrument2 == source:name() and   Type1 == "T"  and Type2 == "T"  then	
	          
			  
			  if  Extend[i]   then
				local a,b;
				local y1=Level1;
				local y2=Level2;
				local x1=core.findDate (source, Date1, false);
				local x2=core.findDate (source, Date2, false);
				a,b=getline(x1, y1, x2, y2);
		       local Date3=source:date(first);
			   local Date4=source:date(source:size()-1);
			   local Level3=a* first + b;
			   local Level4=a* (source:size()-1) + b;
			    core.host:execute("drawLine", 1000+i, Date3,Level3, Date4, Level4,Color[i], core.LINE_DASH, Width[i]);
				end
				
			  
			  core.host:execute("drawLine", i, Date1,Level1, Date2, Level2,Color[i], Style[i], Width[i]+1);
			 
	end
end


end

function getline(x1, y1, x2, y2)
    local a, b;

    a = ((y2 - y1) / (x2 - x1));
    b = (y1 - a * x1);
    return a, b;
end
		

local pattern = "([^;]*);([^;]*)";

function Parse(message)


    if message == nil then
        return 0, 0;	 
    end
    local level, date;
    level, date= string.match(message, pattern, 0);
	
    if level == nil or date == nil then
        return 0, 0;	 
    end
	return tonumber(date),tonumber(level) ;
end

function AsyncOperationFinished(cookie, success, message)

    
    local  Selected;
    
	 if cookie == 101 then
	     
		  local Date, Level;
         Date, Level  = Parse(message);
	     Selected=tonumber(db:get ("Selected", 0));
			 
		 db:put(tostring(Selected.."Level1"), tostring(Level));			  
		 db:put(tostring(Selected.."Date1"), tostring(Date));	
         db:put(tostring(Selected.."Type1"), tostring("H"));	
         db:put(tostring(Selected.."Instrument1"), tostring(source:name()));  	  		 
        		 
	 
	 elseif cookie == 102 then
	 
          local Date, Level;
         Date, Level  = Parse(message);
		 Selected=tonumber(db:get ("Selected", 0));
	  
		 db:put(tostring(Selected.."Level1"), tostring(Level));			  
		 db:put(tostring(Selected.."Date1"), tostring(Date));
		 db:put(tostring(Selected.."Type1"), tostring("V"));	
		 db:put(tostring(Selected.."Instrument1"), tostring(source:name())); 

	 elseif cookie == 103 then	 
			 core.host:execute ("removeAll");	
			 
				 	
			  for i = 1,10, 1 do
					db:put(tostring(i.."Level1"), tostring(0));			
					db:put(tostring(i.."Date1"), tostring(0)); 
					db:put(tostring(i.."Level2"), tostring(0));			
					db:put(tostring(i.."Date2"), tostring(0)); 
			  end		
			  
	 elseif cookie == 104 then		
	    Selected=tonumber(db:get ("Selected", 0));			
	     db:put(tostring(Selected.."Level1"), tostring(0));			  
		 db:put(tostring(Selected.."Date1"), tostring(0));
		 db:put(tostring(Selected.."Level2"), tostring(0));			  
		 db:put(tostring(Selected.."Date2"), tostring(0));
	  elseif cookie == 105 then
	     
		  local Date, Level;
         Date, Level  = Parse(message);
	     Selected=tonumber(db:get ("Selected", 0));
			 
		 db:put(tostring(Selected.."Level1"), tostring(Level));			  
		 db:put(tostring(Selected.."Date1"), tostring(Date));	
         db:put(tostring(Selected.."Type1"), tostring("T"));	
         db:put(tostring(Selected.."Instrument1"), tostring(source:name())); 	 
	 elseif cookie == 106 then
	     
		  local Date, Level;
         Date, Level  = Parse(message);
	     Selected=tonumber(db:get ("Selected", 0));
			 
		 db:put(tostring(Selected.."Level2"), tostring(Level));			  
		 db:put(tostring(Selected.."Date2"), tostring(Date));	
         db:put(tostring(Selected.."Type2"), tostring("T"));	
         db:put(tostring(Selected.."Instrument2"), tostring(source:name())); 	 
      	 
     elseif 	cookie > 200 then
          	
	     db:put(tostring("Selected"), tostring(cookie-200));
		 
	 end
	 
	 Selected=tonumber(db:get ("Selected", 0));
    core.host:execute ("setStatus", "Selected :" .. Selected);
	
	 Draw();
	return core.ASYNC_REDRAW ;
	
end
 