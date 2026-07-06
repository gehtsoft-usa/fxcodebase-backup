-- Id: 5792
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

-- MACD
-- Moving Average Convergence/Divergence
-- MACD uses moving averages, which are lagging indicators, to include
-- some trend-following characteristics. These lagging indicators are
-- turned into a momentum oscillator by subtracting the longer moving
-- average from the shorter moving average. The resulting plot forms a
-- line that oscillates above and below zero, without any upper or lower
-- limits.
-- The MACD produces three lines: MACD, SIGNAL and HISTOGRAM.
-- The classic formulae is:
-- MACD = EMA(price; 12) - EMA(price; 26)
-- SIGNAL = EMA(MACD; 9)
-- HISTOGRAM = MACD - SIGNAL

-- NOTE: **************************************************************************************************
-- NOTE: THIS VERSION OF THE INDICATOR HAS ADDITIONAL COLORING TO UNDERLINE HISTOGRAM UP AND DOWN MOVEMENTS
-- NOTE: **************************************************************************************************

-- The indicator corresponds to the MACD indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 6 "Momentum and Oscillators" (page 128-130)

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters

function Init()
    indicator:name("MACD1");
    indicator:description("Same as MACD indicator only with histogram movement coloring.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
   indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SN", "Short EMA", "(SN)No Description", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long EMA", "(LN)No Description", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal Line", "(IN)No Description", 9, 2, 1000);
	
	
	indicator.parameters:addDouble("Multiplier", "Histo Multiplier", "", 1);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MACD_Up", "MACD Up color", "(MACD Color)", core.rgb(255, 0, 0));
	indicator.parameters:addColor("MACD_Dn", "MACD Down color", "(MACD Color)", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("MACD_width", "MACD Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("MACD_style", "MACD Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("MACD_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("SIGNAL_Up", "Signal Up color", "(Signal Color) ", core.rgb(0, 0, 255));
	indicator.parameters:addColor("SIGNAL_Dn", "Signal Down color", "(Signal Color) ", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("SIGNAL_width", "SIGNAL Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("SIGNAL_style", "SIGNAL Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("SIGNAL_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("HISTOGRAM_color", "Up Histogram", "Up Histogram", core.rgb(0, 255, 0));
    indicator.parameters:addColor("HISTOGRAM2_color", "Down Histogram", "Down Histogram", core.rgb(255, 0, 0));
	
	indicator.parameters:addGroup("Levels");	
    indicator.parameters:addDouble("overbought", "1. Level","", 0.00015);
    indicator.parameters:addDouble("oversold","2. Level","", -0.00015);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
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

local INHIST = nil;

-- Streams block
local MACD = nil;
local SIGNAL = nil;
local HISTOGRAM = nil;
local HISTOGRAM2 = nil;
local Multiplier;
-- Routine
function Prepare()
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
    source = instance.source;
	
	
	Multiplier = instance.parameters.Multiplier;

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
	
	
	HISTOGRAM = instance:addStream( "HISTOGRAM", core.Bar, name .. ".HISTOGRAM", "HISTOGRAM", instance.parameters.HISTOGRAM_color, firstPeriodMACD +  IN);
    HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));
	
    MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACD_Up, firstPeriodMACD);
    MACD:setPrecision(math.max(2, instance.source:getPrecision()));
	MACD:setWidth(instance.parameters.MACD_width);
    MACD:setStyle(instance.parameters.MACD_style);
	
    MACD:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	MACD:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		


    -- Create MVA for the MACD output stream.
    MVAI = core.indicators:create("MVA", MACD, IN);
    
    -- Create output for the signal and histogram
    firstPeriodSIGNAL = MVAI.DATA:first();
    SIGNAL = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_Up, firstPeriodSIGNAL);
    SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
	SIGNAL:setWidth(instance.parameters.SIGNAL_width);
    SIGNAL:setStyle(instance.parameters.SIGNAL_style);
    
  
    INHIST = instance:addInternalStream(firstPeriodSIGNAL);
end

-- Indicator calculation routine
function Update(period, mode)
    -- and update short and long EMAs for the source.
    EMAS:update(mode);
    EMAL:update(mode);

    if (period >= firstPeriodMACD) then
        -- calculate MACD output
         MACD[period] = EMAS.DATA[period] - EMAL.DATA[period];
		 
		  if( MACD[period] > MACD[period - 1]) then
		   MACD:setColor(period, instance.parameters.MACD_Up);  
		  else		
           MACD:setColor(period, instance.parameters.MACD_Dn);  		  
		  end
    end

    -- update MVA on the MACD
    MVAI:update(mode);
    
    if (period >= firstPeriodSIGNAL) then
        SIGNAL[period] = MVAI.DATA[period];
		
		 if( SIGNAL[period] > SIGNAL[period - 1]) then
		   SIGNAL:setColor(period, instance.parameters.SIGNAL_Up);  
		  else		
           SIGNAL:setColor(period, instance.parameters.SIGNAL_Dn);  		  
		  end
        -- calculate histogram as a difference between MACD and signal
        local diff = MACD[period] - SIGNAL[period];
        INHIST[period] = MACD[period] - SIGNAL[period];
        
        if(period >= firstPeriodSIGNAL + 2) then
		
		 HISTOGRAM[period] = (MACD[period] - SIGNAL[period])*Multiplier;
		 
            if( INHIST[period] > INHIST[period - 1]) then
             HISTOGRAM:setColor(period, instance.parameters.HISTOGRAM_color);  
            else
              HISTOGRAM:setColor(period, instance.parameters.HISTOGRAM2_color);  
            end
        end        
    end
    
end






