-- Id: 4067
-- The indicator corresponds to the Bollinger Bands indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 5 "Trend System" (page 91-94)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Bollinger Band Decimal - Bandwidth Oscillator");
    indicator:description("Decimal: Provides a bandwidth histogram between two Bollinger Bands.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	indicator.parameters:addBoolean("Simple", "Calculate Simple Bandwidth", "", false);
    indicator.parameters:addDouble("N", "Number of periods", "Number of periods", 20.0);
    indicator.parameters:addDouble("Dev", "Number of standard deviations", "Number of standard deviations", 2.0);
    indicator.parameters:addColor("clrBBB_UP", "Bandwidth histogram color for UP direction", "The UP color of the histogram.", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrBBB_DN", "Bandwidth histogram color for DN direction", "The DN color of the histogram.", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local N;
local D;
local Simple;

local firstPeriod;
local source = nil;

-- Streams block
local TL = nil;
local AL = nil;
local BL = nil;

local BAND = nil;

-- Routine
function Prepare()
    Simple = instance.parameters.Simple;
    N = instance.parameters.N;
    D = instance.parameters.Dev;
    source = instance.source;
    firstPeriod = source:first() + N - 1;

    local name = "Bollinger Bands Decimal - Bandwidth Oscillator (" .. N .. ", " .. D .. ")";
    instance:name(name);
    
    -- TOP LINE AND BOTTOM LINE INTERNAL STREAMS
    TL = instance:addInternalStream(firstPeriod)
    BL = instance:addInternalStream(firstPeriod)
    AL = instance:addInternalStream(firstPeriod)
    
    -- BAND LINE
    BAND = instance:addStream("Bandwidth", core.Bar, name .. ".BANDWIDTH", "BBBandwidth", instance.parameters.clrBBB_UP, firstPeriod);
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
        if Simple then
		BAND[period] = (TL[period] - BL[period]) ;
        else		
    	BAND[period] = ((TL[period] - BL[period]) / AL[period]);
    	if BAND[period]>BAND[period-1] then
    	 BAND:setColor(period,instance.parameters.clrBBB_UP);
    	else
    	 BAND:setColor(period,instance.parameters.clrBBB_DN);
    	end
		end
    end  
end





