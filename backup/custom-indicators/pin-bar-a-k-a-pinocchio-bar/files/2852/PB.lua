-- Id: 9903
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1459

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Pin Bar");
    indicator:description("Pin Bar Helper");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Calculation");   
    indicator.parameters:addInteger("BB", "Body Lengt", "Body Lengt", 33);
	indicator.parameters:addInteger("BP", "Body Position", "Body Position", 33);
	indicator.parameters:addInteger("NB", "Nose Lengt", "Nose Lengt", 33);
	indicator.parameters:addBoolean("LA", "Left Eye Check", "Left Eye Check", true);
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Top", "Color of Pin bar", "Color of Pin bar", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Bottom", "Color of Pin bar", "Color of Pin bar", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("Size", "Arrow Size", "Arrow Size", 10);
	
	indicator.parameters:addGroup("Trend Filter");
	indicator.parameters:addBoolean("Filter", "Use Filter", "", true);
	  indicator.parameters:addInteger("Period", "Period", "", 34);
	 indicator.parameters:addString("Method", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "EMA" , "EMA");
   indicator.parameters:addStringAlternative("Method", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method", "WMA", "WMA" , "WMA");
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Body=nil;
local Nose=nil;
local Position=nil;
local Left=nil;
local Size;
local first;
local source = nil;

-- Streams block
local up = nil;
local down = nil;
local Period, Method, MA,Filter;
-- Routine
 function Prepare(nameOnly)
 
    source = instance.source;
    
	Nose= instance.parameters.NB;
	Body = instance.parameters.BB;
	Position= instance.parameters.BP;
	Size= instance.parameters.Size;
    Left =  instance.parameters.LA;
	Filter=  instance.parameters.Filter;
	
	Period =  instance.parameters.Period;
	Method =  instance.parameters.Method;
	
	
	 local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA = core.indicators:create(Method, source.close, Period);	
	first = MA.DATA:first();
   
	
	down = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.Bottom, 0);
    up = instance:createTextOutput ("Down", "Down", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Top, 0);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

if Filter then
MA:update(mode);
end 

    if period < first+1 or not  source:hasData(period) then
	return;
	end
	up:setNoData (period);
	down:setNoData (period);
	
    Calculation (period-1);
	 
end

function Calculation(period)
	local Bar= (source.high[period]- source.low[period])/100;
	
			   if Left then 		   
			   
			   
			        if  math.abs(source.close[period]-source.open[period]) <= Bar* Body then
					  
					
								 if math.max(source.close[period], source.open[period]) <= source.low[period] +  Bar *Position then 
									 if source.high[period]- source.high[period-1] >= Nose *Bar then
										 if source.low[period-1]< math.min (source.open[period],source.close[period]) and source.high[period-1] > math.max (source.open[period],source.close[period]) 
										 and (not Filter  or (Filter and source.close[period]> MA.DATA[period]))
										 then 
										 up:set(period, source.high[period], "\226");
										 end
									 end
								 end
								 if math.min(source.close[period], source.open[period]) >= source.high[period] -  Bar *Position then 
								   
									 if source.low[period-1] - source.low[period]  >= Nose *Bar then
									     if source.high[period-1] >  math.max (source.open[period],source.close[period]) and source.low[period-1] <  math.max (source.open[period],source.close[period]) 
										 and (not Filter  or ( Filter and source.close[period]< MA.DATA[period]))
										 then 
									      down:set(period, source.low[period], "\225");
										  end
									end
								 end			 
					end
			         
			   
			   else
			   
				
					if  math.abs(source.close[period]-source.open[period]) <= Bar* Body then
					
					
								 if math.max(source.close[period], source.open[period]) <= source.low[period] +  Bar *Position then 
									 if source.high[period]- source.high[period-1] >= Nose *Bar
									  and (not Filter or (Filter and source.close[period]> MA.DATA[period]))
									 then
									 up:set(period, source.high[period], "\226");
									 end
								 end
								 if math.min(source.close[period], source.open[period]) >= source.high[period] -  Bar *Position then 
								   
									 if source.low[period-1] - source.low[period]  >= Nose *Bar 
									  and (not Filter or (Filter and source.close[period]< MA.DATA[period]))
									 then
									down:set(period, source.low[period], "\225");
									end
								 end			 
					end
				end	
				
				
--[[				Pin Bar Characteristics
Open and Close of pin bar is within left eye
Open and Close of pin bar are very close together (the closer the better)
Open and Close of pin bar near one end of bar (the closer to an end the better)
A long nose that sticks out from surrounding prices (the longer the better)
Candle preceding is called left eye, and following candle is called right eye.
Option allows you to define the length of the nose as a percentage of the total length of candle,
includ checks of the left eye rule.
If MA filter is ON.
We will only have up signals if Price > MA,
We will only have down signals if Price < MA]]

end