-- Id: 5584
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=412

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+
 
function Init()
    indicator:name("Guppy's Multiple Moving Average Convergence/Divergence");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addColor("COLOR", "Indicator's Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addColor("LineClr", "Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local source = nil;
local GMMA = nil;
local out = nil;
local first = nil;
local line=nil;

 function Prepare(nameOnly)  
    source = instance.source;
    local name;
    -- set the indicator name (use the short name of our indicator: GMMA)
    name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("GMMA") ~= nil, "Please, download and install GMMA.LUA indicator");    
		
    GMMA = core.indicators:create("GMMA", source);
    first = GMMA:getStream(11):first();
    out = instance:addStream("H", core.Bar, name .. ".H", "H", instance.parameters.COLOR, first);
    out:setPrecision(math.max(2, instance.source:getPrecision()));
    line = instance:addStream("line", core.Line, name .. ".line", "line", instance.parameters.LineClr, first);
    line:setPrecision(math.max(2, instance.source:getPrecision()));
    line:setWidth(instance.parameters.widthLinReg);
    line:setStyle(instance.parameters.styleLinReg);
    out:addLevel(0);
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
        line[period]=out[period];
    end
end
