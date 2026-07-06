-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=18740
-- Id: 6585

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
    indicator:name("Peaks and Valleys");
    indicator:description("Peaks and Valleys");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addInteger("LookbackPeriod", "Lookback Period", "Lookback Period", 14);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Peaks_color", "Color of Peaks", "Color of Peaks", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("Peaks_width", "Peaks Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("Peaks_style", "Peaks Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Peaks_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Valleys_color", "Color of Valleys", "Color of Valleys", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Valleys_width", "Valleys Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("Valleys_style", "Valleys Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Valleys_style", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("Power_color", "Color of Power", "Color of Power", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Power_width", "Valleys Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("Power_style", "Valleys Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Power_style", core.FLAG_LINE_STYLE);
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
local Peaks = nil;
local Valleys = nil;
local EMA;
local Bulls, Bears;
local LookbackPeriod;
local Power;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	LookbackPeriod = instance.parameters.LookbackPeriod;
    source = instance.source;
    

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		EMA=core.indicators:create("EMA", source.close, Frame);
		first = EMA.DATA:first()+LookbackPeriod;
		
		Bulls= instance:addInternalStream(0, 0);
		Bears= instance:addInternalStream(0, 0);
        Peaks = instance:addStream("Peaks", core.Line, name .. ".Peaks", "Peaks", instance.parameters.Peaks_color, first);
    Peaks:setPrecision(math.max(2, instance.source:getPrecision()));
		Peaks:setWidth(instance.parameters.Peaks_width);
        Peaks:setStyle(instance.parameters.Peaks_style);
        Valleys = instance:addStream("Valleys", core.Line, name .. ".Valleys", "Valleys", instance.parameters.Valleys_color, first);
    Valleys:setPrecision(math.max(2, instance.source:getPrecision()));
		Valleys:setWidth(instance.parameters.Valleys_width);
        Valleys:setStyle(instance.parameters.Valleys_style);
		Power = instance:addStream("Power", core.Line, name .. ".Power", "Power", instance.parameters.Power_color, first);
    Power:setPrecision(math.max(2, instance.source:getPrecision()));
		Power:setWidth(instance.parameters.Power_width);
        Power:setStyle(instance.parameters.Power_style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

		if period  < first   then
		return;
		end
    
        EMA:update(mode);
	
        Bulls[period] = source.high[period] - EMA.DATA[period];
		Bears[period] = source.low[period] - EMA.DATA[period];
		
		local bearcount=0;
		local bullcount=0;
		
		local i;
		for i = period - LookbackPeriod+1, period, 1 do
		
			if  Bulls[i] > 0 then
			bullcount=bullcount+1;
			end
			if  Bears[i] < 0 then
			bearcount=bearcount+1;
			end
		
		end
		
		
		Power[period] = math.abs(bullcount - bearcount) * 100 / LookbackPeriod;
	

        Peaks[period] = bearcount * 100 / LookbackPeriod;
        Valleys[period] = bullcount * 100 / LookbackPeriod;
    
end

