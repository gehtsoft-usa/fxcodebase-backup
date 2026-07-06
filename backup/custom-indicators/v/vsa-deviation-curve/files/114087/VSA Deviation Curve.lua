-- Id: 18805

-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=64975

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
    indicator:name("VSA Deviation Curve");
    indicator:description("VSA Deviation Curve");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addInteger("Period", "Period", "", 200);
	indicator.parameters:addDouble("Factor", "Factor", "", 1.5);
 
	indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("color1", "Color of Deviation Line", "", core.rgb(0,255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("color2", "Color of Signal Line", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local first;
local source = nil;
local VCLOSE,VHIGH;
local Factor, Period;
local Deviation, Signal;
-- Routine
function Prepare(nameOnly)
 
    source = instance.source;
    first = source:first()+1;
 
	
	Factor=instance.parameters.Factor;
	Period=instance.parameters.Period;
	 
    local name = profile:id() .. "(" .. source:name().. ", " .. Period .. ", " .. Factor .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	  
	VCLOSE = instance:addInternalStream(0, 0);
	VHIGH= instance:addInternalStream(0, 0);
	
    
 
		Deviation= instance:addStream("Deviation", core.Line, name .. ".Deviation", "Deviation", instance.parameters.color1, first);
    Deviation:setPrecision(math.max(2, instance.source:getPrecision()));
        Deviation:setWidth(instance.parameters.width1);
        Deviation:setStyle(instance.parameters.style1);
		
		
		Signal= instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.color2, first+Period);
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
        Signal:setWidth(instance.parameters.width2);
        Signal:setStyle(instance.parameters.style2)
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
local init= true;
function Update(period)
    if period < first or not source:hasData(period) then
	return;
	end
	
	
	local VOPEN = VCLOSE[period-1];
    VCLOSE[period] = source.close[period]*source.volume[period];
	VHIGH[period] = math.max( source.high[period]*source.volume[period],VCLOSE[period] ,VOPEN)
	local VLOW = math.min( source.low[period]*source.volume[period],VOPEN ,VCLOSE[period])
	Deviation[period] = (VHIGH[period]+VLOW)/2;
	
	if period < first+Period  then
	return;
	end
	
    Signal[period]= mathex.avg(VHIGH, period-Period+1, period) + mathex.stdev(VHIGH, period-Period+1, period)*Factor;
end

 
 