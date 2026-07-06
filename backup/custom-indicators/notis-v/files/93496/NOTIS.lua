-- Id: 11514
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60533

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
function Init()
    indicator:name("NOTIS % V");
    indicator:description("NOTIS % V");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addInteger("Period", "Period", "Period" , 14);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addString("Type", "Presentation Method", "Presentation Method" , "Components");
    indicator.parameters:addStringAlternative("Type", "Components", "Components" , "Components");
    indicator.parameters:addStringAlternative("Type", "Cumulative", "Cumulative" , "Cumulative");
		
	indicator.parameters:addBoolean("Inverse", "Inverse", "", false);
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Plus_color", "Color of Plus", "Color of Plus", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Minus_color", "Color of Minus", "Color of Minus", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("NOVIS_color", "Color of NOVIS", "Color of NOVIS", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 25);
    indicator.parameters:addDouble("oversold","Oversold Level","", 75);
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
local Method, Period;
-- Streams block
local Plus = nil;
local Minus = nil;
local NOVIS = nil;
local plus, minus;
local PLUS, MINUS;
local Type;
local Inverse;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    Inverse=instance.parameters.Inverse;
	Method=instance.parameters.Method;
	Period=instance.parameters.Period;
	Type=instance.parameters.Type;

    local name = profile:id() .. "(" .. source:name().. ", " ..  Period.. ", " .. Method.. ", " .. Type .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        plus= instance:addInternalStream(0, 0);
        minus= instance:addInternalStream(0, 0);
        
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
        PLUS = core.indicators:create(Method, plus, Period);
        MINUS = core.indicators:create(Method, minus, Period);
        
        first = PLUS.DATA:first();
	
       if Type == "Components" then	
       Plus = instance:addStream("Plus", core.Line, name .. ".Plus", "Plus", instance.parameters.Plus_color, first);
    Plus:setPrecision(math.max(2, instance.source:getPrecision()));
	   Plus:setWidth(instance.parameters.width1);
       Plus:setStyle(instance.parameters.style1);
       Minus = instance:addStream("Minus", core.Line, name .. ".Minus", "Minus", instance.parameters.Minus_color, first);
    Minus:setPrecision(math.max(2, instance.source:getPrecision()));
		Minus:setWidth(instance.parameters.width2);
       Minus:setStyle(instance.parameters.style2);
	   NOVIS= instance:addInternalStream(0, 0);
	   else
	   Plus= instance:addInternalStream(0, 0);
	   Minus= instance:addInternalStream(0, 0);
       NOVIS = instance:addStream("NOVIS", core.Line, name .. ".NOVIS", "NOVIS", instance.parameters.NOVIS_color, first);
    NOVIS:setPrecision(math.max(2, instance.source:getPrecision()));
	   NOVIS:setWidth(instance.parameters.width3);
       NOVIS:setStyle(instance.parameters.style3);
	   
	   NOVIS:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
		NOVIS:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
		
	
	   end
		
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

    plus[period] = source.high[period]-source.close[period];
    minus[period] =  source.close[period]-source.low[period];

    PLUS:update(mode); 
	MINUS:update(mode);
	
    if period < first or not  source:hasData(period) then
	return;
	end
	
	
	
 
	Minus[period] = MINUS.DATA[period];
    Plus[period] =  PLUS.DATA[period];
     
     NOVIS[period] = (Plus[period]/(Plus[period]+Minus[period]))*100;
	
	
	if Inverse then 
	 NOVIS[period]= 100-NOVIS[period];
	 end
	
     
end

