-- Id: 10958

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60216

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
    indicator:name("Moving Average Support Resistance");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("MA Calculation");
	indicator.parameters:addString("Method1", "First MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	indicator.parameters:addInteger("Period1", "First Period", "Period", 20);
	
	indicator.parameters:addString("Method2", "Second MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	indicator.parameters:addInteger("Period2", "Second Period", "Period", 50);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addBoolean("Show" , "Show MA`s", "", true);
	
	indicator.parameters:addInteger("LookBack", "Look Back Period", "Period", 300);
	indicator.parameters:addInteger("Tolerance", "Tolerance Period", "Period", 0);
	indicator.parameters:addString("Find", "Search for ", "Search for ", "Both");	
	 indicator.parameters:addStringAlternative("Find", "Support", "", "Support");
    indicator.parameters:addStringAlternative("Find", "Resistance", "", "Resistance");
    indicator.parameters:addStringAlternative("Find", "Both", "", "Both");
	
 
    indicator.parameters:addGroup("Style");   
    indicator.parameters:addColor("color", "Label Color", "", core.rgb(0, 128, 255));
	indicator.parameters:addColor("Up_Color", "Resistance Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down_Color", "Support Color", "", core.rgb(255, 0, 0));
   
    indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100);
	
	indicator.parameters:addGroup("MA Style");   
    indicator.parameters:addColor("First", "First MA Color", "", core.rgb(0, 255, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("Second", "Second MA Color", "", core.rgb(255, 0, 255));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end
local LookBack;
local Tolerance;
local first;
local source = nil;
local color,Down_Color,Up_Color;
local transparency;
local Method1, Method2;
local Period1, Period2; 
local init = false;
local up, down, Up, Down;
local Last;
local Find; 
 
local Show;
local First, Second;
local One, Two;
-- initializes the instance of the indicator
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    source = instance.source;
	 Tolerance=instance.parameters.Tolerance;
	color=instance.parameters.color;
	Method1=instance.parameters.Method1;
	Method2=instance.parameters.Method2;
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Show=instance.parameters.Show;
	 
	LookBack=instance.parameters.LookBack;
	Down_Color=instance.parameters.Down_Color;
	Up_Color=instance.parameters.Up_Color;
	Find=instance.parameters.Find;
 
	
	
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
	One = core.indicators:create(Method1, source, Period1);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
	Two = core.indicators:create(Method2, source, Period2);
	
	first=math.max(One.DATA:first(),Two.DATA:first() )
	
	if Show then
	First = instance:addStream("First", core.Line, name, "First MA", instance.parameters.First, first);
	First:setWidth(instance.parameters.width1);
    First:setStyle(instance.parameters.style1);
	Second  = instance:addStream("Second", core.Line, name, "Second MA", instance.parameters.Second, first);
	Second:setWidth(instance.parameters.width2);
    Second:setStyle(instance.parameters.style2);
	else
	First = instance:addInternalStream(0, 0);
	Second = instance:addInternalStream(0, 0);
	end
 
 

    instance:ownerDrawn(true); 
    instance:setLabelColor(color);
end

function Update(period, mode)

One:update(mode);
Two:update(mode);
 
 if period < first then
 return;
 end
 
 First[period]=One.DATA[period];
 Second[period]=Two.DATA[period];

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
					
					
		  local i, c1, c2,p1, p2, p3,r1, r2, r3,visible1,visible2, y1, y2,j, count;
		  for i = math.max(first,source:size()-1-LookBack+1, context:firstBar ()) , math.min(source:size()-1, context:lastBar ()), 1 do 
		  
			  if core.crossesOver (First, Second, i) then
			  c1=3;
			  c2=4;		
			  j= UpFractal(i, context:firstBar ());
				   if j~= nil then
				   r1, r2, r3 = context:positionOfBar(j);  	
				  visible1, y1 = context:pointOfPrice (First[j]);
				  count= Count(i,context:lastBar (), true );
				  
				  p1, p2, p3 = context:positionOfBar(i);			  
				  visible2, y2 = context:pointOfPrice (Second[i]);
				  end			  
			  elseif   core.crossesUnder (First, Second, i) then
			  c1=1;
			  c2=2;		
			  j= DownFractal(i,context:firstBar ());
				   if j~= nil then
				   r1, r2, r3 = context:positionOfBar(j); 
				   visible1, y1 = context:pointOfPrice (First[j]);	
				   count= Count(i,context:lastBar (), false);
				   p1, p2, p3 = context:positionOfBar(i); 
				  visible2, y2 = context:pointOfPrice (Second[i]);	
				  end
			  end 
			  
			 if visible1 and visible2  and j~= nil and  count <=Tolerance then 
			  context:drawRectangle (c1,c2, r1 , y1, right, y2, instance.parameters.transparency);
			end
			
		  end
      
end

function Count (j, last, flag )
local i
local count=0;

for i= j,  math.min(last, source:size()-1) do

		if flag then
			if source[i]< Second[j] then
			count=count+1;
			end
		else
		   if source[i] > Second[j] then
			count=count+1;
			end
		end


end

return count;

end

 
		 
function UpFractal (i, FirstBar )					 
 		
local Return= nil ;
			
	for j= i, math.max(first,FirstBar+1) , -1 do
	            
			
				if First[j]< First[j-1] then
				Return = j;
				break;
				end			
	
	end	
	return Return;					 
end


function DownFractal (i, FirstBar)					 
			
local Return= nil ;
			
	for j= i,  math.max(first,FirstBar+1) , -1 do	
			
				if First[j]> First[j-1] then
				Return = j;
				break;
				end			
	end
	
	return Return;	
				 
end
