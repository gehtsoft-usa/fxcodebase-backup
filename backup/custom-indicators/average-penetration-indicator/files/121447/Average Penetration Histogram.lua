-- Id: 22431
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66717

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
    indicator:name("Average Penetration Histogram");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period1", "LB Period", "", 63, 2, 2000);
    indicator.parameters:addInteger("Period2", "Average Period", "", 100, 2, 2000);
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "Up Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("color2", "Down Color", "", core.rgb(255, 0, 0));
 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period1;
local Period2; 
local first;
local source = nil;
 
local Oscillator;  
local Indicator={};
local Low, High;
local  Histogram;
local Top, Bottom;
local Flag=0;
-- Routine
 function Prepare(nameOnly)    
 
    Period1= instance.parameters.Period1; 
	Period2= instance.parameters.Period2; 
	
	
	local Parameters= Period1  ..  ", " ..Period2 ;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
	Low = instance:addInternalStream(0, 0);
    High  = instance:addInternalStream(0, 0);
	Top = instance:addInternalStream(0, 0);
    Bottom  = instance:addInternalStream(0, 0);
    source = instance.source;
    
  
    MA = core.indicators:create("MVA", source.close , Period2);
    
    first=MA.DATA:first() ; 
 
	Histogram = instance:addStream("Histogram" , core.Bar, "  Histogram","  Histogram",instance.parameters.color1, first);
	 
	
	Histogram:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    MA:update(mode);
	
	
    if period < first then
	return;
	end
	
	if source.low[period]< MA.DATA[period]then
	Low[period]=1;
	else
	Low[period]=0;
	end
	
	if source.high[period]> MA.DATA[period]then
	High[period]=1;
	else
	High[period]=0;
	end
	
	
	if period < first+Period1 then
	return;
	end
		
     Top[period]=mathex.sum(High, period-Period1+1, period);
	 Bottom[period]=mathex.sum(Low, period-Period1+1, period);
	 
	 
	
	
	if Top[period] > Bottom[period] then
    Histogram[period] = 1;
    end
 
	if Top[period] < Bottom[period] then
	Histogram[period] = -1
	end
	 
	if Histogram[period] == 1 and (Top[period] - Bottom[period]) < (Top[period-1] - Bottom[period-1]) then
	Histogram[period] = -1
	end
	 
	if Histogram[period] == -1 and (Bottom[period] - Top[period]) < (Bottom[period-1] - Top[period-1]) then
	Histogram[period] = 1
	end
	
	
	if Histogram[period] > 0 then
	 R = 0
	 G = 128
	else
	 R = 128
	 G = 0
	end
	
	Histogram:setColor(period, core.rgb(R, G, 0));
				  
end

 
 