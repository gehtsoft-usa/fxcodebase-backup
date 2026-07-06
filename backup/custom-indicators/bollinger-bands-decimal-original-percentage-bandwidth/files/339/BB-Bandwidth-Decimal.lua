-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=237
-- Id: 78

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
-- The indicator corresponds to the Bollinger Bands indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 5 "Trend System" (page 91-94)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Bollinger Band Decimal - Bandwidth Oscillator");
    indicator:description("Decimal: Provides a bandwidth histogram between two Bollinger Bands.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addDouble("N", "Number of periods", "Number of periods", 20.0);
    indicator.parameters:addDouble("Dev", "Number of standard deviations", "Number of standard deviations", 2.0);
    indicator.parameters:addColor("clrBBB", "Bandwidth histogram color", "The color of the histogram.", core.rgb(0, 255, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local D;

local firstPeriod;
local source = nil;

-- Streams block
local TL = nil;
local AL = nil;
local BL = nil;

local BAND = nil;

-- Routine
function Prepare(nameOnly)
    N = instance.parameters.N;
    D = instance.parameters.Dev;
    source = instance.source;
    firstPeriod = source:first() + N - 1;

    local name = "Bollinger Bands Decimal - Bandwidth Oscillator (" .. N .. ", " .. D .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    
    -- TOP LINE AND BOTTOM LINE INTERNAL STREAMS
    TL = instance:addInternalStream(firstPeriod)
    BL = instance:addInternalStream(firstPeriod)
    AL = instance:addInternalStream(firstPeriod)
    
    -- BAND LINE
    BAND = instance:addStream("Bandwidth", core.Bar, name .. ".BANDWIDTH", "BBBandwidth", instance.parameters.clrBBB, firstPeriod);
    BAND:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
function Update(period)

    -- CALCULATE "Bollinger Bands" INTERNAL STREAMS 
    if(period >= firstPeriod) then
        local p = core.rangeTo(period, N);
        local ml = core.avg(source, p);
        local d = core.stdev(source, p);

        TL[period] = ml + D * d;
        BL[period] = ml - D * d;
        AL[period] = ml;
    end
        
    -- CALCULATE "Bandwidth" LINE
    if(period >= firstPeriod) then
    	BAND[period] = ((TL[period] - BL[period]) / AL[period])
    end  
end





