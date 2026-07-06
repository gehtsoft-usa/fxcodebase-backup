-- Id: 5157
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=8688

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Period Extreme");
    indicator:description("Period Extreme");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PERIOD", "Period", "Period", 0);
	
	
	 indicator.parameters:addGroup("Style");
	 indicator.parameters:addBoolean("Backtrack", "Use completed candles only", "", true);
	  indicator.parameters:addInteger("Size", "Font Size", "", 10);
    indicator.parameters:addColor("up_color", "Color of Crossover", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("dn_color", "Color of Crossunder", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local PERIOD;

local first;
local source = nil;
local Backtrack;
-- Streams block
local up = nil;
local down = nil;
local Size;

-- Routine
function Prepare(nameOnly)
    Backtrack = instance.parameters.Backtrack;
    Size = instance.parameters.Size; 
    PERIOD = instance.parameters.PERIOD;
    source = instance.source;
    first = source:first()+PERIOD +2

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(PERIOD) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
       up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.up_color, 0);
       down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.dn_color, 0);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
 
    if Backtrack then
	period = period-1;
	end

    if period <  first or not  source:hasData(period) then
	return;
	end
	
	
   
     local min=nil;
     local max=nil;				
				 
                min, max = mathex.minmax (source, period-1 - PERIOD+1 -1, period-1);   

      if source.close[period] >  max   then	
	   up:set(period, source.high[period], "\217", source.high[period]);
	   down:setNoData (period);
      elseif source.close[period] <  min  then	
      down:set(period, source.low[period], "\218", source.low[period]);	 
      up:setNoData (period);	  
    end
    
   
end

