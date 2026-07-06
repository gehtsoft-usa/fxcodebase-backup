
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
    indicator:name("Elliott Wave Labelling Tool");
    indicator:description("Elliott Wave Labelling Tool");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	

    indicator.parameters:addInteger("CellSize", "Cell Size", "Cell Size",10);
	indicator.parameters:addInteger("Transparency", "Cell Transparency", "Cell Transparency",50);
    indicator.parameters:addColor("CellColor", "Cell Color", "Cell Color", core.rgb(128, 128, 128));
	indicator.parameters:addColor("LabelColor", "Label Color", "Label Color", core.rgb(0, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 


local first;
local source = nil;
local LabelColor,CellColor;
-- Streams block
local Data = {};
local init = false;
local Transparency;
local Font={}; 
Font[1]={"1","2","3","4","5","A","B","C"}
Font[2]={"I","II","III","IV","V","a","b","b"}
--Font[3]={"((1))","((2))","((3))","((4))","((5))","((A))","((B))","((C))"}

local Size={5,10,15,20,25};
local Color= {core.rgb(128, 128, 128),core.rgb(255, 0, 0), core.rgb(0, 255, 0), core.rgb(0, 0, 255), core.rgb(0, 0, 0) }
local  iColor=1;
local  iFont=1; 
local iSize=3;
local iFinal=1;
local iCell;
local cellSize,CellSize;
local db; 
local pattern = "([^;]*);([^;]*)";
 

--local timerID;
function AddCell(id, y, x,type, value)
 
    local Cell = {};
    Cell.x = x;    
	Cell.y = y;	
	Cell.value = value;
	Cell.type = type;	
    Data[id] = Cell;

end
local Activ={}; 
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
	
	AddCell(1,1,1,"Size",1);
	AddCell(2,1,2,"Size",2);
	AddCell(3,1,3,"Size",3);
	AddCell(4,1,4,"Size",4);
	AddCell(5,1,5,"Size",5);
	
	
	AddCell(6,2,1,"Color",1);
	AddCell(7,2,2,"Color",2);
	AddCell(8,2,3,"Color",3);
	AddCell(9,2,4,"Color",4);
	AddCell(10,2,5,"Color",5);
 
 
    AddCell(11,3,1,"Font", 1);
	AddCell(12,3,2,"Font", 2); 
	--AddCell(13,3,3,"Font", 3);
	
	
	AddCell(13,4,1,"Final",1);
	AddCell(14,4,2,"Final",2);
	AddCell(15,4,3,"Final",3);
	AddCell(16,4,4,"Final",4);
	AddCell(17,4,5,"Final",5);
    AddCell(18,4,6,"Final",6);
	AddCell(19,4,7,"Final",7);
	AddCell(20,4,8,"Final",8);
	
    instance:ownerDrawn(true);
	  
	  
 
	
	require("storagedb");
    db = storagedb.get_db(name);	
	
    core.host:execute("addCommand", 1, "Select");
	core.host:execute("addCommand", 2, "Add");
	 core.host:execute("addCommand", 3, "Remove");
    core.host:execute("addCommand", 4, "Reset");
	
	-- timerID = core.host:execute("setTimer", 6, 1);
end


 
--[[
function ReleaseInstance()
    core.host:execute("killTimer", timerID);
end]]

function AsyncOperationFinished(cookie, success, message)
    
    local t, c, x, y,y1,y2,x1,x2;
	local i,j;
	local Index,Cell;
	
	
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
			Cell= Data[Index];	
			  
			y1 = Cell.y1;
			y2 = Cell.y2;
			
			x1 = Cell.x1;
			x2 = Cell.x2;
					
					 if  x>= x1 
					 and x<= x2
					 and y<= y1 
					 and y>=y2
					 then
					 Decode(Index);
					 --core.host:execute ("setStatus", tostring(x).. ", " ..tostring(y).. ", " ..tostring(x1).. ", " ..tostring(y1).. ", " ..tostring(x2).. ", " ..tostring(y2));
					 end  			 
			 end 
			 
			  
			 
	elseif cookie == 2 then 
	
	Count= db:get ("Count", 0);
	Count=Count+1;
	db:put("Count" , Count);  
	Level, Date = string.match(message, pattern, pos);
	
	db:put("Level"..tostring(Count), tostring(Level));  
	db:put("Date"..tostring(Count), tostring(Date));  	
	db:put("Color"..tostring(Count), tostring(iColor));  
	db:put("Size"..tostring(Count), tostring(iSize));  
	db:put("Font"..tostring(Count), tostring(iFont));  
	db:put("Final"..tostring(Count), tostring(iFinal));  
	db:put("Cell"..tostring(Count), tostring(iCell)); 
    -- core.host:execute ("setStatus", tostring(Level).. ", " ..tostring(Date).. ", " ..tostring(iCell));
	 elseif cookie == 3 then
	 --  local Txt= tostring(x).. ", " ..tostring(y);
	  Count= db:get ("Count", 0);
	       for Index= 1, Count , 1 do
		   
			x1 =  Activ[Index][1]; 
			y1 =  Activ[Index][2];
			x2 =  Activ[Index][3];
			y2 =  Activ[Index][4];
			--Txt= Txt .. ", " .. x1 .. ", " .. y1.. ", " .. x2 .. ", " .. y2
					
					 if  x>= x1 
					 and x<= x2
					 and y>= y1 
					 and y<=y2
					 and (x1~=0 or x2~=0 or y1~=0 or y2~=0)
					 then
					 db:put("Level"..tostring(Index), tostring(0));
					
					 end  			 
		   end	
		   -- core.host:execute ("setStatus", Txt);
    elseif cookie == 4 then
    db:put("Count", 0);  
	end

end	
	
function Decode(Index) 
	  
	local Cell= Data[Index];	
	local value=Cell.value;
	local type= Cell.type;	
		
	if type=="Size" then
	iSize=value;
	elseif type=="Color" then
	iColor=value;
	elseif type=="Font" then
	iFont=value;
	elseif type=="Final" then
	iFinal=value;
	end
end
 
function Draw(stage, context)
    if stage ~= 2 then
        return ;
    end

    -- initialize GDI objects
    if not init then
	
	    CellSize = context:pointsToPixels(instance.parameters.CellSize);
        cellSize = math.floor( CellSize  * 1.5 + 0.5)*2;       
        context:createPen(1, context.SOLID, 1, CellColor);
		context:createSolidBrush (2, CellColor);
		 context:createFont(3, "Arial", CellSize, CellSize, context.NORMAL); 
		  
		Transparency=context:convertTransparency (instance.parameters.Transparency);
		
		
        init= true; 
	end
	
	First=math.max(first,context:firstBar ());
	Last=math.min(source:size()-1, context:lastBar ());
	
	
	--core.host:execute ("setStatus", tostring(iSize).. ", " ..tostring(iColor).. ", ".. tostring(iFont).. ", ".. tostring(iFinal));
	
	local Index;
	local Cell;
	local Value;
    local Type;
    local Style=context.CENTER+context.VCENTER+context.SINGLELINE;
	for Index= 1, #Data , 1 do
	Cell= Data[Index];	
	i= Cell.y;
	j= Cell.x;
	Type=   Cell.type;
	Value =   Cell.value;
	 
	
	    y1 = context:bottom ()  - (i-1) * cellSize-(i-1)*( cellSize/4);
        y2 = y1 - cellSize;		
		x1 = context:left () + cellSize + (j-1) * cellSize +(j-1)*( cellSize/4);
        x2 = x1 + cellSize 
		
		
		 
		
		if Type=="Size" then  
			context:drawEllipse ( 1, 2, x1, y1, x2, y2, Transparency);
		    context:drawText (3,Size[Value], LabelColor, -1, x1, y1, x2, y2, Style)
		    
		
        elseif Type=="Color" then 
		
		     context:createPen(4, context.SOLID, 1, Color[Value]);
		      context:createSolidBrush (5, Color[Value]);
		     --context:drawRectangle (4, 5, x1, y1, x2, y2, Transparency);
			 context:drawEllipse (4,5, x1, y1, x2, y2, Transparency);
		
		elseif Type=="Font" then 
		    
			-- context:drawRectangle (1, 2, x1, y1, x2, y2, Transparency);			
             context:drawEllipse (1,2, x1, y1, x2, y2, Transparency);				
			 context:drawText (3, Font[Value][1], LabelColor, -1, x1, y1, x2, y2, Style);
			 
		elseif Type=="Final" then 
		
		    TempCell= Data[12];	
			ti= TempCell.y;
			ti= context:bottom ()  - (ti+1) * cellSize;
			
			tj= TempCell.x;
			tj = context:left ()  +  (tj-1) * cellSize ;
             
			 cs= math.floor( context:pointsToPixels(Size[iSize])  * 1.5 + 0.5);
			 y1 = ti ;
			 x1 = tj + (j-1) * cs +(j-1)*( cs/4);
		     y2 = y1 - cs;	
			 x2 = x1 +  cs;
		     iCell=cs;
		
			context:createPen(11, context.SOLID, 1, Color[iColor]);
		    context:createSolidBrush (12, Color[iColor]);
			 context:createFont(13, "Arial",   context:pointsToPixels(Size[iSize]),   context:pointsToPixels(Size[iSize]), context.NORMAL); 			
			
            --context:drawRectangle (11, 12, x1, y1, x2, y2, Transparency);		
            context:drawEllipse (11,12, x1, y1,  x2,  y2, Transparency);		
			context:drawText (13, Font[iFont][Value], LabelColor, -1, x1, y1, x2, y2, Style);
		end
		
		
		 Cell.x1=x1;
		 Cell.x2=x2
		 Cell.y1=y1;
		 Cell.y2=y2
	 
		-- core.host:execute ("setStatus",tostring(x1).. ", " ..tostring(y1).. ", " ..tostring(x2).. ", " ..tostring(y2));
		 Data[Index] = Cell;
		
		
		
		
		 
	end
	
	 
	xCount=  tonumber(db:get ("Count", 0));
	 --core.host:execute ("setStatus", tostring( xCount));
	 
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
							 
							xColor= tonumber(db:get("Color"..tostring(i), 0));  
							xSize= tonumber(db:get("Size"..tostring(i), 0));  
							xFont= tonumber(db:get("Font"..tostring(i), 0));  
							xFinal= tonumber(db:get("Final"..tostring(i), 0)); 
							xCell= tonumber(db:get("Cell"..tostring(i), 0)); 

							context:createPen(51, context.SOLID, 1, Color[xColor]);
							context:createSolidBrush (52, Color[xColor]);
							context:createFont(53, "Arial",   context:pointsToPixels(Size[xSize]),   context:pointsToPixels(Size[xSize]), context.NORMAL); 			 
							 context:drawEllipse (51,52, x-math.floor( xCell  * 1.5 + 0.5)/2, y-math.floor( xCell  * 1.5 + 0.5)/2,  x+math.floor( xCell  * 1.5 + 0.5)/2,  y+math.floor( xCell  * 1.5 + 0.5)/2, Transparency);		
							context:drawText (53, Font[xFont][xFinal], LabelColor, -1, x-xCell/2, y-xCell/2, x+xCell/2, y+xCell/2, Style); 

                            Activ[i][1]=x-math.floor( xCell  * 1.5 + 0.5)/2;
							Activ[i][2]=y-math.floor( xCell  * 1.5 + 0.5)/2;
			                Activ[i][3]=x+math.floor( xCell  * 1.5 + 0.5)/2;                            
			                Activ[i][4]=y+math.floor( xCell  * 1.5 + 0.5)/2;							
							end
					end
			end
			
			 
	end
	 
	
end

	


function Update(period)
   
end

