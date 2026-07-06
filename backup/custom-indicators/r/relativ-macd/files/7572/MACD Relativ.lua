-- Id: 2929
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3203

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
	
	indicator.parameters:addGroup("Type"); 
    indicator.parameters:addString("Type", "Method", "" , "Absolute");
    indicator.parameters:addStringAlternative("Type", "Absolute", "" , "Absolute");
    indicator.parameters:addStringAlternative("Type", "Relativ", "Relativ" , "Relativ");
	
	
	indicator.parameters:addGroup("Style"); 
	indicator.parameters:addColor("MACD_color", "MACD color", "The color of MACD.", core.rgb(255, 0, 0));
    indicator.parameters:addColor("SIGNAL_color", "Signal color", "The color of SIGNAL.", core.rgb(0, 0, 255));
	indicator.parameters:addColor("UPHISTOGRAM_color", "Up Histogram color", "The color of Up Histogram.", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DOWNHISTOGRAM_color", "Down Histogram color", "The color of Down Histogram.", core.rgb(255, 0, 0));
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
local Type;

-- Routine
function Prepare(nameOnly)
    Type= instance.parameters.Type;
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
	M = instance.parameters.M;
    H = instance.parameters.H;
	S = instance.parameters.S;
    source = instance.source;

    -- Check parameters
    if (LN <= SN) then
       error("The short EMA period must be smaller than long EMA period");
	end
	
    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. SN .. ", " .. LN .. ", " .. IN .. ", ".. Type..")";
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
    OUT = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACD_color, firstPeriodMACD);
    OUT:setPrecision(math.max(2, instance.source:getPrecision()));

    -- Create MVA for the MACD output stream.
    MVAI = core.indicators:create("MVA", MACD, IN);
    -- Create output for the signal and histogram
    firstPeriodSIGNAL = MVAI.DATA:first();

    SIGNALOUT = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_color, firstPeriodSIGNAL);
    SIGNALOUT:setPrecision(math.max(2, instance.source:getPrecision()));
	if  Type == "Absolute" then
    HISTOGRAM = instance:addStream("HISTOGRAM", core.Bar, name .. "HISTOGRAM", "HISTOGRAM", instance.parameters.UPHISTOGRAM_color, firstPeriodSIGNAL);
    HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));
	end
end

-- Indicator calculation routine
function Update(period, mode)
    -- and update short and long EMAs for the source.
    EMAS:update(mode);
    EMAL:update(mode);
	
	if Type == "Absolute" then

				if (period >= firstPeriodMACD) then
					-- calculate MACD output
					MACD[period] = EMAS.DATA[period] - EMAL.DATA[period];
				
					if (M) then
					OUT[period]=MACD[period];		
					end 
				end

				-- update MVA on the MACD
				MVAI:update(mode);
				if (period >= firstPeriodSIGNAL) then
					SIGNAL[period] = MVAI.DATA[period]; 
					if (S) then 
					SIGNALOUT[period] = SIGNAL[period];
					end
					-- calculate histogram as a difference between MACD and signal
					if (H) then
					HISTOGRAM[period] = MACD[period] - SIGNAL[period];
					
						 if HISTOGRAM[period] > HISTOGRAM[period-1] then
						  HISTOGRAM:setColor(period, instance.parameters.UPHISTOGRAM_color);
						 else
						   HISTOGRAM:setColor(period, instance.parameters.DOWNHISTOGRAM_color);
						 end
					
					end
				end
	else			if (period >= firstPeriodMACD) then
					-- calculate MACD output
					MACD[period] = (EMAS.DATA[period] - EMAL.DATA[period])/ ( EMAL.DATA[period]/100);					
				
					if (M) then
					OUT[period]=MACD[period];		
					end 
				end

				-- update MVA on the MACD
				MVAI:update(mode);
				if (period >= firstPeriodSIGNAL) then
					SIGNAL[period] = MVAI.DATA[period]; 
					if (S) then 
					SIGNALOUT[period] = SIGNAL[period];
					end
				end	
	end
end


