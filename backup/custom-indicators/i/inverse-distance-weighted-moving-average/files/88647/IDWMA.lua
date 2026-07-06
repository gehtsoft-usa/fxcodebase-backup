-- Id: 9764
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59165

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
    indicator:name("Inverse Distance Weighted Moving Average");
    indicator:description("Inverse Distance Weighted Moving Average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("IDWMA_color", "Color of IDWMA", "Color of IDWMA", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;

-- Streams block
local IDWMA = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first()+Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        IDWMA = instance:addStream("IDWMA", core.Line, name, "IDWMA", instance.parameters.IDWMA_color, first);
        IDWMA:setWidth(instance.parameters.width);
        IDWMA:setStyle(instance.parameters.style);
	end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first  then
	return;
	end
	
	local  Ewx=0;
    local  Ew=0; 
	local iLimit = period - Period;
	local iWeight;
	
	for iWeight= period, iLimit, -1 do
		
	local Ed = 0;
	
	local iDist;
			 for  iDist = period,   iLimit , -1 do 
							Ed = Ed + math.abs(source[iWeight] - source[iDist]);
			 end
		 
	local  w = (Period - 1) / math.max(Ed, source:pipSize());
                Ew  = Ew+w;
                Ewx = Ewx + w * source[iWeight];
				
				
	
	end
	
        IDWMA[period] = Ewx / Ew;
    
end


--[[ 
        
           
			
			
			
            for(int iWeight = iBar; iWeight < iLimit; iWeight++)
			{
               
                for(int iDist = iBar; iDist < iLimit; iDist++){
                    Ed += MathAbs(prices[iWeight] - prices[iDist]);
                }
                
            
            
       

]]
