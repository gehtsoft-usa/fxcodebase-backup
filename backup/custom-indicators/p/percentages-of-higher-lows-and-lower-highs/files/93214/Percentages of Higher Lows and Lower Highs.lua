-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60453
-- Id: 11373

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
    indicator:name("Percentages of Higher Lows and Lower Highs");
    indicator:description("Percentages of Higher Lows and Lower Highs");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 200);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("LH_color", "Color of LH", "Color of LH", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("HL_color", "Color of HL", "Color of HL", core.rgb(0, 255, 0));
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

local first;
local source = nil;

-- Streams block
local LH = nil;
local HL = nil;
local rawLH = nil;
local rawHL = nil;

local pLH = nil;
local pHL = nil;

-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first()+Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		rawLH = instance:addInternalStream(0, 0);
		rawHL = instance:addInternalStream(0, 0);
        LH = instance:addStream("LH", core.Line, name .. ".LH", "LH", instance.parameters.LH_color, first+Period);
    LH:setPrecision(math.max(2, instance.source:getPrecision()));
		LH:setWidth(instance.parameters.width1);
        LH:setStyle(instance.parameters.style1);
        HL = instance:addStream("HL", core.Line, name .. ".HL", "HL", instance.parameters.HL_color, first+Period);
    HL:setPrecision(math.max(2, instance.source:getPrecision()));
		HL:setWidth(instance.parameters.width2);
        HL:setStyle(instance.parameters.style2);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first  then
	return;
	end
	
	local H,L;
	H, L= Fractal(period);
	
	if H== true and  pLH== nil  then
	pLH=period-2;
    return;
	end
	
	if L== true  and  pHL== nil then
	pHL=period-2;
	return;
	end
	
	if H then
		if source.high[period - 2] < source.high[pLH]then
		 rawLH[period-2] = 1;
		 pLH=period-2;
		end
		pLH=period-2;
	end
	
	if L then
	    if source.low[period - 2] > source.low[pHL] then
		 rawHL[period-2] = 1;
		 pHL=period-2;
		end
		pHL=period-2;
	end
	
	if period < first+Period then
	return;
	end
	
	local iLH =mathex.sum(rawLH, period-Period+1,period );
	local iHL = mathex.sum(rawHL, period-Period+1, period);
	
	LH[period]=iLH/ ((iLH+iHL)/100);
	HL[period]=iHL/ ((iLH+iHL)/100);
	
       
      
    
end


function Fractal(period)

local H=false;
local L=false;
 
        local curr = source.high[period - 2];
        if (curr > source.high[period - 4] and curr > source.high[period - 3] and
            curr > source.high[period - 1] and curr > source.high[period]) then
            H=true;     
        end
        curr = source.low[period - 2];
        if (curr < source.low[period - 4] and curr < source.low[period - 3] and
            curr < source.low[period - 1] and curr < source.low[period]) then
            L=true;     
        end

		
		return H,L;

end
