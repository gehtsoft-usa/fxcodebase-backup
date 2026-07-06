-- Id: 12777
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61365

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Deviation Oscillator");
    indicator:description("Deviation Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addInteger("Period1", "Period", "Period",40, 1,2000);
    indicator.parameters:addInteger("Period2", "Period", "Period",80, 1,2000);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Style");	 
 
	
	indicator.parameters:addColor("color", "Line Color", "Color of Line", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first1,first2;
local source = nil;

-- Streams block
local A = nil;
 
local MA;
 local pd;
local Period1,Period2 ;
local Method;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Method=instance.parameters.Method;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. Period1 .. ", " .. Period2.. ", " .. Method.. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	 MA= core.indicators:create(Method, source,Period1);
	 
	 pd = instance:addInternalStream(0, 0);
	
	first1 =MA.DATA:first();
	first2=first1+Period2;

    
        A = instance:addStream("Deviation", core.Line, name, "Deviation", instance.parameters.color, first2);
		A:setWidth(instance.parameters.width );
        A:setStyle(instance.parameters.style );
		
		A:setPrecision(math.max(2, instance.source:getPrecision()));
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
 

MA:update(mode);	

if period< first1  then
return;
end

pd[period]=source [period]- MA.DATA[period];

if period< first2  then
return;
end

local lpd,hpd=mathex.minmax(pd, period-Period2,period);

local nf=200/(hpd-lpd);
	 
A[period]=((pd[period]-lpd)*nf)-100;
end
 