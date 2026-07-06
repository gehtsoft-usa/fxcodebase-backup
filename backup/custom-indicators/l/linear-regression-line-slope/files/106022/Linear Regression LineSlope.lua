-- Id: 15964

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63431

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
    indicator:name("Linear Regression Line Slope");
    indicator:description("Linear Regression Line");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PERIOD", "Period", "Perios",20);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Color of Up Trend", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn", "Color of Down Trend", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addInteger("width", "Width", "", 1, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local PERIOD;

local first;
local source = nil;

-- Streams block
local LRL = nil;

-- Routine
function Prepare(nameOnly)
    PERIOD = instance.parameters.PERIOD;
    source = instance.source;
    first = source:first()+PERIOD;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(PERIOD) .. ")";
    instance:name(name);
    
	if   (nameOnly) then
        return;
    end
	
   
        LRL = instance:addStream("LRL", core.Line, name, "LRL", instance.parameters.Up, first);
    LRL:setPrecision(math.max(2, instance.source:getPrecision()));
		LRL:setWidth(instance.parameters.width);
        LRL:setStyle(instance.parameters.style);
     
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not source:hasData(period) then
	return;
	end


     LRL[period] =   mathex.lregSlope(source, period - PERIOD + 1, period)/source:pipSize();
	 
	 
	 
	 if  LRL[period] >  LRL[period-1] then
	 LRL:setColor(period, instance.parameters.Up);
	else
	 LRL:setColor(period, instance.parameters.Dn);
    end
  
end

