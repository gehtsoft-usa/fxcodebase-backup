-- Id: 13989

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62116

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
    indicator:name("Volatility Stop");
    indicator:description("Volatility Stop");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("Multiplier", "Multiplier", "Multiplier", 2);
	 indicator.parameters:addInteger("Period", "Period", "Period", 20);
	 
	 
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("VolatilityStop_color", "Color of VolatilityStop", "Color of VolatilityStop", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("Volatility_color", "Color of Volatility", "Color of Volatility", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Multiplier;

local first;
local source = nil;
local Period;
-- Streams block
local VolatilityStop = nil;
local Volatility;
local HiLoDiff = nil;
-- Routine
function Prepare(nameOnly) 
    Multiplier = instance.parameters.Multiplier;
	Period= instance.parameters.Period;
    source = instance.source;
    first = source:first()+Period;
	


    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Multiplier).. ", " .. tostring(Period) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	    HiLoDiff = instance:addInternalStream(0, 0);
    
        VolatilityStop = instance:addStream("VolatilityStop", core.Line, name, "VolatilityStop", instance.parameters.VolatilityStop_color, first);
    VolatilityStop:setPrecision(math.max(2, instance.source:getPrecision()));
		VolatilityStop:setWidth(instance.parameters.width1);
        VolatilityStop:setStyle(instance.parameters.style1);
		core.host:execute ("attachOuputToChart", "VolatilityStop");
		Volatility = instance:addStream("Volatility", core.Line, name, "Volatility", instance.parameters.Volatility_color, first);
    Volatility:setPrecision(math.max(2, instance.source:getPrecision()));
		Volatility:setWidth(instance.parameters.width2);
        Volatility:setStyle(instance.parameters.style2);
  
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    HiLoDiff[period]=source.high[period]-source.low[period];
	
    if period < first or not source:hasData(period) then
	return;
	end
	
	
        VolatilityStop[period] = source.close[period]-Multiplier*mathex.avg(HiLoDiff, period-Period+1, period);
        Volatility[period] = (source.close[period]-VolatilityStop[period])/source.close[period];
end

