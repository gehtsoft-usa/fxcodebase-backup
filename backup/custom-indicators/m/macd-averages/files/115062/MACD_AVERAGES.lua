-- Id: 19096
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=65111

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


function Init()
    indicator:name("MACD_AVERAGES");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
 
    
	indicator.parameters:addGroup("Calculation"); 

    indicator.parameters:addString("Smooth_Method1", "Fast MA Smooth Method", "", "MVA");
    indicator.parameters:addStringAlternative("Smooth_Method1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Smooth_Method1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Smooth_Method1", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Smooth_Method1", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Smooth_Method1", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Smooth_Method1", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Smooth_Method1", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Smooth_Method1", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Smooth_Method1", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Smooth_Method1", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Smooth_Method1", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Smooth_Method1", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Smooth_Method1", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Smooth_Method1", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Smooth_Method1", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Smooth_Method1", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Smooth_Method1", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Smooth_Method1", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Smooth_Method1", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Smooth_Method1", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Smooth_Method1", "JSmooth", "", "JSmooth");
	
	 indicator.parameters:addString("Smooth_Method2", "Slow MA Smooth Method", "", "MVA");
    indicator.parameters:addStringAlternative("Smooth_Method2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Smooth_Method2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Smooth_Method2", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Smooth_Method2", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Smooth_Method2", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Smooth_Method2", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Smooth_Method2", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Smooth_Method2", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Smooth_Method2", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Smooth_Method2", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Smooth_Method2", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Smooth_Method2", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Smooth_Method2", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Smooth_Method2", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Smooth_Method2", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Smooth_Method2", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Smooth_Method2", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Smooth_Method2", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Smooth_Method2", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Smooth_Method2", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Smooth_Method2", "JSmooth", "", "JSmooth");
	
    indicator.parameters:addInteger("Fast_Period", "Fast MA period", "", 12);
    indicator.parameters:addInteger("Slow_Period", "Slow MA period", "", 26);
    indicator.parameters:addString("Signal_Method", "Signal MA Method", "", "MVA");
    indicator.parameters:addStringAlternative("Signal_Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Signal_Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Signal_Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Signal_Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Signal_Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Signal_Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Signal_Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Signal_Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Signal_Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Signal_Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Signal_Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Signal_Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Signal_Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Signal_Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Signal_Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Signal_Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Signal_Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Signal_Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Signal_Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Signal_Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Signal_Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("Signal_Period", "Signal period", "", 9);
			
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

--Indicator parameters
local Smooth_Method1, Smooth_Method2;
local Fast_Period, Slow_Period;
local Signal_Method,Signal_Period;
local MA, Fast_MA, Slow_MA, Signal_MA;
 
local source = nil;
local first;

-- Streams block
local MACD = nil;
local SIGNAL=nil;
local HISTOGRAM=nil;

local Fast, Slow, Signal;
-- Routine
function Prepare(nameOnly) 
    
   Smooth_Method1= instance.parameters.Smooth_Method1;
   Smooth_Method2= instance.parameters.Smooth_Method2;
   Fast_Period= instance.parameters.Fast_Period;
   Slow_Period= instance.parameters.Slow_Period;
   Signal_Method= instance.parameters.Signal_Method;
   Signal_Period= instance.parameters.Signal_Period;
   
    

    source = instance.source;
 
    -- Base name of the indicator.
    local name = profile:id() .. "(" .. source:name() .. ", " .. Smooth_Method1 .. ", " .. Smooth_Method2 .. ", " .. Fast_Period .. ", " .. Slow_Period .. ", " .. Signal_Method.. ", " .. Signal_Period.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator"); 
	Fast = core.indicators:create("AVERAGES", source, Smooth_Method1, Fast_Period  );
	Slow = core.indicators:create("AVERAGES", source, Smooth_Method2, Slow_Period  );
	
	first=math.max(Fast.DATA:first(), Slow.DATA:first());
 
    MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.MACD_color, first);
	MACD:setWidth(instance.parameters.width1);
    MACD:setStyle(instance.parameters.style1);
	
	Signal= core.indicators:create("AVERAGES", MACD, Signal_Method, Signal_Period  );
 

    SIGNAL = instance:addStream("SIGNAL", core.Line, name .. ".SIGNAL", "SIGNAL", instance.parameters.SIGNAL_color, Signal.DATA:first());
	SIGNAL:setWidth(instance.parameters.width2);
    SIGNAL:setStyle(instance.parameters.style2);
    HISTOGRAM = instance:addStream("HISTOGRAM", core.Bar, name .. "HISTOGRAM", "HISTOGRAM", instance.parameters.UP, Signal.DATA:first());
	
	
	MACD:setPrecision(math.max(2, instance.source:getPrecision()));
	SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
	HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));
	
end

-- Indicator calculation routine
function Update(period, mode)
  
                     Fast:update(mode);
                     Slow:update(mode);
   
                   if period < first then
				   return;
				   end
  
					MACD[period] = Fast.DATA[period] -  Slow.DATA[period];
					
					
					Signal:update(mode);
					if period < Signal.DATA:first() then
					return;
					end
	
					SIGNAL[period] =  Signal.DATA[period];
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


