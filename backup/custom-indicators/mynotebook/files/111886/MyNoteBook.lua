-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64576
-- Id: 17941

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
function Init()
    indicator:name("MyNoteBook");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    
    indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Type", "Price Type", "", "Right");
    indicator.parameters:addStringAlternative("Type", "Right", "", "Right");
    indicator.parameters:addStringAlternative("Type", "Left", "", "Left");
	indicator.parameters:addInteger("vShift", "Vertical Shift ", "", 50); 
 
 
	
	indicator.parameters:addGroup("Entries");
 
	for i= 1, 10 , 1 do	
	indicator.parameters:addString("entry"..i, i.. ". Entry", "", " ");   
    end
	
	for i= 1, 10 , 1 do
   	
    indicator.parameters:addGroup(i .. ". Entry Style");  
    indicator.parameters:addColor("color"..i, "Color", "", core.rgb(225, 225, 225));
    indicator.parameters:addString("font"..i, "Font", "", "Arial Black");
    indicator.parameters:addInteger("size"..i, "Font size ", "", 20); 
	end
	
	

 
end

local source; 
 local ID;
local color={};
local font={};
local size={};
local  entry={};
local vShift;
local Type;
function Prepare(nameOnly)
   
    source = instance.source; 
	ID= instance.parameters.ID;
	vShift= instance.parameters.vShift;
    Type= instance.parameters.Type;
	
    name = string.format("%s %s", profile:id(), source:name() );
    instance:name(name);
	 
	
    if nameOnly then
        return
    end
    
	for i= 1, 10 , 1 do 
     color[i]= instance.parameters:getColor("color"..i);
     font[i]= instance.parameters:getString("font"..i);
     size[i]= instance.parameters:getInteger("size"..i); 
	 entry[i]= instance.parameters:getString("entry"..i);
	end
	 
    instance:setLabelColor(color[1]);
    instance:ownerDrawn(true);
	 
	
end

-- Update the indicator
function Update(period, mode)
   
end

 

local initDraw = false;

function Draw(stage, context)
 
    if stage ~= 2 then
        return ;
    end

   
    local Shift=0;	
	for i= 1, 10 , 1 do
   
		 
		context:createFont (1, font[i], context:pointsToPixels (size[i]), context:pointsToPixels (size[i]), 0);
		width, height= context:measureText (1, tostring(entry[i]), 0)
		
		if Type== "Right" then
		context:drawText (1,  tostring(entry[i]), color[i], -1, context:right ()- width,  context:top () +Shift+vShift         , context:right ()       , context:top ()+Shift + height+vShift, 0);
		else
		context:drawText (1,  tostring(entry[i]), color[i], -1, context:left ()         ,  context:top () +Shift +vShift       , context:left ()+ width, context:top ()+Shift + height+vShift, 0);
		end
		Shift= Shift+height;
		 
	
    end
	
		
    
end	