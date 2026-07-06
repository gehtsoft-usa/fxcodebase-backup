-- Id: 13871
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62047

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
    indicator:name("Distance From MA");
    indicator:description("Distance From MA");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
	
    indicator.parameters:addInteger("Period", "Period", "Period", 21);
    indicator.parameters:addString("Method", "Method", "Method", "MVA");
	indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Distance_color_Up", "Color of Distance Up", "Color of Distance", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Distance_color_Down", "Color of Distance Down", "Color of Distance", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Method;
local Price;
local first;
local source = nil;
local ma;
-- Streams block
local Distance = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    Method = instance.parameters.Method;
	Price = instance.parameters.Price;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Price).. ", " .. tostring(Period) .. ", " .. tostring(Method) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        ma = core.indicators:create(Method, source[Price], Period);
        first = source:first();
        Distance = instance:addStream("Distance", core.Bar, name, "Distance", instance.parameters.Distance_color_Up, first);
		Distance:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    ma:update(mode);
	
    if period < first or not source:hasData(period) then
	return;
	end 
    
       local Dist_Crt_High = math.abs(source.high[period] - ma.DATA[period-1]); -- Absolute value from MA to High
       local Dist_Crt_Low  = math.abs(source.low[period]  - ma.DATA[period-1]);   -- Absolute value from MA to Low
       
	   if (Dist_Crt_High >= Dist_Crt_Low) then 
	   Distance[period] = (source.high[period] - ma.DATA[period-1])/source:pipSize();
	   Distance:setColor(period, instance.parameters.Distance_color_Up);
	   end
	   -- Distance in pips, as integer. Could be (+) or (-);       
	   
       if (Dist_Crt_High < Dist_Crt_Low) then
	   Distance[period]  = (source.low[period]  - ma.DATA[period-1])/source:pipSize() 
	   Distance:setColor(period, instance.parameters.Distance_color_Down);
	   end 
	   -- Distance in pips, as integer. Could be (+) or (-);        
	   
 
    
end

