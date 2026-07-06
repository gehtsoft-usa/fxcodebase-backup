-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66103
-- Id:

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
    indicator:name("Ichimoku + Daily-Candle_X + HULL-MA_X + MacD")
    indicator:description("")
    indicator:requiredSource(core.Tick)
    indicator:type(core.Indicator)

    indicator.parameters:addInteger("keh", "Double HullMA", "", 14);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local source = nil
local keh;
local wma_1;
local wma_2;
local diff;
local diff1;
local wma_3;
local wma_4;
local N1;
local N2;
local C;
local source_d1;

function Prepare(nameOnly)
    local name = profile:id() .. "(" .. instance.source:name()
    instance:name(name)

    if (nameOnly) then
        return
    end

    keh = instance.parameters.keh;
    wma_1 = core.indicators:create("LWMA", instance.source, math.floor(keh / 2 + 0.5));
    wma_2 = core.indicators:create("LWMA", instance.source, keh);
    diff = instance:addInternalStream(0, 0);
    diff1 = instance:addInternalStream(0, 0);
    local sqn = math.floor(math.sqrt(keh) + 0.5);
    wma_3 = core.indicators:create("LWMA", diff, sqn);
    wma_4 = core.indicators:create("LWMA", diff1, sqn);
    source_d1 = core.host:execute("getSyncHistory", instance.source:instrument(), "D1", instance.source:isBid(), 300, 100, 101);
    
    N1 = instance:addStream("N1", core.Line, "N1", "N1", core.rgb(255, 0, 0), 0);
    N2 = instance:addStream("N2", core.Line, "N2", "N2", core.rgb(255, 0, 0), 0);
 --   C = instance:addStream("C", core.Line, "C", "C", core.rgb(255, 0, 0), 0);
   C = instance:addInternalStream(0, 0);
end

local loading = true;

-- Indicator calculation routine
function Update(period, mode)
    wma_1:update(core.UpdateLast);
    wma_2:update(core.UpdateLast);
    if not wma_1.DATA:hasData(period) or not wma_2.DATA:hasData(period) or loading or source_d1.close:size() < 2 then
        return;
    end

    local n2ma = 2 * wma_1.DATA[period];
    local nma = wma_2.DATA[period];
    diff[period] = n2ma - nma;
    diff1[period] = diff[period - 1];
    wma_3:update(core.UpdateLast);
    wma_4:update(core.UpdateLast);
    if not wma_3.DATA:hasData(period) or not wma_4.DATA:hasData(period) then
        return;
    end
    N1[period] = wma_3.DATA[period];
    N2[period] = wma_4.DATA[period];
    C[period] = (source_d1[NOW] - source_d1[NOW - 1]) / source_d1[NOW - 1];
end

function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end
 
