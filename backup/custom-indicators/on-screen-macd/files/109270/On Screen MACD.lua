-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64150

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

-- The indicator corresponds to the MACD indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 6 "Momentum and Oscillators" (page 128-130)


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("On Screen MACD");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
 

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SN", "Short Period", "", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long Period","", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal Period", "", 9, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MACD_color","MACD Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthMACD", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleMACD", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleMACD", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("SIGNAL_color", "Signal Color", "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthSIGNAL", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleSIGNAL", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSIGNAL", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("HISTOGRAM_UpUp", "Up in Up Trend Histogram Color", "", core.rgb(255, 255, 0));
	indicator.parameters:addColor("HISTOGRAM_DownUp", "Down in Up Trend Histogram Color", "", core.rgb(255, 255, 0));
	indicator.parameters:addColor("HISTOGRAM_UpDown", "Up in Down Trend Histogram Color", "", core.rgb(0, 255, 255));
	indicator.parameters:addColor("HISTOGRAM_DownDown", "Down in Down Trend Histogram Color", "", core.rgb(0, 255, 255));
	indicator.parameters:addInteger("widthHISTOGRAM", "Line Width", "", 1, 1, 5);
	indicator.parameters:addInteger("styleHISTOGRAM", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleHISTOGRAM", core.FLAG_LEVEL_STYLE);
	
	
	 indicator.parameters:addColor("colorZero", "Zero Line Color", "", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("widthZero", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleZero", "Line Style", "", core.LINE_SOLID);
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

-- Streams block
local MACD = nil;
local SIGNAL = nil;
local HISTOGRAM = nil;
local Raw;
local Zero;

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


    local precision = math.max(2, source:getPrecision());
    
    -- Create the output stream for the MACD. The first period is equal to the
    -- biggest first period of source EMA streams
    firstPeriodMACD = EMAL.DATA:first();
    MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACD_color, firstPeriodMACD);
    MACD:setWidth(instance.parameters.widthMACD);
    MACD:setStyle(instance.parameters.styleMACD);
    MACD:setPrecision(precision);
	
	Raw = instance:addInternalStream(0, 0);

    -- Create MVA for the MACD output stream.
    MVAI = core.indicators:create("MVA", Raw, IN);
    -- Create output for the signal and histogram
    firstPeriodSIGNAL = MVAI.DATA:first();

    SIGNAL = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_color, firstPeriodSIGNAL);
    SIGNAL:setWidth(instance.parameters.widthSIGNAL);
    SIGNAL:setStyle(instance.parameters.styleSIGNAL);
    SIGNAL:setPrecision(precision);
    HISTOGRAM = instance:addStream("HISTOGRAM", core.Line, name .. ".HISTOGRAM", "HISTOGRAM", instance.parameters.HISTOGRAM_UpUp, firstPeriodSIGNAL);
    HISTOGRAM:setPrecision(precision);
	HISTOGRAM:setWidth(instance.parameters.widthHISTOGRAM);
    HISTOGRAM:setStyle(instance.parameters.styleHISTOGRAM);
	
	
	 
    Zero = instance:addStream("Zero", core.Line, name .. ".Zero", "Zero", instance.parameters.colorZero, firstPeriodMACD);
    Zero:setWidth(instance.parameters.widthZero);
    Zero:setStyle(instance.parameters.styleZero);
 

end
 
function Update(period, mode)
    -- and update short and long EMAs for the source.
    EMAS:update(mode);
    EMAL:update(mode);

    if (period >= firstPeriodMACD) then
        -- calculate MACD output
		 Raw[period] =   ( EMAS.DATA[period] - EMAL.DATA[period]);
         MACD[period] = EMAL.DATA[period] + ( EMAS.DATA[period] - EMAL.DATA[period]);
	     Zero[period] = EMAL.DATA[period];	 
    end
	
	 

    -- update MVA on the MACD
    MVAI:update(mode);
    if (period >= firstPeriodSIGNAL) then
        SIGNAL[period] =  EMAL.DATA[period] +MVAI.DATA[period];
        -- calculate histogram as a difference between MACD and signal
        HISTOGRAM[period] =  EMAL.DATA[period] +( MACD[period] - SIGNAL[period]);
		
		if  (( EMAS.DATA[period] - EMAL.DATA[period]) - MVAI.DATA[period]) > 0 then
		
		  if  (( EMAS.DATA[period] - EMAL.DATA[period]) - MVAI.DATA[period]) > (( EMAS.DATA[period-1] - EMAL.DATA[period-1]) -MVAI.DATA[period-1])   then
		  HISTOGRAM:setColor(period,instance.parameters.HISTOGRAM_UpUp);
		  else
		  HISTOGRAM:setColor(period,instance.parameters.HISTOGRAM_DownUp);
		  end		  
		else
		  if  (( EMAS.DATA[period] - EMAL.DATA[period]) - MVAI.DATA[period]) > (( EMAS.DATA[period-1] - EMAL.DATA[period-1]) -MVAI.DATA[period-1])   then
		  HISTOGRAM:setColor(period,instance.parameters.HISTOGRAM_UpDown);
		  else
		  HISTOGRAM:setColor(period,instance.parameters.HISTOGRAM_DownDown);
		  end
		end
		 
    end
end

 