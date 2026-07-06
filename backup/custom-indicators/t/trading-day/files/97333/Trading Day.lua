-- Id: 13131
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61528

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
    indicator:name("Trading Day ");
    indicator:description("Trading Day ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Y", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Right");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 

    indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("Size", "Font Size", "", 20);
    indicator.parameters:addColor("Label", "Label Color", "Label Color", core.rgb(0, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

-- Streams block
local Label = nil;
local Size;
local X,Y;
local Day;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	Label=instance.parameters.Label;
	Size=instance.parameters.Size;
	Y=instance.parameters.Y;
	X=instance.parameters.X;  

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	Day=0;
	
	local date= core.dateToTable (core.now ());
	year= date.year;
	month= date.month;
	day= date.day; 

	for i=1, month-1, 1 do
	Add=get_days_in_month(month, year);
	Day=Day+ Add;
	end
	
	Day=Day+day; 
	
    instance:ownerDrawn(true);
 
end

local init = false;
 
function Draw(stage, context)
 
	if stage ~= 2 then
	return;
	end
	
        if not init then
           context:createFont (1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
	
	local date= core.dateToTable (core.now ());
	
	local Text1=  "Month  : " ..  date.day;
	 
   width, height = context:measureText (1, Text1, 0);
   context:drawText (1,  Text1, Label, -1,  iX(context,width,0,1) ,  iY(context,height,0,1) ,iX(context,width,0,2),iY(context,height,0,2), 0 );	
   

   	local Text2=  "Year : " .. Day;
	 
   width, height = context:measureText (1, Text2, 0);
   context:drawText (1,  Text2, Label, -1,  iX(context,width,0,1) ,  iY(context,height,1,1) ,iX(context,width,0,2),iY(context,height,1,2), 0 );	
   
end		
 
 

function iX(context, width,Shift,x)

	if X== "Left" then
	return  context:left()+ Shift*width +  width*(x-1) ;
	else
	return context:right() - width*Shift -  width*(1-(x-1));
	end
end



function iY(context, height,Shift,x)

	if Y== "Top" then
		return context:top()+Shift* height + height*(x-1) ;
	else
	return context:bottom()-Shift* height + height*(x-1) ;
	end
end




-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
 
 
 
end


 function get_days_in_month(month, year)
  local days_in_month = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }   
  local d = days_in_month[month]
   
  -- check for leap year
  if (month == 2) then
    if (math.mod(year,4) == 0) then
     if (math.mod(year,100) == 0)then                
      if (math.mod(year,400) == 0) then                    
          d = 29
      end
     else                
      d = 29
     end
    end
  end

  return d  
end 