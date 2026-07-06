-- Id: 4069
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

-- The indicator corresponds to the Bollinger Bands indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 5 "Trend System" (page 91-94)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Bollinger Band Decimal - Percentage Oscillator");
    indicator:description("Decimal Version: Provides a percentage display between two Bollinger Bands.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addDouble("N", "Number of periods", "Number of periods", 20.0);
    indicator.parameters:addDouble("Dev", "Number of standard deviations", "Number of standard deviations", 2.0);
    indicator.parameters:addColor("clrBBP_UP", "Percentage line color for UP direction", "The UP color of the average line of the band.", core.rgb(0, 255, 0 ));
    indicator.parameters:addColor("clrBBP_DN", "Percentage line color for DN direction", "The DN color of the average line of the band.", core.rgb(255, 0, 0));
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

local PL = nil;

-- Routine
function Prepare()
    N = instance.parameters.N;
    D = instance.parameters.Dev;
    source = instance.source;
    firstPeriod = source:first() + N - 1;

    local name = "Bollinger Bands Decimal - Percentage Oscillator (" .. N .. ", " .. D .. ")";
    instance:name(name);
    
    -- TOP LINE AND BOTTOM LINE INTERNAL STREAMS
    TL = instance:addInternalStream(firstPeriod)
    BL = instance:addInternalStream(firstPeriod)
    AL = instance:addInternalStream(firstPeriod)
    
    -- PERCENTAGE LINE
    PL = instance:addStream("Percentage", core.Line, name .. ".PERCENTAGE", "BBPL", instance.parameters.clrBBP_UP, firstPeriod);
    PL:setPrecision(math.max(2, instance.source:getPrecision()));
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
    
    -- CALCULATE "Bollinger Bands" PERCENTAGE STREAM
    if(period >= firstPeriod) then
    	PL[period] = ((source[period] - BL[period]) / (TL[period] - BL[period])) * 100
    	if PL[period]>PL[period-1] then
    	 PL:setColor(period,instance.parameters.clrBBP_UP);
    	else
    	 PL:setColor(period,instance.parameters.clrBBP_DN);
    	end
    end
end





