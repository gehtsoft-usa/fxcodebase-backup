-- Id: 22693
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=66913
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
    indicator:name("MV Indicator");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("1. MA Calculation"); 
    indicator.parameters:addInteger("Period1", "Period", "", 14, 2, 2000);
 
	
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("2. Shift Calculation"); 
	indicator.parameters:addInteger("Shift", "Shift Period", "", 1, 1, 2000);
	indicator.parameters:addBoolean("Show", "Show Delta", "", false);
	
	indicator.parameters:addGroup("2. MA Calculation"); 
    indicator.parameters:addInteger("Period2", "Period", "", 14, 2, 2000);
	
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Style"); 
	
	
	indicator.parameters:addColor("color1", "Delta Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
   
    indicator.parameters:addColor("color2", "MV Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
    
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method1 , Period1;
local Method2 , Period2; 
local Shift;
local first;
local source = nil;
 
local MV;  
local MA1;
local MA2;
local Show;
local Delta;
-- Routine
 function Prepare(nameOnly)    
 
    Period1= instance.parameters.Period1;
    Method1= instance.parameters.Method1; 
	
	Period2= instance.parameters.Period2;
    Method2= instance.parameters.Method2;
	
	Show= instance.parameters.Show;
 
	Shift= instance.parameters.Shift;
	
	local Parameters= Period1 ..  ", " .. Method1  ..  ", " ..Period2  ..  ", " .. Shift ..  ", " .. Method2 ;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. "," ..   Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
    source = instance.source;
    
  
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    MA1 = core.indicators:create(Method1, source , Period1);
	
	if Show then	
	Delta = instance:addStream("Delta" , core.Line, " Delta"," Delta",instance.parameters.color1, MA1.DATA:first()+Shift);
	Delta:setWidth(instance.parameters.width1);
    Delta:setStyle(instance.parameters.style1);
	else
	Delta = instance:addInternalStream( MA1.DATA:first()+Shift, 0);
	end
	
	
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
    MA2 = core.indicators:create(Method2, Delta, Period2);
    
    first=MA2.DATA:first(); 
 
	MV = instance:addStream("MV" , core.Line, " MV"," MV",instance.parameters.color2, first);
	MV:setWidth(instance.parameters.width2);
    MV:setStyle(instance.parameters.style2);
    
	Delta:setPrecision(math.max(2, instance.source:getPrecision()));
	MV:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
function Update(period, mode) 
 
    MA1:update(mode); 
	
    if period < MA1.DATA[period] +Shift  then
	return;
	end 
		
    Delta[period]=MA1.DATA[period]-MA1.DATA[period-Shift];	

    MA2:update(mode);
    if period < first  then
	return;
	end  
   	
	MV[period]=MA2.DATA[period];
	
end

