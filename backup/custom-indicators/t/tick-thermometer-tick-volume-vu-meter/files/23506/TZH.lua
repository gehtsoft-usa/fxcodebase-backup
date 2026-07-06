-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=11732
-- Id: 5599

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Ticks Zone Histogram");
    indicator:description("Ticks Zone Histogram");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
   indicator.parameters:addGroup("Levels");
    indicator.parameters:addDouble("H", "High Level", "", 66);
	indicator.parameters:addDouble("L", "Low Level", "", 33);
	
	indicator.parameters:addString("Mode", "Absolute/Relative", " ", "Relative");	
	 indicator.parameters:addStringAlternative("Mode", "Absolute (Ticks)", "", "Absolute");
    indicator.parameters:addStringAlternative("Mode", "Relative (%)", "", "Relative");
	
	 indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("High", "Color of High Volume", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Mid", "Color of Average Volume", "", core.rgb(255, 128, 0));
	 indicator.parameters:addColor("Low", "Color of Low Volume", "", core.rgb(0, 255, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Mode;

local first;
local source = nil;

-- Streams block
local Volume = nil;

local HIGH, LOW;

-- Routine
function Prepare(nameOnly)
    HIGH = instance.parameters.H;
	LOW = instance.parameters.L;
	Mode = instance.parameters.Mode;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(HIGH)  .. ", " .. tostring(LOW).. ")";
    instance:name(name);
	
	 if  not source:supportsVolume() then
       error("Source do not supports trading volume");
    end
	 
    if (not (nameOnly)) then
        Volume = instance:addStream("Volume", core.Bar, name, "Volume", instance.parameters.High, first);
    Volume:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


  if period < source:size()- 1 then
  return;
  end

  local  max=0;	   
   max = mathex.max (source.volume, first, period);
   
   
   
        local i;
	  
			for i = first, source:size()-1 , 1 do
			
		
			   Volume[i] = source.volume[i];
			 
			  
			  
			  local MIN, MAX;
			  
			  if Mode== "Relative" then
			  MIN=  (max/100 ) *LOW;
			  MAX= (max/100 ) *HIGH; 
			  else
			  MIN= LOW;
			  MAX= HIGH;
			  end
			  
			  if Volume[i] > MAX then
			  Volume:setColor(i, instance.parameters.High);	
			  elseif Volume[i]  < MIN then
			  Volume:setColor(i, instance.parameters.Low);	
			  else
			  Volume:setColor(i, instance.parameters.Mid);	
			  end
			end
        
    
end

