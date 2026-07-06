-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=14691
-- Id: 6017

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("TSF");
    indicator:description("TSF");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PERIOD", "Period", "Period", 20);
	indicator.parameters:addInteger("LWMA", "LWMA Weight", "", 3);
	indicator.parameters:addInteger("MA", "MA Weight", "", 2);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("TSF_Up", "Color of Up Trend", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("TSF_Dn", "Color of Down Trend", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local PERIOD;

local first;
local source = nil;
local LWMA, MA;
-- Streams block
local TSF = nil;

-- Routine
function Prepare(nameOnly)
    PERIOD = instance.parameters.PERIOD;
    source = instance.source;
    first =  source:first() + PERIOD - 1;
	LWMA= instance.parameters.LWMA;
	MA= instance.parameters.MA;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(PERIOD).. ", " .. tostring(LWMA).. ", " .. tostring(MA) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        TSF = instance:addStream("TSF", core.Line, name, "TSF", instance.parameters.TSF_Up, first);
		TSF:setWidth(instance.parameters.width);
		TSF:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not source:hasData(period) then
    return;
    end    

    TSF[period] =  LWMA *  mathex.lwma(source, period-PERIOD+1, period ) - MA *  mathex.avg(source, period-PERIOD+1 , period) ;
	
	if TSF[period] > TSF[period-1] then
	TSF:setColor(period, instance.parameters.TSF_Up);
	else
	TSF:setColor(period, instance.parameters.TSF_Dn);
    end
end

