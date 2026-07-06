 
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62850

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
    indicator:name("Hammer / Hanging Man Patterns with ATR Filter");
    indicator:description("Hammer / Hanging Man Patterns with ATR Filter");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("ATR Calculation");
	indicator.parameters:addInteger("ATR_Period", "ATR Period", "ATR Period", 14);
	indicator.parameters:addDouble("ATR_Multiplier", "ATR Multiplier", "ATR Multiplier", 2);
	
	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addDouble("Ratio", "Minimal Lower Shadow / Body  Ratio", "Minimal Lower Shadow / Body  Ratio", 2);
	indicator.parameters:addDouble("Upper", "Minimal Body / Upper Shadow  Ratio", "Minimal Body / Upper Shadow  Ratio", 10);
	indicator.parameters:addBoolean("Body", "Use Body orientation Filter ", "", false);
	indicator.parameters:addBoolean("Reversal", "Use Trend Reversal Filter ", "", true);
	 indicator.parameters:addInteger("Period", "Trend Reversal Filter Period", "Trend Reversal Filter Period", 5);
	
	indicator.parameters:addGroup("Selection");	
	indicator.parameters:addBoolean("P1", "Hammer", "", true);	
    indicator.parameters:addBoolean("P2", "Hanging Man", "", true);
	
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addInteger("Size", "Font Size", "Font Size", 20);
	indicator.parameters:addColor("Hammer", "Color of Hammer", "Color of Hammer", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Hanging_Man", "Color of Hanging Man", "Color of Hanging MAN", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block


local first;
local source = nil;

-- Streams block
local Hammer = nil;
local Hanging_Man = nil;
local Size;
local P1, P2;
local Ratio;
local Upper;
local Body;
local Reversal;
local Period;
local ATR_Period;
local ATR_Multiplier;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	Period = instance.parameters.Period;
	ATR_Period = instance.parameters.ATR_Period;
	ATR_Multiplier = instance.parameters.ATR_Multiplier;
    ATR=core.indicators:create("ATR", source , ATR_Period);
	
	first = source:first();
    P1 = instance.parameters.P1;
	P2 = instance.parameters.P2;
	Size = instance.parameters.Size;
	Ratio = instance.parameters.Ratio;
	Upper = instance.parameters.Upper;
	Body = instance.parameters.Body;
	Reversal = instance.parameters.Reversal;
	
	
	
    local name = profile:id() .. "(" .. source:name().. ", " .. Ratio .. ", " .. Upper.. ", " .. Period.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	Hammer = instance:createTextOutput ("Hammer", "Hammer", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Hammer, first);
    Hanging_Man = instance:createTextOutput ("Hanging_Man", "Hanging_Man", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Hanging_Man, first);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    ATR:update(mode);
    if period < first+1 or not source:hasData(period) then
	return;
	end
	
	Hammer:setNoData (period);
	Hanging_Man:setNoData (period);
	
	if (source.high[period]- source.low[period]) < ATR_Multiplier*ATR.DATA[period] then
	return;
	end
	
	
	if  (math.abs(source.open[period] -source.close[period]) * Ratio)  > (math.min(source.open[period], source.close[period]) -  source.low[period])  then
	return;
	end
	
	
	if  (math.abs(source.open[period] -source.close[period]) )  < ((   source.high[period] - math.max(source.open[period], source.close[period])) *Upper )  then
	return;
	end
	
	
              
	if P1 then 
    p1(period);
	end
	
	if P2 then 
    p2(period);
	end
	
	
	
end

function p1 (period)

	if Body and source.close[period] <  source.open[period]  then
	return;
	end

	if Reversal then

		 if TEST(period, true) then
		 return;
		 end
		 
	end


Hammer:set(period, source.low[period], "\225"); 
end

function p2 (period)

		if Body and source.close[period] >  source.open[period]  then
		return;
		end

		if Reversal then

				 if  TEST(period, false) then
				 return;
				 end
				 
		end

Hanging_Man:set(period, source.high[period], "\226");
end


function TEST (period, Side )

 local FLAG= false;
 
   local i;
   for i = period, period -Period, -1 do
   
   
        if Side then
		
		     if source.low[period] > source.low[i] then
			 FLAG= true;
			 end
		
        else 
		
		     if source.high[period] < source.high[i] then
			 FLAG= true;
			 end
		
        end		   
   
   end


return FLAG;
end


