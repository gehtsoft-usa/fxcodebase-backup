-- Id: 3336
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3648

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
    indicator:name("Anchored Momentum");
    indicator:description("Anchored Momentum");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("One", "First Period", "", 2,2, 2000);
    indicator.parameters:addInteger("Two", "Second Period", "", 42, 2, 2000);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Method1", "First Method", "", "SMMA");
	indicator.parameters:addStringAlternative("Method1", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method1", "MWA", "", "WMA");
    indicator.parameters:addStringAlternative("Method1", "LWMA", "", "LWMA");
	indicator.parameters:addStringAlternative("Method1", "WMA", "", "WMA");
	indicator.parameters:addStringAlternative("Method1", "Price", "", "Price");
	
	indicator.parameters:addString("Method2", "Second Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method2", "MWA", "", "WMA");
    indicator.parameters:addStringAlternative("Method2", "LWMA", "", "LWMA");
	indicator.parameters:addStringAlternative("Method2", "WMA", "", "WMA");
	indicator.parameters:addStringAlternative("Method2", "SMMA", "", "SMMA");
	--indicator.parameters:addStringAlternative("Method2", "Price", "", "Price");
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP_color", "Color of UP", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DOWN_color", "Color of DOWN", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local One;
local Two;
local Method1, Method2;

local first;
local source = nil;

-- Streams block
local indicator={};
local AM = nil;

-- Routine
function Prepare(nameOnly)
    Method1 = instance.parameters.Method1;
	Method2 = instance.parameters.Method2;
    One = instance.parameters.One;
    Two = instance.parameters.Two;
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(One) .. ", " .. tostring(Two) .."," .. Method1..", ".. Method2.. ")";
    instance:name(name);

    if (not (nameOnly)) then
	    
		if Method1 ~= "Price" then
		indicator[1]=  core.indicators:create(Method1, source, One);
		first= math.max(indicator[1].DATA:first(), first);
		end
		
		--if Method2 ~= "Price" then
		indicator[2]=  core.indicators:create(Method2, source, Two);
		first= math.max(indicator[2].DATA:first(), first);
		--end
		
        AM = instance:addStream("AM", core.Bar, name, "AM", instance.parameters.UP_color,first );
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period >= first and source:hasData(period) then
        
	 local a,b;

	  if Method1 ~= "Price" then
	         indicator[1]:update(mode);
	         if not indicator[1].DATA:hasData(period)  then
		     return;
		     end
		a = indicator[1].DATA[period];
	  else
	   a = source[period];
	  end
	  
	 -- if Method2 ~= "Price" then
	           indicator[2]:update(mode);
		      if not indicator[2].DATA:hasData(period)  then
			  return;
			  end
		b = indicator[2].DATA[period];
	 -- else
	--   b = source[period];		  
	 -- end 
	 
	 
		
		AM[period] =  100*((a / b)-1);
		
		if AM[period] > AM[period-1] then
		AM:setColor(period, instance.parameters.UP_color);
        else
		AM:setColor(period, instance.parameters.DOWN_color);
        end 		
    end
end

