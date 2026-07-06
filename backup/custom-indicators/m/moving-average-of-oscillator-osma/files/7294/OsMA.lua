-- Id: 2817
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1856

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Moving Average of Oscillator");
    indicator:description("Difference between the Moving Average Convergence/Divergence and the signal line.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 

    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Method", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
    indicator.parameters:addInteger("SN", "Short EMA", "The period of the short EMA", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long EMA", "The period of the Long EMA", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal line", "The number of periods for the signal line.", 9, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("OsMAUPPositiv", "Color of Positiv UP OsMA", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("OsMAUPNegativ", "Color of Negativ UP OsMA", "", core.rgb(0, 255, 0));	
	indicator.parameters:addColor("OsMADOWNPositiv", "Color of Positiv DOWN OsMA", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("OsMADOWNNegativ", "Color of Negativ DOWN OsMA", "", core.rgb(255, 0, 0));
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local SN;
local LN;
local IN;
 
local Method;
local firstPeriodMACD;

local firstPeriodSIGNAL;
local source = nil;

local EMAS = nil;
local EMAL = nil;
local MVAI = nil;

-- Streams block
local MACD = nil; 
local OsMA = nil;


-- Routine
 function Prepare(nameOnly)    
    Method = instance.parameters.Method;
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
    source = instance.source;
	
	-- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. SN .. ", " .. LN .. ", " .. IN.. ", " .. Method .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    -- Check parameters
    if (LN <= SN) then
       error("The short EMA period must be smaller than long EMA period");
    end

    -- Create short and long EMAs for the source
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    EMAS = core.indicators:create(Method, source, SN);
    EMAL = core.indicators:create(Method, source, LN);

    

    -- Create the output stream for the MACD. The first period is equal to the
    -- biggest first period of source EMA streams
    firstPeriodMACD = EMAL.DATA:first();
    MACD = instance:addInternalStream(0, 0);

    -- Create MVA for the MACD output stream.
    MVAI = core.indicators:create(Method, MACD, IN);

	
    firstPeriodSIGNAL = MVAI.DATA:first();
    SIGNAL=instance:addInternalStream(0, 0);
	
	 
	OsMA = instance:addStream("OsMA", core.Bar, name .. ".OsMA", "OsMA",  core.rgb(128, 128, 128), firstPeriodSIGNAL);
    OsMA:setPrecision(math.max(2, instance.source:getPrecision()));
	
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
       
        OsMA[period] = MACD[period] - SIGNAL[period];
		
	 
		
			if OsMA[period] > OsMA[period-1]  and OsMA[period] > 0 then			
            OsMA:setColor(period, instance.parameters.OsMAUPPositiv);				
			elseif OsMA[period] > OsMA[period-1]  and OsMA[period] < 0 then
			 OsMA:setColor(period, instance.parameters.OsMAUPNegativ);	
			elseif OsMA[period] < OsMA[period-1]  and OsMA[period] > 0 then		
            OsMA:setColor(period, instance.parameters.OsMADOWNPositiv);				
			elseif OsMA[period] < OsMA[period-1]  and OsMA[period] < 0 then
			 OsMA:setColor(period, instance.parameters.OsMADOWNNegativ);					
			end
		 
    end
end