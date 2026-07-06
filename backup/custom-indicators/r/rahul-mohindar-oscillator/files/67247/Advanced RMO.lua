-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41106
-- Id: 

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("Rahul Mohindar Oscillator");
    indicator:description("Rahul Mohindar Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    
	indicator.parameters:addInteger("Steps", "Steps", "Steps",10);
	
	indicator.parameters:addInteger("Period1", "1. Smoothing Period", "Period", 30);
	indicator.parameters:addInteger("Period2", "2. Smoothing Period", "Period", 30);
	indicator.parameters:addInteger("Period", "Base Period", "Period", 2);
	
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Color of RMO", "Color of RMO", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color2", "Color of Second Signal", " ", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	 indicator.parameters:addColor("color3", "Color of Second Signal", " ", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local  Period1,Period2;
local EMA1, EMA2;
local first;
local source = nil;
local Period;
-- Streams block
local MA={};
local SwingTrd1, SwingTrd2, SwingTrd3;
-- Routine
function Prepare(nameOnly)
     
	Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;
	Period = instance.parameters.Period;
	Steps= instance.parameters.Steps;
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Steps)   .. ", " .. tostring(Period1) .. ", " .. tostring(Period2).. ", " .. tostring(Period) .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	MA[1]  = core.indicators:create("MVA", source, Period);
	for i= 2, Steps, 1 do
	MA[i]  = core.indicators:create("MVA", MA[i-1].DATA, Period);
	end
	 
	
	first = MA[Steps].DATA:first();
	
	SwingTrd1 = instance:addStream("RMO", core.Line, name, "RMO", instance.parameters.color1, first);
	SwingTrd1:setWidth(instance.parameters.width1);
    SwingTrd1:setStyle(instance.parameters.style1);
	
	EMA1 = core.indicators:create("EMA", SwingTrd1, Period1);
	
	SwingTrd2 = instance:addStream("S1", core.Line, name, "First Signal", instance.parameters.color2, EMA1.DATA:first());
	SwingTrd2:setWidth(instance.parameters.width2);
    SwingTrd2:setStyle(instance.parameters.style2);
	
	EMA2 = core.indicators:create("EMA", SwingTrd2, Period2);
	SwingTrd3 = instance:addStream("S2", core.Line, name, "Second Signal", instance.parameters.color3, EMA2.DATA:first());
	SwingTrd3:setWidth(instance.parameters.width3);
    SwingTrd3:setStyle(instance.parameters.style3);

    SwingTrd1:setPrecision(math.max(2, instance.source:getPrecision()));
	SwingTrd2:setPrecision(math.max(2, instance.source:getPrecision()));
	SwingTrd3:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
     
	local Sum=0;
	for i= 1, Steps, 1 do
    MA[i]:update(mode);
	Sum=Sum+MA[i].DATA[period];	 
	end
	
 
	
	if period < first  then
	return;
	end
    
 

   local min, max;
   min, max=mathex.minmax(source, period-Steps+1, period);
   local x= source[period] - Sum/Steps ;
   
   SwingTrd1[period] = 100*(x)/ (max-min);
   
   EMA1:update(mode);
    if EMA1.DATA:first() < first  then
	return;
	end
	
	SwingTrd2[period]=EMA1.DATA[period]
   
   EMA2:update(mode);
   
     if EMA2.DATA:first() < first  then
	return;
	end
    
	SwingTrd3[period]=EMA2.DATA[period]
end

 
