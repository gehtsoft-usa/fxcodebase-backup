--+------------------------------------------------------------------+
--|                               Copyright © 2016, Gehtsoft USA LLC | 
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
    indicator:name("Money_Generator Indicator");
    indicator:description("Money_Generator Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addDouble("KAMAFrame", "KAMA Number of periods", "KAMA Number of periods", 2, 2, 2000);
    indicator.parameters:addDouble("MVAFrame", "MVA Number of periods", "MVA Number of periods", 7, 2, 2000);
	indicator.parameters:addGroup("Style");  
	indicator.parameters:addInteger("Size", "Arrow Size", "Size", 20);
    indicator.parameters:addColor("UP", "Color of Up Trend", "Color of Up Trend", core.rgb(0, 255, 0));
	indicator.parameters:addColor("DOWN", "Color of Down Trend", "Color of Down Trend", core.rgb(255, 0, 0));
	end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local KAMAFrame=nil;
local MVAFrame=nil;

local first;
local source = nil;

-- Streams block
local up = nil;
local down = nil;

local KAMA=nil;
local MVA=nil;

local Size;
-- Routine
function Prepare()
    source = instance.source;
    
	Size=instance.parameters.Size;
	
	MVAFrame=instance.parameters.MVAFrame;
	KAMAFrame=instance.parameters.KAMAFrame;
	
	KAMA  = core.indicators:create("KAMA", source.close, KAMAFrame);
	MVA  = core.indicators:create("MVA", KAMA.DATA, MVAFrame);
	
	first =math.max(KAMA.DATA:first(),MVA.DATA:first());
	
	up = instance:createTextOutput ("UP", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.UP, 0);	
    down = instance:createTextOutput ("DOWN", "Down", "Wingdings",Size, core.H_Center, core.V_Bottom, instance.parameters.DOWN, 0);
	
	local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);	
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    
								    KAMA:update(mode);
									MVA:update(mode);  
									
	up:setNoData (period);
	down:setNoData (period);
									if period < first then
									return;
									end
									
									
						
						           if core.crossesOver(KAMA.DATA, MVA.DATA, period) then
							
									up:set(period, source.high[period], "\225"); 
									
									elseif core.crossesUnder(KAMA.DATA, MVA.DATA, period) then
								   
									down:set(period, source.low[period], "\226"); 	
									
									end

end

