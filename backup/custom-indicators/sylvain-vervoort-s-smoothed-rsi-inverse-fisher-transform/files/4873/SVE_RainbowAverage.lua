
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2297

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
    indicator:name("Sylvain Vervoort's rainbow moving average");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "", 2, 2, 1000);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Indicator Line Color", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("width", "Indicator Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Indicator Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local source;
local first;
local lwmas = {};
local w = {}
local out;

function Prepare(nameOnly)
    local name;

    name = profile:id() .. "(" .. instance.source:name() .. "," .. instance.parameters.N .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end

    local i, src, _w;

    src = instance.source;
    _w = 5;
    for i = 1, 10, 1 do
        w[i] = _w;
        if _w > 1 then
            _w = _w - 1;
        end
        lwmas[i] = core.indicators:create("LWMA", src, instance.parameters.N);
        src = lwmas[i].DATA;
    end

    first = src:first();

    out = instance:addStream("MA", core.Line, name, "MA", instance.parameters.clr, first);
    out:setWidth(instance.parameters.width);
    out:setStyle(instance.parameters.style);
end

function Update(period, mode)
    if period >= first then
        local s, i, t;
        s = 0;
        for i = 1, 10, 1 do
            t = lwmas[i];
            t:update(mode);
            s = s + w[i] * t.DATA[period];
        end
        s = s / 20;
        out[period] = s;
    end
end


