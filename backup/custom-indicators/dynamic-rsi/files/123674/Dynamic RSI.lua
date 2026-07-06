-- Id: 23821
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67317

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
    indicator:name("Dynamic RSI");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 

 
 
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
    indicator.parameters:addInteger("Lb", "LookBack Period ", "", 60, 1, 2000);
	
	indicator.parameters:addDouble("DZbuy", "Buy Zone Probability ", "", 0.1 );
	indicator.parameters:addDouble("DZsell", "Sell Zone Probability ", "", 0.1 );
 
 
   
 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Top Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_DOT );
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 1, 1, 5);
	
	indicator.parameters:addColor("color2", "Bottom Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_DOT );
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 1, 1, 5);
	
	
	indicator.parameters:addColor("color3", "Cental Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_DOT );
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 1, 1, 5);
	
	indicator.parameters:addColor("color4", "Neutral RSI Line Color", "", core.rgb(0, 255, 0));
 
	indicator.parameters:addInteger("style4", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width4", "Line Width", "", 3, 1, 5);
	
	
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("L1", "Overbought Level","", 70);
    indicator.parameters:addDouble("L2","Oversold Level","", 60);
	indicator.parameters:addDouble("L3", "Overbought Level","", 40);
    indicator.parameters:addDouble("L4","Oversold Level","", 30);
	
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);


	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method, Period, Lb, DZbuy, DZsell;
local RSI;
local first;
local source = nil;
local Range,Low;
local Top,Bottom,Central;  
local MA1,MA2;
local rsi;
-- Routine
 function Prepare(nameOnly)   
 
 
    Lb= instance.parameters.Lb;
	DZbuy= instance.parameters.DZbuy;
	DZsell= instance.parameters.DZsell;
    Method= instance.parameters.Method;
	Period= instance.parameters.Period;
   
	
	local Parameters= Method ..  ", " .. Period  ..  ", " ..Lb ..  ", " .. DZbuy ..  ", " .. DZsell;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    
   
	Range = instance:addInternalStream(0, 0);
	Low = instance:addInternalStream(0, 0);
	 
	
    
    RSI = core.indicators:create("RSI", source, Period);
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA1= core.indicators:create(Method, Low, Period);
	MA2= core.indicators:create(Method, Range, Period);
	
	first=MA2.DATA:first();
    
	rsi = instance:addStream("RSI" , core.Line, "RSI","RSI",instance.parameters.color4, first);
    rsi:setWidth(instance.parameters.width4);
    rsi:setStyle(instance.parameters.style4);
    rsi:setPrecision(math.max(2, source:getPrecision()));
	
	
	Central = instance:addStream("Central" , core.Line, "Central","Central",instance.parameters.color3, first);
	Central:setWidth(instance.parameters.width3);
    Central:setStyle(instance.parameters.style3);
    Central:setPrecision(math.max(2, source:getPrecision()));
	
	Central:addLevel(instance.parameters.L1, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Central:addLevel(instance.parameters.L2, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
	Central:addLevel(instance.parameters.L3, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	Central:addLevel(instance.parameters.L4, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 
    Central:addLevel(50, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 	
	
	
	Top = instance:addStream("Top" , core.Line, "Top","Top",instance.parameters.color1, first);
	Top:setWidth(instance.parameters.width1);
    Top:setStyle(instance.parameters.style1);
    Top:setPrecision(math.max(2, source:getPrecision()));
	
	Bottom = instance:addStream("Bottom" , core.Line, "Bottom","Bottom",instance.parameters.color2, first);
	Bottom:setWidth(instance.parameters.width2);
    Bottom:setStyle(instance.parameters.style2);
    Bottom:setPrecision(math.max(2, source:getPrecision()));
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    RSI:update(mode);
	
	if period < RSI.DATA:first() + Lb  then
	return;
	end 
	
	local min,max= mathex.minmax(RSI.DATA, period-Lb+1, period );
    Range[period]=max-min;
	Low[period]=min;
	
	
	MA1:update(mode);
	MA2:update(mode);
	
	if period < RSI.DATA:first() + Lb +Period then
	return;
	end 
	
	if period < 3 then
	return;
	end 
    
		
    Central[period] = (MA2.DATA[period]*0.50)+MA1.DATA[period];
    Top[period] = max-Central[period]*DZbuy;
    Bottom[period] = min+Central[period]*DZsell;
				
    rsi[period] =  ( 4 * RSI.DATA[period] + 3 * RSI.DATA[period-1] + 2 * RSI.DATA[period-2] + RSI.DATA[period-3] ) / 10	;
    
	local R,G,B=0,0,0;
	
	if rsi[period] > Central[period] then 
	 R=0
	 G=255
	else
	 R=255
	 G=0
	end 
	
	rsi:setColor(period, core.rgb(R, G, B));
	
	
end


 