-- Id: 21722
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66292

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
    indicator:name("Relative Chart");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	
	indicator.parameters:addGroup("Calculation");
	
    indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");

    indicator.parameters:addInteger("Period", "Period", "", 10);
	
	indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 0);
    indicator.parameters:addDouble("oversold","Oversold Level","", 0);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);


	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block


local first;
local source = nil;
 
local Period,Method;
local MA;

local Signal;


local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

	
	Period= instance.parameters.Period;
	Method= instance.parameters.Method;
	 
			
    source = instance.source;
	first=source:first()+Period;
	

	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    MA = core.indicators:create(Method, source.median, Period);
	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    open:setPrecision(math.max(2, instance.source:getPrecision()));
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high:setPrecision(math.max(2, instance.source:getPrecision()));
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low:setPrecision(math.max(2, instance.source:getPrecision()));
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close:setPrecision(math.max(2, instance.source:getPrecision()));
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
	
	
	open:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	open:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
    open:addLevel(0, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color); 	
	
    
end

-- Indicator calculation routine
function Update(period, mode)


    MA:update(mode);
	

	
	
    if period < first  then
	return;
	end
	
	
	open[period] = source.open[period]-MA.DATA[period];
	close[period] = source.close[period]-MA.DATA[period];
	high[period] = source.high[period]-MA.DATA[period];
	low[period] = source.low[period]-MA.DATA[period];
 
				  
end


