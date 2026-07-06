-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34141
-- Id: 8912

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
    indicator:name("%B of On-Balance Volume");
    indicator:description("%B of On-Balance Volume");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Period", "Period", 33);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("OBV_color", "Color of Line", "Color of Line", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;

-- Streams block
local OBD = nil;
local obv, MA, MA2;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end

        obv = instance:addInternalStream(0, 0); 
        MA2 = core.indicators:create("MVA", obv, Period);
        first = math.max(   Period, MA2.DATA:first()) ;
        OBD = instance:addStream("OBV", core.Line, name, "OBV", instance.parameters.OBV_color, first);
		OBD:setWidth(instance.parameters.width);
        OBD:setStyle(instance.parameters.style);
		
		OBD:setPrecision(math.max(2, source:getPrecision()));
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    OBV(period); 
	MA2:update(mode);
    if period < first   then
	return;
	end
 
	local std2 = mathex.stdev(obv, period-Period+1, period);	
	local FormulaB, FormulaA;
 
	FormulaB=1+((obv[period]-(MA2.DATA[period]-(2*(std2))))/(MA2.DATA[period] +(2*(std2))-(MA2.DATA[period]-(2*(std2)))))
        OBD[period] =  FormulaB;
		
   
end


function OBV(period)
 
        if source.close[period] > source.close[period - 1] then
            obv[period] = obv[period - 1] + source.volume[period];
        elseif source.close[period] < source.close[period - 1] then
            obv[period] = obv[period - 1] - source.volume[period];
        else
            obv[period] = obv[period - 1];
        end
end

