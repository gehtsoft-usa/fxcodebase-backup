-- Id: 20576

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65742

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



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Simple Moving Average Oscillator");
    indicator:description("Simple Moving Average Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 14,2,2000);
	indicator.parameters:addString("Method", "MA Method", "Method" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "Up Bar Color", "", core.rgb(0, 255, 0));
	  indicator.parameters:addColor("color2", "Down Bar Color", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Period,Method;
local first;
local source = nil;

local MA=nil;


-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Method = instance.parameters.Method;
    source = instance.source;
  

      local name = profile:id() .. "(" .. source:name() .. ", " .. Period.. ", " .. Method  .. ")";
    instance:name(name);
	
	 if   (nameOnly) then
        return;
    end
	 
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	 MA= core.indicators:create(Method, source, Period);
	 first = MA.DATA:first();

	
   
    Oscillator = instance:addStream("Oscillator", core.Bar, name, "Oscillator", instance.parameters.color1, first);
    Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
	
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
 
    if period < first or not source:hasData(period) then
	return;
	end
	
	--///////////////////////
	 MA:update(mode);
	 --//////////////////////
	
	 Oscillator[period]=math.abs(source[period]-MA.DATA[period]);
	 
	 if source[period] > MA.DATA[period] then
	 Oscillator:setColor(period,  instance.parameters.color1);
	 else	 
	  Oscillator:setColor(period,  instance.parameters.color2);
	 end
      
     
end