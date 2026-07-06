-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68932

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
    indicator:name("ADX times RSI");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "ADX Period", "", 14, 1, 2000);
    indicator.parameters:addInteger("Period2", "RSI Period", "", 14, 1, 2000);
	
	
	indicator.parameters:addDouble("Level1", "1. Level ", "", 20, 0, 2000);
    indicator.parameters:addDouble("Level2", "2. Level", "", 25, 0, 2000);
	
 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up bar Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down bar Color", "", core.rgb(255, 0,0));
	indicator.parameters:addColor("Neutral", "Neutral bar Color", "", core.rgb(128, 128, 128));
 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Up, Down, Neutral;
local Period1,Period2 ; 
local first;
local source = nil;
local Level1, Level2; 
local Oscillator;  

local ADX, RSI;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period1= instance.parameters.Period1;
    Period2= instance.parameters.Period2;
	Level1= instance.parameters.Level1;
	Level2 = instance.parameters.Level2;
	
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Neutral= instance.parameters.Neutral;
	 
	
	
	local Parameters= Period1..", "..Period2;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	
	ADX = core.indicators:create("ADX", source, Period1);
	RSI = core.indicators:create("RSI", source.close, Period2);
    first=math.max(ADX.DATA:first(),RSI.DATA:first()) ;
	
	 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",Up, first ); 
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)
    ADX:update(mode);
	RSI:update(mode);
 
	if period < source:first() 
	then
	return;
	end
    
	 if ADX.DATA[period]< Level1 then
	 Oscillator:setColor(period, Neutral);
	 else	  
     Oscillator[ period]= ADX.DATA[period]*RSI.DATA[period];
	  
	   if ADX.DATA[period]> Level2 then
	   Oscillator:setColor(period, Up);
	   else
	   Oscillator:setColor(period, Down);
	   end
	   
	 end
	 
				  
end 
