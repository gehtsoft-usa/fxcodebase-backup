-- Id: 8212
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27922

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
function Init()
    indicator:name(" Adaptive Market Level");
    indicator:description(" Adaptive Market Level");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Fractal", "Fractal", "", 6);
    indicator.parameters:addInteger("Lag", "Lag", "", 7);
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Up", "Color of Up AML", "Color of AML", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Color of Down AML", "Color of AML", core.rgb(255, 0, 0))
	indicator.parameters:addColor("Neutral", "Color of Neutral AML", "Color of AML", core.rgb(0, 0, 255))
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Fractal;
local Lag;

local first;
local source = nil;

-- Streams block
local AML = nil;
local fr;
-- Routine
function Prepare(nameOnly)
    Fractal = instance.parameters.Fractal;
    Lag = instance.parameters.Lag;
    source = instance.source;
    first = source:first()+2*Fractal;
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Fractal) .. ", " .. tostring(Lag) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        fr = instance:addInternalStream(0, 0);
    
        AML = instance:addStream("AML", core.Line, name, "AML", instance.parameters.Neutral, first+Lag );
		AML:setWidth(instance.parameters.width);
        AML:setStyle(instance.parameters.style);
		
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first  then
	return;
	end
	
	
	  local  R1 = Range(Fractal,period)/Fractal; 	  
      local  R2 = Range(Fractal,period-Fractal)/Fractal; 
      local  R3 = Range(2*Fractal,period)/(2*Fractal); 
	  
	  
	  local dim = 0;
	  
      if(R1+R2 > 0 and R3 > 0) then 
         dim = (math.log(R1+R2)-math.log(R3) )* 1.44269504088896;
      end		 

      local  alpha = math.exp (-Lag*(dim-1.0));
      if(alpha > 1.0) then alpha = 1.0; end
      if(alpha < 0.01) then alpha = 0.01; end

      local  price = (source.high[period]+source.low[period]+2*source.open[period]+2*source.close[period])/6;
      fr[period] = alpha * price + (1.0 - alpha) * fr[period-1];    
	  
	  if period < first+Lag then
	  return;
	  end
	  

      if(math.abs(fr[period]-fr[period-Lag]) >= Lag*Lag*source:pipSize()) then
           AML[period]  = fr[period];
      else
          AML[period] =   AML[period-1];
     end 
	 	 
	
		if AML[period] >AML[period-1] then
		AML:setColor(period, instance.parameters.Up);
		elseif AML[period] < AML[period-1] then
		AML:setColor(period, instance.parameters.Down);
		else
		AML:setColor(period, instance.parameters.Neutral);
		end
   
   
end


function Range(  Period, period) 
  local min, max;
    min, max=   mathex.minmax (source, period-Period+1, period)  
   return (max - min); 
end

