-- Id: 7551
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
    indicator:name(" Ergodic Ticks Volume Indicator");
    indicator:description("Ergodic  Ticks Volume Indicator ");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addInteger("r", "TVI First Smoothing Period", "r", 12);
    indicator.parameters:addInteger("s",  "TVI Second Smoothing Period", "", 12);
   
	indicator.parameters:addInteger("er", "Ergodic TVI First Smoothing", "r", 5);
    indicator.parameters:addInteger("es",  "Ergodic TVI Second Smoothing", "", 5);
    indicator.parameters:addInteger("eu", "Ergodic Signal Period", "u", 5);
	
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

local er;
local es;
local eu;

local first, FIRST;
local source = nil;
local DATA;
-- Streams block
local TVI = nil;
local EMA, DEMA;
local Smoothing;
-- Routine
function Prepare(nameOnly)
    r = instance.parameters.r;
    s = instance.parameters.s;
	
	 er = instance.parameters.er;
    es = instance.parameters.es;
	eu = instance.parameters.eu;

    source = instance.source;
	
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(r) .. ", " .. tostring(s) .. ", " .. tostring(er).. ", " .. tostring(es).. ", " .. tostring(eu) .. ")";
    instance:name(name);
   
     if   (nameOnly) then
        return;
    end
   
	assert(core.indicators:findIndicator("TVI") ~= nil, "Please, download and install TVI.LUA indicator");   
	DATA=core.indicators:create("TVI",source , r, s, 2);
	
	 first = DATA.DATA:first();
	
	EMA=core.indicators:create("EMA",DATA.DATA , er);
    DEMA= core.indicators:create("EMA",EMA.DATA , es);

	
   FIRST= DEMA.DATA:first();

   
    
        TVI = instance:addStream("TVI", core.Line, name, "TVI", instance.parameters.TVI_color, FIRST);
    TVI:setPrecision(math.max(2, instance.source:getPrecision()));
		TVI:setWidth(instance.parameters.width);
        TVI:setStyle(instance.parameters.style);
		
		Smoothing= core.indicators:create("EMA",TVI , eu);
		
		SIGNAL = instance:addStream("SIGNAL", core.Line, name, "SIGNAL", instance.parameters.SIGNAL_color, FIRST+eu);
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
	
	
	DATA:update(mode);   	
	EMA:update(mode);		
	DEMA:update(mode);  
	
	 if period <  FIRST then
	return;
	end
	
	TVI[period]=DEMA.DATA[period];
	
	  
	 Smoothing:update(mode);  
	  
	if period <  FIRST +eu then
	return;
	end
	
	SIGNAL[period]= Smoothing.DATA[period];
    
end

