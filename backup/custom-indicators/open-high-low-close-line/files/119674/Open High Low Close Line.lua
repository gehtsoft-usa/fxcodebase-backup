-- Id: 21598
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=66217


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
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Open High Low Close Line");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator); 

	indicator.parameters:addGroup("Selector");
	indicator.parameters:addBoolean("ShowLines", "Show Lines", "", true);
	indicator.parameters:addBoolean("ShowStreams", "Show Streams", "", false);
	
     indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Number of Periods", "", 1, 1, 10000);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");

  
	
    indicator.parameters:addGroup("Band Style");
    indicator.parameters:addColor("close_color", "Close Line Color","", core.rgb(0, 0, 255));
	indicator.parameters:addColor("high_color", "High Line Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("low_color", "Low Line Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("open_color", "Open Line Color","", core.rgb(128, 128, 128));
	 
    indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
	
	
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Period;
local first;
local source = nil;
local Method; 
local Open,open,close,Close,High,high,low,Low;
local ShowLines, ShowStreams;
 
 
-- Routine
function Prepare(nameOnly)   
 
    Period = instance.parameters.Period;
	Method= instance.parameters.Method;
	ShowLines= instance.parameters.ShowLines;
	ShowStreams= instance.parameters.ShowStreams;
 
    source = instance.source;	
		
	first =source:first(period)+Period ;
	 
	


    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ", " .. Method .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
 
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	Close = core.indicators:create(Method, source.close, Period);
	High = core.indicators:create(Method, source.high, Period);
	Low = core.indicators:create(Method, source.low, Period);
	Open = core.indicators:create(Method, source.open, Period);
	
	
	if ShowStreams then
    open = instance:addStream("Open", core.Line, name .. ".Open", "Open", instance.parameters.open_color, first)
    open:setWidth(instance.parameters.width);
    open:setStyle(instance.parameters.style);
	
	high = instance:addStream("High", core.Line, name .. ".High", "High", instance.parameters.high_color, first)
    high:setWidth(instance.parameters.width);
    high:setStyle(instance.parameters.style);
	
	low = instance:addStream("Low", core.Line, name .. ".Low", "Low", instance.parameters.low_color, first)
    low:setWidth(instance.parameters.width);
    low:setStyle(instance.parameters.style);
	
	
	close = instance:addStream("Close", core.Line, name .. ".Close", "Close", instance.parameters.close_color, first)
    close:setWidth(instance.parameters.width);
    close:setStyle(instance.parameters.style);
   
    end
	
    
end

-- Indicator calculation routine
function Update(period, mode)

	 
	    Close:update(mode);
		High:update(mode);
		Low:update(mode);
		Open:update(mode); 
		
		if period < first then
		return;
		end
		
		if ShowStreams then
        close[period] = Close.DATA[period];
		open[period] = Open.DATA[period];
		high[period] = High.DATA[period];
		low[period] = Low.DATA[period];
        end
   
     if ShowLines and period== source:size()-1 then
     core.host:execute ("drawLine", 1, source:date(first), Close.DATA[period], source:date(period), Close.DATA[period], instance.parameters.close_color, instance.parameters.style, instance.parameters.width);
	 core.host:execute ("drawLine", 2, source:date(first), Open.DATA[period], source:date(period), Open.DATA[period], instance.parameters.open_color, instance.parameters.style, instance.parameters.width);
	 core.host:execute ("drawLine", 3, source:date(first), High.DATA[period], source:date(period), High.DATA[period], instance.parameters.high_color, instance.parameters.style, instance.parameters.width);
	 core.host:execute ("drawLine", 4, source:date(first), Low.DATA[period], source:date(period), Low.DATA[period], instance.parameters.low_color, instance.parameters.style, instance.parameters.width);
	 end	
end





