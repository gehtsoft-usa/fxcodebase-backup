-- More information about this indicator can be found at:
-- http://fxcodebase.com/
-- Id: 11243

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
    indicator:name("MA28 indicator");
    indicator:description("MA28 indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 10);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local SMA_C, SMA_O, SMA_H, SMA_L, SMA_M, SMA_T, SMA_W;
local EMA_C, EMA_O, EMA_H, EMA_L, EMA_M, EMA_T, EMA_W;
local SMMA_C, SMMA_O, SMMA_H, SMMA_L, SMMA_M, SMMA_T, SMMA_W;
local LWMA_C, LWMA_O, LWMA_H, LWMA_L, LWMA_M, LWMA_T, LWMA_W;
local MA28=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return
    end
    SMA_C = core.indicators:create("MVA", source.close, Period);
    SMA_O = core.indicators:create("MVA", source.open, Period);
    SMA_H = core.indicators:create("MVA", source.high, Period);
    SMA_L = core.indicators:create("MVA", source.low, Period);
    SMA_M = core.indicators:create("MVA", source.median, Period);
    SMA_T = core.indicators:create("MVA", source.typical, Period);
    SMA_W = core.indicators:create("MVA", source.weighted, Period);
    EMA_C = core.indicators:create("EMA", source.close, Period);
    EMA_O = core.indicators:create("EMA", source.open, Period);
    EMA_H = core.indicators:create("EMA", source.high, Period);
    EMA_L = core.indicators:create("EMA", source.low, Period);
    EMA_M = core.indicators:create("EMA", source.median, Period);
    EMA_T = core.indicators:create("EMA", source.typical, Period);
    EMA_W = core.indicators:create("EMA", source.weighted, Period);
    SMMA_C = core.indicators:create("SMMA", source.close, Period);
    SMMA_O = core.indicators:create("SMMA", source.open, Period);
    SMMA_H = core.indicators:create("SMMA", source.high, Period);
    SMMA_L = core.indicators:create("SMMA", source.low, Period);
    SMMA_M = core.indicators:create("SMMA", source.median, Period);
    SMMA_T = core.indicators:create("SMMA", source.typical, Period);
    SMMA_W = core.indicators:create("SMMA", source.weighted, Period);
    LWMA_C = core.indicators:create("LWMA", source.close, Period);
    LWMA_O = core.indicators:create("LWMA", source.open, Period);
    LWMA_H = core.indicators:create("LWMA", source.high, Period);
    LWMA_L = core.indicators:create("LWMA", source.low, Period);
    LWMA_M = core.indicators:create("LWMA", source.median, Period);
    LWMA_T = core.indicators:create("LWMA", source.typical, Period);
    LWMA_W = core.indicators:create("LWMA", source.weighted, Period);
    MA28 = instance:addStream("MA28", core.Line, name .. ".MA28", "MA28", instance.parameters.clr, first);
    MA28:setWidth(instance.parameters.widthLinReg);
    MA28:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if period>first then
    SMA_C:update(mode);
    SMA_O:update(mode);
    SMA_H:update(mode);
    SMA_L:update(mode);
    SMA_M:update(mode);
    SMA_T:update(mode);
    SMA_W:update(mode);
    EMA_C:update(mode);
    EMA_O:update(mode);
    EMA_H:update(mode);
    EMA_L:update(mode);
    EMA_M:update(mode);
    EMA_T:update(mode);
    EMA_W:update(mode);
    SMMA_C:update(mode);
    SMMA_O:update(mode);
    SMMA_H:update(mode);
    SMMA_L:update(mode);
    SMMA_M:update(mode);
    SMMA_T:update(mode);
    SMMA_W:update(mode);
    LWMA_C:update(mode);
    LWMA_O:update(mode);
    LWMA_H:update(mode);
    LWMA_L:update(mode);
    LWMA_M:update(mode);
    LWMA_T:update(mode);
    LWMA_W:update(mode);
    
    local Sum_SMA=SMA_C.DATA[period]+SMA_O.DATA[period]+SMA_H.DATA[period]+SMA_L.DATA[period]+SMA_M.DATA[period]+SMA_T.DATA[period]+SMA_W.DATA[period];
    local Sum_EMA=EMA_C.DATA[period]+EMA_O.DATA[period]+EMA_H.DATA[period]+EMA_L.DATA[period]+EMA_M.DATA[period]+EMA_T.DATA[period]+EMA_W.DATA[period];
    local Sum_SMMA=SMMA_C.DATA[period]+SMMA_O.DATA[period]+SMMA_H.DATA[period]+SMMA_L.DATA[period]+SMMA_M.DATA[period]+SMMA_T.DATA[period]+SMMA_W.DATA[period];
    local Sum_LWMA=LWMA_C.DATA[period]+LWMA_O.DATA[period]+LWMA_H.DATA[period]+LWMA_L.DATA[period]+LWMA_M.DATA[period]+LWMA_T.DATA[period]+LWMA_W.DATA[period];
    MA28[period]=(Sum_SMA+Sum_EMA+Sum_SMMA+Sum_LWMA)/28;
   end 
end

