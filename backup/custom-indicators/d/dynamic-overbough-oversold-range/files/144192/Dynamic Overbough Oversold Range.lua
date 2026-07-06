-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71626

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|SOL Address            : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                           |
--|Cardano/ADA            : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv             |  
--|Dogecoin Address       : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                     |
--|SHIB Address           : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                             |                                
--+------------------------------------------------------------------------------------------------+

-- Indicator profile initialization routine

function Init()
    indicator:name("Dynamic Overbough Oversold Range");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 

    indicator.parameters:addBoolean("Relative", "Relative", "Relative", false);
 
	indicator.parameters:addString("Method", "MA Method", "Method" , "WMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
    indicator.parameters:addInteger("Period", "RSI Period ", "", 14, 1, 2000);
    indicator.parameters:addInteger("rangeLength", "Overbought/Oversold Range ", "", 50, 1, 2000);
 
   
 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_DOT );
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 1, 1, 5);
	
	indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_DOT );
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 1, 1, 5);
	
	
	indicator.parameters:addColor("color3", "Central Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_DOT );
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 1, 1, 5);
	
 
	indicator.parameters:addColor("color4", "RSI Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("style4", "Line Style", "", core.LINE_DOT );
    indicator.parameters:setFlag("style4", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width4", "Line Width", "", 1, 1, 5);	
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
	
	indicator.parameters:addDouble("Level1", "1. Level","", 30);
	indicator.parameters:addDouble("Level2", "2. Level","", 50);
	indicator.parameters:addDouble("Level3", "3. Level","", 70); 


	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method, Period,rangeLength;
local RSI;
local first;
local source = nil;
local Range,Low;
local Top,Bottom,Central;  
local MA, MA1,MA2;
local rsi, Min,Max ;
-- Routine
 function Prepare(nameOnly)   

    Method= instance.parameters.Method;
	Period= instance.parameters.Period;
	rangeLength= instance.parameters.rangeLength;
	Relative= instance.parameters.Relative;
   
	
	local Parameters= Method ..  ", " .. Period ..  ", " .. rangeLength;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
     
    RSI = core.indicators:create("RSI", source, Period);
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	
   
	Min = instance:addInternalStream(0, 0);
	Max = instance:addInternalStream(0, 0);	
	
	MA1= core.indicators:create(Method, Min, Period);
	MA2= core.indicators:create(Method, Max, Period);
	--MA= core.indicators:create(Method, source, Period);	
	first=MA2.DATA:first();
 
	
	rsi = instance:addStream("RSI" , core.Line, "RSI","RSI",instance.parameters.color4, first);
	rsi:setWidth(instance.parameters.width3);
    rsi:setStyle(instance.parameters.style3);
    rsi:setPrecision(math.max(2, source:getPrecision()));
	
	if Relative then
    rsi:addLevel(instance.parameters.Level1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    rsi:addLevel(instance.parameters.Level2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    rsi:addLevel(instance.parameters.Level3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);	
	end
	
	
	if 	not  Relative then
	Top = instance:addStream("Top" , core.Line, "Top","Top",instance.parameters.color1, first);
	Top:setWidth(instance.parameters.width1);
    Top:setStyle(instance.parameters.style1);
    Top:setPrecision(math.max(2, source:getPrecision()));
	
	Bottom = instance:addStream("Bottom" , core.Line, "Bottom","Bottom",instance.parameters.color2, first);
	Bottom:setWidth(instance.parameters.width2);
    Bottom:setStyle(instance.parameters.style2);
    Bottom:setPrecision(math.max(2, source:getPrecision()));

	Central = instance:addStream("Central" , core.Line, "Central","Central",instance.parameters.color3, first);
	Central:setWidth(instance.parameters.width3);
    Central:setStyle(instance.parameters.style3);
    Central:setPrecision(math.max(2, source:getPrecision()));	
	
	else
	Top = instance:addInternalStream(0, 0);
	Bottom = instance:addInternalStream(0, 0);		
	Central = instance:addInternalStream(0, 0);			
	end
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    RSI:update(mode);
	
	if period < RSI.DATA:first() + rangeLength  then
	return;
	end 
	
	local min,max= mathex.minmax(RSI.DATA, period-rangeLength+1, period );
    Min[period]=min;
	Max[period]=max;
	
	
	
	--MA:update(mode);	
	MA1:update(mode);
	MA2:update(mode);
	
	if period < RSI.DATA:first() + rangeLength +Period then
	return;
	end 
	

    
	if Relative then
	rsi[period] =instance.parameters.Level1+  ( RSI.DATA[period] - MA1.DATA[period])/(( MA2.DATA[period]- MA1.DATA[period])/(math.abs(instance.parameters.Level1-instance.parameters.Level3))); 
	else
    rsi[period] = RSI.DATA[period];
    Top[period] = MA2.DATA[period];
	Bottom[period] = MA1.DATA[period];
	
	
	Central[period]= Bottom[period] + (Top[period]- Bottom[period])/2;
	end
	
	
 
	
	
end
