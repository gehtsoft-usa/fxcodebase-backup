
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=14989

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
    indicator:name("Wide Range Body");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Range Period", "", 3, 1, 100);
    indicator.parameters:addInteger("Shift", "Shift", "Shift", 0, 0 , 100); 
	indicator.parameters:addDouble("MinimumSize", "Minimum Body Size in Pips", "Minimum Size", 0);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UP", "Color of Top", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DOWN", "Color of Bottom", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("NE", "Color of Mixed", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Font Size", "", 10, 1 , 100);	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local Shift; 
local first;
local source = nil;
local Size;
local MinimumSize;
-- Streams block
local up,down, neu,ned;
-- Routine
function Prepare(nameOnly)
    Period = (instance.parameters.Period);
	Size = instance.parameters.Size;
    Shift = instance.parameters.Shift; 
	MinimumSize= instance.parameters.MinimumSize;
    source = instance.source;
    first = source:first()+ Shift  +Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(Shift) .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
  
	 up = instance:createTextOutput ("UP", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.UP, 0);
    down = instance:createTextOutput ("DN", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.DOWN, 0);
	 neu = instance:createTextOutput ("NU", "Ne", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.NE, 0);
	  ned = instance:createTextOutput ("ND", "Ne", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.NE, 0);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not source:hasData(period) then
	return;
	end	
	
	local UP = true;
	local DOWN = true;
	local NEUTRAL = true;

	period = period-Shift;
	
	  down:setNoData (period);
	  up:setNoData (period);
	  neu:setNoData (period);
	  ned:setNoData (period); 

	local i;
	
	if  math.max(source.close[period]- source.open[period])/source:pipSize() < MinimumSize then
	return;
	end
	
	for i = 1, Period , 1 do
	
			if math.abs(source.open[period]  - source.close[period]) < math.abs(source.open[period-i]  - source.close[period-i]) 
			or source.close[period-i] < source.open[period-i]
			or source.close[period]  < source.open[period]
			then
			UP = false;
			end
			
			if math.abs(source.open[period]  - source.close[period]) < math.abs(source.open[period-i]  - source.close[period-i]) 
			or source.close[period-i]  > source.open[period-i]
			or source.close[period]  > source.open[period]
			then
			DOWN = false;
			end
		   
		   	if  math.abs(source.open[period]  - source.close[period]) < math.abs(source.open[period-i]  - source.close[period-i])  then
			NEUTRAL = false;
			end
	end
	
		
	if UP then
	   up:set(period , source.high[period], "\108");  
	   down:setNoData (period);
	   neu:setNoData (period);
	   ned:setNoData (period);
    end

    if DOWN then	
	 down:set(period, source.low[period], "\108");	
	  up:setNoData (period);
	  neu:setNoData (period);
	  ned:setNoData (period);
     end	
	 
	   if NEUTRAL and not UP and not DOWN then	
				 if  source.open[period]  < source.close[period] then
				 neu:set(period, source.low[period], "\108");
				 else	 
				 ned:set(period, source.high[period], "\108");
				 end
	  down:setNoData (period);
	  up:setNoData (period);
     end	
    
end

