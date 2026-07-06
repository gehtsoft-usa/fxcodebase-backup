-- Id: 12923
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61420

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
    indicator:name("SmoothedAdaptiveMomentum");
    indicator:description("SmoothedAdaptiveMomentum");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("Alpha", "Alpha", "Alpha", 0.07);
    indicator.parameters:addInteger("Cutoff", "Cutoff", "Cutoff", 8);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("SAM_color", "Color of SAM", "Color of SAM", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Alpha;
local Cutoff;

local first;
local source = nil;

-- Streams block
local SAM = nil;
local  tempReal, rad2Deg, deg2Rad, coef1, coef2, coef3, coef4;
local CyclePeriod;
-- Routine
function Prepare(nameOnly)
    Alpha = instance.parameters.Alpha;
    Cutoff = instance.parameters.Cutoff;
    source = instance.source;
	assert(core.indicators:findIndicator("CYCLEPERIOD") ~= nil, "Please, download and install CYCLEPERIOD.LUA indicator");
	tempReal = math.atan(1.0);
    rad2Deg = 45.0 / tempReal;
    deg2Rad = 1.0 / rad2Deg;
    local  pi = math.atan(1.0) * 4.0;
    local a1 = math.exp(-pi / Cutoff);
    local b1 = 2 * a1 *  math.cos( math.sqrt(3.0) * pi/ Cutoff);
    local c1 = a1 * a1;
    coef2 = b1 + c1;
    coef3 = -(c1 + b1 * c1);
    coef4 = c1 * c1;
    coef1 = 1.0 - coef2 - coef3 - coef4; 

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Alpha) .. ", " .. tostring(Cutoff) .. ")";
    instance:name(name);
	
    if (not (nameOnly)) then
        CyclePeriod = core.indicators:create("CYCLEPERIOD", source, Alpha);
        first = CyclePeriod.DATA:first();
        SAM = instance:addStream("SAM", core.Line, name, "SAM", instance.parameters.SAM_color, first);
    SAM:setPrecision(math.max(2, instance.source:getPrecision()));
		SAM:setWidth(instance.parameters.width);
        SAM:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    CyclePeriod:update(mode);
	
    if period < first or not source:hasData(period) then
	return;
	end
	
	  
        local Period = math.floor(CyclePeriod.DATA[period]);
		
    if period < first+ Period then
	return;
	end
	
        local  Value1 = source.median[period] -  source.median[period-Period+1];
        SAM[period] = coef1 * Value1 + coef2 * SAM[period - 1] +    coef3 * SAM[period - 2] + coef4 * SAM[period - 3];
      
end

