-- Id: 8336
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=30289

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
    indicator:name("Range Indicator");
    indicator:description("Compares the intraday range (high - low) to the inter-day (close - previous close) range. When the intraday range is greater than the inter-day range, the Range Indicator will be a high value. This signals an end to the current trend. When the Range Indicator is at a low level, a new trend is about to start.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("periodQ", "periodQ", "periodQ", 3);
    indicator.parameters:addInteger("smooth", "smooth", "smooth", 10);
	indicator.parameters:addString("Method", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("RIND_color", "Color of RIND", "Color of RIND", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local periodQ;
local smooth;
local Method;
local stochRange;
local val1;

local first;
local source = nil;

-- Streams block
local RIND = nil;
local MA;
-- Routine
function Prepare(nameOnly)
    periodQ = instance.parameters.periodQ;
	Method = instance.parameters.Method;
    smooth = instance.parameters.smooth;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(periodQ) .. ", " .. tostring(smooth)  .. ", " .. tostring(Method).. ")";
    instance:name(name);

    if (not (nameOnly)) then
        stochRange = instance:addInternalStream(0, 0);
        val1 = instance:addInternalStream(0, 0);
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
        MA = core.indicators:create(Method, stochRange, smooth);
        first = source:first()+1;
        RIND = instance:addStream("RIND", core.Line, name, "RIND", instance.parameters.RIND_color, MA.DATA:first());
    RIND:setPrecision(math.max(2, instance.source:getPrecision()));
		RIND:setWidth(instance.parameters.width);
        RIND:setStyle(instance.parameters.style);
	end	
		 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


    if period <=first   then	
	stochRange[period]=50;			
	return;
	end
	
	
	local  trueRange = math.max(source.high[period], source.close[period-1]) - math.min(source.low[period], source.close[period-1]);

			if (source.close[period] > source.close[period-1]) then
				val1[period]=(trueRange / (source.close[period] - source.close[period-1]));
			else
				val1[period]=trueRange;
            end	
	
	if period < first+periodQ then
	return;
	end
	
			local  val2 = mathex.min(val1, period-periodQ, period);
			local  val3 = mathex.max(val1, period-periodQ, period);

			if ((val3 - val2) > 0) then
				stochRange[period]=(100 * ((val1[period] - val2) / (val3 - val2)));
			else
				stochRange[period]=(100 * (val1[period] - val2));
			end	
			
		 MA:update(mode);	

		if period < MA.DATA:first() then
        return;
        end		
	
        RIND[period] = MA.DATA[period];
   
end

