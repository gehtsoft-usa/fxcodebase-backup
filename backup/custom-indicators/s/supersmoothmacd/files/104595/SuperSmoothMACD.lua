-- Id: 15375

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63103

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams

function Init()
    indicator:name("SuperSmoothMACD");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

   
   
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("SN", "Short MA", "", 12, 2, 1000);
    indicator.parameters:addInteger("LN", "Long MA", "", 26, 2, 1000);	
	indicator.parameters:addInteger("IN", "Smooth MA", "", 9, 2, 1000);	
    indicator.parameters:addInteger("superSmooth", "superSmooth", "", 7, 2, 1000);
	
	 indicator.parameters:addGroup("Indicator Style");
	 indicator.parameters:addColor("MACD_color", "MACD color", "(MACD Color)", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("MACD_width", "MACD Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("MACD_style", "MACD Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("MACD_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("SIGNAL_color", "Signal color", "(Signal Color)", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("SIGNAL_width", "SIGNAL Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("SIGNAL_style", "SIGNAL Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("SIGNAL_style", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("HISTOGRAM_Up_color", "Up Histogram", "Up Histogram", core.rgb(0, 255, 0));
    indicator.parameters:addColor("HISTOGRAM_Down_color", "Down Histogram", "Down Histogram", core.rgb(255, 0, 0));

	
	
	
end
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local SN;
local LN;
local superSmooth;

local EMAS = nil;
local EMAL = nil;
--local MVAI = nil;


-- Streams block
local MACD = nil;
local SIGNAL = nil;
local HISTOGRAM = nil;
local firstPeriodMACD;
local firstPeriodSIGNAL;
local  TempMacd;

function Prepare(nameOnly)

    source = instance.source;	  

	SN = instance.parameters.SN;
    LN = instance.parameters.LN;
	IN = instance.parameters.IN;
    superSmooth = instance.parameters.superSmooth;
	
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. SN .. ", " .. LN.. ", " .. IN .. ", " .. superSmooth.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	if (LN <= SN) then
       error("The short MA period must be smaller than long MA period");
    end
   
   
   EMAS = instance:addInternalStream(source:first(), 0);
   EMAL = instance:addInternalStream(source:first(), 0);
   TempMacd= instance:addInternalStream(source:first(), 0);
   
   MVAI = core.indicators:create("MVA", TempMacd, superSmooth);


    

    firstPeriodMACD = MVAI.DATA:first(); 
	
    MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACD_color, firstPeriodMACD);
	MACD:setWidth(instance.parameters.MACD_width);
    MACD:setStyle(instance.parameters.MACD_style);
	
    

    SIGNAL = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_color, firstPeriodMACD);
	SIGNAL:setWidth(instance.parameters.SIGNAL_width);
    SIGNAL:setStyle(instance.parameters.SIGNAL_style);
    HISTOGRAM = instance:addStream("HISTOGRAMUP", core.Bar, name .. ".HISTOGRAMUP", "HISTOGRAMUP", instance.parameters.HISTOGRAM_Up_color, firstPeriodMACD);
	
	
	MACD:setPrecision(math.max(2, instance.source:getPrecision()));
	SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
	HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));

	first = MVAI.DATA:first();
	
  
end



 

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 

   EMAS[period]= (2.0 / (1 + SN)) * source[period] + (1 - (2.0 / (1 + SN))) * EMAS[period-1];
   EMAL[period]= (2.0 / (1 + LN)) * source[period] + (1 - (2.0 / (1 + LN))) * EMAL[period-1];
   
   TempMacd[period] = EMAS[period] - EMAL[period];
  
    MVAI:update(mode);
    
    if (period < firstPeriodMACD) then
	return;
	end
	
	MACD[period]= MVAI.DATA[period];
	
	SIGNAL[period] = (2.0 / (1 + IN)) * MACD[period] + (1 - (2.0 / (1 + IN))) * SIGNAL[period-1];
	HISTOGRAM[period] =MACD[period]-SIGNAL[period];
       
 

end
