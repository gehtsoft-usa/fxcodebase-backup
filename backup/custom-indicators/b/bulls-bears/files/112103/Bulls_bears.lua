-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64613
-- Id: 18039

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
function Init()
    indicator:name("Bulls_Bears");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
 

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 12);
	
	indicator.parameters:addInteger("Type", "Calculation Method", "Method" , 2);
    indicator.parameters:addIntegerAlternative("Type", "Signal", "Signal" , 2);
    indicator.parameters:addIntegerAlternative("Type", "Value", "Value" , 1);
 
 
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up","Up Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down","Down Color","", core.rgb(255, 0, 0));

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local Bulls_Bears;
local Period;
local first;
local source = nil;
local Raw;
local Calculation;
local Type;
-- Routine
function Prepare(nameOnly)
    
    Period = instance.parameters.Period;
	Type= instance.parameters.Type;
	Show= instance.parameters.Show;
    source = instance.source;
    first = source:first()+Period;
	
 

    local name = profile:id() .. "("     .. Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
    Raw = instance:addInternalStream(0, 0);
	Calculation= instance:addInternalStream(0, 0);
	
    Bulls_Bears = instance:addStream("Bulls_Bears", core.Bar, name .. ".Bulls_Bears", "Bulls_Bears", instance.parameters.Up,first)
    Bulls_Bears:setPrecision(math.max(2, instance.source:getPrecision()));
 
 
  

	
end

 


function Update(period)
   
   if period < first then
   return;
   end
   
    
    
	local min,max= mathex.minmax(source, period-Period+1, period);
	local minmax= (source.high[period] + source.low[period]) / 2.0;
	Calculation[period] =  0.66 * ((minmax - min) / (max - min) - 0.5) + 0.67 * Calculation[period-1];
	Calculation[period] = math.min(math.max(Calculation[period], -0.999), 0.999);
	Raw[period] = math.log((Calculation[period] + 1.0) / (1 - Calculation[period])) / 2.0 + Raw[period-1] / 2.0;  
	
 if  Type == 1 then
 Bulls_Bears[period]=Raw[period];
 else
	  if Raw[period] > 0  then
	  Bulls_Bears[period]=1;
	  else
	  Bulls_Bears[period]=-1;
	  end
 end  
 
 
 if Bulls_Bears[period] > 0 then
 Bulls_Bears:setColor(period, instance.parameters.Up);
 else
  Bulls_Bears:setColor(period, instance.parameters.Down);
 end 
		
end
 

