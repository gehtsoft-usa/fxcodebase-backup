-- Id: 21048

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63018

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("OpenHigh vs OpenLow  ");
    indicator:description("OpenHigh vs OpenLow  ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addBoolean("SumUp", "SumUp", "", true);	
	indicator.parameters:addBoolean("Accumulate", "Accumulate", "", true);	
	indicator.parameters:addBoolean("Prevailing", "Prevailing Only", "", false);
    indicator.parameters:addBoolean("Positive", "Show All As Positive", "", false);
	
	 
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("OH_color", "Color of High Open", "Color of OH", core.rgb(0, 255, 0));
    indicator.parameters:addColor("OL_color", "Color of Open Low", "Color of OL", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

-- Streams block
local OH = nil;
local OL = nil;
local SumUp;
local SUM;
local Accumulate;
local Prevailing;
local Positive;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	SumUp=instance.parameters.SumUp;
	Accumulate=instance.parameters.Accumulate;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	 if   (nameOnly) then
        return;
    end
	
	Prevailing=instance.parameters.Prevailing;
	Positive=instance.parameters.Positive;

 
	    if SumUp   then
		SUM = instance:addStream("SUM", core.Bar, name .. ".SUM", "SUM", instance.parameters.OH_color, first);	
    SUM:setPrecision(math.max(2, instance.source:getPrecision()));
        OH = instance:addInternalStream(0, 0);
        OL  = instance:addInternalStream(0, 0);
		else
        OH = instance:addStream("OH", core.Bar, name .. ".OH", "OH", instance.parameters.OH_color, first);		
    OH:setPrecision(math.max(2, instance.source:getPrecision()));
        OL = instance:addStream("OL", core.Bar, name .. ".OL", "OL", instance.parameters.OL_color, first);
    OL:setPrecision(math.max(2, instance.source:getPrecision()));
		end
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period <first or not source:hasData(period) then
	return;
	end
	   
        OH[period] = (source.high[period]-source.open[period])/source:pipSize();
        OL[period] = -(source.open[period]-source.low[period])/source:pipSize();
        
		if Prevailing then
			if math.abs(OH [period])> math.abs(OL[period]) then
			OL[period]=0;
			else
			OH[period]=0;
			end		
		end
		
		
		if SumUp then
		SUM[period]=  OH[period]+ OL[period];
			if SUM[period]> 0 then
			SUM:setColor(period, instance.parameters.OH_color);
			else
			SUM:setColor(period, instance.parameters.OL_color);
			end
		end
		
		if Positive and not Accumulate and  SumUp then
		SUM[period]= math.abs(SUM[period]);
		elseif Accumulate and  SumUp then
		SUM[period]= SUM[period-1]+SUM[period];
		end
		
	 
		
end

