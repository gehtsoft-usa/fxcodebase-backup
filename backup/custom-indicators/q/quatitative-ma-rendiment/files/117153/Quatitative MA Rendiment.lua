-- Id: 20394

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65651

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Quatitative MA Rendiment");
    indicator:description("Quatitative MA Rendiment");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 5);
	indicator.parameters:addDouble("Multiplier", "Multiplier", "Multiplier", 100);
	
	indicator.parameters:addString("MA_Method", "MA Method", "Method" , "EMA");
    indicator.parameters:addStringAlternative("MA_Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("MA_Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MA_Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MA_Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MA_Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MA_Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MA_Method", "WMA", "WMA" , "WMA");
	
	 indicator.parameters:addInteger("MA_Period", "MA Period", "Period", 5);
	 
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up_color", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down_color", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 5, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block


local first;
local source = nil;
local QRO;
local Period;
local Multiplier;
local MA_Method, MA_Period;
local MA;
-- Routine
function Prepare(nameOnly)
   
    source = instance.source;
   
	Period=instance.parameters.Period;
	
	Multiplier=instance.parameters.Multiplier;
	
	MA_Method=instance.parameters.MA_Method;
	MA_Period=instance.parameters.MA_Period;
	
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
    if (not (nameOnly)) then	  
    assert(core.indicators:findIndicator(MA_Method) ~= nil, MA_Method .. " indicator must be installed");
        MA = core.indicators:create(MA_Method, source, MA_Period);	
        first = MA.DATA:first()+Period;
    
			QRO= instance:addStream("QRO", core.Line, name .. ".QRO", "QRO",  instance.parameters.Up_color, source:first());	 
    QRO:setPrecision(math.max(2, instance.source:getPrecision()));
            QRO:setWidth(instance.parameters.width);
            QRO:setStyle(instance.parameters.style); 			
    end
end
 
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    MA:update(mode);

    if period < first or not source:hasData(period) then
	return;
	end  
   
   
   QRO[period]= Multiplier * math.log (MA.DATA[period]/MA.DATA[period-Period+1]); 
   
   if QRO[period] > QRO[period-1] then
   QRO:setColor(period,  instance.parameters.Up_color);   
   else
   QRO:setColor(period,  instance.parameters.Down_color);
   end
   
    
end 