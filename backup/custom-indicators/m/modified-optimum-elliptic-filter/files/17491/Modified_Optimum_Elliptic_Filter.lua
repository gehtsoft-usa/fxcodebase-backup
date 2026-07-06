-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7889

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
    indicator:name("Modified Optimum Elliptic Filter indicator");
    indicator:description("Modified Optimum Elliptic Filter indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local MOEF=nil;

function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    MOEF = instance:addStream("MOEF", core.Line, name .. ".MOEF", "MOEF", instance.parameters.clr, first);
    MOEF:setWidth(instance.parameters.widthLinReg);
    MOEF:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if (period>first+4) then
    MOEF[period]=0.13785*(2*source[period]-source[period-1])+0.0007*(2*source[period-1]-source[period-2])+0.13785*(2*source[period-2]-source[period-3])+1.2103*MOEF[period-1]-0.4867*MOEF[period-2];
   elseif period>=first then
    MOEF[period]=source[period]; 
   end 
end

