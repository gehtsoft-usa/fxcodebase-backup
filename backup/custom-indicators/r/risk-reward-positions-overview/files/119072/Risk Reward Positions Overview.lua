-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66100

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
    indicator:name("Risk Reward Positions Overview");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Placement");
	indicator.parameters:addBoolean("PositionCapInstrument", "Use Position Instrument", "", true);
	--indicator.parameters:addBoolean("PositionCapCustomID", "Use Position CustomID", "", true);
	
	--indicator.parameters:addString("CustomID", "Custom Identifier", "The identifier that can be used to distinguish Position instances", "Enter  Custom Identifier Here");

	
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
local PositionCapInstrument;
local Offer;
 
-- Routine
function Prepare(nameOnly)
    Y=instance.parameters.Y;
	X=instance.parameters.X;  
	ShiftY=instance.parameters.ShiftY;
    Label=instance.parameters.Label;
 
	Size=instance.parameters.Size;   
    source = instance.source;
    first=source:first();
	
	PositionCapInstrument=instance.parameters.PositionCapInstrument;
	 
	
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
		
	local Number1=0;
    local Number2=0;	
    local Risk="-";
	local Reward="-";
	local PointSize;
	local Bid, Ask;
	
    enum = core.host:findTable("trades"):enumerator();
    row = enum:next();
    while (row ~= nil) do
        -- for every trade for this instance.
        if 	( not PositionCapInstrument or (row.OfferID == Offer and PositionCapInstrument))		 
        then
		
		
		if row.Risk==0  or row.Limit ==0 then
		Risk="-";
		Reward="-";
		else
		Risk="1";
		Reward=math.abs(row.Open-row.Stop)/math.abs(row.Open-row.Limit);
		end
		
		Number1=Number1+1;
		Text="";
		PointSize= core.host:findTable("offers"):find("Instrument", row.Instrument).PointSize;
		 
		  
		 
		  Text=  row.TradeID  .. "  " ..    row.Instrument   .. "   " .. row.BS   .. "   " .. Risk ..  "/"   .. Reward  .. "   " ..  win32.formatNumber((row.Close-row.Open)/PointSize, false, 2)    ;
		   

          width, height = context:measureText (1, Text, 0);
         context:drawText (1,  Text, Label, -1,  iX(context,width,0,1) ,  iY(context,height,Number1+1,0) ,iX(context,width,0,2),iY(context,height,Number1+1,1), 0 );	

				
        end

        row = enum:next();
    end
	
	
	            if Number1~= 0 then				 
				 Text= "Active Trader: " ..  Number1 ;
				  width, height = context:measureText (1, Text, 0);
				 context:drawText (1,  Text, Label, -1,  iX(context,width,0,1) ,  iY(context,height,0,0) ,iX(context,width,0,2),iY(context,height,0,1), 0 );				 
				 end
          		 
	
 
    enum = core.host:findTable("orders"):enumerator();
    row = enum:next();
    while (row ~= nil) do
        -- for every trade for this instance.
        if 	( not PositionCapInstrument or (row.OfferID == Offer and PositionCapInstrument))		 
        then
		
		--Rate
		--Stop
		--Limit;
        --Distance
        --PointSize

		
		if row.Risk==0  or row.Limit ==0 then
		Risk="-";
		Reward="-";
		else
		Risk="1";
		Reward=math.abs(row.Rate-row.Stop)/math.abs(row.Rate-row.Limit);
		end
		
		Number2=Number2+1;
		Text="";
	 
		  Text=  row.TradeID  .. "  " ..    row.Instrument   .. "   " .. row.BS   .. "   " .. Risk ..  "/"   .. Reward   .. "   " .. (- row.Distance) ;
		 

          width, height = context:measureText (1, Text, 0);
         context:drawText (1,  Text, Label, -1,  iX(context,width,0,1) ,  iY(context,height,Number1+Number2+4,0) ,iX(context,width,0,2),iY(context,height,Number1+Number2+4,1), 0 );	

				 
          		 
        end
		
		

        row = enum:next();
    end
	
                if Number2~= 0 then				 
				 Text= "Entry Orders: " ..  Number2 ;
				  width, height = context:measureText (1, Text, 0);
				 context:drawText (1,  Text, Label, -1,  iX(context,width,0,1) ,  iY(context,height,Number1+3,0) ,iX(context,width,0,2),iY(context,height,Number1+3,1), 0 );				 
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
 