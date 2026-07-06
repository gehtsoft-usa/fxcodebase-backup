-- Id: 19841
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65405


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
    indicator:name("Triple Smoothed Momentum");
    indicator:description("Triple Smoothed Momentum");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("MomentumLength", "Momentum Length", "Momentum Length", 14);
 
 
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Color of Momentum", "Color of Momentum", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local MomentumLength;

local first;
local source = nil;

-- Streams block
local Momentum;
local MA; 
local powSlow=1;
local powFast=2;
-- Routine
function Prepare(nameOnly)
    MomentumLength = instance.parameters.MomentumLength;
    source = instance.source;
  
	
 
    first = source:first();
 
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(MomentumLength) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        Momentum = instance:addStream("Momentum", core.Line, name, "Momentum", instance.parameters.color, first+MomentumLength);
    Momentum:setPrecision(math.max(2, instance.source:getPrecision()));
		Momentum:setWidth(instance.parameters.width);
        Momentum:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)


    if period < first or not  source:hasData(period) then
	return;
	end
	 
 
 
     if period < first+MomentumLength then
	 return;
	 end
	 
	 Momentum[period]=Calculation (period);
	 
    
end


function Calculation (period)


      local  suma = 0;
	  local  sumwa=0;
      local sumb = 0;
      local sumwb=0;
	  local  weight;
	  local k;
	  
	  
	  
         for k=0, MomentumLength, 1 do
         
               weight = MomentumLength-k;
               suma = suma + source[period-k] * math.pow(weight,powSlow);
               sumb  = sumb + source[period-k] * math.pow(weight,powFast);
               sumwa = sumwa + math.pow(weight,powSlow);
               sumwb = sumwb + math.pow(weight,powFast);
         end
   return(sumb/sumwb-suma/sumwa);
end
