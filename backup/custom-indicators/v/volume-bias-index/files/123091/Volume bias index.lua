-- Id: 23509
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67221

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
    indicator:name("Volume bias index");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	

	
	indicator.parameters:addGroup("Volume Calculation"); 
    indicator.parameters:addInteger("Period1", "Volume Period", "", 34, 2, 2000);
    
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
 
	
	indicator.parameters:addGroup("Smoothing Calculation"); 
    indicator.parameters:addInteger("Period2", "Period", "", 1, 2, 2000);
   
	
	indicator.parameters:addString("Method2", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("Trigger Calculation"); 
    indicator.parameters:addInteger("Period3", "Period", "", 1, 2, 2000);
 
	
	indicator.parameters:addString("Method3", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Bias Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("Smoothing Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("Trigger Line Style"); 	
    indicator.parameters:addColor("color3", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5);
	
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
	
	indicator.parameters:addDouble("Neutral1", "Neutral Level","", 55);
    indicator.parameters:addDouble("Neutral2","Oversold Level","", 45);
	
	
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);


	
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period1,Method1;
local Method2, Period2; 
local Method3, Period3; 
local first;
local source = nil;
 
local Bias, Smoothing, Trigger;  
local MA2,MA3;
local Up,Down;
-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    Period1= instance.parameters.Period1;
    Method1= instance.parameters.Method1;
	
	Period2= instance.parameters.Period2;
    Method2= instance.parameters.Method2; 
	
	Period3= instance.parameters.Period3;
    Method3= instance.parameters.Method3; 
	
	local Parameters= Period1..  ", " .. Method1  ..  ", " ..Period2 ..  ", " .. Method2  ..  ", " ..Period3 ..  ", " .. Method3 ;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    
    Up= instance:addInternalStream(0, 0);
    Down= instance:addInternalStream(0, 0);
   
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
    MA1 = core.indicators:create(Method1, Up, Period1);
	MA2 = core.indicators:create(Method1, Down, Period1);
    
      
	Bias = instance:addStream("Bias" , core.Line, " Bias"," Bias",instance.parameters.color1, MA2.DATA:first());
	Bias:setWidth(instance.parameters.width1);
    Bias:setStyle(instance.parameters.style1);
    Bias:setPrecision(math.max(2, source:getPrecision()));
	
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
	MA3 = core.indicators:create(Method2, Bias, Period2);
	
	Smoothing = instance:addStream("Smoothing" , core.Line, " Smoothing"," Smoothing",instance.parameters.color2, MA3.DATA:first());
	Smoothing:setWidth(instance.parameters.width2);
    Smoothing:setStyle(instance.parameters.style2);
    Smoothing:setPrecision(math.max(2, source:getPrecision()));
	
	
    assert(core.indicators:findIndicator(Method3) ~= nil, Method3 .. " indicator must be installed");
	MA4 = core.indicators:create(Method3, Smoothing, Period3);
	
	
	Trigger = instance:addStream("Trigger" , core.Line, " Trigger"," Trigger",instance.parameters.color3, MA4.DATA:first());
	Trigger:setWidth(instance.parameters.width3);
    Trigger:setStyle(instance.parameters.style3);
    Trigger:setPrecision(math.max(2, source:getPrecision()));
	
	
	Trigger:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Trigger:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
	Trigger:addLevel(instance.parameters.Neutral1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Trigger:addLevel(instance.parameters.Neutral2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
    if period < source:first()+1 then
	return;
	end
	
	
    if source.close[period]>= source.close[period-1]  then
	Up[period]=source.volume[period];
	Down[period]=0;
	else
	Down[period]=source.volume[period];
	Up[period]=0;
	end
 
    MA1:update(mode);
    MA2:update(mode);
	
	
    if period < MA2.DATA:first() then
	return;
	end
	
	if MA2.DATA[period]~=0 then	
    Bias[period]=100-(100/(1+(MA1.DATA[period]/MA2.DATA[period])));
	end			

	
	 
    MA3:update(mode);
	
	
    if period < MA3.DATA:first() then
	return;
	end
	
	Smoothing[period]=MA3.DATA[period];
	
	
	MA4:update(mode);
	
	
    if period < MA4.DATA:first() then
	return;
	end
	
	Trigger[period]=MA4.DATA[period];
	
end


 