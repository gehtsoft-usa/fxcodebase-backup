-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7511
-- Id: 4824

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
    indicator:name("Simple Support/Resistance");
    indicator:description("Simple Support/Resistance");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	 indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PERIOD", "Period", "Period", 20);
    indicator.parameters:addInteger("Qualified", "Min You Qualified", "Min You Qualified", 1);
    indicator.parameters:addInteger("Zone", "Zone width (in Pips)", "Zone width (in Pips)", 10);
    indicator.parameters:addString("Find", "Search for ", "Search for ", "Both");	
	 indicator.parameters:addStringAlternative("Find", "Support", "", "Support");
    indicator.parameters:addStringAlternative("Find", "Resistance", "", "Resistance");
    indicator.parameters:addStringAlternative("Find", "Both", "", "Both");
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("width", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	indicator.parameters:addColor("color", "Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addBoolean("Extend", " Line Extend", "", true);
	indicator.parameters:addInteger("estyle", "Extend Line style", "Extend Line style", core.LINE_DASH);
    indicator.parameters:setFlag("estyle", core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local PERIOD;
local Qualified;
local Zone;
local Find;

local first;
local source = nil;

local  color, style, width,estyle;
local SIZE, size;
local Extend;
function Prepare(nameOnly)
     estyle = instance.parameters.estyle;
    Extend = instance.parameters.Extend;
    color = instance.parameters.color;
	style = instance.parameters.style;
	width = instance.parameters.width;
    PERIOD = instance.parameters.PERIOD;
    Qualified = instance.parameters.Qualified;
    Zone = instance.parameters.Zone;
    Find = instance.parameters.Find;
    source = instance.source;
    first = source:first()+  PERIOD +1;
	
	SIZE= Zone *source:pipSize ();
	
	local s,e;
	s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
	size= e-s;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(PERIOD) .. ", " .. tostring(Qualified) .. ", " .. tostring(Zone) .. ", " .. tostring(Find) .. ")";
    instance:name(name);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not  source:hasData(period) or period < source:size()-1 then
      return;
    end

	  
	local MAX=0;
	local MIN=0;
	
	
	  local min, max;
	
	  min, max= mathex.minmax (source, period - PERIOD, period);

	  
	  local i;	  
	  
	  for i = period - PERIOD, period, 1 do
	  
	      if source.high[i] >= max - SIZE and   source.high[i] <= max + SIZE then
		  MAX= MAX +1;
		  end
		  
		   if source.low[i] >= min - SIZE and   source.low[i] <= min + SIZE then
		   MIN= MIN  +1;
		  end
	  
	  end
	  
	  
	  if MIN >= Qualified then
			  if Find ~= "Resistance" then
			  core.host:execute ("drawLine", 1, source:date(period-PERIOD), min, source:date(period), min, color, style, width) ;
				  if Extend then
				   core.host:execute ("drawLine", 2, source:date(period), min, source:date(period) + size * PERIOD, min, color, estyle, width) ;
				  end
			  end	  
	  end
	  
	 if MAX >= Qualified then
			   if Find ~= "Support" then
			    core.host:execute ("drawLine", 3, source:date(period-PERIOD), max, source:date(period), max, color, style, width) ;
				          if Extend then
						   core.host:execute ("drawLine", 4, source:date(period), max, source:date(period) + size * PERIOD, max, color, estyle, width) ;						   
						  end
			   end	  
      end
	  
	  

end