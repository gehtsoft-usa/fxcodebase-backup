-- Id: 8798
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=33848

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
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Time Segmented Volume");
    indicator:description("Time Segmented Volume");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Up_color", "Positive TSV Color", "Color of TSV", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn_color", "Negativ TSV Color", "Color of TSV", core.rgb( 255,0 , 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;
local temp;
-- Streams block
local TSV = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;		 
	 
    first = source:first()+Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	
	assert(source:supportsVolume(), "The source must have volume");
	
	temp = instance:addInternalStream(0, 0);
    TSV = instance:addStream("TSV", core.Bar, name, "TSV", instance.parameters.Up_color, first);		
    TSV:setPrecision(math.max(2, instance.source:getPrecision()));
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
  
	
	if source.close[period]> source.close[period-1] then
	temp[period]=  source.volume[period] * (source.close[period]- source.close[period-1]);
	elseif source.close[period]< source.close[period-1] then
	temp[period]=   (-1) * source.volume[period] * (source.close[period-1]-source.close[period]  );
	else
    temp[period]=0;
	end

	if period <  first then
	return;
	end
	
    TSV[period] = mathex.sum(temp, period-Period+1, period);
	
	if TSV[period] > TSV[period-1] then
	TSV:setColor(period, instance.parameters.Up_color);
	else
	TSV:setColor(period, instance.parameters.Dn_color);
    end	
    
end

