-- Id: 22512
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66853

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
    indicator:name("Gann Market Model");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "1. Period", "", 50, 1, 2000); 
    indicator.parameters:addInteger("Period2", "2. Period", "", 100, 1, 2000); 
	indicator.parameters:addInteger("Period3", "3. Period", "", 200, 1, 2000); 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period1;
local Period2; 
local Period3; 

local first;
local source = nil;
 
local Oscillator;  
local MA1H;
local MA1L;
local MA2H;
local MA2L;
local MA3H;
local MA3L;
-- Routine
 function Prepare(nameOnly)   
 
 
 
 
 
    Period1= instance.parameters.Period1; 
	Period2= instance.parameters.Period2; 
    Period3= instance.parameters.Period3; 
	
	
	local Parameters= Period1 ..  ", " .. Period2 ..  ", " ..Period3;
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..   Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
    
  
    MA1H = core.indicators:create("EMA", source.high, Period1);
	MA1L = core.indicators:create("EMA", source.low, Period1);
	
    MA2H = core.indicators:create("EMA", source.high, Period2);
	MA2L = core.indicators:create("EMA", source.low, Period2);
	
	MA3H = core.indicators:create("EMA", source.high, Period3);
	MA3L = core.indicators:create("EMA", source.low, Period3);
    
    first=math.max(MA1H.DATA:first(), MA2H.DATA:first(), MA3H.DATA:first());
	
	 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",instance.parameters.color, first);
	
	Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
	
	Oscillator:addLevel(0);
	Oscillator:addLevel(1);
	Oscillator:addLevel(2);
	Oscillator:addLevel(3);
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    MA1H:update(mode);
    MA1L:update(mode);  
	
	MA2H:update(mode);
    MA2L:update(mode); 
	
	MA3H:update(mode);
    MA3L:update(mode);
	
	
    if period <= first then
	return;
	end
	
	local a1=MA1H.DATA[period-1];
	local b1=MA1L.DATA[period];
	
	
	local a2=MA2H.DATA[period-1];
	local b2=MA2L.DATA[period-1];
	
	local a3=MA3H.DATA[period-1];
	local b3=MA3L.DATA[period-1];
	
	
	
	 
    local c1, D1;
	local c2, D2;
	local c3, D3;
	
	if source.close[period] > a1 then
	 c1 = 1
	 else
	 if source.close[period] < b1 then
	  c1=-1
	 end
	end
	if c1== -1  then
	 D1 = a1 
	else
	 D1=b1 
	end
	
	
	
	if source.close[period] > a2 then
	 c2 = 1
	 else
	 if source.close[period] < b2 then
	  c2=-1
	 end
	end
	if c2== -1  then
	 D2 = a2
	 
	else
	D2=b2
	 
	end
	 
	 
	if source.close[period] > a3 then
	 c3 = 1
	 else
	 if source.close[period] < b3 then
	  c3=-1
	 end
	end
	if c3== -1  then
	 D3 = a3
	 
	else
	 D3=b3
	 
	end
 
	
    local result, result1, result2;

	
	if D1 < source.close[period] then
	 result = 1
	else
	 result = 0
	end
 
    if D2 < source.close[period] then
	 result1 = 1
	else
	 result1 = 0
	end
 
    if D3 < source.close[period] then
	 result2 = 1
	else
	 result2 = 0
	end
		
     Oscillator[period]=(result+result1+result2);
				  
end
