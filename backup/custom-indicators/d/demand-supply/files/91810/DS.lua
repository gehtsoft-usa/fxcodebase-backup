-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60169
-- Id: 10798

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Demand - Supply");
    indicator:description("Demand - Supply");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addString("Type", "Algorithm Type", "Type" , "Moving Average");
    indicator.parameters:addStringAlternative("Type", "Moving Average", "Moving Average" , "Moving Average");
    indicator.parameters:addStringAlternative("Type", "Summarizing", "Summarizing" , "Summarizing");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Positiv", "Color of Positiv Supply", "Color of DS", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Negativ", "Color of Negativ Supply", "Color of DS", core.rgb(255, 0, 0)) 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;
local Raw,MA;
-- Streams block
local DS = nil;
local Method;
local Type;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Method = instance.parameters.Method;
	Type= instance.parameters.Type;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(Method).. ", " .. tostring(Type) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		Raw = instance:addInternalStream(0, 0);
		
		if Type ==  "Moving Average" then	
		MA = core.indicators:create(Method, Raw, Period); 
		first = MA.DATA:first();
		else
		 first = source:first()+Period;
		end
        DS = instance:addStream("DS", core.Bar, name, "DS", instance.parameters.Positiv, first);
		DS:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

local buy= (math.abs(source.close[period]-source.low[period])/(source.high[period]-source.low[period]))*source.volume[period];
local sell= (math.abs(source.high[period]-source.close[period])/(source.high[period]-source.low[period]))*source.volume[period];
    
	Raw[period]= buy-sell;
	if Type ==  "Moving Average" then	
	MA:update(mode);
	end
	
	if period < first or not  source:hasData(period) then
	return;
	end
	    if Type ==  "Moving Average" then			
        DS[period] = MA.DATA[period];
		elseif Type ==  "Summarizing" then	
		DS[period] = mathex.sum(Raw, period-Period+1, period);
		end
		
		if DS[period]> 0 then
		DS:setColor(period, instance.parameters.Positiv);
		else
		DS:setColor(period, instance.parameters.Negativ);
		end
    
end

