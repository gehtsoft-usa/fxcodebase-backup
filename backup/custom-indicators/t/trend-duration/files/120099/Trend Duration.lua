-- Id: 21752
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66310

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
    indicator:name("Trend Duration");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
     indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 10);
	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	indicator.parameters:addGroup("Style"); 	
	indicator.parameters:addColor("up", "Up Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("down", "Down Color", "", core.rgb(255, 0, 0));


end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local first;
local source = nil;
local Trend;
local Indicator;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end


    source = instance.source;
	
    assert(core.indicators:findIndicator(instance.parameters.Method) ~= nil, instance.parameters.Method .. " indicator must be installed");
	Indicator=core.indicators:create(instance.parameters.Method, source, instance.parameters.Period);
    first = Indicator.DATA:first();
	
	Trend = instance:addStream("Trend", core.Bar, name .. ".Trend", "Trend", instance.parameters.up, first)
    Trend:setPrecision(math.max(2, instance.source:getPrecision()));
   
end

-- Indicator calculation routine
function Update(period, mode)
    Indicator:update(mode);

    if period <= first then	
	return;
	end
	
	
	  
            if source[period]>Indicator.DATA[period]  then
			
					if Trend[period-1]< 0 then
					Trend[period]=1;
					else			
					Trend[period]=Trend[period-1]+1; 
					end
			end
			
			if source[period]<Indicator.DATA[period]  then
			
					if Trend[period-1]> 0 then
					Trend[period]=-1;
					else			
					Trend[period]=Trend[period-1]-1;
					end
			end
			
			if Trend[period]>0 then
			Trend:setColor(period, instance.parameters.up);
			else
			Trend:setColor(period, instance.parameters.down);
			end
			

end

