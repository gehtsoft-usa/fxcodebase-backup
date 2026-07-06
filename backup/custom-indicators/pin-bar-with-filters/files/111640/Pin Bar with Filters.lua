-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64539
-- Id: 17858

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
    indicator:name("Pin Bar with Filters");
    indicator:description("Pin Bar Helper");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Calculation");  
	indicator.parameters:addInteger("Nose", "Mimimum Nose Lengt", "Nose Lengt", 75);
	indicator.parameters:addInteger("OppositeNose", "Maximum opposite Nose Lengt", "Nose Lengt", 3); 
    indicator.parameters:addInteger("Extreme", "Extreme Period", "Period", 4);

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
local OppositeNose=nil;
local Nose=nil;
--local Position=nil;
local Size;
local first;
local source = nil;
local Extreme;
-- Streams block
local up = nil;
local down = nil;
local Period, Method, MA,Filter;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    
	Nose= instance.parameters.Nose;
	OppositeNose = instance.parameters.OppositeNose;	 
	Extreme= instance.parameters.Extreme;
	Size= instance.parameters.Size;    
	Filter=  instance.parameters.Filter;	
	Period =  instance.parameters.Period;
	Method =  instance.parameters.Method;
	
	local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
    assert(core.indicators:findIndicator(Method) ~= nil, Method .. " indicator must be installed");
	MA = core.indicators:create(Method, source.close, Period);	
	first = math.max(MA.DATA:first(), Extreme);
	
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
	local Min,Max=mathex.minmax(source, period-1-Extreme+1, period-1);
 
    local Signal=0;
	
	if ((source.high[period]- math.max(source.close[period], source.open[period]) )/Bar)> Nose
	and (( math.min(source.close[period], source.open[period]) - source.low[period] )/Bar)< OppositeNose
	and source.high[period]> Max
	then
	Signal=1;
    end
	
	if (( math.min(source.close[period], source.open[period]) - source.low[period] )/Bar)> Nose
	and ((source.high[period]- math.max(source.close[period], source.open[period]) )/Bar)< OppositeNose
	and source.low[period]< Min
	then
	Signal=-1;
    end
			   
			    
					  
					
								 if Signal==1  
								 and (not Filter  or (Filter and source.close[period]> MA.DATA[period]))
								 then 
								 up:set(period, source.high[period], "\226");								 
								 end
								 
								 
								 if Signal==-1 
								 and (not Filter  or ( Filter and source.close[period]< MA.DATA[period]))
								 then 
								 down:set(period, source.low[period], "\225");
								 end
											 
				 
			   
end