-- Id: 20996
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65941

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
    indicator:name("!X-UK.MA.4");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	 
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("MA_Period", "MA_Period", "", 4, 2, 2000);
    indicator.parameters:addInteger("MA_Sampling_Period", "MA_Sampling_Period", "", 4, 2, 2000);
	
	indicator.parameters:addString("MA_Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("MA_Method", "EMA", "EMA" , "EMA");
    indicator.parameters:addStringAlternative("MA_Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("MA_Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("MA_Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("MA_Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("MA_Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("MA_Method", "WMA", "WMA" , "WMA");
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local MA_Period, MA_Sampling_Period,MA_Method; 
local first;
local source = nil;
 
local Oscillator;  
local Lambda, Alpha;
local MA1,MA2;
-- Routine
 function Prepare(nameOnly)   
 
    MA_Period = instance.parameters.MA_Period;
	MA_Sampling_Period = instance.parameters.MA_Sampling_Period;
	MA_Method = instance.parameters.MA_Method; 
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " ..  MA_Period .. ", " ..  MA_Sampling_Period  .. ", " ..  MA_Method.. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

 
			
    source = instance.source;

	
	Lambda = 1.0 * MA_Period / (1.0 * MA_Sampling_Period);
    Alpha = Lambda * (MA_Period - 1) / (MA_Period - Lambda);
	
	 if (MA_Period * 2 < MA_Sampling_Period) then
	  error( "MA_Period should be >= MA_Sampling_Period * 2.");      
    end
	
    assert(core.indicators:findIndicator(MA_Method) ~= nil, "MA_Method indicator must be installed");
	MA1 = core.indicators:create(MA_Method, source, MA_Period);
    MA2 = core.indicators:create(MA_Method, MA1.DATA, MA_Sampling_Period);
	
	first=MA2.DATA:first();
 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    
	
	
end

-- Indicator calculation routine
function Update(period, mode)
 
	
    if period < first then
	return;
	end
	
	MA1:update(mode);
	MA2:update(mode);
	 
    Oscillator[period]=(Alpha + 1) * MA1.DATA[period] - Alpha * MA2.DATA[period];
				  
end
 