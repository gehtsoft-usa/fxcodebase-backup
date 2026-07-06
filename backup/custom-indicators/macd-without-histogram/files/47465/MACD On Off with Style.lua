-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1050
-- Id: 7993

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- The indicator corresponds to the MACD indicator in MetaTrader.
-- The formula is described in the Kaufman "Trading Systems and Methods" chapter 6 "Momentum and Oscillators" (page 128-130)


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Moving Average Convergence/Divergence");
    indicator:description("A trend-following momentum indicator that shows the relationship between two moving averages of prices.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Selection"); 
	indicator.parameters:addBoolean("H", "Histogram On", "", true);
	indicator.parameters:addBoolean("M", "Macd On", "", true);
	indicator.parameters:addBoolean("S", "Signal On", "", true);
    
	indicator.parameters:addGroup("Calculation"); 	
    indicator.parameters:addInteger("SN", "Short EMA", "The period of the short EMA.", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long EMA", "The period of the long EMA.", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal line", "The number of periods for the signal line.", 9, 2, 1000);
			
	indicator.parameters:addGroup("MACD Style"); 
	indicator.parameters:addColor("MACD_UP", "Up MACD color", "The color of MACD.", core.rgb(255, 0, 0));
	indicator.parameters:addColor("MACD_DN", "Down MACD color", "The color of MACD.", core.rgb(255, 0, 0));
	
	indicator.parameters:addInteger( "MACDType", "MACD Line Type", "", core.Line );
    indicator.parameters:addIntegerAlternative("MACDType", "Line", "", core.Line);
    indicator.parameters:addIntegerAlternative("MACDType", "Bar", "", core.Bar);
	indicator.parameters:addIntegerAlternative("MACDType", "Dot", "", core.Dot);
	
	indicator.parameters:addInteger("MACDwidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("MACDstyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("MACDstyle", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("Signal Style"); 
    indicator.parameters:addColor("SIGNAL_UP", "Up Signal color", "The color of SIGNAL.", core.rgb(0, 0, 255));
	indicator.parameters:addColor("SIGNAL_DN", "Down Signal color", "The color of SIGNAL.", core.rgb(0, 0, 255));
	
	indicator.parameters:addInteger( "SIGNALType", "Signal Line Type", "", core.Line );
    indicator.parameters:addIntegerAlternative("SIGNALType", "Line", "", core.Line);
    indicator.parameters:addIntegerAlternative("SIGNALType", "Bar", "", core.Bar);
	indicator.parameters:addIntegerAlternative("SIGNALType", "Dot", "", core.Dot);
	
	indicator.parameters:addInteger("SIGNALwidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("SIGNALstyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("SIGNALstyle", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("Histogram Style"); 
	indicator.parameters:addColor("HISTOGRAM_UP", "Up Histogram color", "The color of Up Histogram.", core.rgb(0, 255, 0));
	indicator.parameters:addColor("HISTOGRAM_DN", "Down Histogram color", "The color of Down Histogram.", core.rgb(255, 0, 0));
	indicator.parameters:addInteger( "HISTOGRAMType", "Histogram Line Type", "", core.Bar );
    indicator.parameters:addIntegerAlternative("HISTOGRAMType", "Line", "", core.Line);
    indicator.parameters:addIntegerAlternative("HISTOGRAMType", "Bar", "", core.Bar);
	indicator.parameters:addIntegerAlternative("HISTOGRAMType", "Dot", "", core.Dot);
	
	indicator.parameters:addInteger("HISTOGRAMwidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("HISTOGRAMstyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("HISTOGRAMstyle", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local SN;
local LN;
local IN;
local M;
local H;
local S;

local firstPeriodMACD;

local firstPeriodSIGNAL;
local source = nil;

local EMAS = nil;
local EMAL = nil;
local MVAI = nil;

-- Streams block
local MACD = nil;
local SIGNALOUT = nil;
local SIGNAL=nil;
local HISTOGRAM=nil;
local OUT;


local MACDType;
local SIGNALType;
local HISTOGRAMType;

-- Routine
function Prepare(nameOnly)
   
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
	M = instance.parameters.M;
    H = instance.parameters.H;
	S = instance.parameters.S;
    source = instance.source;
	
	  MACDType = instance.parameters.MACDType;
     SIGNALType = instance.parameters.SIGNALType;
     HISTOGRAMType = instance.parameters.HISTOGRAMType;

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
	
	MACD = instance:addInternalStream(0,0); 
	SIGNAL = instance:addInternalStream(0,0); 

    -- Create the output stream for the MACD. The first period is equal to the
    -- biggest first period of source EMA streams
    firstPeriodMACD = EMAL.DATA:first();
    OUT = instance:addStream("MACD", MACDType, name .. ".MACD", "MACD", instance.parameters.MACD_UP, firstPeriodMACD);
    OUT:setPrecision(math.max(2, instance.source:getPrecision()));
	if MACDType== core.Line then
	OUT:setWidth(instance.parameters.MACDwidth);
    OUT:setStyle(instance.parameters.MACDstyle);
	end

    -- Create MVA for the MACD output stream.
    MVAI = core.indicators:create("MVA", MACD, IN);
    -- Create output for the signal and histogram
    firstPeriodSIGNAL = MVAI.DATA:first();

    SIGNALOUT = instance:addStream("SIGNAL", SIGNALType, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_UP, firstPeriodSIGNAL);
    SIGNALOUT:setPrecision(math.max(2, instance.source:getPrecision()));
	if SIGNALType== core.Line then
	SIGNALOUT:setWidth(instance.parameters.SIGNALwidth);
    SIGNALOUT:setStyle(instance.parameters.SIGNALstyle);
	end
    HISTOGRAM = instance:addStream("HISTOGRAM", HISTOGRAMType, name .. "HISTOGRAM", "HISTOGRAM", instance.parameters.HISTOGRAM_UP, firstPeriodSIGNAL);
    HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));
	if HISTOGRAMType== core.Line then
	HISTOGRAM:setWidth(instance.parameters.HISTOGRAMwidth);	
    HISTOGRAM:setStyle(instance.parameters.HISTOGRAMstyle);
	end
	
end

-- Indicator calculation routine
function Update(period, mode)
    -- and update short and long EMAs for the source.
    EMAS:update(mode);
    EMAL:update(mode);

				if (period >= firstPeriodMACD) then
					-- calculate MACD output
					MACD[period] = EMAS.DATA[period] - EMAL.DATA[period];
				
					if (M) then
					OUT[period]=MACD[period];	
                        if OUT[period] > OUT[period-1] then
						  OUT:setColor(period, instance.parameters.MACD_UP);
						 else
						  OUT:setColor(period, instance.parameters.MACD_DN);
						 end 
					
					end 
				end

				-- update MVA on the MACD
				MVAI:update(mode);
				if (period >= firstPeriodSIGNAL) then
					SIGNAL[period] = MVAI.DATA[period]; 
					if (S) then 
					SIGNALOUT[period] = SIGNAL[period];	

					    if SIGNALOUT[period] > SIGNALOUT[period-1] then
						  SIGNALOUT:setColor(period, instance.parameters.SIGNAL_UP);
						 else
						  SIGNALOUT:setColor(period, instance.parameters.SIGNAL_DN);
						 end 
					end
					-- calculate histogram as a difference between MACD and signal
					if (H) then
					HISTOGRAM[period] = MACD[period] - SIGNAL[period];
					
						 if HISTOGRAM[period] > HISTOGRAM[period-1] then
						  HISTOGRAM:setColor(period, instance.parameters.HISTOGRAM_UP);
						 else
						   HISTOGRAM:setColor(period, instance.parameters.HISTOGRAM_DN);
						 end
					
					end
				end
	
end


