-- Id: 7958

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=24476

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("CMA Momentum");
    indicator:description("CMA Momentum");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
     indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period1", "1. Period", "Period", 14);
	indicator.parameters:addInteger("Period2", "2. Period", "Period", 28);
	indicator.parameters:addInteger("p", "Momentum Period", "Period", 1);
	indicator.parameters:addString("Mode", "Calculation Mode", "", "Dynamic");
    indicator.parameters:addStringAlternative("Mode", "Dynamic", "", "Dynamic");
    indicator.parameters:addStringAlternative("Mode", "Static", "", "Static");
	 indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPUP", "Up in Up Trend ", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("UPDN", "Down in Up Trend ", "", core.rgb(0, 200, 0));
	 indicator.parameters:addColor("DNUP", "Up in Down Trend ", "", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("DNDN", "Down in Down Trend ", "", core.rgb(200, 0, 0));
	 
	 indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period1, Period2;

local first;
local source = nil;
local Mode;
local One, Two;
-- Streams block
local CMAS = nil;
local Raw;
local p;
-- Routine
function Prepare(nameOnly)
    Mode = instance.parameters.Mode;
    Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;
	p = instance.parameters.p;
	
    source = instance.source;
   

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period1).. ", " .. tostring(Period2) .. ", " .. tostring(p) .. ", " .. tostring(Mode) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end

	
	assert(core.indicators:findIndicator("CMA") ~= nil, "Please, download and install CMA.LUA indicator");
    One = core.indicators:create( "CMA" , source, Period1);
	Two = core.indicators:create( "CMA" , source, Period2);
	 first = math.max( (One.DATA:first()+Period1/2),(Two.DATA:first()+Period2/2) ) + 1;

    
	
	    Raw = instance:addInternalStream(source:first(), 0);
        CMAS = instance:addStream("CMAS", core.Line, name, "CMAS", instance.parameters.UPUP, first+p);
		CMAS:setWidth(instance.parameters.width);
        CMAS:setStyle(instance.parameters.style);
		
		CMAS:setPrecision(math.max(2, instance.source:getPrecision()));
 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


   
   
   
    if period < first 	
	then
	return;
	end
	
    
   if   Mode == "Dynamic" and period > (period - (math.max(Period1,Period2) ) /2 ) then
   
   
          One:update(core.UpdateAll);
          Two:update(core.UpdateAll);
       local i;
		for i= period - (math.max(Period1,Period2) ) /2 , period, 1 do
		 
        Raw[i] = One.DATA[i]-Two.DATA[i];
		CMAS[i]=Raw[i] -Raw[i-p]
		if CMAS[i] > 0 then
					if  CMAS[i] > CMAS[i-1] then
					CMAS:setColor(i, instance.parameters.UPUP);
					else
					CMAS:setColor(i, instance.parameters.UPDN);
					end                	
				else
					if  CMAS[i] > CMAS[i-1] then
					CMAS:setColor(i, instance.parameters.DNUP);
					else
					CMAS:setColor(i, instance.parameters.DNDN);
					end       
				end
		
		end
		
		
   else 
   
          One:update(mode);
       Two:update(mode);
   
      Raw[period] = One.DATA[period]-Two.DATA[period];
	  CMAS[period]=Raw[period] -Raw[period-p]
		
		      if CMAS[period] > 0 then
					if  CMAS[period] > CMAS[period-1] then
					CMAS:setColor(period, instance.parameters.UPUP);
					else
					CMAS:setColor(period, instance.parameters.UPDN);
					end                	
				else
					if  CMAS[period] > CMAS[period-1] then
					CMAS:setColor(period, instance.parameters.DNUP);
					else
					CMAS:setColor(period, instance.parameters.DNDN);
					end       
				end
		
		
		
   end
   
   
    
end

