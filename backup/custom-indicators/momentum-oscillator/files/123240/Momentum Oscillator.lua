-- Id: 23571
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67245

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
    indicator:name("Momentum Oscillator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("1. MA Calculation"); 
    indicator.parameters:addInteger("Period1", "Period", "", 3, 1, 2000);
 
	indicator.parameters:addString("Price1", "Power Price", "", "close");
	indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");
	
	indicator.parameters:addString("Method1", "MA Method", "Method" , "VOLUME WEIGHTED MOVING AVERAGE");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method1", "VWMA", "VWMA" , "VOLUME WEIGHTED MOVING AVERAGE");
	
	indicator.parameters:addGroup("2. MA Calculation"); 
    indicator.parameters:addInteger("Period2", "Period", "", 10, 1, 2000);
 
	indicator.parameters:addString("Price2", "Power Price", "", "close");
	indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");
	
	indicator.parameters:addString("Method2", "MA Method", "Method" , "VOLUME WEIGHTED MOVING AVERAGE");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	indicator.parameters:addStringAlternative("Method2", "VWMA", "VWMA" , "VOLUME WEIGHTED MOVING AVERAGE");
	
 
	indicator.parameters:addGroup("3. MA Calculation"); 
    indicator.parameters:addInteger("Period3", "Period", "", 10, 1, 2000);
 
	
	indicator.parameters:addString("Method3", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
 
	
	indicator.parameters:addGroup("Oscillator Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("Signal Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block



local Method1 , Period1,Price1;
local Method2 , Period2,Price2; 
local Method3, Period3; 

local first;
local source = nil;
 
local Oscillator;  
local MA1,MA2,MA3;

-- Routine
 function Prepare(nameOnly)    
 
    Period1= instance.parameters.Period1;
    Method1= instance.parameters.Method1;
    Price1= instance.parameters.Price1;
	
	Period2= instance.parameters.Period2;
    Method2= instance.parameters.Method2;
	Price2= instance.parameters.Price2;
 
	
	Period3= instance.parameters.Period3;
    Method3= instance.parameters.Method3; 
	
	
	local Parameters= Period1 ..  ", " .. Method1..  ", " .. Price1  ..  ", " ..Period2 ..  ", " .. Method2 ..  ", " .. Price2..  ", " ..Period3 ..  ", " .. Method3;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
	if Method1==  "VOLUME WEIGHTED MOVING AVERAGE" then
	assert(core.indicators:findIndicator(Method1) ~= nil, "Please, download and install VOLUME WEIGHTED MOVING AVERAGE.LUA indicator");
	elseif Method2==  "VOLUME WEIGHTED MOVING AVERAGE"  then
	assert(core.indicators:findIndicator(Method2) ~= nil, "Please, download and install VOLUME WEIGHTED MOVING AVERAGE.LUA indicator");
	end
			
    source = instance.source;
    
    if Method1==  "VOLUME WEIGHTED MOVING AVERAGE" then
	MA1 = core.indicators:create(Method1, source , Period1); 
	else
    MA1 = core.indicators:create(Method1, source[Price1] , Period1); 
	end
	
	if Method2==  "VOLUME WEIGHTED MOVING AVERAGE" then
    MA2 = core.indicators:create(Method2, source  , Period2);
	else
	 MA2 = core.indicators:create(Method2, source[Price2] , Period2);
	end
    
	
    first=math.max(MA1.DATA:first(), MA2.DATA:first());
	
	
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color1, first);
	Oscillator:setWidth(instance.parameters.width1);
    Oscillator:setStyle(instance.parameters.style1);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	 
    assert(core.indicators:findIndicator(Method3) ~= nil, Method3 .. " indicator must be installed");
	MA3 = core.indicators:create(Method3, Oscillator, Period3);
	 
	
	
	Signal = instance:addStream("Signal" , core.Line, " Signal"," Signal",instance.parameters.color2, MA3.DATA:first());
	Signal:setWidth(instance.parameters.width2);
    Signal:setStyle(instance.parameters.style2);
    Signal:setPrecision(math.max(2, source:getPrecision()));
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    MA1:update(mode);
    MA2:update(mode);
	
	
    if period < first then
	return;
	end
	
		
     Oscillator[period]=MA1.DATA[period]-MA2.DATA[period];
	 
	 
	  MA3:update(mode);
	  
	  if period < MA3.DATA:first() then
	return;
	end
	
	Signal[period]=MA3.DATA[period];
				  
end
 

