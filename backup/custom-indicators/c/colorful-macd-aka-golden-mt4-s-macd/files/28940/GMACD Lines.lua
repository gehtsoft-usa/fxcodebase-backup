-- Id: 6188
--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--|                                 Support our efforts by donating  | 
--|                                    Paypal: http://goo.gl/cEP5h5  |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
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
    indicator.parameters:addColor("HISTOGRAM_color", "The histogram color", "", core.rgb(127, 127, 127));
    indicator.parameters:addColor("HISTOGRAM1_color", "The histogram Up color", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("HISTOGRAM2_color", "The histogram Down color", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addInteger("width", "Signal Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Signal Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);	

  indicator.parameters:addInteger("Hwidth", "Histogram Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("Hstyle", "Histogram Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Hstyle", core.FLAG_LINE_STYLE);		
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
function Prepare()
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
    source = instance.source;

    -- Check parameters
    if (LN <= SN) then
       error("The short EMA period must be smaller than long EMA period");
    end

    -- Create short and long EMAs for the source
    EMAS = core.indicators:create("EMA", source, SN);
    EMAL = core.indicators:create("EMA", source, LN);

    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. SN .. ", " .. LN .. ", " .. IN .. ")";
    instance:name(name);

    -- Create the output stream for the MACD. The first period is equal to the
    -- biggest first period of source EMA streams
    firstPeriodMACD = EMAL.DATA:first();


    HISTOGRAM = instance:addStream("Histogram", core.Line, name .. ".Histogram", "Histogram", instance.parameters.HISTOGRAM_color, firstPeriodMACD);
    HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));
	HISTOGRAM:setWidth(instance.parameters.Hwidth);
    HISTOGRAM:setStyle(instance.parameters.Hstyle);
    -- Create MVA for the MACD output stream.
    MVAI = core.indicators:create("MVA", HISTOGRAM, IN);
    firstPeriodSIGNAL = MVAI.DATA:first();
    -- Create output for the signal and histogram
    firstPeriodSIGNAL = MVAI.DATA:first();
 --  HISTOGRAM1 = instance:addStream("Lines1", core.Bar, name .. ".H1", "H1", instance.parameters.HISTOGRAM1_color, firstPeriodSIGNAL);
    HISTOGRAM1:setPrecision(math.max(2, instance.source:getPrecision()));
  -- HISTOGRAM2 = instance:addStream("Lines2", core.Bar, name .. ".H2", "H2", instance.parameters.HISTOGRAM2_color, firstPeriodSIGNAL);   
    HISTOGRAM2:setPrecision(math.max(2, instance.source:getPrecision()));
  --  instance:createFromToBarGroup("HISTOGRAM", "", HISTOGRAM1, HISTOGRAM2, core.rgb(0, 0, 0));
	
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
	
	-- HISTOGRAM1[period] =  HISTOGRAM[period];
--	  HISTOGRAM2[period] =  HISTOGRAM[period];

    -- update MVA on the MACD
    MVAI:update(mode);
    if (period >= firstPeriodSIGNAL) then
        SIGNAL[period] = MVAI.DATA[period];
        if HISTOGRAM[period] > 0 and HISTOGRAM[period] > SIGNAL[period] then		
		--  HISTOGRAM1:setColor(period, instance.parameters.HISTOGRAM1_color);
		 -- HISTOGRAM2:setColor(period, instance.parameters.HISTOGRAM1_color);
          HISTOGRAM:setColor(period, instance.parameters.HISTOGRAM1_color);
        elseif HISTOGRAM[period] < 0 and HISTOGRAM[period] < SIGNAL[period] then
		-- HISTOGRAM1:setColor(period, instance.parameters.HISTOGRAM2_color);	  
       --  HISTOGRAM2:setColor(period, instance.parameters.HISTOGRAM2_color);			 
          HISTOGRAM:setColor(period, instance.parameters.HISTOGRAM2_color);
        end
    end
end


