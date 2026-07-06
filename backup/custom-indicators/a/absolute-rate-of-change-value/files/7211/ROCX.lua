-- Id: 2792
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3095

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Rate Of Change (Modified version)");
    indicator:description("The indicator shows how the chosen source has been changed");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of bars", "Number of bars ago to compare the current value", 1, 1, 1000);
    indicator.parameters:addInteger("M", "Mode", "", 1);
    indicator.parameters:addIntegerAlternative("M", "Absolute Value", "", 1);
    indicator.parameters:addIntegerAlternative("M", "% Value", "", 2);
    indicator.parameters:addIntegerAlternative("M", "%% Value", "", 3);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrROC", "Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthROC", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleROC", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleROC", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local n;
local m;

local first;
local source = nil;

-- Streams block
local ROC = nil;

-- Routine
function Prepare(nameOnly)
    n = instance.parameters.N;
    m = instance.parameters.M;
    source = instance.source;
    first = source:first() + n + 1;

    local mname;

    if m == 1 then
        mname = "abs";
    elseif m == 2 then
        mname = "%";
    elseif m == 3 then
        mname = "%%";
    else
        assert(false, "Unknown mode");
    end



    local name = profile:id() .. "(" .. source:name() .. ", " .. n .. "," .. mname .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    ROC = instance:addStream("ROCX", core.Line, name, "ROCX", instance.parameters.clrROC, first)
    ROC:setWidth(instance.parameters.widthROC);
    ROC:setStyle(instance.parameters.styleROC);
    local precision = math.max(2, source:getPrecision());
    ROC:setPrecision(precision);
    ROC:addLevel(0);
end

-- Indicator calculation routine
function Update(period)
    if period >= first then
        local diff = source[period] - source[period - n];
        if m == 1 then
            ROC[period] = diff;
        elseif m == 2 then
            ROC[period] = diff / source[period - n] * 100;
        elseif m == 3 then
            ROC[period] = diff / source[period - n] * 1000;
        end
    end
end

