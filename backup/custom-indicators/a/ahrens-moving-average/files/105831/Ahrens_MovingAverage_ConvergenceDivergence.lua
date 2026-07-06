-- Id: 15886
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62629

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
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Ahrens MovingAverage ConvergenceDivergence");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("fastPeriod", "Fast Period", "Period", 12);
	indicator.parameters:addInteger("slowPeriod", "Fast Period", "Period", 26);
	indicator.parameters:addInteger("signalPeriod", "Signal Period", "Period", 9);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Color of MACD", "Color of MACD", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);	
	
	indicator.parameters:addColor("color2", "Color of Signal", "Color of Signal", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("color3", "Color of Histogram Up", "Color of Histogram", core.rgb(0, 0, 255));
    indicator.parameters:addColor("color4", "Color of Histogram Down", "Color of Histogram", core.rgb(0, 0, 0));
end
	

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local fastPeriod;
local slowPeriod;
local signalPeriod;

 
local source = nil;

 
 
local fastAMA, slowAMA,MACD, SIGNAL,HISTOGRAM;
-- Routine
function Prepare(nameOnly)
    fastPeriod = instance.parameters.fastPeriod;
	slowPeriod = instance.parameters.slowPeriod;
	signalPeriod = instance.parameters.signalPeriod;
    source = instance.source;
     

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(fastPeriod).. ", " .. tostring(slowPeriod).. ", " .. tostring(signalPeriod) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        
		fastAMA = instance:addInternalStream(source:first() +fastPeriod,0);
		slowAMA = instance:addInternalStream(source:first() +slowPeriod,0);
		MACD = instance:addStream("MACDS", core.Line, name, "MACD", instance.parameters.color1,  source:first()+math.max(slowPeriod,fastPeriod));
    MACD:setPrecision(math.max(2, instance.source:getPrecision()));
		MACD:setWidth(instance.parameters.width1);
        MACD:setStyle(instance.parameters.style1);
		
		
		SIGNAL = instance:addStream("SIGNAL", core.Line, name, "SIGNAL", instance.parameters.color2,  source:first()+math.max(slowPeriod,fastPeriod)+signalPeriod);
    SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
		SIGNAL:setWidth(instance.parameters.width2);
        SIGNAL:setStyle(instance.parameters.style2);
		
		HISTOGRAM = instance:addStream("HISTOGRAM", core.Bar, name, "HISTOGRAM", instance.parameters.color3, source:first()+math.max(slowPeriod,fastPeriod)+signalPeriod); 
    HISTOGRAM:setPrecision(math.max(2, instance.source:getPrecision()));
  
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
		 if period < source:first()+fastPeriod  then
		 return;
		 end
	 
			
			local MedianMA1=(fastAMA[period-1]+fastAMA[period-fastPeriod])/2; 			
			fastAMA[period]=  fastAMA[period-1]+((source.median[period]-MedianMA1)/fastPeriod);
			
		  if period < source:first()+slowPeriod  then
	      return;
	      end	
		  
			local MedianMA2=(slowAMA[period-1]+slowAMA[period-slowPeriod])/2; 			
			slowAMA[period]=  slowAMA[period-1]+((source.median[period]-MedianMA2)/slowPeriod);
			
			MACD[period]= fastAMA[period]-slowAMA[period];
		 
		  if period < math.max(slowPeriod,fastPeriod)+signalPeriod then
		  return;
		  end
		 
		   local MedianMA3=(SIGNAL[period-1]+SIGNAL[period-signalPeriod])/2; 		
		   SIGNAL[period]=  SIGNAL[period-1]+((MACD[period]-MedianMA3)/signalPeriod);
		   HISTOGRAM[period]= MACD[period]-SIGNAL[period];		   
			 
		  if HISTOGRAM[period] > HISTOGRAM[period-1] then
		  HISTOGRAM:setColor(period, instance.parameters.color3);
		  else
		  HISTOGRAM:setColor(period, instance.parameters.color4);
		  end
		  
 
    
end

