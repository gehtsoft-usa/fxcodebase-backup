
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=901

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
    indicator:name("Williams Accumulation/Distribution (WAD) Price Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
   indicator.parameters:addInteger("Period", "Normalization Period", "Period", 50);
    indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Color", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Period;
-- Streams block
local WAD, wad;

 

-- Routine
function Prepare(nameOnly)
  
    Period=instance.parameters.Period;	
    source = instance.source;
   
     first =  source:first()+Period;
 
  
	 local name = profile:id() .. "(" .. source:name()  .. ", " .. Period .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
         
		wad = instance:addInternalStream(0, 0);
		
		WAD = instance:addStream("WAD", core.Line, name, "", instance.parameters.Color, first+Period);
		WAD:setWidth(instance.parameters.width);
        WAD:setStyle(instance.parameters.style);
		 
     
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

     
	if period < first   then
	return;
	end
	
	Calculation(period);
	    

	if period < first + Period  then
    return;
    end	
        local min1, max1;
		local min2, max2;
		min1,max1=mathex.minmax(source.close,period-Period+1, period);
		min2,max2=mathex.minmax(wad,period-Period+1, period);
		WAD[period] = ((wad[period] - min2)/ (max2-min2))*(max1-min1) +min1
	 
end


function Calculation (period)


 
     local TRH=math.max(source.high[period],source.close[period-1]);
     local TRL=math.min(source.low[period],source.close[period-1]);
     local AD;
     if source.close[period]>source.close[period-1]+source:pipSize() then
      AD=source.close[period]-TRL;
     elseif source.close[period]<source.close[period-1]-source:pipSize() then
      AD=source.close[period]-TRH;
     else
      AD=0.;
     end
	 
     wad[period]=wad[period-1]+AD;
    
end