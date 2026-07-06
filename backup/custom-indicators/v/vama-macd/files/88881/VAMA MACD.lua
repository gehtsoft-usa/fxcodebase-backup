-- Id: 9798
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59293

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
    indicator:name("VAMA Moving Average Convergence/Divergence");
    indicator:description("A trend-following momentum indicator that shows the relationship between two moving averages of prices.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Selection"); 
	indicator.parameters:addBoolean("H", "Histogram On", "", true);
	indicator.parameters:addBoolean("M", "Macd On", "", true);
	indicator.parameters:addBoolean("S", "Signal On", "", true);
    
	indicator.parameters:addGroup("Calculation"); 	
    indicator.parameters:addInteger("SN", "Short VAMA", "The period of the short VAMA.", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long VAMA", "The period of the long VAMAMA.", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal line", "The number of periods for the signal line.", 9, 2, 1000);
	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	
			
	indicator.parameters:addGroup("Style"); 
	indicator.parameters:addColor("MACD_color", "MACD color", "The color of MACD.", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("SIGNAL_color", "Signal color", "The color of SIGNAL.", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("UP", "Up Histogram  in Up Trend", "The color of Up Histogram.", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UPDOWN", "Down Histogram in Up Trend", "The color of Up Histogram.", core.rgb(0, 200, 0));
	
	indicator.parameters:addColor("DOWNUP", "Up Histogram in Down Trend", "The color of Down Histogram.", core.rgb(255, 0, 0));
	indicator.parameters:addColor("DOWN", "Down Histogram in Down Trend", "The color of Down Histogram.", core.rgb(200, 0, 0));
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
local Price;
local firstPeriodMACD;

local firstPeriodSIGNAL;
local source = nil;

-- Streams block
local MACD = nil;
local SIGNALOUT = nil;
local SIGNAL=nil;
local HISTOGRAM=nil;
local OUT;
local PriceTimesVolume;
local SignalTimesVolume;
-- Routine
function Prepare(nameOnly)
   Price = instance.parameters.Price;
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
	M = instance.parameters.M;
    H = instance.parameters.H;
	S = instance.parameters.S;
    source = instance.source;

    -- Check parameters
    if (LN <= SN) then
       error("The short MA period must be smaller than long MA period");
    end

    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. SN .. ", " .. LN .. ", " .. IN .. ", " .. Price.. ")";
	instance:name(name);
	if nameOnly then
		return;
	end

	PriceTimesVolume = instance:addInternalStream(0,0);
	
	MACD = instance:addInternalStream(0,0); 
	SIGNAL = instance:addInternalStream(0,0); 
	
	SignalTimesVolume = instance:addInternalStream(0,0); 
    -- Create the output stream for the MACD. The first period is equal to the
    -- biggest first period of source EMA streams
    firstPeriodMACD = math.max(SN,LN);
    OUT = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACD_color, firstPeriodMACD);
    OUT:setPrecision(math.max(2, instance.source:getPrecision()));
	OUT:setWidth(instance.parameters.width1);
    OUT:setStyle(instance.parameters.style1);

    -- Create MVA for the MACD output stream.
    
    -- Create output for the signal and histogram
    firstPeriodSIGNAL = firstPeriodMACD+IN;

    SIGNALOUT = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_color, firstPeriodSIGNAL);
    SIGNALOUT:setPrecision(math.max(2, instance.source:getPrecision()));
	SIGNALOUT:setWidth(instance.parameters.width2);
    SIGNALOUT:setStyle(instance.parameters.style2);
    HISTOGRAM = instance:addStream("HISTOGRAM", core.Bar, name .. "HISTOGRAM", "HISTOGRAM", instance.parameters.UP, firstPeriodSIGNAL);
    HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));
	
end

-- Indicator calculation routine
function Update(period, mode)
  
    PriceTimesVolume[period]=source[Price][period] *source.volume[period];
    
    
	
				if (period < firstPeriodMACD) then
				return;
				end
				
	local EMAS=mathex.sum(PriceTimesVolume, period -SN+1, period)/mathex.sum(source.volume, period -SN+1, period);
	local EMAL=mathex.sum(PriceTimesVolume, period -LN+1, period)/mathex.sum(source.volume, period -LN+1, period);
	
					-- calculate MACD output
					MACD[period] = EMAS - EMAL;
				
					if (M) then
					OUT[period]=MACD[period];		
					end 
	SignalTimesVolume[period]=	MACD[period] *source.volume[period];

				-- update MVA on the MACD
				
				if (period < firstPeriodSIGNAL) then
				return;
				end
				
	local MVAI=mathex.sum(SignalTimesVolume, period -IN+1, period)/mathex.sum(source.volume, period -IN+1, period);		
	
	
					SIGNAL[period] = MVAI; 
					
					if (S) then 
					SIGNALOUT[period] = SIGNAL[period];
					end
					-- calculate histogram as a difference between MACD and signal
					if (H) then
					HISTOGRAM[period] = MACD[period] - SIGNAL[period];
					
						 if HISTOGRAM[period] > 0 then
							  if HISTOGRAM[period] > HISTOGRAM[period-1] then
							  HISTOGRAM:setColor(period, instance.parameters.UP);
							  else
							   HISTOGRAM:setColor(period, instance.parameters.UPDOWN);
							  end
						 else
						     if HISTOGRAM[period] < HISTOGRAM[period-1] then
							  HISTOGRAM:setColor(period, instance.parameters.DOWN);
							  else
							   HISTOGRAM:setColor(period, instance.parameters.DOWNUP);
							  end
						 end
					
					end
			
	
end


