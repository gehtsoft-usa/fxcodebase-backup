-- Id: 1013
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1466

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 6 "Momentum and Oscillators" (page 145)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name(resources:get("name"));
    indicator:description(resources:get("description"));
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Oscillators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", resources:get("param_N_name"), resources:get("param_N_description"), 7, 2, 1000);
    indicator.parameters:addInteger("M", resources:get("param_M_name"), resources:get("param_M_description"), 14, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrTSI", resources:get("param_clrTSI_name"), resources:get("param_clrTSI_description"), core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;
local m;

local first;
local source = nil;
local delta = nil;
local absDelta = nil;
local ema_r1 = nil;
local ema_r2 = nil;
local ema_s1 = nil;
local ema_s2 = nil;
local deltaFirst = nil;

-- Streams block
local TSI = nil;

-- Routine
function Prepare(nameOnly)
    n = instance.parameters.N;
    m = instance.parameters.M;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. ", " .. m .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    delta = instance:addInternalStream(source:first() + 1, 0);
    absDelta = instance:addInternalStream(source:first() + 1, 0);
    deltaFirst = delta:first();
    
    ema_r1 = core.indicators:create("EMA", delta, n);
    ema_r2 = core.indicators:create("EMA", absDelta, n);
    ema_s1 = core.indicators:create("EMA", ema_r1.DATA, m);
    ema_s2 = core.indicators:create("EMA", ema_r2.DATA, m);
    
    first = ema_s1.DATA:first();
    TSI = instance:addStream("TSI", core.Line, name, "TSI", instance.parameters.clrTSI, first)
    TSI:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
function Update(period, mode)
    if period >= deltaFirst then
        delta[period] = source[period] - source[period - 1];
        absDelta[period] = math.abs(delta[period]);
    end
    
    ema_r1:update(mode);
    ema_r2:update(mode);
    ema_s1:update(mode);
    ema_s2:update(mode);
    
    if period >= first then
        if ema_s2.DATA[period] == 0 then
            TSI[period] = 0;
        else
            TSI[period] = 100 * ema_s1.DATA[period] / ema_s2.DATA[period];
        end
    end
end

