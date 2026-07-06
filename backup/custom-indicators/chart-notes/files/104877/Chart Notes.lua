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

-- Available @ http://fxcodebase.com/code/viewtopic.php?f=17&t=63167&p=104877#p104877

 
local source;
local TextEntry;
local name;

-- Create the indicator's profile
function Init()
    indicator:name("Chart Notes");
    indicator:description("Chart Notes");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
       
	indicator.parameters:addGroup("Text Entry");  
    indicator.parameters:addString("TextEntry", "Text Entry", "", "Text Entry");
    indicator.parameters:addInteger("ID", "Note Identification", "", 1); 
	indicator.parameters:addInteger("X", "X Screen Coordinates", "", 100); 
	indicator.parameters:addInteger("Y", "Y Screen Coordinates", "", 100); 
    
    -- Colours and effects
    indicator.parameters:addGroup("Colours and effects");
    indicator.parameters:addColor("LabelColor", "Label Color", "", core.COLOR_LABEL );
    indicator.parameters:addString("FontName", "Font", "", "Arial");
    indicator.parameters:addInteger("FontSize", "Font size", "", 20);
	
	
end

local ID;
local LabelColor,FontName,FontSize;
local X,Y; 
function Prepare(nameOnly)
   
    source = instance.source;
	TextEntry =instance.parameters.TextEntry;
	LabelColor =instance.parameters.LabelColor;
	FontName =instance.parameters.FontName;
	FontSize =instance.parameters.FontSize;
	X =instance.parameters.X;
	Y =instance.parameters.Y;
	ID=instance.parameters.ID;
	
    name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
 

    if nameOnly then
        return
    end
 
	
    instance:setLabelColor(LabelColor);
    instance:ownerDrawn(true); 
end

-- Update the indicator
function Update(period, mode)
   
end

 
 
 

function Draw(stage, context)



    if stage ~= 2 then
        return ;
    end 
            
 
				

			context:createFont (1, FontName,  FontSize, FontSize, 0);	
			  width, height = context:measureText (1, TextEntry, 0);				
		     context:drawText (1, TextEntry, LabelColor, -1, context:left () + X , context:top () +Y,  context:left () + X+ width,context:top ()+ Y+height, 0);	
		
    
end	