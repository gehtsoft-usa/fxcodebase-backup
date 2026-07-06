
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
	
	indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method", "HPF", "", "HPF");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Indicator Line Color", "", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("width", "Indicator Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Indicator Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local source;
local first;
local ma = {};
local w = {}
local out;
local Method;
function Prepare(nameOnly)
    local name;
	Method=instance.parameters.Method;

    name = profile:id() .. "(" .. instance.source:name() .. "," .. instance.parameters.N .. ")";
    instance:name(name);
    
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please download and install AVERAGES.lua indicator");
	
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
        ma[i] = core.indicators:create("AVERAGES", src, Method, instance.parameters.N);
        src = ma[i].DATA;
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
            t = ma[i];
            t:update(mode);
            s = s + w[i] * t.DATA[period];
        end
        s = s / 20;
        out[period] = s;
    end
end


