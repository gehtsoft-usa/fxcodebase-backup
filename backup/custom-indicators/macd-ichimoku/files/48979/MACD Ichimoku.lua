-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27915
-- Id: 8209

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


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("MACD Ichimoku");
    indicator:description("MACD Ichimoku");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("ICH Calculation");
    indicator.parameters:addInteger("Tenkan", "Tenkan Period", "Tenkan Period", 9);
    indicator.parameters:addInteger("Kijun", "Kijun Period", "Kijun Period", 26);
    indicator.parameters:addInteger("Senkou", "Senkou Period", "Senkou Period", 52);
	
	indicator.parameters:addGroup("MACD Calculation");
    indicator.parameters:addInteger("Fast_Ema", "Fast Ema Period", "Fast Ema Period", 12);
    indicator.parameters:addInteger("Slow_Ema", "Slow Ema Period", "Slow Ema Period", 26);
    indicator.parameters:addInteger("Signal_Sma", "Signal Sma Period", "Signal Sma Period", 9);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Tenkan_Buffer_color", "Color of Tenkan Line", "Color of Tenkan", core.rgb(0, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Kijun_Buffer_color", "Color of Kijun Line", "Color of Kijun_Buffer", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("Chinkou_Buffer_color", "Color of Chinkou Line", "Color of Chinkou", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("SpanA_Buffer_color", "Color of SpanA", "Color of SpanA", core.rgb(0, 255, 0));  
    indicator.parameters:addColor("SpanB_Buffer_color", "Color of SpanB", "Color of SpanB", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);
  
    

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Tenkan;
local Kijun;
local Senkou;
local Fast_Ema;
local Slow_Ema;
local Signal_Sma;

local first;
local source = nil;

-- Streams block
local Tenkan_Buffer = nil;
local Kijun_Buffer = nil;
local SpanA_Buffer = nil;
local SpanB_Buffer = nil;
local Chinkou_Buffer = nil;
local MACD_HIGH, MACD_LOW, MACD_CLOSE;
local Transparency;
-- Routine
function Prepare(nameOnly)
    Transparency= (100 -instance.parameters.Transparency); 
    Tenkan = instance.parameters.Tenkan;
    Kijun = instance.parameters.Kijun;
    Senkou = instance.parameters.Senkou;
    Fast_Ema = instance.parameters.Fast_Ema;
    Slow_Ema = instance.parameters.Slow_Ema;
    Signal_Sma = instance.parameters.Signal_Sma;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Tenkan) .. ", " .. tostring(Kijun) .. ", " .. tostring(Senkou) .. ", " .. tostring(Fast_Ema) .. ", " .. tostring(Slow_Ema) .. ", " .. tostring(Signal_Sma) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
	
        MACD_HIGH = core.indicators:create("MACD", source.high , Fast_Ema,Slow_Ema,Signal_Sma );
        MACD_LOW = core.indicators:create("MACD", source.low , Fast_Ema,Slow_Ema,Signal_Sma );
        MACD_CLOSE = core.indicators:create("MACD", source.close , Fast_Ema,Slow_Ema,Signal_Sma );
        Tenkan_Buffer = instance:addStream("Tenkan_Buffer", core.Line, name .. ".Tenkan", "Tenkan", instance.parameters.Tenkan_Buffer_color, MACD_HIGH.DATA:first() + Tenkan);
    Tenkan_Buffer:setPrecision(math.max(2, instance.source:getPrecision()));
        Tenkan_Buffer:setWidth(instance.parameters.width1);
        Tenkan_Buffer:setStyle(instance.parameters.style1);
		Kijun_Buffer = instance:addStream("Kijun_Buffer", core.Line, name .. ".Kijun", "Kijun", instance.parameters.Kijun_Buffer_color, MACD_HIGH.DATA:first() + Kijun);
    Kijun_Buffer:setPrecision(math.max(2, instance.source:getPrecision()));
        Kijun_Buffer:setWidth(instance.parameters.width2);
        Kijun_Buffer:setStyle(instance.parameters.style2);
	    Chinkou_Buffer = instance:addStream("Chinkou_Buffer", core.Line, name .. ".Chinkou", "Chinkou", instance.parameters.Chinkou_Buffer_color, first, -Kijun);
    Chinkou_Buffer:setPrecision(math.max(2, instance.source:getPrecision()));
        Chinkou_Buffer:setWidth(instance.parameters.width3);
        Chinkou_Buffer:setStyle(instance.parameters.style3);
		
		SpanA_Buffer = instance:addStream("SpanA_Buffer", core.Line, name .. ".SpanA 1", "SpanA 1", instance.parameters.SpanA_Buffer_color,math.max(MACD_HIGH.DATA:first() + Kijun, MACD_HIGH.DATA:first() + Tenkan )+Kijun, Kijun );
    SpanA_Buffer:setPrecision(math.max(2, instance.source:getPrecision()));
        SpanB_Buffer = instance:addStream("SpanB_Buffer", core.Line, name .. ".SpanB 1", "SpanB 1", instance.parameters.SpanB_Buffer_color, MACD_HIGH.DATA:first() + Senkou +Kijun, Kijun);        
    SpanB_Buffer:setPrecision(math.max(2, instance.source:getPrecision()));
		instance:createChannelGroup("Cloud","Cloud" , SpanA_Buffer, SpanB_Buffer, core.rgb(128, 128, 128), Transparency); 
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


-- Tenkan Sen 
	MACD_HIGH:update(mode);
	MACD_LOW:update(mode);
	MACD_CLOSE:update(mode);
	
	if period < MACD_HIGH.DATA:first() + Tenkan then
	return;
    end
	
    local high, low;
	high=  mathex.max (MACD_HIGH.DATA, period-Tenkan+1, period);
	low=  mathex.min (MACD_LOW.DATA, period-Tenkan+1, period);
 
	  Tenkan_Buffer[period]=(high+low)/2;
	  
-- Kijun Sen	  


    if period < MACD_HIGH.DATA:first() + Kijun then
	return;
    end

    high=  mathex.max (MACD_HIGH.DATA, period-Kijun+1, period);
	low=  mathex.min (MACD_LOW.DATA, period-Kijun+1, period);


     	Kijun_Buffer[period] = (high+low)/2;

-- Senkou Span A

         SpanA_Buffer[period+Kijun] =  (Kijun_Buffer[period]+Tenkan_Buffer[period])/2;
		
  
		
-- Senkou Span B		

    if period < MACD_HIGH.DATA:first() + Senkou then
	return;
    end   
    
          high=  mathex.max (MACD_HIGH.DATA, period-Senkou+1, period);
	      low=  mathex.min (MACD_LOW.DATA, period-Senkou+1, period);
		  
		  SpanB_Buffer[period+Kijun] = (high+low)/2; 
		  
	    if SpanA_Buffer[period+Kijun] > SpanB_Buffer[period+Kijun]
		then       
		SpanA_Buffer:setColor(period+Kijun, instance.parameters.SpanA_Buffer_color);
		else
		SpanA_Buffer:setColor(period+Kijun, instance.parameters.SpanB_Buffer_color);			
		end	
		 
		 
--Chinkou	
         
		if period < Kijun then
		return;
		end
       
        Chinkou_Buffer[period-Kijun] = MACD_CLOSE.DATA[period];
    
   
end

