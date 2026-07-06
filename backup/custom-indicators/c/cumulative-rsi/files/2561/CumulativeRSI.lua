-- Id: 910
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1340

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
    indicator:name("Cumulative RSI");
    indicator:description("The indicator for the strategy described in Chapter 9 of Trading Strategies That Work by Larry Connors and Cesar Alvarez.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("N", "RSI period", "", 2, 2, 200);
    indicator.parameters:addInteger("X", "RSI accumulation", "", 2, 1, 200);
    indicator.parameters:addDouble("EL", "Enter Level", "", 35, 0, 200);
    indicator.parameters:addDouble("EX", "Exit Level", "", 65, 0, 200);
    indicator.parameters:addColor("CRSI_color", "Color of CRSI", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local X;
local EL;
local EX;
local RSI;

local first;
local source = nil;

-- Streams block
local CRSI = nil;

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    X = instance.parameters.X;
    EL = instance.parameters.EL;
    EX = instance.parameters.EX;
    source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ", " .. X .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    RSI = core.indicators:create("RSI", source, N);
    first = RSI.DATA:first() + X;
    CRSI = instance:addStream("CRSI", core.Line, name, "CRSI", instance.parameters.CRSI_color, first);
    CRSI:addLevel(EL);
    CRSI:addLevel(EX);
	
	CRSI:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
function Update(period, mode)
    RSI:update(mode);
    if period >= first and source:hasData(period) then
        local range = core.rangeTo(period, X);
        CRSI[period] = core.sum(RSI.DATA, range);
    end
end

