
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62503

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
    indicator:name("Consecutive Candle Count");
    indicator:description("Consecutive Candle Count");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 0);

    indicator.parameters:addGroup("Style");		
    indicator.parameters:addColor("color", "Label Color", "Color of Label", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Font Size", "Size", 15);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Count;
local Period;
local min, max; 
local Size;
-- Routine
function Prepare(nameOnly) 
    source = instance.source;
    first = source:first();
    Period=instance.parameters.Period;
	Size=instance.parameters.Size;
	
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
 
    Count = instance:addInternalStream(0, 0);
	
	instance:ownerDrawn(true);

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
   
   
   if source[period]> source[period-1] then
   
	   if Count[period-1]<0 then
	   Count[period]=1;
	   else
	   Count[period]= Count[period-1]+1;
	   end
   
   elseif source[period]< source[period-1] then
        if Count[period-1]>0 then
	   Count[period]=-1;
	   else
	   Count[period]= Count[period-1]-1;
	   end
   else 
       Count[period]=0;
   end
   
   
 
	 if period == source:size()-1 then
	   if Period == 0 then
	   min, max= mathex.minmax(Count, source:first(), source:size()-1);
	   else
	   min, max= mathex.minmax(Count, math.max(source:first(), (source:size()-1-Period+1)), source:size()-1);
	   end
	 end
   
   
end

local init = false;
 
function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
        if not init then
             context:createFont (1, "Arial", Size, Size, 0)
            init = true;
        end
   
     text1="Up Trend : " .. tostring(max);
	 text2="Down Trend : " .. tostring(math.abs(min));
	 
	
	 
	 width1, height1 = context:measureText (1, text1, 0);
	 width2, height2 = context:measureText (1, text2, 0);
	 
	 local MAX= math.max(width1,width2);
	 
     context:drawText (1, text1, instance.parameters.color, -1,  context:right ()-MAX, context:top (), context:right (), context:top ()+ height1, context.LEFT);
	 context:drawText (1, text2, instance.parameters.color, -1, context:right ()-MAX, context:top ()+height1, context:right (), context:top () +height1*2, context.LEFT);   
	   
end 
 

