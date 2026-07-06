-- Id: 6855
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=19841

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
    indicator:name("Adaptable Moving Average Convergence/Divergence");
    indicator:description("A trend-following momentum indicator that shows the relationship between two moving averages of prices.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
    
	indicator.parameters:addGroup("Calculation"); 	
    indicator.parameters:addInteger("SN1", "Forward Short AMA Period", "The period of the short AMA.", 6, 2, 1000);
    indicator.parameters:addInteger("LN1", "Forward Long AMA Period", "The period of the long AMA.", 13, 2, 1000);
    indicator.parameters:addInteger("IN1", "Forward Signal line Period", "The number of periods for the signal line.", 5, 2, 1000);
	
	 indicator.parameters:addInteger("SN2", "Backward Short AMA Period", "The period of the short AMA.", 6, 2, 1000);
    indicator.parameters:addInteger("LN2", "Backward Long AMA Period", "The period of the long AMA.", 13, 2, 1000);
    indicator.parameters:addInteger("IN2", "Backward Signal line Period", "The number of periods for the signal line.", 5, 2, 1000);
	
	
	indicator.parameters:addGroup("Style"); 
	indicator.parameters:addColor("MACD_color", "MACD color", "The color of MACD.", core.rgb(255, 0, 0));
    indicator.parameters:addColor("SIGNAL_color", "Signal color", "The color of SIGNAL.", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Up_color", "Up Histogram color", "The color of Up Histogram.", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn_color", "Down Histogram color", "The color of Down Histogram.", core.rgb(255, 0, 0));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local SN1;
local LN1;
local IN1;

local SN2;
local LN2;
local IN2;

local firstPeriodMACD;

local firstPeriodSIGNAL;
local source = nil;

local EMAS = nil;
local EMAL = nil;
local MVAI = nil;

-- Streams block
local MACD = nil;
local SIGNAL=nil;
local HISTOGRAM=nil;


local Method1,Method2, Method3;

-- Routine
function Prepare(nameOnly)   
    
    SN1 = instance.parameters.SN1;
    LN1 = instance.parameters.LN1;
    IN1 = instance.parameters.IN1;
	
	SN2 = instance.parameters.SN2;
    LN2 = instance.parameters.LN2;
    IN2 = instance.parameters.IN2;
	
	
    source = instance.source;

    -- Check parameters
    if (LN1 <= SN1) then
       error("The short AMA period must be smaller than long AMA period");
    end
	
	assert(core.indicators:findIndicator("AMA") ~= nil, "Please, download and install AMA.bin indicator");

    local name;
	name = profile:id() .. "(" .. source:name() .. ", " .. SN1 .. ", " .. SN2 .. ", " .. LN1  .. ", " .. LN2.. ", " .. IN1 .. ", " .. IN2..")";
    instance:name(name);
    if nameOnly then
        return;
    end
    EMAS = core.indicators:create("AMA", source,  SN1,SN1);
    EMAL = core.indicators:create("AMA", source, LN1,LN2);

    -- Create the output stream for the MACD. The first period is equal to the
    -- biggest first period of source EMA streams
    firstPeriodMACD = EMAL.DATA:first();	
	
	
	
	MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACD_color, firstPeriodMACD);
		
    -- Create MVA for the MACD output stream.	
	
	MVAI = core.indicators:create("AMA", MACD, IN1, IN2);
	-- Create output for the signal and histogram
    firstPeriodSIGNAL = MVAI.DATA:first();
	
	SIGNAL = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_color, firstPeriodSIGNAL);
	HISTOGRAM = instance:addStream("HISTOGRAM", core.Bar, name .. "HISTOGRAM", "HISTOGRAM", instance.parameters.Up_color, firstPeriodSIGNAL);
	
	MACD:setPrecision(math.max(2, instance.source:getPrecision()));
	SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
	HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));
	
end

-- Indicator calculation routine
function Update(period, mode)
    -- and update short and long EMAs for the source.
    EMAS:update(mode);
    EMAL:update(mode);
	
	
				if (period >= firstPeriodMACD) then
					-- calculate MACD output
					MACD[period] = EMAS.DATA[period] - EMAL.DATA[period];				
					
				end

				-- update MVA on the MACD
				MVAI:update(mode);
				if (period >= firstPeriodSIGNAL) then
					SIGNAL[period] = MVAI.DATA[period]; 
					
					-- calculate histogram as a difference between MACD and signal
					
					HISTOGRAM[period] = MACD[period] - SIGNAL[period];
					
						 if HISTOGRAM[period] > HISTOGRAM[period-1] then
						  HISTOGRAM:setColor(period, instance.parameters.Up_color);
						 else
						   HISTOGRAM:setColor(period, instance.parameters.Dn_color);
						 end
					
					
				end
	
end


