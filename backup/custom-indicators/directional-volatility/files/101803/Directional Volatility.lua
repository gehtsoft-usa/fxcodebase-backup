-- Id: 14666
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62540

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
    indicator:name("Directional Volatility");
    indicator:description("Directional Volatility");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
    indicator.parameters:addInteger("Deviation", "Deviation", "Deviation", 3);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Long_color", "Color of Long", "Color of Long", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Short_color", "Color of Short", "Color of Short", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Deviation;

local first;
local source = nil;

-- Streams block
local Long = nil;
local Short = nil;
local long,short;
local longMA,shortMA;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    Deviation = instance.parameters.Deviation;
    source = instance.source;
    first = source:first()+1;
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Deviation) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        long = instance:addInternalStream(first, 0);
        short = instance:addInternalStream(first, 0);
        
        longMA= core.indicators:create("EMA", long, Period);
        shortMA= core.indicators:create("EMA", short, Period);
        Long = instance:addStream("Long", core.Line, name .. ".Long", "Long", instance.parameters.Long_color, longMA.DATA:first() +Period);
		Long:setWidth(instance.parameters.width1);
        Long:setStyle(instance.parameters.style1);
        Short = instance:addStream("Short", core.Line, name .. ".Short", "Short", instance.parameters.Short_color, longMA.DATA:first() +Period);
		Short:setWidth(instance.parameters.width2);
        Short:setStyle(instance.parameters.style2);
		
		Long:setPrecision(math.max(2, instance.source:getPrecision()));
		Short:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    
    if period < first or not  source:hasData(period) then
	return;
	end
	 
	long[period]= source.close[period-1]-source.low[period];
	short[period]= source.high[period]- source.close[period-1];
	
	longMA:update(mode);
	shortMA:update(mode);
	
	 if period < longMA.DATA:first() +Period then
	return;
	end
        Long[period] = longMA.DATA[period]+Deviation*mathex.stdev(longMA.DATA,period-Period+1,period);
        Short[period] = shortMA.DATA[period]+Deviation*mathex.stdev(shortMA.DATA,period-Period+1,period);
 
	
end

