-- Id: 21674
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66261

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

function Init()
    indicator:name("Consecutive Candles");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 1 );
	
	
	indicator.parameters:addString("Method", "Method", "Method" , "Pips");
    indicator.parameters:addStringAlternative("Method", "Pips", "Pips" , "Pips");
    indicator.parameters:addStringAlternative("Method", "Count", "Count" , "Count");
  
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "", core.rgb(128, 128, 128));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local first;
local source = nil;
 
local Oscillator;  
local Count;
local Period;
local Method;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
  
  
   
    Period = instance.parameters.Period ;
    Method= instance.parameters.Method;
			
    source = instance.source;
    
    first=source:first();
   
    if Method == "Pips" then
	Count = instance:addInternalStream(0, 0);
	Oscillator = instance:addStream("Oscillator" , core.Bar, "Pips","Pips",instance.parameters.Up, first); 
    Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
    else
	Oscillator = instance:addInternalStream(0, 0);
	Count = instance:addStream("Oscillator" , core.Bar, "Count","Count",instance.parameters.Up, first); 
    Count:setPrecision(math.max(2, instance.source:getPrecision()));
	end
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
  
	
    if period < first then
	return;
	end
	
	 if source[period]> source[period-1] and source[period-1]> source[period-2] then
	 Oscillator[period]=Oscillator[period-1]+math.abs(source[period]- source[period-1])/source:pipSize();
	 Count[period]=Count[period-1]+1;
	 elseif source[period]< source[period-1] and source[period-1]< source[period-2] then
	 Oscillator[period]=Oscillator[period-1]-math.abs(source[period]- source[period-1])/source:pipSize();
	 Count[period]=Count[period-1]-1;
	 elseif source[period]> source[period-1] and source[period-1]< source[period-2] then
     Oscillator[period]=math.abs(source[period]- source[period-1])/source:pipSize();
	 Count[period]=1;
	 elseif source[period]< source[period-1] and source[period-1]> source[period-2] then
     Oscillator[period]=-math.abs(source[period]- source[period-1])/source:pipSize();
	 Count[period]=-1;
     end	 
	 
	 
	 if Oscillator[period]> 0 then
	 Oscillator:setColor(period, instance.parameters.Up);
	 else
	 Oscillator:setColor(period, instance.parameters.Down);
	 end
	 
	 if math.abs(Count[period]) < Period then
	 Oscillator:setColor(period, instance.parameters.Neutral);
	 end
	 
end

