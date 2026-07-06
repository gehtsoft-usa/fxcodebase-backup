-- Id: 7519
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23831

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
    indicator:name("Exponential Smoothing with Trend Adjustment");
    indicator:description("Exponential Smoothing with Trend Adjustment");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation")
    indicator.parameters:addDouble("Alfa", "Alpha", "Alpha", 0.2);
    indicator.parameters:addDouble("Beta", "Beta", "Beta", 0.3);
	--indicator.parameters:addDouble("Period", "Forecast Period", "Forecast Period", 10);
	indicator.parameters:addBoolean("Use", "Use Trend Adjustment", "", true);
	indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("H_color", "Color of Historical Forecast", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);

--	indicator.parameters:addColor("F_color", "Color of Future Forecast", "", core.rgb(0, 255, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Alfa;
local Beta;
local Period=0;
local first;
local source = nil;
--local Source;
-- Streams block
local F, T;
local Use;
-- Routine
function Prepare(nameOnly)
    Alfa = instance.parameters.Alfa;
	Use = instance.parameters.Use;
    Beta = instance.parameters.Beta;
	--Period = instance.parameters.Period;
    source = instance.source;
    first = source:first();
	--Source= instance:addInternalStream(first, Period);
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Alfa) .. ", " .. tostring(Beta) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		T= instance:addInternalStream(first, Period);
        F = instance:addStream("EMATA", core.Line, name, "EMATA", instance.parameters.H_color, first, Period );
		F:setWidth(instance.parameters.width);
        F:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not  source:hasData(period) then
	return;
	end
   
   -- Source[period]= source[period];	
	
	F[period] = Alfa* source[period-1]+(1-Alfa)*(F[period-1]+T[period-1]);	
	if Use then 
	T[period]=Beta*(F[period]-F[period-1])+(1-Beta)*T[period-1];
	else
	T[period]=0;
	end
	
	--[[
	if period == source:size()-1 then 
		
	   local i;
	   
	   for i = period+1, period+Period+1, 1  do
	     F[i] = Alfa* Source[i-1]+(1-Alfa)*(F[i-1]+T[i-1]);	
		if Use then 
	    T[i]=Beta*(F[i]-F[i-1])+(1-Beta)*T[i-1];  
        else  
        T[i]=0;		
        end		
		Source[i]= F[i];
		
		
		F:setColor(i, instance.parameters.F_color);
		
	   end   
	 
	end]]
    

end