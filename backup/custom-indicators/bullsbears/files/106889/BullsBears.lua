-- Id: 16283

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63618

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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Bulls Bears");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "No description", 12, 2 , 2000);
	indicator.parameters:addBoolean("Binary" , "Binary", "", true);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Bulls_color", "Color of Bulls", "Color of Bulls", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Bears_color", "Color of Bears", "Color of Bears", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;

-- Streams block
local  BullsBears = nil;
local Raw;
local Flag;
local Calculation;
local Binary;
-- Routine
function Prepare(nameOnly) 
    Period = instance.parameters.Period;
	Binary= instance.parameters.Binary;
    source = instance.source;
    first = source:first();
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	Calculation = instance:addInternalStream(0, 0); 
	Flag = instance:addInternalStream(0, 0);
	Raw = instance:addInternalStream(0, 0);
	
	
	
	
    BullsBears = instance:addStream(" BullsBears", core.Bar, name, " BullsBears", instance.parameters.Bulls_color, first);
    BullsBears:setPrecision(math.max(2, instance.source:getPrecision()));
	 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    if period < Period or not  source:hasData(period) then
	return;
	end
 
	  
	  local min,max=mathex.minmax(source, period-Period+1, period);
	  
      local HighLow = (source.high[period] + source.low[period]) / 2.0;
      Calculation[period] = 0.66 * ((HighLow - min) / (max - min) - 0.5) + 0.67 * Calculation[period-1];
      Calculation[period] = math.min(math.max(Calculation[period], -0.999), 0.999);
	  
	  --***
       Raw[period] = math.log((Calculation[period] + 1.0) / (1 - Calculation[period])) / 2.0 + Raw[period-1] / 2.0;
      
	  
	  if Binary then
		  if Raw[period] > 0 
		  and Raw[period-1] < 0
		  then
		  Flag[period]=1;
		  elseif Raw[period] < 0 
		  and Raw[period-1] > 0
		  then
		  Flag[period]=-1;
		  else
		  Flag[period]=Flag[period-1];
		  end 
		  
	  
	      BullsBears[period] =Flag[period];
	  else
	  BullsBears[period]=Raw[period];
      end	 
	  
	  if BullsBears[period] > 0 then
	  BullsBears:setColor(period,  instance.parameters.Bulls_color);
	  else
	  BullsBears:setColor(period,  instance.parameters.Bears_color);
	  end
       
end

