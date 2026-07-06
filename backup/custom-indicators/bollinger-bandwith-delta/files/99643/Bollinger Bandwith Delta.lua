-- Id: 13923
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=62078


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
    indicator:name("Bollinger Bandwith Delta");
    indicator:description("Bollinger Bandwith Delta");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Periods", "Period", "Period", 20);
    indicator.parameters:addDouble("Deviations", "Deviation", "Deviation", 2);
	 indicator.parameters:addInteger("Delta_Period", "Delta Period", "Period", 20);
	 
	 indicator.parameters:addString("Method", "Delta Method", "Method" , "Pips");
    indicator.parameters:addStringAlternative("Method", "Percentage", "Percentage" , "Percentage");
    indicator.parameters:addStringAlternative("Method", "Pips", "Pips" , "Pips");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Delta_color_Up", "Color of Delta Up", "Color of Delta", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Delta_color_Down", "Color of Delta Down", "Color of Delta", core.rgb(255, 0 , 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Periods;
local Deviations;
local Method;
local first;
local source = nil;
local Delta_Period;
-- Streams block
local Delta = nil;
local Bandwith;
-- Routine
function Prepare(nameOnly)  
    Periods = instance.parameters.Periods;
    Deviations = instance.parameters.Deviations;
	Delta_Period = instance.parameters.Delta_Period;
	Method= instance.parameters.Method;
    source = instance.source;
    first = source:first()+Periods;
	
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Periods) .. ", " .. tostring(Deviations) .. ", " .. tostring(Method) .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
	    Bandwith= instance:addInternalStream(first, 0);
		
        Delta = instance:addStream("Delta", core.Bar, name, "Delta", instance.parameters.Delta_color_Up, first+ Delta_Period);
    Delta:setPrecision(math.max(2, instance.source:getPrecision()));
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not  source:hasData(period) then
	return;
	end
	
	
	  local Central= mathex.avg(source, period-Periods+1, period);
        local stdev = mathex.stdev(source,  period-Periods+1, period);

        local TL = Central + Deviations * stdev;
        local BL = Central - Deviations * stdev;
 
     
    	Bandwith[period] = ((TL - BL ) / Central)

	if period < first + Delta_Period  then
	return;
	end	
	
	if Method == "Percentage" then
	Delta[period] = (Bandwith[period]-Bandwith[period-Delta_Period+1] )/(Bandwith[period-Delta_Period+1]/100);
	else	
    Delta[period] =(Bandwith[period]-Bandwith[period-Delta_Period+1] )/source:pipSize();
    end
	
	if Delta[period]> Delta[period-1] then
	Delta:setColor(period, instance.parameters.Delta_color_Up);
	else
	Delta:setColor(period, instance.parameters.Delta_color_Down);
    end
end

