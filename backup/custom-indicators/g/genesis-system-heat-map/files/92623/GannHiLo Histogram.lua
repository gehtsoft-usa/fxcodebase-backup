-- Id: 11119

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60294

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("GannHiLo Histogram");
    indicator:description("GannHiLo Histogram");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
 
	indicator.parameters:addInteger("Period", "Period", "Period", 10);
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
local Histogram;
local Trend;
local  Period,Method;
local MA;
 
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    source = instance.source;
	
	 Period = instance.parameters.Period;
	Method= instance.parameters.Method;
   
    source = instance.source;
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA = core.indicators:create(Method, source, Period);
    first = MA.DATA:first();
	
   
       Trend = instance:addInternalStream(0, 0);
     
   
    Histogram = instance:addStream("Histogram", core.Bar, name .. ".Histogram", "Histogram", instance.parameters.Up, first);
    Histogram:setPrecision(math.max(2, instance.source:getPrecision()));
	 Histogram:addLevel(0, core.LINE_NONE , 1, core.rgb(128, 128, 128));    
	 Histogram:addLevel(1, core.LINE_NONE , 1, core.rgb(128, 128, 128));  	
 

end

function Update(period, mode)

Histogram[period]=1;
MA:update(mode);
if period < first+1 or not source:hasData(period) then
return;
end

  
	 
	
	if source[period]> MA.DATA[period] then
		 Trend[period]=1;
	elseif source[period]< MA.DATA[period] then
		 Trend[period]=-1;
	else	
		 Trend[period]=Trend[period-1];
    end
	
	if( Trend[period]== 1  ) then
		Histogram:setColor(period, instance.parameters.Up);
	else  
		Histogram:setColor(period, instance.parameters.Down);
	end

	 
end

 
