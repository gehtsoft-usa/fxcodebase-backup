-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=8109

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
    indicator:name("Percentage Price Position");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addInteger("Height", "Height as % of Chart", "", 100 , 50, 100);
    indicator.parameters:addInteger("Size", "Font Size as % of Cell Size", "", 100, 50, 150);
	indicator.parameters:addInteger("Spacing", "Spacing", "", 25, 0, 25); 
	indicator.parameters:addInteger("transparency", "Transparency", "",50, 0, 100); 
	 
	indicator.parameters:addString("Orientation", "Orientation", "", "Vertical");    
    indicator.parameters:addStringAlternative("Orientation", "Horizontal", "", "Horizontal");
    indicator.parameters:addStringAlternative("Orientation", "Vertical", "", "Vertical");
	
 
    indicator.parameters:addBoolean("ShowLabel", "Show Label", "", true);
	indicator.parameters:addBoolean("ShowNeutral", "Show Neutral", "", true);
    indicator.parameters:addColor("Up", "Indicator Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Indicator Down Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral", "Neutral color", "", core.rgb(0, 0, 0));		
    indicator.parameters:addColor("Label", "Label color", "", core.COLOR_LABEL);
   

end
local Spacing;
local Height; 
local fisrt, source;
local Up,Down, Neutral,Label;
local Placement;
local Size;
local Number=5;
local  ShowLabel; 
local Orientation;
local Transparency;
 
local ShowNeutral;
function Prepare()  
    Placement= instance.parameters.Placement; 
    ShowLabel= instance.parameters.ShowLabel;
	ShowNeutral= instance.parameters.ShowNeutral;
	Orientation= instance.parameters.Orientation;
	Spacing= instance.parameters.Spacing;
    Size= instance.parameters.Size; 
    Height= instance.parameters.Height;
    Up= instance.parameters.Up;
	Down= instance.parameters.Down;
    Neutral= instance.parameters.Neutral;
    Label= instance.parameters.Label 
    source = instance.source;
    first= source:first();  
	 
    local name =  profile:id()  ; 
    instance:name(name);	
	
	 instance:ownerDrawn(true);

end


function Update(period, mode)
			
      
end





--DRAW( period, source.high[period] , source.low[period] , source.close[period], HEIGHT, 50 , 50, Placement );

local init = false;
 
function Draw(stage, context)

 
if stage~= 2 then
return;
end

    Transparency = context:convertTransparency (instance.parameters.transparency);

    if Orientation == "Horizontal" then
	xSize= context:right ()-context:left ();
	ySize=( context:bottom ()-context:top ())/Number;		
	context:createFont (1, "Arial", ySize*(Spacing/100)/3 , ySize*(Spacing/100)/3, 0);
	elseif Orientation == "Vertical" then
	ySize= context:bottom ()-context:top ();
	xSize= (context:right ()-context:left ())/Number;   
    context:createFont (1, "Arial", xSize*(Spacing/100)/3, xSize*(Spacing/100)/3, 0);	
    end		 
    
   --Maximum=5;
   
   Add(context, 5,xSize,ySize);


end	

 function Add(context,id,xSize,ySize)
 
     
	 
	 local Maximum=(source.high[source:size()-1]-source.low[source:size()-1]);
     local Value=(source.close[source:size()-1]-source.low[source:size()-1])/(Maximum/100);
	 
     if Orientation == "Horizontal" then

	color1= Down;
	color2= Up;
	color3= Up;
	color4= Down;
	x1 =context:left ();
	x2=context:left ()+xSize*(Height/100);
	x3=context:left ()+xSize*(Height/100);
	x4=context:left ();
	
	y1 =context:bottom ()-ySize*(Height/100)*(id-1)-ySize*(Spacing/100);
	y2=context:bottom ()-ySize*(Height/100)*(id-1) -ySize*(Spacing/100);
	y3=context:bottom ()-ySize*(Height/100)*(id)+ySize*(Spacing/100);
	y4=context:bottom ()-ySize*(Height/100)*(id)+ySize*(Spacing/100);
	
	
 
	
	if ShowNeutral then 
	context:drawGradientRectangle (x1, y1, Neutral, x2, y2, Neutral, x3, y3, Neutral, x4, y4, Neutral,Transparency);
	end
 
	
	x2=context:left ()+(xSize/100)*Value;
	x3=context:left ()+(xSize/100)*Value;
	
	context:drawGradientRectangle (x1, y1, color1, x2, y2, color2, x3, y3, color3, x4, y4, color4,Transparency);
	
    if ShowLabel then	
	--Value=(Value/Maximum)*100;
	Value = win32.formatNumber(Value, false, 2);
	width, height = context:measureText (1, Value, 0);
	context:drawText (1, Value, Label, -1, x3-width, y3, x3, y3+height,0);
	Value=id;
	width, height = context:measureText (1, Value, 0);
	context:drawText (1, Value, Label, -1, context:right ()-width, y3-height, context:right (), y3,0);
	end
	
	elseif Orientation == "Vertical" then
	
	color1= Up;
	color2= Up;
	color3= Down;
	color4= Down;  
    y1=context:bottom ()-ySize*(Height/100); 
	y2=context:bottom ()-ySize*(Height/100); 
	y3=context:bottom ();
	y4=context:bottom ();	
	
	x1 =context:left ()+xSize*(Height/100)*(id) - xSize*(Spacing/100) ;
	x2=context:left ()+xSize*(Height/100)*(id-1) + xSize*(Spacing/100) ;
	x3=context:left ()+xSize*(Height/100)*(id-1) + xSize*(Spacing/100);
	x4=context:left ()+xSize*(Height/100)*(id) - xSize*(Spacing/100);
	
	if ShowNeutral then 
	context:drawGradientRectangle (x1, y1, Neutral, x2, y2, Neutral, x3, y3, Neutral, x4, y4, Neutral,Transparency);
	end
	
	y1=context:bottom ()-(ySize/100)*Value; 
	y2=context:bottom ()-(ySize/100)*Value; 
	
	
	context:drawGradientRectangle (x1, y1, color1, x2, y2, color2, x3, y3, color3, x4, y4, color4,Transparency);

	
	if ShowLabel then
	--Value=(Value/Maximum)*100;
	Value = win32.formatNumber(Value, false, 2);
	width, height = context:measureText (1, Value, 0);
	context:drawText (1, Value, Label, -1, x2, y1, x2+width, y1+height,0);
	Value=id;
	width, height = context:measureText (1, Value, 0);
	context:drawText (1, Value, Label, -1, x4, context:top (), x4+width, context:top () +height,0);
	end
	
    end		
 
	 
 end
 
 