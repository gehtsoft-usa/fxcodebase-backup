-- Id: 2502
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
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SN", "Short", "", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long", "", 26, 2, 1000);
    indicator.parameters:addInteger("IN", "Signal Line", "", 9, 2, 1000);
	
	indicator.parameters:addString("Method1", "MACD MA Type", "MA Type" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "HMA", "HMA" , "HMA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method1", "VAMA", "VAMA" , "VAMA");	
	
	
	indicator.parameters:addString("Method2", "MACD MA Type", "MA Type" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
	indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "HMA", "HMA" , "HMA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method2", "VAMA", "VAMA" , "VAMA");	
	
	indicator.parameters:addString("Type1", "Price Type", "", "C");
    indicator.parameters:addStringAlternative("Type1", "OPEN", "", "O");
    indicator.parameters:addStringAlternative("Type1", "HIGH", "", "H");
    indicator.parameters:addStringAlternative("Type1", "LOW", "", "L");
    indicator.parameters:addStringAlternative("Type1","CLOSE", "", "C");
    indicator.parameters:addStringAlternative("Type1", "MEDIAN", "", "M");
    indicator.parameters:addStringAlternative("Type1", "TYPICAL", "", "T");
    indicator.parameters:addStringAlternative("Type1", "WEIGHTED", "", "W");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("SIGNAL_color", "The signal line color", "", core.rgb(127, 255, 0));
    indicator.parameters:addColor("HISTOGRAM_color", "The histogramm color", "", core.rgb(127, 127, 127));
    indicator.parameters:addColor("HISTOGRAM1_color", "The histogramm color 1", "", core.rgb(0, 0, 255));
    indicator.parameters:addColor("HISTOGRAM2_color", "The histogramm color 2", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);	
end

-- Indicator instance initialization routine

-- Parameters block
local SN;
local LN;
local IN;

local Method1;
local Method2;
local Type1;

local firstPeriodMACD;
local firstPeriodSIGNAL;
local source;

local EMAS = nil;
local EMAL = nil;
local MVAI = nil;

-- Streams block
local MACD = nil;
local SIGNAL = nil;
local HISTOGRAM = nil;

-- Routine
function Prepare()
    Type1= instance.parameters.Type1;	
    Method1= instance.parameters.Method1;
	Method2= instance.parameters.Method2;
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
    source = instance.source;
	
	 assert(core.indicators:findIndicator(Method1) ~= nil, "Please, download and install "..Method1..  " indicator");
	 assert(core.indicators:findIndicator(Method2) ~= nil, "Please, download and install "..Method2..  " indicator");
	 
	local  P1; 
	 
	if Type1 == "O" then
        P1 = source.open;
    elseif Type1 == "H" then
        P1 = source.high;
    elseif Type1 == "L" then
        P1 = source.low;
    elseif Type1 == "M" then
        P1 = source.median;
    elseif Type1 == "T" then
        P1 = source.typical;
    elseif Type1 == "W" then
        P1 = source.weighted;
    else
        P1 = source.close;
    end

    -- Check parameters
    if (LN <= SN) then
       error("The short EMA period must be smaller than long EMA period");
    end

    -- Create short and long EMAs for the source
    if Method1 == "VAMA" then
    EMAS = core.indicators:create(Method1, source, SN);
    EMAL = core.indicators:create(Method1, source, LN);
	else
	EMAS = core.indicators:create(Method1, P1, SN);
    EMAL = core.indicators:create(Method1, P1, LN);
	end

    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. SN .. ", " .. LN .. ", " .. IN .. ", " .. Method1 ..  ", " .. Method2 .."," .. Type1 .. ")";
    instance:name(name);

    -- Create the output stream for the MACD. The first period is equal to the
    -- biggest first period of source EMA streams
    firstPeriodMACD = EMAL.DATA:first();


    HISTOGRAM = instance:addStream("H", core.Bar, name .. ".H", "H", instance.parameters.HISTOGRAM_color, firstPeriodMACD);
    HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));
    -- Create MVA for the MACD output stream.
    MVAI = core.indicators:create(Method2, HISTOGRAM, IN);
    firstPeriodSIGNAL = MVAI.DATA:first();
    -- Create output for the signal and histogram
    firstPeriodSIGNAL = MVAI.DATA:first();
    HISTOGRAM1 = instance:addStream("H1", core.Bar, name .. ".H1", "H1", instance.parameters.HISTOGRAM1_color, firstPeriodSIGNAL);
    HISTOGRAM1:setPrecision(math.max(2, instance.source:getPrecision()));
    HISTOGRAM2 = instance:addStream("H2", core.Bar, name .. ".H2", "H2", instance.parameters.HISTOGRAM2_color, firstPeriodSIGNAL);
    HISTOGRAM2:setPrecision(math.max(2, instance.source:getPrecision()));
    SIGNAL = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_color, firstPeriodSIGNAL);
    SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
	SIGNAL:setWidth(instance.parameters.width);
    SIGNAL:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
function Update(period, mode)
    -- and update short and long EMAs for the source.	
	
	if not source:hasData(period) or period < 1 then
	return;
	end
	
			EMAS:update(mode);
			EMAL:update(mode);
			
			if not  EMAS.DATA:hasData(period) or not EMAL.DATA:hasData(period)  then
			return;
			end

			
				 HISTOGRAM[period] = EMAS.DATA[period] - EMAL.DATA[period];
		   

			-- update MVA on the MACD
			MVAI:update(mode);
			if   MVAI.DATA:hasData(period)  then
				SIGNAL[period] = MVAI.DATA[period];
				if HISTOGRAM[period] > 0 and HISTOGRAM[period] > SIGNAL[period] then
				   HISTOGRAM1[period] = HISTOGRAM[period];
				elseif HISTOGRAM[period] < 0 and HISTOGRAM[period] < SIGNAL[period] then
				   HISTOGRAM2[period] = HISTOGRAM[period];
				end
			end
	
end


