
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=68297

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("Multiple Horizontal Lines Helper Tool");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
 

   Add(1, true, core.rgb(0, 0, 255),3,core.LINE_SOLID);
   Add(2, true, core.rgb(0, 255, 0),3,core.LINE_SOLID);
   Add(3, true, core.rgb(255, 0, 0),3,core.LINE_SOLID);
   Add(4, false, core.rgb(0, 0, 255),3,core.LINE_DASH);
   Add(5, false, core.rgb(0, 255, 0),3,core.LINE_DASH);
   Add(6, false, core.rgb(255, 0, 0),3,core.LINE_DASH);
   Add(7, false, core.rgb(0, 0, 255),3,core.LINE_DOT);
   Add(8, false, core.rgb(0, 255, 0),3,core.LINE_DOT);
   Add(9, false, core.rgb(255, 0, 0),3,core.LINE_DOT);
   Add(10, false, core.rgb(0, 255, 0),3,core.LINE_DASHDOT);
   
  indicator.parameters:addGroup( "Label Style");  
  indicator.parameters:addInteger("Size" , "Font Size", "", 10); 
  indicator.parameters:addColor("LabelColor"  , "Labe Color", "", core.COLOR_LABEL ); 
   
end

function Add(id, On, Color, Width, Style)

indicator.parameters:addGroup(id ..". Line");
indicator.parameters:addBoolean("on"..id , "Show  This Line", "", On);
indicator.parameters:addBoolean("Onward"..id , "Onward Only", "", false);
indicator.parameters:addDouble("Price"..id , "Line Price Level", "", 0);


indicator.parameters:addString("Label"..id , id.. ". Line Label", "",  id.. ". Line");

indicator.parameters:addColor("color"..id , "Line Color", "", Color);
indicator.parameters:addInteger("width"..id , "Line Width", "", Width, 1, 5);
indicator.parameters:addInteger("style"..id , "Line Style", "", Style);
indicator.parameters:setFlag("style"..id , core.FLAG_LINE_STYLE);
 
end
 
local color={};
local style={};
local width={};
local on={};
local Price={};
local Label={};
local first;
local source;
local Size;
local LabelColor;
local Onward= {};
function Prepare(onlyName)
     
	source = instance.source; 
	first=source:first();
    local name;
    name = profile:id() .. "(" .. instance.source:name()  .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end 
	
    Size=instance.parameters.Size;
	LabelColor=instance.parameters.LabelColor;
	
	for i= 1, 10 , 1 do
	on[i]=instance.parameters:getBoolean("on" .. i);
	Onward[i]=instance.parameters:getBoolean("Onward" .. i);
	color[i]=instance.parameters:getColor("color" .. i);
	width[i]=instance.parameters:getInteger("width" .. i);
    style[i]=instance.parameters:getInteger("style" .. i);
	Price[i]=instance.parameters:getDouble("Price" .. i);	
	Label[i]=instance.parameters:getString("Label" .. i);	
	end
	
   instance:ownerDrawn(true);

end


function Update(period)     
end 


local init = false;
function Draw(stage, context)
    if stage ~= 2  
	then
	return;
	
	
	end
        if not init then
		    for i=1, 10 , 1 do
            context:createPen (i, context:convertPenStyle (style[i]), width[i], color[i]);
			end
            init = true;
			
			context:createFont (11, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
         end

	
	local visible, y;
	
	for i=1, 10 , 1 do
		if on[i]  then		 
		visible, y = context:pointOfPrice (Price[i]);	
        if Onward[i] then
		x, X, X= context:positionOfBar (source:size()-1);
		context:drawLine (i, x, y, context:right (), y);		
        else		
		context:drawLine (i, context:left (), y, context:right (), y);
		end
		
		width, height = context:measureText (11, Label[i], 0);
		context:drawText (11, Label[i], LabelColor,-1, context:right () -width , y-height, context:right (), y, 0);
		
		end
    end
	
end