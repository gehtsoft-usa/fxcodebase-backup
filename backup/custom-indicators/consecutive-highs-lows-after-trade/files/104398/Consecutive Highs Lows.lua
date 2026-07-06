
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63057

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



function Init()
    indicator:name("Consecutive Highs Lows");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Period", "Period",4);
 
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up  color", "Up  color", core.rgb(0,255,0));
    indicator.parameters:addColor("Down", "Down  color", "Down  color", core.rgb(255,0,0)); 
	indicator.parameters:addInteger("Size", "Font Size", "", 20, 1 , 100);	 
end

local source;
local Size;
local Period;
local first;
local Up,Down;
local Array={};
local Side={};
local Num;
local Ignore;
function Prepare(nameOnly)
    source = instance.source;
    Size = instance.parameters.Size;
	Period = instance.parameters.Period; 
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	 
    first=source:first();	 
	 
    local name = profile:id() ;
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	instance:ownerDrawn(true);
end

function Update(period) 
 

			   
			 

	     
	      
	 
end
function Check(Index)
local p1=0;
local p2=0;
local Long=0;
local Short=0;
local i=0;

	for i= 1, Period, 1 do
	
	
		
		if 	Index+i > source:size()-1 then
		break;
		end
		
        
			
				if source.close[Index-i+1]>= source.close[Index-i]  then			
				Long=Long+1;
				end
				
				if source.close[Index-i+1]<= source.close[Index-i]  then
				Short=Short+1;
				end 
			
		 	
		
	end
	
	if Long==Period then
	p2=Index+i;
	p1=1;
	elseif Short== Period then
	p2=Index+i;
	p1=-1;
	end

return p1, p2;


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
	
			
	local Text1=  "\234";
	local Text2=  "\233"; 
	 width, height = context:measureText (1, Text1, 0);
	
	for i= math.max(context:firstBar (), source:first()), math.min(context:lastBar (), source:size()-1 ), 1 do
	
        p1, p2= Check (i);
	
	       if p2 < context:lastBar()
		   and p2 < source:size()-1 
		   and p1 ~=0
		   then
					x, x1, x2 =context:positionOfBar (i);
					visible, y1 = context:pointOfPrice (source.high[i]);
					visible, y2 = context:pointOfPrice (source.low[i]);
			
					if p1 == 1 then
					context:drawText (1,  Text1, Up  , -1,  x-width/2 ,  y1-height   ,x+width/2           ,y1       , context.BOTTOM );
					elseif p1 == -1 then	
					context:drawText (1,  Text2, Down, -1,  x-width/2 ,  y2          ,x+width/2           ,y2+height, context.TOP );
					end
			end
	end

end		
 
 
 
 
 
