-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7895

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
    indicator:name("Jurik Ultralinear Smoothing");
    indicator:description("Jurik Ultralinear Smoothing (Copyright © 1998, Jurik Research) (JurX, JRX) produces ultra smooth curves with very little lag");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods to smooth", "", 8, 1, 10000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width", "Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
end

local n, first, first0, alive, jrx, jrx1;
local source;
local data;

function Prepare(onlyName)

    source = instance.source;
    n = instance.parameters.N;

    local name;
    name = profile:id() .. "(" .. source:name() .. "," .. n .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end
	
	require("jmalua");


    first0 = source:first();
    first = first0 + n * 3;
    data = instance:addStream("JRX", core.Line, name .. ".JRX", "JRX", instance.parameters.clr, first);
    data:setWidth(instance.parameters.width);
    data:setStyle(instance.parameters.style);
    alive = source:isAlive();
    jrx = jmalua.jrx();
    jrx1 = jmalua.jrx();
end

local lastN = nil;
local lastS = nil;

function Update(period, mode)
    --if lastN == nil or period < lastN then
    if period == 0 then
        jrx:init();
        jrx:prepare(n);
        lastS = nil;
    end
    lastN = period;


    if period >= first0 then
        if lastS ~= nil and lastS == source:serial(period) then
            -- calculating the same period again
            jrx:restore(jrx1);
        else
            --if (period == source:size() - 1) and alive then
            if alive then
                -- store the last bar state before calculating, we may calculate it again
                jrx:save(jrx1);
                lastS = source:serial(period);
            end
        end

        local v = jrx:next(source[period]);
        if period >= first then
            data[period] = v;
        end
    end
end
