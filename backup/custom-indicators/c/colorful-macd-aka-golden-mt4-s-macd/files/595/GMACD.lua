-- Id: 2500
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=358

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("MACD with bar's coloring");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SN", "Short EMA", "", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long EMA", "", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal Line", "", 9, 2, 1000);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("SIGNAL_color", "The signal line color", "", core.rgb(127, 255, 0));
    indicator.parameters:addColor("HISTOGRAM_color", "The histogramm color", "", core.rgb(127, 127, 127));
    indicator.parameters:addColor("HISTOGRAM1_color", "The histogramm color 1", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("HISTOGRAM2_color", "The histogramm color 2", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);		
end

-- Indicator instance initialization routine

-- Parameters block
local SN;
local LN;
local IN;

local firstPeriodMACD;

local firstPeriodSIGNAL;
local source = nil;

local EMAS = nil;
local EMAL = nil;
local MVAI = nil;

-- Streams block
local MACD = nil;
local SIGNAL = nil;
local HISTOGRAM = nil;

-- Routine
function Prepare(nameOnly)
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
    source = instance.source;

    -- Check parameters
    if (LN <= SN) then
       error("The short EMA period must be smaller than long EMA period");
    end
    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. SN .. ", " .. LN .. ", " .. IN .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end

    -- Create short and long EMAs for the source
    EMAS = core.indicators:create("EMA", source, SN);
    EMAL = core.indicators:create("EMA", source, LN);

    -- Create the output stream for the MACD. The first period is equal to the
    -- biggest first period of source EMA streams
    firstPeriodMACD = EMAL.DATA:first();


    HISTOGRAM = instance:addStream("H", core.Bar, name .. ".H", "H", instance.parameters.HISTOGRAM_color, firstPeriodMACD);
    HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));
    -- Create MVA for the MACD output stream.
    MVAI = core.indicators:create("MVA", HISTOGRAM, IN);
    firstPeriodSIGNAL = MVAI.DATA:first();
    -- Create output for the signal and histogram
    firstPeriodSIGNAL = MVAI.DATA:first();
    HISTOGRAM1 = instance:addStream("H1", core.Bar, name .. ".H1", "H1", instance.parameters.HISTOGRAM1_color, firstPeriodSIGNAL);
    HISTOGRAM1:setPrecision(math.max(2, instance.source:getPrecision()));
    HISTOGRAM2 = instance:addStream("H2", core.Bar, name .. ".H2", "H2", instance.parameters.HISTOGRAM2_color, firstPeriodSIGNAL);
    HISTOGRAM2:setPrecision(math.max(2, instance.source:getPrecision()));
    SIGNAL = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_color, firstPeriodSIGNAL);
    SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
	SIGNAL:setWidth(instance.parameters.width);
    SIGNAL:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
function Update(period, mode)
    -- and update short and long EMAs for the source.
    EMAS:update(mode);
    EMAL:update(mode);

    if (period >= firstPeriodMACD) then
        -- calculate MACD output
         HISTOGRAM[period] = EMAS.DATA[period] - EMAL.DATA[period];
    end

    -- update MVA on the MACD
    MVAI:update(mode);
    if (period >= firstPeriodSIGNAL) then
        SIGNAL[period] = MVAI.DATA[period];
        if HISTOGRAM[period] > 0 and HISTOGRAM[period] > SIGNAL[period] then
           HISTOGRAM1[period] = HISTOGRAM[period];
        elseif HISTOGRAM[period] < 0 and HISTOGRAM[period] < SIGNAL[period] then
           HISTOGRAM2[period] = HISTOGRAM[period];
        end
    end
end


