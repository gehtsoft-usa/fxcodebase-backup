-- Id: 23722
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67290

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


-- Indicator profile initialization routine

function Init()
    indicator:name("Simple moving average arithmetic");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("11. MA Calculation"); 
    indicator.parameters:addInteger("Period11", "Period", "", 14, 1, 2000);
 
	indicator.parameters:addString("Price11", "Power Price", "", "close");
	indicator.parameters:addStringAlternative("Price11","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price11", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price11", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price11", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Price11", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price11", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price11", "WEIGHTED", "", "weighted");
	
	indicator.parameters:addString("Method11", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method11", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method11", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method11", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method11", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method11", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method11", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method11", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method11", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("12. MA Calculation"); 
    indicator.parameters:addInteger("Period12", "Period", "", 28, 1, 2000);
 
	indicator.parameters:addString("Price12", "Power Price", "", "close");
	indicator.parameters:addStringAlternative("Price12","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price12", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price12", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price12", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Price12", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price12", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price12", "WEIGHTED", "", "weighted");
	
	indicator.parameters:addString("Method12", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method12", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method12", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method12", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method12", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method12", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method12", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method12", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method12", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("1. Calculation"); 
	indicator.parameters:addString("Calculation1", "1. Calculation", "" , "0");
	indicator.parameters:addStringAlternative("Calculation1", "0", "" , "0");
    indicator.parameters:addStringAlternative("Calculation1", "1+2", "" , "1+2");
    indicator.parameters:addStringAlternative("Calculation1", "1-2", "" , "1-2");
	indicator.parameters:addStringAlternative("Calculation1", "1", "" , "1");
	indicator.parameters:addStringAlternative("Calculation1", "2", "" , "2");
	indicator.parameters:addStringAlternative("Calculation1", "0-1", "" , "0-1");
	indicator.parameters:addStringAlternative("Calculation1", "0-2", "" , "0-2");
	
	
	indicator.parameters:addGroup("21. MA Calculation"); 
    indicator.parameters:addInteger("Period21", "Period", "", 14, 2, 2000);
 
	indicator.parameters:addString("Price21", "Power Price", "", "close");
	indicator.parameters:addStringAlternative("Price21","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price21", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price21", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price21", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Price21", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price21", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price21", "WEIGHTED", "", "weighted");
	
	indicator.parameters:addString("Method21", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method21", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method21", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method21", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method21", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method21", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method21", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method21", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method21", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("22. MA Calculation"); 
    indicator.parameters:addInteger("Period22", "Period", "", 28, 2, 2000);
 
	indicator.parameters:addString("Price22", "Power Price", "", "close");
	indicator.parameters:addStringAlternative("Price22","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price22", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price22", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price22", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Price22", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price22", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price22", "WEIGHTED", "", "weighted");
	
	indicator.parameters:addString("Method22", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method22", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method22", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method22", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method22", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method22", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method22", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method22", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method22", "WMA", "WMA" , "WMA");
	
	
	
	indicator.parameters:addGroup("2. Calculation"); 
	indicator.parameters:addString("Calculation2", "2. Calculation", "" , "0");
	indicator.parameters:addStringAlternative("Calculation2", "0", "+" , "0");
    indicator.parameters:addStringAlternative("Calculation2", "1+2", "" , "1+2");
    indicator.parameters:addStringAlternative("Calculation2", "1-2", "" , "1-2");
	indicator.parameters:addStringAlternative("Calculation2", "1", "" , "1");
	indicator.parameters:addStringAlternative("Calculation2", "2", "" , "2");
	indicator.parameters:addStringAlternative("Calculation2", "0-1", "" , "0-1");
	indicator.parameters:addStringAlternative("Calculation2", "0-2", "" , "0-2");
	
	
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addString("Calculation", "2. Calculation", "" , "1+2");
    indicator.parameters:addStringAlternative("Calculation", "1+2", "" , "1+2");
    indicator.parameters:addStringAlternative("Calculation", "1-2", "" , "1-2");
	indicator.parameters:addStringAlternative("Calculation", "1", "" , "1");
	indicator.parameters:addStringAlternative("Calculation", "2", "" , "2");
	indicator.parameters:addStringAlternative("Calculation", "0-1", "" , "0-1");
	indicator.parameters:addStringAlternative("Calculation", "0-2", "" , "0-2");
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method11, Price11, Period11;
local Method12, Price12, Period12; 

local Method21, Price21, Period21;
local Method22, Price22, Period22; 
local first;
local source = nil;
 
local Oscillator;  
local Indicator={};

local Calculation1, Calculation2, Calculation;
-- Routine
 function Prepare(nameOnly)   
 
    Calculation1= instance.parameters.Calculation1;
	Calculation2= instance.parameters.Calculation2;
	Calculation= instance.parameters.Calculation;
 
 
 
    Period11= instance.parameters.Period11; 
    Method11= instance.parameters.Method11;
    Price11 = instance.parameters.Price11;
	
	Period12= instance.parameters.Period12;
    Method12= instance.parameters.Method12;
    Price12 = instance.parameters.Price12;
	
	 Period21= instance.parameters.Period21; 
    Method21= instance.parameters.Method21;
    Price21 = instance.parameters.Price21;
	
	Period22= instance.parameters.Period22;
    Method22= instance.parameters.Method22;
    Price22 = instance.parameters.Price22;
	 
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    
    Indicator[1]={};
    assert(core.indicators:findIndicator(Method11) ~= nil, Method11 .. " indicator must be installed");
    Indicator[1][1] = core.indicators:create(Method11, source[Price11], Period11);
    assert(core.indicators:findIndicator(Method12) ~= nil, Method12 .. " indicator must be installed");
    Indicator[1][2] = core.indicators:create(Method12, source[Price12], Period12);
	
	Indicator[2]={};
    assert(core.indicators:findIndicator(Method21) ~= nil, Method21 .. " indicator must be installed");
    Indicator[2][1] = core.indicators:create(Method21, source[Price21], Period21);
    assert(core.indicators:findIndicator(Method22) ~= nil, Method22 .. " indicator must be installed");
    Indicator[2][2] = core.indicators:create(Method22, source[Price22], Period22);
    
    first=math.max(Indicator[1][1].DATA:first(), Indicator[1][2].DATA:first(),Indicator[2][1].DATA:first(), Indicator[2][2].DATA:first());
	

	Oscillator1 = instance:addInternalStream(0, 0);
    Oscillator2 = instance:addInternalStream(0, 0);
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    Indicator[1][1]:update(mode);
    Indicator[1][2]:update(mode);
	Indicator[2][1]:update(mode);
    Indicator[2][2]:update(mode);
	
    if period < first then
	return;
	end
	
	 
	 if Calculation1== "0" then
     Oscillator1[period]=0;
	 elseif Calculation1== "1+2" then
     Oscillator1[period]=Indicator[1][1].DATA[period]+Indicator[1][2].DATA[period];
	 elseif Calculation1== "1-2" then			  
	 Oscillator1[period]=Indicator[1][1].DATA[period]-Indicator[1][2].DATA[period];
	 elseif Calculation1== "1" then
     Oscillator1[period]=Indicator[1][1].DATA[period]
	 elseif Calculation1== "2" then
     Oscillator1[period]=Indicator[1][2].DATA[period]
	 elseif Calculation1== "0-1" then
     Oscillator1[period]=0-Indicator[1][1].DATA[period]
	 elseif Calculation1== "0-2" then
     Oscillator1[period]=0-Indicator[1][2].DATA[period]
	 end
	 
	 
	 
	 
	 if Calculation2== "0" then
     Oscillator2[period]=0;
	 elseif Calculation2== "1+2" then
     Oscillator2[period]=Indicator[2][1].DATA[period]+Indicator[2][2].DATA[period];
	 elseif Calculation2== "1-2" then			  
	 Oscillator2[period]=Indicator[2][1].DATA[period]-Indicator[2][2].DATA[period];
	 elseif Calculation2== "1" then
     Oscillator2[period]=Indicator[2][1].DATA[period]
	 elseif Calculation2== "2" then
     Oscillator2[period]=Indicator[2][2].DATA[period]
	 elseif Calculation2== "0-1" then
     Oscillator2[period]=0-Indicator[2][1].DATA[period]
	 elseif Calculation2== "0-2" then
     Oscillator2[period]=0-Indicator[2][2].DATA[period]
	 end
	 
	 
	 if Calculation== "1+2" then
     Oscillator[period]=Oscillator1[period]+Oscillator2[period];
	 elseif Calculation== "1-2" then			  
	 Oscillator[period]=Oscillator1[period]-Oscillator2[period];
	 elseif Calculation== "1" then
     Oscillator[period]=Oscillator1[period];
	 elseif Calculation== "2" then
     Oscillator[period]=Oscillator2[period];
	 elseif Calculation== "0-1" then
     Oscillator[period]=0-Oscillator1[period];
	 elseif Calculation== "0-2" then
     Oscillator[period]=0-Oscillator2[period];
	 end
end

 
 