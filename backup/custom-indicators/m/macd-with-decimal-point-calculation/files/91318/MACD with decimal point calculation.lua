-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60055
-- Id: 10639

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

 
function Init()
    indicator:name("Moving Average Convergence/Divergence");
    indicator:description("A trend-following momentum indicator that shows the relationship between two moving averages of prices.");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator:setTag("group", "Classic Oscillators");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("SN", "Short MA PPeriod","", 12, 2, 1000);
    indicator.parameters:addDouble("LN", "Long MA Period", "", 26, 2, 1000);
    indicator.parameters:addDouble("IN", "Signal Line Period", "", 9, 2, 1000);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MACD_color", "MACD Line Color","", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthMACD","Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleMACD","Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleMACD", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("SIGNAL_color", "Signal Line Color","", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthSIGNAL", "Line Width","", 1, 1, 5);
    indicator.parameters:addInteger("styleSIGNAL", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("styleSIGNAL", core.FLAG_LEVEL_STYLE);
    indicator.parameters:addColor("HISTOGRAM_color", "Histogram Bar Color","", core.rgb(0, 255, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local SN;
local LN;
local IN;

local first={}; 
local source = nil;

local EMAS = nil;
local EMAL = nil;
local MVAI = nil;

-- Streams block
local MACD = nil;
local SIGNAL = nil;
local HISTOGRAM = nil;
local k={};
local internal={};
local value={};
-- Routine
function Prepare(nameOnly)
    SN = instance.parameters.SN;
    LN = instance.parameters.LN;
    IN = instance.parameters.IN;
    source = instance.source;

    -- Check parameters
    if (LN <= SN) then
       error("The short EMA period must be smaller than long EMA period");
    end
	
	 k["SN"] = 2.0 / (SN + 1.0);
     k["LN"] = 2.0 / (LN + 1.0); 
     k["IN"] = 2.0 / (IN + 1.0);
	 
	 first["SN"]=  source:first()+math.floor(SN * 1.5);
	 first["LN"]=  source:first()+math.floor(LN * 1.5)
	 first["MACD"]=  math.max(first["SN"], first["LN"]);
	  first["SIGNAL"]= first["MACD"] + math.floor(IN * 1.5)
	 
    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. SN .. ", " .. LN .. ", " .. IN .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    internal["SN"] = instance:addInternalStream(0, 0);
    internal["LN"] = instance:addInternalStream(0, 0);
    internal["IN"] = instance:addInternalStream(0, 0);

    local precision = math.max(2, source:getPrecision());
    
    -- Create the output stream for the MACD. The first period is equal to the
    -- biggest first period of source EMA streams
   
    MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACD_color,  first["MACD"]);
    MACD:setWidth(instance.parameters.widthMACD);
    MACD:setStyle(instance.parameters.styleMACD);
    MACD:setPrecision(precision);

    
    SIGNAL = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_color, first["SIGNAL"]);
    SIGNAL:setWidth(instance.parameters.widthSIGNAL);
    SIGNAL:setStyle(instance.parameters.styleSIGNAL);
    SIGNAL:setPrecision(precision);
    HISTOGRAM = instance:addStream("HISTOGRAM", core.Bar, name .. ".HISTOGRAM", "HISTOGRAM", instance.parameters.HISTOGRAM_color, first["SIGNAL"]);
    HISTOGRAM:setPrecision(precision);
end

-- Indicator calculation routine
function Update(period)

    value["SN"]=0;
	value["LN"]=0;
	value["IN"]=0;
	
    if (period == first["SN"]) then
            value["SN"] = source[period];
    else
            value["SN"] = internal["SN"][period - 1];
     end
		
	if (period == first["LN"]) then
            value["LN"] = source[period];
    else
            value["LN"] = internal["LN"][period - 1];
     end


   

    internal["SN"][period] = (1 - k["SN"]) * value["SN"] + k["SN"] * source[period];
	internal["LN"][period] = (1 - k["LN"]) * value["LN"] + k["LN"] * source[period];

	
    if (period< first["MACD"]) then
    return;
    end
	
         MACD[period] = internal["SN"][period] - internal["LN"][period];
  

    if (period < first["SIGNAL"]) then
	return;
	end
	
	
	 if (period == first["SIGNAL"]) then
            value["IN"] =  MACD[period];
    else
            value["IN"] = internal["IN"][period - 1];
     end	 
		
		
    internal["IN"][period] = (1 - k["IN"]) * value["IN"] + k["IN"] * MACD[period];
	
	
     SIGNAL[period] = internal["IN"][period];
        
     HISTOGRAM[period] = MACD[period] - SIGNAL[period];
    
end


