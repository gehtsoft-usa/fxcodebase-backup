-- Id: 22132
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66586

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

function Init()
    indicator:name("Profit Matrix");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("1. MA Calculation"); 
    indicator.parameters:addInteger("Period1", "Period", "", 7, 2, 2000);
 
	indicator.parameters:addString("Price1", "Power Price", "", "close");
	indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");
	
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("2. MA Calculation"); 
    indicator.parameters:addInteger("Period2", "Period", "", 21, 2, 2000);
 
	indicator.parameters:addString("Price2", "Power Price", "", "close");
	indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");
	
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("BB Calculation"); 
	indicator.parameters:addString("Price3", "Power Price", "", "close");
	indicator.parameters:addStringAlternative("Price3","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price3", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price3", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price3", "LOW", "", "low");    
    indicator.parameters:addStringAlternative("Price3", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price3", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price3", "WEIGHTED", "", "weighted");
    indicator.parameters:addInteger("BBPeriod", "Period", "", 15, 2, 2000);
	indicator.parameters:addDouble("BBDeviation", "BB Deviation", "", 1, 0, 2000);
	indicator.parameters:addInteger("BBShift", "BBShift", "", 1, 2, 2000);
 
	
	
 
	

    indicator.parameters:addGroup("Style");	 
	indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);
    indicator.parameters:addColor("Up", "Color of Up", "Color of Up", core.rgb( 0, 255, 0)); 
    indicator.parameters:addColor("Down", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Color of Neutral", "Color of Neutral", core.rgb(128, 128, 128));
	indicator.parameters:addColor("Color", "Color", "Color", core.rgb( 0, 0, 255)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method1, Price1, Period1;
local Method2, Price2, Period2;
local Price3,  BBPeriod, BBDeviation, BBShift; 
local first;
local source = nil;
local ma1, ma2, Top,Bottom; 
local Oscillator;  
local Line1, Line2, Line3,Line4;
local Transparency,Up, Down, Neutral,Color;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    Period1= instance.parameters.Period1;
    Method1= instance.parameters.Method1;
    Price1 = instance.parameters.Price1;
	
	Period2= instance.parameters.Period2;
    Method2= instance.parameters.Method2;
    Price2 = instance.parameters.Price2;
	
	BBPeriod= instance.parameters.BBPeriod;
	BBDeviation= instance.parameters.BBDeviation;
	BBShift= instance.parameters.BBShift;
	Price3= instance.parameters.Price3;
	
	
	Transparency= instance.parameters.Transparency;
	Transparency= 100-Transparency;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Neutral= instance.parameters.Neutral;
	Color= instance.parameters.Color;
			
    source = instance.source;
    
  
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    MA1 = core.indicators:create(Method1, source[Price1], Period1);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
    MA2 = core.indicators:create(Method2, source[Price2], Period2);
	BB = core.indicators:create("BB", source[Price3], BBPeriod, BBDeviation);
    
    first=math.max(MA1.DATA:first(), MA2.DATA:first(), BB.DATA:first())+1;
	
	 
   
 
	Line1 = instance:addInternalStream(0, 0);
	Line2 = instance:addInternalStream(0, 0);
	Line3 = instance:addStream("Line3", core.Line, "", "", Neutral, first);
	Line4 =  instance:addStream("Line4", core.Line, "", "", Neutral, first);
	
	instance:createChannelGroup("Top","Top" , Line3,Line1, Neutral, Transparency);
    instance:createChannelGroup("Bottom","Bottom" , Line4,Line2, Color, Transparency);
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    MA1:update(mode);
    MA2:update(mode);
	BB:update(mode);
	
	
    if period < first then
	return;
	end
	
		
     Line1[period]=math.max(MA1.DATA[period], MA2.DATA[period], BB.TL[period-BBShift]);
	 Line2[period]=math.min(MA1.DATA[period], MA2.DATA[period], BB.BL[period-BBShift]);
	 Line3[period]=math.min(MA1.DATA[period], MA2.DATA[period]);
	 Line4[period]=Line3[period];
	 
	 if MA1.DATA[period]> MA2.DATA[period] then
	 Line3:setColor(period, Up); 
	 else
	 Line3:setColor(period, Down); 
	 end
	 
 
				  
end

