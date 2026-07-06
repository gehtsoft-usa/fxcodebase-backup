-- Id: 15833

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63347

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
    indicator:name("Heiken_Ashi_Exit");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator:setTag("replaceSource", "t")
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "MA Period", "Period" ,  40);
    indicator.parameters:addString("Method", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up Trend Color","Up Trend Color", core.rgb(0,255,0));
	indicator.parameters:addColor("Down", "Down Trend Color","Down Trend Color", core.rgb(255,0,0));
	indicator.parameters:addColor("Neutral", "Neutral Trend Color","Neutral Trend Color", core.rgb(128,128,128));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
 

local Method=nil;
local Period;

local first;
local source = nil;

local open=nil;
local close=nil;
local high=nil;
local low=nil;
local Up, Down, Neutral;
local MA_C, MA_O, MA_H, MA_L;
-- Routine
function Prepare(nameOnly) 
    Period = instance.parameters.Period;
	Method= instance.parameters.Method;
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	Neutral = instance.parameters.Neutral; 
	
    source = instance.source;
   
	
   

    local name = profile:id() .. "(" .. source:name() .. ", "  .. Period .. ", " .. Method .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	 MA_C = core.indicators:create(Method, source.close, Period);
	MA_L = core.indicators:create(Method, source.low, Period);
	MA_H = core.indicators:create(Method, source.high, Period);
	MA_O = core.indicators:create(Method, source.open, Period);
    
    first = MA_C.DATA:first()+1 ;	
    
	
	open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ZONE", "", open, high, low, close);
	
	
end

-- Indicator calculation routine
function Update(period, mode)


    MA_C:update(mode);
    MA_O:update(mode);
	MA_H:update(mode);
	MA_L:update(mode);
	
	
     
	if period < first  or not source:hasData(period) then
	 open:setColor(period, Neutral);		
    return;
    end 
  
	 if (period == first) then
            open[period] = (MA_O.DATA[period - 1] + MA_C.DATA[period - 1]) / 2;
        else
            open[period] = (open[period - 1] + close[period - 1]) / 2;
        end
        close[period] = (MA_O.DATA[period] + MA_H.DATA[period] + MA_L.DATA[period] + MA_C.DATA[period]) / 4;
        high[period] = math.max(open[period], close[period], MA_H.DATA[period]);
        low[period] = math.min(open[period], close[period], MA_L.DATA[period]);			   
   
		        if open[period]< close[period] then 
				open:setColor(period, Up);	
                elseif open[period]> close[period] then 				
				open:setColor(period, Down);			
                else   				
			    open:setColor(period, Neutral);	
                end				
		  
end

