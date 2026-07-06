-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15886
-- Id: 6335

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("Serial MA indicator");
    indicator:description("Serial MA indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("CrossClr", "Cross Color", "Cross Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5);
end

local first;
local source = nil;
local LastCross;
local SerialMA=nil;
local Cross=nil;

function Prepare(nameOnly)
    source = instance.source;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    LastCross = instance:addInternalStream(first, 0);
    SerialMA = instance:addStream("SerialMA", core.Line, name .. ".SerialMA", "SerialMA", instance.parameters.clr, first);
    SerialMA:setWidth(instance.parameters.widthLinReg);
    SerialMA:setStyle(instance.parameters.styleLinReg);
    Cross = instance:addStream("Cross", core.Dot, name .. ".Cross", "Cross", instance.parameters.CrossClr, first);
    Cross:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)
   if (period>first) then
    LastCross[period]=LastCross[period-1];
    SerialMA[period]=core.avg(source, core.range(LastCross[period], period));
    if (SerialMA[period-1]-source[period-1])*(SerialMA[period]-source[period])<0 then
     LastCross[period]=period;
     Cross[period]=source[period];
     SerialMA[period]=source[period];
    else
     Cross[period]=nil;
    end
   elseif period==first then
    LastCross[period]=period;
    SerialMA[period]=source[period];
    Cross[period]=source[period];
   end 
end

