-- Id: 12118

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
    indicator:name("CMA difference");
    indicator:description("CMA difference");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
     indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period1", "1. Period", "Period", 14);
	indicator.parameters:addInteger("Period2", "2. Period", "Period", 28);
	indicator.parameters:addString("Mode", "Calculation Mode", "", "Dynamic");
    indicator.parameters:addStringAlternative("Mode", "Dynamic", "", "Dynamic");
    indicator.parameters:addStringAlternative("Mode", "Static", "", "Static");
	 indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPUP", "Up in Up Trend ", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("UPDN", "Down in Up Trend ", "", core.rgb(0, 200, 0));
	 indicator.parameters:addColor("DNUP", "Up in Down Trend ", "", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("DNDN", "Down in Down Trend ", "", core.rgb(200, 0, 0));
	 
	 --indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
   -- indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    --indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
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

-- Routine
function Prepare(nameOnly)
    Mode = instance.parameters.Mode;
    Period1 = instance.parameters.Period1;
	Period2 = instance.parameters.Period2;
    source = instance.source;
   

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period1).. ", " .. tostring(Period2) .. ", " .. tostring(Mode) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("CMA") ~= nil, "Please, download and install CMA.LUA indicator");
    One = core.indicators:create( "CMA" , source, Period1);
	Two = core.indicators:create( "CMA" , source, Period2);
	 first = math.max( (One.DATA:first()+Period1/2),(Two.DATA:first()+Period2/2) ) + 1;

    
        CMAS = instance:addStream("CMAS", core.Bar, name, "CMAS", instance.parameters.UPUP, first);
		CMAS:setPrecision(math.max(2, instance.source:getPrecision()));
	 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode )

 
   
   
   

	 
   if   Mode == "Dynamic"  and period > ( period - (math.max(Period1,Period2) ) /2) then
   
        One:update(core.UpdateAll);
        Two:update(core.UpdateAll);
		
		    if period < first 
			or not  One.DATA:hasData(period) 
			or not  Two.DATA:hasData(period) 	
			then	 
			return;
			end
   
       local i;
		for i= period - (math.max(Period1,Period2) ) /2 , period, 1 do
		
        CMAS[i] = One.DATA[i]-Two.DATA[i];
		
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
	  
	          if period < first 
				or not  One.DATA:hasData(period) 
				or not  Two.DATA:hasData(period) 	
				then	 
				return;
				end
			   
      CMAS[period] = One.DATA[period]-Two.DATA[period];
		
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

