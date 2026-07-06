-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61600

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



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Price Heatmap");
    indicator:description("Price Heatmap");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addInteger("Period", "Period", "Period", 25);
	indicator.parameters:addDouble("BoxSize", "Zone in Pips", "Zone", 5);
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
local Last;
local TPO;
local max;
local Min,Max;
local Show;
local Label;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    source = instance.source;
	Color=instance.parameters.Color;
	Period=instance.parameters.Period;
	BoxSize=instance.parameters.BoxSize;
	Label=instance.parameters.Label;
	Show=instance.parameters.Show;
    first = source:first();

 

   instance:ownerDrawn(true);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < source:size()-1 
    and Last== source:serial(period)
	then
	return;
	end
	
	TPO = {};
    max = 0;
	Min,Max=mathex.minmax(source, source:size()-1-Period+1,source:size()-1);
	
	Last= source:serial(period);

	local i;
	for i= math.max(source:first(), source:size()-1-Period+1) ,source:size()-1, 1 do
	Calculation (i);
	end
	
	
 
end

function Calculation (period)


       
		local Step=source:pipSize()*BoxSize;
		for median= Min, Max, Step do		
			Set(median,period);		
		end

        	 
 
end

function Set(median,period)
            
		 
			local v = rawget(TPO, median);
			if v == nil then
				v = 0;
			end 
			
			if source.low[period] <=median 
			and source.high[period] >= (median+source:pipSize()*BoxSize)
			then			 
			v = v + 1;
			else
			return;
			end
			 
			if v > max then
				max = v;
			end
			  
			 
			local v = rawset(TPO, median, v);
 
end


local init = false;
 
function Draw(stage, context)
    if stage ~= 0 then
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
		
		

        local Price2=  k ;
		local Price1=  Price2 + BoxSize* source:pipSize();		
		local iTransparency=100-(v / (max/100));
		
		
		
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
