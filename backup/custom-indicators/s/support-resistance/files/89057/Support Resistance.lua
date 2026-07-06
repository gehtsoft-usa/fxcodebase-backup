-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59367


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
    indicator:name("Support Resistance");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addInteger("LookBack", "Look Back Period", "Period", 1000);
	indicator.parameters:addString("Find", "Search for ", "Search for ", "Both");	
	indicator.parameters:addStringAlternative("Find", "Support", "", "Support");
    indicator.parameters:addStringAlternative("Find", "Resistance", "", "Resistance");
    indicator.parameters:addStringAlternative("Find", "Both", "", "Both");
	
	indicator.parameters:addString("Method", "Validation Method", "Validation" , "High/Low");
    indicator.parameters:addStringAlternative("Method", "High/Low", "High/Low" , "High/Low");
    indicator.parameters:addStringAlternative("Method", "Open/Close", "Open/Close" , "Open/Close");
	
	indicator.parameters:addString("Zone", "Zone Method", "Zone Method" , "Narrow");
    indicator.parameters:addStringAlternative("Zone", "Narrow", "Narrow" , "Narrow");
    indicator.parameters:addStringAlternative("Zone", "Wide", "Wide" , "Wide");
	
	indicator.parameters:addInteger("Tolerance", "Tolerance", "Tolerance", 0, 0 , 10);	
	
    indicator.parameters:addGroup("Style");   
    indicator.parameters:addColor("color", "Label Color", "", core.rgb(0, 128, 255));
	indicator.parameters:addColor("Up_Color", "Resistance Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down_Color", "Support Color", "", core.rgb(255, 0, 0));
   
    indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100);
end
local LookBack;
local Zone;
local first;
local source = nil;
local color,Down_Color,Up_Color;
local transparency;
local Method;
local TLclr, BLclr, TRclr, BRclr;
local init = false;
local up, down, Up, Down;
local Last;
local Find;
local Method;
local Count=0;
local Tolerance;
-- initializes the instance of the indicator
function Prepare(onlyName)
    source = instance.source;
	Tolerance=instance.parameters.Tolerance;	
	color=instance.parameters.color;
	Method=instance.parameters.Method;
	Zone=instance.parameters.Zone;
	LookBack=instance.parameters.LookBack;
	Down_Color=instance.parameters.Down_Color;
	Up_Color=instance.parameters.Up_Color;
	Find=instance.parameters.Find;
    local name = profile:id() .. "(" .. source:name()  .. ", " .. LookBack .. ", " .. Find .. ", " .. Method.. ", " .. Zone.. ", " .. Tolerance.. ")";
    instance:name(name);
	
	   if onlyName then
        return ;
    end
	
	first=source:first()+6
	
	up = instance:addInternalStream(0, 0);
	down = instance:addInternalStream(0, 0);
	
	Up = instance:addInternalStream(0, 0);
	Down = instance:addInternalStream(0, 0);
	
	Count=0;

 

    instance:ownerDrawn(true); 
    instance:setLabelColor(color);
end

function Update(period)

up[period]=nil;
down[period]=nil;

if period < 2 then
return;
end
 
up[period-2]=nil;
down[period-2]=nil;

if period < first   then
return;
end


Fractal(period);

if period < source:size()-1 then
return;
end

Filters();

end

function Filters()


local i,j;
local Value;
					for i = math.max(first,source:size()-1-LookBack+1) , source:size()-1, 1 do
					
					
					        
							
							if up[i] ~= nil then							
							
							Up[i]= 0;
							
								--for j = up[i]+1 , source:size()-1, 1 do 
								
								j = up[i]+1;
								while (j<=source:size()-1 and Up[i] >= -Tolerance )  do
								
								       if Zone == "Narrow" then
									   Value=math.max(source.close[up[i]], source.open[up[i]]);
									   else
									   Value=math.min(source.close[up[i]], source.open[up[i]]);
									   end
								    
								
										if Method == "High/Low"  then
																			
										
										 if source.high[j] > Value then
										 Up[i]=Up[i]-1;
										 end
										 
										else
										
										 if source.close[j] > Value then
										 Up[i]=Up[i]-1;
										 end
										
										end
										
										--if Up[i] >= -Tolerance then
										j=j+1;
								
								
								end		
							else
                        	Up[i]= nil;													
							end
							
							if down[i]~= nil then							
							Down[i]= 0;
							
							   -- for j = down[i]+1 , source:size()-1, 1 do 
							   j = down[i]+1
								while (j<=source:size()-1 and Down[i] >= -Tolerance )  do
								
								       if Zone == "Narrow" then
									   Value=math.min(source.close[down[i]], source.open[down[i]]);
									   else
									   Value=math.max(source.close[down[i]], source.open[down[i]]);
									   end 
								
								if Method == "High/Low"  then
										
										 if source.low[j] < Value then
										 Down[i]=Down[i]-1;										 
										 end
								 else
								 
								         if source.close[j] < Value then
										 Down[i]=Down[i]-1;											 
										 end
								 
								 end
								 
								        --if Down[i] >= -Tolerance then
										j=j+1
								
								end		

							else                            
							Down[i]= nil;							
							end
					
					end

end

function Fractal (period)

local curr;

        curr = source.high[period - 2];
        if (curr > source.high[period - 4] and curr > source.high[period - 3] and
            curr > source.high[period - 1] and curr > source.high[period]) then           
                up[period-2]= period-2;    
		else
		up[period-2]= nil;
        end
		
        curr = source.low[period - 2];
        if (curr < source.low[period - 4] and curr < source.low[period - 3] and
            curr < source.low[period - 1] and curr < source.low[period]) then            
			 down[period-2]= period-2;  
		else	 
		down[period-2]= nil; 	
        end
end


function Draw(stage, context)
    
	local visible1, y1;
	local visible2, y2;
	local p1, p2, p3;
	
	
    if stage ~=0 then
	return;
	end
		
				
					if not init then
						context:createPen (1, context.SOLID, 1, Up_Color)
						context:createSolidBrush (2, Up_Color)
						
						context:createPen (3, context.SOLID, 1, Down_Color)
						context:createSolidBrush (4, Down_Color)
						init = true;
					end
					local right =  context:right();
					
					
			  
					
					local i;
					for i = math.max(first,source:size()-1-LookBack+1) , source:size()-1  , 1 do
						if Up:hasData(i) and up:hasData(i) then	
							if Up[i] >= -Tolerance  and Up[i] ~= nil   and  Find ~= "Support" then
							visible1, y1 = context:pointOfPrice (source.high[up[i]]);
							visible2, y2 = context:pointOfPrice (math.max(source.open[up[i]],source.close[up[i]]));
							p1, p2, p3 = context:positionOfBar(up[i]);
							context:drawRectangle (1,2, p1 , y1, right, y2, instance.parameters.transparency);
							end
						end
						if Down:hasData(i) and down:hasData(i) then	
							if Down[i] >= -Tolerance and Down[i] ~= nil   and  Find ~= "Resistance" then  
							visible1, y1 = context:pointOfPrice (source.low[down[i]]);
							visible2, y2 = context:pointOfPrice (math.min(source.open[down[i]],source.close[down[i]]));
							p1, p2, p3 = context:positionOfBar(down[i]);
							context:drawRectangle (3,4, p1, y2, right, y1, instance.parameters.transparency);
							end
						end	
						 
			    end
    
end



