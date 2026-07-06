-- Id: 15729

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63289

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


function Init()
    indicator:name("Heikin Ashi Trend Bars");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator); 
    indicator:setTag("replaceSource", "t");
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

    indicator.parameters:addInteger("Period", "Periods", "", 34, 1, 1000);
    indicator.parameters:addBoolean("Show", "Show MA", "", true);
   
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("UP", "Color of Up Candel", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DOWN", "Color of Down Candle", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("NEUTRAL", "Color of Neutral Candle", "", core.rgb(128,128,128));
	
	indicator.parameters:addColor("color", "Color of MA Line", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end
 
local iopen = nil;
local ihigh = nil;

local open = nil;
local high = nil;
local low = nil;
local close = nil;

local first;
local UP, DOWN,NEUTRAL;
local Open, Close;

local Show;

local color;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
   
    -- was missing, so N1 was not set
    Period = instance.parameters.Period;
	Method= instance.parameters. Method;
	Show= instance.parameters.Show;
	
	UP = instance.parameters.UP;
	DOWN = instance.parameters.DOWN;
    NEUTRAL= instance.parameters.NEUTRAL;
	
	color= instance.parameters.color;

    first = source.close:first() ;
	
    iopen = instance:addInternalStream(first, 0);
    iclose = instance:addInternalStream(first, 0);
    
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    Open = core.indicators:create(Method, iopen, Period);
	Close = core.indicators:create(Method, iclose, Period);
	
	 local name = "Heikin Ashi Trend Bars" .. "(" .. source:name() .. "," .. Method .. "," .. Period.. ")"
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	
    if Show then
    MA = instance:addStream("MA", core.Line, name, "MA", color, Open.DATA:first());
	MA:setWidth(instance.parameters.width);
    MA:setStyle(instance.parameters.style);
	else
	MA = instance:addInternalStream(Open.DATA:first(), 0);
    end	
	
   
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("HAS", "HAS", open, high, low, close);
end

-- Indicator calculation routine
function Update(period, mode)
 
 
        if period  < first then
		open:setColor(period, NEUTRAL);	
		return;
		end
		
		
            iclose[period] =  (source.open[period] + source.high[period] + source.low[period] + source.close[period])/4;
    
	        if period== first then
			iopen[period]=(source.open[period] + source.close[period]) / 2
			else
			iopen[period]=(iopen[period-1] + iclose[period-1]) / 2
			end
	
      
        Open:update(mode);
        Close:update(mode);
		
		
		if period < Open.DATA:first() then
		return;
		end
		
  
        MA[period]= (Open.DATA[period] + Close.DATA[period])/2

        open[period] = source.open[period];
        close[period] = source.close[period];
        high[period] = source.high[period];
        low[period] = source.low[period];
		
		
		if source.typical[period] > MA[period] then
		open:setColor(period, UP);	
		else
		open:setColor(period, DOWN);		 
		end		
   
end
 