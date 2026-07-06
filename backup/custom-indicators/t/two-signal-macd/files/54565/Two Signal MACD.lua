-- Id: 8498
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=31999

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
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Two Signal MACD");
    indicator:description("Two Signal MACD");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SN", "Short MA", "", 12, 2, 1000);
     indicator.parameters:addInteger("LN", "Long MA", "", 26, 2, 1000);
	 
    indicator.parameters:addString("MAMethod", "MA Method", "", "EMA");
    indicator.parameters:addStringAlternative("MAMethod", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("MAMethod", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("MAMethod", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("MAMethod", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("MAMethod", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("MAMethod", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("MAMethod", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("MAMethod", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("MAMethod", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("MAMethod", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("MAMethod", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("MAMethod", "T3", "", "T3");
    indicator.parameters:addStringAlternative("MAMethod", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("MAMethod", "Median", "", "Median");
    indicator.parameters:addStringAlternative("MAMethod", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("MAMethod", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("MAMethod", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("MAMethod", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("MAMethod", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("MAMethod", "JSmooth", "", "JSmooth");
		
    indicator.parameters:addInteger("IN1", "1. Signal Line MA", "", 9, 2, 1000);
	 indicator.parameters:addString("SIGNALMethod1", "MA Method", "", "MVA");
    indicator.parameters:addStringAlternative("SIGNALMethod1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("SIGNALMethod1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("SIGNALMethod1", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("SIGNALMethod1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("SIGNALMethod1", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("SIGNALMethod1", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("SIGNALMethod1", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("SIGNALMethod1", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("SIGNALMethod1", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("SIGNALMethod1", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("SIGNALMethod1", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("SIGNALMethod1", "T3", "", "T3");
    indicator.parameters:addStringAlternative("SIGNALMethod1", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("SIGNALMethod1", "Median", "", "Median");
    indicator.parameters:addStringAlternative("SIGNALMethod1", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("SIGNALMethod1", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("SIGNALMethod1", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("SIGNALMethod1", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("SIGNALMethod1", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("SIGNALMethod1", "JSmooth", "", "JSmooth");  
	
	indicator.parameters:addInteger("IN2", "2. Signal Line MA", "", 9, 2, 1000);
	 indicator.parameters:addString("SIGNALMethod2", "MA Method", "", "MVA");
    indicator.parameters:addStringAlternative("SIGNALMethod2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("SIGNALMethod2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("SIGNALMethod2", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("SIGNALMethod2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("SIGNALMethod2", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("SIGNALMethod2", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("SIGNALMethod2", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("SIGNALMethod2", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("SIGNALMethod2", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("SIGNALMethod2", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("SIGNALMethod2", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("SIGNALMethod2", "T3", "", "T3");
    indicator.parameters:addStringAlternative("SIGNALMethod2", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("SIGNALMethod2", "Median", "", "Median");
    indicator.parameters:addStringAlternative("SIGNALMethod2", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("SIGNALMethod2", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("SIGNALMethod2", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("SIGNALMethod2", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("SIGNALMethod2", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("SIGNALMethod2", "JSmooth", "", "JSmooth");  
	
    indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("MACD_color", "MACD Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthMACD", "MACD width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleMACD", "MACD Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleMACD", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("SIGNAL_color1", "1. SIGNAL Color" , "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthSIGNAL1", "SIGNAL Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleSIGNAL1", "SIGNAL Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSIGNAL1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("SIGNAL_color2", "2. SIGNAL Color" , "", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthSIGNAL2", "SIGNAL Width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleSIGNAL2", "SIGNAL Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSIGNAL2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addString("Show", "Show Histogram", "", "No");
    indicator.parameters:addStringAlternative("Show", "One", "", "One");
    indicator.parameters:addStringAlternative("Show", "Two", "", "Two");	
	indicator.parameters:addStringAlternative("Show", "None", "", "No");
	
    indicator.parameters:addColor("UU", "Rising Up Histogram Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UD", "Rasing Down Histogram Color", "", core.rgb(0, 200, 0));
	indicator.parameters:addColor("DU", "Faling Up Histogram Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("DD", "Faling Down Histogram Color", "", core.rgb(200, 0, 0));
	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local SN,LN,IN1,IN2,SIGNALMethod1, SIGNALMethod2,MAMethod,ColorMode;

local first;
local source = nil;

local MACD;
local SIGNAL1;
local SIGNAL2;

local LONG;
local SHORT;
local SMOOTH1, SMOOTH2;
local Show;

local HISTOGRAM;
-- Routine
function Prepare(nameOnly)  

    source = instance.source;
   

	UP = instance.parameters.UP;
	DOWN = instance.parameters.DOWN;
	Show = instance.parameters.Show;
	
	SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN1 = instance.parameters.IN1;
	IN2 = instance.parameters.IN2;
	
	ColorMode = instance.parameters.ColorMode;
	
	SIGNALMethod1= instance.parameters.SIGNALMethod1;
	SIGNALMethod2= instance.parameters.SIGNALMethod2;
    MAMethod = instance.parameters.MAMethod;
		 
     local name = profile:id() .. "(" .. source:name() .. ", " .. SN .. ", " .. LN .. ", " .. MAMethod ..", " .. IN1 .. ", ".. SIGNALMethod1..", " .. IN2 .. ", ".. SIGNALMethod2.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	if (LN <= SN) then
       error("The short MA period must be smaller than long MA period");
    end	
	
    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");

    local precision = math.max(2, source:getPrecision());

	
	LONG = core.indicators:create("AVERAGES", source, MAMethod, LN , false);
	SHORT = core.indicators:create("AVERAGES", source, MAMethod, SN ,false);  
	
	first = LONG.DATA:first();
   
    MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACD_color, first);
    MACD:setWidth(instance.parameters.widthMACD);
    MACD:setStyle(instance.parameters.styleMACD);
    MACD:setPrecision(precision);
	
	SMOOTH1 = core.indicators:create("AVERAGES", MACD, SIGNALMethod1, IN1 , false);
	SMOOTH2 = core.indicators:create("AVERAGES", SMOOTH1.DATA, SIGNALMethod2, IN2 , false);

    SIGNAL1 = instance:addStream("SIGNAL1", core.Line, name .. "1. SIGNAL", "1. SIGNAL", instance.parameters.SIGNAL_color1, SMOOTH1.DATA:first());
    SIGNAL1:setWidth(instance.parameters.widthSIGNAL1);
    SIGNAL1:setStyle(instance.parameters.styleSIGNAL1);
    SIGNAL1:setPrecision(precision);
	
	
	SIGNAL2 = instance:addStream("SIGNAL2", core.Line, name .. "2. SIGNAL", "2. SIGNAL", instance.parameters.SIGNAL_color2, SMOOTH2.DATA:first());
    SIGNAL2:setWidth(instance.parameters.widthSIGNAL2);
    SIGNAL2:setStyle(instance.parameters.styleSIGNAL2);
    SIGNAL2:setPrecision(precision);
	
	
    
		if Show == "One" then
		HISTOGRAM = instance:addStream("HISTOGRAM", core.Bar, name .. "HISTOGRAM", "HISTOGRAM", instance.parameters.UU, SMOOTH1.DATA:first());
    HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));
    	elseif Show == "Two" then
		HISTOGRAM= instance:addStream("HISTOGRAM", core.Bar, name .. "HISTOGRAM", "HISTOGRAM", instance.parameters.DD , SMOOTH2.DATA:first());
        HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));
    else
		HISTOGRAM = instance:addInternalStream(SMOOTH2.DATA:first(), 0);
		end
	
	
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
  
	
    LONG:update(mode); 
	SHORT:update(mode); 
	
	if period <first then
	return;
	end
		
			MACD[period]=SHORT.DATA[period]-LONG.DATA[period];
			
			SMOOTH1:update(mode); 
			SMOOTH2:update(mode); 
			
			
    if period >  SMOOTH1.DATA:first() then
	SIGNAL1[period]=SMOOTH1.DATA[period];
	if Show ~= "Two" then 
	HISTOGRAM[period]=MACD[period]-SIGNAL1[period];
	end		
	end
	
	
	if period >  SMOOTH2.DATA:first() then
	SIGNAL2[period]=SMOOTH2.DATA[period];
	if Show ~= "One" then
	HISTOGRAM[period]=MACD[period]-SIGNAL2[period];
	end					
	end
	
	if HISTOGRAM[period] > 0 then
		if HISTOGRAM[period]> HISTOGRAM[period-1] then
		HISTOGRAM:setColor(period,  instance.parameters.UU);
		else
		HISTOGRAM:setColor(period,  instance.parameters.UD);
		end
    else
	    if HISTOGRAM[period]< HISTOGRAM[period-1] then
		HISTOGRAM:setColor(period,  instance.parameters.DU);
		else
		HISTOGRAM:setColor(period,  instance.parameters.DD);
		end
    end	
	
							
	
end

