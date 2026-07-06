-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68406

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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
    indicator:name("Synthetic Volatility Index");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 20, 1, 2000);
	indicator.parameters:addInteger("ATR_Period", "ATR_Period", "", 1, 1, 2000);
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period;
local first;
local source = nil;
local Data; 
local Oscillator;  
local ATR;
local ATR_Period;
-- Routine
 function Prepare(nameOnly)   
 
    Period= instance.parameters.Period;
	ATR_Period= instance.parameters.ATR_Period;
	
	
	local Parameters= Period .. ", " .. ATR_Period;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

   
			
    source = instance.source;
	
	ATR= core.indicators:create("ATR", source , ATR_Period); 
	 
    first=ATR.DATA:first();
   
  
    Data= instance:addInternalStream(0, 0);

	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first+Period);
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(5, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
   ATR:update(mode);
   
	
	
    if period < first then
	return;
	end
	
	Data[period]= ATR.DATA[period]/source.close[period];
	
    if period < first +Period then
	return;
	end 	
	
     Oscillator[period]=mathex.avg(Data,period-Period+1, period);
				  
end
 
