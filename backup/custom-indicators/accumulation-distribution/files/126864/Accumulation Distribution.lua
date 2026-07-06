-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68563

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
    indicator:name("Accumulation Distribution");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addDouble("Up_Value", "Up Value", "", 0.0001);
    indicator.parameters:addDouble("Down_Value", "Down Value", "", -0.0001);
	
 
 
	
	indicator.parameters:addGroup("Accumulation Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("Distribution Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("Alert Parameters");  
	indicator.parameters:addString("Live", "Execution", "", "End of Turn");
    indicator.parameters:addStringAlternative("Live", "End of Turn", "", "End of Turn");
	indicator.parameters:addStringAlternative("Live", "Live", "", "Live");  

  
	
end

 


-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Up_Value,Down_Value; 
local first;
local source = nil;
 
local Accumulation, Distribution;
-- Routine
 function Prepare(nameOnly)   
 
 
    Up_Value= instance.parameters.Up_Value;
	Down_Value= instance.parameters.Down_Value;
	
	
	local Parameters= Up_Value..", "..Down_Value;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
 
    
			
    source = instance.source; 
    first=source:first() +1;
	
	 
 
	Accumulation = instance:addStream("Accumulation" , core.Line, " Accumulation"," Accumulation",instance.parameters.color1, first );
	Accumulation:setWidth(instance.parameters.width1);
    Accumulation:setStyle(instance.parameters.style1);
    Accumulation:setPrecision(math.max(2, source:getPrecision()));
	
	Distribution = instance:addStream("Distribution" , core.Line, " Distribution"," Distribution",instance.parameters.color2, first );
	Distribution:setWidth(instance.parameters.width2);
    Distribution:setStyle(instance.parameters.style2);
    Distribution:setPrecision(math.max(2, source:getPrecision()));
	
 
	
end
 
 

-- Indicator calculation routine
function Update(period, mode)

 
	if period < source:first()  
	then
	return;
	end 
	
	
	if source[period] > source[period-1] then
	Accumulation[period]=math.abs( Accumulation[period-1]+Up_Value);
	else
	Accumulation[period]=math.abs( Accumulation[period-1]+Down_Value);
	end
	
	if source[period] < source[period-1] then
	Distribution[period]=math.abs( Distribution[period-1]+Up_Value);
	else
	Distribution[period]=math.abs( Distribution[period-1]+Down_Value);
	end
	
	 
end 