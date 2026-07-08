
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2374

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

-- original MT4 implementation (c) TudorGirl (AnneTudor@ymail.com).

function Init()
    indicator:name("TrendMagic Indicator (new version)");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Parameters");
    indicator.parameters:addInteger("CCI", "CCI", "", 50);
    indicator.parameters:addInteger("ATR", "ATR", "", 5);
    indicator.parameters:addBoolean("Signal", "Signal Mode", "Don't change this parameter when use indicator on chart", false);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP_color", "Color of UP", "Color of UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DN_color", "Color of DN", "Color of DN", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "Dot Size", "", 2, 1, 5);
end

local pCCI;
local pATR;

local first;
local source = nil;
local ATR = nil;
local CCI = nil;
local SIG = nil;
local dotUp, dotDown;
local bufferUp, bufferDown;

function Prepare(nameOnly)
    pCCI = instance.parameters.CCI;
    pATR = instance.parameters.ATR;
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. pATR .. ", " .. pCCI .. ")";
    instance:name(name);
    if nameOnly then
        return ;
    end

    ATR = core.indicators:create("ATR", source, pATR);
    CCI = core.indicators:create("CCI", source, pCCI);
    first = math.max(ATR.DATA:first(), CCI.DATA:first()) + 1;

    dotUp = instance:addStream("UP", core.Dot, name .. ".UP", "UP", instance.parameters.UP_color, first);
    dotUp:setWidth(instance.parameters.width);

    dotDn = instance:addStream("DN", core.Dot, name .. ".DN", "DN", instance.parameters.DN_color, first);
    dotDn:setWidth(instance.parameters.width);

    bufferUp = instance:addInternalStream(first, 0);
    bufferDn = instance:addInternalStream(first, 0);

    if instance.parameters.Signal then
        SIG = instance:addStream("SIG", core.Line, name .. ".SIG", "SIG", core.rgb(0, 0, 0), first);
    else
        SIG = instance:addInternalStream(0, 0);
    end
end

function Update(period, mode)
    ATR:update(mode);
    CCI:update(mode);

    if period >= first then
        local thisCCI, v;
        thisCCI = CCI.DATA[period];

        if thisCCI >= 0 then
            SIG[period] = 1;
        else
            SIG[period] = -1;
        end

        if SIG[period] == 1 and SIG[period - 1] == -1 then
            bufferUp[period - 1] = bufferDn[period - 1];
        end

        if SIG[period] == -1 and SIG[period - 1] == 1 then
            bufferDn[period - 1] = bufferUp[period - 1];
        end

        if SIG[period] == 1 then
            v = source.low[period] - ATR.DATA[period];
            if SIG[period - 1] ~= 0 and v < bufferUp[period - 1] then
                v = bufferUp[period - 1];
            end
            bufferUp[period] = v;
            dotUp[period] = v;
        elseif SIG[period] == -1 then
            v = source.high[period] + ATR.DATA[period];
            if SIG[period - 1] ~= 0 and v > bufferDn[period - 1] then
                v = bufferDn[period - 1];
            end
            bufferDn[period] = v;
            dotDn[period] = v;
        end

    else
        SIG[period] = 0;
    end
end

