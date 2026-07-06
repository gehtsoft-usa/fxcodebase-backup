
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3596

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


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("BarAlert");
    indicator:description("BarAlert");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
    indicator.parameters:addGroup("Calculation");	 
    indicator.parameters:addDouble("Level", "Min. Bar Lengt in Pips", "", 10, 0, 100000);	
    indicator.parameters:addInteger("Size", "Font Size", "", 8, 1, 100000);
	indicator.parameters:addInteger("Lookback", "Lookback Period", "", 0); 
	 
	 indicator.parameters:addString("Type", "Sign/Label", "", "Sign");
    indicator.parameters:addStringAlternative("Type", "Sign", "", "Sign");
    indicator.parameters:addStringAlternative("Type", "Label", "", "Label");
	
	
	indicator.parameters:addGroup("Style");	 
    indicator.parameters:addColor("Top_color", "Up Bar Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Bottom_color", "Down Bar Color", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;
local Size;
local Level;
local Type;
local font;
local Lookback;
-- Routine
function Prepare(nameOnly)   
    Type = instance.parameters.Type; 
    Size = instance.parameters.Size;
    Level = instance.parameters.Level;
	Lookback = instance.parameters.Lookback;
    source = instance.source;
    first = source:first();
	
  

	
	
    local name = profile:id() .. "(" .. source:name() ..", ".. Level.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	  instance:ownerDrawn(true);
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    
	   
	 
end
 
 function Draw(stage, context)
    if stage ~= 2 then
    return;
	end
	
    for period= context:firstBar (), context:lastBar (), 1  do
	  Add(context,period);
	  context:createFont (1, "Wingdings", context:pointsToPixels (Size), context:pointsToPixels (Size), 0)
	  context:createFont (2, "Arial", context:pointsToPixels (Size), context:pointsToPixels (Size), 0)
    end
end


function Add(context, period)


		if Lookback~= 0 and period< source:size()-1- Lookback+1 then
		return;
        end		
		
	local Lengt;	
	local Font;
	
	x, x1, x2 = context:positionOfBar (period);
	Lengt= (source.close[period] -source.open[period])/source:pipSize();
	
		    if Type ==  "Sign" then	
			Text= "\108";
			Font=1;
            else   						
			Text = string.format("%." .. 2 .. "f",  Lengt );
			Font=2;
			end
			
			width, height= context:measureText (Font, Text, 0);
			
		   if Lengt > Level then
		   visible, y =context:pointOfPrice (source.high[period]);
		   context:drawText (Font, Text, instance.parameters.Top_color, -1, x, y-height, x+width, y, 0, 0)		  
		   elseif Lengt < -Level then
		    visible, y =context:pointOfPrice (source.low[period]);
		   context:drawText (Font, Text, instance.parameters.Bottom_color, -1, x , y, x+width, y+height, 0, 0);	   
		   end
  end