-- Id: 22467
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66832

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
    indicator:name("Bollinger Bands on MACD");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Fast Calculation"); 
    indicator.parameters:addInteger("Period1", "Fast Period", "", 38, 1, 2000); 
	indicator.parameters:addString("Method1", "Fat MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
   
	
	indicator.parameters:addGroup("Slow Calculation"); 
	indicator.parameters:addInteger("Period2", "Slow Period", "", 120, 1, 2000); 
	indicator.parameters:addString("Method2", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("MA Calculation"); 
	indicator.parameters:addInteger("Period3", "MA Period", "", 20, 1, 2000); 
	indicator.parameters:addString("Method3", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addDouble("Multiplier", "Multiplier", "", 1.1, 0, 2000); 
	
	indicator.parameters:addGroup("MACD Line Style"); 	
    indicator.parameters:addColor("Up", "MACD Line Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "MACD Line Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	indicator.parameters:addGroup("Top Line Style"); 	
    indicator.parameters:addColor("color2", "MACD Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_DASH );
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 1, 1, 5);
	
	
	indicator.parameters:addGroup("Bottom Line Style"); 	
    indicator.parameters:addColor("color3", "MACD Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_DASH );
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 1, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period1,Period2;
local Method1, Method2;
local Method3, Method3;
local first;
local source = nil;
 
local MACD;  
local Top;
local Bottom;
local MA1, MA2,MA3;
local Multiplier;
local Up, Down;
-- Routine
 function Prepare(nameOnly)   
    Period1= instance.parameters.Period1; 
	Period2= instance.parameters.Period2; 
	Period3= instance.parameters.Period3; 
	Method1= instance.parameters.Method1;
	Method2= instance.parameters.Method2;
	Method3= instance.parameters.Method3;
	Multiplier= instance.parameters.Multiplier;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	
	local Parameters= Period1 ..  ", " ..Method1 ..  ", " ..Period2..  ", " ..Method2..  ", " ..Period3..  ", " ..Method3..  ", " ..Multiplier;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    
  
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    MA1 = core.indicators:create(Method1, source, Period1);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
    MA2 = core.indicators:create(Method2, source, Period2);
    
    first=math.max(MA1.DATA:first(),MA2.DATA:first());
	
	 
   
    Top = instance:addStream("Top" , core.Line, " Top"," Top",instance.parameters.color2, first+Period3);
	Top:setWidth(instance.parameters.width2);
    Top:setStyle(instance.parameters.style2);
	
	
	Bottom = instance:addStream("Bottom" , core.Line, " Bottom"," Bottom",instance.parameters.color3, first+Period3);
	Bottom:setWidth(instance.parameters.width3);
    Bottom:setStyle(instance.parameters.style3);
	
   
 
	MACD = instance:addStream("MACD" , core.Line, " MACD"," MACD",Up, first);
	MACD:setWidth(instance.parameters.width1);
    MACD:setStyle(instance.parameters.style1);
	
    assert(core.indicators:findIndicator(Method3) ~= nil, Method3 .. " indicator must be installed");
	MA3 = core.indicators:create(Method3, MACD, Period3);
	
	
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
	Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
	MACD:setPrecision(math.max(2, instance.source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    MA1:update(mode);
    MA2:update(mode);
	
	
    if period < first then
	return;
	end
	
		
     MACD[period]=MA1.DATA[period]-MA2.DATA[period];
	 
	 if MACD[period] > MACD[period-1] then
	 MACD:setColor(period, Up);
	 else
	 MACD:setColor(period, Down);
	 end
	 
	 
	 
	 MA3:update(mode);
	
	
    if period < first+Period3 then
	return;
	end
	
	local Deviation= mathex.stdev(MACD, period-Period3+1, period);
	Top[period]= MA3.DATA[period]+Multiplier*Deviation;
    Bottom[period]= MA3.DATA[period]-Multiplier*Deviation;
 
				  
end

