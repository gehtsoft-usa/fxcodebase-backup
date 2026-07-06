-- Id: 5838
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=13530

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("Commodity Selection Index - (CSI)");
    indicator:description("No description");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Trend Strength");


    indicator.parameters:addInteger("N1", "Period ADXR", "Period for ADXR", 14);
    indicator.parameters:addInteger("N2", "Period ATR", "Period for ATR", 14);
    indicator.parameters:addColor("CSI_color", "Color of CSI", "Color of CSI", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local N1;
local N2;

local first;
local source = nil;

-- Streams block
local CSI = nil;
local ADX = nil;
local ATR = nil;

-- Routine
function Prepare(nameOnly)
    N1 = instance.parameters.N1;
    N2 = instance.parameters.N2;
    source = instance.source;
 

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(N1) .. ", " .. tostring(N2) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        ADX = core.indicators:create("ADX", source, N1);
        ATR = core.indicators:create("ATR", source, N2);
 
        first = math.max(ADX.DATA:first(),ATR.DATA:first())  ;
        CSI = instance:addStream("CSI", core.Line, name, "CSI", instance.parameters.CSI_color, first);
		CSI:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    ADX:update(mode);
    ATR:update(mode);

    if period > first then
        local vATR      = ATR.DATA[period];
        local vADXR     = (ADX.DATA[period] + ADX.DATA[period-14])/ 2;
        local V         = vATR/source:pipSize();
        local pipCost   = core.host:findTable("offers"):find("Instrument", source:instrument()).PipCost;
        local M         = math.sqrt(core.host:findTable("offers"):find("Instrument", source:instrument()).MMR);
        local spread    = core.host:findTable("offers"):find("Instrument", source:instrument()).Ask-core.host:findTable("offers"):find("Instrument", source:instrument()).Bid
        local C         = spread*pipCost;
        local ka        = V/M;
        local kb        = 1.0/(150+C);
 
        CSI[period] = ka*kb*100*vADXR*vATR;
    end
end


