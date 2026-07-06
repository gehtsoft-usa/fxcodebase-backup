-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65694

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
    indicator:name("Anas MACD with MVA");
    indicator:description("Anas MACD with MVA");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SN", "fast moving avarag", "fast moving avarag", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "slow moving avarag", "slow moving avarag", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "signal period", "signal period", 9, 2, 1000);
    
    indicator.parameters:addString("Method", "type of moving avarage", "type of moving avarage","MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
    
    
indicator.parameters:addGroup("Style");
    
indicator.parameters:addColor("MACD_color","MACD color","MACD color",core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthMACD","MACD width ","MACD width", 1, 1, 5);
    indicator.parameters:addInteger("styleMACD", "MACD style","MACD style",core.LINE_SOLID);
    indicator.parameters:setFlag("styleMACD", core.FLAG_LEVEL_STYLE);
    
    indicator.parameters:addColor("SIGNAL_color", "SIGNAL color","SIGNAL_color",core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthSIGNAL","signal width","signal width", 1, 1, 5);
    indicator.parameters:addInteger("styleSIGNAL","signal style","signal style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSIGNAL", core.FLAG_LEVEL_STYLE);
    
    indicator.parameters:addColor("HISTOGRAM_color", "HISTOGRAM color","HISTOGRAM color",core.rgb(255, 128, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local SN;
local LN;
local IN;
local ME;
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
    ME = instance.parameters.Method;
    
    source = instance.source;
	
	
	
    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. ME .. " , " .. SN .. ", " .. LN .. ", " .. IN .. ")";
    instance:name(name); 

	if   (nameOnly) then
        return;
    end


    -- Check parameters
    if (LN <= SN) then
       error("The short EMA period must be smaller than long EMA period");
    end

    -- Create short and long EMAs for the source
    if ME=="EMA" then 
    EMAS = core.indicators:create("EMA", source, SN);
    EMAL = core.indicators:create("EMA", source, LN);
    else 
    EMAS = core.indicators:create("MVA", source, SN);
    EMAL = core.indicators:create("MVA", source, LN);
    end 

    local precision = math.max(2, source:getPrecision());
    
    -- Create the output stream for the MACD. The first period is equal to the
    -- biggest first period of source EMA streams
    firstPeriodMACD = EMAL.DATA:first();
    MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACD_color, firstPeriodMACD);
    MACD:setWidth(instance.parameters.widthMACD);
    MACD:setStyle(instance.parameters.styleMACD);
    MACD:setPrecision(precision);

    -- Create MVA for the MACD output stream.
    MVAI = core.indicators:create("MVA", MACD, IN);
    -- Create output for the signal and histogram
    firstPeriodSIGNAL = MVAI.DATA:first();

    SIGNAL = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_color, firstPeriodSIGNAL);
    SIGNAL:setWidth(instance.parameters.widthSIGNAL);
    SIGNAL:setStyle(instance.parameters.styleSIGNAL);
    SIGNAL:setPrecision(precision);
    HISTOGRAM = instance:addStream("HISTOGRAM", core.Bar, name .. ".HISTOGRAM", "HISTOGRAM", instance.parameters.HISTOGRAM_color, firstPeriodSIGNAL);
    HISTOGRAM:setPrecision(precision);

   

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
    end
end

