-- Id: 13852
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62032

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
    indicator:name("Wind Rose");
    indicator:description("Wind Rose");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("TF"  , "Time Frame ", "", "D1");
    indicator.parameters:setFlag("TF"  , core.FLAG_PERIODS);
	
	
	indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Y", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Right");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 
	
	
	indicator.parameters:addGroup("Style");
	 Add(1,   "EUR/USD"); 
    Add(2,   "USD/JPY"); 
    Add(3,  "GBP/USD"); 
    Add(4,  "USD/CHF"); 
    Add(5,  "EUR/CHF"); 
    Add(6,  "AUD/USD"); 
    Add(7,  "USD/CAD"); 
    Add(8,   "NZD/USD" ); 
    Add(9, "NZD/USD" ); 
    Add(10,   "EUR/JPY"); 
	 
	 
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Label Color", "Color of Label", core.rgb(0, 0, 0));
	indicator.parameters:addColor("RoseColor", "Rose Color", "Color of Rose", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("RoseSize", "Rose Size", "Rose Size",300);
	indicator.parameters:addInteger("FontSize", "Font Size", "Rose Size",10);
	indicator.parameters:addInteger("Transparency", "Transparency", "Transparency",50);
end

function Add(id, Instrument)

    
    indicator.parameters:addGroup(id .. ". Slot");	
	indicator.parameters:addBoolean("On"..id, "Use This Slot", "", true);	
	
	indicator.parameters:addString("Instrument" .. id, "Instrument", "", Instrument);
    indicator.parameters:setFlag("Instrument" .. id, core.FLAG_INSTRUMENTS);
 

  
end 
 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local RoseSize;
local first;
local source = nil; 
local Color = nil;
local Number;
local Instrument={};
local Source={};
local loading={};
local TF; 
local X, Y;
local Transparency;
local FontSize;
local RoseColor;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	Color=instance.parameters.Color;
	RoseColor=instance.parameters.RoseColor;
	RoseSize=instance.parameters.RoseSize;
	FontSize=instance.parameters.FontSize;
	TF=instance.parameters.TF;
	X=instance.parameters.X;
	Y=instance.parameters.Y;

    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	Number=0;
	
	for i= 1 , 10 , 1 do
	 if  instance.parameters:getBoolean("On" .. i)    then
	 Number=Number+1;
	 Instrument[Number]=  instance.parameters:getString("Instrument" .. i);	 
     Source[Number]  = core.host:execute("getSyncHistory",  Instrument[Number],  TF, source:isBid(), 0 , 2000 + Number , 1000 +Number);	 	 
	 loading[Number]  = true;  	 
	 
	 end
	 
	end
	
	instance:ownerDrawn(true);
    
end



local init = false;

function Draw (stage, context)

    if stage  ~= 2 then
	return;
	end
	 
	 
	local FLAG=false; 

    for j = 1, Number, 1 do
		     
                 if loading[j] then
				 FLAG= true; 
				 end
				 
	end    
    
	
	if FLAG then
	return;	 
	end
 
	 
  
      context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
    if not init then
	init =true;
	context:createFont (1, "Arial", context:pointsToPixels (FontSize), context:pointsToPixels (FontSize), 0);
	Transparency=context:convertTransparency (instance.parameters.Transparency);
	context:createPen (3, context.SOLID, 1, RoseColor)       
	context:createSolidBrush(4, RoseColor);
	end
	
	
	local xCenter= iX(context,  0 );
	local yCenter= iY(context,  0 );
	
	 
    width, height = context:measureText (1, "X", 0); 
	context:drawText (1, "X", Color, -1, xCenter-width/2, yCenter-height/2, xCenter+width/2, yCenter+height/2, 0);
    local Max=0;
	for i= 1, Number,1 do
		if Max<  math.abs(Source[i].close[Source[i].close:size()-1]-Source[i].open[Source[i].open:size()-1] ) / ( Source[i].open[Source[i].open:size()-1] /100) then
		Max =  math.abs(Source[i].close[Source[i].close:size()-1]-Source[i].open[Source[i].open:size()-1] ) / ( Source[i].open[Source[i].open:size()-1] /100) ;
		end
	end	
	local points= ownerdraw_points.new ()
	local Percentage;
	
    for i= 1, Number,1 do
	Label= tostring(i)..". " .. Instrument[i];
	
	if X== "Left" then
	width, height = context:measureText (1, Label , 0); 
	context:drawText (1,Label, Color, -1, xCenter+RoseSize-width/2, yCenter-RoseSize/2+(i-1)*height, xCenter+RoseSize+width/2, yCenter -RoseSize/2+(i)*height, 0);
	else
	width, height = context:measureText (1, Label , 0); 
	context:drawText (1,Label, Color, -1, xCenter-RoseSize-width/2, yCenter-RoseSize/2+(i-1)*height, xCenter-RoseSize+width/2, yCenter -RoseSize/2+(i)*height, 0);
	end
	
	Azimuth=math.rad( (360/Number)*(i-1));
	Percentage=math.abs( Source[i].close[Source[i].close:size()-1]-Source[i].open[Source[i].open:size()-1] ) / ( Source[i].open[Source[i].open:size()-1] /100);
	p=(RoseSize) *(Percentage/Max);
	x, y = math2d.polarToCartesian (p , Azimuth);
	
	width, height = context:measureText (1, tostring(i), 0); 
	--width, height = context:measureText (1,  win32.formatNumber((Percentage/Max), false, 2) , 0);
	x1=xCenter-width/2 +x;
	x2= xCenter+width/2+x;
	y1=yCenter-height/2+y;
	y2= yCenter+height/2+y;
		
	
 
	points:add (xCenter  +x , yCenter +y ); 
	
	context:drawText (1, tostring(i), Color, -1, x1, y1,x2,y2, 0);	
   --  context:drawText (1, win32.formatNumber((Percentage/Max), false, 2), Color, -1, x1, y1,x2,y2, 0);	
	end	   
	
	
	context:drawPolygon (3, 4, points, Transparency)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    
end


function AsyncOperationFinished(cookie)

local j;
local FLAG=false; 
local Num=0; 
    for j = 1, Number, 1 do
		   
			  if cookie == (1000 + j) then
			  loading[j]  = true;
		      elseif  cookie == (2000 + j ) then
			  loading[j]  = false;     
			  end
		 
		       
                 if loading[j] then
				 FLAG= true;
				 Num=Num+1;
				 end
	end    
   
           
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Number) - Num) .. " / " .. (Number) );	 
	else
	core.host:execute ("setStatus", "Loaded");
	instance:updateFrom(0);
	end
   
        
    return core.ASYNC_REDRAW ;
	
end


function iX(context,  Shift  )

	if X== "Left" then
	return  context:left()+ Shift*RoseSize +context:pointsToPixels (FontSize)*10;  
	else
	return context:right() - Shift*RoseSize-context:pointsToPixels (FontSize)*10;   
	end
end



function iY(context ,Shift)

   
	if Y== "Top" then
	return context:top()+(Shift+1)*RoseSize; 
	else
	return context:bottom()-(Shift+1)*RoseSize; 
	end
end
