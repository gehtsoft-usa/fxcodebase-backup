-- Id: 6489
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

local Period ={3,5,8,10,12,15,30,35,40,45,50,60};
function Init()
    indicator:name("Customizable Guppy's Multiple Moving Average Convergence/Divergence");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	local i;
	for i =1, 12, 1 do 	
	indicator.parameters:addInteger("Period"..i, "Period", "", Period[i]);
	end	
	
    indicator.parameters:addColor("COLOR", "Indicator's Color", "", core.rgb(255, 0, 0));
end

local source = nil;
local GMMA = nil;
local out = nil;
local first = nil;

function Prepare(nameOnly)
    source = instance.source;
    local name;
    -- set the indicator name (use the short name of our indicator: GMMA)
    name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if nameOnly then
        return;
    end
	
	assert(core.indicators:findIndicator("CGMMA") ~= nil, "Please, download and install CGMMA.LUA indicator");
	
    GMMA = core.indicators:create("CGMMA", source, 
	instance.parameters:getInteger("Period" .. 1),
	instance.parameters:getInteger("Period" .. 2),
	instance.parameters:getInteger("Period" .. 3),
	instance.parameters:getInteger("Period" .. 4),
	instance.parameters:getInteger("Period" .. 5),
	instance.parameters:getInteger("Period" .. 6),
	instance.parameters:getInteger("Period" .. 7),
	instance.parameters:getInteger("Period" .. 8),
	instance.parameters:getInteger("Period" .. 9),
	instance.parameters:getInteger("Period" .. 10),
	instance.parameters:getInteger("Period" .. 11),
	instance.parameters:getInteger("Period" .. 12)
	);
    first = GMMA:getStream(11):first();
    out = instance:addStream("H", core.Bar, name .. ".H", "H", instance.parameters.COLOR, first);
    out:addLevel(0);
	
	out:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
    GMMA:update(mode);

    if (period >= first) then
        local f, s;
        f = GMMA:getStream(0)[period] + GMMA:getStream(1)[period] + GMMA:getStream(2)[period] +
            GMMA:getStream(3)[period] + GMMA:getStream(4)[period] + GMMA:getStream(5)[period];
        s = GMMA:getStream(6)[period] + GMMA:getStream(7)[period] + GMMA:getStream(9)[period] +
            GMMA:getStream(9)[period] + GMMA:getStream(10)[period] + GMMA:getStream(11)[period];
        out[period] = (f - s) / s * 100;
    end
end
