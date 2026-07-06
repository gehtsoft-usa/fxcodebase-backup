-- Id: 14651
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62526

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
    indicator:name("Decycler Oscillator");
    indicator:description("Decycler Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 
    indicator.parameters:addGroup("Calculation"); 
 
	indicator.parameters:addDouble("HPPeriod", "HPPeriod ", "HPPeriod", 125);
	indicator.parameters:addDouble("K", "K ", "K", 1);
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Color of Decycler Oscillator ", "Color of Decycler Oscillator", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first1,first2;
local source = nil;
local HPPeriod, K;
-- Streams block
local Decycler_Oscillator;
local alpha1,alpha2;
local HP;
local DecycleOsc;
local Decycle;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first1 = source:first()+2;
    first2 = first1+2;
	HPPeriod=instance.parameters.HPPeriod;
	K=instance.parameters.K;
	 
	 local PI = 3.1415926;
	 local angle1 = 0.707 * 2 * PI / HPPeriod;
     local angle2 = 0.707 * 2 * PI / ( 0.5 * HPPeriod );
	 alpha1 = ( math.cos( angle1 ) + math.sin( angle1 ) - 1 ) / math.cos( angle1 );
	 alpha2 = ( math.cos( angle2 ) + math.sin( angle2 ) - 1 ) / math.cos( angle2 ); 
	
	local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
 
     HP = instance:addInternalStream(first1, 0);
	 Decycle= instance:addInternalStream(first1, 0);
	 DecycleOsc= instance:addInternalStream(first2, 0);
	 
     Decycler_Oscillator  = instance:addStream("Decycler_Oscillator", core.Line, name, "Decycler Oscillator", instance.parameters.color, first2);
    Decycler_Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
	 Decycler_Oscillator:setWidth(instance.parameters.width);
     Decycler_Oscillator:setStyle(instance.parameters.style);
 
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first1 or not source:hasData(period) then
	return;
	end
	 
       
    HP[period] = (1 - alpha1 / 2)*(1 - alpha1 / 2)*(source[period] - 2*source[period-1] + source[period-2]) + 2*(1 - alpha1)*HP[period-1] - (1 - alpha1)*(1 - alpha1)*HP[period-2];
	Decycle[period] = source[period] - HP[period];
	
	
	if period < first2 or not source:hasData(period) then
	return;
	end
	
	DecycleOsc[period] = (1 - alpha2 / 2)*(1 - alpha2 / 2)*(Decycle[period] - 2*Decycle[period-1]+ Decycle[period-2]) + 2*(1 - alpha2)*DecycleOsc[period-1] - (1 -alpha2)*(1 - alpha2)*DecycleOsc[period-2];
	
	
	Decycler_Oscillator[period]=100*K*DecycleOsc[period]/source[period];
end

 