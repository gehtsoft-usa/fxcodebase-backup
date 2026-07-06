-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=604

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
    indicator:name("Time Price Opportunity Profile Price Heatmap");
    indicator:description("Time Price Opportunity Profile Price Heatmap");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Calculation");	
	
	indicator.parameters:addString("Price", "Price Source", "", "median");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	indicator.parameters:addInteger("Period", "Period or 0 for All", "Period", 25);
	indicator.parameters:addInteger("BoxSize", "Zone in Pips", "Zone", 5);
    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Color", "Color of Zone", "Color of Zone", core.rgb(128, 128, 128));
	indicator.parameters:addColor("Label", "Color of Label", "Color of Label", core.rgb(0, 0, 255));
	indicator.parameters:addBoolean("Show", "Show Label", "", true);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Color; 
local Period = nil;
local BoxSize; 
local TPO;
local max;
local Show;
local Label;
local Price;
local Last;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
 
	max=0;
	TPO = {};
	Last=nil;
	
    source = instance.source;
	 first = source:first();
	 
	 
	Color=instance.parameters.Color;
	Period=instance.parameters.Period;
	BoxSize=instance.parameters.BoxSize;
	Label=instance.parameters.Label;
	Show=instance.parameters.Show;
	Price=instance.parameters.Price;
   

 

   instance:ownerDrawn(true);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
 

	
	
	if period<= source:first() then
	TPO = {};
    max = 0; 
	Last=nil;
	end
	
	
	
	period=period-1;
	
	
	
	if Last==source:serial(period) then
	return;
	end
	
	Last=source:serial(period);
	
	
	
	if Period==0 then
	         
		 local median=source[Price][period];
        median = median / source:pipSize();
        median = median - median % BoxSize;
		
		
			local v = rawget(TPO, median);
			
			
			if v == nil then
				v = 0;
			end 
			
			 
			v = v + 1;
			 
			 
			if v > max then
				max = v;
			end
			  
			 
			local v = rawset(TPO, median, v);
 
			 
	elseif Period~=0  and period >= source:size()-1 -Period +1 then
			 
		  local median=source[Price][period];
            median = median / source:pipSize();
           median = median - median % BoxSize;
		
		
			local v = rawget(TPO, median);
			
			
			if v == nil then
				v = 0;
			end 
			
			 
			v = v + 1;
			 
			 
			if v > max then
				max = v;
			end
			  
			 
			local v = rawset(TPO, median, v);
 
			 
	end
	
 
end
 

 

local init = false;
 
function Draw(stage, context)
    if stage ~= 0
	or max==0 
	then
	return;
	end 
	
        if not init then
            context:createSolidBrush(1, Color);
            init = true;
        end
		
        for k, v in pairs(TPO) do 	 
	    Add(context, k, v, Transparency);			
        end

end

function Add(context,k,v, Transparency)

        if v== nil or v==0 then
		return;
		end
		
		

        local Price2=  k* source:pipSize() ;
		local Price1=  Price2 + BoxSize* source:pipSize();		
		local iTransparency=100-(v / max)*100;
		
		
		
		Transparency = context:convertTransparency (iTransparency);	  

		visible1, y1 =context:pointOfPrice (Price1);
		visible2, y2  = context:pointOfPrice (Price2);
		context:drawRectangle(-1, 1, context:left(), y1, context:right(), y2, Transparency);
		
		if Show then
		Size = y2-y1;
		context:createFont (2, "Arial", Size, Size, 0);
		width, height=context:measureText (2, tostring(v), 0);
		context:drawText (2, tostring(v) , Label, -1,  context:right()-width, y1, context:right(), y2, 0, 0);
		end
end
