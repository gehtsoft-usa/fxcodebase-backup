-- Id: 22314
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=66653

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
    indicator:name("NORMALIZED VOLUME OSCILLATOR");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup(" MA Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 10, 2, 2000);

	
	indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
	
	
	indicator.parameters:addGroup("Levels"); 
	
	indicator.parameters:addDouble("Level1", "1. Level", "", 0);
	indicator.parameters:addDouble("Level2", "2. Level", "", 38.2);
	indicator.parameters:addDouble("Level3", "3. Level", "", 61.8);
	indicator.parameters:addDouble("Level4", "4. Level", "", 100); 
	 
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color1", "1. Level Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("color2", "2. Level Color", "", core.rgb(0, 128, 0));
	indicator.parameters:addColor("color3", "3. Level Color", "",  core.rgb(0, 255, 0));
	indicator.parameters:addColor("color4", "4. Level Color", "", core.rgb(255, 165, 0));
	indicator.parameters:addColor("color5", "5. Level Color", "", core.rgb(255, 0, 0)); 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Method, Period;
local first;
local source = nil;
 
local Oscillator;  
local MA;
local Level1, Level2, Level3, Level4;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    Period= instance.parameters.Period;
    Method= instance.parameters.Method;
	
	Level1= instance.parameters.Level1;
	Level2= instance.parameters.Level2;
	Level3= instance.parameters.Level3;
	Level4= instance.parameters.Level4;
			
    source = instance.source;
    
  
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
    MA = core.indicators:create(Method, source.volume, Period);
    
    first=MA.DATA:first();
	
	 
   
 
	Oscillator = instance:addStream("Oscillator" , core.Bar, " Oscillator"," Oscillator",instance.parameters.color1, first);
	Oscillator:setPrecision(math.max(2, instance.source:getPrecision()));
	 
	
end

-- Indicator calculation routine
function Update(period, mode)

 
 
    MA:update(mode);
	
	
    if period < first then
	return;
	end 
	
	local Normalizevolume= (source.volume[period]/MA.DATA[period]);
    Oscillator[period]= Normalizevolume* 100 - 100;
	    
		if Oscillator[period] <  Level1 then 
		Oscillator:setColor(period, instance.parameters.color1);
		elseif Oscillator[period] < Level2 then
		Oscillator:setColor(period, instance.parameters.color2); 
		elseif Oscillator[period] < Level3 then
		Oscillator:setColor(period, instance.parameters.color3); 
		elseif Oscillator[period] < Level4 then
	    Oscillator:setColor(period, instance.parameters.color4);
		else
		Oscillator:setColor(period, instance.parameters.color5); 
		end
 
				  
end

