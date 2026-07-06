-- Id: 17252
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64239

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

function Init()
    indicator:name("MAMA convergence divergence");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("MAMA Calculation"); 
    indicator.parameters:addDouble("FastLimit", "FastLimit", "FastLimit", 0.5, 0, 1);
    indicator.parameters:addDouble("SlowLimit", "SlowLimit", "SlowLimit", 0.05, 0, 1);
	
	indicator.parameters:addGroup("Signal Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	
	indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addColor("color1", "MACD Line Color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "Signal Line Color", "Line Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color3", "Histogram Bar Color", "Bare Color", core.rgb(0, 0, 255));
 
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local FastLimit, SlowLimit;


local source = nil;

-- Streams block
local MAMA ;
local MAMACD = nil;
local Signal, SIGNAL;
local Histogram;
local Period;
-- Routine
function Prepare(nameOnly)
    
    source = instance.source;
	
	assert(core.indicators:findIndicator("MAMA") ~= nil, "Please, download and install MAMA.LUA indicator");
    
	FastLimit= instance.parameters.FastLimit;
	SlowLimit= instance.parameters.SlowLimit;
	Period= instance.parameters.Period;
	
    local name = profile:id() .. "(" .. source:name()  .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end

	MAMA= core.indicators:create("MAMA", source, FastLimit, SlowLimit);
    
  
    MAMACD = instance:addStream("MAMACD", core.Line, name .. ".MAMACD", "MAMACD", instance.parameters.color1, MAMA.DATA:first());
    MAMACD:setPrecision(math.max(2, instance.source:getPrecision()));
	MAMACD:setWidth(instance.parameters.width1);
    MAMACD:setStyle(instance.parameters.style1);
	
	
	SIGNAL= core.indicators:create("MVA", MAMACD, Period);
	
	Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.color2, SIGNAL.DATA:first());
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
	Signal:setWidth(instance.parameters.width2);
    Signal:setStyle(instance.parameters.style2);
	
	Histogram = instance:addStream("Histogram", core.Bar, name .. ".Histogram", "Histogram", instance.parameters.color3, SIGNAL.DATA:first());
    Histogram:setPrecision(math.max(2, instance.source:getPrecision()));
end


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


    MAMA:update(mode);
 
    
	if period < MAMA.DATA:first() or not  source:hasData(period) then
	return;
	end
	
	MAMACD[period]= MAMA.MAMA[period]- MAMA.FAMA[period]
	
	SIGNAL:update(mode);
 
	if period < SIGNAL.DATA:first() then
	return;
	end
	
	
	Signal[period]=SIGNAL.DATA[period] ;
	Histogram[period]=MAMACD[period]- SIGNAL.DATA[period] ;
	
end


