-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62872
-- Id: 15057

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
    indicator:name("Advanced fractal");
    indicator:description("Predicts a reversal in the current trend.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Period", "Period",10);
	indicator.parameters:addInteger("FastPeriod", "Fast MA Period", "Period",3);
	indicator.parameters:addString("FastMethod", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("FastMethod", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("FastMethod", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("FastMethod", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("FastMethod", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("FastMethod", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("FastMethod", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("FastMethod", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("FastMethod", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addInteger("SlowPeriod", "Fast MA Period", "Period",3);
	indicator.parameters:addString("SlowMethod", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("SlowMethod", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("SlowMethod", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("SlowMethod", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("SlowMethod", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("SlowMethod", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("SlowMethod", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("SlowMethod", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("SlowMethod", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("DOWN", "Down fractal color", "Down fractal color", core.rgb(255,0,0)); 
	indicator.parameters:addInteger("Size", "Font Size", "", 10, 1 , 100);	 
end

local source;
local up, down; 
local Size;
local Range;
local Period;
local first;
local FastPeriod, SlowPeriod;
local FastMethod, SlowMethod;
local Fast, Slow;
function Prepare(nameOnly)
    source = instance.source;
    Size = instance.parameters.Size;
	Period = instance.parameters.Period;
	FastPeriod= instance.parameters.FastPeriod;
	SlowPeriod= instance.parameters.SlowPeriod;
	FastMethod= instance.parameters.FastMethod;
	SlowMethod= instance.parameters.SlowMethod;
	
	 
  local name = profile:id() ;
    instance:name(name);
    if nameOnly then
        return;
    end
    assert(core.indicators:findIndicator(FastMethod) ~= nil, FastMethod .. " indicator must be installed");
	Fast = core.indicators:create(FastMethod, source.close, FastPeriod);	
    assert(core.indicators:findIndicator(SlowMethod) ~= nil, SlowMethod .. " indicator must be installed");
	Slow = core.indicators:create(SlowMethod, source.open, SlowPeriod);
	
    up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.UP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.DOWN, 0);
	first=math.max(source:first()+Period, Fast.DATA:first(), Slow.DATA:first());
	Range = instance:addInternalStream(0, 0);
end

function Update(period, mode)
 
      Fast:update(mode);
	  Slow:update(mode);
	  
      
	  Range[period]= source.high[period]-source.low[period];
		
       period=period-1;
	   
       if period < first+1 then
	   return;
	   end
	   
	   local Average= mathex.avg(Range, period-Period+1, period);	   
	   
	   up:setNoData (period);
	   down:setNoData (period);
	   
	   if ((Fast.DATA[period] > Slow.DATA[period]) and (Fast.DATA[period-1] < Slow.DATA[period-1]) and (Fast.DATA[period+1] > Slow.DATA[period+1])) then
        
      
			 down:set(period, source.low[period]-Range[period]*0.3, "\225");
        
        elseif ((Fast.DATA[period] < Slow.DATA[period]) and (Fast.DATA[period-1] > Slow.DATA[period-1]) and (Fast.DATA[period+1] < Slow.DATA[period+1])) then
            
			 up:set(period , source.high[period]+ Range[period]*0.3, "\226");
 
       end
	   
		    
	      
	 
end
