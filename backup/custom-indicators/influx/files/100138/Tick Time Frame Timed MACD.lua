-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62160

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
    indicator:name("Tick Timed MACD");
    indicator:description("Tick Timed MACD");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation"); 

    indicator.parameters:addInteger("DurationOfFast", "Fast MA Duration in seconds", "Fast MA Duration in seconds", 100);
    indicator.parameters:addInteger("DurationOfSlow", "Slow MA Duration in seconds", "Slow MA Duration in seconds", 200);
	indicator.parameters:addInteger("DurationOfSignal", "Signal MA Duration in seconds", "Signal MA Duration in seconds", 90);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Color of MACD", "Color of MACD", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Color2", "Color of Signal", "Color of Siganal", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("Width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Color3", "Color of Histogram", "Color of Histogram", core.rgb(0, 0, 255));
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;

-- Streams block
local RawFast = nil;
local RawSlow = nil; 
local DurationOfFast;
local DurationOfSlow;
local DurationOfSignal;
local MACD;
local Signal;
local Histogram;
-- Routine
function Prepare(nameOnly)
    DurationOfFast = instance.parameters.DurationOfFast;
    DurationOfSlow = instance.parameters.DurationOfSlow; 
	DurationOfSignal= instance.parameters.DurationOfSignal;
    source = instance.source;
    first=source:first();
	
	local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    
    if (not (nameOnly)) then
        RawFast= instance:addInternalStream(0, 0);
        RawSlow= instance:addInternalStream(0, 0); 
        MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.Color, source:first());
		MACD:setWidth(instance.parameters.Width);
        MACD:setStyle(instance.parameters.Style);
		MACD:setPrecision (source:getPrecision());
		
		Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Color2, source:first());
		Signal:setWidth(instance.parameters.Width2);
        Signal:setStyle(instance.parameters.Style2)
		Signal:setPrecision (source:getPrecision());
		
		Histogram = instance:addStream("Histogram", core.Bar, name .. ".Histogram", "Histogram", instance.parameters.Color3, source:first());
		Histogram:setPrecision (source:getPrecision());
      
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


    	if period <= first then
	return;
	end
	
	
	local P1, P2;
    local One=1/86400;
	P1= core.findDate (source, source:date(period)-One*DurationOfFast, false);
	P2= core.findDate (source, source:date(period)-One*DurationOfSlow, false);
	P3= core.findDate (source, source:date(period)-One*DurationOfSignal, false); 
	 
	if P1==-1 or P2==-1  or P3==-1 
	or P1< first+1 or P2< first+1 or P3< first+1
	or P1 >= period or P2  >= period or P3  >= period
    then
    return;
    end
	
	
        RawFast[period] = mathex.avg(source ,P1, period);
        RawSlow[period]  = mathex.avg(source ,P2, period);
		
 
	 	MACD[period]= RawFast[period]-RawSlow[period];
          Signal[period]= mathex.avg(MACD,P3, period);
		Histogram[period]= MACD[period]-Signal[period];
		 
end
 