-- Id: 2885
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3164

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Bid Ask Spread Ovelay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("replaceSource", "t");

    indicator.parameters:addGroup("Style");  
	indicator.parameters:addInteger("Size", "Font Size", "", 15);
	indicator.parameters:addString("Font", "Font Type", "Font Type" , "Arial");  
	indicator.parameters:addColor("Up", "Color Of Up", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Down", "Color Of Down", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("LabelColor", "Label Color", "", core.rgb(0, 0, 0));
	
	indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Y", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Right");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 
	
   
end

local first;

local source;
local AskLabelColor, BidLabelColor, LabelColor ;
local AskColor = core.rgb(128, 128, 128);
local BidColor = core.rgb(128, 128, 128);
local AL=0;
local BL=0;
local SL=0;
local Size;
local Font;
local X,Y;
local Up, Down;
function Prepare(nameOnly)
    source = instance.source;
	Size = instance.parameters.Size;
	Font = instance.parameters.Font;
	X = instance.parameters.X;
	Y = instance.parameters.Y;	
    first = source:first();
    local name;
    name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name); 
	if nameOnly then
		return;
	end
	
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	LabelColor = instance.parameters.LabelColor; 
	
	 instance:ownerDrawn(true);

end


function Update(period )
 
end


local init = false;


function Draw(stage, context)

  if stage~= 2 then
  return;
  end
  

	local ASK = core.host:findTable("offers"):find("Instrument", source:instrument()).Ask;
	local BID = core.host:findTable("offers"):find("Instrument", source:instrument()).Bid;
	
	if ASK== nil or BID == nil then
	return;
	end
	
	
	  if not init then
           context:createFont (1, Font, context:pointsToPixels (Size), context:pointsToPixels (Size), 0);
            init = true;
       end
		
	
	local sub_value = 0; 
	
	 sub_value = (ASK - BID) / source:pipSize() ;
	 
	 
			if ASK~= AL then
					 
					 if  ASK > AL then
					 AskColor =Up;
					 else
					  AskColor =Down;
					 end
			        AL = ASK   
			 end
	
	        if BID ~= BL then
					 
					 if  BID > BL then
					BidColor =Up;
					 else
					  BidColor =Down;
					 end
			        BL = BID; 
			 end
			 
			 if sub_value ~= SL then
					 
					 if  sub_value > SL  then
					SpreadColor =Up;
					 else
					  SpreadColor =Down;
					 end
			         SL  = sub_value;
			 end
	
	
	width= context:pointsToPixels (Size)*10;
	
    Text="Bid";
	x, height = context:measureText (1, Text, 0);	
    context:drawText (1,  	Text, LabelColor, -1,  iX(context,width,1,1) ,  iY(context,height,1,1) ,iX(context,width,1,2),iY(context,height,1,2), 0 );	
	
	Text="Ask";
	x, height = context:measureText (1, Text, 0);	
    context:drawText (1,  	Text, LabelColor, -1,  iX(context,width,1,1) ,  iY(context,height,2,1) ,iX(context,width,1,2),iY(context,height,2,2), 0 );	
	
	
	Text="Spread";
	x, height = context:measureText (1, Text, 0);	
    context:drawText (1,  	Text, LabelColor, -1,  iX(context,width,1,1 ),  iY(context,height,3,1) ,iX(context,width,1,2),iY(context,height,3,2), 0 );	
	
	----------------------------------------
	 Text= string.format("%." .. source:getPrecision() .. "f", BID);
	x, height = context:measureText (1, Text, 0);	
    context:drawText (1,  	Text, BidColor, -1,  iX(context,width,0,1) ,  iY(context,height,1,1) ,iX(context,width,0,2),iY(context,height,1,2), 0 );	
	
	Text=  string.format("%." .. source:getPrecision() .. "f", ASK);
	x, height = context:measureText (1, Text, 0);	
    context:drawText (1,  	Text, AskColor, -1,  iX(context,width,0,1) ,  iY(context,height,2,1) ,iX(context,width,0,2),iY(context,height,2,2), 0 );	
	
	
	Text= string.format("%." .. source:getPrecision() .. "f", sub_value);
	x, height = context:measureText (1, Text, 0);	
    context:drawText (1,  	Text, SpreadColor, -1,  iX(context,width,0,1 ),  iY(context,height,3,1) ,iX(context,width,0,2),iY(context,height,3,2), 0 );	
	 
	 
	 
end	 


 
function iX(context, width,Shift,x)

	if X== "Left" then
	return  context:left()+ Shift*width +  width*(x-1) ;
	else
	return context:right() - width*Shift -  width*(1-(x-1));
	end
end



function iY(context, height,Shift,x)

	if Y== "Top" then
		return context:top()+Shift* height + height*(x-1) ;
	else
	return context:bottom()-Shift* height + height*(x-1) ;
	end
end
