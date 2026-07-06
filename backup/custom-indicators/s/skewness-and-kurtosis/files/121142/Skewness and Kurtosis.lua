-- Id: 22288
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66647

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

function Init()
    indicator:name("Skewness and Kurtosis");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("MA Calculation"); 
    indicator.parameters:addInteger("n", "Period", "", 50, 1, 2000);
 
 
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Skewness Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addColor("color2", "Kurtosis Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method, n,Period;
local Skewness, Kurtosis;
local first;
local source = nil;
local MA;
local X2, X3,X4;

-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    n= instance.parameters.n;
	Period=n;
    Method= instance.parameters.Method;
			
    source = instance.source;
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    MA = core.indicators:create(Method, source, n);    
    first=MA.DATA:first();
	
	X2= instance:addInternalStream(0, 0);
	X3= instance:addInternalStream(0, 0);
	X4= instance:addInternalStream(0, 0);
 
	Skewness = instance:addStream("Skewness" , core.Line, " Skewness"," Skewness",instance.parameters.color1, first);
    Skewness:setPrecision(math.max(2, instance.source:getPrecision()));
	Skewness:setWidth(instance.parameters.width1);
    Skewness:setStyle(instance.parameters.style1);
	
	Kurtosis = instance:addStream("Kurtosis" , core.Line, " Kurtosis"," Kurtosis",instance.parameters.color2, first);
    Kurtosis:setPrecision(math.max(2, instance.source:getPrecision()));
	Kurtosis:setWidth(instance.parameters.width2);
    Kurtosis:setStyle(instance.parameters.style2)
    
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    MA:update(mode);
	
    X2[period]=source[period]*source[period];
	X3[period]=source[period]*source[period]*source[period];
	X4[period]=source[period]*source[period]*source[period]*source[period];
	
    if period < first then
	return;
	end
	

	
	
	local a=mathex.stdev(source, period-Period+1, period);
	local b=MA.DATA[period];	
	local s=a*a*a;
	
	--computation skeweness	
	local Skewprimo=mathex.sum(X3, period-Period+1, period);
    local Skewsecondo=-3*b*mathex.sum(X2, period-Period+1, period);
    local Skewterzo=3*b*b*mathex.sum(source, period-Period+1, period);
     
	 
	local Skewquarto=-b*b*b*n;
	
	Skewness[period]=(Skewprimo+Skewsecondo+Skewterzo+Skewquarto)/(n*s);
	
	
	--computation kurtosis
	
	local kurtprimo=mathex.sum(X4, period-Period+1, period);
	local kurtsecondo=-4*b*mathex.sum(X3, period-Period+1, period);
	local kurtterzo=6*b*b*mathex.sum(X2, period-Period+1, period);
	local kurtquarto=-4*b*b*b*mathex.sum(source, period-Period+1, period);
	local kurtquinto=b*b*b*b*n;
    Kurtosis[period]=((kurtprimo+kurtsecondo+kurtterzo+kurtquarto+kurtquinto)/(n*s*a))-3;
	
				  
end


--[[
a=std[periodo](close)
b=average[periodo](close)
n=periodo
 
s=a*a*a
//computation skeweness
Skewprimo=summation[periodo](close*close*close)
Skewsecondo=-3*b*summation[periodo](close*close)
Skewterzo=3*b*b*summation[periodo](close)
Skewquarto=-b*b*b*n
modskew=(skewprimo+skewsecondo+skewterzo+skewquarto)/(n*s)
//computation kurtosis
kurtprimo=summation[periodo](close*close*close*close)
kurtsecondo=-4*b*summation[periodo](close*close*close)
kurtterzo=6*b*b*summation[periodo](close*close)
kurtquarto=-4*b*b*b*summation[periodo](close)
kurtquinto=+b*b*b*b*n
modkurt=((kurtprimo+kurtsecondo+kurtterzo+kurtquarto+kurtquinto)/(n*s*a))-3
]]
