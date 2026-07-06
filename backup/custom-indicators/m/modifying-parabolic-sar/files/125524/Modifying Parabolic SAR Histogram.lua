-- Id: 24641
-- More information about this indicator can be found at:
-- http://fxcodebase.com/

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
	indicator:name("Modifying Parabolic SAR Histogram")
	indicator:description("")
	indicator:requiredSource(core.Bar)
	indicator:type(core.Oscillator)
	indicator.parameters:addGroup("Calculation")
	indicator.parameters:addDouble("xo_inc", "xo_inc", "", 3.25)
	indicator.parameters:addDouble("AF_start", "AF_start", "", 0.06)
	indicator.parameters:addDouble("AF_inc", "AF_inc", "", 0.04)
	indicator.parameters:addDouble("AF_max", "AF_max", "", 1.0)

	indicator.parameters:addGroup("Style")
	indicator.parameters:addColor("clrUp", "Up Color", "", core.rgb(255, 0, 0))
	indicator.parameters:addColor("clrDown", "Down Color", "", core.rgb(0, 255, 0))
end

local first
local source = nil

-- Streams block
local SAR = nil
local xo_inc, AF_start, AF_inc, AF_max
local indi;

-- Routine
function Prepare(nameOnly)
	source = instance.source
	first = source:first()

	xo_inc = instance.parameters.xo_inc * source:pipSize()
	AF_start = instance.parameters.AF_start
	AF_inc = instance.parameters.AF_inc
	AF_max = instance.parameters.AF_max

	local name =
		profile:id() .. "(" .. source:name() .. "," .. xo_inc .. "," .. AF_start .. "," .. AF_inc .. "," .. AF_max .. ")"
	instance:name(name)

	if (nameOnly) then
		return
    end
    assert(core.indicators:findIndicator("MODIFYING PARABOLIC SAR") ~= nil, "Please, download and install MODIFYING PARABOLIC SAR.LUA indicator");    
    indi = core.indicators:create("MODIFYING PARABOLIC SAR", source, xo_inc, AF_start, AF_inc, AF_max,
        instance.parameters.clrUp, instance.parameters.clrDown);
    SAR = instance:addStream("UP", core.Bar, name .. ".Up", "UP", instance.parameters.clrUp, first)
    SAR:setPrecision(math.max(2, instance.source:getPrecision()));
    SAR:addLevel(0);
end

-- Indicator calculation routine
function Update(period, mode)
    indi:update(mode);
    if indi.DATA:hasData(period) then
        SAR[period] = 1;
        SAR:setColor(period, indi.DATA:colorI(period));
    end
end
