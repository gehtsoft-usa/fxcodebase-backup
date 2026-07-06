-- Id: 12117

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=24476

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
    indicator:name("CMA speed");
    indicator:description("CMA speed");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
     indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "Period", 14);
	indicator.parameters:addString("Mode", "Calculation Mode", "", "Dynamic");
    indicator.parameters:addStringAlternative("Mode", "Dynamic", "", "Dynamic");
    indicator.parameters:addStringAlternative("Mode", "Static", "", "Static");
	 indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPUP", "Up in Up Trend ", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("UPDN", "Down in Up Trend ", "", core.rgb(0, 200, 0));
	 indicator.parameters:addColor("DNUP", "Up in Down Trend ", "", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("DNDN", "Down in Down Trend ", "", core.rgb(200, 0, 0));
	 
	-- indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
   -- indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
  --  indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;
local Mode;
local One;
-- Streams block
local CMAD = nil;

-- Routine
function Prepare(nameOnly)
    Mode = instance.parameters.Mode;
    Period = instance.parameters.Period;
    source = instance.source;
   

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Mode) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("CMA") ~= nil, "Please, download and install CMA.LUA indicator");
    One = core.indicators:create( "CMA" , source, Period);
	
	 first = One.DATA:first()+Period/2+ 1;

   
        CMAD = instance:addStream("CMAD", core.Bar, name, "CMAD", instance.parameters.UPUP, first);
		CMAD:setPrecision(math.max(2, instance.source:getPrecision()));
	 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

  

    if period < first then
	return;
	end
	
    
   if   Mode == "Dynamic" and period > (period - (Period ) /2 )then
    One:update(core.UpdateAll);
       local i;
		for i= period - (Period ) /2 , period, 1 do
		
        CMAD[i] = One.DATA[i]-One.DATA[i-1];
		
		if CMAD[i] > 0 then
					if  CMAD[i] > CMAD[i-1] then
					CMAD:setColor(i, instance.parameters.UPUP);
					else
					CMAD:setColor(i, instance.parameters.UPDN);
					end                	
				else
					if  CMAD[i] > CMAD[i-1] then
					CMAD:setColor(i, instance.parameters.DNUP);
					else
					CMAD:setColor(i, instance.parameters.DNDN);
					end       
				end
		
		end
		
		
   else
    One:update(mode);
      CMAD[period] = One.DATA[period]-One.DATA[period-1];
		
		      if CMAD[period] > 0 then
					if  CMAD[period] > CMAD[period-1] then
					CMAD:setColor(period, instance.parameters.UPUP);
					else
					CMAD:setColor(period, instance.parameters.UPDN);
					end                	
				else
					if  CMAD[period] > CMAD[period-1] then
					CMAD:setColor(period, instance.parameters.DNUP);
					else
					CMAD:setColor(period, instance.parameters.DNDN);
					end       
				end
		
		
		
   end
   
   
    
end

