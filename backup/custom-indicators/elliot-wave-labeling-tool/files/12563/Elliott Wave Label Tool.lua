
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4360#p12563

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Elliott Wave Label Tool");
    indicator:description("Elliott Wave Label Tool");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator:setTag("group", "Waves");
 
	indicator.parameters:addInteger("Transparency", "Cell Transparency", "Cell Transparency",100);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 


local first;
local source = nil;
 
-- Streams block
local Data = {};
local init = false;
local Transparency; 

local  iColor;
local  iFont; 
local iSize;
local iColor;
local iLabel= nil;
local iForeground;
local iBackground;
local db; 
local pattern = "([^;]*);([^;]*)";
local Flag=true;
local Activ={};
local Selector={};

function AddCell( y, x,font, size, foreground, background ,label)
 
    local Cell = {};
    Cell.x = x;    
	Cell.y = y ;	
	Cell.label = label;
	Cell.font = font;	
	Cell.size = size; 
	Cell.foreground = foreground;
	Cell.background = background;
    Data[#Data+1] = Cell;

end

-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    CellColor = instance.parameters.CellColor;
	LabelColor = instance.parameters.LabelColor;
	 
    source = instance.source;
    first = source:first();
	
	Data={};
	local Size,Foreground,Background;

	Foreground= core.rgb(0, 200, 250);
	Background= core.rgb(128, 128, 128); 
	Size= 6;
	AddCell(5,12,"Arial", Size,Foreground, Background,1);
	AddCell(5,36,"Arial", Size,Foreground, Background,2);
	AddCell(5,62,"Arial", Size,Foreground, Background,3);
	AddCell(5,90,"Arial", Size,Foreground, Background,4);
	AddCell(5,117,"Arial", Size,Foreground, Background,5);
	AddCell(5,140,"Arial", Size,Foreground, Background,"A");
	AddCell(5,165,"Arial", Size,Foreground, Background,"B");
	AddCell(5,190,"Arial", Size,Foreground, Background,"C");
	AddCell(5,213,"Arial", Size,Foreground, Background,"1 or A");
	AddCell(5,270,"Arial", Size,Foreground, Background,"2 or B");
	AddCell(5,330,"Arial", Size,Foreground, Background,"3 or C");	
	----
	Foreground= core.rgb(0, 128, 0);
	Background= core.rgb(128, 128, 128); 
	Size= 6;
	AddCell(20,12,"Arial", Size,Foreground, Background,1);
	AddCell(20,36,"Arial", Size,Foreground, Background,2);
	AddCell(20,62,"Arial", Size,Foreground, Background,3);
	AddCell(20,90,"Arial", Size,Foreground, Background,4);
	AddCell(20,117,"Arial", Size,Foreground, Background,5);
	AddCell(20,140,"Arial", Size,Foreground, Background,"A");
	AddCell(20,165,"Arial", Size,Foreground, Background,"B");
	AddCell(20,190,"Arial", Size,Foreground, Background,"C");
	AddCell(20,213,"Arial", Size,Foreground, Background,"1 or A");
	AddCell(20,270,"Arial", Size,Foreground, Background,"2 or B");
	AddCell(20,330,"Arial", Size,Foreground, Background,"3 or C");		
	----
    Foreground= core.rgb(200, 0, 0);
	Background= core.rgb(128, 128, 128); 
	Size= 6;
	AddCell(35,12,"Arial", Size,Foreground, Background,1);
	AddCell(35,36,"Arial", Size,Foreground, Background,2);
	AddCell(35,62,"Arial", Size,Foreground, Background,3);
	AddCell(35,90,"Arial", Size,Foreground, Background,4);
	AddCell(35,117,"Arial", Size,Foreground, Background,5);
	AddCell(35,140,"Arial", Size,Foreground, Background,"A");
	AddCell(35,165,"Arial", Size,Foreground, Background,"B");
	AddCell(35,190,"Arial", Size,Foreground, Background,"C");
	AddCell(35,213,"Arial", Size,Foreground, Background,"1 or A");
	AddCell(35,270,"Arial", Size,Foreground, Background,"2 or B");
	AddCell(35,330,"Arial", Size,Foreground, Background,"3 or C");		
 ---
    Foreground= core.rgb(0, 200, 250);
	Background= core.rgb(128, 128, 128); 
	Size= 6;
	AddCell(50,14,"Arial", Size,Foreground, Background,"i");
	AddCell(50,36,"Arial", Size,Foreground, Background,"ii");
	AddCell(50,62,"Arial", Size,Foreground, Background,"iii");
	AddCell(50,90,"Arial", Size,Foreground, Background,"iv");
	AddCell(50,117,"Arial", Size,Foreground, Background,"v");
	AddCell(50,140,"Arial", Size,Foreground, Background,"a");
	AddCell(50,165,"Arial", Size,Foreground, Background,"b");
	AddCell(50,190,"Arial", Size,Foreground, Background,"c");
	AddCell(50,217,"Arial", Size,Foreground, Background,"i or a");
	AddCell(50,272,"Arial", Size,Foreground, Background,"ii or b");
	AddCell(50,332,"Arial", Size,Foreground, Background,"iii or c");		
 ----
    Foreground= core.rgb(0, 128, 0);
	Background= core.rgb(128, 128, 128); 
	Size= 6;
	AddCell(65,14,"Arial", Size,Foreground, Background,"i");
	AddCell(65,36,"Arial", Size,Foreground, Background,"ii");
	AddCell(65,62,"Arial", Size,Foreground, Background,"iii");
	AddCell(65,90,"Arial", Size,Foreground, Background,"iv");
	AddCell(65,117,"Arial", Size,Foreground, Background,"v");
	AddCell(65,140,"Arial", Size,Foreground, Background,"a");
	AddCell(65,165,"Arial", Size,Foreground, Background,"b");
	AddCell(65,190,"Arial", Size,Foreground, Background,"c");
	AddCell(65,217,"Arial", Size,Foreground, Background,"i or a");
	AddCell(65,272,"Arial", Size,Foreground, Background,"ii or b");
	AddCell(65,332,"Arial", Size,Foreground, Background,"iii or c");		
 ---
    Foreground= core.rgb(200, 0, 0);
	Background= core.rgb(128, 128, 128); 
	Size= 6;
	AddCell(80,14,"Arial", Size,Foreground, Background,"i");
	AddCell(80,36,"Arial", Size,Foreground, Background,"ii");
	AddCell(80,62,"Arial", Size,Foreground, Background,"iii");
	AddCell(80,90,"Arial", Size,Foreground, Background,"iv");
	AddCell(80,117,"Arial", Size,Foreground, Background,"v");
	AddCell(80,140,"Arial", Size,Foreground, Background,"a");
	AddCell(80,165,"Arial", Size,Foreground, Background,"b");
	AddCell(80,190,"Arial", Size,Foreground, Background,"c");
	AddCell(80,217,"Arial", Size,Foreground, Background,"i or a");
	AddCell(80,272,"Arial", Size,Foreground, Background,"ii or b");
	AddCell(80,332,"Arial", Size,Foreground, Background,"iii or c");		
 ----
    Foreground= core.rgb(0, 200, 250);
	Background= core.rgb(128, 128, 128); 
	Size= 6;
	AddCell(95,10,"Arial", Size,Foreground, Background,"(i)");
	AddCell(95,30,"Arial", Size,Foreground, Background,"(ii)");
	AddCell(95,54,"Arial", Size,Foreground, Background,"(iii)");
	AddCell(95,82,"Arial", Size,Foreground, Background,"(iv)");
	AddCell(95,110,"Arial", Size,Foreground, Background,"(v)");
	AddCell(95,135,"Arial", Size,Foreground, Background,"(a)");
	AddCell(95,160,"Arial", Size,Foreground, Background,"(b)");
	AddCell(95,185,"Arial", Size,Foreground, Background,"(c)");
	AddCell(95,210,"Arial", Size,Foreground, Background,"(i or a)");
	AddCell(95,265,"Arial", Size,Foreground, Background,"(ii or b)");
	AddCell(95,325,"Arial", Size,Foreground, Background,"(iii or c)");		
 ---
 
  Foreground= core.rgb(0, 128, 0);
	Background= core.rgb(128, 128, 128); 
	Size= 6;
	AddCell(110,10,"Arial", Size,Foreground, Background,"(i)");
	AddCell(110,30,"Arial", Size,Foreground, Background,"(ii)");
	AddCell(110,54,"Arial", Size,Foreground, Background,"(iii)");
	AddCell(110,82,"Arial", Size,Foreground, Background,"(iv)");
	AddCell(110,110,"Arial", Size,Foreground, Background,"(v)");
	AddCell(110,135,"Arial", Size,Foreground, Background,"(a)");
	AddCell(110,160,"Arial", Size,Foreground, Background,"(b)");
	AddCell(110,185,"Arial", Size,Foreground, Background,"(c)");
	AddCell(110,210,"Arial", Size,Foreground, Background,"(i or a)");
	AddCell(110,265,"Arial", Size,Foreground, Background,"(ii or b)");
	AddCell(110,325,"Arial", Size,Foreground, Background,"(iii or c)");		
 ---
 
  Foreground= core.rgb(200, 0, 0);
	Background= core.rgb(128, 128, 128); 
	Size= 6;
	AddCell(125,10,"Arial", Size,Foreground, Background,"(i)");
	AddCell(125,30,"Arial", Size,Foreground, Background,"(ii)");
	AddCell(125,54,"Arial", Size,Foreground, Background,"(iii)");
	AddCell(125,82,"Arial", Size,Foreground, Background,"(iv)");
	AddCell(125,110,"Arial", Size,Foreground, Background,"(v)");
	AddCell(125,135,"Arial", Size,Foreground, Background,"(a)");
	AddCell(125,160,"Arial", Size,Foreground, Background,"(b)");
	AddCell(125,185,"Arial", Size,Foreground, Background,"(c)");
	AddCell(125,210,"Arial", Size,Foreground, Background,"(i or a)");
	AddCell(125,265,"Arial", Size,Foreground, Background,"(ii or b)");
	AddCell(125,325,"Arial", Size,Foreground, Background,"(iii or c)");		
 ---
    Foreground= core.rgb(0, 200, 250);
	Background= core.rgb(128, 128, 128); 
	Size= 6;
	AddCell(140,10,"Arial", Size,Foreground, Background,"efa");
	AddCell(140,60,"Arial", Size,Foreground, Background,"efb");
	AddCell(140,110,"Arial", Size,Foreground, Background,"efc");
	AddCell(140,160,"Arial", Size,Foreground, Background,"^a");
	AddCell(140,190,"Arial", Size,Foreground, Background,"^b");
	AddCell(140,220,"Arial", Size,Foreground, Background,"^c");
	AddCell(140,250,"Arial", Size,Foreground, Background,"^d");
	AddCell(140,280,"Arial", Size,Foreground, Background,"^e");

 
	
    instance:ownerDrawn(Flag);
	  
	if iLabel== nil then
	Decode(1);
	end  
  
	
	require("storagedb");
    db = storagedb.get_db(name);	
	
	
	core.host:execute("addCommand", 5, "Show/Hide");
    core.host:execute("addCommand", 1, "Select");
	core.host:execute("addCommand", 2, "Add");
	core.host:execute("addCommand", 3, "Remove");
    core.host:execute("addCommand", 4, "Reset");

end


 
--[[
function ReleaseInstance()
    core.host:execute("killTimer", timerID);
end]]

function AsyncOperationFinished(cookie, success, message)
    
    local t, c, x, y,y1,y2,x1,x2;
	local i,j;
	local Index,Cell;
	
	if cookie == 5
	then
       if Flag then
	   Flag= false;
	   else
	    Flag= true;
	   end
    end	
	
	
	if cookie == 1
	or cookie == 2
	or cookie == 3
	then
		
		 
		 t, c = core.parseCsv(message, ";");
		 x = tonumber(t[2]);
		 y = tonumber(t[3]);
	     
	end
	
	if cookie == 1  then 
	  
			for Index= 1, #Data , 1 do
			
			x1 =  Selector[Index][1]; 
			y1 =  Selector[Index][2];
			x2 =  Selector[Index][3];
			y2 =  Selector[Index][4];
					
					 if  x>= x1 
					 and x<= x2
					 and y<= y1 
					 and y>=y2
					 then
					 Decode(Index);
					 
					 end  			 
			 end 
			 
			  
			 
	elseif cookie == 2 then 
	
	
	
	Count= db:get ("Count", 0);
	Count=Count+1;
	db:put("Count" , Count);  
	
	Level, Date = string.match(message, pattern, pos);
	
	db:put("Level"..tostring(Count), tostring(Level));  
	db:put("Date"..tostring(Count), tostring(Date));  	
	db:put("Foreground"..tostring(Count), tostring(iForeground));  
	db:put("Background"..tostring(Count), tostring(iBackground));  
	db:put("Size"..tostring(Count), tostring(iSize));  
	db:put("Font"..tostring(Count), tostring(iFont));   
	db:put("Label"..tostring(Count), tostring(iLabel)); 
     
	
	
	 elseif cookie == 3 then
	
	  Count= db:get ("Count", 0);
	       for Index= 1, Count , 1 do
		   
			x1 =  Activ[Index][1]; 
			y1 =  Activ[Index][2];
			x2 =  Activ[Index][3];
			y2 =  Activ[Index][4];
			 
					
					 if  x>= x1 
					 and x<= x2
					 and y>= y1 
					 and y<=y2
					 and (x1~=0 or x2~=0 or y1~=0 or y2~=0)
					 then
					 db:put("Level"..tostring(Index), tostring(0));
					
					 end  			 
		   end	
		  
    elseif cookie == 4 then
    db:put("Count", 0);  
	end

end	
	
function Decode(Index) 
	  
	local Cell= Data[Index];			
	 iFont=Cell.font
	 iSize=Cell.size 
	 iLabel=Cell.label	 
	 iForeground=Cell.foreground
	 iBackground=Cell.background
	 
	 
end
 
function Draw(stage, context)
    if stage ~= 2  
	then
        return ;
    end

    
   if not init then 
		Transparency=context:convertTransparency (instance.parameters.Transparency); 
       init= true; 
	end
	
	First=math.max(first,context:firstBar ());
	Last=math.min(source:size()-1, context:lastBar ());
	
	local Style=context.CENTER+context.VCENTER+context.SINGLELINE;
	
		 local Size,Foreground,Background, Font, Label;
		 
	if Flag then
	
		
		for Index= 1, #Data , 1 do
				Selector[Index]={0,0,0,0} 
				Cell= Data[Index];	
				
				Foreground=Cell.foreground
				 Background=Cell.background 
				Label =   Cell.label; 
				Size =   Cell.size;
				Font =   Cell.font;
				
				CellSize = context:pointsToPixels(Size);
				cellSize = math.floor( CellSize  * 1.5  ); 
				
				
				context:createPen(1, context.SOLID, 1, Background);
				context:createSolidBrush (2, Background);
				context:createFont(3, Font, CellSize, CellSize, context.NORMAL); 
				width, height = context:measureText (3, Label, 0)
				
				
				i= Cell.y;
				j= Cell.x;
				y1 = context:bottom ()  - i;
				y2 = y1 - height;		
				x1 = context:left () + j ;
				x2 = x1 +  width 
				
						Selector[Index][1]=x1;
						Selector[Index][2]=y1;
						Selector[Index][3]=x2;                            
						Selector[Index][4]=y2;	
				
					 context:drawRectangle ( 1, 2, x1, y1, x2, y2, Transparency);
					context:drawText (3,Label, Foreground, -1, x1, y1, x2, y2, Style)
					end
		
	
	end
	  
	  
	  
	  xCount=  tonumber(db:get ("Count", 0));

	 
	if xCount== 0 then
	return;
	end
	
	for i=1, xCount, 1 do
	       Activ[i]={0,0,0,0} 
	        	
			 
	        xLevel=  tonumber(db:get("Level"..tostring(i), 0));  
			visible, y =context:pointOfPrice (xLevel)
	        if xLevel ~= 0 and visible then
			xDate= tonumber(db:get("Date"..tostring(i), 0));  
			        if xDate~=0 then
					 p= core.findDate (source, xDate, false)    
							if p~= -1 and p >= First and p <= Last then
							x, x1 , x1 =  context:positionOfBar (p);
							 
							xBackground= tonumber(db:get("Background"..tostring(i), 0));  
							xForeground= tonumber(db:get("Foreground"..tostring(i), 0));  
							xSize= tonumber(db:get("Size"..tostring(i), 0));  
							xFont= (db:get("Font"..tostring(i), 0));  
							xLabel=(db:get("Label"..tostring(i), 0));  
							xCell = context:pointsToPixels(xSize);
				            xcell = math.floor( xCell  * 1.5  ); 
				
							 
                           
							context:createPen(1, context.SOLID, 1,  xBackground);
							context:createSolidBrush (2,  xBackground);
							context:createFont(3, xFont,   context:pointsToPixels( xSize),   context:pointsToPixels( xSize), context.NORMAL); 			 
							

                            width, height = context:measureText (3, xLabel, 0)
							
							x1= x-width/2
							y1=y-math.floor(  height  * 1.5  )/2;
							x2= x+width/2
							y2=y+math.floor(  height  * 1.5  )/2;
							 context:drawRectangle (1,2, x1, y1,  x2,  y2, Transparency);		
							context:drawText (3, xLabel, xForeground, -1,x1, y1,  x2,  y2, Style); 
                             
                            Activ[i][1]=x1;
							Activ[i][2]=y1;
			                Activ[i][3]=x2;                            
			                Activ[i][4]=y2;							
							end
					end
			end
			
    end
end	


function Update(period)
   
end

