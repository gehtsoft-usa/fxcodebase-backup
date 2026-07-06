-- Id: 7549
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23995

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
    indicator:name("Ticks Volume Indicator ");
    indicator:description("Ticks Volume Indicator ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addInteger("r", "First Smoothing", "r", 12);
    indicator.parameters:addInteger("s",  "Second Smoothing", "", 12);
    indicator.parameters:addInteger("u", "Signal", "u", 5);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("TVI_color", "Color of TVI Line", "Color of TVI", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("SIGNAL_color", "Color of Signal Line", "Color of SIGNAL", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Swidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Sstyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Sstyle", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local r;
local s;
local u;

local first, FIRST;
local source = nil;

-- Streams block
local TVI = nil;
local UpTicks, DownTicks
local EMA_UpTicks, DEMA_UpTicks;
local EMA_DownTicks, DEMA_DownTicks;
local Smoothing;
-- Routine
function Prepare(nameOnly)
    r = instance.parameters.r;
    s = instance.parameters.s;
    u = instance.parameters.u;
    source = instance.source;
    first = source:first();
	
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(r) .. ", " .. tostring(s) .. ", " .. tostring(u) .. ")";
    instance:name(name);
  
     if   (nameOnly) then
        return;
    end
	
	UpTicks= instance:addInternalStream(first, 0);
	DownTicks= instance:addInternalStream(first, 0);
	
	EMA_UpTicks=core.indicators:create("EMA",UpTicks , r);
	EMA_DownTicks=core.indicators:create("EMA",DownTicks , r);
	
   
    DEMA_UpTicks= core.indicators:create("EMA",EMA_UpTicks.DATA , r);
	DEMA_DownTicks=core.indicators:create("EMA",EMA_DownTicks.DATA , r);
	
   FIRST= DEMA_UpTicks.DATA:first();

   
   
        TVI = instance:addStream("TVI", core.Line, name, "TVI", instance.parameters.TVI_color, FIRST);
    TVI:setPrecision(math.max(2, instance.source:getPrecision()));
		TVI:setWidth(instance.parameters.width);
        TVI:setStyle(instance.parameters.style);
		
		Smoothing= core.indicators:create("EMA",TVI , u);
		
		SIGNAL = instance:addStream("SIGNAL", core.Line, name, "SIGNAL", instance.parameters.SIGNAL_color, FIRST+u);
    SIGNAL:setPrecision(math.max(2, instance.source:getPrecision()));
		SIGNAL:setWidth(instance.parameters.Swidth);
        SIGNAL:setStyle(instance.parameters.Sstyle);
  
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first or not source:hasData(period) then
	return;
	end
    
    UpTicks[period]=(source.volume[period]+(source.close[period]-source.open[period])/source:pipSize())/2;
    DownTicks[period]=source.volume[period]-UpTicks[period];
	
	
	EMA_UpTicks:update(mode);
	DEMA_UpTicks:update(mode);  
	
	EMA_DownTicks:update(mode);
	DEMA_DownTicks:update(mode);  
	
	 if period <  FIRST then
	return;
	end
	
	  
      TVI[period] =100.0*(DEMA_UpTicks.DATA[period]-DEMA_DownTicks.DATA[period])/(DEMA_UpTicks.DATA[period]+DEMA_DownTicks.DATA[period]);
	  
	  
	  Smoothing:update(mode);  
	  
	if period <  FIRST +u then
	return;
	end
	
	SIGNAL[period]= Smoothing.DATA[period];
    
end

