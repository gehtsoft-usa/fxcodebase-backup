-- Id: 
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=69098

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("RSI + MA of RSI");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

	
	indicator.parameters:addGroup("RSI Calculation");
	indicator.parameters:addInteger("Period", "Period", "", 14, 1, 1000);
    indicator.parameters:addGroup("MA Calculation");
    indicator.parameters:addInteger("MA_Period", "Period", "", 14, 1, 1000);
	
	indicator.parameters:addString("MA_Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("MA_Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MA_Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MA_Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MA_Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MA_Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MA_Method", "WMA", "WMA" , "WMA");
 
 
	indicator.parameters:addGroup("RSI Line Style");
	indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("MA Line Style");
	indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
	indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

 
local first;
local source = nil;
local MA_Period, MA_Method;
 


local Period;

local RSI,MA;
local rsi, ma;

 function Prepare(nameOnly)   
 
 
    Period = instance.parameters.Period;
	MA_Period = instance.parameters.MA_Period;
	MA_Method = instance.parameters.MA_Method;

 
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " ..  Period .. ", " ..  MA_Period .. ", " ..  MA_Method .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

  

	source = instance.source;
	
	
	
	rsi=core.indicators:create("RSI",  source  ,  Period);
	ma=core.indicators:create(MA_Method,  rsi.DATA,  MA_Period);
 
	
	first= rsi.DATA:first();

    
	RSI = instance:addStream("RSI", core.Line, "RSI", "RSI", instance.parameters.color1, first);
	RSI:setWidth(instance.parameters.width1);
    RSI:setStyle(instance.parameters.style1);
    RSI:setPrecision(math.max(2, source:getPrecision()));

    MA= instance:addStream("MA", core.Line, "MA", "MA", instance.parameters.color2, first);
    MA:setPrecision(math.max(2, instance.source:getPrecision()));
	MA:setWidth(instance.parameters.width2);
    MA:setStyle(instance.parameters.style2);
 
	
 
	
	
	
 
	
	RSI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	RSI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
	
	
 
		
end

-- Indicator calculation routine
function Update(period, mode)
	
    
			if period < first then 
			return;
			end
	

    
			   rsi:update(mode);
			   ma:update(mode); 
	 
		
	MA[period]=ma.DATA[period];			
    RSI[period]=rsi.DATA[period];		
		
 end


