-- Id: 23735
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67297

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
    indicator:name("Carbon Double Wam");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 
	
	indicator.parameters:addGroup("1. MA Calculation"); 
    indicator.parameters:addInteger("Period1", "1. Period", "", 21, 1, 2000);
	indicator.parameters:addInteger("Period2", "2. Period", "", 3, 1, 2000);
	
	indicator.parameters:addInteger("Lag1", "Primary Lag", "", 1, 1, 2000);
 
    indicator.parameters:addInteger("Period3", "1. Smoothing Period", "", 21, 1, 2000);
	indicator.parameters:addInteger("Period4", "2. Smoothing Period", "", 21, 1, 2000);
	
	indicator.parameters:addInteger("Lag2", "Smoothing Lag", "", 1, 1, 2000);
	
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
    indicator.parameters:addColor("color1", "1. Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	 indicator.parameters:addColor("color2", "2. Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method1, Period1, Period2, Period3, Period4;
local Lag1, Lag2;
local first;
local source = nil;
 
local First1, Second1;
local First2, Second2;
local DataA,DataB;
local A,B;
local C,D;
local E,F;
-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    Period1= instance.parameters.Period1;
	Period2= instance.parameters.Period2;
	Period3= instance.parameters.Period3;
	Period4= instance.parameters.Period4;
    Method= instance.parameters.Method;
    
	
	Lag2= instance.parameters.Lag2;
	Lag1= instance.parameters.Lag1;
	
	
	
	
	local Parameters= Period1  ..  ", " .. Period2 ..  ", " .. Lag1 ..  ", " ..Period3 ..  ", " ..Period4 ..  ", " .. Lag2 ..  ", " .. Method;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    
  
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    A = core.indicators:create(Method, source, Period1);
    B = core.indicators:create(Method, source, Period2);
    
   
	
	DataA1 = instance:addInternalStream(0, 0);
	DataB1  = instance:addInternalStream(0, 0);
		
	C = core.indicators:create(Method, DataA1, Period3);
    D = core.indicators:create(Method, DataB1, Period3);
	
	DataA2 = instance:addInternalStream(0, 0);
	DataB2  = instance:addInternalStream(0, 0);
   
   
    E = core.indicators:create(Method, DataA2, Period4);
    F = core.indicators:create(Method, DataB2, Period4); 
	
	
	first=math.max(E.DATA:first(), F.DATA:first()) 
 
	First1 = instance:addStream("First1" , core.Line, "1. First"," 1. First",instance.parameters.color1, first);
	First1:setWidth(instance.parameters.width1);
    First1:setStyle(instance.parameters.style1);
    First1:setPrecision(math.max(2, source:getPrecision()));
	
	First2 = instance:addStream("First2" , core.Line, "2. First"," 2. First",instance.parameters.color1, first);
	First2:setWidth(instance.parameters.width1);
    First2:setStyle(instance.parameters.style1);
    First2:setPrecision(math.max(2, source:getPrecision()));
	
	Second1 = instance:addStream("Second1" , core.Line, "1. Second","1. Second",instance.parameters.color2, first);
	Second1:setWidth(instance.parameters.width2);
    Second1:setStyle(instance.parameters.style2);
    Second1:setPrecision(math.max(2, source:getPrecision()));
	
	Second2 = instance:addStream("Second2" , core.Line, "2. Second","2. Second",instance.parameters.color2, first);
	Second2:setWidth(instance.parameters.width2);
    Second2:setStyle(instance.parameters.style2);
    Second2:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    A:update(mode);
    B:update(mode);
	
	
    if period < math.max(A.DATA:first(), B.DATA:first())  +math.max(Lag1,Lag2)  then
	return;
	end
	
	DataA1[period]=A.DATA[period]-A.DATA[period-Lag1];
	DataB1[period]=B.DATA[period]-B.DATA[period-Lag2];
	
	
	C:update(mode);
    D:update(mode);
	
	
	if period < math.max(C.DATA:first(), D.DATA:first())+math.max(Lag1,Lag2) then
	return;
	end
	
	
	DataA2[period]=C.DATA[period]-C.DATA[period-Lag1];
	DataB2[period]=D.DATA[period]-D.DATA[period-Lag2];
	
	E:update(mode);
    F:update(mode);
	
	
	if period < math.max(E.DATA:first(), F.DATA:first()) then
	return;
	end
		
    First1[period]=E.DATA[period]/source:pipSize();
    Second1[period]=F.DATA[period]/source:pipSize();

    First2[period]=-E.DATA[period]/source:pipSize();
    Second2[period]=-F.DATA[period]/source:pipSize();
				  
end

