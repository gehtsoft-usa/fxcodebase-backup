-- Id: 7538
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23910

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
    indicator:name("Blau`s Ergodic Candlestick Oscillator");
    indicator:description("Blau`s Ergodic Candlestick Oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
     indicator.parameters:addGroup("Calculation");   
    indicator.parameters:addInteger("Period1", "Ema Period", "Ema Period", 32);
    indicator.parameters:addInteger("Period2", "vEMA Period", "vEMA Period", 12);
	 indicator.parameters:addInteger("Period3", "Signal Period", "SIgnal Period", 12);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("CO_color", "Color of CO", "Color of CO", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	   indicator.parameters:addColor("Signal_color", "Color of Signal", "Color of Signal", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("Swidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Sstyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Sstyle", core.FLAG_LINE_STYLE);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period1;
local Period2;
local Period3;

local first1,first2,first3,first4;
local source = nil;

-- Streams block
local CO = nil;
local Buf1,Buf2;
local EMA1, EMA2, EMA3, EMA4, EMA5;
local Signal;
-- Routine
function Prepare(nameOnly)
    Period1 = instance.parameters.Period1;
    Period2 = instance.parameters.Period2;
	Period3 = instance.parameters.Period3;
    source = instance.source;
    first1 = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period1) .. ", " .. tostring(Period2).. ", " .. tostring(Period3) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	Buf1 = instance:addInternalStream(first1, 0);
	Buf2 = instance:addInternalStream(first1, 0);
     EMA1=core.indicators:create("EMA", Buf1, Period1);
	 EMA2=core.indicators:create("EMA", Buf2, Period1);
	
	first2= math.max(EMA1.DATA:first(), EMA2.DATA:first())
	
	 EMA3= core.indicators:create("EMA", EMA1.DATA, Period2);
	 EMA4= core.indicators:create("EMA", EMA2.DATA, Period2);
	
	first3= math.max(EMA3.DATA:first(), EMA4.DATA:first())
	
	

 
        CO = instance:addStream("CO", core.Line, name, "CO", instance.parameters.CO_color, first3);
    CO:setPrecision(math.max(2, instance.source:getPrecision()));
		CO:setWidth(instance.parameters.width);
        CO:setStyle(instance.parameters.style);
		
		
		EMA5= core.indicators:create("EMA", CO, Period3);
		first4=EMA5.DATA:first();
		
		 Signal = instance:addStream("SIGNAL", core.Line, name, "Signal", instance.parameters.Signal_color, first4);
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
		Signal:setWidth(instance.parameters.Swidth);
        Signal:setStyle(instance.parameters.Sstyle)
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first1 or not  source:hasData(period) then
	return;
	end
	
	Buf1[period]=source.close[period]- source.open[period];
	Buf2[period]=source.high[period]- source.low[period];
	
	EMA1:update(mode);
	EMA2:update(mode);
	
	if period < first2 then
	return;
	end
	
	
	EMA3:update(mode);
	EMA4:update(mode);
	
	if period < first3  then
	return;
	end
	
        CO[period] = (EMA3.DATA[period]/EMA4.DATA[period])*100;
		
	EMA5:update(mode);	
		
	if period < first4  then
	return;
	end
	
	   Signal[period]= EMA5.DATA[period];
		
    
end

