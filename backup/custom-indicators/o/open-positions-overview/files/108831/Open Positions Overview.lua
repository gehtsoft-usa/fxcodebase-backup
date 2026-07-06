-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64035

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
    indicator:name("Open Positions Overview");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Placement");
	indicator.parameters:addBoolean("PositionCapInstrument", "Use Position Instrument", "", true);
	indicator.parameters:addBoolean("PositionCapCustomID", "Use Position CustomID", "", true);
	
	indicator.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish Position instances", "Enter  Custom Identifier Here");

	
	indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Y", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Left");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 
    indicator.parameters:addInteger("ShiftY", "Shift","" , 3);
 
	
	indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
   indicator.parameters:addInteger("Size", "Font Size", "", 10);
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local X,Y;
local font;
local Label;
local Size;
local ShiftY;
local PositionCapInstrument, PositionCapCustomID;
local Offer;
local CustomID;
-- Routine
function Prepare(nameOnly)
    Y=instance.parameters.Y;
	X=instance.parameters.X;  
	ShiftY=instance.parameters.ShiftY;
    Label=instance.parameters.Label;
	CustomID=instance.parameters.CustomID;
	Size=instance.parameters.Size;   
    source = instance.source;
    first=source:first();
	
	PositionCapInstrument=instance.parameters.PositionCapInstrument;
	PositionCapCustomID=instance.parameters.PositionCapCustomID;
	
    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
   	Offer = core.host:findTable("offers"):find("Instrument", source:instrument()).OfferID;
    instance:ownerDrawn(true);

	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
 
function Update(period)   

  
end
 
local init = false;
 
function Draw(stage, context)
 
	  if stage~= 2 then
	  return;
	  end
	
        if not init then
           context:createFont (1, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
        end
		
	local Number=0;	

    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while (row ~= nil) do
        -- for every trade for this instance.
        if 	( not PositionCapInstrument or (row.OfferID == Offer and PositionCapInstrument))
		and ( not PositionCapCustomID or ( row.QTXT == CustomID  and PositionCapCustomID))
        then
		
		Number=Number+1;
		
		  Text= "Instrument: " ..  row.Instrument .. " Custom Identifier: " ..    row.QTXT  .. " Direction: " .. row.BS  .. " Profit: " ..  row.PL  .. " Profit: " .. row.GrossPL ;

          width, height = context:measureText (1, Text, 0);
         context:drawText (1,  Text, Label, -1,  iX(context,width,0,1) ,  iY(context,height,Number,0) ,iX(context,width,0,2),iY(context,height,Number,1), 0 );	    
        end

        row = enum:next();
    end
	
 

   

end		
 
 

function iX(context, width,Shift,x)

	if X== "Left" then
	return  context:left()+ Shift*width +  width*(x-1) ;
	else
	return context:right() - width*Shift -  width*(1-(x-1));
	end
end



function iY(context, height,Index , Line)

	if Y== "Top" then
		return context:top()+Index*height +ShiftY*height + Line *height;
	else
		if Line== 1 then
		return context:bottom()-(Index+1)*height -ShiftY*height + height;
		else
		return context:bottom()-(Index+1)*height -ShiftY*height;
		end
	end
end
 