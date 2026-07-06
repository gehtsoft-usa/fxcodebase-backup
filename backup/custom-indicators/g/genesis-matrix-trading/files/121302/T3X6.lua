-- More information about this indicator can be found at:
-- http://www.fxcodebase.com/code/viewtopic.php?f=17&t=66681

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
function Init()
    indicator:name("Triple Exponential Moving Average");
    indicator:description("Triple Exponential Moving Average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 8,2,2000);
	indicator.parameters:addDouble("b", "b", "b", 0.618, 0, 2000);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("width", "TEMA Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "TEMA Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
    indicator.parameters:addColor("TC", "Color of TEMA", "Color of TEMA", core.rgb(0, 255, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Period;

local first;
local source = nil;
local b;
-- Streams block
local TEMA = nil;
local EMA1, EMA2, EMA3, EMA4, EMA5, EMA6;
local TC = nil;
local b, b2, b3, c1, c2, c3, c4;
-- Routine
 function Prepare(nameOnly) 
    
    TC = instance.parameters.TC;
    source = instance.source;
	
	 local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

    EMA1 = core.indicators:create("EMA", source, Period);
    EMA2 = core.indicators:create("EMA", EMA1.DATA, Period);
    EMA3 = core.indicators:create("EMA", EMA2.DATA, Period);
	EMA4 = core.indicators:create("EMA", EMA3.DATA, Period);
	EMA5 = core.indicators:create("EMA", EMA4.DATA, Period);
	EMA6 = core.indicators:create("EMA", EMA5.DATA, Period);
    first = EMA6.DATA:first();
	
	Period = instance.parameters.Period;
	b= instance.parameters.b;
	 
	b2 = (b * b);
	b3 = (b * b * b);
	c1 = -b3;
	c2 = (3 * b2) + (3 * b3);
	c3 = (-6 * b2) - (3 * b) - (3 * b3);
	c4 = 1 + (3 * b) + b3 + (3 * b2);

   
    T3 = instance:addStream("T3", core.Line, name, "T3", TC, first);
	T3:setWidth(instance.parameters.width);
    T3:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
function Update(period,mode)
    EMA1:update(mode);
    EMA2:update(mode);
    EMA3:update(mode);
	EMA4:update(mode);
    EMA5:update(mode);
	EMA6:update(mode); 
	
     if period <  first  then
	 return;
	 end
	 
	 local e1=EMA1.DATA[period];
	 local e2=EMA2.DATA[period];
	 local e3=EMA3.DATA[period];
	 local e4=EMA4.DATA[period];
	 local e5=EMA5.DATA[period];
	 local e6=EMA6.DATA[period];
	 
     T3[period] = c1 * e6 + c2 * e5 + c3 * e4 + c4 * e3;
   
end
 