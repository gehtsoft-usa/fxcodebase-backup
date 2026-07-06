-- Id: 4929
-- More information about this indicator can be found at:
-- The indicator was revised and updated

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
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
    indicator:name("Positive Volume Index");
    indicator:description("Positive Volume Index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local PVI=nil;

function Prepare(nameOnly)
    source = instance.source;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    PVI = instance:addStream("PVI", core.Line, name .. ".PVI", "PVI", instance.parameters.clr, first);
    PVI:setPrecision(math.max(2, instance.source:getPrecision()));
    PVI:setWidth(instance.parameters.widthLinReg);
    PVI:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if (period>first) then
    if source.volume[period]>source.volume[period-1] then
     PVI[period]=PVI[period-1]*(1+((source.close[period]-source.close[period-1])/source.close[period-1]));
    else
     PVI[period]=PVI[period-1];
    end
   elseif period==first then
    PVI[period]=1;
   end 
end

