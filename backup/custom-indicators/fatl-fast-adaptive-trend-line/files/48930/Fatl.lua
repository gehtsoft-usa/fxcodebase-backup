-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27885
-- Id: 8204

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("FATL indicator");
    indicator:description("FATL indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Fatl=nil;
local FatlCoeff={[0]=0.4360409450, 0.3658689069, 0.2460452079, 0.1104506886, -0.0054034585, -0.0760367731, -0.0933058722, -0.0670110374, -0.0190795053, 0.0259609206,
                 0.0502044896, 0.0477818607, 0.0249252327, -0.0047706151, -0.0272432537, -0.0338917071, -0.0244141482, -0.0055774838, 0.0128149838, 0.0226522218,
                 0.0208778257, 0.0100299086, -0.0036771622, -0.0136744850, -0.0160483392, -0.0108597376, -0.0016060704, 0.0069480557, 0.0110573605, 0.0095711419,
                 0.0040444064, -0.0023824623, -0.0067093714, -0.0072003400, -0.0047717710, 0.0005541115, 0.0007860160, 0.0130129076, 0.0040364019};

function Prepare(nameOnly)
    source = instance.source;
    first = source:first()+38;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Fatl = instance:addStream("Fatl", core.Line, name .. ".Fatl", "Fatl", instance.parameters.clr, first);
    Fatl:setWidth(instance.parameters.widthLinReg);
    Fatl:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if (period>first) then
    local i;
    local _fatl=0;
    for i=0,38,1 do
     _fatl=_fatl+source[period-i]*FatlCoeff[i];
    end
    Fatl[period]=_fatl;
   end 
end

