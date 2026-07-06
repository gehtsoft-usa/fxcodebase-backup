-- Id: 16552

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63771

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
function Init()
    indicator:name("Customizable MACD");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SN", "Short MA Period", "", 12 );
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
	indicator.parameters:addStringAlternative("Method1", "DEMA", "DEMA" , "DEMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
    indicator.parameters:addInteger("LN", "Long MA Period", "", 26 );
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
	indicator.parameters:addStringAlternative("Method2", "DEMA", "DEMA" , "DEMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	
    indicator.parameters:addInteger("IN", "Signal Line Period", "", 9 );
	indicator.parameters:addString("Method3", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
	indicator.parameters:addStringAlternative("Method3", "DEMA", "DEMA" , "DEMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("Style");
	 indicator.parameters:addColor("MACD_color", "MACD line color", "", core.rgb(255, 127, 0));
    indicator.parameters:addColor("SIGNAL_color", "Signal line color", "", core.rgb(127, 255, 0));
    indicator.parameters:addColor("HISTOGRAM_color", "Histogramm color", "", core.rgb(127, 127, 127)); 
	
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

local MAS = nil;
local MAL = nil;
local MAI = nil;

-- Streams block
local MACD = nil;
local SIGNAL = nil;
local HISTOGRAM = nil;

local Method1;
local Method2;
local Method3;

-- Routine
function Prepare(nameOnly)  
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
	Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
	Method3 = instance.parameters.Method3;
	
	
	assert(core.indicators:findIndicator(Method1) ~= nil, "Please, download and install ".. Method1 .. " indicator");
	assert(core.indicators:findIndicator(Method2) ~= nil, "Please, download and install ".. Method2 .. " indicator");
	assert(core.indicators:findIndicator(Method3) ~= nil, "Please, download and install ".. Method3 .." indicator");
	
    source = instance.source;
	
	
	-- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. SN .. ", " .. Method1 .. ", " .. LN .. ", " .. Method2 .. ", " .. IN .. ", " .. Method3.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	

    -- Check parameters
    if (LN <= SN) then
       error("The short MA period must be smaller than long MA period");
    end

    -- Create short and long EMAs for the source
    MAS = core.indicators:create(Method1, source, SN);
    MAL = core.indicators:create(Method2, source, LN);

    

    -- Create the output stream for the MACD. The first period is equal to the
    -- biggest first period of source EMA streams
    firstPeriodMACD = MAL.DATA:first();
	MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACD_color, firstPeriodMACD);
	MACD:setWidth(instance.parameters.width);
    MACD:setStyle(instance.parameters.style);
	 
	
    HISTOGRAM = instance:addStream("H", core.Bar, name .. ".H", "H", instance.parameters.HISTOGRAM_color, firstPeriodMACD);
    -- Create MVA for the MACD output stream.
    MAI = core.indicators:create(Method3, MACD, IN);
    firstPeriodSIGNAL = MAI.DATA:first();
    -- Create output for the signal and histogram
    firstPeriodSIGNAL = MAI.DATA:first();
    
    SIGNAL = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_color, firstPeriodSIGNAL);
	SIGNAL:setWidth(instance.parameters.width);
    SIGNAL:setStyle(instance.parameters.style);
	
	MACD:setPrecision(math.max(2, instance.source:getPrecision()));
	HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));
	SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
function Update(period, mode)
    -- and update short and long EMAs for the source.
    MAS:update(mode);
    MAL:update(mode);

    if (period >= firstPeriodMACD) then
        -- calculate MACD output		
		 MACD[period] = MAS.DATA[period] - MAL.DATA[period];
          
    end

    -- update MVA on the MACD
    MAI:update(mode);
    if (period >= firstPeriodSIGNAL) then
        SIGNAL[period] = MAI.DATA[period];         
		HISTOGRAM[period]=  MACD[period]-  SIGNAL[period];
		
    end
end


