-- Id: 22301
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66654

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
    indicator:name("TradeNavigator RSI");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
 
	
	
	
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addBoolean("singleRSI", "singleRSI", "", false);
	 indicator.parameters:addInteger("periodRSI", "RSI Period", "", 14, 1, 2000); 
	 indicator.parameters:addInteger("shiftMA1", "MA Shift", "", 0, 0, 2000 ); 
	 indicator.parameters:addInteger("periodTMArsi", " TMA RSI Period", "", 4, 1, 2000); 
	
	indicator.parameters:addGroup("1. MA Calculation"); 
    indicator.parameters:addInteger("Period1", "Period", "", 4, 1, 2000); 
	
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
    indicator.parameters:addInteger("Period2", "Period", "", 5, 1, 2000);
    indicator.parameters:addInteger("shiftMA2", "MA Shift", "", 0, 0, 2000 );
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("3. MA Calculation"); 
    indicator.parameters:addInteger("Period3", "Period", "", 13, 2, 2000);	
	indicator.parameters:addInteger("shiftMA3", "MA Shift", "", 2, 0, 2000 );
	indicator.parameters:addString("Method3", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("Level1", "Overbought Level","", 30);
    indicator.parameters:addDouble("Level2","Oversold Level","", 40);
	indicator.parameters:addDouble("Level3","Oversold Level","", 50);
	indicator.parameters:addDouble("Level4", "Overbought Level","", 60);
    indicator.parameters:addDouble("Level5","Oversold Level","", 70);
	
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
	
 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method1, Period1;
local Method2, Period2; 
local Method3, Period3; 
local singleRSI, periodRSI, periodTMArsi, shiftMA1, shiftMA2, shiftMA3;
local first;
local source = nil;
local MA3, MA2, MA1; 
local Oscillator;  
local RSI,TEMA;
local Transparency;

-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 

    Period1= instance.parameters.Period1;
    Method1= instance.parameters.Method1; 
	
	Period2= instance.parameters.Period2;
    Method2= instance.parameters.Method2; 
	
	Period3= instance.parameters.Period3;
    Method3= instance.parameters.Method3;
	
	
	singleRSI= instance.parameters.singleRSI;
	periodRSI= instance.parameters.periodRSI;
	periodTMArsi= instance.parameters.periodTMArsi;
	shiftMA1= instance.parameters.shiftMA1;
	shiftMA2= instance.parameters.shiftMA2;
	shiftMA3= instance.parameters.shiftMA3;
			
    source = instance.source;
    
	
	assert(core.indicators:findIndicator("TEMA") ~= nil, "Please, download and install TEMA.LUA indicator"); 
  
    RSI = core.indicators:create("RSI", source, periodRSI); 	
	TEMA = core.indicators:create("TEMA", RSI.DATA, periodTMArsi); 
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
	MA1 = core.indicators:create(Method1, RSI.DATA, Period1); 
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
	MA2 = core.indicators:create(Method2, RSI.DATA, Period2); 
    assert(core.indicators:findIndicator(Method3) ~= nil, Method3 .. " indicator must be installed");
	MA3 = core.indicators:create(Method3, RSI.DATA, Period3); 
	
	
	if singleRSI then
    first=TEMA.DATA:first();
	else
	first=math.max(TEMA.DATA:first(), MA1.DATA:first(), MA2.DATA:first(), MA3.DATA:first());
	end
	 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first);
    Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
	
	Oscillator:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Oscillator:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    Oscillator:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    Oscillator:addLevel(instance.parameters.Level4, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    Oscillator:addLevel(instance.parameters.Level5, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
    
 
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    RSI:update(mode); 
	TEMA:update(mode);
	
	if not singleRSI then
	MA1:update(mode); 
	MA2:update(mode);
	MA3:update(mode);
	end
	
	
    if period < first +math.max(shiftMA3, shiftMA2, shiftMA1)then
	return;
	end
	
	if singleRSI then
    Oscillator[period]=TEMA.DATA[period];
	else
	Oscillator[period]=(TEMA.DATA[period-shiftMA1] +MA1.DATA[period-shiftMA2]+MA2.DATA[period]+MA3.DATA[period-shiftMA3])/4;
	end
	
				  
end

 