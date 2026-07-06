-- Id: 22271
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32539

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
    indicator:name("AFL Winner Bars");
    indicator:description("AFL Winner Bars");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Periods", "", 10);
    indicator.parameters:addInteger("Average", "Average", "", 5);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Color", "Up Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Color", "Down Color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Period;
local Average;
local Method;
 
local PriceVolume;
local Ratio;
local rsv;
local MA1, MA2;

local open=nil;
local close=nil;
local high=nil;
local low=nil;

local Up, Down;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Average=instance.parameters.Average;
    Method=instance.parameters.Method;
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Average.. ", " .. instance.parameters.Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
  
    PriceVolume = instance:addInternalStream(0, 0); 
	Ratio= instance:addInternalStream(0, 0); 
	rsv= instance:addInternalStream(0, 0); 
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    MA1 = core.indicators:create(Method, rsv, Average );
    MA2 = core.indicators:create(Method, MA1.DATA, Average);
	
	
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    open:setPrecision(math.max(2, instance.source:getPrecision()));
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    high:setPrecision(math.max(2, instance.source:getPrecision()));
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    low:setPrecision(math.max(2, instance.source:getPrecision()));
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first) 
    close:setPrecision(math.max(2, instance.source:getPrecision()));
    instance:createCandleGroup("ZONE", "ZONE", open, high, low, close );
    
end

function Update(period, mode)
   
   
   
   PriceVolume[period]= source.volume[period]*( 2*source.close[period]+source.high[period]+source.low[period])/4;
   
   if period<source:first()+Average then
   return;
   end
   
   local VolumeSum=mathex.sum(source.volume, period-Average+1, period);
   local PriceVolumeSum=mathex.sum(PriceVolume, period-Average+1, period);
   
   Ratio[period]=PriceVolumeSum/VolumeSum;
   
   if period<source:first()+Average +Period then
   return;
   end
   
    local min,max=mathex.minmax(Ratio, period-Period+1, period);
 
    rsv[period]=((Ratio[period]-min)/(max-min))*100;
	
	
	MA1:update(mode);
	MA2:update(mode);
	
	if period<source:first()+Average*3 +Period then
	return;
	end
	
	  high[period]=math.max(MA1.DATA[period],MA2.DATA[period]);
	  low[period]=math.min(MA1.DATA[period],MA2.DATA[period]);
	  open[period] = MA2.DATA[period] ;
	  close[period]=MA1.DATA[period];
	  
	  if MA1.DATA[period]> MA2.DATA[period] then
	  open:setColor(period, Up);
	  else
	  open:setColor(period, Down);
	  end
	  
	 
end 