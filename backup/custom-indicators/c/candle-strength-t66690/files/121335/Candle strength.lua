-- Id: 22373
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66690

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
    indicator:name("Candle strength");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Style"); 	
	indicator.parameters:addBoolean("TwoStreams", "Two Streams", "", false);
	
    indicator.parameters:addColor("Up", "Up Bar Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Bar Color", "", core.rgb(255, 0, 0));
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local first;
local source = nil;
local TwoStreams; 
local Oscillator;  
local First, Second; 
local Up, Down; 
-- Routine
 function Prepare(nameOnly)   
 
 
    Profile_Label=""; 
	Up = instance.parameters.Up;
	Down = instance.parameters.Down;
	TwoStreams= instance.parameters.TwoStreams;
	
	
	Profile_Label="";
 
    local name = profile:id() .. "(" ..  instance.source:name() .. Profile_Label  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

  
			
    source = instance.source; 
    first=source:first();
	
	 
   
    if TwoStreams then
	First = instance:addStream("First" , core.Bar, " First"," First",Up, first); 
    First:setPrecision(math.max(2, instance.source:getPrecision()));
	Second = instance:addStream("Second" , core.Bar, " Second"," Second",Down, first); 
    Second:setPrecision(math.max(2, instance.source:getPrecision()));
	else
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",Up, first); 
    Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
	end
    
	
	
end

-- Indicator calculation routine
function Update(period, mode)

  
	
    if period < first then
	return;
	end
	
		
     
	 
	 if TwoStreams then	        
		 local Value=100*(source.open[period]-source.low[period])/(source.high[period]-source.low[period])-50;
	     if source.close[period]> source.open[period] then
		 First[period]=Value;
		 Second[period]=0;
		 else	 
		 Second[period]=Value;
		 First[period]=0;
		 end
		 
	 else
	   
	     Oscillator[period]=100*(source.open[period]-source.low[period])/(source.high[period]-source.low[period])-50;
		 if source.close[period]> source.open[period] then
		 Oscillator:setColor(period, Up);
		 else	 
		 Oscillator:setColor(period, Down);
		 end
	 end
				  
end

