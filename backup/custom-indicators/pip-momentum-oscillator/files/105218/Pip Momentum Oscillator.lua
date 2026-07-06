-- Id: 15636
-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=63241


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
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Pip Momentum Oscillator");
    indicator:description("Pip Momentum Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
	
	
    indicator.parameters:addInteger("Period1", "Short MA Period", "Period", 5);
	indicator.parameters:addString("Method1", "Short MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addInteger("Period2", "Long MA Period", "Period", 20);
	indicator.parameters:addString("Method2", "Long MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addDouble("Positive", "Positive Limit", "Limit", 20);
	indicator.parameters:addDouble("Negative", "Negative Limit", "Limit", -20);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up_color", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down_color", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Neutral_color", "Color of Neutral", "Color of Neutral", core.rgb(128, 128, 128));
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Positive, Negative;
local first;
local source = nil;
local PMO;
local Period2, Period1, Method1, Method2;
local MA1, MA2;

-- Routine
function Prepare(nameOnly)
   
    source = instance.source;
    
	Period1=instance.parameters.Period1;
	Period2=instance.parameters.Period2;
	Method1=instance.parameters.Method1;
	Method2=instance.parameters.Method2;
	Positive=instance.parameters.Positive;
	Negative=instance.parameters.Negative;
	
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. Period1 .. ", " .. Method1.. ", " .. Period2 .. ", " .. Method2.. ")";
    instance:name(name);
	
    if   (nameOnly) then
        return;
    end	  
	
	
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
	MA1 = core.indicators:create(Method1, source, Period1);
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
	MA2 = core.indicators:create(Method2, source, Period2);
	
	first = math.max(MA1.DATA:first(), MA2.DATA:first());
	
	
			PMO= instance:addStream("QRO", core.Bar, name .. ".PMO", "PMO",  instance.parameters.Up_color, source:first());	 
    PMO:setPrecision(math.max(2, instance.source:getPrecision()));
         			
    
end
 
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
   
    MA1:update(mode);
	MA2:update(mode);
    if period < first or not source:hasData(period) then
	return;
	end  
	 	
   PMO[period]=  (MA1.DATA[period]-MA2.DATA[period])/source:pipSize(); 
   
   if PMO[period] > Positive then
   PMO:setColor(period,  instance.parameters.Up_color);   
   elseif PMO[period] < Negative then
   PMO:setColor(period,  instance.parameters.Down_color);
   else
   PMO:setColor(period,  instance.parameters.Neutral_color);
   end
   
    
end 