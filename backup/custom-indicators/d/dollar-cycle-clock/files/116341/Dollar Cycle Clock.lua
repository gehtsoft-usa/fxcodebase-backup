-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65429

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

function Init()

    indicator:name("Dollar Cycle Clock");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation")
	indicator.parameters:addInteger("Period", "Period","", 12);
	
	indicator.parameters:addString("Method", "Presentation Method", "Method" , "Month");
    indicator.parameters:addStringAlternative("Method", "Index", "Method" , "Index");
    indicator.parameters:addStringAlternative("Method", "Month", "Method" , "Month");
	
	indicator.parameters:addGroup("Style");	 
	indicator.parameters:addColor("Color", "Label Color", "", core.rgb(0, 0, 0));
    indicator.parameters:addColor("Line", "Line Color", "", core.rgb(128,128, 128));
	indicator.parameters:addColor("BACKGROUND", "Background Color","",  core.COLOR_BACKGROUND);
 

 
 
	indicator.parameters:addInteger("Size", "Font Size ", "", 10);
 
	
end

 
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local first;
local source = nil;
local Line;

local Color;
local BACKGROUND;
local Source={};
local loading={};  
local Pair={"EUR/USD", "USD/JPY"};
local  Count=2;   
local Period;
local X={};
local Y={};
local Size;
local Method;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
    source = instance.source;
    first = source:first();	
	
    Color= instance.parameters.Color; 
	BACKGROUND= instance.parameters.BACKGROUND;
    Period= instance.parameters.Period;
	Size= instance.parameters.Size;
	Line= instance.parameters.Line;
	Method= instance.parameters.Method;
 
 
	Id=0;
	local Test;
	
	for j = 1, Count, 1 do 
	      
		 	   Id=Id+1;			
			   Source [j] = core.host:execute("getSyncHistory", Pair[j], "M1", source:isBid(),Period*2 , 2000 +  Id , 1000 + Id);
			   loading[j]  = true;  
			   
	end
    
	instance:setLabelColor(Color);
    instance:ownerDrawn(true);    
	
 
	 
end
 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)    

 
 
end


function AsyncOperationFinished(cookie)

	
	local i,j;
    local Id=0;
    for j = 1, Count, 1 do
 
		      Id=Id+1;
			  if cookie == (1000 + Id) then
			  loading[j]  = true;
		      elseif  cookie == (2000 + Id) then
			  loading[j]  = false;               
			  end 
 
	end    
	
	  
    local FLAG=false; 
	local Number=0;
	
	for j = 1, Count, 1 do
		  

                 if loading[j]  then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
        
    end
	
 
	
	if FLAG then	
	 core.host:execute ("setStatus", "  Loading "..((Count ) - Number) .. " / " .. (Count  ) );	
    else
	
	 core.host:execute ("setStatus", "")	
    instance:updateFrom(0);	
	end
   
        
    return core.ASYNC_REDRAW ;
end



local initDraw = false;

 function Draw(stage, context)
 
 
 
   context:createPen(1, context.SOLID, 1,  BACKGROUND); 
   context:createSolidBrush (2, BACKGROUND )
   
    context:drawRectangle (1, 2,  context:left(), context:top(), context:right(),  context:bottom(), 0);
	
    if stage ~= 2 then
        return ;
    end

	local FLAG=false; 
	local Number=0;
	
	for j = 1, Count, 1 do
		  

                 if loading[j]  then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
       
    end
	
	
	if FLAG then
	return;
	end 
	
	 core.host:execute ("setStatus", " Loaded ");


     
    if not init then 
		  context:createPen(2, context.SOLID, 1, Color); 
		  context:createFont (3, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
		  context:createPen(4, context.SOLID, 1, Line); 
		  
		  init = true;
    end
		
	    
    
    top, bottom = context:top(), context:bottom();
    left, right = context:left(), context:right(); 
   
 
     V_Center=top+(bottom-top)/2;
     H_Center=left+(right-left)/2;	 
  
  
   context:drawLine (2, H_Center, top, H_Center, bottom);
   context:drawLine (2, left, V_Center, right, V_Center);
   
   
  --"EUR/USD", "USD/JPY";
   
   for i=1, Period, 1 do  
   
   X[i]=-(Source[1].close[Source[1]:size()-1 - i+1 ]- Source[1].open[Source[1]:size()-1 - i+1 ])/(Source[1].open[Source[1]:size()-1 - i+1 ]/100);
   Y[i]=(Source[2].close[Source[2]:size()-1 - i+1 ]- Source[2].open[Source[2]:size()-1 - i +1])/(Source[2].open[Source[2]:size()-1 - i +1]/100);
   end
   
    local Max=0;
	
   for i=1, Period, 1 do
  
   if X[i] > Max then
   Max= X[i];
   end
   
    if Y[i] > Max then
   Max= Y[i];
   end
   
   end
   
   Delta=math.min((bottom-top)/2,(right-left)/2 )*0.5;
   
   X_Shift={};
   Y_Shift={};
   
    for i= 1, Period, 1 do
   X_Shift[i]= H_Center+ (X[i]/Max)*Delta ;
   Y_Shift[i]= V_Center+ (Y[i]/Max)*Delta ;
   end
   
    width, height = context:measureText (3, "EUR", 0);
   context:drawText (3, "EUR", Color, -1,H_Center, top, H_Center+width, top+height, 0);
   
    width, height = context:measureText (3, "JPY", 0);
	context:drawText (3, "JPY", Color, -1,  right-width,  V_Center-height, right, V_Center, 0);
 
   for i= 1, Period, 1 do
   
   if Method== "Index" then
   Text=i;
   else
   Table= core.dateToTable (Source[1]:date(Source[1]:size()-1 - i+1));
   
   
   Temp=tostring(Table.year);
   Text=Temp:sub( 3 ) ..  "/" .. Table.month ;
   end
   width, height = context:measureText (3,  Text, 0);
   context:drawText (3,  Text, Color, -1, X_Shift[i]-width/2, Y_Shift[i]-height/2, X_Shift[i]+width/2, Y_Shift[i]+height/2, 0);
   
   if i> 1 then
   context:drawLine (4, X_Shift[i-1], Y_Shift[i-1], X_Shift[i], Y_Shift[i]);
   end
   
   
   
   end
   
	
end
 
 