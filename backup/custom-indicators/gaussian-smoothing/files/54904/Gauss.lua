-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32208
-- Id: 8521

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
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Gaussian smoothing");
    indicator:description("gaussian smoothing");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Mode", "Period", "", 50, 1, 2000);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color", "Color of Gauss", "Color of Gauss", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local Mode;
local first;
local source = nil;
local Raw={}
local Norm={};
-- Streams block
local Gauss = nil;

-- Routine
function Prepare(nameOnly)
    Mode=instance.parameters.Mode;  
    source = instance.source;
    first = source:first()+Mode;

    local name = profile:id() .. "(" .. source:name() .. ", " .. Mode .. ")";
    instance:name(name);


	Gaussian(Mode);
	Normalization(Mode);
	
	
    if (not (nameOnly)) then
        Gauss = instance:addStream("Gauss", core.Line, name, "Gauss", instance.parameters.color, first);
		Gauss:setWidth(instance.parameters.width);
        Gauss:setStyle(instance.parameters.style);
    end
end

function  Gaussian( Mode) 
    local i;
	for i = 0, Mode, 1 do
    Raw[i]= (math.exp(-i*i*9/((Mode+1)*(Mode+1))));
	end
   
end

function Normalization(Mode)

local i;
local Sum=0;

  
  for i = 0, Mode, 1 do
  Sum = Sum +Raw[i];
  end
  
  for i = 0, Mode, 1 do
  Norm[i] = Raw[i]/Sum;
  end
  

end



-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first  then
	return;
	end
	
	
        Gauss[period] =Smooth(period);
    
end
function Smooth (period)
	local i;
	local sum =0;
	for i=0, Mode , 1 do
	 sum=sum +Norm[i]*source[period-i];
	end
	return sum;
end

